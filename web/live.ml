(* SynMPST live *)
open Js_of_ocaml

module Html = Dom_html
module T = Js_of_ocaml_tyxml.Tyxml_js.Html
open Js_of_ocaml_tyxml.Tyxml_js
module W = Webutils

(* let show_protocol_role protocol role = *)
(*   let protocol = ProtocolName.user protocol in *)
(*   let role = RoleName.user role in *)
(*   Printf.sprintf "%s@%s" role protocol *)

let show_protocol_role _protocol _role =
  Printf.sprintf "prot@role"


let project _scr (name, role) =
  (* let ltyp = project_role scr ~protocol:name ~role in *)
  (* let s = Ltype.show ltyp in *)
  let s = "" in
  (W.get "projected")##.innerHTML
  := Js.string
     @@ Printf.sprintf "Projected on to %s :\n%s"
          (show_protocol_role name role)
          s

let fsm _scr (_name, _role) =
  (* let _, fsm = generate_fsm scr ~protocol:name ~role in *)
  (* let dot = Efsm.show fsm in *)
  (* Interface.Graph.set_dot dot *)
  Interface.GraphEFSM.set_dot ""

let display_role scr (protocol, role) =
  let lk_p =
    Of_dom.of_anchor
      (W.make_link (fun () -> project scr (protocol, role)) "Project")
  in
  let lk_f =
    Of_dom.of_anchor (W.make_link (fun () -> fsm scr (protocol, role)) "FSM")
  in
  T.(
    li
      [ txt (show_protocol_role protocol role)
      ; txt " [ "
      ; lk_p
      ; txt " ] "
      ; txt " [ "
      ; lk_f
      ; txt " ] " ])

let display_roles scr l =
  To_dom.of_element @@ T.(ul (List.map (display_role scr) l))

(* let display_role scr (protocol, role) = *)
(*   let lk_p = *)
(*     Of_dom.of_anchor *)
(*       (W.make_link (fun () -> project scr (protocol, role)) "Project") *)
(*   in *)
(*   let lk_f = *)
(*     Of_dom.of_anchor (W.make_link (fun () -> fsm scr (protocol, role)) "FSM") *)
(*   in *)
(*   T.( *)
(*     li *)
(*       [ txt (show_protocol_role protocol role) *)
(*       ; txt " [ " *)
(*       ; lk_p *)
(*       ; txt " ] " *)
(*       ; txt " [ " *)
(*       ; lk_f *)
(*       ; txt " ] " ]) *)

(* let display_roles scr l = *)
(*   To_dom.of_element @@ T.(ul (List.map (display_role scr) l)) *)

let display_label (protocol, label) =
  (* let lk_p = *)
  (*   Of_dom.of_anchor *)
  (*     (W.make_link (fun () -> project scr (protocol, role)) "Project") *)
  (* in *)
  (* let lk_f = *)
  (*   Of_dom.of_anchor (W.make_link (fun () -> fsm scr (protocol, role)) "FSM") *)
  (* in *)
  let l : string = SynMPSTlib.string_of_transition_label label in
  T.(li [ txt protocol
        ; txt " : "
        ; txt l])
  (* T.( *)
  (*   li *)
  (*     [ txt (show_protocol_role protocol role) *)
  (*     ; txt " [ " *)
  (*     ; lk_p *)
  (*     ; txt " ] " *)
  (*     ; txt " [ " *)
  (*     ; lk_f *)
  (*     ; txt " ] " ]) *)

let display_labels (lbls : (string * SynMPSTlib__.Syntax.transition_label) list) =
  To_dom.of_element @@ T.(ul (List.map display_label lbls))

let set_local fsms =
  let set (r, _fsm) =
    "<div class='localFSM'> <h3> Role: " ^ r ^ "</h3>" ^
    "<div id = local_" ^ r  ^ " style=\"overflow: scroll;\" > </div> </div>"
  in
  let divs = List.map set fsms |> String.concat "\n" in

  Interface.GraphLocal.set_div "local" divs ;

  let set_graph (r, fsm) =
    Interface.GraphLocal.set_dot ("local_" ^ r) (SynMPSTlib.dot_of_local_machine fsm)
  in

  List.iter set_graph fsms


