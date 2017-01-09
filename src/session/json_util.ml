open Itp_server
open Controller_itp
open Call_provers

(* TODO match exceptions *)

(* Simplified json value *)
type json_object =
  | Assoc of (string * json_object) list
  | Array of json_object list
  | Int of int
  | Bool of bool
  | Float of float
  | String of string
  | Empty

let convert_prover_to_json (p: Whyconf.prover) =
  Assoc ["prover_name", String p.Whyconf.prover_name;
         "prover_version", String p.Whyconf.prover_version;
         "prover_altern", String p.Whyconf.prover_altern]

let convert_infos (i: global_information) =
  Assoc ["provers", Array (List.map (fun x -> String x) i.provers);
         "transformations", Array (List.map (fun x -> String x) i.transformations);
         "strategies", Array (List.map (fun x -> String x) i.strategies);
         "commands", Array (List.map (fun x -> String x) i.commands)]

let convert_prover_answer (pa: prover_answer) =
  match pa with
  | Valid             -> String "Valid"
  | Invalid           -> String "Invalid"
  | Timeout           -> String "Timeout"
  | OutOfMemory       -> String "OutOfMemory"
  | StepLimitExceeded -> String "StepLimitExceeded"
  | Unknown _         -> String "Unknown"
  | Failure _         -> String "Failure"
  | HighFailure       -> String "HighFailure"

let convert_limit (l: Call_provers.resource_limit) =
  Assoc ["limit_time", Int l.Call_provers.limit_time;
         "limit_mem", Int l.Call_provers.limit_mem;
         "limit_steps", Int l.Call_provers.limit_steps]

let convert_unix_process (ps: Unix.process_status) =
  match ps with
  | Unix.WEXITED _   -> String "WEXITED"
  | Unix.WSIGNALED _ -> String "WSIGNALED"
  | Unix.WSTOPPED _  -> String "WSTOPPED"

let convert_model (m: Model_parser.model) =
  String (Pp.string_of (fun fmt m -> Model_parser.print_model fmt m) m)

(* TODO pr_model should have a different format *)
let convert_proof_result (pr: prover_result) =
  Assoc ["pr_answer", convert_prover_answer pr.pr_answer;
         "pr_status", convert_unix_process pr.pr_status;
         "pr_output", String pr.pr_output;
         "pr_time", Float pr.pr_time;
         "pr_steps", Int pr.pr_steps;
         "pr_model", convert_model pr.pr_model]

let convert_proof_attempt (pas: proof_attempt_status) =
  match pas with
  | Unedited ->
      Assoc ["proof_attempt", String "Unedited"]
  | JustEdited ->
      Assoc ["proof_attempt", String "JustEdited"]
  | Interrupted ->
      Assoc ["proof_attempt", String "Interrupted"]
  | Scheduled ->
      Assoc ["proof_attempt", String "Scheduled"]
  | Running ->
      Assoc ["proof_attempt", String "Running"]
  | Done pr ->
      Assoc ["proof_attempt", String "Done";
             "prover_result", convert_proof_result pr]
  | Controller_itp.InternalFailure e ->
      Assoc ["proof_attempt", String "InternalFailure";
             "exception", String (Pp.string_of Exn_printer.exn_printer e)]
  | Uninstalled p ->
      Assoc ["proof_attempt", String "Uninstalled";
             "prover", convert_prover_to_json p]

let convert_update u =
  match u with
  | Proved b ->
      Assoc ["update_info", String "Proved";
             "proved", Bool b]
  | Proof_status_change (pas, b, l) ->
      Assoc ["update_info", String "Proof_status_change";
             "proof_attempt", convert_proof_attempt pas;
             "obsolete", Bool b;
             "limit", convert_limit l]

let convert_notification_constructor n =
  match n with
  | New_node _    -> String "New_node"
  | Node_change _ -> String "Node_change"
  | Remove _      -> String "Remove"
  | Initialized _ -> String "Initialized"
  | Saved         -> String "Saved"
  | Message _     -> String "Message"
  | Dead _        -> String "Dead"
  | Task _        -> String "Task"

