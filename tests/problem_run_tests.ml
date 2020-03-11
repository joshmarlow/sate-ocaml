open Core.Std
open OUnit2

open Agent
open Problem
open Problem_run

let problem_run = {
    problem_ = {
        Problem.name = "";
        Problem.description = None;
        state = {
            inner_state_ = IntState 0;
            instance = IntInstance 0;
        };
        a_spec = DiscreteActionSpec [[ 0 ]];
        action_names = None;
        handle_action = (fun a _b -> (a, 0.0));
    };
    agent_ = {
        Agent.name = "";
        Agent.description = None;
        Agent.state = NothingState;
        select_action = (fun a _p aspec ->
            match aspec with
                | DiscreteActionSpec il -> (DiscreteAction [List.hd_exn (List.hd_exn il)], a)
                | ParamActionSpec _ -> failwith "ParamActionSpec should not happen"
                | NoSpec -> failwith "NoSpec should not be provided"
        );
        process_reward = (fun a _r -> a);
    };
    interactions = [
        {
            i_state = {
                inner_state_ = IntState 0;
                instance = IntInstance 0;
            };
            f_state = {
                inner_state_ = IntState 1;
                instance = IntInstance 1;
            };
            action = DiscreteAction [0];
            reward = 1.0;
        };
        {
            i_state = {
                inner_state_ = IntState 0;
                instance = IntInstance 0;
            };
            f_state = {
                inner_state_ = IntState 1;
                instance = IntInstance 1;
            };
            action = DiscreteAction [0];
            reward = 2.0;
        };
    ];
    start_time=Time.now ();
    end_time=None;
}

let test__total_reward _ =
    assert_bool "Reward should be 3.0"
        (Float.equal 3.0 (total_reward problem_run));
    ()

let test__num_interactions _ =
    assert_bool "Number of interactions should be 2"
        (Int.equal 2 (num_interactions problem_run));
    ()

let all_tests =
    "all_tests">:::[
        "test__total_reward">::test__total_reward;
        "test__num_interactions">::test__num_interactions;
    ];;

let () =
    run_test_tt_main all_tests;
    ()
