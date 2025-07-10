### This folder is set up to run the Pioneer WEC-Sim model in a range of wave conditions to prep for LAMP testing.

## Data files
- The `trajectoryFiles` folder contains the 130 second timeseries data (6 dof position) for each run. The data is set to 0 average and ramped to 0 on both ends.
- `regularBatch.mat` has the buoy response data for the regular waves to be run at LAMP. 
- `PMBatch.mat` has the buoy response data for the Pierson-Moskowitz waves to be run at LAMP. 
- `loadBatchData.m` is used for loading data from batch runs and analyzing.
- `addRamps.m` is used for loading data from batch runs, adding ramps, and saving for each run.

## Running more waves
- `addSource.m` should be run before running the WEC-Sim model to add the WEC-Sim source code to the MATLAB path.
- `runRegularBatch.m` and `runPMBatch.m` were used to complete the batch runs for wave condtions.
- `runWave.m` can be used to run a one-off wave (regular or PM spectrum).
    - `PMWaveCreation.m` creates a spectrum data file (which WEC-Sim loads in) for a 120 s repeat period.
    - `postProcess.m` plots and extracts the response data.

## WEC-Sim model
- `wecSimInputFile.m` is the input file defining model parameters.
- `pioneerSNL.slx` is the simulink model.
- `hydroData` contains the .h5 (BEM data).
- `geometry` contains the stl files.