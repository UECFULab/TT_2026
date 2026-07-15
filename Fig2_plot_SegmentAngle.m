%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Function to plot joint angles [degrees] for the MP, PIP, and wrist joints

Input file: processed_marker
Output file: out_seg_figure
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
clear all
post_name = ["pre1" "post1" "post2" "post3" "post4" "post5" "post6" "post7" "post8" "right710"];
actual_day_name = [-5, 7, 14, 22, 82, 187, 327, 537, 670];
task_name = "task04";
seg_name = ["mp", "pip"];

dayIndxList = [1:4 6:9];
outDayIndxList = [2,4,9];
post_name_list  = post_name(dayIndxList);
actual_day_list = actual_day_name(dayIndxList);
mp = [];
for k = 1:2 %Segment index (1:mph3, 2:pip3)
    for j = dayIndxList %post index
        load(append('trial_timing/timing_', post_name(j), '_', task_name), "on");
        if(ismember(j, outDayIndxList))
            figure;
        end
        path_name = append('processed_marker/marker_',  post_name(j),  '_',  task_name);
        load(path_name, "plotmr", "plotpr");
        switch k
            case 1 %Plot MPH angle
                [rec_plotmr, ~, ~, ~] = motion_RBF(plotmr);
                [row, col] = find(isnan(plotmr));
                plotmr(row, col) = rec_plotmr(row, col);
                mr_hrz{j, 1} = max(plotmr) - min(plotmr);
                mr_avg = mean(plotmr, 2);
                mr_std = std(plotmr, 0, 2);
                %
                if(ismember(j, outDayIndxList))
                    clr = [0.2 0.2 0.8]; % Color
                    plot(mr_avg, 'Color', clr, 'LineWidth', 2);
                    hold on;
                    plot(mr_avg+mr_std, 'Color', clr, 'LineWidth', 2);
                    plot(mr_avg-mr_std, 'Color', clr, 'LineWidth', 2);
                end
                %
                clear plotmr
                %
                % Healthy Side
                load(append('processed_marker/marker_',  post_name(10),  '_',  task_name), "plotmr");
                [rec_plotmr, ~, ~, ~] = motion_RBF(plotmr);
                [row, col] = find(isnan(plotmr));
                plotmr(row, col) = rec_plotmr(row, col);
                mr_avg = mean(plotmr, 2);
                mr_std = std(plotmr, 0, 2);
                if(ismember(j, outDayIndxList))
                    plot(mr_avg, 'Color', 'k', 'LineWidth', 2);
                    plot(mr_avg+mr_std, 'Color', 'k', 'LineWidth', 2);
                    plot(mr_avg-mr_std, 'Color', 'k', 'LineWidth', 2);
                    %
                    ylabel('MP degree', 'FontSize', 24);
                    xlabel('task achievement [%]', 'FontSize', 24);
                    ttl = append('MP');
                    title(ttl, 'FontSize', 24);
                    hold off;
                end
                clear plotmr
            case 2 %Plot PIP angle
                [rec_plotpr, ~, ~, ~] = motion_RBF(plotpr);
                [row, col] = find(isnan(plotpr));
                plotpr(row, col) = rec_plotpr(row, col);
                pr_hrz{j, :} = max(plotpr) - min(plotpr);
                pr_avg = mean(plotpr, 2);
                pr_std = std(plotpr, 0, 2);
                %
                if(ismember(j, outDayIndxList))
                    hold on;
                    plot(pr_avg, 'Color', clr, 'LineWidth', 2);
                    plot(pr_avg+pr_std, 'Color', clr, 'LineWidth', 2);
                    plot(pr_avg-pr_std, 'Color', clr, 'LineWidth', 2);
                end
                %
                clear plotpr
                %
                % Healthy Side
                load(append('processed_marker/marker_',  post_name(10),  '_',  task_name), "plotpr");
                [rec_plotpr, ~, ~, ~] = motion_RBF(plotpr);
                [row, col] = find(isnan(plotpr));
                plotpr(row, col) = rec_plotpr(row, col);
                pr_avg = mean(plotpr, 2);
                pr_std = std(plotpr, 0, 2);
                if(ismember(j, outDayIndxList))
                    plot(pr_avg, 'Color', 'k', 'LineWidth', 2);
                    plot(pr_avg+pr_std, 'Color', 'k', 'LineWidth', 2);
                    plot(pr_avg-pr_std, 'Color', 'k', 'LineWidth', 2);
                    %
                    ylabel('PIP degree', 'FontSize', 24);
                    xlabel('task achievement [%]', 'FontSize', 24);
                    ttl = append('PIP');
                    title(ttl, 'FontSize', 24);
                    hold off;
                end
                clear plotpr
        end
        posture_timing = on(:, 3:2+3);
        posture_avg = mean(posture_timing, 1);
        posture_std = std(posture_timing, 0, 1);
        if(ismember(j, outDayIndxList))
            xlim([0,100]);
            xticks(0:20:100);
            ylim([60 200]);
            yticks(80:40:200);
            xlabel('task achievement [%]', 'FontSize', 24);
            if k == 1
                ylabel('MP degree', 'FontSize', 24);
            elseif k == 2
                ylabel('PIP degree', 'FontSize', 24);
            end
            %
            hold on;
            for mm = 1:size(posture_avg, 2)
                l1 = xline(posture_avg(mm), 'HandleVisibility', 'off', 'LineWidth', 2);
                uistack(l1, 'bottom');
                timeSDM =posture_avg(mm)-posture_std(mm);
                timeSDP =posture_avg(mm)+posture_std(mm);
                yRange = ylim;
                ar1 = area([timeSDM timeSDP], [yRange(2) yRange(2)], 'FaceColor', [0.9 0.9 0.9]);
                uistack(ar1, 'bottom');
            end
            hold off;
            saveas(gcf, append('out_seg_figure/', seg_name(k), '_', post_name(j)), 'emf');
        end
    end
