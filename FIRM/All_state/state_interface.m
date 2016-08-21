classdef state_interface
    % This class encapsulates the state of the system.
    properties (Abstract, Constant)
        dim; % state dimension
    end
    properties (Abstract)
%         dim; % state dimension
        val; % value of the state
        plot_handle; % handle for the "drawings" associated with the state
        text_handle; % handle for the "displayed text" associated with the state
    end
    
    
    methods
        function obj = state_interface(varargin) % constructor function
            if (nargin == 0 || isempty(varargin{1}))
                obj.val = []; % if no X is inputted
            else
                X = varargin{1};
                if isa(X,'state')
                    obj = X;
                elseif all(size(X,2) == 1)
                    obj.val = X;
                elseif all(size(X,1) == 1)
                    obj.val = X';
                else
                    error('The state dimension is not correct')
                end
            end
        end
        function obj = apply_differentiable_constraints(obj)
            % normally this function is empty. If the state has any
            % differentiable constraints (e.g., quaternion norm is one),
            % this function needs to be written specifically in the child class.
        end
        function J = get_differentiable_constraints_jacobian(obj)
            % normally this function is empty. If the state has any
            % differentiable constraints (e.g., quaternion norm is one),
            % this function needs to be written specifically in the child class.
            J = nan;
        end
        function distance_for_control = compute_distance_for_control(obj,x2)
            distance_for_control = obj.signed_element_wise_dist(x2);
        end
    end
    
     methods (Static)
        function origin = SpaceOrigin()
            origin = zeros(state.dim,1); % note that the "state" class will be generated on the fly (using TypeDef) function.
        end
    end
    
    methods (Abstract)
        signed_dist_vector = signed_element_wise_dist(obj,x2) % this function returns the "Signed element-wise distnace" between two states x1 and x2
        obj = draw(obj, varargin) % draw state
        obj = delete_plot(obj,varargin) % delete state drawings
        neighb_plot_handle = draw_neighborhood(obj, scale)
        YesNo = is_constraint_violated(obj)
        old_limits = zoom_in(obj,zoom_ratio)
        sampled_state = sample_a_valid_state(obj)
    end
    
    
end