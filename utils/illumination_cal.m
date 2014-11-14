
%% Room configuration
length = 5;
width = 5;
height = 3;

%% LED chips configuration
half_intensity_angle = pi/3;
lambert_index = -1/log2(cos(half_intensity_angle));
I0 = 9.5;
power = 63e-3;

%% LEDs scenario configuration
%% configuration 1
% position_matrix_x = zeros(31,31);
% position_matrix_y = zeros(31,31);
% for i = 1:31
%     position_matrix_x(i,:) = linspace(0.1,4.9,31);
% end
% for j = 1:31
%     position_matrix_y(:,j) = linspace(0.1,4.9,31);
% end

%% configuration 2
position_matrix_x1 = zeros(15,15);
position_matrix_y1 = zeros(15,15);
for i = 1:15
    position_matrix_x1(i,:) = linspace(0.75,1.75,15);
end
for j = 1:15
    position_matrix_y1(:,j) = linspace(0.75,1.75,15);
end

position_matrix_x2= zeros(15,15);
position_matrix_y2 = zeros(15,15);
for i = 1:15
    position_matrix_x2(i,:) = linspace(3.25,4.25,15);
end
for j = 1:15
    position_matrix_y2(:,j) = linspace(0.75,1.75,15);
end

position_matrix_x3= zeros(15,15);
position_matrix_y3 = zeros(15,15);
for i = 1:15
    position_matrix_x3(i,:) = linspace(0.75,1.75,15);
end
for j = 1:15
    position_matrix_y3(:,j) = linspace(3.25,4.25,15);
end

position_matrix_x4= zeros(15,15);
position_matrix_y4 = zeros(15,15);
for i = 1:15
    position_matrix_x4(i,:) = linspace(3.25,4.25,15);
end
for j = 1:15
    position_matrix_y4(:,j) = linspace(3.25,4.25,15);
end

position_matrix_x= [position_matrix_x1,position_matrix_x2;position_matrix_x3,position_matrix_x4];
position_matrix_y= [position_matrix_y1,position_matrix_y2;position_matrix_y3,position_matrix_y4];

%% receiver configuration, point, or plane, or objects
%% receiver plan
[X, Y] = meshgrid(0:.05:5, 0:.05:5);
[r,c] = size(X);
res = zeros(r,c);
receiver_height = 0.85;

%% Luminous distribution calculation
[m,n] = size(position_matrix_x);
for i = 1:r
    for j = 1:c
        for k = 1:m
            for l = 1:n
                vector_A  = [X(i,j)-position_matrix_x(k,l), Y(i,j)-position_matrix_y(k,l), height-receiver_height];
                cos_theta = dot(vector_A, [0,0,1])/norm(vector_A);
                cos_yita = cos_theta;
                res(i,j) = res(i,j) + I0*cos_theta^lambert_index*cos_yita/norm(vector_A)^2;
%                 res(i,j)
            end
        end
    end
end

surf(X,Y,res);
figure(2);
contourf(X,Y,res);