end
pMPList  = zeros(1,7);
pPIPList = zeros(1,7);
num=1;
for nn = 1:size(mr_hrz, 1)
    mr(nn, 1) = mean(mr_hrz{nn, 1});
    mr(nn, 2) = std(mr_hrz{nn, 1});
    pr(nn, 1) = mean(pr_hrz{nn, 1});
    pr(nn, 2) = std(pr_hrz{nn, 1});
    %
    if(nn~=1 && nn~=5)
        [~,pMP, ~,statsMP]  = ttest2(mr_hrz{1,1}, mr_hrz{nn,1});
        [~,pPIP,~,statsPIP] = ttest2(pr_hrz{1,1}, pr_hrz{nn,1});
        pMPList(num)  = pMP;
        pPIPList(num) = pPIP;
        num=num+1;
    end
end
pMPBonf  = min(pMPList*7, 1);
pPIPBonf = min(pPIPList*7, 1);
for dayIndx=1:length(pMPBonf)
    disp(['nn: ' num2str(dayIndx) ', ' num2str(pMPBonf(dayIndx)) ', ' num2str(pPIPBonf(dayIndx))]);
end
figure;
errorbar(actual_day_list(1:end), mr(dayIndxList(1:end), 1), mr(dayIndxList(1:end), 2), '-+','LineWidth', 2.0); hold on;
errorbar(actual_day_list(1:end), pr(dayIndxList(1:end), 1), pr(dayIndxList(1:end), 2), '-+','LineWidth', 2.0);
xline(19);
xline(212);
xline(356);
xline(691);
ylim([0 100]);
xrange = [-10 700];
xlim(xrange);
%
legend('MP %TAM', 'PIP %TAM', 'Location', 'best');
yticks(0:20:100)
%
xticks(sort(actual_day_list(1:end)))
ylabel('%TAM');
set(gca, 'FontName','Arial', 'FontWeight','bold', 'FontSize',24, 'LineWidth',1.5, 'TickDir','out', 'XColor','k', 'YColor','k')
saveas(gcf, append('out_seg_figure/TAM'), 'emf');

%%
function [rec_plotpr, w_obs, M_obs, H_obs] = motion_RBF(plotpr)
warning('off'); 
r = 1.7; lam = 0.5*10^(-1); 

H = zeros(100); 
H_design = zeros(100); 
L = zeros(100); 
rec_plotpr = zeros(100, size(plotpr, 2)); 
w_obs = cell(size(plotpr, 2), 1); 
M_obs = cell(size(plotpr, 2), 1); 
H_obs = cell(size(plotpr, 2), 1); 

for count = 1:size(plotpr, 2)
    for mm = 1:100
        L(mm, mm) = lam; 
        for pp = 1:100
            H(pp, mm) = 1/(1+exp(-(pp+r-mm))) + 1/(1+exp(pp-r-mm)) - 1; 
        end
    end
    [row, ~] = find(isnan(plotpr(:, count))); 
    plotpr(fix(1/6*min(row)+5/6*max(row)), count) = plotpr(min(row)-1, count);     
    plotpr(fix(2/6*min(row)+4/6*max(row)), count) = plotpr(min(row)-1, count);  
    plotpr(fix(3/6*min(row)+3/6*max(row)), count) = plotpr(min(row)-1, count); 
    plotpr(fix(4/6*min(row)+2/6*max(row)), count) = plotpr(min(row)-1, count); 
    plotpr(fix(5/6*min(row)+1/6*max(row)), count) = plotpr(min(row)-1, count); 
    [row, ~] = find(isnan(plotpr(:, count))); 
    H(row, :) = []; 

    M = pinv(H'*H + L)*H'; 

    w = M*rmmissing(plotpr(:, count)); 
    w_obs{count, 1} = w;
    M_obs{count, 1} = M;
    H_obs{count, 1} = H; 

    for mm = 1:100
        for pp = 1:100
            H_design(pp, mm) = 1/(1+exp(-(pp+r-mm))) + 1/(1+exp(pp-r-mm)) - 1; 
        end
    end

    rec_plotpr(:, count) = H_design*w; 

end
end

