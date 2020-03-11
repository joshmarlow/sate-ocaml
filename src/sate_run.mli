open Core.Std

type sate_run = {
    problem_runs : Problem_run.problem_run list;
    start_time   : Time.t;
    end_time     : Time.t option;
} with sexp

val get_available_problems : unit -> (string * Problem.problem) list

val get_available_agents : unit -> (string * Agent.agent) list

val run_problem : ?max_interactions:int -> Agent.agent -> string ->
    Problem_run.problem_run

val run_problems : ?max_interactions:int -> string list -> string ->
    sate_run

val save_run : sate_run -> string -> unit

val load_run : string -> sate_run
