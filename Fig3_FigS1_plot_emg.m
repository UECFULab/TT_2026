%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Function to Plot EMG Data
For each measurement day, the mean and variance for all trials are calculated.

Input file: processed_EMG, trial_timing
Output file: out_emg_figure
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
muscle_name = ["IOD1" "2L" "3L" "4L" "APB" "ADQ" "EDC" "ECR" "BRD" "FCU" "FCR" "FDS" "Biceps" "Triceps" "DLA" "DLM"];
post_name = ["pre1" "post1" "post2" "post3" "post4" "post5" "post6" "post7" "post8" "right710"];
task_name = "task04";
trial_name = ["trial1" "trial2" "trial3" "trial4" "trial5" "trial6" "trial7" "trial8" "trial9" "trial10" "trial11" "trial12" "trial13" "trial14" "trial15" "trial16"];


%%
% Normalize EMG Data of Unaffected Side %
load(append('processed_EMG/emg_', post_name(10), '_', task_name), "each_trial");
load(append('trial_timing/timing_', post_name(10), '_', task_name), "on");
countH = size(on, 1);
trial = on(:, 2) -on(:, 1) + 1;
emg_fix_healthy = cell(countH, 1);
for k = 1:countH
    emg = getfield(each_trial, trial_name(k));
    for l = 1:100
        emg_fix_healthy{k, 1}(l, :) = emg(fix(l/100*trial(k)), :);
    end
    for l = 1:length(muscle_name)
        emg_fix_healthy{k, 1}(:, l) = emg_fix_healthy{k, 1}(:, l)./norm(emg_fix_healthy{k, 1}(:, l));
    end
end
%--%

figure
% dispDayIndxList = [2,4,8];
dispDayIndxList = [2,4,9];
for j = 1:length(dispDayIndxList)
    dispDayIndx = dispDayIndxList(j);
    load(append('processed_EMG/emg_', post_name(dispDayIndx), '_', task_name), "each_trial");
    load(append('trial_timing/timing_', post_name(dispDayIndx), '_', task_name), "on");
    count = size(on, 1);
    trial = on(:, 2) -on(:, 1) + 1;
    % Normalize EMG Data %
    emg_fix = cell(count, 1);
    for k = 1:count
        emg = getfield(each_trial, trial_name(k));
        for l = 1:100
            emg_fix{k, 1}(l, :) = emg(fix(l/100*trial(k)), :);
        end
        for l = 1:length(muscle_name)
            emg_fix{k, 1}(:, l) = emg_fix{k, 1}(:, l)./norm(emg_fix{k, 1}(:, l));
        end
    end
    %--%
    posture_timing = on(:, 3:2+3);
    posture_avg = mean(posture_timing, 1);
    posture_std = std(posture_timing, 0, 1);
    idx = 0;
    dispEMGIndxList = [1,7,11,12];
    for i=1:length(dispEMGIndxList)
        disEMGIndx = dispEMGIndxList(i);
        hold on;
        idx = idx + 1;
        emg_all = zeros(100, count);
        for l = 1:count
            emg_all(:, l) = emg_fix{l, 1}(:, disEMGIndx);
        end
        emg_avg = mean(emg_all, 2);
        emg_std = std(emg_all, 0, 2);        
        %
        emg_all_healthy = zeros(100, countH);
        for l = 1:countH
            emg_all_healthy(:, l) = emg_fix_healthy{l, 1}(:, disEMGIndx);
        end
        emg_avg_healthy = mean(emg_all_healthy, 2);
        emg_std_healthy = std(emg_all_healthy, 0, 2);

        subplot(4,3, 3*(i-1)+j)
        plot(emg_avg, 'Color', 'b', 'LineWidth', 2);
        hold on;
        plot(emg_avg+emg_std, 'Color', 'b', 'LineWidth', 2);
        plot(emg_avg-emg_std, 'Color', 'b', 'LineWidth', 2);
        plot(emg_avg_healthy, 'Color', 'g', 'LineWidth', 2);
        plot(emg_avg_healthy+emg_std_healthy, 'Color', 'g', 'LineWidth', 2);
        plot(emg_avg_healthy-emg_std_healthy, 'Color', 'g', 'LineWidth', 2);
        ylim([0 0.35]);
        xticks([0,50,100]);
        %
        for mm = 1:size(posture_avg, 2)
            l1 = xline(posture_avg(mm), 'HandleVisibility', 'off', 'LineWidth', 2);
            uistack(l1, 'bottom');
            ar1 = area([posture_avg(mm)-posture_std(mm) posture_avg(mm)+posture_std(mm)], [0.35 0.35], 'FaceColor', [0.9 0.9 0.9], 'HandleVisibility', 'off');
            uistack(ar1, 'bottom');
        end
        hold off;
        if(j==1), ylabel(muscle_name(disEMGIndx)); end
        if(i==1), title(post_name(dispDayIndx)); end
        set(gca, 'FontName','Arial', 'FontWeight','bold', 'FontSize',12, 'LineWidth',1.5, 'XColor','k', 'YColor','k')
    end
end
saveas(gcf, append('out_emg_figure/emg_', task_name), 'emf');


%% Draw All EMGs
selected = 1; %0:selected emg, 1:all emg
figure;
posture_timing = NaN(15, 3);
for j = [2:4 6:10] %post index
    load(append('processed_EMG/emg_', post_name(j), '_', task_name), "each_trial");
    load(append('trial_timing/timing_', post_name(j), '_', task_name), "on");
    count = size(on, 1);
    trial = on(:, 2) -on(:, 1) + 1;

    if post_name(j) == "pre1"
        n_muscle = 15;
    else
        n_muscle = 16;
    end

    %% Normalize the EMG Data %%
    emg_fix = cell(count, 1);
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
    elseif post_name(j) == "right710"
        clr = [0 0 1];
    end

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
    xticks([0,50,100]);
    set(gca, 'FontName','Arial', 'FontWeight','bold', 'FontSize',12, 'LineWidth',1.5, 'XColor','k', 'YColor','k')
end
saveas(gcf, append('out_emg_figure/emgAll_', task_name), 'emf');
