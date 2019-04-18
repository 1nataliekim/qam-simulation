function noisySignal = channel(sentSignal, SNR)
% Add white Gaussian noise to the original signal.
% SNR must be in dB
% noisySignal - the signal with AWGN

noisySignal = awgn(sentSignal,SNR,'measured');

end