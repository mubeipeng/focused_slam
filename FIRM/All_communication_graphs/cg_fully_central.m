classdef cg_fully_central < cg_interface
    % This class encapsulates the state as well as a communication graph
    
    properties
        mat
    end
    
    methods
        function obj = cg_fully_central(num_robots)
            obj = obj.sampleCg(num_robots);
        end
        
        function obj = sampleCg(obj, num_robots)
            obj.mat = ones(num_robots, num_robots);
        end
    end
end










