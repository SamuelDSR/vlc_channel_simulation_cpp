function SIR = SIR_cal(receiver_count,source_count,h,p,maxbounce,array_length,timestep,Rb)
    close all;
   
    % construct OOK signal (without pulse shaping)
    Fs = 1/timestep;
    nsamp = floor(Fs/Rb);
    ook_pulse = ones(round(nsamp),1);
    
    %pulse shaping
    %h = fdesign.pulseshaping(sampling_points,'Raised Cosine', 'Nsym,Beta', 8, 0.5);
    %Hd = design(h);
    %shaped_pulse = Hd.coefficients;

    %get total channel impulse response
    [source_sum_h, source_sum_p] = plot_IR_total(receiver_count,source_count,h,p,maxbounce,array_length,timestep);
    
    %eliminate channel delay
    delay = find(source_sum_h,1);
    channel_impulse = source_sum_h(delay:end);
    
    % get channel response
    Rx_data = conv(ook_pulse,channel_impulse);
    %Rx_data = filter(channel_impulse,1,ook_pulse);
    
    %% create low pass filter response 
    filter_type = 2;
    % receiver filter
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
            Rx_data = filter(lpf_impulse,1,Rx_data);
            %Rx_data = conv(Rx_data, lpf_impulse);
        case 2
            Wn = 2*Rb/Fs;
            [b,a] = butter(3,Wn,'low');
            Rx_data = filter(b,a,Rx_data);
        case 3
            MF_coef = ones(1,nsamp);
            Rx_data = filter(MF_coef,1,Rx_data);
        case 4 
            Wo = (Rb/2)*2*pi;
            [num, den] = besself(5,Wo);
            [numd, dend] = bilinear(num,den,Fs);
            %Rx_data = filter(numd,dend,Rx_data);
            [bessel_impulse,t] = impz(numd,dend);
            Rx_data = conv(bessel_impulse,Rx_data);
    end
   
   %plot 
    time_t = (0:timestep:(length(Rx_data)-1)*timestep);
    figure(2);
    plot(time_t,Rx_data);

    
   %% calculate SIR (For a single OOK)  
   method_type =  2;
   switch method_type
       case 0
           % sampling method
           % singal power
           delay = 2;
           P_s = Rx_data(floor(nsamp-delay),1)^2;
           % inteference power
           P_isi = 0;
           k = 2;
           while k*nsamp - delay< length(Rx_data)
               index = k*nsamp -delay;
               a = Rx_data(floor(index),1);
               P_isi = P_isi + abs(a)^2;
               k = k+1;
           end
           SIR = P_s/P_isi;
           
       case 1
           
           %integral method
           P_s = trapz(1:1:nsamp,Rx_data(1:1:nsamp))*timestep;
           P_isi = trapz(nsamp+1:1:length(Rx_data), Rx_data(nsamp+1:1:length(Rx_data),1))*timestep;
           
           SIR = (P_s/P_isi)^2;
           
           
       case 2
           % samping method with peak 
           [P_s, max_I] = max(Rx_data);
           P_s = P_s^2;
           P_isi = 0;
           N_Left = floor(max_I/nsamp);  
           k = 0;         
           while k*nsamp + max_I >= 0 && k*nsamp + max_I < length(Rx_data)
               if k ~= 0
                   P_isi = P_isi + abs(Rx_data(floor(k*nsamp+max_I+1)))^2;
               end
               k = k+1;
           end
           SIR = P_s/ P_isi;
               
   end
           
           