### Overview 
Data  & Program files for<br/> 
** Paper Title **<br/>
Authors: 

### System Requirements 
The analysis and simulation software was developed and tested using MATLAB R2025b.


### Structure of the program files (Matlab files)
<ins>**Fig2_plot_SegmentAngle.m**</ins>
Function to plot joint angles (deg) for the MP, PIP, and wrist joints, for Figure 2. 

* Input file:
  * **processed_marker/marker_post{exp_day}_task04.mat:** Time series of measured marker position.
* Output file:
  * **out_seg_figure/mp_post{exp_day}.emf:** Time series of MP angle. 
  * **out_seg_figure/pip_post{exp_day}.emf:** Time series of PIP angle. 
  * **out_seg_figure/TAM.emf:** TAM of each experimental days. 

<ins>**Fig3_FigS1_plot_emg.m**</ins>
Function to Plot EMG Data for Figure 3 and Figure S1.
For each measurement day, the mean and variance for all trials are calculated.

* Input file:
  * **processed_EMG/emg_post{exp_day}_task04.mat:** Time series of measured EMG data.
  * **trial_timing/timing_post{exp_day}_task04.mat:** Timing data of motion events (Rock/Scissors/Paper)
* Output file:
  * **out_emg_figure/emg_task04.emf:** Time series of Selected EMG (Fig. 3). 
  * **out_emg_figure/emgAll_task04.emf:** Time series of All EMG data (Fig. S1). 

