%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Function to plot muscle synergies.

Use sub-function: sort_sunergy.m
Input file: trial_timing, synergy_spatial, synergy_temporal, synergy_sqdev
Output file：out_synergy_figure
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
post_name = ["pre1" "post1" "post2" "post3" "post4" "post5" "post6" "post7" "post8" "right710"]; 
trial_name = ["trial1" "trial2" "trial3" "trial4" "trial5" "trial6" "trial7" "trial8" "trial9" "trial10" "trial11" "trial12" "trial13" "trial14" "trial15" "trial16"];
day_name = ["pre surgery" "Day1" "Day2" "Day3" "" "Day4" "Day5" "Day6" "Day7", "Healthy side"];
actual_day_name = [-5, 7, 14, 22, 82, 187, 327, 537, 670];
task_name = "task04";

% sy_n_option = 1; % Fix synergy number? 1: not fix, 2: fix
sy_n_option = 2; % Fix synergy number? 1: not fix, 2: fix 2, 3: fix 3
% sy_n_option = 3; % Fix synergy number? 1: not fix, 2: fix 2, 3: fix 3

dispSynGraph=1;
post_idx = [1:4 6:10];
actual_day_list = actual_day_name(post_idx(1:(end-1)));

if(sy_n_option>1)
    tSy_SD_list = zeros(length(post_idx),sy_n_option);
end

sy_n_before = [];
sigma_w = NaN(9, 3);
sigma_h = NaN(9, 3);
t_vari = cell(length(post_idx), 3);
p_mat = zeros(3);
if(sy_n_option>1)
    tempSynPreMean     = zeros(100,sy_n_option);
    tempSynPostMean    = zeros(100,sy_n_option);
    tempSynHealthyMean = zeros(100,sy_n_option);
