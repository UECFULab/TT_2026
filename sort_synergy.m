function [syw_each,syh_each] = sort_synergy(synergy_w, synergy_h, sy_n, n_muscle, on, task_name, post_name)

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
        else
            cormat = zeros(sy_n_before, sy_n);
            for m = 1:sy_n_before
                for l = 1:sy_n
                    fix_w(:, l) = wdata(:, l)/norm(wdata(:, l));
                    fix_h(l, :) = hdata(l, :)/norm(hdata(l, :));
                    fix_h_before(m, :) = hdata_before(m, :)/norm(hdata_before(m, :));
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
            wdata = X(:, 101:(100+n_muscle))';
            hdata = X(:, 1:100);

            cormat = zeros(sy_n_before, sy_n);
            for m = 1:sy_n_before
                for l = 1:sy_n
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

        syw_each{k, 1} = wdata;
        syh_each{k, 1} = hdata;
    end
    wdata_before = wdata_sum./count;
    hdata_before = hdata_sum./count;
    sy_n_before = sy_n;
end

[syw_each, syh_each] = synergy_detail_arrange(syw_each, syh_each, sy_n, count, task_name, post_name);

end

%%
function [syw_each, syh_each] = synergy_detail_arrange(syw_each, syh_each, sy_n, count, task_name, post_name)

if task_name == "task04" && sy_n == 4
    if post_name == "post2"
        for k = 1:count
            if syh_each{k, 1}(3, 60) > 0.2
                syh_each{k, 1}([4 3], :) = syh_each{k, 1}([3 4], :);
                syw_each{k, 1}(:, [4 3]) = syw_each{k, 1}(:, [3 4]);
            end
            if syh_each{k, 1}(3, 25) > 0.1
                syh_each{k, 1}([2 3], :) = syh_each{k, 1}([3 2], :);
                syw_each{k, 1}(:, [2 3]) = syw_each{k, 1}(:, [3 2]);
            end
        end
    end
end

if task_name == "task01" && sy_n == 4
    if post_name == "post1"
        for k = 1:count
            if syh_each{k, 1}(2, 25) < 0.2
                syw_each{k, 1}(:, [2 4]) = syw_each{k, 1}(:, [4 2]);
                syh_each{k, 1}([2 4], :) = syh_each{k, 1}([4 2], :);
            end
            if syh_each{k, 1}(2, 80) > 0.1
                syw_each{k, 1}(:, [2 3]) = syw_each{k, 1}(:, [3 2]);
                syh_each{k, 1}([2 3], :) = syh_each{k, 1}([3 2], :);
            end
        end
    end
    if post_name == "post2"
        for k = 1:count
            if syh_each{k, 1}(3, 100) > 0.2
                syw_each{k, 1}(:, [3 4]) = syw_each{k, 1}(:, [4 3]);
                syh_each{k, 1}([3 4], :) = syh_each{k, 1}([4 3], :);
            end
        end
    end
end
if sy_n == 3
    if task_name == "task02"
        if post_name == "pre1"
            for k = 1:count
                syw_each{k, 1}(:, [1 2]) = syw_each{k, 1}(:, [2 1]);
                syh_each{k, 1}([1 2], :) = syh_each{k, 1}([2 1], :);
            end
        end
    end
    if task_name == "task03"
        if post_name == "pre1"
            for k = 1:count
                syw_each{k, 1}(:, [1 2]) = syw_each{k, 1}(:, [2 1]);
                syh_each{k, 1}([1 2], :) = syh_each{k, 1}([2 1], :);
                syw_each{k, 1}(:, [1 3]) = syw_each{k, 1}(:, [3 1]);
                syh_each{k, 1}([1 3], :) = syh_each{k, 1}([3 1], :);
            end
        end
    end

    if task_name == "task04"
        if post_name == "post2"
            for k = 1:count
                if syh_each{k, 1}(2, 62) > 0.2
                    syw_each{k, 1}(:, [3 2]) = syw_each{k, 1}(:, [2 3]);
                    syh_each{k, 1}([3 2], :) = syh_each{k, 1}([2 3], :);
                end
            end
        end
        if post_name == "post7"
            for k = 1:count
                syh_each{k, 1}([2 3], :) = syh_each{k, 1}([3 2], :);
                syw_each{k, 1}(:, [2 3]) = syw_each{k, 1}(:, [3 2]);
                syh_each{k, 1}([1 3], :) = syh_each{k, 1}([3 1], :);
                syw_each{k, 1}(:, [1 3]) = syw_each{k, 1}(:, [3 1]);
            end
        end

        if post_name == "post8"
            for k = 1:count
                syh_each{k, 1}([1 2], :) = syh_each{k, 1}([2 1], :);
                syw_each{k, 1}(:, [1 2]) = syw_each{k, 1}(:, [2 1]);
                syh_each{k, 1}([2 3], :) = syh_each{k, 1}([3 2], :);
                syw_each{k, 1}(:, [2 3]) = syw_each{k, 1}(:, [3 2]);
            end
        end
        if post_name == "post5"
            for k = 1:count
                syh_each{k, 1}([2 3], :) = syh_each{k, 1}([3 2], :);
                syw_each{k, 1}(:, [2 3]) = syw_each{k, 1}(:, [3 2]);
            end
        end
        if post_name == "post6"
            for k = 1:count
                syh_each{k, 1}([2 3], :) = syh_each{k, 1}([3 2], :);
                syw_each{k, 1}(:, [2 3]) = syw_each{k, 1}(:, [3 2]);
                syh_each{k, 1}([1 3], :) = syh_each{k, 1}([3 1], :);
                syw_each{k, 1}(:, [1 3]) = syw_each{k, 1}(:, [3 1]);
            end
        end
    end
end
end
