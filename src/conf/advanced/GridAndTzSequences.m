%% Home single step sequence

% For limbs calibration
homeCalibLimbs.labels = {...
    'ctrl','ctrl','ctrl','ctrl','ctrl','ctrl';...
    'pos','pos','pos','pos','pos','pos';
    'left_arm','right_arm','left_leg','right_leg','torso','head'};
homeCalibLimbs.val = {...
    [10 45 0 60 0 0 0],...
    [10 45 0 60 0 0 0],...
    [0 10 0 0 0 0],...
    [0 10 0 0 0 0],...
    [0 0 0],...
    [0 0 0]};

% For torso calibration
homeCalibTorso = homeCalibLimbs;
homeCalibTorso.val = {...
    [-30 30 -30 20 0 0 0],...
    [-30 30 -30 20 0 0 0],...
    [0 10 0 0 0 0],...
    [0 10 0 0 0 0],...
    [0 0 0],...
    [0 0 0]};

%% Motion sequences
% (a single sequence is intended to move all defined parts synchronously,
% motions from 2 different sequences should be run asynchronously)
% each calibPart should be caibrated within a single sequence.

% define tables for each limb
%% Grid sequence
% common parameters
gridBuilder = GridGeneratorWOsuspend();
acqVel = 5; transVel = 5;

left_leg_GridParams.labels = {...
    'ctrl'               ,'ctrl'          ,'meas'     ,'meas'      ,'meas'     ,'meas'      ,'meas'     ,'meas'     ,'meas'      ,'meas'      ,'meas'      ;...
    'pos'                ,'vel'           ,'joint'    ,'joint'     ,'joint'    ,'joint'     ,'joint'    ,'joint'    ,'ftsMulti'       ,'ftsMulti'       ,'fts'       ;...
    'left_leg'          ,'left_leg'     ,'left_arm' ,'right_arm' ,'left_leg' ,'right_leg' ,'torso'    ,'head'       ,'left_leg'  ,'left_foot','left_arm'};


gridParams = {...
    'joint'     ,'qmin','qmax','nbInterv';...
    'l_hip_pitch', -30   , 76   , 6        ;...
    'l_hip_roll' ,6   , 76   , 6        };

left_leg_GridParams.val = SensorDataAcquisition.setValFromGrid(...
    gridBuilder,gridParams,acqVel,transVel,left_leg_GridParams.labels);

right_leg_GridParams.labels = {...
    'ctrl'               ,'ctrl'          ,'meas'     ,'meas'      ,'meas'     ,'meas'      ,'meas'     ,'meas'     ,'meas'      ,'meas'      ,'meas'      ;...
    'pos'                ,'vel'           ,'joint'    ,'joint'     ,'joint'    ,'joint'     ,'joint'    ,'joint'    ,'ftsMulti'       ,'ftsMulti'       ,'fts'       ;...
    'right_leg'          ,'right_leg'     ,'left_arm' ,'right_arm' ,'left_leg' ,'right_leg' ,'torso'    ,'head'     ,'right_leg' ,'right_foot','right_arm'};



right_leg_GridParams.val = left_leg_GridParams.val;

%% tz sequence
left_leg_tzParams.labels = {...
    'ctrl'               ,'ctrl'          ,'meas'     ,'meas'      ,'meas'     ,'meas'      ,'meas'     ,'meas'     ,'meas'      ,'meas'      ,'meas'      ;...
    'pos'                ,'vel'           ,'joint'    ,'joint'     ,'joint'    ,'joint'     ,'joint'    ,'joint'    ,'ftsMulti'       ,'ftsMulti'       ,'fts'       ;...
    'left_leg'          ,'left_leg'     ,'left_arm' ,'right_arm' ,'left_leg' ,'right_leg' ,'torso'    ,'head'       ,'left_leg'  ,'left_foot','left_arm'};
left_leg_tzParams.val = {...
    [ 90  50  0  -90  0  0],repmat(5,[1 6]),true      ,true      ,true      ,true      ,true      ,true      ,true      ,true      ,true      ;...    
    [ 90  50  -70  -90  0  0],repmat(5,[1 6]),true      ,true      ,true      ,true      ,true      ,true      ,true     ,true      ,true          ;...    
    [ 90  50  70  -90  0  0],repmat(5,[1 6]),true      ,true      ,true      ,true      ,true      ,true      ,true      ,true      ,true           ;...
    [ 90  50  0  -90  0  0],repmat(5,[1 6]),true      ,true      ,true      ,true      ,true      ,true      ,true      ,true      ,true            };    
   
right_leg_tzParams.labels = {...
    'ctrl'               ,'ctrl'          ,'meas'     ,'meas'      ,'meas'     ,'meas'      ,'meas'     ,'meas'     ,'meas'      ,'meas'      ,'meas'      ;...
    'pos'                ,'vel'           ,'joint'    ,'joint'     ,'joint'    ,'joint'     ,'joint'    ,'joint'    ,'ftsMulti'       ,'ftsMulti'       ,'fts'       ;...
    'right_leg'          ,'right_leg'     ,'left_arm' ,'right_arm' ,'left_leg' ,'right_leg' ,'torso'    ,'head'     ,'right_leg' ,'right_foot','right_arm'};

right_leg_tzParams.val = left_leg_tzParams.val;



% define sequences for limbs {1} and torso {2} calibration
seqHomeParams{1} = homeCalibLimbs;
seqHomeParams{2} = homeCalibLimbs;
seqEndParams     = homeCalibLimbs;

% Map parts to sequences and params
selector.calibedParts = {...
    'left_leg','right_leg',...
    'left_leg','right_leg'
    };
selector.calibedSensors = {...
    {'fts'},{'fts'},...
    {'fts'},{'fts'}
    };
selector.setIdx  = {1,1,2,2}; % max index must not exceed max index of seqHomePArams
selector.seqParams = {...
    left_leg_GridParams,right_leg_GridParams,...
    left_leg_tzParams,right_leg_tzParams
    };
