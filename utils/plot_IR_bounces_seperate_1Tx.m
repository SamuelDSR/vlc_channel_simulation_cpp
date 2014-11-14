%% plot the impulse response according to the bounces numbers contributed by one transmitter (LED)

function plot_IR_bounces_seperate_1Tx(receiver_count, total_sources,h,p,maxbounce,array_length,timestep)
count = maxbounce +1;
for j = 1:count
    num_h = cell2mat(h(j,total_sources));
    num_p = cell2mat(p(j,total_sources));
    num_p(isnan(num_p))=0;
    num_h(isnan(num_h))=0;
    
    %figure(j);
    subplot(2,2,j);
    count_h = num_h(((receiver_count-1)*array_length+1):(receiver_count*array_length));
    plot([1:1:length(count_h)]*timestep*1e9,count_h*num_p(receiver_count)/timestep);
    xlabel('Time (ns)');
    ylabel('Impulse response (s^-1)');
    xlim([0 80]);
end


