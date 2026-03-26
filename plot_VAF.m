%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Plot the VAF.
For each task, plot the VAF value against the number of synergies and the temporal change in VAF when the number of synergies is fixed.(line:13)
Input file：trial_timing, synergy_sqdev
output file：vaf_figure
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
post_name = ["pre1" "post1" "post2" "post3" "post4" "post5" "post6" "post7" "post8" "healthyside" "healthysub1" "healthysub2"];
task_name = ["task01" "task02" "task03" "task04" "task05"];
Task_name = {'LargeCube' 'MiddleCube' 'SmallCube' 'Janken' 'JankenLie'}; 
trial_name = ["trial1" "trial2" "trial3" "trial4" "trial5" "trial6" "trial7" "trial8" "trial9" "trial10" "trial11" "trial12" "trial13" "trial14" "trial15" "trial16"]; 
syn_fix = 3; 

for i = [1 4] %task index
    vaf_rate = cell(3, 1); 
    h_scaled = cell(3, 6); 
    clear R2 R2_std; 
    path_save = append('vaf_figure/vaf_', task_name(i)); 
    for j = [1:4 6:10] %post index
        path_timing = append('trial_timing/timing_', post_name(j), '_', task_name(i)); 
        path_r2 = append('synergy_sqdev/synergy_', post_name(j), '_', task_name(i)); 
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
    errorbar(1:8, R2(syn_fix, 1:end-1), R2_std(syn_fix, 1:end-1), '-+'); 
    ylim([0.65 1]); 
    yline(R2(3, end), '-', {'Healthy side'}); 
    hold on; 
    ar1 = area(1:8, repmat([R2(3, end)-R2_std(3, end) R2_std(3, end)+R2_std(3,end)], 8, 1)); 
    set(ar1(1),'FaceColor','None','LineStyle',':','EdgeColor', [0 0 0]); 
    set(ar1(2),'FaceColor', [0 0 0], 'FaceAlpha',0.1,'LineStyle',':','EdgeColor', [0 0 0]); 
    xticklabels({'pre surgery', 'Day1', 'Day2', 'Day3', 'Day4', 'Day5', 'Day6', 'Day7'}); 
    ylabel('VAF'); 
    
    saveas(gcf, path_save, 'emf'); 

end
