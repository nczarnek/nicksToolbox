%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 26 May 2014
%
% nick_kaggleExtractPSD
% This function extracts the frequency features from the patients in the
% Kaggle dataset based on those features described in:
% Park, Yun, et al. "Seizure prediction with spectral power of EEG using cost?sensitive support vector machines." Epilepsia 52.10 (2011): 1761-1770.

function psdFeats = nick_kaggleExtractPSD(inputData)

psdFeats = prtDataSetClass;
psdFeats.userData = inputData.userData;
psdFeats.targets = inputData.targets;


%% Define the frequency limits.
fStart = [0.5 4 8 13 30 53 75 103];
fStop = [4 8 13 30 47 75 97 128];

numBands = max(size(fStart));

%% Go through each row, and extract the frequency features from each channel.
nChans = size(fieldnames(inputData.userData.channels),1);
if ceil(inputData.userData.freq) == 5000
  nObs = 500;
else
  nObs = ceil(inputData.userData.freq);
end
fs = nObs;
xTimes = 0:1/nObs:1-1/nObs;

nFFT = 2.^nextpow2(nObs);
deltaFREQ = fs/nFFT;
eegFREQS = [-fs/2:deltaFREQ:fs/2-deltaFREQ];

psdFeats.data = zeros(inputData.nObservations,nChans*max(size(fStart)));

observationError = zeros(inputData.nObservations,1);
errorChannels = cell(inputData.nObservations,1);

for obsInc = 1:inputData.nObservations
  rowNow = inputData.data(obsInc,:);
  
  currentData = [reshape(rowNow',nObs,nChans)]';
  
  zedData = zscore(currentData')';
  
  eegDATA = fftshift(fft(zedData,nFFT,2),2);
  
  eegPowerSpectrum = abs(eegDATA).^2;
  
  totalPower = trapz(eegPowerSpectrum,2) * deltaFREQ;
  
  psdMat = zeros(nChans,max(size(fStart)));
  
  %% Mark observations with all zero values - measurement error
  if any(all(currentData == 0,2))
    observationError(obsInc) = 1;
    
    errorChannels{obsInc} = find(all(currentData == 0,2));
  end
  
  
  %% Go through each frequency band.
  for pBand = 1:max(size(fStart))
    bandIdx = find(abs(eegFREQS) >= fStart(pBand) & abs(eegFREQS) < fStop(pBand));
    
    bandPower = trapz(eegPowerSpectrum(:,bandIdx),2) * deltaFREQ;
    
    psdMat(:,pBand) = bandPower./totalPower;
  end
  
  reshapedPsd = reshape(psdMat',1,nChans*max(size(fStart)));
  
  %   if any(isnan(reshapedPsd))
  %     keyboard
  %   end
  %
  psdFeats.data(obsInc,:) = reshapedPsd;
end

%% Handle the outliers
notError = ~logical(observationError);

zCorrect = prtPreProcZmuv;

goodData = psdFeats.retainObservations(notError);

zCorrect = zCorrect.train(goodData);

zMeans = reshape(zCorrect.means,numBands,nChans)';

%% Go through each bad observation
badIdx = find(observationError);

if ~isempty(badIdx)
  for badInc = 1:max(size(badIdx))
    currentIdx = badIdx(badInc);
    
    badChannels = errorChannels{currentIdx};
    
    currentVector = psdFeats.retainObservations(currentIdx);
    
    currentBlock = reshape(currentVector.data,numBands,nChans)';
    
    for chanInc = 1:max(size(badChannels))
      currentBlock(badChannels(chanInc),:) = zMeans(badChannels(chanInc),:);
    end
    
    replacedVector = reshape(currentBlock',1,numBands*nChans);
    
    psdFeats.data(currentIdx,:) = replacedVector;
  end
end