let convert_node_type nt =
  match nt with
  | NRoot           -> String "NRoot"
  | NFile           -> String "NFile"
  | NTheory         -> String "NTheory"
  | NTransformation -> String "NTransformation"
  | NGoal           -> String "NGoal"
  | NProofAttempt   -> String "NProofAttempt"

let convert_request_constructor (r: ide_request) =
  match r with
  | Command_req _        -> String "Command_req"
  | Prove_req _          -> String "Prove_req"
  | Transform_req _      -> String "Transform_req"
  | Strategy_req _       -> String "Strategy_req"
  | Open_session_req _   -> String "Open_session_req"
  | Add_file_req _       -> String "Add_file_req"
  | Set_max_tasks_req _  -> String "Set_max_tasks_req"
  | Get_task _           -> String "Get_task"
  | Remove_subtree _     -> String "Remove_subtree"
  | Copy_paste _         -> String "Copy_paste"
  | Copy_detached _      -> String "Copy_detached"
  | Get_Session_Tree_req -> String "Get_Session_Tree_req"
  | Save_req             -> String "Save_req"
  | Reload_req           -> String "Reload_req"
  | Replay_req           -> String "Replay_req"
  | Exit_req             -> String "Exit_req"

let print_request_to_json (r: ide_request): json_object =
  let cc = convert_request_constructor in
  match r with
  | Command_req (nid, s) ->
      Assoc ["ide_request", cc r;
             "node_ID", Int nid;
             "command", String s]
  | Prove_req (nid, p, l) ->
      Assoc ["ide_request", cc r;
             "node_ID", Int nid;
             "prover", String p;
             "limit", convert_limit l]
  | Transform_req (nid, tr, args) ->
      Assoc ["ide_request", cc r;
             "node_ID", Int nid;
             "transformation", String tr;
             "arguments", Array (List.map (fun x -> String x) args)]
  | Strategy_req (nid, str) ->
      Assoc ["ide_request", cc r;
             "node_ID", Int nid;
             "strategy", String str]
  | Open_session_req f ->
      Assoc ["ide_request", cc r;
             "file", String f]
  | Add_file_req f ->
      Assoc ["ide_request", cc r;
             "file", String f]
  | Set_max_tasks_req n ->
      Assoc ["ide_request", cc r;
             "tasks", Int n]
  | Get_task n ->
      Assoc ["ide_request", cc r;
             "node_ID", Int n]
  | Remove_subtree n ->
      Assoc ["ide_request", cc r;
             "node_ID", Int n]
  | Copy_paste (from_id, to_id) ->
      Assoc ["ide_request", cc r;
             "node_ID", Int from_id;
             "node_ID", Int to_id]
  | Copy_detached from_id ->
      Assoc ["ide_request", cc r;
             "node_ID", Int from_id]
  | Get_Session_Tree_req ->
      Assoc ["ide_request", cc r]
  | Save_req ->
      Assoc ["ide_request", cc r]
  | Reload_req ->
      Assoc ["ide_request", cc r]
  | Replay_req ->
      Assoc ["ide_request", cc r]
  | Exit_req ->
      Assoc ["ide_request", cc r]

let convert_constructor_message (m: message_notification) =
  match m with
  | Proof_error _     -> String "Proof_error"
  | Transf_error _    -> String "Transf_error"
  | Strat_error _     -> String "Strat_error"
  | Replay_Info _     -> String "Replay_Info"
  | Query_Info _      -> String "Query_Info"
  | Query_Error _     -> String "Query_Error"
  | Help _            -> String "Help"
  | Information _     -> String "Information"
  | Task_Monitor _    -> String "Task_Monitor"
  | Error _           -> String "Error"
  | Open_File_Error _ -> String "Open_File_Error"


