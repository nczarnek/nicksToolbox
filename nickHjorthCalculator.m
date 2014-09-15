%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% Generic Hjorth Calculator
% The purpose of this script is to act as a test bed for determining the
% Hjorth parameters of different types of shapes and data formats.  This is
% mostly an exploratory script. Restrict the length of the input to roughly
% 100 times the window length over which the parameter is calculated
%

function hjParams = nickHjorthCalculator(rawData)

hjorthWindowSec = 20;
pctOverlap = 0;
samplingFrequency = 256;
integralBandwith = samplingFrequency/2;
notchCenters = [50 100];
notchBandwidth = 2;
lowerBandLimit = .5;
upperBandLimit = 40;
plotOption = 1;
bpfOption = 1;

% For each window, read data, process, and write to an output array
windowIncrementSec = hjorthWindowSec * ...
    (1-(pctOverlap/100));

% Data length.
dataLength = size(rawData,1);

% Specify the length of the block used to calculate the Hjorth parameter.
blockLength = hjorthWindowSec * ...
    samplingFrequency;

% First window
Wi = 1;

fs = samplingFrequency;

hjParams.hjorthActivity = zeros(floor(size(rawData,1)/blockLength),1);
hjParams.hjorthMobility = zeros(floor(size(rawData,1)/blockLength),1);
hjParams.hjorthComplexity = zeros(floor(size(rawData,1)/blockLength),1);

eegDataBlockStart = 1;
eegDataBlockEnd = blockLength;

while (eegDataBlockEnd <= dataLength && Wi<1e6)
    % Wi portion - fail safe for large data sets
    currentBlock = rawData(eegDataBlockStart:eegDataBlockEnd,1);
    
    % Block size is necessary for energy normalization between domains.
    blockSize = size(currentBlock,1);
    
    % Find the mean of the block. Hjorth parameters all assume 0 mean.
    meanBlock = mean(currentBlock);
    
    % Calculate the power spectrum of the zero mean signal.
%     nFFT = 2.^nextpow2(size(currentBlock,1));
    eegDATA = fftshift(fft(currentBlock - meanBlock)) / ...
        sqrt(blockSize);
    deltaFREQ = fs/blockSize;
    deltaFREQrad = deltaFREQ * 2 * pi;
    eegFREQS = [-fs/2:deltaFREQ:fs/2-deltaFREQ]';
    
    % Frequencies within specified bandwidth
    eegFreqIdx = find(eegFREQS >= -integralBandwith & eegFREQS <= integralBandwith);
    
    eegPowerSpectrum = abs(eegDATA(eegFreqIdx)).^2;
    eegFREQS = eegFREQS(eegFreqIdx);
    eegFREQSrad = eegFREQS * 2 * pi;
    
    % Apply ideal notch filter to eliminate 50 Hz noise and harmonics.
    notchIdx = [];
    for thisNotch = 1:size(notchCenters,2)
        notchIdx = [notchIdx; ...
            find(abs(eegFREQS) >= notchCenters(thisNotch)-0.5*notchBandwidth & ...
            abs(eegFREQS) <= notchCenters(thisNotch)+0.5*notchBandwidth)];
    end
    eegPowerSpectrum(notchIdx) = 0;
    
    lowBandIdx = [];
    highBandIdx = [];
    if bpfOption == 1
        % Low stop
        lowBandIdx = [lowBandIdx; find(abs(eegFREQS) <= lowerBandLimit)];
        eegPowerSpectrum(lowBandIdx) = 0;
        
        highBandIdx = [highBandIdx; find(abs(eegFREQS) >= upperBandLimit)];
        eegPowerSpectrum(highBandIdx) = 0;
    end
    
    % Calculate the even moments of the power spectrum
    m0 = trapz(eegPowerSpectrum)*deltaFREQrad;
    m2 = trapz((eegFREQSrad.^2).*eegPowerSpectrum)*deltaFREQrad;
    m4 = trapz((eegFREQSrad.^4).*eegPowerSpectrum)*deltaFREQrad;
    
    hjorthActivity(Wi,1) = m0;
    hjorthMobility(Wi,1) = sqrt(m2./m0);
    hjorthComplexity(Wi,1) = sqrt(m4./m2)./sqrt(m2./m0);
    
    if isnan(hjorthActivity(Wi,1))
        hjorthActivity(Wi,1) = mean(hjorthActivity(max(1,Wi-100):Wi-1,1));
        % anomaly in data, use average of last 100 pieces
    end
    
    if isnan(hjorthMobility(Wi,1))
        hjorthMobility(Wi,1) = mean(hjorthMobility(max(1,Wi-100):Wi-1,1));
        % anomaly in data, use average of last 100 pieces
    end

    if isnan(hjorthComplexity(Wi,1))
        hjorthComplexity(Wi,1) = mean(hjorthComplexity(max(1,Wi-100):Wi-1,1));
        % anomaly in data, use average of last 100 pieces
    end

    % Increment the blocks and window number
    eegDataBlockStart = eegDataBlockStart + blockLength;
    eegDataBlockEnd = eegDataBlockEnd + blockLength - 1;
    Wi = Wi + 1;
end

hjLength = size(hjorthComplexity,1);

if plotOption == 1
    startTime = 0;
    endTime = startTime + size(rawData,1) * ...
        hjorthWindowSec / ...
        samplingFrequency / ...
        86400;
    xTimes = linspace(startTime,endTime,hjLength);
    
    
    actHandle = figure;
    hold on
    
    plot(xTimes,hjorthActivity);
    xlim([min(xTimes) max(xTimes)])
    xlabel('Time from measurement start (hr)')
    title('Activity','Rotation',0,'HorizontalAlignment','Right')
    
    mobHandle = figure;
    hold on
    
    plot(xTimes,hjorthMobility);
    xlim([min(xTimes) max(xTimes)])
    xlabel('Time from measurement start (hr)')
    title('Mobility','Rotation',0,'HorizontalAlignment','Right')

    
    compHandle = figure;
    hold on
    
    plot(xTimes,hjorthComplexity);
    xlim([min(xTimes) max(xTimes)])
    xlabel('Time from measurement start (hr)')
    title('Complexity','Rotation',0,'HorizontalAlignment','Right')
end