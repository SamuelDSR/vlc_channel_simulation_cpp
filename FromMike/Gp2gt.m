function [t,gt]=Gp2gt(num, den, fs, tmax);

% we use Matlabs function impinvar to sample the 
% impulse response of an analog filter with the frequency fs

% the filter coeff. in the analog domain are num, den

% the impulse response gt is samples from 0:1/fs:tmax

[a_dig,b_dig]=impinvar(num,den,fs); % coefficients of digital filter

t0=1/fs;
t=0:t0:tmax;
N=length(t)-1;

xin=[1, zeros(1,N)];
y=filter(a_dig, b_dig, xin);
gt=y(1:N+1)*fs;

