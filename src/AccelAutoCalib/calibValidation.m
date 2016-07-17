%%         Calibration Validation on several datasets
%
%
%% clear all variables and close all previous figures
clear
close all
clc

%% Main interface parameters ==============================================

% 'matFile' or 'dumpFile' mode
loadSource = 'dumpFile';
saveToCache = false;
loadJointPos = true;

% model and data capture file
modelPath = '../models/iCubGenova05/iCubFull.urdf';
dataPath  = '../../data/calibration/dumper/iCubGenova05_#1/';
dataSetNb = '_00003';
calibrationMapFile = './data/calib/calibrationMap_#1.mat';
iterator = 1;
logTest = false; % if set to true, current iter number (saved in a file) 
% is incremented, all data is saved and figures printed in a new folder
% indexed by the iter number.
% Above 4 parameters are saved in text format for easier search from
% a file explorer app.

% Start and end point of data samples
timeStart = 1;  % starting time in capture data file (in seconds)
timeStop  = -1; % ending time in capture data file (in seconds). If -1, use 
                % the end time from log
% filtering/subsampling: the main single data bucket of (timeStop-timeStart)/10ms 
% samples is sub-sampled to 'subSamplingSize' samples for running the ellipsoid fitting.
subSamplingSize = 1000;

% define the limb from which we will calibrate all the sensors.
% Activate all the sensors of that limb.
jointsToCalibrate.parts = {'left_leg'};

%% set init parameters 'ModelParams'
%
run jointsNsensorsDefinitions;

%% Update iterator and prepare log folders/files
%
if logTest
    if exist('./data/test/iterator.mat','file') == 2
        load('./data/test/iterator.mat','iterator');
        iterator = iterator+1;
    end
    save('./data/test/iterator.mat','iterator');
    
    figsFolder = ['./data/test/log_' num2str(iterator)];
    dataFolder = ['./data/test'];
    [mkdirStatus,mkdirCmdout] = system(['mkdir ' figsFolder],'-echo')
    [mkdirStatus,mkdirCmdout] = system(['mkdir ' dataFolder],'-echo')
    fileID = fopen([dataFolder '/log_' num2str(iterator) '.txt'],'w');
    fprintf(fileID,'modelPath = %s\n',modelPath);
    fprintf(fileID,'dataPath = %s\n',dataPath);
    fprintf(fileID,'dataSetNb = %s\n',dataSetNb);
    fprintf(fileID,'calibrationMapFile = %s\n',calibrationMapFile);
    fprintf(fileID,'iterator = %d\n',iterator);
    fclose(fileID);
end

%% ===================================== CALIBRATION VALIDATION ==============================
%

%% build input data before calibration
%

% Build input data without calibration applied
[data.bc,sensorsIdxListFile,sensMeasCell.bc] = buildInputDataSet(...
    loadSource,saveToCache,loadJointPos,...
    dataPath,dataSetNb,...
    subSamplingSize,timeStart,timeStop,...
    ModelParams);

% Common result buckets
pVecList = cell(1,length(sensorsIdxListFile));
dVecList = cell(1,length(sensorsIdxListFile));
dOrientList = cell(1,length(sensorsIdxListFile));
dList = cell(1,length(sensorsIdxListFile));

%% Apply calibration and reload input data
%

% Load existing calibration
if exist(calibrationMapFile,'file') == 2
    load(calibrationMapFile,'calibrationMap');
end

if ~exist('calibrationMap','var')
    error('calibrationMap not found');
end

% Build input data with calibration applied
[data.ac,sensorsIdxListFile,sensMeasCell.ac] = buildInputDataSet(...
    loadSource,saveToCache,false,...
    dataPath,dataSetNb,...
    subSamplingSize,timeStart,timeStop,...
    ModelParams,calibrationMap);


%% Check distance to 9.807 sphere manifold
%

% iteration list
activeAccs = mtbSensorCodes_list{1}(cell2mat(mtbSensorAct_list));
accIter = sensorsIdxListFile;

for acc_i = accIter
    %% distance to a centered sphere (R=9.807) before calibration
    [pVec.bc,dVec.bc,dOrient.bc,d.bc] = ellipsoid_proj_distance_fromExp(...
        sensMeasCell.bc{1,acc_i}(:,1),...
        sensMeasCell.bc{1,acc_i}(:,2),...
        sensMeasCell.bc{1,acc_i}(:,3),...
        [0 0 0]',[9.807 9.807 9.807]',eye(3,3));
    
    %% distance to a centered sphere (R=9.807) after calibration
    [pVec.ac,dVec.ac,dOrient.ac,d.ac] = ellipsoid_proj_distance_fromExp(...
        sensMeasCell.ac{1,acc_i}(:,1),...
        sensMeasCell.ac{1,acc_i}(:,2),...
        sensMeasCell.ac{1,acc_i}(:,3),...
        [0 0 0]',[9.807 9.807 9.807]',eye(3,3));
    
    pVecList{1,acc_i} = pVec;
    dVecList{1,acc_i} = dVec;
    dOrientList{1,acc_i} = dOrient;
    dList{1,acc_i} = d;
    
