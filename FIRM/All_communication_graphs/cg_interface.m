classdef cg_interface
    % This class encapsulates the cg of the system.
    
    properties (Abstract)
        mat; %CG matrix (symmetric). Element ij == 1 iff communication between agent i and agent j occurs.
    end
    
    methods (Abstract)
        obj = sampleCg(obj) % this function returns a sampled CG based on the CG policy
    end
end