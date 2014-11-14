receiver_count =1;
source_count = total_sources;
[source_sum_h1, source_sum_p1] = plot_1r_total_ir(receiver_count,source_count,h1,p1,maxbounce,array_length,timestep);
[source_sum_h2, source_sum_p2] = plot_1r_total_ir(receiver_count,source_count,h2,p2,maxbounce,array_length,timestep);
[source_sum_h3, source_sum_p3] = plot_1r_total_ir(receiver_count,source_count,h3,p3,maxbounce,array_length,timestep);
[source_sum_h4, source_sum_p4] = plot_1r_total_ir(receiver_count,source_count,h4,p4,maxbounce,array_length,timestep);
close all;
source_sum_h = source_sum_h1+source_sum_h2+source_sum_h3+source_sum_h4;
source_sum_p = source_sum_p1+source_sum_p2+source_sum_p3+source_sum_p4;

stem([1:1:length(source_sum_h)]*timestep*1e9,source_sum_h, 'Marker','None');
xlabel('Time (ns)');
ylabel('Impulse response (s^-1)');

%sample frequency (HZ)
Fs = 1/timestep;

size = length(source_sum_h);
nfft =512*pow2(nextpow2(size));


figure(10000)
freqz(source_sum_h,1,4096,10^10);
% magresp = 20*log10(abs(H));
% maxresp = max(magresp);
% [I,~] = find(magresp < maxresp-3,3,'first');
% %fprintf('3-dB point is %2.3f*pi radians/sample\n', W(I(1))/pi)