end

%% Plot figures
%

time = data.ac.tInit + data.ac.parsedParams.time(:);

for acc_i = accIter
    %% Plot distributions
    % Check if we should print to a log file
    if logTest
        FID = fopen([figsFolder '/distrib_' activeAccs{acc_i} '.txt'],'w');
    else
        FID = 1;
    end
    
    figure('Name',['calibration of MTB sensor ' activeAccs{acc_i}]);
    %set(gcf,'PositionMode','manual','Units','centimeters','Position',[5 5 50 200]);
    set(gcf,'PositionMode','manual','Units','normalized','outerposition',[0 0 1 1]);

    % distr of signed distances before calibration
    axbc = subplot(3,2,1);
    title('distribution of distances to a centered sphere (R=9.807) before calibration',...
        'Fontsize',16,'FontWeight','bold');
    plotNprintDistrb(FID,dOrientList{1,acc_i}.bc,false);
    
    % distr of signed distances after calibration
    axac = subplot(3,2,3);
    title('distribution of distances to a centered sphere (R=9.807) after calibration',...
        'Fontsize',16,'FontWeight','bold');
    plotNprintDistrb(FID,dOrientList{1,acc_i}.ac,true,axbc,axac);

    % close file
    if FID ~= 1
        fclose(FID);
    end
    
    %% plot fitting
    subplot(3,2,5);
    title('Fitting ellipsoid before calibration','Fontsize',16,'FontWeight','bold');
    plotFittingEllipse([0 0 0]',[9.807 9.807 9.807]',eye(3,3),sensMeasCell.bc{1,acc_i});

    subplot(3,2,6);
    title('Fitting ellipsoid after calibration','Fontsize',16,'FontWeight','bold');
    plotFittingEllipse([0 0 0]',[9.807 9.807 9.807]',eye(3,3),sensMeasCell.ac{1,acc_i});
    
    %% Plot norm uniformity improvement
    subplot(3,2,2);
    title('Norm of sensor measurements before calibration','Fontsize',16,'FontWeight','bold');
    for iter = 1:subSamplingSize
        normMeas(iter) = norm(sensMeasCell.bc{1,acc_i}(iter,:));
    end
    hold on;
    grid ON;
    plot(time,normMeas,'r','lineWidth',2.0);
    xlabel('Time (sec)','Fontsize',12);
    ylabel('Acc norm (m/s^2)','Fontsize',12);
    hold off;
    
    subplot(3,2,4);
    title('Norm of sensor measurements after calibration','Fontsize',16,'FontWeight','bold');
    for iter = 1:subSamplingSize
        normMeas(iter) = norm(sensMeasCell.ac{1,acc_i}(iter,:));
    end
    hold on;
    grid ON;
    plot(time,normMeas,'r','lineWidth',2.0);
    xlabel('Time (sec)','Fontsize',12);
    ylabel('Acc norm (m/s^2)','Fontsize',12);
    hold off;
    set(gca,'FontSize',12);
    
    if logTest
        set(gcf,'PaperPositionMode','auto');
        print('-dpng','-r300','-opengl',[figsFolder '/figs_' activeAccs{acc_i}]);
    end
end

%% Plot joint trajectories
figure('Name','chain joint positions q');
set(gcf,'PositionMode','manual','Units','normalized','outerposition',[0 0 1 1]);
title('chain joint positions q','Fontsize',16,'FontWeight','bold');
hold on
myColors = {'b','g','r','c','m','y'};
colorIdx = 1;
eval(['qsRad = data.bc.parsedParams.qsRad_' jointsToCalibrate.parts{1} '_state;']); qsRad = qsRad';
for qIdx = 1:size(qsRad,2)
    plot(time,qsRad(:,qIdx)*180/pi,myColors{colorIdx},'lineWidth',2.0);
    colorIdx = colorIdx+1;
end
hold off
grid ON;
xlabel('Time (sec)','Fontsize',12);
ylabel('Joints positions (degrees)','Fontsize',12);
legend('Location','BestOutside',jointsToCalibrate.partJoints{1});
set(gca,'FontSize',12);

if logTest
    set(gcf,'PaperPositionMode','auto');
    print('-dpng','-r300','-opengl',[figsFolder '/jointTraject']);
end

%% Log all data
if logTest
    save([dataFolder '/log_' num2str(iterator) '_All.mat']);
end 

