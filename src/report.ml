open Core.Std

open Problem_run
open Sate_run

let script_filename = ".sate_gnuplot_scriptfile"
let data_filename = ".sate_gnuplot_data"

let gather_interactions_for_iteration sate_run iteration =
    List.map ~f:(fun p_run ->
        List.nth p_run.interactions iteration
    ) sate_run.problem_runs

let compute_max_interactions sate_run =
    List.fold_left ~init:0
                    ~f:(fun acc p_run -> Int.max acc (num_interactions p_run))
                    sate_run.problem_runs

let compute_max_reward sate_run =
    (*** Determine the maximum reward received over this sate_run ***)
    match List.max_elt ~cmp:Float.compare begin
        List.map ~f:max_reward_exn sate_run.problem_runs
    end with
        | None -> failwith "sate_run has no interactions!"
        | Some reward -> reward

let render_script sate_run filename =
    let construct_line_title p_run =
        Printf.sprintf "%s/%s" p_run.agent_.Agent.name p_run.problem_.Problem.name
    in
    let plot_args = String.concat ~sep:", " begin List.mapi ~f:(fun idx p_run ->
        Printf.sprintf "'%s' using 1:%d title '%s' with linespoints" data_filename (idx + 2) (construct_line_title p_run))
        sate_run.problem_runs
    end in
    let title = Filename.chop_extension (Filename.basename filename) in
    String.concat ~sep:"\n" [
        "set terminal png";
        "set xlabel 'Interactions'";
        "set ylabel 'Reward'";
        Printf.sprintf "set title \"%s\"" title;
        Printf.sprintf "set xrange [0:%d]" (compute_max_interactions sate_run);
        Printf.sprintf "set yrange [0.0:%f]" (1.1 *. compute_max_reward sate_run);
        "set zeroaxis";
        Printf.sprintf "plot %s\n" plot_args;
    ]

let render_data sate_run =
    let construct_rewards_line_for_iteration iteration =
        (*** Construct a line of all rewards that occurred during the specified iteration. ***)
        String.concat ~sep:" " begin
            List.map ~f:(function
                | None -> " "
                | Some interaction -> Printf.sprintf "%f" interaction.reward
            ) (gather_interactions_for_iteration sate_run iteration)
        end
    in
    String.concat ~sep:"\n" begin
        List.map ~f:(fun idx ->
            Printf.sprintf "%d %s" idx (construct_rewards_line_for_iteration idx)
        ) (List.range 0 (compute_max_interactions sate_run))
    end

let render_run sate_run filename =
    if List.is_empty sate_run.problem_runs then
        failwith "Nothing to render!"
    else begin
        Out_channel.write_all script_filename ~data:(render_script sate_run filename);
        Out_channel.write_all data_filename ~data:(render_data sate_run);
        let gnuplot_command = Printf.sprintf "gnuplot %s > %s" script_filename filename in
        let command_execution_result = Unix.system gnuplot_command in
        if Result.is_error command_execution_result then
            failwith "Could not render run"
        else
            ()
    end

let summarize_agent_score sate_run agent_name =
    let runs_for_this_agent = List.filter ~f:(fun p_run -> String.equal p_run.agent_.Agent.name agent_name)
                                            sate_run.problem_runs in
    let total_reward = List.fold_left ~init:0.0 ~f:(+.) begin
        List.map ~f:total_reward runs_for_this_agent
    end in
    let total_interactions = List.fold_left ~init:0 ~f:(+) begin
        List.map ~f:num_interactions runs_for_this_agent
    end in
    Printf.sprintf "Agent: %s - Num interactions: %d - Total reward: %f" agent_name total_interactions total_reward

let display_summary sate_run =
    let agents_tested = List.remove_consecutive_duplicates ~equal:String.equal begin
        List.sort ~cmp:String.compare begin
            List.map ~f:(fun p_run -> p_run.agent_.Agent.name) sate_run.problem_runs
        end
    end in
    Printf.printf "%s\n" begin
        String.concat ~sep:"\n" begin
            List.map ~f:(fun agent_name -> summarize_agent_score sate_run agent_name) agents_tested
        end
    end
