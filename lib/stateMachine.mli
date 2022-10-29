module type STATE =
sig
  type t
  val equal : t -> t -> bool
  val hash : t -> int
  val compare : t -> t -> int
  val get_id : t -> int
  val fresh : unit -> t
  val freshen : t -> t
  val renumber_state : int -> t -> t
  val as_string : t -> string
  val list_as_string : t list -> string
  val mark_as_start : t -> t
  val mark_as_end : t -> t
  val is_start : t -> bool
  val is_end : t -> bool
end
module type LABEL =
sig
  type t
  val default : t
  val compare : t -> t -> int
  val as_string : t -> string
  val list_as_string : t list -> string
  val is_default : t -> bool
end
module type FSMT =
sig
  type t
  module State : STATE
  module Label : LABEL
  type vertex = State.t
  module E :
  sig
    type t
    val compare : t -> t -> int
    val src : t -> vertex
    val dst : t -> vertex
    type label = Label.t
    val create : vertex -> label -> vertex -> t
    val label : t -> label
  end
  val get_vertices : t -> vertex list
  val get_start_state : t -> vertex
  val add_vertex : t -> vertex -> t
  val empty : t
  type edge = E.t
  val get_edges : t -> edge list
  val add_edge : t -> vertex -> vertex -> t
  val add_edge_e : t -> edge -> t
  val succ : t -> vertex -> vertex list
  val succ_e : t -> vertex -> edge list
  val fold_edges : (vertex -> vertex -> 'a -> 'a) -> t -> 'a -> 'a
  val iter_edges_e : (edge -> unit) -> t -> unit
  val fold_edges_e : (edge -> 'a -> 'a) -> t -> 'a -> 'a
  val iter_vertex : (vertex -> unit) -> t -> unit
  val fold_vertex : (vertex -> 'a -> 'a) -> t -> 'a -> 'a
  val walk_collect_edges_with_predicate :
    t -> vertex -> (vertex -> edge list) -> (edge -> bool) -> edge list
  val walk_collect_vertices_with_predicate :
    t -> vertex -> (vertex -> edge list) -> (edge -> bool) -> vertex list
  val walk_with_function :
    vertex -> (vertex -> edge list) -> (edge -> 'a) -> 'a list
  val walk_with_any_predicate :
    vertex -> (vertex -> edge list) -> (edge -> bool) -> bool
  val only_with_tau : t -> vertex -> edge list
  val with_any_transition : t -> vertex -> edge list
  val state_can_step : t -> vertex -> bool
  val get_reachable_labels : t -> vertex -> E.label list
  val state_can_step_recursive : t -> vertex -> bool
  val has_strong_outgoing_transitions : t -> vertex -> bool
  val get_final_states : t -> vertex list
  val tau_reachable : t -> vertex -> vertex list
  val tau_reachable_labelled_edges : t -> vertex -> edge list
  val can_reach_with_anything :
    E.t list -> vertex -> E.label -> vertex list
  val can_reach_with_weak_step : t -> vertex -> E.label -> vertex list
  val minimise_state_numbers : t -> t
  val merge : t -> t -> t
  val merge_all : t list -> t
  val remove_reflexive_taus : t -> t
  module Dot : sig val generate_dot : t -> string end
end
module FSM :
  functor (State : STATE) (Label : LABEL) ->
  sig
    (* module G : *)
    (*   sig *)
    (*     type t = Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t *)
    (*     module V : *)
    (*       sig *)
    (*         type t = State.t *)
    (*         val compare : t -> t -> int *)
    (*         val hash : t -> int *)
    (*         val equal : t -> t -> bool *)
    (*         type label = State.t *)
    (*         val create : label -> t *)
    (*         val label : t -> label *)
    (*       end *)
    (*     type vertex = V.t *)
    (*     type edge = E.t *)
    (*     val is_directed : bool *)
    (*     val is_empty : t -> bool *)
    (*     val nb_vertex : t -> int *)
    (*     val nb_edges : t -> int *)
    (*     val out_degree : t -> vertex -> int *)
    (*     val in_degree : t -> vertex -> int *)
    (*     val mem_vertex : t -> vertex -> bool *)
    (*     val mem_edge : t -> vertex -> vertex -> bool *)
    (*     val mem_edge_e : t -> edge -> bool *)
    (*     val find_edge : t -> vertex -> vertex -> edge *)
    (*     val find_all_edges : t -> vertex -> vertex -> edge list *)
    (*     val succ : t -> vertex -> vertex list *)
    (*     val pred : t -> vertex -> vertex list *)
    (*     val succ_e : t -> vertex -> edge list *)
    (*     val pred_e : t -> vertex -> edge list *)
    (*     val iter_vertex : (vertex -> unit) -> t -> unit *)
    (*     val fold_vertex : (vertex -> 'a -> 'a) -> t -> 'a -> 'a *)
    (*     val iter_edges : (vertex -> vertex -> unit) -> t -> unit *)
    (*     val fold_edges : (vertex -> vertex -> 'a -> 'a) -> t -> 'a -> 'a *)
    (*     val iter_edges_e : (edge -> unit) -> t -> unit *)
    (*     val fold_edges_e : (edge -> 'a -> 'a) -> t -> 'a -> 'a *)
    (*     val map_vertex : (vertex -> vertex) -> t -> t *)
    (*     val iter_succ : (vertex -> unit) -> t -> vertex -> unit *)
    (*     val iter_pred : (vertex -> unit) -> t -> vertex -> unit *)
    (*     val fold_succ : (vertex -> 'a -> 'a) -> t -> vertex -> 'a -> 'a *)
    (*     val fold_pred : (vertex -> 'a -> 'a) -> t -> vertex -> 'a -> 'a *)
    (*     val iter_succ_e : (edge -> unit) -> t -> vertex -> unit *)
    (*     val fold_succ_e : (edge -> 'a -> 'a) -> t -> vertex -> 'a -> 'a *)
    (*     val iter_pred_e : (edge -> unit) -> t -> vertex -> unit *)
    (*     val fold_pred_e : (edge -> 'a -> 'a) -> t -> vertex -> 'a -> 'a *)
    (*     val empty : t *)
    (*     val add_vertex : t -> vertex -> t *)
    (*     val remove_vertex : t -> vertex -> t *)
    (*     val add_edge : t -> vertex -> vertex -> t *)
    (*     val add_edge_e : t -> edge -> t *)
    (*     val remove_edge : t -> vertex -> vertex -> t *)
    (*     val remove_edge_e : t -> edge -> t *)
    (*   end *)
    (* module V = G.V *)
    (* type vertex = V.t *)
    (* module E = G.E *)
    (* type edge = E.t *)
    (* val is_directed : bool *)
    (* val is_empty : *)
    (*   Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t -> bool *)
    (* val nb_vertex : *)
    (*   Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t -> int *)
    (* val nb_edges : *)
    (*   Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t -> int *)
    (* val out_degree : *)
    (*   Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t -> *)
    (*   vertex -> int *)
    (* val in_degree : *)
    (*   Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t -> *)
    (*   vertex -> int *)
    (* val mem_vertex : *)
    (*   Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t -> *)
    (*   vertex -> bool *)
    (* val mem_edge : *)
    (*   Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t -> *)
    (*   vertex -> vertex -> bool *)
    (* val mem_edge_e : *)
    (*   Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t -> *)
    (*   edge -> bool *)
    (* val find_edge : *)
    (*   Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t -> *)
    (*   vertex -> vertex -> edge *)
    (* val find_all_edges : *)
    (*   Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t -> *)
    (*   vertex -> vertex -> edge list *)
    (* val succ : *)
    (*   Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t -> *)
    (*   vertex -> vertex list *)
    (* val pred : *)
    (*   Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t -> *)
    (*   vertex -> vertex list *)
    (* val succ_e : *)
    (*   Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t -> *)
    (*   vertex -> edge list *)
    (* val pred_e : *)
    (*   Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t -> *)
    (*   vertex -> edge list *)
    (* val iter_vertex : *)
    (*   (vertex -> unit) -> *)
    (*   Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t -> unit *)
    (* val fold_vertex : *)
    (*   (vertex -> 'a -> 'a) -> *)
    (*   Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t -> 'a -> 'a *)
    (* val iter_edges : *)
    (*   (vertex -> vertex -> unit) -> *)
    (*   Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t -> unit *)
    (* val fold_edges : *)
    (*   (vertex -> vertex -> 'a -> 'a) -> *)
    (*   Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t -> 'a -> 'a *)
    (* val iter_edges_e : *)
    (*   (edge -> unit) -> *)
    (*   Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t -> unit *)
    (* val fold_edges_e : *)
    (*   (edge -> 'a -> 'a) -> *)
    (*   Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t -> 'a -> 'a *)
    (* val map_vertex : *)
    (*   (vertex -> vertex) -> *)
    (*   Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t -> *)
    (*   Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t *)
    (* val iter_succ : *)
    (*   (vertex -> unit) -> *)
    (*   Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t -> *)
    (*   vertex -> unit *)
    (* val iter_pred : *)
    (*   (vertex -> unit) -> *)
    (*   Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t -> *)
    (*   vertex -> unit *)
    (* val fold_succ : *)
    (*   (vertex -> 'a -> 'a) -> *)
    (*   Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t -> *)
    (*   vertex -> 'a -> 'a *)
    (* val fold_pred : *)
    (*   (vertex -> 'a -> 'a) -> *)
    (*   Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t -> *)
    (*   vertex -> 'a -> 'a *)
    (* val iter_succ_e : *)
    (*   (edge -> unit) -> *)
    (*   Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t -> *)
    (*   vertex -> unit *)
    (* val fold_succ_e : *)
    (*   (edge -> 'a -> 'a) -> *)
    (*   Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t -> *)
    (*   vertex -> 'a -> 'a *)
    (* val iter_pred_e : *)
    (*   (edge -> unit) -> *)
    (*   Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t -> *)
    (*   vertex -> unit *)
    (* val fold_pred_e : *)
    (*   (edge -> 'a -> 'a) -> *)
    (*   Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t -> *)
    (*   vertex -> 'a -> 'a *)
    (* val empty : Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t *)
    (* val add_vertex : *)
    (*   Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t -> *)
    (*   vertex -> Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t *)
    (* val remove_vertex : *)
    (*   Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t -> *)
    (*   vertex -> Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t *)
    (* val add_edge : *)
    (*   Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t -> *)
    (*   vertex -> *)
    (*   vertex -> Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t *)
    (* val add_edge_e : *)
    (*   Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t -> *)
    (*   edge -> Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t *)
    (* val remove_edge : *)
    (*   Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t -> *)
    (*   vertex -> *)
    (*   vertex -> Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t *)
    (* val remove_edge_e : *)
    (*   Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t -> *)
    (*   edge -> Graph__Persistent.Digraph.ConcreteLabeled(State)(Label).t *)
    type t (* = G.t *)
    type vertex = State.t

    module E :
    sig
      type t = State.t * Label.t * State.t
      val compare : t -> t -> int
      (* type vertex = vertex *)
      val src : t -> vertex
      val dst : t -> vertex
      type label = Label.t
      val create : vertex -> label -> vertex -> t
      val label : t -> label
    end

    type edge = E.t

    module State :
    sig
      type t = State.t
      val equal : t -> t -> bool
      val hash : t -> int
      val compare : t -> t -> int
      val get_id : t -> int
      val fresh : unit -> t
      val freshen : t -> t
      val renumber_state : int -> t -> t
      val as_string : t -> string
      val list_as_string : t list -> string
      val mark_as_start : t -> t
      val mark_as_end : t -> t
      val is_start : t -> bool
      val is_end : t -> bool
    end
    module Label :
    sig
      type t = Label.t
      val default : t
      val compare : t -> t -> int
      val as_string : t -> string
      val list_as_string : t list -> string
      val is_default : t -> bool
    end


    val add_edge : t -> vertex -> vertex -> t
    val add_edge_e : t -> edge -> t
    val succ : t -> vertex -> vertex list
    val succ_e : t -> vertex -> edge list
    val fold_edges : (vertex -> vertex -> 'a -> 'a) -> t -> 'a -> 'a
    val iter_edges_e : (edge -> unit) -> t -> unit
    val fold_edges_e : (edge -> 'a -> 'a) -> t -> 'a -> 'a
    val iter_vertex : (vertex -> unit) -> t -> unit
    val fold_vertex : (vertex -> 'a -> 'a) -> t -> 'a -> 'a
    val add_vertex : t -> vertex -> t
    val empty : t


    val _string_of_edge : E.t -> string
    val get_edges :
      t ->
      edge list
    val get_vertices : t -> vertex list
    val get_start_state : t -> vertex
    val _can_reach_with_labels :
      E.t list -> vertex -> E.label -> vertex list
    val walk_collect_edges_with_predicate :
      t -> vertex -> (vertex -> edge list) -> (edge -> bool) -> edge list
    val walk_collect_vertices_with_predicate :
      t -> vertex -> (vertex -> edge list) -> (edge -> bool) -> vertex list
    val walk_with_function :
      vertex -> (vertex -> edge list) -> (edge -> 'a) -> 'a list
    val walk_with_any_predicate :
      vertex -> (vertex -> edge list) -> (edge -> bool) -> bool
    val only_with_tau : t -> vertex -> edge list
    val with_any_transition : t -> vertex -> edge list
    val state_can_step : t -> vertex -> bool
    val get_reachable_labels : t -> vertex -> Label.t list
    val state_can_step_recursive : t -> vertex -> bool
    val has_strong_outgoing_transitions :
      t ->
      vertex -> bool
    val get_final_states : t -> vertex list
    val tau_reachable : t -> vertex -> vertex list
    val tau_reachable_labelled_edges : t -> vertex -> edge list
    val can_reach_with_anything :
      E.t list -> vertex -> E.label -> vertex list
    val can_reach_with_weak_step : t -> vertex -> E.label -> vertex list
    val minimise_state_numbers : t -> t
    val merge : t -> t -> t
    val merge_all : t list -> t
    val remove_reflexive_taus : t -> t
    module Dot :
    sig
      val generate_dot : t -> string
    end
  end