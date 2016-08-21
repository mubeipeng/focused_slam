classdef Landmarks_Range_bearing < ObservationModel_interface
    properties (Constant) % Note that you cannot change the order of the definition of properties in this class due to its structure (due to dependency between properties.)
        tmp_prop = Landmarks_Range_bearing.costant_property_constructor();  % I use this technique to initialize the costant properties in run-time. If I can find a better way to do it, I will update it, as it seems a little bit strange.
        eta = [0.2100 , 0.2100];
        sigma_b = [0.2 , 0*pi/180];
    end
    properties
        landmarks;
        obsDim;
        obsNoiseDim;
        zeroNoise;
        plot_handle;
    end
    
    methods (Static = true)
        function tmp_prop = costant_property_constructor()  % I use this technique to initialize the costant properties in run-time. If I can find a better way to do it, I will update it, as it seems a little bit strange.
            tmp_prop = [];
        end
        function Map_of_landmarks = getMap(sim)
            global par;
            LoadFileName = par.LoadFileName;
            SaveFileName = par.SaveFileName;
            Man_L = par.observation_model_parameters.interactive_OM;
            if Man_L == 0
                load(LoadFileName,'Landmarks')
                Map_of_landmarks.landmarks = Landmarks; %#ok<NODEF>
                Map_of_landmarks.obsDim = 2*size(Landmarks,2);
            else
                Map_of_landmarks = Landmarks_Range_bearing.request_landmarks(sim);
            end
            Landmarks = Map_of_landmarks.landmarks; %#ok<NASGU>
            save(SaveFileName,'Landmarks','-append') % here, we save the landmarks for the future runs.
        end
        function temporary_props = request_landmarks(sim)
            old_prop = Landmarks_Range_bearing.set_figure(sim);
            i=0;
            title({'Please mark Landmarks','Press Enter/Return when done'},'fontsize',14)
            button = 0;
            while button~=3
                i=i+1;
                [Lx_temp,Ly_temp,button]=ginput(1);
                if isempty(Lx_temp) && i<3
                    title({'You have to choose at least 3 landmarks to have an observable system'},'fontsize',14)
                    i=i-1;
                    continue
                elseif isempty(Lx_temp) && i>=3
                    break
                else
                    Lx(i)=Lx_temp; %#ok<AGROW>
                    Ly(i)=Ly_temp; %#ok<AGROW>
                    temporary_props.plot_handle(i)=plot(Lx(i),Ly(i),'kp','markerfacecolor','k','markersize',12);
                end
            end
            Landmarks=[Lx;Ly];
            temporary_props.landmarks = Landmarks;
            temporary_props.obsDim = 2*size(Landmarks,2);
            Landmarks_Range_bearing.reset_figure(old_prop);
            title([])
        end
        function old_prop = set_figure(sim) % This function sets the figure (size and other properties) to values that are needed for landmark selection or drawing.
            figure(gcf);
            old_prop{1}=get(gca,'NextPlot');hold on; % save the old "NextPlot" property and set it to "hold on" % Note that this procedure cannot be moved into the "set_figure" function.
            old_prop{2}=get(gca,'XGrid'); % save the old "XGrid" property.
            old_prop{3}=get(gca,'YGrid'); % save the old "YGrid" property.
            grid on; % set the XGrid and YGrid to "on".
            if ~isempty(sim.par.figure_position)
                set(gcf,'Position',sim.par.figure_position)
            end
            axis(sim.par.env_limits);
            set(gca,'DataAspectRatio',[1 1 1]); % makes the scaling of different axes the same. So, a circle is shown as a circle not ellipse.
        end
        function reset_figure(old_prop) % This function resets the figure properties (size and other properties), to what they were before setting them in this class.
            set(gca,'NextPlot',old_prop{1}); % reset the "NextPlot" property to what it was.
            set(gca,'XGrid',old_prop{2}); % reset  the "XGrid" property to what it was.
            set(gca,'YGrid',old_prop{3}); % reset  the "YGrid" property to what it was.
        end
    end
    
    methods
        function obj = Landmarks_Range_bearing(Map_of_landmarks)
            obj.landmarks = Map_of_landmarks.landmarks;
            obj.obsDim = Map_of_landmarks.obsDim;
            obj.obsNoiseDim = obj.obsDim;
            obj.zeroNoise = zeros(obj.obsNoiseDim,1);
        end
        function obj = draw(obj,sim) % note that the "draw" function in this class is "static". Thus, if you call it, you have to assign its output to the "plot_handle" by yourself.
            old_prop = Landmarks_Range_bearing.set_figure(sim);
            obj.plot_handle = plot(obj.landmarks(1,:),obj.landmarks(2,:),'kp','markerfacecolor','k','markersize',8);
            Landmarks_Range_bearing.reset_figure(old_prop);
        end
        function obj = delete_plot(obj)
            delete(obj.plot_handle)
            obj.plot_handle = [];
        end
        function z = h_func(obj,x,v)
            L=obj.landmarks;
            od = obj.obsDim;
            N_L=size(L,2);
            
            d=L-repmat(x(1:2),1,N_L);
            z(1:2:od-1,1) = sqrt(d(1,:).^2+d(2,:).^2)'+v(1:2:od-1,1);
            z(2:2:od  ,1) = atan2(d(2,:),d(1,:))'-x(3)'+v(2:2:od,1);
        end
        function H = dh_dx_func(obj,x,v) %#ok<INUSD>
            L = obj.landmarks;
            od = obj.obsDim;
            stDim = size(x,1);
            H=nan(od,stDim); % memory preallocation
            for j=1:size(L,2)
                dj=x(1:2)-L(:,j);
                phi_j = atan2(dj(2),dj(1));
                rj = sqrt(dj'*dj);
                
                H(2*j-1:2*j,:)=[ cos(phi_j)  ,      sin(phi_j)  ,      0
                    -sin(phi_j)/rj,    cos(phi_j)/rj,     -1 ];
                
                %                 H_debug=[dj(1)/rj        dj(2)/rj        0
                %                     -dj(2)/(rj^2)   dj(1)/(rj^2)    -1];
                %                 if any(any(H(2*j-1:2*j,:)-H_debug>1.0e-12))
                %                     error('Error in dh_dx')
                %                 end
            end
        end
        function M = dh_dv_func(obj,x,v) %#ok<INUSD>
            % Jacobian of observation wrt observation noise.
            M = eye(obj.obsDim);
        end
        function V = generate_observation_noise(obj,x)
            R = obj.noise_covariance(x);
            indep_part_of_obs_noise=randn(obj.obsDim,1);
            V = indep_part_of_obs_noise.*diag(R.^(1/2));
        end
        function R = noise_covariance(obj,x)
            od = obj.obsDim;
            L = obj.landmarks;
            eta = obj.eta; %#ok<PROP>
            sigma_b = obj.sigma_b;%#ok<PROP>
            d=repmat(x(1:2),1,size(L,2))-L;
            ranges=sqrt(d(1,:).^2+d(2,:).^2)';
            R_std(1:2:od-1)=eta(1)*ranges+sigma_b(1);%#ok<PROP>
            R_std(2:2:od)=eta(2)*ranges+sigma_b(2);%#ok<PROP>
            R=diag(R_std.^2);
        end
        function innov = compute_innovation(obj,Xprd,Zg)
            V = zeros(obj.obsNoiseDim,1);
            Zprd = obj.h_func(Xprd,V);
            innov = Zg - Zprd;
            wrong_innovs = find(innov>pi | innov<-pi);
            for jjj=1:length(wrong_innovs)
                i=wrong_innovs(jjj);
                if mod(i,2)==0 && innov(i)>pi
                    innov(i)=innov(i)-2*pi;
                elseif mod(i,2)==0 && innov(i)<-pi
                    innov(i)=innov(i)+2*pi;
                end
            end
        end
    end
    
end