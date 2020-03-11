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

let empty = {
    name = "";
    description = None;
    state = NothingState;
    select_action = (fun state _problem_instance _a_spec -> (Problem.NoOp, state));
    process_reward = (fun state _reward -> state);
}

let agent_of_sexp sexp =
    let failer () = failwith "expected (agent :name NAME)" in
    match sexp with
        | Sexp.List [
            Sexp.Atom "agent"; Sexp.Atom ":name"; Sexp.Atom name;
        ] -> {
            empty with name = name;
        }
        | Sexp.List _ -> failer ()
        | Sexp.Atom _ -> failer ()
let sexp_of_agent agent =
    Sexp.List [
        Sexp.Atom "agent";
        Sexp.Atom ":name";
        Sexp.Atom agent.name;
    ]

let agent_states_equal s1 s2 =
    match s1, s2 with
        | NothingState, NothingState -> true

let equal a1 a2 =
    String.equal a1.name a2.name &&
        Option.equal String.equal a1.description a2.description &&
            agent_states_equal a1.state a2.state
