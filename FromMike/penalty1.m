close all;
%clear all;

%load gt.mat % contains the impulse response 

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

figure(1);
plot(cumsum( gt_VLC)*t0 );
title('step response of multipath channel');

figure(2);
Gf = fft(gt);
Nfft = length(Gf);

plot( ([0:Nfft-1]-Nfft/2)*fs/Nfft, fftshift( db(Gf/max(Gf)) ) );
axis([0 2 -5 0])
xlabel('f in GHz');
ylabel('20\cdot 10 log_{10} G(f) in dB (normalized)' )


% calculation of ISI / SIR
Rb = logspace(1, 3, 15); % in Mbps

cntr = 0;
for R_B = Rb/1000 % in Gbps

  cntr = cntr + 1;
  T_B = 1/R_B; % bit intervall in ns
  N_B = round( T_B/t0 ); % samples per bit

  % Tx and Rx pulse shaping %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  xt = ones(N_B, 1);    % Tx NRZ-rect() - pulse 
  
  fgBessel=R_B/2;
  % we arrange f3dB first to 1 Hz (2*pi rad) -> see later
  W0 = 2*pi / 0.6157; % for 5th order Bessel filter

  [alpha, beta] = besself(5, W0); % filter coefficients for f3dB = 1 Hz and analog filter
  [dummy,gtNorm] = Gp2gt(alpha, beta, fs/fgBessel, 2.5);  % impulse response for d3dB=1 Hz
%  gtRx = gtNorm' * fgBessel;
  gtRx = xt / T_B; % Matched filter

  gtSys =   conv(xt, gtRx)*t0;
  figure(3);
  plot([0:length(gtSys)-1]*t0/T_B, gtSys, 'linewidth', 2); % pulse shape of Tx- and Rx-filter cascade
  xlabel('t/T_b');



  % now we include the multipath channel
  gtTotal = conv(gtSys, gt_VLC)*t0;
  hold on
  plot([0:length(gtTotal)-1]*t0/T_B, gtTotal/max(gtTotal),'r-.'); 
  legend('only Tx- and Rx-filter', 'complete channel');
  title(sprintf('data rate: %.1f Mbps',R_B*1000) );
  hold off;
  
  disp('press any key');
  pause

  % calculate SIR
  
  [P_sig, ind] = max(gtTotal.^2);
  P_isi = sum( gtTotal(ind+N_B:N_B:end).^2 ) +  sum( gtTotal(ind-N_B:-N_B:1).^2 );
  SIR(cntr) = P_sig / P_isi;

  EyeOpening(cntr) = (gtTotal(ind) - sum( gtTotal(ind+N_B:N_B:end) ) - sum( gtTotal(ind-N_B:-N_B:1) ) ) / gtTotal(ind)  ; % worst case relative eye-opening; a single one-bit produces the amplitude gtTotal(ind)
end

figure(3);
plot(Rb, db(SIR)/2,  'linewidth', 2);
xlabel('data rate in Mbps');
ylabel('SIR in dB');

figure(4);
plot(Rb, -db(EyeOpening),  '-x','linewidth', 2);
xlabel('data rate in Mbps');
ylabel('worst case eye-opening penalty in dB');




