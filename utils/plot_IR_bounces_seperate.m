%% plot the impulse response according to the bounces number 
%% contributed by all transmitters (LEDs) for one receiver
function [source_sum_h, source_sum_p] = plot_IR_bounces_seperate(receiver_count,source_count,h,p,maxbounce,array_length,timestep)
close all;
source_sum_p = 0;
source_sum_h = zeros(array_length,1);
maxbounce = 3;
for j = 1:(maxbounce+1)
    
    source_sum_p = 0;
    source_sum_h = zeros(array_length,1);
    for i = 1:source_count
        
        num_h = cell2mat(h(j,i));
        num_p = cell2mat(p(j,i));
        num_p(isnan(num_p))=0;
        num_h(isnan(num_h))=0;
        
        plot_h = num_h(((receiver_count-1)*array_length+1):(receiver_count*array_length));
        
        source_sum_p  = source_sum_p+num_p(receiver_count);
        source_sum_h  = source_sum_h+plot_h*num_p(receiver_count);
        
    end
    
    %Plot steps
    plotstep = 0.1*10^-9;
    compressionFactor = plotstep/timestep;
    source_sum_h_plot = zeros(floor(array_length/compressionFactor),1);
    
    for k = 1:floor(array_length/compressionFactor)
        source_sum_h_plot(k) = sum(source_sum_h((k-1)*compressionFactor+1:k*compressionFactor));
    end
    source_sum_h_plot(end) = sum(source_sum_h(end+1-mod(array_length,compressionFactor):end));
        
    %hold on
    %figure(j)
    %     if j ==1
    %     bar([1:1:length(source_sum_h)]*timestep*1e9,source_sum_h*1e9);
    %     else
    %         plot([1:1:length(source_sum_h)]*timestep*1e9,source_sum_h*1e9);
    %     end
    
    subplot(2,2,j);
    plot([1:1:length(source_sum_h_plot)]*plotstep*1e9,source_sum_h_plot*1e9);
    xlabel('Time (ns)');
    ylabel('Impulse response (s^{-1})');
    xlim([0 80]);
end


