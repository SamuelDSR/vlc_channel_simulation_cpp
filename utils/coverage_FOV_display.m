addpath('./utils');
hFig = figure(1);
screen  = get(0,'ScreenSize');
%set(hFig,'Position',[screen(3)/6,screen(4)/6,800,800]);
%% draw first the rectange represents the rooms
rectangle('Position',[0,0,room(1),room(2)],...
    'Curvature',[0,0],...
    'LineWidth',2,'LineStyle','-');
%axis off
grid on
%% calcuate and draw the coverage of each transmitter on the receiver plan
radius = zeros(1,source.count);
circles_handlers = [];
for i = 1:source.count
    radius(i) = (source.locationz(i) - receiver.locationz(1))*tan(2^(-1/source.order(i)));
%     rectangle('Position',[source.locationx(i)-radius(i),source.locationy(i)-radius(i),radius(i),radius(i)],...
%     'Curvature',[1,1],...
%     'LineWidth',1,'LineStyle','-');
    circles_handlers(i) = draw_circle(source.locationx(i),source.locationy(i),radius(i));
    hold on
    plot(source.locationx(i), source.locationy(i), 'o', 'MarkerSize', 4,'MarkerFaceColor', 'k');
    hold off
end

%% plot the receivers
for i = 1:receiver.count
    hold on;
    plot(receiver.locationx(i), receiver.locationy(i), 'o', 'MarkerSize', 6, 'MarkerFaceColor', 'g');
end
axis([0 room(1) 0 room(2)]);

% while 2>1
%     k = waitforbuttonpress;
%     point_temp = get(gca, 'currentpoint');
%     point_temp(1,1)
%     point_temp(1,2)
%     for j = 1:source.count
%         angle = atan(sqrt((point_temp(1,1)-source.locationx(i))^2 + (point_temp(1,2)-source.locationy(i))^2)/(source.locationz(i) - receiver.locationz(1)));
%         angle = radtodeg(angle)
%         if angle <= source.semianlge(i)
%             set(circles_handlers(i),'Color','r','LineWidth',2);
%         end
%     end
%             
% end