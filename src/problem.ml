open Core.Std

type inner_state = IntState of int | NoState
type problem_instance = IntInstance of int | NoneInstance

let inner_state_of_sexp sexp =
    let failer () = failwith "expected (int-state VALUE)" in
    match sexp with
        | Sexp.List [Sexp.Atom "int-state"; state] -> IntState (int_of_sexp state)
        | Sexp.List [Sexp.Atom "null"] -> NoState
        | Sexp.List _ -> failer ()
        | Sexp.Atom _ -> failer ()
let sexp_of_inner_state = function
    | IntState state -> Sexp.List [Sexp.Atom "int-state"; Sexp.Atom (Int.to_string state)]
    | NoState -> Sexp.List [Sexp.Atom "null"]

let problem_instance_of_sexp sexp =
    let failer () = failwith "expected (int-instance VALUE)" in
    match sexp with
        | Sexp.List [Sexp.Atom "int-instance"; state] -> IntInstance (int_of_sexp state)
        | Sexp.List [Sexp.Atom "null"] -> NoneInstance
        | Sexp.List _ -> failer ()
        | Sexp.Atom _ -> failer ()
let sexp_of_problem_instance = function
    | IntInstance state -> Sexp.List [Sexp.Atom "int-instance"; Sexp.Atom (Int.to_string state)]
    | NoneInstance -> Sexp.List [Sexp.Atom "null"]

type problem_state = {
    inner_state_: inner_state;
    instance: problem_instance;
} with sexp
type int_list = int list
type float_range = float * float

(** Action specification **)
type action_spec =
    DiscreteActionSpec of int list list
    | ParamActionSpec of float_range list
    | NoSpec

(** Action representation **)
type action =
    DiscreteAction of int list
    | ParamAction of float list
    | NoOp
    with sexp

(** A particular problem instance **)
type problem = {
    name           : string;
    description    : string option;
    state          : problem_state;
    a_spec         : action_spec;
    action_names   : string array option;
    handle_action  : problem_state -> action -> (problem_state * float);
}

let empty = {
    name = "";
    description = None;
    state = {
        inner_state_ = NoState;
        instance = NoneInstance;
    };
    a_spec = NoSpec;
    action_names = None;
    handle_action = fun pstate _a -> pstate, 0.0;
}

let problem_of_sexp sexp =
    let failer () = failwith "expected (problem :name NAME)" in
    match sexp with
        | Sexp.List [
            Sexp.Atom "problem"; Sexp.Atom ":name"; Sexp.Atom name;
        ] -> {
            empty with name = name;
        }
        | Sexp.List _ -> failer ()
        | Sexp.Atom _ -> failer ()
let sexp_of_problem problem =
    Sexp.List [
        Sexp.Atom "problem";
        Sexp.Atom ":name";
        Sexp.Atom problem.name;
    ]

let in_range (a, b) x =
    Float.between ~low:a ~high:b x

let validate_action spec_ action_ =
    let validate_helper helper spec_list action =
        List.fold2_exn spec_list action ~init:true ~f:(fun valid spec_elm action_elm ->
            valid && (helper spec_elm action_elm)
        )
    in
    match spec_, action_ with
        | DiscreteActionSpec spec_list, DiscreteAction ilist ->
            validate_helper (List.mem ~equal:Int.equal) spec_list ilist
        | ParamActionSpec spec_list, ParamAction plist ->
            validate_helper in_range spec_list plist
        | DiscreteActionSpec _, ParamAction _ -> false
        | DiscreteActionSpec _, NoOp -> false
        | ParamActionSpec _, DiscreteAction _ -> false
        | ParamActionSpec _, NoOp -> false
        | NoSpec, ParamAction  _-> false
        | NoSpec, DiscreteAction _ -> false
        | NoSpec, _ -> false

let inner_states_equal is1 is2 =
    match is1, is2 with
        | IntState i, IntState i2 -> Int.equal i i2
        | NoState, NoState -> true
        | IntState _, _ -> false
        | NoState , _ -> false

let problem_instances_equal pi1 pi2 =
    match pi1, pi2 with
        | IntInstance i, IntInstance i2 -> Int.equal i i2
        | NoneInstance, NoneInstance -> true
        | IntInstance _, _ -> false
        | NoneInstance, _ -> false

let problem_states_equal ps1 ps2 =
    inner_states_equal ps1.inner_state_ ps2.inner_state_ &&
        problem_instances_equal ps1.instance ps2.instance

let int_list_equal il il2 =
    List.equal ~equal:Int.equal il il2

let float_range_equal flist flist2 =
    match flist, flist2 with
        | (l, u), (l2, u2) -> Float.equal l l2 && Float.equal u u2

let action_spec_equal as1 as2 =
    match as1, as2 with
        | DiscreteActionSpec spec_list, DiscreteActionSpec spec_list2 ->
            List.equal ~equal:int_list_equal spec_list spec_list2
        | ParamActionSpec spec_list, ParamActionSpec spec_list2 ->
            List.equal ~equal:float_range_equal spec_list spec_list2
        | NoSpec, NoSpec -> true
        | DiscreteActionSpec _, _ -> false
        | ParamActionSpec _, _ -> false
        | NoSpec, _ -> false

let action_equal as1 as2 =
    match as1, as2 with
        | DiscreteAction a, DiscreteAction a2 ->
            List.equal ~equal:Int.equal a a2
        | ParamAction a, ParamAction a2 ->
            List.equal ~equal:Float.equal a a2
        | NoOp, NoOp -> true
        | DiscreteAction _, _ -> false
        | ParamAction _, _ -> false
        | NoOp, _ -> false

let equal p1 p2 =
    String.equal p1.name p2.name &&
        Option.equal String.equal p1.description p2.description &&
            problem_states_equal p1.state p2.state &&
                action_spec_equal p1.a_spec p2.a_spec &&
                    Option.equal (Array.equal ~equal:String.equal) p1.action_names p2.action_names
