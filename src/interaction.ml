open Problem_run
open Problem

let select_agent_action agent_ problem_instance a_spec =
    let action, new_state = agent_.Agent.select_action agent_.Agent.state
                                                    problem_instance
                                                    a_spec
    in
    (action, { agent_ with Agent.state = new_state })

let reward_agent agent_ reward =
    let new_state = agent_.Agent.process_reward agent_.Agent.state reward in
    { agent_ with Agent.state = new_state }

let respond_to_action problem_ action =
    let new_problem_state, reward = problem_.Problem.handle_action problem_.Problem.state action in
    ( { problem_ with Problem.state = new_problem_state }, reward)

let perform_interaction problem_run =
    (*** The agent acts ***)
    let problem_ = problem_run.problem_ in
    let action, agent_2 = select_agent_action problem_run.agent_
                                                problem_.state.instance
                                                problem_run.problem_.Problem.a_spec in
    (*** The problem responds ***)
    let problem_2, reward = respond_to_action problem_ action in
    (*** the agent learns ***)
    let interaction = {
        i_state = problem_run.problem_.Problem.state;
        f_state = problem_2.Problem.state;
        action  = action;
        reward  = reward;
    } in
    let agent_3 = reward_agent agent_2 reward in
    {
        problem_ = problem_2;
        agent_ = agent_3;
        interactions = interaction :: problem_run.interactions;
        start_time = problem_run.start_time;
        end_time = problem_run.end_time;
    }