let convert_message (m: message_notification) =
  let cc = convert_constructor_message in
  match m with
  | Proof_error (nid, s) ->
      Assoc ["mess_notif", cc m;
             "node_ID", Int nid;
             "error", String s]
  | Transf_error (nid, s) ->
      Assoc ["mess_notif", cc m;
             "node_ID", Int nid;
             "error", String s]
  | Strat_error (nid, s) ->
      Assoc ["mess_notif", cc m;
             "node_ID", Int nid;
             "error", String s]
  | Replay_Info s ->
      Assoc ["mess_notif", cc m;
             "replay_info", String s]
  | Query_Info (nid, s) ->
      Assoc ["mess_notif", cc m;
             "node_ID", Int nid;
             "qinfo", String s]
  | Query_Error (nid, s) ->
      Assoc ["mess_notif", cc m;
             "node_ID", Int nid;
             "qerror", String s]
  | Help s ->
      Assoc ["mess_notif", cc m;
             "qhelp", String s]
  | Information s ->
      Assoc ["mess_notif", cc m;
             "information", String s]
  | Task_Monitor (n, k, p) ->
      Assoc ["mess_notif", cc m;
             "monitor", Array [Int n; Int k; Int p]]
  | Error s ->
      Assoc ["mess_notif", cc m;
             "error", String s]
  | Open_File_Error s ->
      Assoc ["mess_notif", cc m;
             "open_error", String s]

let print_notification_to_json (n: notification): json_object =
  let cc = convert_notification_constructor in
  match n with
  | New_node (nid, parent, node_type, name) ->
      Assoc ["notification", cc n;
             "node_ID", Int nid;
             "parent_ID", Int parent;
             "node_type", convert_node_type node_type;
             "name", String name]
  | Node_change (nid, update) ->
      Assoc ["notification", cc n;
             "node_ID", Int nid;
             "update", convert_update update]
  | Remove nid ->
      Assoc ["notification", cc n;
             "node_ID", Int nid]
  | Initialized infos ->
      Assoc ["notification", cc n;
             "infos", convert_infos infos]
  | Saved ->
      Assoc ["notification", cc n]
  | Message m ->
      Assoc ["notification", cc n;
             "message", convert_message m]
  | Dead s ->
      Assoc ["notification", cc n;
             "message", String s]
  | Task (nid, s) ->
      Assoc ["notification", cc n;
             "node_ID", Int nid;
             "task", String s]

(* Needs to print strings as JSON strings. So we have to convert them before
  they are printed *)
let convert_string (s: string) =
  Str.global_replace (Str.regexp "/") "\\/" s

let rec print_pair fmt ((s, j): string * json_object) : unit =
  Format.fprintf fmt "\"%s\" : %a" s print_json j

and print_json fmt (j: json_object) : unit  =
  match j with
  | Assoc l -> Format.fprintf fmt "{ %a }" (Pp.print_list Pp.comma print_pair) l
  | Array l -> Format.fprintf fmt "[ %a ]" (Pp.print_list Pp.comma print_json) l
  | Int x -> Format.fprintf fmt "%d" x
  | Bool b -> Format.fprintf fmt "%b" b
  | Float f -> Format.fprintf fmt "%f" f
  | String s -> Format.fprintf fmt "\"%s\"" (convert_string (String.escaped s))
  | Empty -> Format.fprintf fmt "null"

let print_notification fmt (n: notification) =
  Format.fprintf fmt "%a" print_json (print_notification_to_json n)

let print_request fmt (r: ide_request) =
  Format.fprintf fmt "%a" print_json (print_request_to_json r)

exception NotProver

let parse_prover_from_json (j: json_object) =
  match j with
  | Assoc ["prover_name", String pn;
           "prover_version", String pv;
           "prover_altern", String pa] ->
            {Whyconf.prover_name = pn; prover_version = pv; prover_altern = pa}
  | _ -> raise NotProver

exception NotLimit

let parse_limit_from_json (j: json_object) =
  match j with
  | Assoc ["limit_time", Int t;
           "limit_mem", Int m;
           "limit_steps", Int s] ->
             {limit_time = t; limit_mem = m; limit_steps = s}
  | _ -> raise NotLimit

exception NotRequest of string

