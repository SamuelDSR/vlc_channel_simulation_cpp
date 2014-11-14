function [fft_fs, f]= frequence_response(receiver_count,source_count,h,p,minbounce,maxbounce,array_length,timestep)
source_sum_p = 0;
source_sum_h = zeros(array_length,1);
for i = 1:source_count
    for j =minbounce:maxbounce
        
        num_h = cell2mat(h(j+1,i));
        num_p = cell2mat(p(j+1,i));
        num_p(isnan(num_p))=0;
        num_h(isnan(num_h))=0;
        
        plot_h = num_h(((receiver_count-1)*array_length+1):(receiver_count*array_length));
        
        source_sum_p  = source_sum_p+num_p(receiver_count);
        
        source_sum_h  = source_sum_h+plot_h*num_p(receiver_count);
    end
end
sum(source_sum_h);

% bar([1:1:length(source_sum_h)]*timestep*1e9,source_sum_h);
% xlabel('Time (ns)');
% ylabel('Impulse response (s^-1)');

%delete delay of the CIR
% ind = find(source_sum_h>0);
% source_sum_h = source_sum_h(ind(1):end);

Fs = 1/timestep;
size = length(source_sum_h);
nfft = pow2(nextpow2(size));

%% special treatement
%indice = find(source_sum_h,1);
%source_sum_h = source_sum_h(indice:array_length);
%
%source_sum_h = detrend(source_sum_h);

%% Pwelch approach
% source_sum_h(size+1:nfft) = 0;
% window_s = length(source_sum_h);
% [pxx, f] = pwelch(source_sum_h,window_s,0,[],Fs);
% figure(2);
% pxx =  pxx/max(pxx);
% plot(f,10*log10(pxx))
% xlabel('Hz'); ylabel('dB');

%% freqz approach
%source_sum_h = detrend(source_sum_h);
[fft_fs, f] =freqz(source_sum_h,1,4096,Fs);

fft_fs = abs(fft_fs);
fft_fs = fft_fs/max(fft_fs);
fft_fs = 10*log10(fft_fs);
plot(f,fft_fs);
xlabel('Frequency (Hz)'); 
ylabel('Power (db)'); 

axis([0 5e9 -5 0])

%% FFT approach
% fft_fr = fft(source_sum_h_plot,nfft);
% NumUniquePts = ceil((nfft+1)/2);
% fft_fr = fft_fr(1:NumUniquePts);
% 
% %Power compesation
% if rem(nfft, 2) % odd nfft excludes Nyquist point
%   fft_fr(2:end) = fft_fr(2:end)*2;
% else
%   fft_fr(2:end -1) = fft_fr(2:end -1)*2;
% end
% 
% %fft_fs = fft_fr;
% 
% %normalize and db
% fft_fr = abs(fft_fr);
% %fft_fr(1) = fft_fr(2);
% fft_fr = fft_fr/max(fft_fr);
% fft_fr = 10*log10(fft_fr);
% 
% 
% 
% % This is an evenly spaced frequency vector with NumUniquePts points. 
% f = (0:NumUniquePts-1)*Fs/nfft; 
% 
% figure(2)
% % Generate the plot, title and labels. 
% %fft_fr_smooth = sgolayfilt(fft_fr,3,13);
% plot(f,fft_fr); 
% xlabel('Frequency (Hz)'); 
% ylabel('Power (db)'); 
% 
% axis([0 5e9 -5 0])

%% Mike approach

% Gf = fft(source_sum_h,nfft);
% plot( ([0:nfft-1]-nfft/2)*Fs/nfft, fftshift( db(Gf/max(Gf)) ) );
% axis([0 2 -1 0])
% xlabel('f in GHz');
% ylabel('20\cdot 10 log_{10} G(f) in dB (normalized)' )