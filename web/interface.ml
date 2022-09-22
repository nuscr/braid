open Js_of_ocaml
(* open Nuscrlib *)

module Code = struct
  let id = "protocol-textarea"

  let get () = Js.(to_string (Webutils.get_textarea id)##.value)

  let set s = (Webutils.get_textarea id)##.value := Js.string s
end

module Error = struct
  let errorbox = "errorbox"

  let display fmt =
    let display string =
      let string = Str.global_substitute (Str.regexp "<") (fun _ -> "&lt") string in
      let string = Str.global_substitute (Str.regexp ">") (fun _ -> "&gt") string in
      let string = Str.global_substitute (Str.regexp "$") (fun _ -> "</br>") string in
      let e = Webutils.get errorbox in
      Webutils.(
        set_inner_html e "%s" string ;
        set_display e "block")
    in
    Printf.ksprintf display fmt

  (* let display_exn = function *)
  (*   | Err.UserError e -> *)
  (*       display "<b>User error</b>: %s" (Err.show_user_error e) *)
  (*   | Err.UnImplemented (s, _) -> *)
  (*       display "<b>Feature not implemented</b>: %s" s *)
  (*   | Err.Violation (s, _) -> display "<b>Violation</b>: %s" s *)
  (*   | e -> display "<b>Unknown error</b>: %s" (Printexc.to_string e) *)

  let display_exn s = display "%s" s (* "Something sad happened" *)

  let reset () = Webutils.(set_display (get "errorbox") "none")
end

module GraphEFSM = struct
  let id = "efsm"

  let clear () = Webutils.set_children (Webutils.get id) []

  let set (svg : Dom.node Js.t) =
    Webutils.set_children (Webutils.get id) [svg]

  let set_dot (dot : string) =
    let dot = Js.string dot in
    let viz = Js.Unsafe.global##._Viz in
    let viz = Js.Unsafe.new_obj viz [||] in
    let promise =
      Js.Unsafe.meth_call viz "renderSVGElement" [|Js.Unsafe.inject dot|]
    in
    let _promise =
      Js.Unsafe.meth_call promise "then" [|Js.Unsafe.inject set|]
    in
    ()
end

module GraphLocal = struct
  let clear id = Webutils.set_children (Webutils.get id) []

  let set id (svg : Dom.node Js.t) =
    Webutils.set_children (Webutils.get id) [svg]

  let set_dot id (dot : string) =
    let dot = Js.string dot in
    let viz = Js.Unsafe.global##._Viz in
    let viz = Js.Unsafe.new_obj viz [||] in
    let promise =
      Js.Unsafe.meth_call viz "renderSVGElement" [|Js.Unsafe.inject dot|]
    in
    let _promise =
      Js.Unsafe.meth_call promise "then" [|Js.Unsafe.inject (set id) |]
    in
    ()
end
