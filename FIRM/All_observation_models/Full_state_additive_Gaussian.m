classdef Full_state_additive_Gaussian < ObservationModel_interface
    
    properties
        obsDim;
        obsNoiseDim; % observation noise dimension. In some other observation models the noise dimension may be different from the observation dimension.
        R; % observation noise covariance
        zeroNoise;
        plot_handle;
    end
    
    methods
        function obj = Full_state_additive_Gaussian(state)
            obj.obsDim = state.dim;
            obj.obsNoiseDim = state.dim; % observation noise dimension. In some other observation models the noise dimension may be different from the observation dimension.
            obj.R = eye(state.dim)*0.0001; % observation noise covariance
            obj.zeroNoise = zeros(state.dim,1);
        end
        function handle_of_plot = draw(obj)
            handle_of_plot = [];
        end
        function obj = delete_plot(obj)
        end
        function z = h_func(obj,x,v)
            z = x+v;
        end
        function H = dh_dx_func(obj,x,v) %#ok<INUSD>
            H = eye(obj.obsDim);
        end
        function M = dh_dv_func(obj,x,v) %#ok<INUSD>
            M = eye(obj.obsNoiseDim);
        end
        function V = generate_observation_noise(obj,x) %#ok<INUSD>
            noise=randn(obj.obsDim,1);
            V = noise.*diag((obj.R).^(1/2));
        end
        function R = noise_covariance(obj,x) %#ok<INUSD>
            R = obj.R;
        end
        function innov = compute_innovation(obj,Xprd,Zg)
            innov = Zg - Xprd;
        end
    end
    
end