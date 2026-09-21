clear all;
clc; 
close all;

fs=8000;
[x_full, fs] = audioread('test_noisy_speech_5sec.wav');
if size(x_full, 2) > 1
    x_full = x_full(:, 1); 
end
%Applying hamming window
window=hamming(length(x_full));
x_windowed=x_full.*window;
t = (0:length(x_full)-1)'/ fs;
%cepstrum analysis
X=fft(x_windowed);
power_spectrum=abs(X).^2;
log_spectrum=log(power_spectrum +eps);
cepstrum_full=real(ifft(log_spectrum));
power_cepstrum=abs(cepstrum_full).^2;
quefrency=(0:length(power_cepstrum)-1)/fs;
%enhancement
lifter_cutoff=round(fs*0.0125);   
lifter=zeros(size(cepstrum_full));
lifter(1:lifter_cutoff) = 1;
lifter(end-lifter_cutoff+1:end) = 1;
cepstrum_liftered=cepstrum_full.*lifter;
smooth_log_spectrum = real(fft(cepstrum_liftered));
noise_floor=mean(smooth_log_spectrum);          
gain=max(smooth_log_spectrum - noise_floor, 0); 
gain=gain/(max(gain) + eps);                  
enhanced_magnitude=abs(X).*gain;
original_phase=angle(X);
X_enhanced=enhanced_magnitude.*exp(1i*original_phase);
x_enhanced=real(ifft(X_enhanced));
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

subplot(3,1,3);
plot(t,x_enhanced);
title("Enhanced signal for output");
xlabel('Time in seconds');
ylabel('Amplitude');

disp('Playing noisy input...');
sound(x_full, fs);
pause(length(x_full)/fs + 1);

disp('Playing enhanced output...');
sound(x_enhanced, fs);

figure;
subplot(1,1,1);
start_idx = 5;  
end_idx = round(length(quefrency)/2);
plot(quefrency(start_idx:end_idx)*1000, 10*log10(power_cepstrum(start_idx:end_idx)+eps));
xlim([0 25]); 
title('Power Cepstrum');
xlabel('Quefrency (ms)');
ylabel('Power (dB)');
xline(2.2,  '--r', 'F0 low (2.2 ms)');
xline(12.5, '--b', 'F0 high (12.5 ms)');
grid on;