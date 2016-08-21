classdef agent_class
    % This class encapsulates the "agent" concept in FIRM
    % (Feedback-controller-based Information-state RoadMap).
    properties
        id; %agent ID (unique to each agent -- only needed if dealing with a multi-robot problem)
        mm; %motion model
        om; %observation model
        belief; %current state
        neighbor_ids; %communication graph
        ss; %state space
    end
    
    methods
        function obj = agent_class( id_inp, state_name, mm_name, om_name, belief_name )
            obj.id = id_inp;
            obj.ss = feval(state_name,[],1);
            obj.mm = feval(str2func(mm_name), obj.ss);
            obj.om = feval(str2func(om_name), obj.ss);
            obj.belief = feval(str2func(belief_name), obj.ss);
            obj.neighbor_ids = [];
        end
    end
end