end
for dayIndx = 1:length(post_idx) % pre1,post1-8,healtyside
    j = post_idx(dayIndx);
    path_timing = append('trial_timing/timing_', post_name(j), '_', task_name);
    path_figure_detail = append('synergy_figure_detail/', post_name(j), '_', task_name);
    path_figure = append('out_synergy_figure/', post_name(j), '_', task_name);
    path_synergy_w = append('synergy_spatial/synergy_', post_name(j), '_', task_name);
    path_synergy_h = append('synergy_temporal/synergy_', post_name(j), '_', task_name);
    path_synergy_r2 = append('synergy_sqdev/synergy_', post_name(j), '_', task_name);
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
    elseif post_name(j) == "post7"
        n_muscle = 15;
        x = categorical({'IOD1', '2L', '3L', '4L', 'ADQ', 'EDC', 'ECR', 'BRD', 'FCU', 'FCR', 'FDS', 'Biceps', 'Triceps', 'DLA', 'DLM'});
        x = reordercats(x, {'IOD1', '2L', '3L', '4L', 'ADQ', 'EDC', 'ECR', 'BRD', 'FCU', 'FCR', 'FDS', 'Biceps', 'Triceps', 'DLA', 'DLM'});
    else
        n_muscle = 16;
        x = categorical({'IOD1', '2L', '3L', '4L', 'APB', 'ADQ', 'EDC', 'ECR', 'BRD', 'FCU', 'FCR', 'FDS', 'Biceps', 'Triceps', 'DLA', 'DLM'});
        x = reordercats(x, {'IOD1', '2L', '3L', '4L', 'APB', 'ADQ', 'EDC', 'ECR', 'BRD', 'FCU', 'FCR', 'FDS', 'Biceps', 'Triceps', 'DLA', 'DLM'});
    end

    if(dispSynGraph)
        figure;
    end

    %% Determine the numer of synergies %%
    % 1:determine with threshold
    % 2:fix the number of synergies with 2
    % 3:fix the number of synergies with 3
    switch sy_n_option
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
        case 2 % fix synergy num=2
            sy_n = 2;
        case 3 % fix synergy num=2
            sy_n = 3;
    end

    vaf = mean(synergy_num(:, 2));

    [syw_each, syh_each] = sort_synergy(synergy_w, synergy_h, sy_n, n_muscle, on, task_name, post_name(j));

    % Draw Figures %
    ttl = append(day_name(j));
    sgtitle(ttl, 'FontSize', 18);
    for k = 1:sy_n
        bar_y   = double.empty;
        graph_y = double.empty;
        for m = 1:count
            y = syw_each{m, 1};
            bar_y = cat(2, bar_y, y(:, k));
            y = syh_each{m, 1};
            graph_y = cat(2, graph_y, y(k, :)');
        end

        avg_bar = mean(bar_y, 2);
        sigma_w(j, k) =  std(avg_bar);

        % Plot saptial synergy
        stde_bar = std(bar_y, 0, 2);
        if(dispSynGraph)
            subplot(sy_n, 2, 2*k-1);
            % avg_bar
            b = bar(x, avg_bar, "FaceColor", [0.2 0.2 1]);
            % avg_bar
            b.FaceColor = "flat";
            if post_name(j) == "post7" % APB emg data was discarded
                b.CData(6, :) = [1 0.2 0.2];
                b.CData(10, :) = [1 0.2 0.2];
            else
                b.CData(7, :) = [1 0.2 0.2];
                b.CData(11, :) = [1 0.2 0.2];
            end
            hold on;
            er = errorbar(x, avg_bar,stde_bar,stde_bar);
            er.Color = [0 0 0];
            er.LineStyle = 'none';
            h_axis = gca;
            h_axis.YAxis.FontSize = 12;
            hold off;
        end
        avg_graph  = mean(graph_y, 2);
        stde_graph = std(graph_y, 0, 2);
        if(sy_n_option>1) % synergy num: fix
            tSy_SD_list(dayIndx,k) = mean(stde_graph);
        end

        vec_dist = zeros(count, 1);
        for nn = 1:count
            r = corrcoef(avg_graph, graph_y(:, nn));
            vec_dist(nn) = r(1, 2)/(norm(avg_graph)*norm(graph_y(:, nn)));
        end
        sigma_h(j, k) = std(vec_dist);
        t_vari{dayIndx, k} = graph_y;

        % Plot temporal synergy
        if(dispSynGraph)
            subplot(sy_n, 2, 2*k);
            plot(avg_graph, 'Color', [0.2 0.2 1], 'LineWidth', 2);
            hold on;
            ar1=area(1:100,[avg_graph-stde_graph stde_graph+stde_graph]);
            set(ar1(1),'FaceColor','None','LineStyle',':','EdgeColor',[0.2 0.2 1]);
            set(ar1(2),'FaceColor', [0.2 0.2 1], 'FaceAlpha',0.2,'LineStyle',':','EdgeColor',[0.2 0.2 1]);
            h_axis = gca;
            h_axis.XAxis.FontSize = 12;
            h_axis.YAxis.FontSize = 12;
            if k == 1
                ylim([0 0.4]);
            else
                ylim([0 0.3]);
            end
            if size(on, 2)>2
                posture_avg = mean(on(:, 3:5), 1);
                posture_std = std(on(:, 3:5), 0, 1);
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
            saveas(gcf, path_figure, 'emf');
        end
    end
end
if(sy_n_option>1) % synergy num: fix
    for k= 1:sy_n_option
        tempSynPreMean(:,k)     = mean(t_vari{1, k}, 2);
        tempSynPostMean(:,k)    = mean(t_vari{8, k}, 2);
        tempSynHealthyMean(:,k) = mean(t_vari{9, k}, 2);
    end
    rDayPostListMean   = zeros(length(post_idx)-1, sy_n_option);
    rDayPostListSD     = zeros(length(post_idx)-1, sy_n_option);
    pList = zeros(length(post_idx)-1, sy_n_option);
    for dayIndx = 1:length(post_idx)-1 % pre1,post1-8
        for k= 1:sy_n_option
            tempSyn = t_vari{dayIndx, k};
            rPostList = zeros(1,size(tempSyn,2));
            for tryIndx = 1:size(tempSyn,2)
                R = corrcoef(tempSynPostMean(:,k), tempSyn(:,tryIndx));
                rPostList(tryIndx) = R(1,2);
            end
            rDayPostListMean(dayIndx, k) = mean(rPostList);
            rDayPostListSD(dayIndx, k)   = std(rPostList);
            %
            % Permutation test
            nPerm = 10000;
            result = permTestTimeSeriesGlobal(tempSyn, t_vari{8, k}, nPerm);
            pList(dayIndx,k) = result.p;
        end
    end
    for k= 1:sy_n_option
        for dayIndx = 1:length(post_idx)-1 % pre1,post1-8
            disp(['Synergy ' num2str(k) ', dayIndx ' num2str(dayIndx), 'P-Value (after Bonferroni Correction): ' num2str(pList(dayIndx,k)*(length(post_idx)-1), '%.3f')]);
        end
    end

    figure;
    for k= 1:sy_n_option
        subplot(sy_n_option,1,k)
        errorbar(actual_day_list, rDayPostListMean(:,k), rDayPostListSD(:,k),'LineWidth', 2.0);
        xline(19);
        xline(212);
        xline(356);
        xline(691);
        xlim([-10 700]);
        xticks(sort(actual_day_list))
        ylim([0,1]);
        ylabel(['Synergy ' num2str(k)]);
        set(gca, 'FontName','Arial', 'FontWeight','bold', 'FontSize',12, 'LineWidth',1.5, 'XColor','k', 'YColor','k')
    end
    path_tempSynergy_Corr = append('out_synergy_figure/', task_name, '_tempSynCOrr_', num2str(sy_n_option));
    saveas(gcf, path_tempSynergy_Corr, 'emf');
end

%%
function result = permTestTimeSeriesGlobal(A, B, nPerm)
% A, B: nTime x nTrial
% nPerm: number of permutation
%
% result.p      : p-value
% result.Tobs   : observed statistic
% result.Tperm  : permutation statistics
% result.meanA  : mean waveform of A
% result.meanB  : mean waveform of B
% result.diffObs: difference between mean waveforms

if nargin < 3
    nPerm = 10000;
end

[nTimeA, nA] = size(A);
[nTimeB, nB] = size(B);

if nTimeA ~= nTimeB
    error('A and B must have the same number of time points.');
end
meanA = mean(A, 2, 'omitnan');
meanB = mean(B, 2, 'omitnan');
diffObs = meanA - meanB;

Tobs = mean(diffObs.^2, 'omitnan');

X = [A B];
nTotal = nA + nB;
Tperm = zeros(nPerm, 1);

for i = 1:nPerm
    idx = randperm(nTotal);
    idxA = idx(1:nA);
    idxB = idx(nA+1:end);
    Aperm = X(:, idxA);
    Bperm = X(:, idxB);
    diffPerm = mean(Aperm, 2, 'omitnan') - mean(Bperm, 2, 'omitnan');
    Tperm(i) = mean(diffPerm.^2, 'omitnan');
end

p = (sum(Tperm >= Tobs) + 1) / (nPerm + 1);

result.p = p;
result.Tobs = Tobs;
result.Tperm = Tperm;
result.meanA = meanA;
result.meanB = meanB;
result.diffObs = diffObs;
end
