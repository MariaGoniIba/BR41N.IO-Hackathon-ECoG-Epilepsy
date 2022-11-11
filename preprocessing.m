function [y_BP, classes] = preprocessing(y, fs)

fny = fs/2; %nyquist

%There is always a peak in the beginning. This is just the settling from the amplifier filters. You can manually delete the first one or two seconds.
samp2sec=2*fs; %we will remove the first 2 seconds
y_trim=y(:,samp2sec+1:end);

%classes 62
classes = y_trim(62,:);
y_trim = y_trim(2:61,:);

% % Visualize channels
% figure(1)
% for i = 1:size(y_trim,1)
%     subplot(60,1,i)
%     plot(y_trim(i,:))
% end

%% CAR (common MEDIAN re-reference)
% Subtracting the median of all channels from each channel. 
% This eliminates common mode interference, such as line noise and prevents from leaking noise from noisy channels.
med_s = median(y_trim);

for i=1:size(y_trim,1)
    y_CAR(i,:) = y_trim(i,:) - med_s(i);
end

%% Notch-filter cascade 
% Recursive 6th-order Butterworth, bandwidth: 5 Hz, up to the 6th harmonic (limit of the notch filter)
%Explanation: 5 Hz is the bandwidth of the notch filter, i.e., we notch-filtered from 
%47.5-52.5 Hz, 97.5-102.5 Hz, etc., up to fs/2 in integer multiples of the power line frequency.
order = 6;
bw = 5;
harm = 6;
pwfreq = 50; %power line frequency
for i=1:size(y_CAR,1)
    temp = y_CAR(i,:);

    %notch-filter cascade
    for j=1:harm       
        harm_f = pwfreq*j; %50 100 150.... until the 6th harmonic
        [b,a] = iirnotch(harm_f/fny,bw/fny);
        %[b,a]=butter(order,[(harm_f-bw/2) (harm_f+bw/2)]/fny);
        temp = filter(b,a,temp);
    end
    
    y_notch(i,:) = temp;
    clear temp
end

%% Band-pass filter 50-300 Hz
lower_bnd = 50; % Hz
upper_bnd = 300; % Hz
frange = [lower_bnd upper_bnd];
lower_trans = 0.1;
upper_trans = 0.1;
filtorder = 6*round(fs/lower_bnd);
filt_shape = [ 0 0 1 1 0 0 ];
filt_freqs = [ 0 lower_bnd*(1-lower_trans) lower_bnd ...
 upper_bnd upper_bnd+upper_bnd*upper_trans ...
 (fs/2) ] / (fs/2);
filtkern = firls(filtorder,filt_freqs,filt_shape);
hz = linspace(0,fs/2,floor(length(filtkern)/2)+1);
filtpow = abs(fft(filtkern)).^2;
filtpow = filtpow(1:length(hz));
 
subplot(121)
plot(filtkern,'linew',2)
xlabel('Time points')
title('Filter kernel (firls)')
axis square
 
% plot amplitude spectrum of the filter kernel
subplot(122), hold on
plot(hz,filtpow,'ks-','linew',2,'markerfacecolor','w')
plot(filt_freqs*(fs/2),filt_shape,'ro-','linew',2,'markerfacecolor','w')
 
% make the plot look nicer
set(gca,'xlim',[0 450])
xlabel('Frequency (Hz)'), ylabel('Filter gain')
legend({'Actual';'Ideal'})
title('Frequency response of filter (firls)')
axis square

% Apply filter
for i=1:size(y_notch,1)
    temp = y_notch(i,:);
    % Apply filter
    temp = filtfilt(filtkern,1,temp);
    
    y_BP(i,:) = temp;
    clear temp
end

%% Remove offset
% Delete 1 second
y_BP=y_BP(:,fs:end);
classes = classes(:,fs:end);