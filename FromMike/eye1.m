close all;
clear all;

Rb = 260; % in Mbps

load gt.mat % contains the impulse response 

% time t in ns
% gt u.a.

t0 = t(2)-t(1);
fs = 1/t0;

% first we process the multipath-channels impulse resonse a little bit

% delete delay at the beginning
ind = find(gt>0);
gt_VLC = gt(ind(1):end);

% now I delelte the tail at the end which has almost now impact on the eye-opening
ht = cumsum(gt_VLC(end:-1:1));
ind = find(ht > ht(end)/1000); % you may change this value
gt_VLC = gt_VLC(1:end-ind(1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
R_B = Rb/1000 % in Gbps

T_B = 1/R_B; % bit intervall in ns
N_B = round( T_B/t0 ); % samples per bit

% generate data with all bit comibinations by m-sequences
m=9;
m_seq=mseq(m);
data = [0; m_seq; m_seq(1:m-1)]; 

NumBits = length(data);

% Tx-signal

xt = reshape( repmat(data, 1, N_B)', NumBits*N_B, 1);
gtTx = ones(N_B,1);

fgBessel=R_B/2;
% we arrange f3dB first to 1 Hz (2*pi rad) -> see later
W0 = 2*pi / 0.6157; % for 5th order Bessel filter

[alpha, beta] = besself(5, W0); % filter coefficients for f3dB = 1 Hz and analog filter
[dummy,gtNorm] = Gp2gt(alpha, beta, fs/fgBessel, 2.5);  % impulse response for d3dB=1 Hz
%  gtRx = gtNorm' * fgBessel;
gtRx = gtTx / T_B; % Matched filter

% received signal
yt = conv( xt, conv(gtRx, gt_VLC) )*t0^2;

% total impulse response (transmission of single 1 bit)
gtTotal = conv( gtTx, conv(gtRx, gt_VLC) )*t0^2;
gtMax=max(gtTotal);

eyediagram(yt/gtMax, N_B, 1.0, 0,'b');

axis([-0.5 0.5 -0.1 1.4])
grid on

