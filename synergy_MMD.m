%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
For each measurement day, calculate the Maximum Mean Discrepancy (MMD) between spatial bases of muscle synergies,
and plot the temporal changes from preoperatively to Day7.
When calculating MMD, fix the number of muscle synergies to three(Line:62).

Inside Function: sort_synergy.m
Input file: trial_timing, synergy_spatial, synergy_temporal, synergy_sqdev
Output file: mmd_figure
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
post_name = ["pre1" "post1" "post2" "post3" "post4" "post5" "post6" "post7" "post8" "healthyside" "healthysub1" "healthysub2"];
post_date = ["0" "7" "14" "22" "82" "187" "327"]; 
task_name = ["task01" "task02" "task03" "task04" "task05"];
Task_name = ["LargeCube" "MiddleCube" "SmallCube" "Janken" "JankenLie"]; 
trial_name = ["trial1" "trial2" "trial3" "trial4" "trial5" "trial6" "trial7" "trial8" "trial9" "trial10" "trial11" "trial12" "trial13" "trial14" "trial15" "trial16"]; 
sy_name = ["sy1" "sy2" "sy3" "sy4" "sy5"]; 
fig = 'syw'; %'syw' or 'syh'

for i = [1 4] %task index
    sigma_w = NaN(13, 3);
    sigma_h = NaN(13, 3); 
    t_vari = cell(13, 3); 
    mmd_transition = NaN(13, 3); 
    path_save = append('mmd_figure/mmd_', task_name(i)); 
    for j = [1:4 6:10] %post index
        path_timing = append('trial_timing/timing_', post_name(j), '_', task_name(i));
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
            x = categorical({'IOD1', '2L', '3L', '4L', 'APB', 'EDC', 'ECR', 'BRD', 'FCU', 'FCR', 'FDS', 'Biceps', 'Triceps', 'DLA'}); 
            x = reordercats(x, {'IOD1', '2L', '3L', '4L', 'APB', 'EDC', 'ECR', 'BRD', 'FCU', 'FCR', 'FDS', 'Biceps', 'Triceps', 'DLA'});
        elseif post_name(j) == "healthysub2"
            n_muscle = 15; 
            x = categorical({'IOD1', '2L', '3L', '4L', 'APB', 'EDC', 'ECR', 'BRD', 'FCU', 'FCR', 'FDS', 'Biceps', 'Triceps', 'DLA', 'DLM'}); 
            x = reordercats(x, {'IOD1', '2L', '3L', '4L', 'APB', 'EDC', 'ECR', 'BRD', 'FCU', 'FCR', 'FDS', 'Biceps', 'Triceps', 'DLA', 'DLM'});
        elseif  post_name(j) == "post7"
            n_muscle = 15; 
            x = categorical({'IOD1', '2L', '3L', '4L', 'ADQ', 'EDC', 'ECR', 'BRD', 'FCU', 'FCR', 'FDS', 'Biceps', 'Triceps', 'DLA', 'DLM'}); 
            x = reordercats(x, {'IOD1', '2L', '3L', '4L', 'ADQ', 'EDC', 'ECR', 'BRD', 'FCU', 'FCR', 'FDS', 'Biceps', 'Triceps', 'DLA', 'DLM'});
        else
            n_muscle = 16; 
            x = categorical({'IOD1', '3L', '4L', 'APB', 'EDC', 'ECR', 'BRD', 'FCU', 'FCR', 'FDS', 'Biceps', 'Triceps', 'DLA', 'DLM'}); 
            x = reordercats(x, {'IOD1', '3L', '4L', 'APB', 'EDC', 'ECR', 'BRD', 'FCU', 'FCR', 'FDS', 'Biceps', 'Triceps', 'DLA', 'DLM'});
            
        end

        % The Number of Synergies
        sy_n = 3; 
         
        vaf = mean(synergy_num(:, 2)); 
        
        wdata_sum = zeros(n_muscle, sy_n); 
        hdata_sum = zeros(sy_n, 100); 

        [syw_each,syh_each] = sort_synergy(synergy_w, synergy_h, sy_n, n_muscle, on, task_name(i), post_name(j)); 

  
                
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
         
         p_mat = NaN(3); 
         mmd_mat = NaN(3); 
         for k = 1:sy_n
             for l = 1:sy_n
                 sigma = median_heuristic_sigma(t_vari{j, k}', t_vari{j, l}');
                 p_value = mmd_permutation_test(t_vari{j, k}', t_vari{j, l}', sigma, 1000);
                 mmd_value = compute_mmd(t_vari{j, k}', t_vari{j, l}', sigma); 
                 p_mat(k, l) = p_value; 
                 mmd_mat(k, l) = mmd_value; 
             end
         end
         %{
         figure; 
         heatmap(p_mat); 
         clim([0 1]); 
         %}
         mmd_transition(j, :) = [mmd_mat(1, 2) mmd_mat(2, 3) mmd_mat(1, 3)]; 
    end
    mmd_transition = rmmissing(mmd_transition); 
    
    figure; 
    f = plot(mmd_transition(2:end, :)); 
    legend('post surgery synergy1 - synergy2', 'post surgery synergy2 - synergy3', 'post surgery synergy3 - synergy1', 'FontSize', 12, 'Location', 'best'); 
    yline(mmd_transition(1, :), '-', {'pre surgery synergy1 - synergy2', 'pre surgery synergy2 - synergy3', 'pre surgery synergy3 - synergy1'}, 'FontSize', 12, 'HandleVisibility', 'off'); 
    xticklabels({'Day1', 'Day2', 'Day3', 'Day4', 'Day5', 'Day6', 'Day7'}); 
    ylabel('MMD value'); 

    saveas(gcf, path_save, 'emf'); 
    close all; 
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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