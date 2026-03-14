%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Calculate muscle synergies from the EMG dataset using NNMF.
Save the spatial basis, temporal basis, and VAF data into separate files.

Inside Function: makeEMGNMFOhta
Input file：processed_EMG, trial_timing
Output file: synergy_spatial, synergy_temporal, synergy_sqdev
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
post_name = ["pre1" "post1" "post2" "post3" "post4" "post5" "post6" "post7" "post8" "healthyside" "healthysub1" "healthysub2"];
task_name = ["task01" "task02" "task03" "task04" "task05"];
trial_name = ["trial1" "trial2" "trial3" "trial4" "trial5" "trial6" "trial7" "trial8" "trial9" "trial10" "trial11" "trial12" "trial13" "trial14" "trial15" "trial16"]; 

for i = [1:4 6:10] %post index
    for j = [1 4] %task index
        path_each_trial = append('processed_EMG/emg_', post_name(i), '_', task_name(j));
        path_timing = append('trial_timing/timing_',  post_name(i),  '_',  task_name(j)); 
        path_synergy_w = append('synergy_spatial/synergy_', post_name(i), '_', task_name(j)); 
        path_synergy_h = append('synergy_temporal/synergy_', post_name(i), '_', task_name(j));
        path_synergy_r2 = append('synergy_sqdev/synergy_', post_name(i), '_', task_name(j)); 
        load(path_timing, '-mat'); 
        load(path_each_trial); 

        count = size(on, 1); 
        trial = on(:, 2)-on(:, 1)+1; 
        kf = 1; 
        nrep = 20; 
        nshuffle = 1; 
        alg = 'alg'; 
        normalization_method    = 'mean';
        warning('off'); 

        if post_name(i) == "pre" 
            n_muscle = 14; 
        elseif post_name(i) == "post7"
            n_muscle = 15; 
        else
            n_muscle =16; 
        end

                synergy_w = struct("trial1", []); 
                synergy_h = struct("trial1", []); 
                synergy_r2 = struct("trial1", []); 
                for k = 1:count
                    X_fix = zeros(100, n_muscle);   
                    X = getfield(each_trial, trial_name(k)); 
                    
                    %Discard defective data
                    if post_name(i) == "post4"
                        X(:, 2) = []; 
                        X(:, 6) = []; 
                    end
                    if post_name(i) == "post7"
                        X(:, 5) = []; 
                    end

                    X = X'; 
                    X = normalize(X, normalization_method); 
                    X(X<0) = 0; 
                    [Y, Y_dat] = makeEMGNMFOhta(X, kf, nrep, nshuffle, alg, normalization_method); 
                    synergy_w = setfield(synergy_w, trial_name(k), Y_dat.W); 
                    synergy_h = setfield(synergy_h, trial_name(k), Y_dat.H); 
                    synergy_r2 = setfield(synergy_r2, trial_name(k), cat(2, Y.r2, Y.shuffle.r2)); 
                end
                save(path_synergy_w, 'synergy_w'); 
                save(path_synergy_h, 'synergy_h'); 
                save(path_synergy_r2, 'synergy_r2'); 
        
        warning('on'); 
    end
end


