%% Nicholas Czarnek
% 26 May 2014
% SSPACISS Laboratory, Duke University
%
% nick_kaggleHjorthActivity.m
% This code is based on code written by Stacy Tantum, PhD, Duke University.
% This function takes in a prtDataSet and outputs a prtDataSet with 
% Hjorth Activity features.
%
% Input:
%   inputData               - prtDataSet with one measurement per row
%                           - it is important to note that a 10 channel
%                             measurement at 100 Hz will yield 1000 columns
%                             per row
%                           - account for this later
%
% Output:
% hMob                      - Hjorth mobility
%                           - for 10 channels and 50 measurements, this
%                             will yield a prtDataSet with 50 observations
%                             and 10 columns

function hMob = nick_kaggleHjorthMobility(inputData)

hMob = prtDataSetClass;
hMob.userData = inputData.userData;

%% What frequency was the data recorded at?
recFreq = inputData.userData.freq;

nChans = size(fieldnames(inputData.userData.channels),1);

blockLength = inputData.nFeatures/nChans;

%% FFT setup
fs = hMob.userData.freq;
nFFT = 2.^nextpow2(blockLength);
deltaFREQ = fs/nFFT;
eegFREQS = [-fs/2:deltaFREQ:fs/2-deltaFREQ]';

%% Go through each block.
for chanInc = 1:nChans
  startMeas = (chanInc - 1)*blockLength + 1;
  endMeas = chanInc*blockLength;
  channelData = inputData.data(:,startMeas:endMeas);
  
  channelMeans = mean(channelData,2);
  
  eegDATA = fftshift(fft(bsxfun(@minus,channelData,channelMeans),nFFT,2));
  
  eegPowerSpectrum = abs(eegDATA).^2;
  
  eegPowerSpectrum = nick_killLowAnd60(eegPowerSpectrum,eegFREQS);
  
  m0 = trapz(eegPowerSpectrum)*deltaFREQ;
  m2 = trapz((eegFREQS.^2).*eegPowerSpectrum)*deltaFREQ;
  
  hMobility = sqrt(m2./m0);
  
  hMob.data = cat(2,hMob.data,hMobility);
end