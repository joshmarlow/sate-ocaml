open Core.Std

open Problem

let keep_it_up = {
    name = "Keep-it-up";
    description = Some "A game of keeping a falling integer from going to zero; the reward is the value of the integer";
    state = {
        inner_state_ = IntState 0;
        instance = IntInstance 0;
    };
    a_spec = DiscreteActionSpec [[-1; 0; 1]];
    action_names = Some [| "down"; "noop"; "up" |];
    handle_action = (fun p_state action ->
        match p_state.inner_state_ with
            | NoState -> failwith "Keep-it-up has no state; this should not happen"
            | IntState i -> begin
                    let new_i = match action with
                        | DiscreteAction [delta] -> Int.max 0 (Int.min (i + delta) 100)
                        | ParamAction _ -> failwith "Keep-it-up does not support a parametric interface."
                        | DiscreteAction _ -> failwith "Kee-it-up requres a discrete action with one element."
                        | NoOp -> failwith "Keep-it-up does not accept NoOps type constructors."
                    in
                    let reward = if new_i = 0 then 0.0 else 1.0 in
                    (
                        {
                            inner_state_ = IntState new_i;
                            instance = IntInstance new_i;
                        },
                        reward
                    );
                end);
}
