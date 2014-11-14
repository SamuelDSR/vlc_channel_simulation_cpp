function delay = delay_spread(receiver_count, total_sources,h,p,maxbounce,array_length,timestep)
source_sum_p = 0;
source_sum_h = zeros(array_length,1);
for i = 1:(maxbounce+1)
    for j = 1:total_sources
        num_h = cell2mat(h(i,j));
        num_p = cell2mat(p(i,j));
        num_p(isnan(num_p))=0;
        num_h(isnan(num_h))=0;
        source_sum_p  = source_sum_p + num_p(receiver_count,1);
        
        plot_h = num_h(((receiver_count-1)*array_length+1):(receiver_count*array_length));
        source_sum_h  = source_sum_h+plot_h*num_p(receiver_count)/timestep;
    end
end

timestep_array = double(1:1:array_length);
timestep_array = timestep_array'*timestep;

% square_int_sum_h = trapz(timestep_array, source_sum_h.^2);
% t_square_int_sum_h =  trapz(timestep_array,timestep_array.*source_sum_h.^2);
square_int_sum_h = sum(timestep_array.*source_sum_h.^2);
t_square_int_sum_h = sum(timestep_array.^2.*source_sum_h.^2);

mu = t_square_int_sum_h/square_int_sum_h

%delay = trapz(timestep_array, (timestep_array-mu).^2.*source_sum_h.^2)/square_int_sum_h;
delay = sum(timestep_array.*(timestep_array-mu).^2.*source_sum_h.^2)/square_int_sum_h;
delay = delay^0.5

end