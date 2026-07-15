%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Function to verify the correlation of synergy between measurement dates
The output heatmap contains synergy information from the previous measurement in the rows and from the current measurement in the columns

CorrW: Verified using the spatial correlation coefficient between measurement dates
Corrh: Verified using the temporal correlation coefficient between measurement dates
ReconW: Verifies the spatial correlation between measurement dates using the non-negative least squares method
ReconH: Verifies the temporal correlation between measurement dates using the non-negative least squares method

Use sub-function: sort_synergy.m
Input file: trial_timing, synergy_spatial, synergy_temporal, synergy_sqdev
Output file: out_map
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
post_name = ["pre1" "post1" "post2" "post3" "post4" "post5" "post6" "post7" "post8" "right710"];
task_name = "task04";
trial_name = ["trial1" "trial2" "trial3" "trial4" "trial5" "trial6" "trial7" "trial8" "trial9" "trial10" "trial11" "trial12" "trial13" "trial14" "trial15" "trial16"];
label_sy = ["synergy1" "synergy2" "synergy3" "synergy4" "synergy5"];
type = 'ReconW';  %'CorrW', 'Corrh', 'ReconW' or 'ReconH'
% type = 'ReconH';  %'CorrW', 'Corrh', 'ReconW' or 'ReconH'
syn_fix = 1; %0:fix the number of synergies

