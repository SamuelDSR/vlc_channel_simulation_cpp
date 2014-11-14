[source_sum_h1, source_sum_p1] = plot_1r_total_ir(receiver_count,source_count,h1,p1,maxbounce,array_length,timestep);
[source_sum_h2, source_sum_p2] = plot_1r_total_ir(receiver_count,source_count,h2,p2,maxbounce,array_length,timestep);
[source_sum_h3, source_sum_p3] = plot_1r_total_ir(receiver_count,source_count,h3,p3,maxbounce,array_length,timestep);
[source_sum_h4, source_sum_p4] = plot_1r_total_ir(receiver_count,source_count,h4,p4,maxbounce,array_length,timestep);
close all;
source_sum_h = source_sum_h1+source_sum_h2+source_sum_h3+source_sum_h4;
source_sum_p = source_sum_p1+source_sum_p2+source_sum_p3+source_sum_p4;
plot([1:1:length(source_sum_h)]*timestep*1e9,source_sum_h/timestep);
xlabel('Time (ns)');
ylabel('Impulse response (s^-1)');


