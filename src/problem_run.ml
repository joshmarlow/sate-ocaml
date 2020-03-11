open Core.Std

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
let total_reward pr =
    List.fold_left ~f:(+.) ~init:0.0 begin
        List.map pr.interactions ~f:(fun interaction -> interaction.reward)
    end

let max_reward pr =
    List.max_elt ~cmp:Float.compare begin
        List.map ~f:(fun interaction -> interaction.reward) pr.interactions
    end

let max_reward_exn pr =
    match max_reward pr with
        | None -> failwith "max_reward_exn - Problem_run must have some interactions"
        | Some reward -> reward

let num_interactions pr = List.length pr.interactions

let run_time pr =
    match pr.end_time with
        | None -> None
        | Some et -> Some (Time.diff et pr.start_time)

let summarize_problem_run pr =
    String.concat ~sep:"\n" begin [
        "Problem Run";
        "===========";
        Printf.sprintf "Problem Name: %s" pr.problem_.Problem.name;
        Printf.sprintf "Agent: %s" pr.agent_.Agent.name;
        Printf.sprintf "Total Reward: %f" (total_reward pr);
        Printf.sprintf "Num interactions: %d" (num_interactions pr);
    ] end

let interactions_equal intr1 intr2 =
    Problem.problem_states_equal intr1.i_state intr2.i_state &&
        Problem.problem_states_equal intr1.f_state intr2.f_state &&
            Problem.action_equal intr1.action intr2.action &&
                Float.equal intr1.reward intr2.reward

let equal pr1 pr2 =
    Problem.equal pr1.problem_ pr2.problem_ &&
        Agent.equal pr1.agent_ pr2.agent_ &&
            List.equal ~equal:interactions_equal pr1.interactions pr2.interactions &&
            Core.Std.Time.equal pr1.start_time pr2.start_time &&
                Option.equal Core.Std.Time.equal pr1.end_time pr2.end_time
