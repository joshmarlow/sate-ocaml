(** An interaction between an agent and a problem **)
type interaction = {
    (*** Initial state at beginning of interaction ***)
    i_state : Problem.problem_state;
    (*** Final state at end of interaction ***)
    f_state : Problem.problem_state;
    (*** Agent action ***)
    action  : Problem.action;
    (*** Reward given to the agent ***)
    reward  : float;
} with sexp

(** The history of a set of interactions between an agent and a problem. **)
type problem_run = {
    problem_     : Problem.problem;
    agent_       : Agent.agent;
    interactions : interaction list;
    start_time   : Core.Std.Time.t;
    end_time     : Core.Std.Time.t option;
} with sexp

(*** Basic data structure interface ***)
val total_reward : problem_run -> float
val max_reward : problem_run -> float option
val max_reward_exn : problem_run -> float
val num_interactions : problem_run -> int
val run_time : problem_run -> Core.Std.Time.Span.t option
val summarize_problem_run : problem_run -> string
val equal : problem_run -> problem_run -> bool
