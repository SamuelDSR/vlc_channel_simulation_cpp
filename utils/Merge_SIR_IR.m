receiver_count =3;
source_count = total_sources;
[source_sum_h1, source_sum_p1] = plot_1r_total_ir(receiver_count,source_count,h1,p1,maxbounce,array_length,timestep);
[source_sum_h2, source_sum_p2] = plot_1r_total_ir(receiver_count,source_count,h2,p2,maxbounce,array_length,timestep);
[source_sum_h3, source_sum_p3] = plot_1r_total_ir(receiver_count,source_count,h3,p3,maxbounce,array_length,timestep);
[source_sum_h4, source_sum_p4] = plot_1r_total_ir(receiver_count,source_count,h4,p4,maxbounce,array_length,timestep);
close all;
source_sum_h = source_sum_h1+source_sum_h2+source_sum_h3+source_sum_h4;
source_sum_p = source_sum_p1+source_sum_p2+source_sum_p3+source_sum_p4;

data_rate = 80*10^6;
 Ts = 1/data_rate;
 sampling_factor = Ts/timestep;
    
 signal = ones(round(sampling_factor),1);
 response = conv(signal, source_sum_h);
    
 %time_t = (0:timestep:(length(response)-1)*timestep);
 figure(2);
 plot(response);
    
%% calculate SIR (For a single OOK)
    delay = find(response,1);
    symbol_step = round(Ts/timestep);
    
 %% Method integral
   p_symbole = trapz(1:1:delay+symbol_step,response(1:1:delay+symbol_step))*timestep;
   p_isi = trapz(delay+symbol_step+1:1:length(response), response(delay+symbol_step+1:1:length(response),1))*timestep;
   
   SIR = p_symbole/p_isi
   SIR_dB = 10*log10(SIR)
        
    