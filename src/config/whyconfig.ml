(**************************************************************************)
(*                                                                        *)
(*  Copyright (C) 2010-                                                   *)
(*    François Bobot                                                     *)
(*    Jean-Christophe Filliâtre                                          *)
(*    Claude Marché                                                      *)
(*    Andrei Paskevich                                                    *)
(*                                                                        *)
(*  This software is free software; you can redistribute it and/or        *)
(*  modify it under the terms of the GNU Library General Public           *)
(*  License version 2.1, with the special exception on linking            *)
(*  described in file LICENSE.                                            *)
(*                                                                        *)
(*  This software is distributed in the hope that it will be useful,      *)
(*  but WITHOUT ANY WARRANTY; without even the implied warranty of        *)
(*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                  *)
(*                                                                        *)
(**************************************************************************)

open Format
open Why
open Util
open Whyconf

let usage_msg =
  sprintf "Usage: [WHY3LIB=... WHY3DATA=... %s [options]@.\t\
$WHY3LIB and $WHYDATA are used only when a configuration file is created"
    (Filename.basename Sys.argv.(0))

(* let libdir = ref None *)
(* let datadir = ref None *)
let conf_file = ref None
let autoprovers = ref false
let autoplugins = ref false

let save = ref true

let set_oref r = (fun s -> r := Some s)

let plugins = Queue.create ()

let add_plugin x = Queue.add x plugins

let option_list = Arg.align [
  (* "--libdir", Arg.String (set_oref libdir), *)
  (* "<dir> set the lib directory ($WHY3LIB)"; *)
  (* "--datadir", Arg.String (set_oref datadir), *)
  (* "<dir> set the data directory ($WHY3DATA)"; *)
  "--conf_file", Arg.String (set_oref conf_file),
  "<file> use this configuration file, create it if it doesn't exist
($WHY_CONFIG), otherwise use the default one";
  "--autodetect-provers", Arg.Set autoprovers,
  " autodetect the provers in the $PATH";
  "--autodetect-plugins", Arg.Set autoplugins,
  " autodetect the plugins in the default library directories";
  "--install-plugin", Arg.String add_plugin,
  "install a plugin to the actual libdir";
  "--dont-save", Arg.Clear save,
  "dont modify the config file"
]

let anon_file _ = Arg.usage option_list usage_msg; exit 1

let install_plugin main p =
  begin match Plugin.check_plugin p with
    | Plugin.Plubad -> eprintf "Unknown extension (.cmo|.cmxs) : %s@." p;
      raise Exit
    | Plugin.Pluother ->
      eprintf "The plugin %s will not be used with this kind of compilation \
and it has not been tested@."
        p
    | Plugin.Plugood -> ()
    | Plugin.Plufail exn -> eprintf "The plugin %s dynlink failed :@.%a@."
      p Exn_printer.exn_printer exn; raise Exit
  end;
  let base = Filename.basename p in
  let plugindir = Whyconf.pluginsdir main in
  if not (Sys.file_exists plugindir) then Unix.mkdir plugindir 0o777;
  let target = (Filename.concat plugindir base) in
  if p <> target then Sysutil.copy_file p target;
  Whyconf.add_plugin main (Filename.chop_extension target)

let plugins_auto_detection config =
  let main = get_main config in
  let main = set_plugins main [] in
  let dir = Whyconf.pluginsdir main in
  let files = Sys.readdir dir in
  let fold main p =
    let p = Filename.concat dir p in
    try eprintf "== Found %s ==@." p;
        install_plugin main p with Exit -> main in
  let main = Array.fold_left fold main files in
  set_main config main

let () =
  Arg.parse option_list anon_file usage_msg;
  let config =
    try read_config !conf_file
    with Not_found ->
      let conf_file = match !conf_file with
        | None -> Sys.getenv "WHY_CONFIG"
        | Some f -> f in
      default_config conf_file in
  let main = get_main config in
  (* let main = option_apply main (fun d -> {main with libdir = d})
     !libdir in *)
  (* let main = option_apply main (fun d -> {main with datadir = d})
     !datadir in *)
  let main = try Queue.fold install_plugin main plugins with Exit -> exit 1 in
  let config = set_main config main in
  let conf_file = get_conf_file config in
  let conf_file_doesnt_exist = not (Sys.file_exists conf_file) in
  if conf_file_doesnt_exist then
    printf "Config file %s doesn't exist, \
 so autodetection of provers and plugins is automatically triggered@."
      conf_file;
  let config =
    if !autoprovers || conf_file_doesnt_exist
    then Autodetection.run_auto_detection config
    else config in
  let config =
    if !autoplugins || conf_file_doesnt_exist
    then plugins_auto_detection config
    else config in
  if !save then begin
    printf "Save config to %s@." conf_file;
    save_config config end
