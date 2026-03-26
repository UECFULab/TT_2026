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
