%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Function to calculate maximum mean deviation (MMD)
For each measurement date, calculate the MMD between spatial reference points for muscle synergies and plot the changes over time from preoperative to day VII.

Use sub-function: sort_synergy.m
Input file: trial_timing, synergy_spatial, synergy_temporal, synergy_sqdev
Output file: out_mmd_figure
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
post_name = ["pre1" "post1" "post2" "post3" "post4" "post5" "post6" "post7" "post8" "right710"]; 
task_name = "task04";
actual_day_name = [-5, 7, 14, 22, 82, 187, 327, 537, 670];
fig = 'syw'; %'syw' or 'syh'

sy_n_list = [2,3];
mmd_transition_list = {};
for sy_n_indx = 1:length(sy_n_list)
    sy_n = sy_n_list(sy_n_indx);
    %
    sigma_w = NaN(13, sy_n);
    sigma_h = NaN(13, sy_n);
    t_vari = cell(13, sy_n);
    mmd_transition = NaN(13, sy_n);
    path_save = append('out_mmd_figure/mmd_', task_name);
    dayIndxList = [1:4 6:9];
    actual_day_list = actual_day_name(dayIndxList);
    for j = dayIndxList %post index
        path_timing = append('trial_timing/timing_', post_name(j), '_', task_name);
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
            x = categorical({'IOD1', '2L', '3L', '4L', 'APB', 'EDC', 'ECR', 'BRD', 'FCU', 'FCR', 'FDS', 'Biceps', 'Triceps', 'DLA'});
            x = reordercats(x, {'IOD1', '2L', '3L', '4L', 'APB', 'EDC', 'ECR', 'BRD', 'FCU', 'FCR', 'FDS', 'Biceps', 'Triceps', 'DLA'});
        elseif  post_name(j) == "post7"
            n_muscle = 15;
            x = categorical({'IOD1', '2L', '3L', '4L', 'ADQ', 'EDC', 'ECR', 'BRD', 'FCU', 'FCR', 'FDS', 'Biceps', 'Triceps', 'DLA', 'DLM'});
            x = reordercats(x, {'IOD1', '2L', '3L', '4L', 'ADQ', 'EDC', 'ECR', 'BRD', 'FCU', 'FCR', 'FDS', 'Biceps', 'Triceps', 'DLA', 'DLM'});
        else
            n_muscle = 16;
            x = categorical({'IOD1', '3L', '4L', 'APB', 'EDC', 'ECR', 'BRD', 'FCU', 'FCR', 'FDS', 'Biceps', 'Triceps', 'DLA', 'DLM'});
            x = reordercats(x, {'IOD1', '3L', '4L', 'APB', 'EDC', 'ECR', 'BRD', 'FCU', 'FCR', 'FDS', 'Biceps', 'Triceps', 'DLA', 'DLM'});
        end
        vaf = mean(synergy_num(:, 2));
        wdata_sum = zeros(n_muscle, sy_n);
        hdata_sum = zeros(sy_n, 100);

        [syw_each,syh_each] = sort_synergy(synergy_w, synergy_h, sy_n, n_muscle, on, task_name, post_name(j));

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
            stde_bar = std(bar_y, 0, 2);
            %
            avg_graph = mean(graph_y, 2);
            stde_graph = std(graph_y, 0, 2);
            vec_dist = zeros(count, 1);
            for nn = 1:count
                r = corrcoef(avg_graph, graph_y(:, nn));
                vec_dist(nn) = r(1, 2)/(norm(avg_graph)*norm(graph_y(:, nn)));
            end
            sigma_h(j, k) = std(vec_dist);
            switch fig
                case 'syw'
                    t_vari{j, k} = bar_y;
                case 'syh'
                    t_vari{j, k} = graph_y;
            end
            avg_bar_fix = zeros(fix(max(avg_bar)*100)+1, 1);
            for mm = 1:n_muscle
                idx = fix(avg_bar(mm)*100) + 1;
                avg_bar_fix(idx) = avg_bar_fix(idx) + 1/n_muscle;
            end
            y = movmean(avg_bar_fix, [5, 5]);
        end

        p_mat = NaN(sy_n);
        mmd_mat = NaN(sy_n);
        for k = 1:sy_n
            for l = 1:sy_n
                sigma = median_heuristic_sigma(t_vari{j, k}', t_vari{j, l}');
                p_value = mmd_permutation_test(t_vari{j, k}', t_vari{j, l}', sigma, 1000);
                mmd_value = compute_mmd(t_vari{j, k}', t_vari{j, l}', sigma);
                p_mat(k, l) = p_value;
                mmd_mat(k, l) = mmd_value;
            end
        end
        if sy_n==3
            mmd_transition(j, :) = [mmd_mat(1, 2) mmd_mat(2, 3) mmd_mat(1, 3)];
        else % sy_n==2
            mmd_transition(j, :) = [mmd_mat(1, 2) mmd_mat(2, 1)];
        end
    end
    % mmd_transition
    mmd_transition = rmmissing(mmd_transition);
    mmd_transition_list{sy_n_indx} = mmd_transition;
