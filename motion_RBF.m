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

