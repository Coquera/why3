(* This is the main file of gnatwhy3 *)

(* Gnatwhy3 does the following:
   - it reads a .mlw file that was generated by gnat2why
   - it computes the VCs
   - it runs the selected provers on each VC.
   - it generates a summary of what was proved and not proved in JSON format
 and outputs this JSON format to stdout (for gnat2why to read).

   See gnat_objectives.mli for the notion of objective and goal.

   See gnat_report.mli for the JSON format

   gnat_main can be seen as the "driver" for gnatwhy3. Much of the
   functionality is elsewhere.
   Specifically, this file does:
      - compute the objective that belongs to a goal/VC
      - drive the scheduling of VCs, and handling of results
      - output the messages
*)

open Why3
open Term


let search_labels =
  let extract_wrap l =
    match Gnat_expl.extract_check l with
    | None -> []
    | Some x -> [x] in
  let search = Termcode.search_labels extract_wrap in
  fun f ->
    try
    begin match search f with
    | [] -> None
    | [x] -> Some x
    | _ -> assert false
    end
  with Exit -> None

let rec is_trivial fml =
   (* Check wether the formula is trivial.  *)
   match fml.t_node with
   | Ttrue -> true
   | Tquant (_,tq) ->
         let _,_,t = t_open_quant tq in
         is_trivial t
   | Tlet (_,tb) ->
         let _, t = t_open_bound tb in
         is_trivial t
   | Tbinop (Timplies,_,t2) ->
         is_trivial t2
   | Tcase (_,tbl) ->
         List.for_all (fun b ->
            let _, t = t_open_branch b in
            is_trivial t) tbl
   | _ -> false

let register_goal goal =
   (* Register the goal by extracting the explanation and trace. If the goal is
    * trivial, do not register *)
     match Session.goal_task_option goal with
     | None ->
         Gnat_objectives.set_not_interesting goal
     | Some task ->
         let fml = Task.task_goal_fmla task in
         match is_trivial fml, search_labels fml with
         | true, None ->
               Gnat_objectives.set_not_interesting goal
         | _, None ->
               Gnat_util.abort_with_message ~internal:true
               "Task has no tracability label."
         | _, Some c ->
             if c.Gnat_expl.already_proved then
               Gnat_objectives.set_not_interesting goal
             else
               Gnat_objectives.add_to_objective c goal

let rec handle_vc_result goal result =
   (* This function is called when the prover has returned from a VC.
       goal           is the VC that the prover has dealt with
       result         a boolean, true if the prover has proved the VC
       prover_result  the actual proof result, to extract statistics
   *)
   let obj, status = Gnat_objectives.register_result goal result in
   match status with
   | Gnat_objectives.Proved -> ()
   | Gnat_objectives.Not_Proved -> ()
   | Gnat_objectives.Work_Left ->
       List.iter (create_manual_or_schedule obj) (Gnat_objectives.next obj)
   | Gnat_objectives.Counter_Example ->
     (* In this case, counterexample prover will be never None *)
     let prover_ce = (Opt.get Gnat_config.prover_ce) in
     Gnat_objectives.schedule_goal_with_prover ~cntexample:true goal
       prover_ce

and interpret_result pa pas =
   (* callback function for the scheduler, here we filter if an interesting
      goal has been dealt with, and only then pass on to handle_vc_result *)
   match pas with
   | Session.Done r ->
         let goal = pa.Session.proof_parent in
         let answer = r.Call_provers.pr_answer in
         if answer = Call_provers.HighFailure &&
	   not Gnat_config.counterexamples then
           Gnat_report.add_warning r.Call_provers.pr_output;
         handle_vc_result goal (answer = Call_provers.Valid)
   | _ ->
         ()

and create_manual_or_schedule obj goal =
  match Gnat_config.manual_prover with
  | Some _ when Gnat_objectives.goal_has_splits goal &&
                goal.Session.goal_verified = None ->
                  handle_vc_result goal false
  | Some p when Gnat_manual.is_new_manual_proof goal &&
                goal.Session.goal_verified = None ->
                  let _ = Gnat_manual.create_prover_file goal obj p in
                  ()
  | _ -> schedule_goal goal

and schedule_goal (g : Gnat_objectives.goal) =
   (* schedule a goal for proof - the goal may not be scheduled actually,
      because we detect that it is not necessary. This may have several
      reasons:
         * command line given to skip proofs
         * goal already proved
         * goal already attempted with identical options
   *)
   if (Gnat_config.manual_prover <> None
       && g.Session.goal_verified = None) then begin
      actually_schedule_goal g
   (* then implement reproving logic *)
   end else begin
      (* Maybe the goal is already proved *)
      if g.Session.goal_verified <> None then begin
         handle_vc_result g true
      (* Maybe there was a previous proof attempt with identical parameters *)
      end else if Gnat_objectives.all_provers_tried g then begin
         (* the proof attempt was necessarily false *)
         handle_vc_result g false
      end else begin
         actually_schedule_goal g
      end;
   end

and actually_schedule_goal g =
  Gnat_objectives.schedule_goal ~cntexample:false g

