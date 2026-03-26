%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Plot the spatial and temporal basis sets of muscle synergies.
Specify in the 'type'(line:20) whether to plot each individual trial for every measurement day or to plot the trial average.('detail', 'mean')

Inside Function: sort_sunergy.m
Input file: trial_timing, synergy_spatial, synergy_temporal, synergy_sqdev
Output file：synergy_figure_detail, synergy_figure
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
post_name = ["pre1" "post1" "post2" "post3" "post4" "post5" "post6" "post7" "post8" "healthyside" "healthysub1" "healthysub2"];
post_date = ["0" "7" "14" "22" "82" "187" "327"]; 
task_name = ["task01" "task02" "task03" "task04" "task05"];
Task_name = ["LargeCube" "MiddleCube" "SmallCube" "Janken" "JankenLie"]; 
trial_name = ["trial1" "trial2" "trial3" "trial4" "trial5" "trial6" "trial7" "trial8" "trial9" "trial10" "trial11" "trial12" "trial13" "trial14" "trial15" "trial16"]; 
sy_name = ["sy1" "sy2" "sy3" "sy4" "sy5"]; 
day_name = ["pre surgery" "Day1" "Day2" "Day3" "" "Day4" "Day5" "Day6" "Day7", "Healthy side", "Healthy sub1", "Healthy sub2"]; 
sy_n_option = 1; %how the number of synergies determined

type = 'mean'; 
task_idx = [1 4]; 
post_idx = [1:4 6:10]; 

