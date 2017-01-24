classdef MotionSequencer < handle
    % Joint controller reaching each joint position set of a sequence
    %   This class processes a sequence of position sets, each position set 
    %   defining the set of joint positions to reach in a synchronous way.
    %   The class methods produce inputs to the remote control board
    %   remapper moveToPos method.
    
    properties(SetAccess = protected, GetAccess = public)
        ctrlApp;
        robotName;
        sequences;
        logStart; logStop;
        ctrlBoardRemap;
        partList = {};
    end
    
    methods
        function obj = MotionSequencer(ctrlApp,robotName,sequences,logStart,logStop)
            % Init class parameters
            obj.ctrlApp = ctrlApp;
            obj.robotName = robotName;
            obj.sequences = sequences;
            obj.logStart = logStart;
            obj.logStop = logStop;
            
            % create ctrl board remapper
            obj.ctrlBoardRemap = RemoteControlBoardRemapper(robotName,ctrlApp);
        end
        
        function run(obj)
            % process each sequence
            for seqIdx = 1:size(obj.sequences,1)
                % get next sequence to run
                sequence = obj.sequences{seqIdx};
                
                % open ctrl board remapper driver
                obj.ctrlBoardRemap.open(sequence.part);
                
                for posIdx = 1:size(sequence.pos,1)
                    % get next position, velocity and acquire flag from the
                    % sequence. Get concatenated matrices for all parts
                    pos = cell2mat(sequence.pos(posIdx,:));
                    vel = cell2mat(sequence.vel(posIdx,:));
                    acquire = cell2mat(sequence.acquire(posIdx,:));
                    
                    % Stop logging of parts for which 'acquire' flag is off
                    % Start logging of parts for which 'acquire' flag is on
                    %obj.logStop(sequence.part(~acquire));
                    %obj.logStart(sequence.part(acquire));
                    
                    % run the sequencer step
                    waitMotionDone = true; timeout = 120; % in seconds
                    if ~obj.ctrlBoardRemap.setEncoders(pos,'refVel',vel,waitMotionDone,timeout)
                        error('Waiting for motion done timeout!');
                    end
                end
                % Stop logging of last step
                %obj.logStop(sequence.part);
            end
        end
    end
    
end