end

figure;
subplot(2,1,1)
f1 = plot(actual_day_list(2:end), mmd_transition_list{1}(2:end, :),'LineWidth', 2.0); % synergy num: 2
yline(mmd_transition_list{1}(1, :), '-', {'Pre Surgery'}, 'FontSize', 24, 'HandleVisibility', 'off');
xline(19);
xline(212);
xline(356);
xline(691);
legend('Synergy 1-2', 'FontSize', 24, 'Location', 'best');
ylabel('MMD value');
xlim([-10 700]);
xticks(sort(actual_day_list(2:end)));
xticklabels([]);
ylim([1.2 1.4]);
yticks(1.2:0.1:1.4);
set(gca, 'FontName','Arial', 'FontWeight','bold', 'FontSize',24, 'LineWidth',1.5, 'TickDir','out', 'XColor','k', 'YColor','k')
%
subplot(2,1,2)
f2 = plot(actual_day_list(2:end), mmd_transition_list{2}(2:end, :),'LineWidth', 2.0); % synergy num: 3
xline(19);
xline(212);
xline(356);
xline(691);
legend('Synergy 1-2', 'Synergy 2-3', 'Synergy 3-1', 'FontSize', 24, 'Location', 'best');
yline(mmd_transition_list{2}(1, :), '-', {'Pre Surgery Synergy 1-2', 'Pre Surgery Synergy 2-3', 'Pre Surgery Synergy 3-1'}, 'FontSize', 24, 'HandleVisibility', 'off');
xticks(sort(actual_day_list(2:end)))
ylabel('MMD value');
xlim([-10 700]);
set(gca, 'FontName','Arial', 'FontWeight','bold', 'FontSize',24, 'LineWidth',1.5, 'TickDir','out', 'XColor','k', 'YColor','k')
saveas(gcf, path_save, 'emf');


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mmd_value = compute_mmd(X, Y, sigma)
rbf = @(A,B) exp(-pdist2(A,B,'euclidean').^2 / (2*sigma^2));

Kxx = rbf(X, X);
Kyy = rbf(Y, Y);
Kxy = rbf(X, Y);

n = size(X,1);
m = size(Y,1);

mmd_value = (sum(Kxx(:)) - sum(diag(Kxx))) / (n*(n-1)) + ...
    (sum(Kyy(:)) - sum(diag(Kyy))) / (m*(m-1)) - ...
    2 * mean(Kxy(:));
end

%%
function p_value = mmd_permutation_test(X, Y, sigma, num_permutations)
n = size(X,1);
m = size(Y,1);

% Original MMD value
observed_mmd = compute_mmd(X, Y, sigma);
% Combine all data
all_data = [X; Y];
N = n + m;

permuted_mmds = zeros(num_permutations, 1);

for i = 1:num_permutations
    % Randomly shuffle the index
    idx = randperm(N);
    X_perm = all_data(idx(1:n), :);
    Y_perm = all_data(idx(n+1:end), :);

    % MMD calculation with permuted data
    permuted_mmds(i) = compute_mmd(X_perm, Y_perm, sigma);
end

p_value = mean(permuted_mmds >= observed_mmd);
end

%%
function sigma = median_heuristic_sigma(X, Y)
% Combine all data
data = [X; Y];

% Calculate Euclidean distances for all pairs
D = pdist2(data, data, 'euclidean');

% Upper triangular matrix (excluding duplicates and self-distance)
D = triu(D, 1);
distances = D(D > 0);

% Calculate sigma from the median distance
sigma = sqrt(0.5) * median(distances);
end