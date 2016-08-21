classdef OneD_linear_robot_state < state_interface
    % This class encapsulates the state of a planar robot, described by its 2D location and heading angle.
    
    properties
        dim; % state dimension
        val; % value of the state
        plot_handle=[]; % handle for the "drawings" associated with the state
        head_handle=[];
        tria_handle=[];
        text_handle=[]; % handle for the "displayed text" associated with the state
    end
    
    methods
        function obj = OneD_linear_robot_state(varargin)
            obj = obj@state_interface(varargin{:});
            obj.dim =  1;
        end
        function signed_dist_vector = signed_element_wise_dist(obj,x2) % this function returns the "Signed element-wise distnace" between two states x1 and x2
            x1 = obj.val; % retrieve the value of the state vector
            if isa(x2,'OneD_linear_robot_state'), x2=x2.val; end % retrieve the value of the state vector  % Note that the format (spacing and words) of this function must remain the same (as it is used in the typeDef function)
            signed_dist_vector = x1 - x2;
        end
        
        function obj = draw(obj, varargin)
            % default values
            robot_color = {'r'};
            head_shape = 'o';
            head_size = 6;
            robot_text = {};
            font_size = 15;
            text_color  = 'b';
            for i = 1 : 2 : length(varargin)
                switch lower(varargin{i})
                    case lower('color')
                        robot_color = varargin{i+1};
                    case lower('HeadShape')
                        head_shape = varargin{i+1};
                    case lower('HeadSize')
                        head_size = varargin{i+1};
                    case lower('text')
                        robot_text = varargin{i+1};
                    case lower('fontsize')
                        font_size = varargin{i+1};
                    case lower('textcolor')
                        text_color = varargin{i+1};
                    otherwise
                        error('This property does not exist.')
                end
            end
            tmp=get(gca,'NextPlot');
            hold on
            x = obj.val;
            obj.head_handle = [obj.head_handle,plot(x,0,'Marker',head_shape,'MarkerSize',head_size,'MarkerEdgeColor',robot_color,'MarkerFaceColor',robot_color)];
            % write the text next to the robot
            if ~isempty(robot_text)
                text_pos= [x,1]; % we shift the text a little bit away from the node.
                text_pos(1) = text_pos(1) - 0.45; % for some reason MATLAB shifts the starting point of the text a little bit to the right. So, here we return it back.
                obj.text_handle = [obj.text_handle,text(text_pos(1),text_pos(2),robot_text,'fontsize',font_size,'color',text_color)];
            end
            set(gca, 'NextPlot', tmp);
        end
        function obj = delete_plot(obj,varargin)
            if isempty(varargin)
                try % Avoid errors if the graphic object has already been deleted
                    delete(obj.head_handle);
                    obj.head_handle = [];
                end
                try % Avoid errors if the graphic object has already been deleted
                    delete(obj.text_handle);
                    obj.text_handle = [];
                end
            else
                for i = 1 : length(varargin)
                    switch varargin{i}
                        case 'head'
                            try % Avoid errors if the graphic object has already been deleted
                                delete(obj.head_handle)
                                obj.head_handle = [];
                            end
                        case 'text'
                            try % Avoid errors if the graphic object has already been deleted
                                delete(obj.text_handle);
                                obj.text_handle = [];
                            end
                        otherwise
                            error('There is no such a handle to delete')
                    end
                end
            end
        end
        function neighb_plot_handle = draw_neighborhood(obj, scale)
            tmp_th = 0:0.1:2*pi;
            neighb_plot_handle = [];
                x = obj.val;
                y = 0;
                tmp_h = plot(scale*cos(tmp_th) + x , scale*sin(tmp_th) + y);
                neighb_plot_handle = [neighb_plot_handle , tmp_h];
        end
        function YesNo = is_constraint_violated(obj)
            YesNo = 0; % initialization
            obst = obstacles_class.obst; % for abbreviation
            x = obj.val;
            for i_ob = 1:length(obst)
                if any(inpolygon(x(1,:),x(2,:),obst{i_ob}(:,1),obst{i_ob}(:,2)))
                    YesNo =1;
                    return
                end
            end
        end
        function old_limits = zoom_in(obj,zoom_ratio)
            old_xlim = xlim;
            old_ylim = ylim;
            old_limits = [old_xlim,old_ylim];
            %             new_center = obj.joint_2D_locations(:,end);
            %             new_x_length = (old_xlim(2)-old_xlim(1))/zoom_ratio;
            %             new_y_length = (old_ylim(2)-old_ylim(1))/zoom_ratio;
            %             new_xlim = new_center(1) + [-new_x_length,new_x_length]/2;
            %             new_ylim = new_center(2) + [-new_y_length,new_y_length]/2;
            %             axis([new_xlim,new_ylim])
        end
    end
    
    methods
        function sampled_state = sample_a_valid_state(obj)
            disp('we have to check the validity also')
            robots_val = [ ];
            
            [x,~]=ginput(1);
            y = 0;
                if isempty(x)
                    sampled_state = [];
                    return
                else
                    robots_val = [robots_val ; [x ; y ] ];
                end
                
                sampled_state = feval(class(obj),robots_val);
                
                if sampled_state.is_constraint_violated();
                    disp('selected sample violates the constraints')
                    sampled_state = obj.sample_a_valid_state();
                end
                
        end
    end
end
