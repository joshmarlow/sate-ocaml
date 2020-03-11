val select_agent_action : Agent.agent -> Problem.problem_instance -> Problem.action_spec -> (Problem.action * Agent.agent)
val reward_agent : Agent.agent -> float -> Agent.agent
val respond_to_action : Problem.problem -> Problem.action -> Problem.problem * float
val perform_interaction : Problem_run.problem_run -> Problem_run.problem_run