syw_post = struct("pre1", []);
syh_post = struct("pre1", []);
corw_transition = NaN(11, 3);
corh_transition = NaN(11, 3);
order = 1;
clear corh corw rech recw r2h r2w;
for j = [2:4 6:9]%post
    path_timing = append('trial_timing/timing_', post_name(j), '_', task_name);
    path_synergy_w = append('synergy_spatial/synergy_', post_name(j), '_', task_name);
    path_synergy_h = append('synergy_temporal/synergy_', post_name(j), '_', task_name);
    path_synergy_r2 = append('synergy_sqdev/synergy_', post_name(j), '_', task_name);
    path_save = append('out_map/heatmap_', post_name(j), '_', task_name);
    load(path_timing);
    load(path_synergy_w);
    load(path_synergy_h);
    load(path_synergy_r2);
    threshold_VAF = 0.8;

    if post_name(j)=="pre1"
        n_muscle = 14;
    elseif post_name(j)=="healthysub2" || post_name(j)=="post7"
        n_muscle = 15;
    else
        n_muscle = 16;
    end
    count = size(on, 1);
    trial = on(:, 2) - on(:, 1) + 1;

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

    if syn_fix == 0
        sy_n = 3;
    end

    [syw_each,syh_each] = sort_synergy(synergy_w, synergy_h, sy_n, n_muscle, on, task_name, post_name(j));
    if order == 1
        syw1 = syw_each;
        syh1 = syh_each;
        count1 = count;
        syn1 = sy_n;
        order = 0;
        muscle1 = n_muscle;
    elseif order == 0
        syw2 = syw_each;
        syh2 = syh_each;
        count2 = count;
        syn2 = sy_n;
        idx = 1;
        for ii = 1:count1
            for jj = 1:count2
                for kk = 1:syn1
                    for ll = 1:syn2
                        corh{j, 1}{kk, ll}(idx, 1) = max(xcorr(syh1{ii, 1}(kk, :), syh2{jj, 1}(ll, :), 5));
                        rech{j, 1}{ll, 1}(idx, :) = lsqnonneg(syh1{ii, 1}', syh2{jj, 1}(ll, :)');
                        if post_name(j) == "post1"
                            r = corrcoef(syw1{ii, 1}(:, kk), syw2{jj, 1}(1:14, ll));
                            corw{j, 1}{kk, ll}(idx, 1) = r(1, 2);
                            recw{j, 1}{ll, 1}(idx, :) = lsqnonneg(syw1{ii, 1}, syw2{jj, 1}(1:14, ll));
                        elseif post_name(j) == "post7"
                            r = corrcoef(syw1{ii, 1}([1:4 6:16], kk), syw2{jj, 1}(:, ll));
                            corw{j, 1}{kk, ll}(idx, 1) = r(1, 2);
                            recw{j, 1}{ll, 1}(idx, :) = lsqnonneg(syw1{ii, 1}([1:4 6:16], :), syw2{jj, 1}(:, ll));
                        elseif post_name(j) == "post8"
                            r = corrcoef(syw1{ii, 1}(:, kk), syw2{jj, 1}([1:4 6:16], ll));
                            corw{j, 1}{kk, ll}(idx, 1) = r(1, 2);
                            recw{j, 1}{ll, 1}(idx, :) = lsqnonneg(syw1{ii, 1}, syw2{jj, 1}([1:4 6:16], ll));
                        else
                            r = corrcoef(syw1{ii, 1}(:, kk), syw2{jj, 1}(:, ll));
                            corw{j, 1}{kk, ll}(idx, 1) = r(1, 2);
                            recw{j, 1}{ll, 1}(idx, :) = lsqnonneg(syw1{ii, 1}, syw2{jj, 1}(:, ll));
                        end
                    end
                end
                idx = idx + 1;
            end
        end

        figure;
        math = zeros(syn1, syn2);
        matw = zeros(syn1, syn2);
        matw_rec = zeros(syn1, syn2);
        math_rec = zeros(syn1, syn2);

        for kk = 1:syn1
            for ll = 1:syn2
                matw(kk, ll) = mean(corw{j, 1}{kk, ll});
                math(kk, ll) = mean(corh{j, 1}{kk, ll});
                matw_rec(:, ll) = mean(recw{j, 1}{ll, 1}, 1);
                math_rec(:, ll) = mean(rech{j, 1}{ll, 1}, 1);
            end
        end

        clear xval yval;
        for kk = 1:syn2
            xval{kk} = label_sy(kk);
        end
        for kk = 1:syn1
            yval{kk} = label_sy{kk};
        end

        switch type
            case 'CorrW'
                h = heatmap(xval, yval, matw, 'FontSize', 16);
                h.CellLabelFormat = '%.2f';
            case 'CorrH'
                h = heatmap(xval, yval, math, 'FontSize', 16);
                h.CellLabelFormat = '%.2f';
            case 'ReconW'
                h = heatmap(xval, yval, matw_rec, 'FontSize', 16);
                h.CellLabelFormat = '%.2f';
            case 'ReconH'
                h = heatmap(xval, yval, math_rec, 'FontSize', 16);
                h.CellLabelFormat = '%.2f';
        end

        colormap(flipud(gray));
        if post_name(j) == "post1"
            ttl = 'pre surgery - Day I';
            h.YLabel = 'pre surgery';
            h.XLabel = 'Day I';
        elseif post_name(j) == "post2"
            ttl = 'Day I - Day II';
            h.YLabel = 'Day I';
            h.XLabel = 'Day II';
        elseif post_name(j) == "post3"
            ttl = 'Day II - Day III';
            h.YLabel = 'Day II';
            h.XLabel = 'Day III';
        elseif post_name(j) == "post5"
            ttl = 'Day III - Day IV';
            h.YLabel = 'Day III';
            h.XLabel = 'Day IV';
        elseif post_name(j) == "post6"
            ttl = 'Day IV - Day V';
            h.YLabel = 'Day IV';
            h.XLabel = 'Day V';
        elseif post_name(j) == "post7"
            ttl = 'Day V - Day VI';
            h.YLabel = 'Day V';
            h.XLabel = 'Day VI';
        elseif post_name(j) == "post8"
            ttl = 'Day VI - Day VII';
            h.YLabel = 'Day VI';
            h.XLabel = 'Day VII';
        elseif post_name(j) == "right710"
            ttl = 'Day VII - healthy side';
            h.YLabel = 'Day VII';
            h.XLabel = 'healthy side';
        end
        clim([0 1]);
        title(ttl);

        saveas(gcf, path_save, 'emf');

        syw1 = syw2;
        syh1 = syh2;
        count1 = count2;
        syn1 = syn2;
        clear xval;
        clear yval;
    end
end