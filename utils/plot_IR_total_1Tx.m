%% plot the aggregated impulse response (including all bounces) contributed by one transmitter (LEDs)
function plot_IR_total_1Tx(receiver_count, source_count,h,p,maxbounce,array_length,timestep)

source_sum_p = 0;
source_sum_h = zeros(array_length,1);

 for j = 1:(maxbounce+1)
     
       num_h = cell2mat(h(j,source_count));
       num_p = cell2mat(p(j,source_count));
       num_p(isnan(num_p))=0;
       num_h(isnan(num_h))=0;
       
       plot_h = num_h(((receiver_count-1)*array_length+1):(receiver_count*array_length));   

       source_sum_p  = source_sum_p+num_p(receiver_count);
       source_sum_h  = source_sum_h+plot_h*num_p(receiver_count);
    end
    plot([1:1:length(source_sum_h)]*timestep*1e9,source_sum_h);
    xlabel('Time (ns)');
    ylabel('Impulse response (s^-1)');
    
    source_sum_p
end


