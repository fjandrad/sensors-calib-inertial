if loadJointPos == true
    %% Select the joints to calibrate through the respective indexes in the port data
    %
    jointsIdxes.left_arm = '1:4';
    jointsIdxes.right_arm = '1:4';
    jointsIdxes.left_leg = '1:6';
    jointsIdxes.right_leg = '1:6';
    jointsIdxes.torso = '1:3';
    jointsIdxes.head = '1:3';
    
    %% Define parameters for all joints (calibrated or not)
    %
    
    % Optimization starting point
    jointsDq0.left_arm = [0 0 0 0];
    jointsDq0.right_arm = [0 0 0 0];
    jointsDq0.left_leg = [0 0 0 0 0 0];
    jointsDq0.right_leg = [0 0 0 0 0 0];
    jointsDq0.torso = [0 0 0];
    jointsDq0.head = [0 0 0];
else
    jointsIdxes = struct([]);
    jointsDq0 = struct([]);
end

%% some sensors are de-activated because of faulty behaviour, bad calibration or wrong frame definition
mtbSensorAct.left_arm(1:7) = {true};
mtbSensorAct.left_arm([3 5:7]) = {false};

mtbSensorAct.right_arm(1:7) = {true};
mtbSensorAct.right_arm([1 3 5:7]) = {false};

mtbSensorAct.left_leg(1:13) = {true};
mtbSensorAct.left_leg(12:13) = {false};

mtbSensorAct.right_leg(1:13) = {true};
%mtbSensorAct.right_leg([6 7 12:13]) = {false};

mtbSensorAct.torso(1:4) = {false};

mtbSensorAct.head(1) = {true};
