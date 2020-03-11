open OUnit2

let test__validate_action__returns_true_for_valid_discrete_action _ =
    let action_spec = Problem.DiscreteActionSpec [[1; 2; 3]; [4; 5; 6]] in
    let action = Problem.DiscreteAction [2; 5] in
    assert_equal true (Problem.validate_action action_spec action);
    ()

let test__validate_action__returns_false_for_invalid_discrete_action _ =
    let action_spec = Problem.DiscreteActionSpec [[1; 2; 3]; [4; 5; 6]] in
    let action = Problem.DiscreteAction [2; 9] in
    assert_equal false (Problem.validate_action action_spec action);
    ()

let test__validate_action__returns_true_for_valid_parametric_action _ =
    let action_spec = Problem.ParamActionSpec [(0.0, 1.0); (-1.0, 1.0)] in
    let action = Problem.ParamAction [0.5; 0.0] in
    assert_equal true (Problem.validate_action action_spec action);
    ()

let test__validate_action__returns_false_for_invalid_parametric_action _ =
    let action_spec = Problem.ParamActionSpec [(0.0, 1.0); (-1.0, 1.0)] in
    let action = Problem.ParamAction [0.5; 2.0] in
    assert_equal false (Problem.validate_action action_spec action);
    ()

let test__validate_action__returns_false_for_mismatched_spec_and_action _ =
    let action_spec = Problem.ParamActionSpec [(0.0, 1.0); (-1.0, 1.0)] in
    let action = Problem.DiscreteAction [0; 2] in
    assert_equal false (Problem.validate_action action_spec action);
    ()

let all_tests =
    "all_tests">:::[
        "test__validate_action__returns_true_for_valid_discrete_action">::test__validate_action__returns_true_for_valid_discrete_action;
        "test__validate_action__returns_false_for_invalid_discrete_action">::test__validate_action__returns_false_for_invalid_discrete_action;
        "test__validate_action__returns_true_for_valid_parametric_action">::test__validate_action__returns_true_for_valid_parametric_action;
        "test__validate_action__returns_false_for_invalid_parametric_action">::test__validate_action__returns_false_for_invalid_parametric_action;
        "test__validate_action__returns_false_for_mismatched_spec_and_action">::test__validate_action__returns_false_for_mismatched_spec_and_action;
    ];;

(* run all tests *)
let () =
    run_test_tt_main all_tests;
