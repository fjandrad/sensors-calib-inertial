classdef LowlevTauCtrlCalibrator < Calibrator
    %LowlevTauCtrlCalibrator Holds all methods for low level joint torque control calibration
    %   'calibrateSensors()' is the main procedure for calibrating the
    %   low level parameters. These parameters include the PWM voltage to
    %   torque rate, the viscuous and Coulomb friction parameters.
    
    properties(Constant=true, Access=protected)
        singletonObj = LowlevTauCtrlCalibrator();
    end
    
    properties(Constant=true, Access=public)
        task@char = 'LowlevTauCtrlCalibrator';
        
        initSection@char = 'lowLevelTauCtrlCalib';
        
        calibedSensorType@char = 'LLTctrl';
        
        stateStart@int       = 1
        stateAcqFriction@int = 2;
        stateFitFriction@int = 3;
        stateAcqKtau@int     = 4;
        stateFitKtau@int     = 5;
        stateNextGroup@int   = 6;
        stateEnd@int         = 7;
        
        statesNextState = {...
            'restart'           ,'proceed'           ,'skip'            ,'end'       ;...
            []                  ,obj.stateAcqFriction,[]                ,[]          ;...  % stateStart
            obj.stateAcqFriction,obj.stateFitFriction,obj.stateNextGroup,obj.stateEnd;...  % stateAcqFriction
            obj.stateAcqFriction,obj.stateAcqKtau    ,obj.stateNextGroup,obj.stateEnd;...  % stateFitFriction
            obj.stateAcqKtau    ,obj.stateFitKtau    ,obj.stateNextGroup,obj.stateEnd;...  % stateAcqKtau
            obj.stateAcqKtau    ,obj.stateNextGroup  ,obj.stateNextGroup,obj.stateEnd;...  % stateFitKtau
            []                  ,obj.stateAcqFriction,[]                ,obj.stateEnd};    % stateNextGroup
        
        statesCurrentProcessing = {...
            'currentProc'   ,'transition'         ,;...
            @obj.start      ,@(varargin) 'proceed',;... % stateStart
            @obj.acqFriction,@promptUser          ,;... % stateAcqFriction
            @obj.fitFriction,@promptUser          ,;... % stateFitFriction
            @obj.acqKtau    ,@promptUser          ,;... % stateAcqKtau
            @obj.fitKtau    ,@promptUser          ,;... % stateFitKtau
            @(varargin) []  ,@nextGroupTrans      ,};   % stateNextGroup
        
        statesTransitionProcessing = {...
            'restartProc'          ,'proceedProc'        ,'skipProc'             ,'endProc'              ;...
            @(varargin) []         ,@obj.stateAcqFriction,@(varargin) []         ,@(varargin) []         ;...  % stateStart
            @obj.discardAcqFriction,@obj.savePlotCallback,@obj.discardAcqFriction,@obj.discardAcqFriction;...  % stateAcqFriction
            @obj.discardAcqFriction,@obj.savePlotCallback,@obj.discardAcqFriction,@obj.discardAcqFriction;...  % stateFitFriction
            @obj.discardAcqKtau    ,@obj.savePlotCallback,@obj.discardAcqKtau    ,@obj.discardAcqKtau    ;...  % stateAcqKtau
            @obj.discardAcqKtau    ,@obj.savePlotCallback,@obj.discardAcqKtau    ,@obj.discardAcqKtau    ;...  % stateFitKtau
            @(varargin) []         ,@obj.stateAcqFriction,@(varargin) []         ,@(varargin) []         };    % stateNextGroup
        
        stateArray = defStatesFromDesc([statesNextState statesCurrentProcessing statesTransitionProcessing]);
    end
    
    properties(Access=protected)
        init@struct;
        model@RobotModel;
        lastAcqSensorDataAccessorMap@containers.Map;
        jointMotorCouplings = {};
        timeStart = 0;
        timeStop = 0;
        subSamplingSize = 0;
        filtParams@struct;
        savePlotCallback@function_handle;
        
        % Main state of the state machine:
        % - 'state.current' gives the current state indexing the 'stateArray'
        % - 'state.transition' hold the transition to the next state
        %    through the field values 'restart', 'proceed', 'skip', 'end'.
        % - 'state.currentJMcplgIdx' indexes the current joint/motor group to
        %    process.
        state@struct = struct('current',obj.stateStart,'transition',[],'currentJMcplgIdx',0);
    end
    
    methods(Access=protected)
        function obj = LowlevTauCtrlCalibrator()
        end
        
        % state machine methods
        transition = promptUser(obj);
        
        transition = nextGroupTrans(obj);
        
        start(obj);
        
        acquire(obj,frictionOrKtau);
        
        fit(obj,frictionOrKtau);
        
        function acqFriction(obj), obj.acquire('friction'); end
        
        function acqKtau(obj), obj.acquire('ktau'); end
        
        function fitFriction(obj), obj.fit('friction'); end
        
        function fitKtau(obj), obj.fit('ktau'); end
        
        function discardAcqFriction(obj), []; end
        
        function discardAcqKtau(obj), []; end
        
        plotTrainingData(obj,path,sensors,parts,model,taskSpec);
        
        plotModel(obj,frictionOrKtau,data,calibList);
    end
    
    methods(Static=true, Access=public)
        % this function should initialize properly the shared attribute
        % 'singletonObj' and returns the handler to the caller
        function theInstance = instance()
            theInstance = LowlevTauCtrlCalibrator.singletonObj;
        end
    end
    
    methods(Access=public)
        run(obj,init,model,lastAcqSensorDataAccessorMap);
    end
    
    methods(Static=true, Access=protected)
        calibrateSensors(...
            dataPath,~,measedSensorList,measedPartsList,...
            model,taskSpecificParams);
        
        % Each line of 'statesDesc' is converted to a struct which fields
        % are listed in the first line of 'statesDesc'.
        stateStructList = defStatesFromDesc(statesDesc);
        
        % Parameters used for loading and parsing the acquired data
        dataLoadingParams = buildDataLoadingParams(...
            model,measedSensorList,measedPartsList,...
            calibedJointOrderedList);
        
        % Save plot with some context parameters
        savePlot(figuresHandler,savePlot,exportPlot,dataPath);
    end
    
end
