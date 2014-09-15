%% Nicholas Czarnek
% 26 May 2014
% SSPACISS Laboratory, Duke University
%
% nick_killLowAnd60.m
% This function takes in eeg data and kills low frequency trends below 0.5
% Hz and adds a Notch filter around 60 Hz and all multiples.

function powerOut = nick_killLowAnd60(eegPowerSpectrum,eegFREQS)

numNotches = round(max(eegFREQS)/60);

% 1 Hz
notchWidth = 1;

baseFreq = 60;

%% Low frequency trends.
notchIdx = find(abs(eegFREQS) <= 0.5);

for notchInc = 1:numNotches
  notchIdx = [notchIdx;...
    find(abs(eegFREQS)>=baseFreq*notchInc - notchWidth & ...
    abs(eegFREQS)<=baseFreq*notchInc + notchWidth)];
end


%% Kill the frequencies.
powerOut = eegPowerSpectrum;

powerOut(:,notchIdx) = 0;