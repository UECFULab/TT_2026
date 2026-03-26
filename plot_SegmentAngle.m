%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Plot the joint angles[degrees] of the MP, PIP, and wrist joints.
Specify whether to plot data for all trials or plot the mean value in 'option'(line:14, 'mean', 'detail').

Input file: processed_marker
Output file: seg_figure
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
post_name = ["pre1" "post1" "post2" "post3" "post4" "post5" "post6" "post7" "post8" "healthyside" "healthysub1" "healthysub2"];
task_name = ["task01" "task02" "task03" "task04" "task05"]; 
Task_name = ["Cube task" "Small Cube" "Middle Cube" "Janken task"]; 
seg_name = ["mph", "pip", "wrist"]; 
option = 'mean'; 

Fs = 100;                                
T = 1/Fs;                  
L = 99;             
t = (0:L-1)*T; 

switch option
    case 'detail' 
        %% Plot the segment angle for all trials
        for k = 1:2 %Segment index (1:mph3, 2:pip3, 3:wrist)
            for i = [1 4] %task index
                figure;
                for j = [1:4 6:10] %post index
                    path_name = append('processed_marker/marker_',  post_name(j),  '_',  task_name(i));
                    load(path_name, '-mat'); 
                    val = (j-1)/6; 
                    if post_name(j) == "pre1"
                        clr = [0 0 0]; 
                    elseif post_name(j) == "healthyside"
                        clr = "k"; 
                    elseif post_name(j) == "healthysub1"
                        clr = [0 1 0]; 
                    elseif post_name(j) == "healthysub2"
                        clr = [1 0 1]; 
                    elseif post_name(j) == "post1"
                        clr = [0.2 0.2 0.8]; 
                    elseif post_name(j) == "post2"
                        clr = [0.2 0.2 0.6]; 
                    elseif post_name(j) == "post3"
                        clr = [0.2 0.2 0.4]; 
                    elseif post_name(j) == "post4"
                        clr = [1 2/3 2/3]; 
                    elseif post_name(j) == "post5"
                        clr = [0.4 0.2 0.2];  
                    elseif post_name(j) == "post6"
                        clr = [0.6 0.2 0.4];
                    elseif post_name(j) == "post7"
                        clr = [0.8 0.2 0.6]; 
                    end
                    hold on; 
                    switch k
                        case 1 %Plot MPH angle
                            plot(plotmr, 'Color', clr);
                            lgd = legend(post_name(j)); 
                            set(lgd, 'visible', 'off'); 
                            ylim([60 200]); 
                        case 2 %Plot PIP angle
                            [rec_plotpr, w_obs, M_obs, H_obs] = motion_RBF(plotpr); 
                            [row, col] = find(isnan(plotpr)); 
                            plotpr(row, col) = rec_plotpr(row, col); 
                            pr_avg = mean(plotpr, 2); 
                            pr_std = std(plotpr, 0, 2); 
                            plot(plotpr(:, 1), "Color", clr, "DisplayName", post_name(j)); 
                            plot(plotpr, 'Color', clr);
                            ylim([60 200]);
                        case 3 %Plot Wrist angle
                            if exist('plotwr')==1 %When wrist angle data is available
                                disp(post_name(j)); 
                                if post_name(j) == "post4"
                                    plotwr = plotwr(:, 1:9); 
                                end
                                plot(plotwr(:, 1), 'Color', clr, "DisplayName", post_name(j)); 
                                plot(plotwr, 'Color', clr);
                                ylim([0 90]);
                                clear plotwr
                            end
                    end
                    clear plotmr
                    clear plotpr
                    clear plotwr
                end
            end
            hold off;   
        end
    case 'mean' 
        %% Plot the average segment angle
        for i = [1 4] %task index
            clear mr pr mr_hrz pr_hrz; 
            save_tam = append('seg_figure/TAM_', task_name(i)); 
            for k = 1:2 %Segment index (1:mph3, 2:pip3, 3:wrist)
                figure; 
                path_model = append('processed_marker/marker_post7_', task_name(i)); 
                path_save = append('seg_figure/', seg_name(k), '_', task_name(i)); 
                load(path_model); 
                mr_model = mean(plotmr, 2); 
                pr_model = mean(plotpr, 2); 

                for j = [2:4 6:10] %post index
                    path_name = append('processed_marker/marker_',  post_name(j),  '_',  task_name(i)); 
                    load(path_name); 
                    if post_name(j) == "pre1"
                        clr = [0 0 0]; 
                    elseif post_name(j) == "healthyside"
                        clr = "k"; 
                    elseif post_name(j) == "healtysub1"
                        clr = [0 1 0]; 
                    elseif post_name(j) == "healthysub2"
                        clr = [1 0 1]; 
                    elseif post_name(j) == "post1"
                        clr = [0.5 0.2 1]; 
                    elseif post_name(j) == "post2"
                        clr = [0.2 0.2 1]; 
                    elseif post_name(j) == "post3"
                        clr = [0.2 0.5 0.2]; 
                    elseif post_name(j) == "post4"
                        clr = [1 2/3 2/3]; 
                    elseif post_name(j) == "post5"
                        clr = [0.2 1 0.2];  
                    elseif post_name(j) == "post6"
                        clr = [1 1 0.2];
                    elseif post_name(j) == "post7"
                        clr = [1 0.6 0.2]; 
                    elseif post_name(j) == "post8"
                        clr = [1 0.2 0.2]; 
                    end
                    hold on; 
                    switch k
                        case 1 %Plot MPH angle

                            [rec_plotmr, w_obs, M_obs, H_obs] = motion_RBF(plotmr); 
                            [row, col] = find(isnan(plotmr)); 
                            plotmr(row, col) = rec_plotmr(row, col); 
                            mr_hrz{j, 1} = max(plotmr) - min(plotmr); 
                            mr_avg = mean(plotmr, 2); 
                            mr_std = std(plotmr, 0, 2); 
                            mp(:, j) = mr_avg; 
                            plot(mr_avg, 'Color', clr, 'LineWidth', 2); 
                            ylim([60 200]); 
                            ylabel('MP degree', 'FontSize', 12); 
                            xlabel('task achievement [%]', 'FontSize', 12); 
                            ttl = append(Task_name(i), ' MP'); 
                            title(ttl, 'FontSize', 12); 
                            r = corrcoef(mr_avg(40:100), mr_model(40:100)); 

                        case 2 %Plot PIP angle

                            [rec_plotpr, w_obs, M_obs, H_obs] = motion_RBF(plotpr); 
                            [row, col] = find(isnan(plotpr)); 
                            plotpr(row, col) = rec_plotpr(row, col); 
                            pr_hrz{j, :} = max(plotpr) - min(plotpr); 
                            pr_avg = mean(plotpr, 2); 
                            pr_std = std(plotpr, 0, 2); 
                            pip(:, j) = pr_avg; 
                            plot(pr_avg, 'Color', clr, 'LineWidth', 2); 
                            ylim([60 200]);
                            ylabel('PIP degree', 'FontSize', 12); 
                            xlabel('task achievement [%]', 'FontSize', 12);
                            ttl = append(Task_name(i), ' PIP'); 
                            title(ttl, 'FontSize', 12); 
                            
                        case 3 %Plot Wrist angle
                            
                            if exist('plotwr')==1 
                                disp(post_name(j)); 
                                if post_name(j) == "post4"
                                    plotwr = 180 - plotwr; 
                                end                               
                                wr_avg = mean(plotwr, 2); 
                                wr_std = std(plotwr, 0, 2);
                                plot(wr_avg, 'Color', clr,'LineWidth', 2); 
                                ylim([0 70]);
                            end         
                    end
                    clear plotpr
                    clear plotmr
                    clear plotwr
                    if post_name(j) == "healthyside"
                        for nn = size(mr_hrz, 1)
                            if k == 1
                                mr_hrz{nn, 1} = mr_hrz{nn, 1}./mean(mr_hrz{j, 1}); 
                            elseif k == 2
                                pr_hrz{nn, 1} = pr_hrz{nn, 1}./mean(pr_hrz{j, 1}); 
                            end
                        end
                    end
                end
                hold off; 
                if i == 4 || i == 1
                    if k == 3
                        legend('', 'post2', 'post4', 'post5', 'post6', 'post7', 'HealthySide', 'Location', 'best'); 
                        xlabel('task achievement [%]', 'FontSize', 12); 
                        ylabel('Wrist degree', 'FontSize', 12); 
                    elseif k == 1
                        lgd = legend('Day1', 'Day2', 'Day3', 'Day4', 'Day5', 'Day6', 'Day7', 'HealthySide', 'Location', 'best');
                        xlabel('task achievement [%]', 'FontSize', 12); 
                        ylabel('MP degree', 'FontSize', 12); 
                    elseif k == 2
                        legend('Day1', 'Day2', 'Day3', 'Day4', 'Day5', 'Day6', 'Day7', 'HealthySide', 'Location', 'best');
                        xlabel('task achievement [%]', 'FontSize', 12); 
                        ylabel('PIP degree', 'FontSize', 12); 
                    end
                end
                
                saveas(gcf, path_save, 'emf'); 
                close all; 

            end

            for nn = 1:size(mr_hrz, 1)
                mr(nn, 1) = mean(mr_hrz{nn, 1}); 
                mr(nn, 2) = std(mr_hrz{nn, 1}); 
                pr(nn, 1) = mean(pr_hrz{nn, 1}); 
                pr(nn, 2) = std(pr_hrz{nn, 1}); 
            end

            figure; errorbar(1:8, mr([1:4 6:9], 1), mr([1:4 6:9], 2), '-+'); hold on; errorbar(1:8, pr([1:4 6:9], 1), pr([1:4 6:9], 2), '-+'); 
            legend('MP %TAM', 'PIP %TAM', 'Location', 'best'); 
            xticklabels({'pre surgery', 'Day1', 'Day2', 'Day3', 'Day4', 'Day5', 'Day6', 'Day7'}); 
            ylabel('%TAM', 'FontSize', 12); 
            ylim([0 100]); 
            if i == 4
                title('Janken %TAM', 'FontSize', 12); 
            elseif i == 1
                title('Cube %TAM', 'FontSize', 12); 
            end

            saveas(gcf, save_tam, 'emf'); 

        end
end