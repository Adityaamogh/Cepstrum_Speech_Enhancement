clc;
clear;
close all;

N = 10000;
sigma_w = 1;               
h = [1 0.5 0.25];          

w = sqrt(sigma_w) * randn(1, N);

x = filter(h, 1, w);

mean_w = mean(w);
mean_x = mean(x);
var_w = var(w);
var_x = var(x);

disp(['Mean of W[n] = ', num2str(mean_w)]);
disp(['Mean of X[n] = ', num2str(mean_x)]);
disp(['Variance of W[n] = ', num2str(var_w)]);
disp(['Variance of X[n] = ', num2str(var_x)]);

[Rx, lags_x] = xcorr(x, 'biased');
[Rw, lags_w] = xcorr(w, 'biased');

Rx_norm = Rx / max(Rx);
Rw_norm = Rw / max(Rw);

[Px, fx] = pwelch(x, [], [], [], 1);
[Pw, fw] = pwelch(w, [], [], [], 1);

figure;
subplot(2,1,1);
histogram(w, 50, 'Normalization', 'pdf');
title('Histogram of White Gaussian Noise W[n]');
xlabel('Amplitude');
ylabel('PDF');

subplot(2,1,2);
histogram(x, 50, 'Normalization', 'pdf');
title('Histogram of Output Colored Gaussian Process X[n]');
xlabel('Amplitude');
ylabel('PDF');

figure;
subplot(2,1,1);
stem(lags_w, Rw_norm, 'filled');
xlim([-20 20]);
title('Normalized Autocorrelation of White Noise W[n]');
xlabel('Lag');
ylabel('R_W[k]');

subplot(2,1,2);
stem(lags_x, Rx_norm, 'filled');
xlim([-20 20]);
title('Normalized Autocorrelation of Colored Process X[n]');
xlabel('Lag');
ylabel('R_X[k]');

figure;
subplot(2,1,1);
plot(fw, 10*log10(Pw));
title('PSD of White Noise W[n]');
xlabel('Normalized Frequency');
ylabel('Power/Frequency (dB)');

subplot(2,1,2);
plot(fx, 10*log10(Px));
title('PSD of Colored Process X[n]');
xlabel('Normalized Frequency');
ylabel('Power/Frequency (dB)');

h_auto = xcorr(h, h);   
lags_h = -(length(h)-1):(length(h)-1);

figure;
stem(lags_h, h_auto, 'filled');
title('Theoretical Autocorrelation of X[n]');
xlabel('Lag');
ylabel('R_X[k]');

center = floor(length(Rx)/2) + 1;
Rx_est_small = Rx(center-2:center+2);

disp('Estimated autocorrelation near zero lag:');
disp(Rx_est_small);

disp('Theoretical autocorrelation:');
disp(h_auto);