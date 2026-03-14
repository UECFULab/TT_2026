%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Filter the EMG data and save it separately for each trial.

Input file: trial_timing, each raw EMG data file(csv)
Output file: processed_EMG
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
post_name = ["pre1" "post1" "post2" "post3" "post4" "post5" "post6" "post7" "post8" "healthyside" "healthysub1" "healthysub2"];
task_name = ["task01" "task02" "task03" "task04" "task05"]; 
Task_name = ["Task01" "Task02" "Task03" "Task04" "Task05"]; 
trial_name = ["trial1", "trial2", "trial3", "trial4", "trial5", "trial6", "trial7", "trial8", "trial9", "trial10", "trial11", "trial12", "trial13", "trial14", "trial15", "trial16"]; 

for i = [1:4 6:10] %post index
    for j = [1 4] %task index
        path_timing = append('trial_timing/timing_',  post_name(i),  '_',  task_name(j)); 
        path_EMG = append('data', post_name(i), '/', Task_name(j), '.csv'); 
        savefile_name = append('emg_', post_name(i), '_', task_name(j), '.mat'); 
        file_dir = 'processed_EMG/'; 
        file = append(file_dir, savefile_name); 
        each_trial = struct('trial1', []); 
        load(path_timing); 
        data = readmatrix(path_EMG); 
        data = data(4:end, 3:end); 
        data = rmmissing(data); 
        if post_name(i) == "healthysub2"
            data(:, 7) = [];  
        end
        if post_name(i) == "pre1"
            data(:, end) = []; 
        end
        se1 = size(data, 1); 
        se2 = size(data, 2); 
        count = size(on, 1); 
        trial = on(:, 2) -on(:, 1) +1; 
        fhp = 50; %High pass frequency
        flp = 20; %Low pass frequency
        fs = 1000; %Sampling frequency
        medianfilter = 1; %medianfilter(1:active, 0:deactive)
        med_window = 200; %medianfilter window size
        dsr = 100; %Down sampling frequency

        %Filtering (High pass filter> Rectification> medianfilter> Low pass filter> Down sampling)
        [b_lp, a_lp] = butter(2, 2.*fhp ./ fs, 'high'); 
        for k = 1:se2
            data(:, k) = filtfilt(b_lp, a_lp, data(:, k)); 
        end
        data = abs(data); 
        if medianfilter
            data = medfilt1(data,med_window);
        end
        [b_lp, a_lp] = butter(2, 2.*flp ./ fs, 'low'); 
        for k = 1:se2
            data(:, k) = filtfilt(b_lp, a_lp, data(:, k)); 
        end
        data = resample(data, dsr, fs);

        %Save EMG data separated by trial
        for k = 1:count
            pro_EMG = data(on(k, 1):on(k, 2), :); 
            each_trial = setfield(each_trial, trial_name(k), pro_EMG); 
        end
        
        save(file, 'each_trial'); 
    end
end


        
