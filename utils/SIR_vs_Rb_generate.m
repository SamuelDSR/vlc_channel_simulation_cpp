% target data rate 10Mbps - 200Mbps
%data_rate = 5:5:200;
data_rate = [10 50 100];
data_rate = data_rate*10^6;

total_receivers = 3;
% generate SIR data for cases
% three positions, different data_rate;
P_s = zeros(length(data_rate),total_receivers);
P_isi = zeros(length(data_rate),total_receivers);
for i = 1:length(data_rate)
    for j = 1:total_receivers
        [P_s(i,j), P_isi(i,j)] = SIR_cal(j,total_sources,h,p,maxbounce,array_length,timestep,data_rate(1,i));
    end
end

SIR = P_s./P_isi;
SIR = 10*log10(SIR);
save('SIR.mat', 'data_rate', 'SIR');

%% plot SIR vesus data rate
close all;
for i = 1:total_receivers
    plot(data_rate/10^6,SIR);
    grid on;
    xlabel('data rate[Mbps]');
    ylabel('P_{isi}');
    hold on;
end

        