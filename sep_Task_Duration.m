%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Extracting Task Durations for Cube and Rock-Scissors-Paper Tasks.

## Cube Task ##
Figures are output for each measurement day, plotting the Wrist joint x-coordinate in the first row, y-coordinate in the second row, and z-coordinate in the third row.

## Rock-Scissors-Paper Task ##
Figures are output for each measurement day, plotting the MP joint z-coordinate in the first row, the MP joint angle in the second row, and the PIP joint angle in the third row.

① When “Select the start timings” appears, place a data hint at the start of the trial.
② Export to the workspace and press Enter.
③ When “Select the end timings” appears, add data hints at the end of the trial.
④ Export to the workspace and press Enter.

From the points where data hints are added, the start and end positions are corrected based on the average value ± 3*standard deviation over a 0.3-second interval.

Input file: Each raw marker data file
Output file: trial_timing
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

post_name = ["pre1" "post1" "post2" "post3" "post4" "post5" "post6" "post7" "post8" "healthyside" "healthysub1" "healthysub2"];
task_name = ["task01" "task02" "task03" "task04" "task05"];
Task_name = ["Task01" "Task02" "Task03" "Task04" "Task05"]; 

for i = [1:4 6:10] %post index
    for j = [1 4] %task index
        marker_file = append('data/', post_name(i), '/', Task_name(j), '_Traj.csv');  
        savefile_name = append('timing_', post_name(i), '_', task_name(j), '.mat');
        file_dir = 'trial_timing/'; 
        file = append(file_dir, savefile_name); 
        data = readmatrix(marker_file);
        data = data(4:end, 3:end); 

        norm_data = zeros(size(data, 1), 12); 
        rad_angle = zeros(size(norm_data, 1), 2); 
        if size(data, 2) == 15
            norm_data(:, 1:3) = (data(:, 1:3) + data(:, 7:9))./2; 
            norm_data(:, 4:end) = data(:, [4:6 10:15]); 
        else 
            norm_data = data; 
        end

        %% Place a data hint at the start of the trial %%
        if task_name(k) == "task04" %Rock-Scissors-Paper Task Duration
            line = 6; %MPH joint z-coordinate
            fs = 100; %Sampling flequency
            flp = 15; %Low pass Flequency
            v1_mph = norm_data(:, 1:3) - norm_data(:, 4:6); 
            v2_mph = norm_data(:, 7:9) - norm_data(:, 4:6); 
            v1_pip = norm_data(:, 4:6) - norm_data(:, 7:9);
            v2_pip = norm_data(:, 10:12) - norm_data(:, 7:9); 
    
            for k = 1: size(norm_data, 1)
                rad_angle(k, 1) = acos((dot(v1_mph(k, :), v2_mph(k, :)) / (norm(v1_mph(k, :))*norm(v2_mph(k, :))))); 
                rad_angle(k, 2) = acos((dot(v1_pip(k, :), v2_pip(k, :)) / (norm(v1_pip(k, :))*norm(v2_pip(k, :))))); 
            end
    
            [b_lp, a_lp] = butter(2, 2.*flp ./ fs, 'low'); 
            rad_angle(:, 1) = filtfilt(b_lp, a_lp, rad_angle(:, 1)); 
            rad_angle(:, 1) = filtfilt(b_lp, a_lp, rad_angle(:, 1)); 
    
            figure; 
            for k = 1:3 
                subplot(3,1,k)
                if k == 1
                    hold on; 
                    plot(data(:, line)); 
                    title('MPH z position'); 
                elseif k == 2
                    hold on; 
                    plot(rad_angle(:, 1)); 
                    title('MPH angle'); 
                elseif k == 3
                    hold on; 
                    plot(rad_angle(:, 2)); 
                    title('PIP angle'); 
                end
                hold off;
            end
        else %Cube Task Duration
            figure; 
            for k = 1:3 % x, y, z
                subplot(3,1,k)
                hold on;
                plot(norm_data(:,k))
                hold off;
                if k == 1
                    title('x position');
                elseif k == 2
                    title('y position'); 
                else 
                    title('zposition'); 
                end
            end
        end
        disp('please select start position'); 
        clear cursor_info; 
        pause; 
        cursor_info;
        crsr_info_size = size(struct2table(cursor_info), 1); 
        clear on; 
        on = zeros(crsr_info_size, 2); 
        target = zeros(crsr_info_size, 1); 
        stdev = zeros(crsr_info_size, 1); 
        avg = zeros(crsr_info_size, 1); 
        for k = 1:crsr_info_size
            target(k) = cursor_info(k).DataIndex; 
        end
        target = sort(target); 
        close all; 
        for k = 1:crsr_info_size %Outlier Detection (using mean+3*std as the threshold)
            stdev(k) = std(data((target(k)-30):target(k), line));
            avg(k) = mean(data((target(k)-30):target(k), line));
            while data(target(k), line) < avg(k)+3*stdev(k)
                target(k) = 1 + target(k); 
            end
            on(k, 1) = target(k); 
        end

        %% %Place a data hint at the end of the trial. %%
        if taks_name(j) == "task04" %Rock-Scissors-Paper Task Duraiton
            figure; 
            for k = 1:3 % x, y, z
                subplot(3,1,k)
                hold on;
                yyaxis left; 
                plot(data(:,k*3))
                hold off;
                if k == 2
                    hold on; 
                    yyaxis right; 
                    plot(rad_angle(:, 1)); 
                elseif k == 3
                    hold on; 
                    yyaxis right
                    plot(rad_angle(:, 2)); 
                end
            end
        else %Cube Task Duration
            figure; 
            for k = 1:3 % x, y, z
                subplot(3,1,k)
                hold on;
                plot(norm_data(:,k))
                hold off;
                if k == 1
                    title('x position');
                elseif k == 2
                    title('y position'); 
                else 
                    title('zposition'); 
                end
            end
        end
        disp('please select end position'); 
        clear cursor_info; 
        pause; 
        cursor_info;
        crsr_info_size = size(struct2table(cursor_info), 1); 
        target = zeros(crsr_info_size, 1); 
        stdev = zeros(crsr_info_size, 1); 
        avg = zeros(crsr_info_size, 1); 
        target = sort(target); 
        close all; 
        if task_name(j) ~= "task04"
            for k = 1:crsr_info_size
                stdev(k) = std(data((target(k)+30):target(k), line));
                avg(k) = mean(data((target(k)+30):target(k), line));
                while data(target(k), line) < avg(k)+3*stdev(k)
                    target(k) = target(k) - 1; 
                end
            end
        end
        on(:, 2) = target; 
 
        save(file, "on", '-mat');
    end
end