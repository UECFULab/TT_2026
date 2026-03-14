%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Verify the correlation between spatial and temporal synergies during measurement days.
Provide methods for quantifying correlations as 'type' (line:24, 'CorrW', 'Corrh', 'ReconW', 'ReconH').
The output heatmap contains synergy information from the previous measurement in the row direction and the current measurement in the column direction.

CorrW: To verify the spatial basis correlation between measurement days, use the correlation coefficient.
Corrh: To verify the temporal basis correlation between measurement days, use the correlation coefficient.
ReconW: ReconW: To verify the spatial basis correlation between measurement days, regress the spatial basis using the spatial basis obtained from the previous measurement via non-negative least squares.
ReconH: ReconW: To verify the temporal basis correlation between measurement days, regress the temporal basis using the temporal basis obtained from the previous measurement via non-negative least squares.

Inside Function: sort_synergy.m
Input file: trial_timing, synergy_spatial, synergy_temporal, synergy_sqdev
Output file: map
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
post_name = ["pre1" "post1" "post2" "post3" "post4" "post5" "post6" "post7" "post8" "healthyside" "healthysub1" "healthysub2"];
Post_name = ['pre1', 'post1', 'post2', 'post3', 'post4', 'post5', 'post6', 'post7', 'post8']; 
task_name = ["task01" "task02" "task03" "task04" "task05"];
Task_name = ["LargeCube" "MiddleCube" "SmallCube" "Janken" "JankenLie"]; 
trial_name = ["trial1" "trial2" "trial3" "trial4" "trial5" "trial6" "trial7" "trial8" "trial9" "trial10" "trial11" "trial12" "trial13" "trial14" "trial15" "trial16"]; 
sy_name = ["sy1" "sy2" "sy3" "sy4" "sy5"]; 
label_sy = ["synergy1" "synergy2" "synergy3" "synergy4" "synergy5"]; 
type = 'ReconW';  %'CorrW', 'Corrh', 'ReconW' or 'ReconH'
R2_option = 1; %0:disp R2
syn_fix = 1; %0:fix the number of synergies

