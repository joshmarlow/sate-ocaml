open Core.Std
open OUnit2

open Interaction
open Problem_run
open Problem

let test_perform_interaction _ =
    let now = Time.now () in
    let initial_problem_run = {
        problem_ = {
            Problem.name = "test problem";
            Problem.description = None;
            Problem.state = {
                inner_state_ = Problem.IntState 0;
                instance = Problem.IntInstance 0;
            };
            a_spec = Problem.DiscreteActionSpec [[ 0 ]];
            action_names = None;
            handle_action = (fun _a _b -> (
                {
                    inner_state_ = Problem.IntState 1;
                    instance = Problem.IntInstance 1;
                }, 2.0));
        };
        agent_ = {
            Agent.name = "test agent";
            Agent.description = None;
            Agent.state = Agent.NothingState;
            select_action = (fun a _p aspec ->
                match aspec with
                    | Problem.DiscreteActionSpec il -> (Problem.DiscreteAction [List.hd_exn (List.hd_exn il)], a)
                    | Problem.ParamActionSpec _ -> failwith "ParamActionSpec should not happen"
                    | Problem.NoSpec -> failwith "NoSpec should not be provided"
            );
            process_reward = (fun a _r -> a);
        };
        interactions=[];
        start_time=now;
        end_time=None;
    } in
    let expected_final_problem_run = {
        problem_ = {
            Problem.name = "test problem";
            Problem.description = None;
            state = {
                inner_state_ = Problem.IntState 1;
                instance = Problem.IntInstance 1;
            };
            a_spec = Problem.DiscreteActionSpec [[ 0 ]];
            action_names = None;
            handle_action = (fun _a _b -> (
                {
                    inner_state_ = Problem.IntState 1;
                    instance = Problem.IntInstance 1;
                }, 2.0));
        };
        agent_ = {
            Agent.name = "test agent";
            Agent.description = None;
            Agent.state = Agent.NothingState;
            select_action = (fun a _p aspec ->
                match aspec with
                    | Problem.DiscreteActionSpec il -> (Problem.DiscreteAction [List.hd_exn (List.hd_exn il)], a)
                    | Problem.ParamActionSpec _ -> failwith "ParamActionSpec should not happen"
                    | Problem.NoSpec -> failwith "NoSpec should not be provided"
            );
            process_reward = (fun a _r -> a);
        };
        interactions=[
            {
                i_state = {
                    inner_state_ = Problem.IntState 0;
                    instance = Problem.IntInstance 0;
                };
                f_state = {
                    inner_state_ = Problem.IntState 1;
                    instance = Problem.IntInstance 1;
                };
                action = Problem.DiscreteAction [0];
                reward = 2.0;
            }
        ];
        start_time=now;
        end_time=None;
    } in
    let actual_final_problem_run = perform_interaction initial_problem_run in
    assert_bool (Printf.sprintf "Expected:\n%s\nActual:\n%s\n"
                                    (Sexp.to_string (Problem_run.sexp_of_problem_run expected_final_problem_run))
                                    (Sexp.to_string (Problem_run.sexp_of_problem_run actual_final_problem_run)))
                (Problem_run.equal expected_final_problem_run actual_final_problem_run);
    ()

let all_tests =
    "all_tests">:::[
        "test_perform_interaction">::test_perform_interaction;
    ];;

let () =
    run_test_tt_main all_tests;
    ()
