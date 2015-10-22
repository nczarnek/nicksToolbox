%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 18 August 2014
%
% detectEnergyEvents.m
% Based on code originally from Kyle Bradbury, PhD, Duke University.
% The purpose of this function is to detect events from energyDataSets.
%
% detectedEvents = detectEnergyEvents(energyDS,eventParameters,varargin)
%
% This function just wraps detectEventConfidences.
%
% Check the default options for the input to detectEventConfidences below.
%
% Change log:
% 150219:
%   - added parser functionality
%   - removed eventParameters from the inputs


function detectedEvents = detectEnergyEvents(energyDS,varargin)

%% Parse the optional inputs.
options.device = 1:energyDS.nFeatures;
options.detectorType = 'glr';
options.halfWindowInS = 61;
options.threshold = 0.2;
options.smoothFactor = 0.5;
options.bufferLength = 0;
options.extraSmooth = false;
options.extraSmoothWindowInS = 61;

parsedOut = prtUtilSimpleInputParser(options,varargin);


device = parsedOut.device;
detectorType = parsedOut.detectorType;

ds.halfWindowInS = parsedOut.halfWindowInS;
ds.threshold = parsedOut.threshold;
ds.timeStamps = energyDS.getTimesFromUTC('timeScale','days','zeroTimes',false);
ds.smoothFactor = parsedOut.smoothFactor;
ds.bufferLength = parsedOut.bufferLength;
ds.extraSmooth = parsedOut.extraSmooth;
ds.extraSmoothWindowInS = parsedOut.extraSmoothWindowInS;

%%%%%

%%
for dInc = 1:numel(device)
    ds.data = energyDS.data(:,device(dInc));
    detectedEvents(device(dInc)) = detectEventConfidences(ds,'detectorType',detectorType);
end























% 
% if isempty(varargin)
%   for deviceInc = 1:energyDS.nFeatures
%     ds.data = energyDS.data(:,deviceInc);
%     detectedEvents(deviceInc) = detectEventConfidences(ds);
%   end
% else
%   if strcmp(varargin{1},'sobel')
%     for deviceInc = 1:energyDS.nFeatures
%       ds.data = energyDS.data(:,deviceInc);
%       detectedEvents(deviceInc) = detectEventConfidences(ds,'sobel');
%     end
%   else
%     for deviceInc = 1:energyDS.nFeatures
%       ds.data = energyDS.data(:,deviceInc);
%       detectedEvents(deviceInc) = detectEventConfidences(ds);
%     end
%   end
% end