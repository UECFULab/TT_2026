%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Record the timing of the Rock, Paper, Scissors poses in the Janken task, and the Grasp and Release timings in the Cube task.
Specify which task to perform the operation on via ‘input’. (‘cube’, ‘janken’)
① Add data hints for all timings to every graph output.
② Export to workspace
③ Enter

Input file：trial_timing
Output file：trial_timing
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
post_name = ["pre1" "post1" "post2" "post3" "post4" "post5" "post6" "post7" "post8" "healthyside" "healthysub1" "healthysub2"];
task_name = ["task01" "task02" "task03" "task04" "task05"];
trial_name = ["trial1" "trial2" "trial3" "trial4" "trial5" "trial6" "trial7" "trial8" "trial9" "trial10" "trial11" "trial12" "trial13" "trial14" "trial15" "trial16"]; 
Task_name = ["Task01" "Task02" "Task03" "Task04"]; 
option = input('task type cube or janken> '); 

for i = [1 4] %task index
    for j = [1:4 6:10] %post index
        path_timing = append('trial_timing/timing_', post_name(j), '_', task_name(i), '.mat'); 
        path_save = append('trial_timing/timing_', post_name(j), '_', task_name(i), '.mat'); 
        load(path_timing); 
        trial = on(:, 2)-on(:, 1)+1;
        count = size(on, 1); 
        on_mat = zeros(count, 8); 

        switch option 
            case 'cube'
                path_mk = append(post_name(j), '/', Task_name(i), '_Traj.csv'); 
                data = readmatrix(path_mk);
                data(:, 1:2) = []; 
                data(1:3, :) = []; 
                if size(data, 2) == 12
                    data_norm = data; 
                else
                    data_norm(:, 1:3) = (data(:, 1:3)+data(:, 7:9))./2; 
                    data_norm(:, 4:12) = data(:, [4:6 10:15]); 
                end
                if post_name(j) == "post4" %Coordinate axes are misaligned.
                    data(:, 1:3:13) = -1*data(:, 1:3:13); 
                end

                wrist = data_norm(:, 1:3); 
                mph = data_norm(:, 4:6); 
                pip = data_norm(:, 7:9); 
                dip = data_norm(:, 10:12); 

                figure; 
                for k = 1:count
                    wrist_fix = zeros(100, 3); 
                    for l = 1:100
                        wrist_fix(l, :) = wrist(on(k, 1) + fix(trial(k)*l/100) - 1, :); 
                    end
                    subplot(ceil(count/2), 2, k); 
                    yyaxis left; 
                    plot(wrist_fix(:, 1));
                    hold on; 
                    yyaxis right;
                    plot(wrist_fix(:, 2)); 
                end

                clear cursor_info; 
                pause; 
                cursor_info;
                on_idx = zeros(count*2, 1); 
                for nn = 1:count*2
                    on_idx(nn) = cursor_info(nn).DataIndex; 
                end
                on_idx = reshape(on_idx, 2, count);
                on_idx = flip(on_idx)'; 
                on_idx = sort(on_idx, 2); 
                close all; 

                on(:, 3:end) = []; 
                on = cat(2, on, on_idx); 

            case 'janken'
                path_mk = append('processed_marker/marker_', post_name(j), '_', Task_name(i), '.mat'); 
                load(path_mk); 

                [rec_plotmr, w_obs, M_obs, H_obs] = motion_RBF(plotmr); 
                [row, col] = find(isnan(plotmr)); 
                plotmr(row, col) = rec_plotmr(row, col); 
                vel_mph = diff(plotmr, 1, 1); 
                [b_lp, a_lp] = butter(2, 2.*10 ./ 100, 'low'); 

                for k = 1:count
                    vel_mph(:, k) = filtfilt(b_lp, a_lp, vel_mph(:, k));
                end
        
                figure; 
                for k = 1:count
                    subplot(ceil(count/2), 2, k); 
                    yyaxis left; 
                    plot(plotmr(:, k)); 
                    ylim([70 200]); 
                    hold on; 
                    yyaxis right; 
                    plot(vel_mph(:, k)); 
                    yline(0); 
                end
                clear cursor_info; 
                pause; 
                cursor_info;
                on_idx = zeros(count*3, 1); 
                for nn = 1:count*3
                    on_idx(nn) = cursor_info(nn).DataIndex; 
                end
                on_idx = flip(reshape(on_idx, [3, count]), 1)'; 
                on_idx = sort(on_idx, 2); 
                on(:, 3:end) = []; 
                on = cat(2, on, on_idx); 
                close all; 
        end
        save(path_save, "on"); 
    end
end