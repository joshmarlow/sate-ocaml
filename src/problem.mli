(*type action_handler = 'a -> int -> 'a -> reward*)
open Core.Std

type inner_state = IntState of int | NoState
type problem_instance = IntInstance of int | NoneInstance
type problem_state = {
    inner_state_: inner_state;
    instance: problem_instance;
} with sexp
type int_list = int list
type float_range = float * float

(** Action specification **)
type action_spec =
    DiscreteActionSpec of int list list
    | ParamActionSpec of float_range list
    | NoSpec

(** Action representation **)
type action =
    DiscreteAction of int list
    | ParamAction of float list
    | NoOp
    with sexp

(** A particular problem instance **)
type problem = {
    name           : string;
    description    : string option;
    state          : problem_state;
    a_spec         : action_spec;
    action_names   : string array option;
    handle_action  : problem_state -> action -> (problem_state * float);
}

val empty : problem

val inner_state_of_sexp : Sexp.t -> inner_state
val sexp_of_inner_state : inner_state -> Sexp.t

val problem_instance_of_sexp : Sexp.t -> problem_instance
val sexp_of_problem_instance : problem_instance -> Sexp.t

val problem_of_sexp : Sexp.t -> problem
val sexp_of_problem : problem -> Sexp.t

val int_list_equal : int_list -> int_list -> bool
val float_range_equal : float_range -> float_range -> bool
val problem_states_equal : problem_state -> problem_state -> bool
val action_spec_equal : action_spec -> action_spec -> bool
val action_equal : action -> action -> bool
val equal: problem -> problem -> bool

val validate_action : action_spec -> action -> bool

val in_range : float_range -> float -> bool
