function value = bellShapeFunc(points, bellCenter, bellWidth, bellSlope)
% This function evaluates a bellShaped curve at the given input point

% input sanity check
if size(points, 1) ~= size(bellCenter, 1)
    error('bellShapeFunc: The size of bell center and input points does not match')
end
if isscalar(bellWidth)
    bellWidth = ones(size(bellCenter))*bellWidth;
elseif size(bellWidth, 1) ~= size(bellCenter, 1)
    error('bellShapeFunc: The size of bell center and bell width does not match')
end
if isscalar(bellSlope)
    bellSlope = ones(size(bellCenter))*bellSlope;
elseif size(bellSlope, 1) ~= size(bellCenter, 1)
    error('bellShapeFunc: The size of bell slope and bell width does not match')
end
    
%%% Example 1
%%% Draw a 1D bell shaped curve
% figure; hold on
% domain{1} = 1:0.1:10;
% x = domain{1};
% bellCenter = 4.5;
% bellWidth = 5;
% bellSlope = 5;
% val = bellShapeFunc(x, bellCenter, bellWidth, bellSlope);
% plot (x, val)

%%% Example 2
%%% Draw a 2D symmetric bell shaped curve
% figure; hold on
% bellCenter = [4.5; 0];
% bellWidth = 5;
% bellSlope = 5;
% domain{1} = 1:0.1:10;
% domain{2} = -3:0.1:3;
% [x1,x2] = ndgrid(domain{1}, domain{2});
% val = zeros(size(x1)); % pre-allocation
% for i = 1:size(x1,1)
%     for j = 1:size(x1, 2)
%         point = [x1(i,j) ; x2(i,j)];
%         val(i,j) = bellShapeFunc(point, bellCenter, bellWidth, bellSlope);
%     end
% end
% mesh(x1,x2, val)


%%% Draw a 2D non-symmetric bell shaped curve
% figure; hold on
% bellCenter = [4.5; 0];
% bellWidth = [5 ; 2];
% bellSlope = [10;1];
% domain{1} = 1:0.1:10;
% domain{2} = -3:0.1:3;
% [x1,x2] = ndgrid(domain{1}, domain{2});
% val = zeros(size(x1)); % pre-allocation
% for i = 1:size(x1,1)
%     for j = 1:size(x1, 2)
%         point = [x1(i,j) ; x2(i,j)];
%         val(i,j) = bellShapeFunc(point, bellCenter, bellWidth, bellSlope);
%     end
% end
% mesh(x1,x2, val)

for d = 1:length(bellCenter) % dimension
    bellStart(d) = bellCenter(d) - bellWidth(d)/2;
    bellEnd(d) = bellCenter(d) + bellWidth(d)/2;
    y(d,:)=dsigmf(points(d,:),[bellSlope(d)   bellStart(d)   bellSlope(d)  bellEnd(d)]);
end
value = prod(y,1);

for d = 1:length(bellCenter) % dimension
    bellStart(d) = bellCenter(d) - bellWidth(d)/2;
    bellEnd(d) = bellCenter(d) + bellWidth(d)/2;
    y_max(d,1)=dsigmf(bellCenter(d), [bellSlope(d)   bellStart(d)   bellSlope(d)   bellEnd(d)]);
end
value_max = prod(y_max,1);

value = value/value_max;  % This is to make sure the maximum of the function is one

end

