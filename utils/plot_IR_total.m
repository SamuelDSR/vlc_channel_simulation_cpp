%% plot the aggreagted impulse response 
%% contributed by all bounces and all transmitters (LEDs) for one receiver 
function [source_sum_h, source_sum_p] = plot_IR_total(receiver_count,source_count,h,p,maxbounce,array_length,timestep)

source_sum_p = 0;
source_sum_h = zeros(array_length,1);
for i = 1:source_count
    for j = 1:(maxbounce+1)
        
        num_h = cell2mat(h(j,i));
        num_p = cell2mat(p(j,i));
        num_p(isnan(num_p))=0;
        num_h(isnan(num_h))=0;
        
        plot_h = num_h(((receiver_count-1)*array_length+1):(receiver_count*array_length));
        
        source_sum_p  = source_sum_p+num_p(receiver_count);
        source_sum_h  = source_sum_h+plot_h*num_p(receiver_count);
    end
end
save('gt-R3.mat', 'source_sum_h');
plot([1:1:length(source_sum_h)]*timestep*1e9,source_sum_h*1e9);
xlabel('Time (ns)');
ylabel('Impulse response (s^{-1})');
axis([0 25 0 12000])
end


