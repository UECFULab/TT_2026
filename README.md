### Overview 
Data  & Program files for<br/> 
** Paper Title **<br/>
Authors: 

### System Requirements 
The analysis and simulation software was developed and tested using MATLAB R2025b.

## Data and program files 
### Structure of the program files (Matlab files)
<ins>**Fig2_plot_SegmentAngle.m**</ins><br>
Function to plot joint angles (deg) for the MP, PIP, and wrist joints, for Figure 2. 

* Input file:
  * **processed_marker/marker_post{exp_day}_task04.mat:** Time series of measured marker position
* Output file:
  * **out_seg_figure/mp_post{exp_day}.emf:** Time series of MP angle
  * **out_seg_figure/pip_post{exp_day}.emf:** Time series of PIP angle
  * **out_seg_figure/TAM.emf:** TAM of each experimental days

<ins>**Fig3_FigS1_plot_emg.m**</ins><br>
Function to Plot EMG Data for Figure 3 and Figure S1.
For each measurement day, the mean and variance for all trials are calculated.

* Input file:
  * **processed_EMG/emg_post{exp_day}_task04.mat:** Time series of measured EMG data
  * **trial_timing/timing_post{exp_day}_task04.mat:** Timing data of motion events (Rock/Scissors/Paper)
* Output file:
  * **out_emg_figure/emg_task04.emf:** Time series of Selected EMG (Fig. 3)
  * **out_emg_figure/emgAll_task04.emf:** Time series of All EMG data (Fig. S1)

<ins>**Fig4AC_Fig6_plot_synergy.m**</ins><br>
Function to plot muscle synergies for Figure 4AC and Figure 6.

* Input file:
  * **synergy_spatial/synergy_post{exp_day}_task04.mat:** Muscle Synergies
  * **synergy_temporal/synergy_post{exp_day}_task04.mat:** Temporal Synergy Coefficient
  * **synergy_sqdev/synergy_post{exp_day}_task04.mat:** VAF values
  * **trial_timing/timing_post{exp_day}_task04.mat:** Timing data of motion events (Rock/Scissors/Paper)
* Output file:
  * **out_synergy_figure/post{exp_day}_task04.emf:** Synergy Analysis Results of the experimental day (Fig. 4AC)
  * **out_synergy_figure/task04_tempSynCOrr_{2,3}.emf:** Correlation of Temporal Synergy Coefficient with fixed synergy number 2/3 (Fig. 6)
* Used program file:
  * **sort_sunergy.m:** Program for sorting synergies.

<ins>**Fig4B_plot_VAF.m**</ins><br>
Function to Plot VAF for Muscle Synergies, Figure 4B.
For each task, this function plots the VAF values against the number of synergies and plots the change in VAF over time when the number of synergies is fixed.

* Input file:
  * **synergy_sqdev/synergy_post{exp_day}_task04.mat:** VAF values
  * **trial_timing/timing_post{exp_day}_task04.mat:** Timing data of motion events (Rock/Scissors/Paper)
* Output file:
  * **out_vaf_figure/vaf_task04.emf:** VAF of synergies (Fig. 4B).

<ins>**Fig5A_plot_synergy_correlation.m**</ins><br>
Function to verify the correlation of synergy between measurement dates in Figure 5A.
The output heatmap contains synergy information from the previous measurement in the rows and from the current measurement in the columns

* Input file:
  * **synergy_spatial/synergy_post{exp_day}_task04.mat:** Muscle Synergies
  * **synergy_temporal/synergy_post{exp_day}_task04.mat:** Temporal Synergy Coefficient
  * **synergy_sqdev/synergy_post{exp_day}_task04.mat:** VAF values
  * **trial_timing/timing_post{exp_day}_task04.mat:** Timing data of motion events (Rock/Scissors/Paper)
* Output file:
  * **out_map/heatmap_post{exp_day}_task04.emf:** Correlation map of synergies
* Used program file:
  * **sort_sunergy.m:** Program for sorting synergies.

<ins>**Fig5B_plot_synergy_MMD.m**</ins><br>
Function to calculate maximum mean deviation (MMD) in Figure 5B.
For each measurement date, calculate the MMD between spatial reference points for muscle synergies and plot the changes over time from preoperative to day VII.

* Input file:
  * **synergy_spatial/synergy_post{exp_day}_task04.mat:** Muscle Synergies
  * **synergy_temporal/synergy_post{exp_day}_task04.mat:** Temporal Synergy Coefficient
  * **synergy_sqdev/synergy_post{exp_day}_task04.mat:** VAF values
  * **trial_timing/timing_post{exp_day}_task04.mat:** Timing data of motion events (Rock/Scissors/Paper)
* Output file:
  * **out_mmd_figure/mmd_task04.emf:** maximum mean deviation (MMD) between synergies
