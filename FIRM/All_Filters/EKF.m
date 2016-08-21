classdef EKF < kalman_filter_interface
    methods (Static = true)
        function b_next = estimate(b,U,Zg,system)
            if nargin > 4
                error('Ali: EKF does not need linearized system. Because EKF computes its own linearized system.')
            end
            % EKF computes its own linearized system. EKF linearizes
            % the system twice: once in prediction phase, and again in
            % update phase.
            lnr_pts_for_prediction.x = b.est_mean.val; % in EKF, in prediction stage, we linearize about estimation mean
            lnr_pts_for_prediction.u = U; % in EKF, we linearize about the up+dU
            lnr_pts_for_prediction.w = zeros(system.mm.wDim,1);
            lnr_sys_for_prediction = Linear_system_class(system, lnr_pts_for_prediction);
            b_prd = EKF.predict(b,U,lnr_sys_for_prediction, system);
            
            lnr_pts_for_update.x = b_prd.est_mean.val; % in EKF, in update stage, we linearize about prediction mean
            lnr_pts_for_update.u = U; % in EKF, we linearize about the up+dU
            lnr_pts_for_update.v = zeros(system.om.obsNoiseDim,1);
            lnr_sys_for_update = Linear_system_class(system, lnr_pts_for_update);
            
            b_next = EKF.update(b_prd,Zg,lnr_sys_for_update, system);
        end
        function b_prd = predict(b,U,lnr_sys, system)
            % lnr_sys is the linear or linearized system, Kalman filter is
            % designed for.
            A = lnr_sys.A;
            %B = lnr_sys.B; % not needed in this function
            G = lnr_sys.G;
            Q = lnr_sys.Q;
            % Pprd=(A-B*L)*Pest_old*(A-B*L)'+Q;  % wroooooong one
            Xest_old = b.est_mean.val;
            Pest_old = b.est_cov;
            zerow = zeros(system.mm.wDim,1);
            Xprd = system.mm.f_discrete(Xest_old,U,zerow);
            % I removed following display, because it comes up there too
            % much times!
            %disp('AliFW: for LKF, it seems more correct to use linear prediction step.')
            %Xprd = A*Xest_old+B*U; % This line is veryyyyyyyyyy
            %wroooooooooooooooooooooooooong. Because, this equation only
            %holds for state error NOT the state itself.
            Pprd = A*Pest_old*A'+G*Q*G';
            Xprd_state = feval(class(system.ss), Xprd);
            b_prd = feval(class(system.belief), Xprd_state, Pprd);
        end
        
        function b = update(b_prd,Zg,lnr_sys, system)
            % lnr_sys is the linear or linearized system, Kalman filter is
            % designed for.
            H = lnr_sys.H;
            R = lnr_sys.R;
            Pprd = b_prd.est_cov;
            % I think in following line changing "inv" to "pinv" fixes possible
            
            % numerical issues
            
            KG = (Pprd*H')/(H*Pprd*H'+R); %KG is the "Kalman Gain"
            Xprd = b_prd.est_mean.val;
            innov = system.om.compute_innovation(Xprd,Zg);
            Xest_next = Xprd+KG*innov;
            Pest_next = Pprd-KG*H*Pprd;
            Xnext_state = feval(class(system.ss), Xest_next);
            b = feval(class(system.belief),Xnext_state,Pest_next);
            bout = b.apply_differentiable_constraints(); % e.g., quaternion norm has to be one
            b = bout;
            
        end
    end
end