let parse_request (constr: string) l =
  match constr, l with
  | "Command_req", ["node_ID", Int nid;
                    "command", String s] ->
    Command_req (nid, s)
  | "Prove_req", ["node_ID", Int nid;
                  "prover", String p;
                  "limit", l] ->
    Prove_req (nid, p, parse_limit_from_json l)
  | "Transform_req", ["node_ID", Int nid;
                      "transformation", String tr;
                      "arguments", Array args] ->
    Transform_req (nid, tr,
                   List.map (fun x ->
                     match x with
                     | String t -> t
                     | _ -> raise (NotRequest "")) args)
  | "Strategy_req", ["node_ID", Int nid;
                     "strategy", String str] ->
    Strategy_req (nid, str)
  | "Open_session_req", ["file", String f] ->
    Open_session_req f
  | "Add_file_req", ["file", String f] ->
    Add_file_req f
  | "Set_max_tasks_req", ["tasks", Int n] ->
    Set_max_tasks_req n
  | "Get_task", ["node_ID", Int n] ->
    Get_task n
  | "Remove_subtree", ["node_ID", Int n] ->
    Remove_subtree n
  | "Copy_paste", ["node_ID", Int from_id; "node_ID", Int to_id] ->
    Copy_paste (from_id, to_id)
  | "Copy_detached", ["node_ID", Int n] ->
    Copy_detached n
  | "Get_Session_Tree_req", [] ->
    Get_Session_Tree_req
  | "Save_req", [] ->
    Save_req
  | "Reload_req", [] ->
    Reload_req
  | "Replay_req", [] ->
    Replay_req
  | "Exit_req", [] ->
    Exit_req
  | _ -> raise (NotRequest "")

let parse_request (j: json_object): ide_request =
  match j with
  | Assoc (("ide_request", String constr) :: l) ->
      parse_request constr l
  | _ -> let s =Pp.string_of print_json j in
    begin Format.eprintf "BEGIN \n %s \nEND\n@." s; raise (NotRequest s); end

exception NotNodeType

let parse_node_type_from_json j =
  match j with
  | String "NRoot"           -> NRoot
  | String "NFile"           -> NFile
  | String "NTheory"         -> NTheory
  | String "NTransformation" -> NTransformation
  | String "NGoal"           -> NGoal
  | String "NProofAttempt"   -> NProofAttempt
  | _                        -> raise NotNodeType

exception NotProverAnswer

let parse_prover_answer j =
  match j with
  | String "Valid"             -> Valid
  | String "Invalid"           -> Invalid
  | String "Timeout"           -> Timeout
  | String "OutOfMemory"       -> OutOfMemory
  | String "StepLimitExceeded" -> StepLimitExceeded
  | String "Unknown"           -> raise NotProverAnswer (* TODO *)
  | String "Failure"           -> raise NotProverAnswer (* TODO *)
  | String "HighFailure"       -> HighFailure
  | _                          -> raise NotProverAnswer

exception NotUnixProcess

let parse_unix_process j =
  match j with
  | String "WEXITED" -> Unix.WEXITED 0 (* TODO dummy value *)
  | String "WSIGNALED" -> Unix.WSIGNALED 0 (* TODO dummy value *)
  | String "WSTOPPED" -> Unix.WSTOPPED 0 (* TODO dummy value *)
  | _ -> raise NotUnixProcess

exception NotProverResult

let parse_prover_result j =
  match j with
  | Assoc ["pr_answer", pr_answer;
           "pr_status", pr_status_unix;
           "pr_output", String pr_output;
           "pr_time", Float pr_time;
           "pr_steps", Int pr_steps;
           "pr_model", String pr_model] ->
     {pr_answer = parse_prover_answer pr_answer;
      pr_status = parse_unix_process pr_status_unix;
      pr_output = pr_output;
      pr_time = pr_time;
      pr_steps = pr_steps;
      pr_model = Obj.magic pr_model} (* TODO pr_model is a string, should be model *)
  | _ -> raise NotProverResult

exception NotProofAttempt

