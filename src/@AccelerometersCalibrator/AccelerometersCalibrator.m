classdef AccelerometersCalibrator
    %AccelerometersCalibrator Holds all methods for calibrating the accelerometers.
    %   'calibrateSensors()' is the main procedure.
    
    methods(Static = true, Access = public)
        calibrateSensors(...
            calibrationMap,...
            taskSpecificParams,dataPath,...
            measedSensorList,measedPartsList);
    end
    
end
