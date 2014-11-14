function h = height(h0,theta1,theta2)
thetaP = max(theta1,theta2)*pi/180;
thetaM = min(theta1,theta2)*pi/180;
h = h0*(tan(thetaP)*tan(thetaM))/(tan(thetaP)-tan(thetaM));
end