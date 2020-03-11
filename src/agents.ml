open Core.Std

open Agent

let random_float_in_range (a, b) =
    a +. (Random.float (b -. a))

let rando = {
    name = "Rando";
    description = Some "Randomly select an action";
    state = Agent.NothingState;
    select_action = (fun agent_state _problem_state action_spec ->
        let action = (match action_spec with
            | Problem.DiscreteActionSpec spec_list ->
                    Problem.DiscreteAction (List.map ~f:Random_utils.List_utils.choice_exn spec_list)
            | Problem.ParamActionSpec spec_list ->
                    Problem.ParamAction (List.map ~f:random_float_in_range spec_list)
            | Problem.NoSpec -> Problem.NoOp
        ) in
        (action, agent_state));
    process_reward = fun agent_state _reward -> agent_state;
}
