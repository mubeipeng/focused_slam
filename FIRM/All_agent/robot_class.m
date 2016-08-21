classdef robot_class
    % This class encapsulates the "robot" concept in FIRM
    % (Feedback-controller-based Information-state RoadMap).
    properties
        id; %robot ID (unique to each robot -- only needed if dealing with a multi-robot problem)
        ss; %state space
        mm; %motion model
        om; %observation model
        belief; %current state
        neighbor_ids; %communication graph
    end
    
    methods
        function obj = robot_class( id_inp, state_name, mm_name, om_name, belief_name, Map)
            obj.id = id_inp;
            obj.ss = feval(state_name);
            obj.mm = feval(str2func(mm_name) );
            obj.om = feval(str2func(om_name), Map);
            obj.belief = feval(str2func(belief_name), obj.ss);
            obj.neighbor_ids = [];
        end
    end
end