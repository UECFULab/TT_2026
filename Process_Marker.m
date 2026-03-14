%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Calculate joint angles from marker data.
Due to insufficient marker points around the wrist joint in “pre1”, ‘post1’, and “post3”, wrist joint angles cannot be calculated.

Input file: Each raw marker data
Output file: processed_marker
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
post_name = ["pre1" "post1" "post2" "post3" "post4" "post5" "post6" "post7" "post8" "healthyside" "healthysub1" "healthysub2"];
task_name = ["task01" "task02" "task03" "task04" "task05"];
Task_name = ["Task01" "Task02" "Task03" "Task04" "Task05"]; 
for post = [1:4 6:10] %post index
    for task = [1 4] %task index
        path_data = append('data/', post_name(post), '/', Task_name(task), '_Traj.csv'); 
        path_timing = append('trial_timing/timing', '_', post_name(post), '_', task_name(task)); 
        data = readmatrix(path_data); 
        savefile_name = append('processed_marker/marker_', post_name(post), '_', task_name(task), '.mat');
        fig_dir = 'processed_marker/'; 
        data = data(4:end, 3:end); 
        sm = size(data, 1); 
        marker_case = size(data, 2); 

        % Data type
        if marker_case < 15
            data_type = 0; %recessive 
        else
            data_type = 1; %dominant 
        end

        if post_name(l) == "post4"
            data(:, 1:3:13) = -1*data(:, 1:3:13); 
        end

        %Read trial_timing
        load(path_timing);
        trial = on(:, 2) - on(:, 1) + 1;
        p = sum(trial); 
        count = size(on, 1); 

        % Get the marker corrdinate
        uln = []; 
        rad = []; 
        wrist = []; 
        mph3 = []; 
        pip3 = []; 
        dip3 = []; 
        for j = 1:count
            if data_type == 1
                uln = cat(1, uln, data(on(j, 1):on(j, 2), 1:3));
                rad  = cat(1, rad, data(on(j, 1):on(j, 2), 7:9)); 
                wrist = cat(1, wrist, (data(on(j, 1):on(j, 2), 1:3)+data(on(j, 1):on(j, 2), 7:9))/2); 
                mph3 = cat(1, mph3, data(on(j, 1):on(j, 2), 4:6)); 
                pip3 = cat(1, pip3, data(on(j, 1):on(j, 2), 10:12)); 
                dip3 = cat(1, dip3, data(on(j, 1):on(j, 2), 13:15)); 
            elseif data_type == 0
                wrist = cat(1, wrist, data(on(j, 1):on(j, 2), 1:3));
                mph3 = cat(1, mph3, data(on(j, 1):on(j, 2), 4:6)); 
                pip3 = cat(1, pip3, data(on(j, 1):on(j, 2), 7:9)); 
                dip3 = cat(1, dip3, data(on(j, 1):on(j, 2), 10:12)); 
            end
        end

        %Calcuration of segment angle. (radial value)
        %rad wrist
        zvec = zeros(size(uln, 1), 3); 
        zvec(:, 3) = 1; 
        frontvec = cross(uln - rad, zvec); 
        wristrad = zeros(p, 1); 
        mph3rad = zeros(p, 1); 
        pip3rad = zeros(p, 1); 
        if data_type == 1
            for i = 1:p
                wristrad(i) = acos(dot(frontvec(i, :), mph3(i, :)-wrist(i, :))/(norm(frontvec(i, :))*norm(mph3(i, :)-wrist(i, :)))); 
            end
        end

        %rad mph3
        for i = 1:p 
            mph3rad(i) = acos(dot(wrist(i, :)-mph3(i, :), pip3(i, :)-mph3(i, :))/(norm(wrist(i, :)-mph3(i, :))*norm(pip3(i, :)-mph3(i, :)))); 
        end

        %rad pip3
        for i = 1:p 
            pip3rad(i) = acos(dot(mph3(i, :)-pdip3(i, :), dip3(i, :)-pip3(i, :))/(norm(mph3(i, :)-pip3(i, :))*norm(dip3(i, :)-pip3(i, :)))); 
        end

        %Normarize the task duration
        plotwr = NaN(100, count); 
        plotmr = NaN(100, count); 
        plotpr = NaN(100, count); 
        for i = 1:count
            for j = 1:100
                if i == 1
                    plotwr(j, i) = wristrad(fix(trial(i)*j/100)); 
                    plotmr(j, i) = mph3rad(fix(trial(i)*j/100)); 
                    plotpr(j, i) = pip3rad(fix(trial(i)*j/100)); 
                else
                    plotwr(j, i) = wristrad(sum(trial(1:i-1))+ fix(trial(i)*j/100));
                    plotmr(j, i) = mph3rad(sum(trial(1:i-1))+ fix(trial(i)*j/100));
                    plotpr(j, i) = pip3rad(sum(trial(1:i-1))+ fix(trial(i)*j/100));
                end
            end
        end
        plotwr = plotwr.*180./pi; 
        plotmr = plotmr.*180./pi; 
        plotpr = plotpr.*180./pi; 

        if post_name(l) == "healthyside"
            plotwr = 180-plotwr; 
        end

        %Save data
        if data_type == 1
            save(savefile_name, "plotwr", '-mat');
        end
        save(savefile_name, "plotmr", '-mat', "-append"); 
        save(savefile_name, "plotpr", '-mat', "-append"); 
    end
end