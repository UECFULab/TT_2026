%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Function to Plot VAF for Muscle Synergies
For each task, this function plots the VAF values against the number of synergies and plots the change in VAF over time when the number of synergies is fixed.

Input file：trial_timing, synergy_sqdev
output file：out_vaf_figure
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
post_name = ["pre1" "post1" "post2" "post3" "post4" "post5" "post6" "post7" "post8" "right710"];
task_name = "task04";
trial_name = ["trial1" "trial2" "trial3" "trial4" "trial5" "trial6" "trial7" "trial8" "trial9" "trial10" "trial11" "trial12" "trial13" "trial14" "trial15" "trial16"];
actual_day_name = [-5, 7, 14, 22, 82, 187, 327, 537, 670];
syn_fix3 = 3;
syn_fix2 = 2;

vaf_rate = cell(3, 1);
h_scaled = cell(3, 6);
clear R2 R2_std;
path_save = append('out_vaf_figure/vaf_', task_name);
dayIndxList = [1:4 6:9];
actual_day_list = actual_day_name(dayIndxList);
for j = dayIndxList %post index
    path_timing = append('trial_timing/timing_', post_name(j), '_', task_name);
    path_r2 = append('synergy_sqdev/synergy_', post_name(j), '_', task_name);
    load(path_timing);
    load(path_r2);
    count = size(on, 1);
    trial = on(:, 2) - on(:, 1) + 1;
    VAF_post = zeros(16, count);
    vaf_each = zeros(count, 1);
    synergy_num = zeros(count, 2);

    if post_name(j) == "pre1"
        n_muscle = 14;
    elseif post_name(j) == "post7"
        n_muscle = 15;
    else
        n_muscle = 16;
    end

    %% Get the VAF value
    r2 = zeros(n_muscle, count);
    for k = 1:count
        R = getfield(synergy_r2, trial_name(k));
        r2(:, k) = R(:, 1);
    end
    if post_name(j) == "pre1"
        R2(:, j) = cat(1, mean(r2, 2), [NaN; NaN]);
        R2_std(:, j) = cat(1, std(r2, 0, 2), [NaN; NaN]);
    elseif post_name(j) == "post7"
        R2(:, j) = cat(1, mean(r2, 2), NaN);
        R2_std(:, j) = cat(1, std(r2, 0, 2), NaN);
    else
        R2(:, j) = mean(r2, 2);
        R2_std(:, j) = std(r2, 0, 2);
    end
end

%Plot the VAF values against the synergy number
R2(:, 5) = [];
R2_std(:, 5) = [];
figure;
plot(R2, '-o');
xlabel('number of synergy');
ylabel('VAF');
legend({'pre surgery', 'Day1', 'Day2', 'Day3', 'Day4', 'Day5', 'Day6', 'Day7'}, 'Location', 'southeast');
yline(0.8, 'HandleVisibility', 'off');
grid minor;

%Plot the change in VAF over time when the synergy number is fixed
figure;
hold on;
r = rectangle('Position',[-10 0.65 710 0.15]','FaceColor',[0.85 0.85 0.85], 'EdgeColor','none');
errorbar(actual_day_list, R2(syn_fix3, 1:end), R2_std(syn_fix3, 1:end), '-+','LineWidth', 2.0);
errorbar(actual_day_list, R2(syn_fix2, 1:end), R2_std(syn_fix2, 1:end), '-+','LineWidth', 2.0);
ylim([0.65 1]);
xline(19);
xline(212);
xline(356);
xline(691);
legend('Synergy Num:3', 'Synergy Num:2', 'Location', 'best');
ylabel('VAF');
xticks(sort([actual_day_list, 19, 212, 356, 691]))
xlim([-10,700])
yticks(0.7:0.1:1)
set(gca, 'FontName','Arial', 'FontWeight','bold', 'FontSize',24, 'LineWidth',1.5, 'TickDir','out', 'XColor','k', 'YColor','k')
saveas(gcf, path_save, 'emf');

