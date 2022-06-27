

val say_hello : unit -> string


val parse_string : string -> Syntax.Ext.compilation_unit
val translate_and_validate : Syntax.Ext.compilation_unit -> Syntax.Int.compilation_unit option

val get_transitions : Syntax.Int.compilation_unit -> (string * Syntax.transition_label) list

val string_of_transition_label : Syntax.transition_label -> string
