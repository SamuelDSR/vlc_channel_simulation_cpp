tic

% bin width of CIR
binwidth = 10^-10;
Fs = 1/binwidth;
t0 = 1/Fs;

% get CIR
[CIR, gain] = plot_IR_total(3,total_receivers,h,p,maxbounce,array_length,timestep);

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

% max gain
[max_gain,ind] = max(CIR_VLC); 

% generate OOK pulse
%Rb = logspace(10,100,20);
Rb = linspace(10,100,21);
Rb = Rb*10^6;

% simulation unit
simu_unit = 10^4; 
% number of errors 
num_err = zeros(length(Rb),1);
% minimum errors 
num_err_demand = 10^5*ones(length(Rb));
% error rate
err_rate = zeros(length(Rb),1);

% Responsitivity
R = 1;

% SNR per bits, fixed for all data rates
EbNo_db = 10;
EbNo = 10^(EbNo_db/10);
No = 1;
Eb = No*EbNo;

for i = 1:length(Rb)
    simu_times = 0;
    while num_err(i) < num_err_demand(i) % run the simulation until we have at least the minimum number of errors 
        
        if simu_times > 2000
            break;
        else
            simu_times = simu_times + 1;
        end
        
        % samples per OOK symbol
        nsamp = floor(Fs/Rb(i)); 
        Tb = 1/Rb;
        
        % Optical power
        P_opt_avg = 1/R*sqrt(Eb*Rb/2);
        P_opt_peak = 2*P_opt_avg;
        
        % generate random ook optical signal
        s_data = randi([0 1], simu_unit,1); %    
        tx_signal = zeros(simu_unit*nsamp,1);
        
        for k = 1:simu_unit
            if s_data(k) == 1
                tx_signal((k-1)*nsamp+1:k*nsamp)    = 1;
            end
        end        
        tx_signal = tx_signal*P_opt_peak;
       
        % transmit over indoor VLC channel
        rx_signal = conv(CIR_VLC,tx_signal);
        
        % PD, O-E conversion
        rx_signal = R*rx_signal;
        % supposed current peak
        I_peak = R*P_opt_peak;
        % supposed energy peak 
        E_peak = I_peak^2*Tb;
        
        % adding awgn noise, sigma = noise variance
        sigma = sqrt(No/2*Rb*nsamp);
        rx_signal = rx_signal+sigma*randn(1,length(rx_signal));
        
        % matched filtering
        MF_coef = ones(1,nsamp)*I_peak;
        MF_out = conv(MF_coef,rx_signal)*nsamp;

        % downsampling
        MF_out = MF_out(nsamp:nsamp:end);
        % transaction
        MF_out = MF_out(1:simu_unit);
        
        % hard detection
        d_data = zeros(1,simu_unit);
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
plot(Rb,qfunc(sqrt(EbNo)));