for i = task_idx %task01~05
    sy_n_before = []; 
    sigma_w = NaN(9, 3);
    sigma_h = NaN(9, 3); 
    t_vari = cell(9, 3); 
    p_mat = zeros(3);  
    for j = post_idx %pre1,post1~8,healtyside
        path_timing = append('trial_timing/timing_', post_name(j), '_', task_name(i));
        path_figure_detail = append('synergy_figure_detail/', post_name(j), '_', task_name(i));
        path_figure = append('synergy_figure/', post_name(j), '_', task_name(i));
        path_synergy_w = append('synergy_spatial/synergy_', post_name(j), '_', task_name(i)); 
        path_synergy_h = append('synergy_temporal/synergy_', post_name(j), '_', task_name(i)); 
        path_synergy_r2 = append('synergy_sqdev/synergy_', post_name(j), '_', task_name(i));
        load(path_synergy_w); 
        load(path_synergy_h); 
        load(path_synergy_r2); 
        load(path_timing); 
        count = size(on, 1);
        trial = on(:, 2) - on(:, 1) + 1; 
        threshold_VAF = 0.8;  
        synergy_num = zeros(count, 2);
        if post_name(j)=="pre1"
            n_muscle = 14; 
            x = categorical({'IOD1', '2L', '3L', '4L', 'APB', 'ADQ', 'EDC', 'ECR', 'BRD', 'FCU', 'FCR', 'FDS', 'Biceps', 'Triceps'}); 
            x = reordercats(x, {'IOD1', '2L', '3L', '4L', 'APB', 'ADQ', 'EDC', 'ECR', 'BRD', 'FCU', 'FCR', 'FDS', 'Biceps', 'Triceps'});
        elseif post_name(j) == "healthysub2"
            n_muscle = 15; 
            x = categorical({'IOD1', '2L', '3L', '4L', 'APB', 'EDC', 'ECR', 'BRD', 'FCU', 'FCR', 'FDS', 'Biceps', 'Triceps', 'DLA', 'DLM'}); 
            x = reordercats(x, {'IOD1', '2L', '3L', '4L', 'APB', 'EDC', 'ECR', 'BRD', 'FCU', 'FCR', 'FDS', 'Biceps', 'Triceps', 'DLA', 'DLM'});
        elseif post_name(j) == "post7"
            n_muscle = 15; 
            x = categorical({'IOD1', '2L', '3L', '4L', 'ADQ', 'EDC', 'ECR', 'BRD', 'FCU', 'FCR', 'FDS', 'Biceps', 'Triceps', 'DLA', 'DLM'}); 
            x = reordercats(x, {'IOD1', '2L', '3L', '4L', 'ADQ', 'EDC', 'ECR', 'BRD', 'FCU', 'FCR', 'FDS', 'Biceps', 'Triceps', 'DLA', 'DLM'});
        else
           
            n_muscle = 16; 
            x = categorical({'IOD1', '2L', '3L', '4L', 'APB', 'ADQ', 'EDC', 'ECR', 'BRD', 'FCU', 'FCR', 'FDS', 'Biceps', 'Triceps', 'DLA', 'DLM'}); 
            x = reordercats(x, {'IOD1', '2L', '3L', '4L', 'APB', 'ADQ', 'EDC', 'ECR', 'BRD', 'FCU', 'FCR', 'FDS', 'Biceps', 'Triceps', 'DLA', 'DLM'});
        end

        figure; 

        %% Determine the numer of synergies %%
        % 0:compared with shaffled data. (method of Ohta)
        % 1:determine with threshold
        % 2:fix the number of ysnergies with 3
        switch sy_n_option
            case 0 
                r2_real = zeros(n_muscle, count); 
                r2_shuffle = zeros(n_muscle, count); 
                r2_real_diff = zeros(n_muscle-1, count); 
                r2_shuffle_diff = zeros(n_muscle-1, count); 
                sy_n_each = zeros(count, 1); 
                for k = 1:count
                    r2 = getfield(synergy_r2, trial_name(k));
                    r2_real(:, k) = r2(:, 1); 
                    r2_shuffle(:, k) = r2(:, 2); 
                    r2_real_diff(:, k) = diff(r2_real(:, k)); 
                    r2_shuffle_diff(:, k) = diff(r2_shuffle(:, k)); 
                    for l = 1:16
                        if r2_real_diff(l, k) < r2_shuffle_diff(l, k)
                            break; 
                        end
                    end
                    sy_n_each(k) = l; 
                end
                sy_n = mode(sy_n_each); 

            case 1
                r2_real = zeros(n_muscle, count); 
                for k = 1:count
                    r2 = getfield(synergy_r2, trial_name(k)); 
                    r2_real(:, k) = r2(:, 1); 
                end
                r2_real_mean = mean(r2_real, 2); 
                for k = 1:16
                    if r2_real_mean(k) > threshold_VAF
                        break; 
                    end
                end
                sy_n = k; 

            case 2
                sy_n = 3; 
        end                     
         
        vaf = mean(synergy_num(:, 2));  

        [syw_each, syh_each] = sort_synergy(synergy_w, synergy_h, sy_n, n_muscle, on, task_name(i), post_name(j)); 
        
        %% Out put the figure %%
        switch type %How the figure drawn
            case 'detail'
                for k = 1:sy_n
                    bar_y = double.empty; 
                    graph_y = double.empty; 
                    for m = 1:count
                        y = syw_each{m, 1};
                        bar_y = cat(2, bar_y, y(:, k));
                        y = syh_each{m, 1}; 
                        graph_y = cat(2, graph_y, y(k, :)'); 
                    end
                    subplot(sy_n, 2, 2*k-1);
                    bar(x, bar_y, "FaceColor", [0.2 0.2 1], "EdgeColor", [0.2 0.2 1]);
                    subplot(sy_n, 2, 2*k); 
                    plot(graph_y, 'Color', [0.2 0.2 1]);
                end
                saveas(gcf, path_figure_detail, 'emf'); 
                close all;

             case 'mean'
                 ttl = append(day_name(j)); 
                 sgtitle(ttl, 'FontSize', 18); 
                 for k = 1:sy_n
                    bar_y = double.empty; 
                    graph_y = double.empty; 
                    for m = 1:count
                        y = syw_each{m, 1}; 
                        bar_y = cat(2, bar_y, y(:, k));
                        y = syh_each{m, 1}; 
                        graph_y = cat(2, graph_y, y(k, :)'); 
                    end

                    avg_bar = mean(bar_y, 2); 
                    sigma_w(j, k) =  std(avg_bar); 

                    %%Plot saptial synergy

                    stde_bar = std(bar_y, 0, 2);
                    subplot(sy_n, 2, 2*k-1); 
                    b = bar(x, avg_bar, "FaceColor", [0.2 0.2 1]);
                    %b = bar(1:n_muscle, avg_bar, "FaceColor", [0.2 0.2 1]);
                    b.FaceColor = "flat"; 
                    if post_name(j) == "post7" %APB emg data was discarded
                        b.CData(6, :) = [1 0.2 0.2]; 
                        b.CData(10, :) = [1 0.2 0.2]; 
                    else
                        b.CData(7, :) = [1 0.2 0.2]; 
                        b.CData(11, :) = [1 0.2 0.2]; 
                    end
                    hold on; 
                    er = errorbar(x, avg_bar,stde_bar,stde_bar); 
                    %er = errorbar(1:n_muscle, avg_bar,stde_bar,stde_bar); 
                    er.Color = [0 0 0];                            
                    er.LineStyle = 'none'; 
                    h_axis = gca;
                    %h_axis.XAxis.FontSize = 12;
                    h_axis.YAxis.FontSize = 12;
                    hold off; 
   
                    avg_graph = mean(graph_y, 2); 
                    stde_graph = std(graph_y, 0, 2);

                    vec_dist = zeros(count, 1); 
                    for nn = 1:count
                        r = corrcoef(avg_graph, graph_y(:, nn)); 
                        vec_dist(nn) = r(1, 2)/(norm(avg_graph)*norm(graph_y(:, nn))); 
                    end
                    sigma_h(j, k) = std(vec_dist); 
                    t_vari{j, k} = graph_y; 

                    %%Plot temporal synergy
                    subplot(sy_n, 2, 2*k); 
                    plot(avg_graph, 'Color', [0.2 0.2 1], 'LineWidth', 2);
                    hold on; 
                    ar1=area(1:100,[avg_graph-stde_graph stde_graph+stde_graph]); 
                    set(ar1(1),'FaceColor','None','LineStyle',':','EdgeColor',[0.2 0.2 1]); 
                    set(ar1(2),'FaceColor', [0.2 0.2 1], 'FaceAlpha',0.2,'LineStyle',':','EdgeColor',[0.2 0.2 1]); 
                    h_axis = gca;
                    h_axis.XAxis.FontSize = 12;
                    h_axis.YAxis.FontSize = 12;
                    if task_name(i) == "task01"
                        ylim([0 0.3]); 
                    elseif task_name(i) == "task04"
                        if k == 1
                            ylim([0 0.4]); 
                        else
                            ylim([0 0.3]); 
                        end
                    end
                    
                    if size(on, 2)>2
                        if task_name(i) == "task04"
                            posture_avg = mean(on(:, 3:5), 1); 
                            posture_std = std(on(:, 3:5), 0, 1); 
                        elseif task_name(i) == "task01"
                            posture_avg = mean(on(:, 3:4), 1); 
                            posture_std = std(on(:, 3:4), 0, 1); 
                        end 

                        if k == 1 
                            hight = 0.4; 
                        else
                            hight = 0.3;
                        end
                        xline(posture_avg); 
                        for nn = 1:size(posture_avg, 2)
                            ar2 = area([posture_avg(nn)-posture_std(nn) posture_avg(nn)+posture_std(nn)], [hight hight], 'FaceColor', [0.9 0.9 0.9], 'EdgeColor', 'none');
                            uistack(ar2, 'bottom'); 
                        end
                    end
                    hold off; 
              
                 end

                 saveas(gcf, path_figure, 'emf'); 
                 close all; 
        end
    end
end