let handle_obj obj =
   if Gnat_objectives.objective_status obj <> Gnat_objectives.Proved then begin
      match Gnat_objectives.next obj with
      | [] -> ()
      | l ->
         List.iter (create_manual_or_schedule obj) l
   end

let normal_handle_one_subp subp =
   if Gnat_objectives.matches_subp_filter subp then begin
     Gnat_objectives.init_subp_vcs subp;
     Gnat_objectives.iter_leaf_goals subp register_goal
   end

let all_split_subp subp =
   if Gnat_objectives.matches_subp_filter subp then begin
     Gnat_objectives.init_subp_vcs subp;
     Gnat_objectives.iter_leaf_goals subp register_goal;
     Gnat_objectives.all_split_leaf_goals ();
     Gnat_objectives.clear ()
   end

let filter_model m trace =
  if trace = Gnat_loc.S.empty then
    m
  else
    let trace_to_list trace =
    (* Build list of locations (pairs of filename and line number) from trace *)
      Gnat_loc.S.fold
        (fun loc list ->
          let sloc = Gnat_loc.orig_loc loc in
          let col = Gnat_loc.get_col sloc in
          let pos = Why3.Loc.user_position
            (Gnat_loc.get_file sloc) (Gnat_loc.get_line sloc) col col in
          (pos::list)
        )
        trace
        [] in
    let positions = trace_to_list trace in
    Model_parser.model_for_positions_and_decls m ~positions

let report_messages obj =
  let result =
    if Gnat_objectives.session_proved_status obj  then
      Gnat_report.Proved (Gnat_objectives.Save_VCs.extract_stats obj)
    else
      let unproved_pa = Gnat_objectives.session_find_unproved_pa obj in
      let unproved_goal =
        Opt.map (fun pa -> pa.Session.proof_parent) unproved_pa in
      let unproved_task = Opt.map Session.goal_task unproved_goal in
      let (tracefile, trace) =
        match unproved_goal, Gnat_config.proof_mode with
        | Some goal, (Gnat_config.Progressive | Gnat_config.Per_Path) ->
            Gnat_objectives.Save_VCs.save_trace goal
        | _ -> ("", Gnat_loc.S.empty) in
      let model =
        match unproved_pa with
        | Some { Session.proof_state =
                   Session.Done { Call_provers.pr_answer =
                     Call_provers.Unknown (_, Some Call_provers.Resourceout)} }
          ->
            (* Resource limit was hit, the model is not useful *)
            None
        | Some { Session.proof_state =
                  Session.Done ({ Call_provers.pr_answer = _ } as r) } ->
             Some (filter_model r.Call_provers.pr_model trace)
        | _ -> None
      in
      let manual_info =
        match unproved_pa with
        | None -> None
        | Some pa -> Gnat_manual.manual_proof_info pa in
      Gnat_report.Not_Proved (unproved_task, model, tracefile, manual_info) in
  Gnat_report.register obj result

let _ =
   (* This is the main code. We read the file into the session if not already
      done, we apply the split_goal transformation when needed, and we schedule
      the first VC of all objectives. When done, we save the session.
   *)
   (* save session on interrupt initiated by the user *)
   let save_session_and_exit signum =
     (* ignore all SIGINT, SIGHUP and SIGTERM, which may be received when
        gnatprove is called in GPS, so that the session file is always saved *)
     Sys.set_signal Sys.sigint Sys.Signal_ignore;
     Sys.set_signal Sys.sighup Sys.Signal_ignore;
     Sys.set_signal Sys.sigterm Sys.Signal_ignore;
     Gnat_objectives.save_session ();
     exit signum
   in
   Sys.set_signal Sys.sigint (Sys.Signal_handle save_session_and_exit);

   try
     Util.init_timing ();
     Gnat_sched.init ();
     Gnat_objectives.init ();
     Util.timing_step_completed "gnatwhy3.init";
     match Gnat_config.proof_mode with
     | Gnat_config.Progressive
     | Gnat_config.Per_Path
     | Gnat_config.Per_Check ->
        Gnat_objectives.iter_subps normal_handle_one_subp;
        Util.timing_step_completed "gnatwhy3.register_vcs";
        if Gnat_config.replay then begin
          Gnat_objectives.replay ();
          Gnat_objectives.do_scheduled_jobs (fun _ _ -> ());
        end else begin
          Gnat_objectives.iter handle_obj;
          Util.timing_step_completed "gnatwhy3.schedule_vcs";
          Gnat_objectives.do_scheduled_jobs interpret_result;
          Util.timing_step_completed "gnatwhy3.run_vcs";
        end;
        Gnat_objectives.save_session ();
        Util.timing_step_completed "gnatwhy3.save_session";
        Gnat_objectives.iter report_messages;
        Gnat_report.print_messages ()
     | Gnat_config.All_Split ->
        Gnat_objectives.iter_subps all_split_subp
     | Gnat_config.No_WP ->
        (* we should never get here *)
        ()
    with e ->
       let s = Pp.sprintf "%a.@." Exn_printer.exn_printer e in
       Gnat_util.abort_with_message ~internal:true s
