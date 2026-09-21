clear all; clc; close all;
%signal details
fs = 8000;                      
t = (0:1/fs:0.05)';             
fm = 150;                       

%creating noisy signal
clean_speech = zeros(length(t), 1);
for k = 1:15  
    clean_speech = clean_speech + (0.8^k) * sin(2*pi*k*fm*t);
end

x = awgn(clean_speech,10);       
%applying hamming window
window = hamming(length(x));
x_windowed=x.*window;
%cepstrum analysis
X=fft(x_windowed);
power_spectrum=abs(X).^2;
log_spectrum=log(power_spectrum +eps);
cepstrum_full=real(ifft(log_spectrum));
power_cepstrum=abs(cepstrum_full).^2;
quefrency=(0:length(power_cepstrum)-1)/fs;
%enhancement
lifter_cutoff = round(fs * 0.0125);    
lifter = zeros(size(cepstrum_full));
lifter(1:lifter_cutoff) = 1;
lifter(end-lifter_cutoff+1:end) = 1;
cepstrum_liftered = cepstrum_full .* lifter;
smooth_log_spectrum = real(fft(cepstrum_liftered));
noise_floor = mean(smooth_log_spectrum);          
gain = max(smooth_log_spectrum - noise_floor, 0); 
gain = gain / (max(gain) + eps);                  
enhanced_magnitude = abs(X) .* gain;
original_phase = angle(X);
X_enhanced = enhanced_magnitude .* exp(1i * original_phase);
x_enhanced = real(ifft(X_enhanced));
%results
figure;
subplot(3,1,1);
plot(t,x_windowed);
title('Windowed Noisy Signal(Time Domain)');
xlabel('Time in seconds');
ylabel('Amplitude');

subplot(3,1,2);
plot(quefrency(1:round(length(quefrency)/2))*1000,power_cepstrum(1:round(length(power_cepstrum)/2)));
xlim([0 25]); 
title('Power Cepstrum');
xlabel('Quefrency(ms)');
ylabel('Amplitude');
xline(2.2,  '--r', 'F0 low (2.2 ms)');
xline(12.5, '--b', 'F0 high (12.5 ms)');

% 3. Keep your markers
xline(2.2,  '--r', 'F0 low (2.2 ms)');
xline(12.5, '--b', 'F0 high (12.5 ms)');
grid on;
subplot(3,1,3);
plot(t,x_enhanced);
title("Enhanced signal for output");
xlabel('Time in seconds');
ylabel('Amplitude');

figure;
subplot(1,1,1);

power_db = 10 * log10(power_cepstrum + eps);

plot(quefrency(5:round(end/2))*1000, power_db(5:round(end/2)));

xlim([0 25]); 
title('Power Cepstrum (Log Scale)');
xlabel('Quefrency (ms)');
ylabel('Power (dB)'); 




