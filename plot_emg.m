%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Plot the EMG data. The mean and variance for all trials are calculated for each measurement day.
Assign whether to plot all EMGs or selected EMGs to the variable 'selected'(line:22). 

Input file: processed_EMG, trial_timing
Output file: emg_figure
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
muscle_name = ["IOD1" "2L" "3L" "4L" "APB" "ADQ" "EDC" "ECR" "BRD" "FCU" "FCR" "FDS" "Biceps" "Triceps" "DLA" "DLM"];  
post_name = ["pre1" "post1" "post2" "post3" "post4" "post5" "post6" "post7" "post8" "healthyside" "healthysub1" "healthysub2"];
task_name = ["task01" "task02" "task03" "task04" "task05"];
Task_name = ["LargeCube" "MiddleCube" "SmallCube" "Janken" "JankenLie"]; 
trial_name = ["trial1" "trial2" "trial3" "trial4" "trial5" "trial6" "trial7" "trial8" "trial9" "trial10" "trial11" "trial12" "trial13" "trial14" "trial15" "trial16"]; 

flt = 1; 
fhp = 50; %High pass frequency
flp = 20; %Low pass frequency
fs = 1000; %Sampling frequency
medianfilter = 1; %medianfilter (1:active, 0:deactive)
med_window = 200; %medianfilter window size
dsr = 100; %Downsampling frequency
normalize_method = 'mean'; 
selected = 0; %0:selected emg, 1:all emg

for i = [1 4] %task index
    figure; 
    if task_name(i) == "task04"
        posture_timing = NaN(15, 3); 
    elseif task_name(i) == "task01"
        posture_timing = NaN(15, 2); 
    end
    for j = [2:4 6:10] %post index
        path_emg = append('processed_EMG/emg_', post_name(j), '_', task_name(i)); 
        path_timing = append('trial_timing/timing_', post_name(j), '_', task_name(i));
        path_save = append('emg_figure/emg_', task_name(i)); 
        load(path_emg); 
        load(path_timing); 
        count = size(on, 1);
        trial = on(:, 2) -on(:, 1) + 1; 
        emg_fix = cell(count, 1); 

        if post_name(j) == "pre1"
            n_muscle = 15; 
        else
            n_muscle = 16; 
        end

        %% Normalize the EMG Data %%
        for k = 1:count 
            emg = getfield(each_trial, trial_name(k)); 
            for l = 1:100
                emg_fix{k, 1}(l, :) = emg(fix(l/100*trial(k)), :); 
            end
            for l = 1:n_muscle
                emg_fix{k, 1}(:, l) = emg_fix{k, 1}(:, l)./norm(emg_fix{k, 1}(:, l)); 
            end
        end

        %% Graph Setting and Drawing %%
        if post_name(j) == "post1"
            clr = [0.14 0 0]; 
        elseif post_name(j) == "post2"
            clr = [0.28 0 0]; 
        elseif post_name(j) == "post3"
            clr = [0.42 0 0]; 
        elseif post_name(j) == "post5"
            clr = [0.56 0 0]; 
        elseif post_name(j) == "post6"
            clr = [0.7 0 0]; 
        elseif post_name(j) == "post7"
            clr = [0.84 0 0]; 
        elseif post_name(j) == "post8"
            clr = [1 0 0]; 
        elseif post_name(j) == "healthyside"
            clr = [0 0 1]; 
        end
        
        ttl = append(Task_name(i)); 

        if selected == 0
            muidx = [1 7 8 10 11 12]; 
        elseif selected == 1
            muidx = 1:16;
        end

        idx = 0; 
        for k = 1:n_muscle
            hold on; 
            if any(k==muidx)
                idx = idx + 1; 
                emg_all = zeros(100, count); 
                for l = 1:count
                    emg_all(:, l) = emg_fix{l, 1}(:, k); 
                end
                    
                emg_avg = mean(emg_all, 2); 
                emg_std = std(emg_all, 0, 2); 

                if post_name(j) == "post7" && k == 5
                    emg_avg = NaN; 
                end

                if size(muidx, 2) == 6
                    subplot(3, 2, idx); 
                else
                    subplot(4, 4, idx); 
                end

                plt = plot(emg_avg, 'Color', clr, 'LineWidth', 2); 

                ylim([0 0.35]); 
                hold on; 
                title(muscle_name(k)); 
            end
        end
            
        posture_timing(j, :) = mean(on(:, 3:2+size(posture_timing, 2)), 1);

    end
    lgd = legend({'Day1', 'Day2', 'Day3', 'Day4', 'Day5', 'Day6', 'Day7', 'Healty Side'}, 'Location', 'best');
    lgd.NumColumns = 4;
    posture_timing = rmmissing(posture_timing); 
    posture_avg = mean(posture_timing, 1); 
    posture_std = std(posture_timing, 0, 1); 
    
    for nn = 1:size(muidx, 2)
        if size(muidx, 2) == 6
            subplot(3, 2, nn); 
        else
            subplot(4, 4, nn); 
        end
        for mm = 1:size(posture_avg, 2)
            l1 = xline(posture_avg(mm), 'HandleVisibility', 'off'); 
            uistack(l1, 'bottom'); 
            hold on; 
            ar1 = area([posture_avg(mm)-posture_std(mm) posture_avg(mm)+posture_std(mm)], [0.35 0.35], 'FaceColor', [0.9 0.9 0.9], 'HandleVisibility', 'off'); 
            uistack(ar1, 'bottom'); 
        end
    end

    saveas(gcf, path_save, 'emf'); 

end