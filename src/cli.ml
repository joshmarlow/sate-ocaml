open Core.Std

let default_sate_directory = "runs"
let datetime_format = "%Y-%m-%dT-%H-%M-%S"

let construct_formatted_now () = Time.format (Time.now ()) datetime_format
let construct_default_run_output_filepath () =
    Filename.concat default_sate_directory (Printf.sprintf "run-%s.lsp" (construct_formatted_now ()))

let construct_default_report_output_filepath () =
    Printf.sprintf "report-%s.png" (construct_formatted_now ())

let run_subcommand =
    let default_filename = construct_default_run_output_filepath () in
    Command.basic ~summary: "Test an agent against one or more problems"
        Command.Spec.(
            empty
            +> anon ("problem_list" %: string)
            +> anon ("agent" %: string)
            +> flag "-o" (optional_with_default default_filename file)
                        ~doc:"output filepath for run results"
        )
        (fun problems agent_name filename () ->
            let problem_list = String.split ~on:',' problems in
            let run = Sate_run.run_problems ~max_interactions:100 problem_list agent_name in
            Sate_run.save_run run filename)

let report_subcommand =
    let default_report_filename = construct_default_report_output_filepath () in
    Command.group ~summary: "Report on a previous run"
        [
            ("chart", Command.basic ~summary: "Create a chart displaying the results of the run."
                Command.Spec.(
                    empty
                    +> anon ("run_filename" %: file)
                    +> flag "-o" (optional_with_default default_report_filename file)
                                ~doc:"output filepath for run report"
                )
                (fun run_filename report_filename () ->
                    let sate_run = Sate_run.load_run run_filename in
                    Report.render_run sate_run report_filename;
                    Printf.printf "Report in %s\n" report_filename)
            );
            ("summary", Command.basic ~summary: "Display a text summary fo the run."
                Command.Spec.(
                    empty
                    +> anon ("run_filename" %: file)
                )
                (fun run_filename () ->
                    let sate_run = Sate_run.load_run run_filename in
                    Report.display_summary sate_run)
            );
        ]

let list_agents_subcommand =
    let list_agent (agent_name, agent_) =
        (Printf.printf "\t%s - %s\n" agent_name (Option.value ~default:"N/A" agent_.Agent.description))
    in
    let available_agents = Sate_run.get_available_agents () in
    let spec = Command.Spec.empty in
    Command.basic ~summary:"List available agents"
                    spec
                    (fun () -> List.iter ~f:list_agent available_agents)

let list_problems_subcommand =
    let list_problem (problem_name, problem_) =
        (Printf.printf "\t%s - %s\n" problem_name (Option.value ~default:"N/A" problem_.Problem.description))
    in
    let available_problems = Sate_run.get_available_problems () in
    let spec = Command.Spec.empty in
    Command.basic ~summary:"List available problems"
                    spec
                    (fun () -> List.iter ~f:list_problem available_problems)

let command_group =
    Command.group
        ~summary: "sate - a testing framework for AI systems"
        ~readme: (fun () -> "sate - a testing framework for AI systems")
        [
            "run", run_subcommand;
            "report", report_subcommand;
            "list-agents", list_agents_subcommand;
            "list-problems", list_problems_subcommand;
        ]

let () =
    Command.run ~build_info:"dev" ~version:"0.1" command_group
