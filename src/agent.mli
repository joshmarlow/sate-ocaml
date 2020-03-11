open Core.Std

type agent_state = NothingState

type agent = {
    name           : string;
    description    : string option;
    state          : agent_state;
    select_action  : agent_state -> Problem.problem_instance -> Problem.action_spec ->
        (Problem.action * agent_state);
    process_reward : agent_state -> float -> agent_state;
}

val empty : agent

val agent_of_sexp : Sexp.t -> agent
val sexp_of_agent : agent -> Sexp.t

val agent_states_equal : agent_state -> agent_state -> bool
val equal: agent -> agent -> bool
