open Core.Std

type sate_run = {
    problem_runs : Problem_run.problem_run list;
    start_time   : Time.t;
    end_time     : Time.t option;
} with sexp

let make_problem_available available_problems problem =
    (problem.Problem.name, problem) :: available_problems

let make_agent_available available_agents agent =
    (agent.Agent.name, agent) :: available_agents

let available_problems = make_problem_available [] Problems.keep_it_up

let available_agents = make_agent_available [] Agents.rando

let load_agent name =
    match List.Assoc.find available_agents name with
        | None -> failwith (Printf.sprintf "Cannot find specified agent - %s\n" name)
        | Some agent -> agent

let load_problem name =
    match List.Assoc.find available_problems name with
        | None -> failwith (Printf.sprintf "Cannot find specified problem - %s\n" name)
        | Some problem -> problem

let get_available_problems () =
    available_problems

let get_available_agents () =
    available_agents

let run_problem ?max_interactions:(max_interactions=10) agent problem_name =
    let problem_run = {
        Problem_run.problem_ = load_problem problem_name;
        Problem_run.agent_ = agent;
        Problem_run.interactions = [];
        Problem_run.start_time = Time.now ();
        Problem_run.end_time = None;
    } in
    Utils.recurse Interaction.perform_interaction problem_run max_interactions

let run_problems ?max_interactions:(max_interactions=10) problem_list agent_name =
    let start_time = Time.now () in
    let agent = load_agent agent_name in
    {
        problem_runs = List.map ~f:(run_problem ~max_interactions:max_interactions agent)
                                problem_list;
        start_time = start_time;
        end_time = Some (Time.now ());
    }

let ensure_directory_exists filename =
    Unix.mkdir_p (Filename.dirname filename)

let save_run run filename =
    Printf.printf "Saving in %s\n" filename;
    let sexp = sexp_of_sate_run run in
    let sexp_str = Sexp.to_string sexp in
    ensure_directory_exists filename;
    Out_channel.write_all filename ~data:sexp_str

let load_run filename =
    let sexp_str = In_channel.read_all filename in
    let sexp = Sexp.of_string sexp_str in
    sate_run_of_sexp sexp