let parse_proof_attempt j =
  match j with
  | Assoc ["proof_attempt", String "Unedited"] ->
      Unedited
  | Assoc ["proof_attempt", String "JustEdited"] ->
      JustEdited
  | Assoc ["proof_attempt", String "Interrupted"] ->
      Interrupted
  | Assoc ["proof_attempt", String "Scheduled"] ->
      Scheduled
  | Assoc ["proof_attempt", String "Running"] ->
      Running
  | Assoc ["proof_attempt", String "Done";
             "prover_result", pr] ->
       Done (parse_prover_result pr)
  | Assoc ["proof_attempt", String "InternalFailure";
             "exception", _e] ->
       raise NotProofAttempt (* TODO *)
  | Assoc ["proof_attempt", String "Uninstalled";
             "prover", p] ->
       Uninstalled (parse_prover_from_json p)
  | _ -> raise NotProofAttempt

exception NotUpdate

let parse_update j =
  match j with
  | Assoc ["update_info", String "Proved";
           "proved", Bool b] ->
    Proved b
  | Assoc ["update_info", String "Proof_status_change";
           "proof_attempt", pas;
           "obsolete", Bool b;
           "limit", l] ->
    Proof_status_change (parse_proof_attempt pas, b, parse_limit_from_json l)
  | _ -> raise NotUpdate

exception NotInfos

let parse_infos j =
  match j with
  | Assoc ["provers", Array pr;
           "transformations", Array tr;
           "strategies", Array str;
           "commands", Array com] ->
     {provers = List.map (fun j -> match j with | String x -> x | _ -> raise NotInfos) pr;
      transformations = List.map (fun j -> match j with | String x -> x | _ -> raise NotInfos) tr;
      strategies = List.map (fun j -> match j with | String x -> x | _ -> raise NotInfos) str;
      commands = List.map (fun j -> match j with | String x -> x | _ -> raise NotInfos) com}
  | _ -> raise NotInfos

exception NotMessage

let parse_message constr l =
  match constr, l with
  |  "Proof_error", ["node_ID", Int nid;
                    "error", String s] ->
      Proof_error (nid, s)
  | "Transf_error", ["node_ID", Int nid;
                     "error", String s] ->
      Transf_error (nid, s)
  | "Strat_error", ["node_ID", Int nid;
                    "error", String s] ->
      Strat_error (nid, s)
  | "Replay_Info", ["replay_info", String s] ->
      Replay_Info s
  | "Query_Info", ["node_ID", Int nid;
             "qinfo", String s] ->
       Query_Info (nid, s)
  | "Query_Error", ["node_ID", Int nid;
             "qerror", String s] ->
      Query_Error (nid, s)
  | "Help", ["qhelp", String s] ->
      Help s
  | "Information", ["information", String s] ->
      Information s
  | "Task_Monitor", ["monitor", Array [Int n; Int k; Int p]] ->
      Task_Monitor (n, k, p)
  | "Error", ["error", String s] ->
      Error s
  | "Open_File_Error", ["open_error", String s] ->
      Open_File_Error s
  | _ -> raise NotMessage


let parse_message j =
  match j with
  | Assoc (("mess_notif", String constr) :: l) ->
      parse_message constr l
  | _ -> raise NotMessage



exception NotNotification

let parse_notification constr l =
  match constr, l with
  | "New_node", ["node_ID", Int nid;
                 "parent_ID", Int parent;
                 "node_type", node_type;
                 "name", String name] ->
      New_node (nid, parent, parse_node_type_from_json node_type, name)
  | "Node_change", ["node_ID", Int nid;
                    "update", update] ->
      Node_change (nid, parse_update update)
  | "Remove", ["node_ID", Int nid] ->
      Remove nid
  | "Initialized", ["infos", infos] ->
      Initialized (parse_infos infos)
  | "Saved", [] -> Saved
  | "Message", ["message", m] ->
      Message (parse_message m)
  | "Dead", ["message", String s] ->
      Dead s
  | "Task", ["node_ID", Int nid;
             "task", String s] ->
       Task (nid, s)
  | _ -> raise NotNotification

let parse_notification j =
  match j with
  | Assoc (("notification", String constr) :: l) ->
      parse_notification constr l
  | _ -> raise NotNotification