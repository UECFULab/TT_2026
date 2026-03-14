function [syw_each,syh_each] = sort_synergy(synergy_w, synergy_h, sy_n, n_muscle, on, task_name, post_name)
%計算された筋シナジーを時間基底を参照してグルーピングする

trial_name = ["trial1" "trial2" "trial3" "trial4" "trial5" "trial6" "trial7" "trial8" "trial9" "trial10" "trial11" "trial12" "trial13" "trial14" "trial15" "trial16"]; 

count = size(on, 1); 
trial = on(:, 2) - on(:, 1) + 1; 

for nn = 1:20
    hdata_sum = zeros(sy_n, 100); 
    wdata_sum = zeros(n_muscle, sy_n); 
    for k = 1:count
        w = getfield(synergy_w, trial_name(k)); 
        h = getfield(synergy_h, trial_name(k));
        wdata = w{sy_n, 1}; 
        hdata_raw = h{sy_n, 1};
        hdata = zeros(sy_n, 100); 
        for l = 1:100
            hdata(:, l) = hdata_raw(:, fix(l/100*trial(k))); 
        end
        %wdata(2, :) = []; wdata(6, :) = []; 
        fix_w = zeros(n_muscle, sy_n); 
        fix_h = zeros(sy_n, 100); 
        if exist('hdata_before') == 0
            idx = zeros(sy_n, 1); 
            for m = 1:sy_n
                [M, I] = max(hdata(m, :));
                idx(m) = I; 
            end
            X = cat(2, hdata, wdata'); 
            X = cat(2, X, idx);
            X = sortrows(X, 100+n_muscle+1, 'ascend');
            wdata = X(:, 101:(100+n_muscle))'; 
            hdata = X(:, 1:100); 
            for m = 1:sy_n
                wdata(:, m) = wdata(:, m)/norm(wdata(:, m)); 
                hdata(m, :) = hdata(m, :)/norm(wdata(m, :)); 
            end
        else %最初のループ以外の時並び替え
            cormat = zeros(sy_n_before, sy_n); 
            for m = 1:sy_n_before
                for l = 1:sy_n
                    %cormat(m, l) = sum((wdata(:, l)-wdata_before(:, m)).*(wdata(:, l)-wdata_before(:, m))); 
                    %cormat(m, l) =  dot(wdata(:, l), wdata_before(:, m))/(norm(wdata(:, l))*norm(wdata_before(:, m)));
                    fix_w(:, l) = wdata(:, l)/norm(wdata(:, l)); 
                    fix_h(l, :) = hdata(l, :)/norm(hdata(l, :)); 
                    fix_h_before(m, :) = hdata_before(m, :)/norm(hdata_before(m, :)); 
                    %cormat(m, l) =  dot(fix_h(l, :), fix_h_before(m, :))/(norm(fix_h(l, :))*norm(fix_h_before(m, :))); 
                    %cormat(m, l) =  dot(wdata(:, l), wdata_before(:, m))/(norm(wdata(:, l))*norm(wdata_before(:, m)));
                    cormat(m, l) = max(xcorr(fix_h(l, :), fix_h_before(m, :), 10)); 
                end
            end
            X = cat(2, fix_h, fix_w'); 
            X = cat(2, X, cormat');

            %%%%%%%%%%%%%%%%%%%%%%%
            [row, col] = find(cormat==max(cormat, [], 'all'));
            X([row col], :) = X([col row], :); 
            cormat = X(:, (100+n_muscle+1):(100+n_muscle+sy_n)); 
            cormat(col, :) = NaN; cormat(:, col) = NaN;  
            [row, col] = find(cormat==max(cormat, [], 'all'));
            X([row col], :) = X([col row], :); 
            %%%%%%%%%%%%%%%%%%%%%%%
        %{
                                    for m = 1:min(sy_n, sy_n_before)
                                        X = sortrows(X, 100+n_muscle+m, 'descend'); 
                                    end
        %}
            wdata = X(:, 101:(100+n_muscle))'; 
            hdata = X(:, 1:100); 

            cormat = zeros(sy_n_before, sy_n); 
            for m = 1:sy_n_before
                for l = 1:sy_n
                    %fix_w(:, l) = wdata(:, l)/norm(wdata(:, l)); 
                    fix_h(l, :) = hdata(l, :)/norm(hdata(l, :)); 
                    fix_h_before(m, :) = hdata_before(m, :)/norm(hdata_before(m, :)); 
                    cormat(m, l) = sum((fix_h(l, :)-fix_h_before(m, :)).^2); 
                end
            end


            X = cat(2, hdata, wdata'); 
            X = cat(2, X, cormat');
        
            %%%%%%%%%%%%%%%%%%%%%%%
            [row, col] = find(cormat==min(cormat, [], 'all'));
            X([row col], :) = X([col row], :); 
            cormat = X(:, (100+n_muscle+1):(100+n_muscle+sy_n)); 
            cormat(col, :) = NaN; cormat(:, col) = NaN;  
            [row, col] = find(cormat==min(cormat, [], 'all'));
            X([row col], :) = X([col row], :); 
            %%%%%%%%%%%%%%%%%%%%%%%
            wdata = X(:, 101:(100+n_muscle))'; 
            hdata = X(:, 1:100); 
        end
        hdata_sum = hdata_sum + hdata; 
        wdata_sum = wdata_sum + wdata; 

        %[wdata, hdata] = synergy_detail_arrange(wdata, hdata, sy_n, task_name, post_name); 

        syw_each{k, 1} = wdata; 
        syh_each{k, 1} = hdata; 
    end
    wdata_before = wdata_sum./count; 
    hdata_before = hdata_sum./count; 
    sy_n_before = sy_n; 
end

[syw_each, syh_each] = synergy_detail_arrange(syw_each, syh_each, sy_n, count, task_name, post_name); 

end


