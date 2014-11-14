% bin width of CIR
tic
binwidth = 10^-10;
Fs = 1/binwidth;
t0 = 1/Fs;

% get CIR
[CIR, gain] = plot_IR_total(3,total_receivers,h,p,maxbounce,array_length,timestep);
% Compress the bin width of CIR
compressionFactor = binwidth/timestep;
CIR_VLC = zeros(floor(array_length/compressionFactor),1);
for k = 1:floor(array_length/compressionFactor)
    CIR_VLC(k) = sum(CIR((k-1)*compressionFactor+1:k*compressionFactor));
end
CIR_VLC(end) = sum(CIR(end+1-mod(array_length,compressionFactor):end));



% eliminate time delay of CIR
delay = find(CIR_VLC,1);
CIR_VLC = CIR_VLC(delay:end);

[max_gain,ind] = max(CIR_VLC);  % max gain

%generate OOK pulse
%Rb = [10 50 100]*10^6;
Rb = (10:5:100)*10^6;

simu_unit = 10^4; % simulation unit

num_err = zeros(length(Rb),1); %err
num_err_demand = 10^5*ones(length(Rb));
num_err_demand(1) = 10000;
num_err_demand(2) = 10000;
num_err_demand(3) = 50000;
err_rate = zeros(length(Rb),1);

EbNo = 10; %Energy per bit/Noise power; 10dB for 10Mbps (reference)
EsNo = EbNo;

snr = zeros(length(Rb),1);

for i = 1:length(Rb)
    simu_times = 0;
    while num_err(i) < num_err_demand(i) % run the simulation until we have at least 100 errors
        
        if simu_times > 2000
            break;
        else
            simu_times = simu_times + 1;
        end
            
        nsamp = floor(Fs/Rb(i)); % num of sampling point of OOK symbol
        
        s_data = randi([0 1], simu_unit,1); %    
        ook_signal = zeros(simu_unit*nsamp,1);
        
        for k = 1:simu_unit
            if s_data(k) == 1
                ook_signal((k-1)*nsamp+1:k*nsamp)    = 1;
            end
        end
        
%       plot(ook_signal(1:10000));
        
        % passing through channel
        snr(i) = EsNo*10^7/Rb(i) - 10*log10(nsamp);
        %snr = 10;
        ook_signal = awgn(ook_signal,snr(i),'measured');
        
        %tx_signal = ook_signal;
        tx_signal = conv(CIR_VLC,ook_signal);
        % add receiver noise
        %tx_signal = awgn(tx_signal, EbNo, 'measured');
%         
%         figure
%         plot(tx_signal(1:10000));
         
        % matched filtering
        MF_coef = ones(1,nsamp);
        rx_signal = conv(MF_coef,tx_signal);
%         figure;
%         plot(rx_signal(1:20000));
        
        % hard detection
        delay = ind-1;
        max_gain_c = max_gain*nsamp;
        d_data = zeros(simu_unit,1);
        for k = 1:simu_unit
            if rx_signal(k*nsamp+delay) >= max_gain_c/2
                d_data(k) = 1;
            else
                d_data(k) = 0;
            end
        end  
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
plot(Rb,qfunc(sqrt(10.^(EsNo*10^7./Rb/2/10))));  