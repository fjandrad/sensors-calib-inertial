classdef JointMotorCoupling < handle
    %This class hold the coupling info for a set of joints/motors
    %   - coupling.T : the coupling matrix 3x3 or just the integer 1
    %   - coupling.coupledJoints : ordered list of coupled joint names
    %   - coupling.coupledMotors : ordered list of coupled motor names
    
    properties(GetAccess=public, SetAccess=protected)
        label@char = ''; % unique id of the coupling
        T = 0;           % coupling matrix
        coupledJoints = {}; % cell array of strings
        coupledMotors = {}; % cell array of motor names
        gearboxRatios = [];
        part = '';       % parent part of the coupled joints/motors
    end
    
    methods
        function obj = JointMotorCoupling(T, cpldJoints, cpldMotors, ratios, part)
            obj.T = T;
            obj.coupledJoints = cpldJoints;
            obj.coupledMotors = cpldMotors;
            obj.gearboxRatios = ratios;
            obj.part = part;
            obj.label = [cpldJoints{:}];
        end
    end
    
end