let analyse' () =
  try
    let () = Interface.Error.reset () in
    let protocol = Interface.Code.get () in
    let cu  = SynMPSTlib.parse_string protocol in
    let cu' = SynMPSTlib.translate_and_validate cu in

    match cu' with
    | [] -> Interface.Error.display_exn "No protocols found!"
    | prot::_ ->
      let _, fsm = SynMPSTlib.generate_global_state_machine prot.interactions in
      SynMPSTlib.dot_of_global_machine fsm |> Interface.GraphEFSM.set_dot ;

      let fsms = SynMPSTlib.generate_all_local_machines prot in
      (* SynMPSTlib.dot_of_local_machine fsm |> Interface.GraphLocal.set_dot "local" ; *)
      set_local fsms ;

      SynMPSTlib.well_behaved_protocol prot

    (* let tr : Dom_html.element Js.t = SynMPSTlib.get_traces_as_string cu' |> T.txt |> To_dom.of_element in *)
    (* W.(set_children (get "projected") [(tr :> Dom.node Js.t)]) ; *)
    (* let labels = SynMPSTlib.get_transitions cu' in *)
    (* let labels_html = display_labels labels in *)
    (* W.(set_children (get "result") [(labels_html :> Dom.node Js.t)]) *)
  with
  | Invalid_argument _ -> () (* TODO this is a HACK to avoid errors on protocols without interactions *)
  | SynMPSTlib__.Error.UserError msg -> Interface.Error.display_exn (msg)
  | e -> Interface.Error.display_exn ("Error: " ^ Printexc.to_string e)


let analyse () =
  analyse' () ;
  Js_of_ocaml.Firebug.console##log (Js_of_ocaml.Js.string @@ SynMPSTlib.get_log())

(* let analyse () = *)
(*   let () = Interface.Error.reset () in *)
(*   let protocol = Interface.Code.get () in *)
(*   match parse_string protocol with *)
(*   | exception e -> Interface.Error.display_exn e *)
(*   | ast -> ( *)
(*     match validate_exn ast with *)
(*     | exception e -> Interface.Error.display_exn e *)
(*     | () -> *)
(*         let roles_html = display_roles ast @@ enumerate ast in *)
(*         W.(set_children (get "roles") [(roles_html :> Dom.node Js.t)]) ) *)

let quick_parse () =
  Interface.GraphLocal.set_div "output" "";
  let src = Interface.Code.get () in
  let names nms =
    let l = List.map (fun n -> "<li> " ^ n ^ " </li>") nms |> String.concat "\n" in
    Interface.GraphLocal.set_div "output" @@ "<h2> Protocols: </h2><ul>\n" ^ l ^ "\n</ul>"
  in
  match SynMPSTlib.quick_parse_string src with
  | Result.Ok prots -> names prots
  | Result.Error err -> Interface.GraphLocal.set_div "output" err


let quick_render () =
  let code = Interface.Code.get() in
  match SynMPSTlib.quick_parse_string code with
  | Result.Ok _ -> analyse ()
  | Result.Error _ -> ()

let _ =
  let open Js_of_ocaml in
  Js.export "synMPST"
    (object%js
       method parse () =
         quick_parse ()
       method clear () =
         Interface.GraphLocal.clear "efsm" ;
         Interface.GraphLocal.clear "local" ;
       method render () =
         quick_render ()
     end)

let init _ =
  let button =
    ( Js.Unsafe.coerce (Dom_html.getElementById "button")
      :> Dom_html.inputElement Js.t )
  in
  button##.onclick := Dom_html.handler (fun _ -> analyse () ; Js._false) ;
  W.make_combobox "examples"
    (List.map
       (fun (name, value) -> (name, fun () -> Interface.Code.set value ; quick_parse (); quick_render()))
       Examples.list ) ;
  Js._false

(* This calls our init function when the page is loaded. *)
let () = Dom_html.window##.onload := Dom_html.handler init
