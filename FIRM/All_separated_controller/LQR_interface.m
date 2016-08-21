classdef LQR_interface < separated_controller_interface
    %LQR_class encapsulates the LQR controller.
    
    properties
        Feedback_gains; % feedback gain (either a single feedback gain/ periodic sequence/ or a finite number of gains  depending on the derived class)
        lnr_pts; % linearization points (either a single point/ periodic sequence/ or a finite number of pointa  depending on the derived class)
        Final_state_cost;
        state_cost;
        control_cost;
        valid_lnr_domain
    end
    
    methods (Abstract)
        obj = generate_feedback_control(obj, varargin)
    end
    
end
