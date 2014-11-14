% This m file contains the funtion for calculating a single SIR cases
% There are two variables to control the type of filter and method for calculating SIR
% set filter_type will change the type of filter you use
% set method_type will change the type of method you use
% see below for more detail

function [P_s, P_isi] = SIR_cal(receiver_count,source_count,h,p,maxbounce,array_length,timestep,Rb)
close all;

% construct OOK signal (without pulse shaping)
plotstep = 0.1*10^-9;
%Fs = 1/timestep;
Fs = 1/plotstep;
nsamp = floor(Fs/Rb);
ook_pulse = 1000*ones(round(nsamp),1);

%pulse shaping
%h = fdesign.pulseshaping(sampling_points,'Raised Cosine', 'Nsym,Beta', 8, 0.5);
%Hd = design(h);
%shaped_pulse = Hd.coefficients;

%get total channel impulse response
[source_sum_h, source_sum_p] = plot_IR_total(receiver_count,source_count,h,p,maxbounce,array_length,timestep);

%compress the CIR data by increasing the time steps
compressionFactor = plotstep/timestep;
source_sum_h_plot = zeros(floor(array_length/compressionFactor),1);
for k = 1:floor(array_length/compressionFactor)
    source_sum_h_plot(k) = sum(source_sum_h((k-1)*compressionFactor+1:k*compressionFactor));
end
source_sum_h_plot(end) = sum(source_sum_h(end+1-mod(array_length,compressionFactor):end));

%eliminate channel delay
delay = find(source_sum_h_plot,1);
channel_impulse = source_sum_h_plot(delay:end);
% channel_impulse(1) = channel_impulse(1)/2;
% channel_impulse(2:end) = 4*channel_impulse(2:end);

% creating dirac impulse response
%channel_impulse = zeros(length(channel_impulse),1);
%channel_impulse(1) = 1;

% get channel response

Rx_data = conv(ook_pulse,channel_impulse);
%Rx_data = ook_pulse;
%Rx_data = filter(channel_impulse,1,ook_pulse);
%plot(Rx_data);
%% create low pass filter response
filter_type =3;

% receiver filter type
% 0 no filter; not recommended
% 1 sub-optimal low pass RC filter
% 2 butterworth low pass filter
% 3 matched filter
% 4 bessel filter

switch filter_type
    case 0
        Rx_data = Rx_data;
    case 1
        fc = 0.75*Rb;
        t = timestep:timestep:20/Rb;
        lpf_impulse = exp(-t*2*pi*fc);
        %Rx_data = filter(lpf_impulse,1,Rx_data);
        Rx_data = conv(Rx_data, lpf_impulse);
    case 2
        %% cutoff frequency for Butterwidth filter, Here, cutoff frequency is set to Rb
        Wn = 2*Rb/Fs;
        [b,a] = butter(3,Wn,'low');
        Rx_data = filter(b,a,Rx_data);
    case 3
        MF_coef = ones(1,nsamp);
        Rx_data = conv(MF_coef,Rx_data);
        %Rx_data = filter(MF_coef,1,Rx_data);
        plot(Rx_data)
        cfe = 1+1;
    case 4
        %% cutoff frequency for 5th order Bessel filter, here, cutoff frequency is set to Rb/2
        
        fgBessel=Rb/2;
        % we arrange f3dB first to 1 Hz (2*pi rad) -> see later
        W0 = 2*pi / 0.6157; % Matlab's cut-off frequency is NOT 3dB, it is defined via
        % the group velocity-> this value is only correct for 5th order
        
        [alpha, beta] = besself(5, W0); % filter coefficients for f3dB = 1 Hz and analog filter
        % Note: if you calculate the filter coeff. for say f3dB = 1 GHz,
        % the dynamic range of beta is to large -> strong errros !!!
        % -> always develope a normalized filter !!!
        % we use the impinvar method to find the impulse response of a digital recursive filter
        % (->note: a digital Bessel filter is not implemented in Matlab!), where the impulse
        % response of the analog Bessel filter is correctly sampled at the time bins 0, 1s, 2s,
        [dummy,gtNorm] = Gp2gt(alpha, beta, Fs/fgBessel, 3);  % impulse response for d3dB=1 Hz
        bessel_impulse = gtNorm' * fgBessel;
        %plot(bessel_impulse);
        
        Rx_data = conv(bessel_impulse,Rx_data);
        plot(Rx_data)
        cfe = 1+1;
end

%plot
time_t = (0:timestep:(length(Rx_data)-1)*timestep);
figure(2);
plot(time_t,Rx_data);


%% calculate SIR (For a single OOK)

% Method type for calculating SIR
% 0: sampling method (not chose the peak)
% 1: integral method
% 2: sampling method (chose the peak)
interference_points = zeros(200,1);
method_type =  2;
switch method_type
    case 0
        % delay=0  represents sampling at the end of symbol, aka, (Ts, 2Ts, 3Ts)
        % if want to sampling at the middle, set delay = nsamp/2;
        delay = 0;
        % sampling method
        % singal power
        signal_point = Rx_data(floor(nsamp-delay),1);
        P_s = signal_point^2;
        % inteference power
        k = 2;
        while k*nsamp < length(Rx_data)
            index = k*nsamp -delay;
            interference_points(k-1) = Rx_data(floor(index),1);
            %P_isi = P_isi + abs(a)^2;
            k = k+1;
        end
        P_isi = sum(interference_points.^2);
        SIR = P_s/P_isi;
        
    case 1
        
        %integral method
        %Notice that, if using low pass filter, the resulting signal will have negative part, so in that case, this sampling method is not a good choice.
        P_s = trapz(1:1:nsamp,Rx_data(1:1:nsamp))*timestep;
        P_isi = trapz(nsamp+1:1:length(Rx_data), Rx_data(nsamp+1:1:length(Rx_data),1))*timestep;
        SIR = (P_s/P_isi)^2;
        
        
    case 2
        % samping method with peak, containing all interference points (Left and right)
        [P_s, max_I] = max(Rx_data);
        P_s = P_s^2;
        P_isi = 0;
        N_Left = floor(max_I/nsamp);
        k = -N_Left;
        while k*nsamp + max_I >= 0 && k*nsamp + max_I < length(Rx_data)
            if k ~= 0
                P_isi = P_isi + abs(Rx_data(floor(k*nsamp+max_I+1)))^2;
            end
            k = k+1;
        end
        SIR = P_s/ P_isi;
end



