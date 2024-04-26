clc; clear all; close all;

%% Add dependencies folder to the search path

addpath(genpath('dependencies'))

%% Would you like to run simulation test or see the summary 

prompt = ['Do you want to run the (1)simulation test or (2)see the summary statistic results?',...
    '\nPress "1" for simulation test or "2" for summary statistic results.    '];
selection = input(prompt);   % Ask for running open loop simulation
disp(' ');
addpath(genpath(pwd));

if selection==1
    disp('Running the simulation test. This might take some time')
    cd m_files
    main_simulation
    cd ..
elseif selection==2
    disp('Displaying the summary statistic results')
    cd m_files
    % Run the summary statistic result code
    summary_result
    cd ..
else
    disp('Default: Displaying the summary statistic results')
    cd m_files
    % Run the summary statistic result code
    summary_result
    cd ..
end