# # Cepstrum-Based Adaptive Speech Enhancement for Hearing Aid Applications

A digital signal processing (DSP) framework in **MATLAB** implementing homomorphic deconvolution, real power cepstrum analysis, and low-time liftering to enhance degraded speech signals for digital hearing aids.

The algorithm separates the convolved vocal-tract transfer function from the glottal excitation source, suppressing background noise (10 dB AWGN) while preserving critical speech formants and fundamental pitch harmonics ($F_0$).

---

## 🔬 Theoretical Background

Speech production is modeled as the convolution of a glottal excitation signal $e[n]$ with the vocal-tract impulse response $v[n]$:

$$s[n] = e[n] * v[n]$$

In the frequency domain, convolution becomes multiplication:

$$S(\omega) = E(\omega) \cdot V(\omega)$$

Taking the complex logarithm transforms multiplication into addition:

$$\log\vert{}S(\omega)\vert{} = \log\vert{}E(\omega)\vert{} + \log\vert{}V(\omega)\vert{}$$

Applying the Inverse Discrete Fourier Transform (IDFT) maps the log-spectrum into the **quefrency domain** (the real cepstrum $c[n]$):

$$c[n] = \mathcal{F}^{-1}\{\log\vert{}S(\omega)\vert{}\}$$

* **Low-Quefrency Region ($< 12.5\text{ ms}$):** Represents slowly varying vocal-tract resonances (formants).
* **High-Quefrency Region ($> 12.5\text{ ms}$):** Contains periodic excitation spikes corresponding to the fundamental pitch period ($T_0$).

By applying a **low-time lifter** (quefrency-domain filter), the spectral envelope is smoothed and separated from noise and excitation, enabling adaptive spectral gain estimation without musical noise artifacts.

---

## 🏛 Processing Pipeline

```text
 Noisy Input Speech x[n] (fs = 8 kHz)
                 │
                 ▼
   ┌───────────────────────────┐
   │      Hamming Window       │  Reduces spectral side-lobe leakage
   └─────────────┬─────────────┘
                 ▼
   ┌───────────────────────────┐
   │         FFT & Log         │  Computes log power spectrum: log(|X|^2 + eps)
   └─────────────┬─────────────┘
                 ▼
   ┌───────────────────────────┐
   │           IFFT            │  Maps to Quefrency Domain (Real Cepstrum)
   └─────────────┬─────────────┘
                 ▼
   ┌───────────────────────────┐
   │     Low-Time Lifter       │  Applies rectangular lifter (cutoff: 12.5 ms)
   └─────────────┬─────────────┘
                 ▼
   ┌───────────────────────────┐
   │  Spectral Gain Estimator  │  Subtracts noise floor to compute adaptive gain
   └─────────────┬─────────────┘
                 ▼
   ┌───────────────────────────┐
   │ Phase Recombination & IFFT│  Recombines with original phase -> x_enhanced[n]
   └───────────────────────────┘
