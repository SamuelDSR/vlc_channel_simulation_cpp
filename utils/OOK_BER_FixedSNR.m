close all;

tic

% bin width of CIR
binwidth = 10^-10;
Fs = 1/binwidth;
Ts = 1/Fs;

% get CIR
[CIR, gain] = plot_IR_total(3,total_sources,h,p,maxbounce,array_length,timestep);

% compress the bin width of CIR
compressionFactor = binwidth/timestep;
CIR_VLC = zeros(floor(array_length/compressionFactor),1);
for k = 1:floor(array_length/compressionFactor)
    CIR_VLC(k) = sum(CIR((k-1)*compressionFactor+1:k*compressionFactor));
end
CIR_VLC(end) = sum(CIR(end+1-mod(array_length,compressionFactor):end));

% eliminate time delay of CIR
delay = find(CIR_VLC,1);
CIR_VLC = CIR_VLC(delay:end);

% normalize channel by H(0)
CIR_VLC = CIR_VLC/sum(CIR_VLC);

% max gain
%[max_gain,ind] = max(CIR_VLC); 

% generate OOK pulse
%Rb = logspace(10,100,20);
%Rb = linspace(5,100,20);
%Rb = 15:5:100;
Rb = 15:5:20;
%Rb = [10 50 100];
Rb = Rb*10^6;

% simulation unit
simu_unit = 10^4; 
% number of errors 
num_err = zeros(length(Rb),1);
% minimum errors 
num_err_demand = 3000*ones(length(Rb));
num_err_demand(1) = 75;
num_err_demand(2) = 75;

% error rate
err_rate = zeros(length(Rb),1);

% Responsitivity
R = 1;

% SNR per bits, fixed for all data rates
EbNo_db = 16;
EbNo = 10^(EbNo_db/10);
No = 10^-23;
Eb = EbNo*No;

for i = 1:length(Rb)
    simu_times = 0;
    while num_err(i) < num_err_demand(i) && simu_times<10000 % run the simulation until we have at least the minimum number of errors 
        simu_times = simu_times + 1;
        
        % samples per OOK symbol
        nsamp = floor(Fs/Rb(i)); 
        Tb = 1/Rb(i);
        
        P_opt_avg = 1/R*sqrt(Eb*Rb(i)/2);
        P_opt_peak = 2*P_opt_avg;
        % supposed current peak
        I_peak = R*P_opt_peak;
        % supposed energy peak 
        E_peak = I_peak^2*Tb;
        
        % generate random ook optical signal
        s_data = randi([0 1], simu_unit,1); 
        tx_signal = rectpulse(s_data,nsamp);
       
        tx_signal = tx_signal*P_opt_peak;
       
        % transmit over indoor VLC channel
        rx_signal = conv(CIR_VLC,tx_signal);
        % rx_signal = tx_signal; 

        % PD, O-E conversion
        rx_signal = R*rx_signal;

        % adding awgn noise, sigma = noise variance
        sigma = sqrt(No/2*Rb(i)*nsamp);
        rx_signal = rx_signal+sigma*randn(length(rx_signal),1);
        
        % matched filtering
        MF_coef = ones(1,nsamp)*I_peak;
        MF_out = conv(MF_coef,rx_signal)*Ts;

        % downsampling
        MF_out = MF_out(nsamp:nsamp:end);
        % transaction
        MF_out = MF_out(1:simu_unit);
        
        % hard detection
        d_data = zeros(simu_unit,1);
        d_data(MF_out>E_peak/2) = 1;
        
        [num, ratio] = biterr(s_data,d_data);
        num_err(i) = num_err(i) + num;
    end  
    err_rate(i) = num_err(i)/(simu_times*simu_unit);
    simu_times*simu_unit
end

figure
toc
plot(Rb,err_rate);
hold on;
plot(Rb,ones(length(Rb),1)*qfunc(sqrt(EbNo)));