for i = [1 4] %task
    syw_post = struct("pre1", []); 
    syh_post = struct("pre1", []); 
    corw_transition = NaN(11, 3); 
    corh_transition = NaN(11, 3); 
    order = 1; 
    clear corh corw rech recw r2h r2w; 
    for j = [1:4 6:10]%post
        path_timing = append('trial_timing/timing_', post_name(j), '_', task_name(i));
        path_synergy_w = append('synergy_spatial/synergy_', post_name(j), '_', task_name(i)); 
        path_synergy_h = append('synergy_temporal/synergy_', post_name(j), '_', task_name(i)); 
        path_synergy_r2 = append('synergy_sqdev/synergy_', post_name(j), '_', task_name(i));
        path_save = append('map/heatmap_', post_name(j), '_', task_name(i)); 
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

        [syw_each,syh_each] = sort_synergy(synergy_w, synergy_h, sy_n, n_muscle, on, task_name(i), post_name(j)); 
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
                            if R2_option == 0
                                mdl = fitlm(syh1{ii, 1}'*rech{j, 1}{ll, 1}(idx, :)', syh2{jj, 1}(ll, :)'); 
                                r2h{j, 1}(idx, ll) = mdl.Rsquared.Adjusted; 
                            end
                            if post_name(j) == "post1"
                                r = corrcoef(syw1{ii, 1}(:, kk), syw2{jj, 1}(1:14, ll)); 
                                corw{j, 1}{kk, ll}(idx, 1) = r(1, 2); 
                                recw{j, 1}{ll, 1}(idx, :) = lsqnonneg(syw1{ii, 1}, syw2{jj, 1}(1:14, ll)); 
                                if R2_option == 0
                                    mdl = fitlm(syw1{ii, 1}*recw{j, 1}{ll, 1}(idx, :)', syw2{jj, 1}(1:14, ll)); 
                                    r2w{j, 1}(idx, ll) = mdl.Rsquared.Adjusted; 
                                end
                            elseif post_name(j) == "post7"
                                r = corrcoef(syw1{ii, 1}([1:4 6:16], kk), syw2{jj, 1}(:, ll)); 
                                corw{j, 1}{kk, ll}(idx, 1) = r(1, 2); 
                                recw{j, 1}{ll, 1}(idx, :) = lsqnonneg(syw1{ii, 1}([1:4 6:16], :), syw2{jj, 1}(:, ll)); 
                                if R2_option == 0
                                    mdl = fitlm(syw1{ii, 1}([1:4 6:16], :)*recw{j, 1}{ll, 1}(idx, :)', syw2{jj, 1}(:, ll)); 
                                    r2w{j, 1}(idx, ll) = mdl.Rsquared.Adjusted;  
                                end
                            elseif post_name(j) == "post8"
                                r = corrcoef(syw1{ii, 1}(:, kk), syw2{jj, 1}([1:4 6:16], ll)); 
                                corw{j, 1}{kk, ll}(idx, 1) = r(1, 2); 
                                recw{j, 1}{ll, 1}(idx, :) = lsqnonneg(syw1{ii, 1}, syw2{jj, 1}([1:4 6:16], ll)); 
                                if R2_option == 0
                                    mdl = fitlm(syw1{ii, 1}*recw{j, 1}{ll, 1}(idx, :)', syw2{jj, 1}([1:4 6:16], ll)); 
                                    r2w{j, 1}(idx, ll) = mdl.Rsquared.Adjusted; 
                                end
                            else
                                r = corrcoef(syw1{ii, 1}(:, kk), syw2{jj, 1}(:, ll)); 
                                corw{j, 1}{kk, ll}(idx, 1) = r(1, 2); 
                                recw{j, 1}{ll, 1}(idx, :) = lsqnonneg(syw1{ii, 1}, syw2{jj, 1}(:, ll)); 
                                if R2_option == 0
                                    mdl = fitlm(syw1{ii, 1}*recw{j, 1}{ll, 1}(idx, :)', syw2{jj, 1}(:, ll)); 
                                    r2w{j, 1}(idx, ll) = mdl.Rsquared.Adjusted; 
                                end
                            end
                        end
                    end
                    idx = idx + 1; 
                end
            end

            %mdl = fitlm(syh1{ii, 1}'*rech{j, 1}{ll, 1}(idx, :)', syh2{jj, 1}(ll, :)'); 
            %r2h{j, 1}(idx, ll) = mdl.Rsquared.Adjusted; 

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
                switch type
                    case 'ReconW'
                        if R2_option == 0
                            xval{kk} = append(label_sy(kk), ' R^2=', num2str(mean(r2w{j, 1}(:, kk))), '[', num2str(min(r2w{j, 1}(:, kk))), ' ', num2str(max(r2w{j, 1}(:, kk))), ']'); 
                        else
                            xval{kk} = label_sy(kk); 
                        end 
                    case 'ReconH'
                        if R2_option == 0
                            xval{kk} = append(label_sy(kk), ' R^2=', num2str(mean(r2h{j, 1}(:, kk))), '[', num2str(min(r2w{j, 1}(:, kk))), ' ', num2str(max(r2w{j, 1}(:, kk))), ']'); 
                        else
                            xval{kk} = label_sy(kk);
                        end
                    case 'CorrW'
                        xval{kk} = label_sy{kk}; 
                    case 'CorrH'
                        xval{kk} = label_sy{kk}; 
                end
            end
            for kk = 1:syn1
                yval{kk} = label_sy{kk}; 
            end

            switch type
                case 'CorrW'
                    h = heatmap(xval, yval, matw, 'FontSize', 14); 
                case 'CorrH'
                    h = heatmap(xval, yval, math, 'FontSize', 14);
                case 'ReconW'
                    h = heatmap(xval, yval, matw_rec, 'FontSize', 14); 
                case 'ReconH'
                    h = heatmap(xval, yval, math_rec, 'FontSize', 14); 
            end

            colormap(flipud(gray)); 
            if post_name(j) == "post1"
                ttl = 'pre surgery - Day1'; 
                h.YLabel = 'pre surgery'; 
                h.XLabel = 'Day1'; 
            elseif post_name(j) == "post2"
                ttl = 'Day1 - Day2'; 
                h.YLabel = 'Day1'; 
                h.XLabel = 'Day2'; 
            elseif post_name(j) == "post3"
                ttl = 'Day2 - Day3'; 
                h.YLabel = 'Day2'; 
                h.XLabel = 'Day3'; 
            elseif post_name(j) == "post5"
                ttl = 'Day3 - Day4'; 
                h.YLabel = 'Day3'; 
                h.XLabel = 'Day4'; 
            elseif post_name(j) == "post6"
                ttl = 'Day4 - Day5'; 
                h.YLabel = 'Day4'; 
                h.XLabel = 'Day5'; 
            elseif post_name(j) == "post7"
                ttl = 'Day5 - Day6'; 
                h.YLabel = 'Day5'; 
                h.XLabel = 'Day6'; 
            elseif post_name(j) == "post8"
                ttl = 'Day6 - Day7'; 
                h.YLabel = 'Day6'; 
                h.XLabel = 'Day7'; 
            elseif post_name(j) == "healthyside"
                ttl = 'Day7 - healthy side'; 
                h.YLabel = 'Day7'; 
                h.XLabel = 'healthy side'; 
            end
            clim([0 1]); 
            title(ttl); 

            saveas(gcf, path_save, 'pdf'); 

            syw1 = syw2; 
            syh1 = syh2; 
            count1 = count2; 
            syn1 = syn2; 
            clear xval; 
            clear yval; 
        end
    end
end