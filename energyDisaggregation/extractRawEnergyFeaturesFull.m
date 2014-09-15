%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 11 August 2014
%
% extractRawEnergyFeaturesFull.m
% The purpose of this function is to extract raw energy features from an
% energyDataSet surrounding events.  This is similar to
% extractRawEnergyFeatures, but it uses full sets rather than individual
% time series
%
% Inputs:
%   ds:                     energyDataSet from which the features will be
%                           extracted
%
%   eventTimes:             structure containing the following:
%                           - onEventsTimes
%                           - offEventsTimes
%                           - classNumber
%                           - className
%
%   halfWindowInS:          size of one side of the extraction window
%
%   varargin:               0 or 1 to indicate baseline subtraction
%                           - default is 1
%
% Outputs:
%   energyFeats:            prtDataSet
%                           - features are extracted from the input ds
%                           - 'on' or 'off' in observationInfo tells what
%                             type of event occurred
%                           - class label is the same as
%                             eventTimes.classNumber or
%                             featureInfo.pecanClass from the input ds

function energyFeats = extractRawEnergyFeaturesFull(ds,eventTimes,halfWindowInS,varargin)

%% Check if the baseline should be removed.
if ~isempty(varargin)
  removeBaseline = varargin{1};
else
  removeBaseline = 1;
end

%% Create the output feature set.
energyFeats = prtDataSetClass;

%% Set up the input dataset times.
timeStamps = [ds.observationInfo.times]';

timeInterval = timeStamps(2) - timeStamps(1); % UTC

halfWindowLength = round(halfWindowInS/86400/timeInterval);

inputFeatureInfo = ds.getFeatureInfo;

%% Go through each of the features.
for fInc = 1:ds.nFeatures
  onFeats = [];
  offFeats = [];
  
  onTS = [];
  offTS = [];
  
  removeOns = false(size(eventTimes(fInc).onEventsTimes));
  removeOffs = false(size(eventTimes(fInc).offEventsTimes));
  
  
  if removeBaseline
    for eInc = 1:size(eventTimes(fInc).onEventsTimes,1)
      try
        midPoint      = find(timeStamps == eventTimes(fInc).onEventsTimes(eInc));
        currentFeats  = ds.data(midPoint - halfWindowLength:midPoint + halfWindowLength,fInc)';
        
        onFeats       = cat(1,onFeats,currentFeats - min(currentFeats));
        onTS          = cat(1,onTS,timeStamps(midPoint));
      catch
        removeOns(eInc) = true;
      end
    end
    
    for eInc = 1:size(eventTimes(fInc).offEventsTimes,1)
      try
        midPoint      = find(timeStamps == eventTimes(fInc).offEventsTimes(eInc));
        currentFeats  = ds.data(midPoint - halfWindowLength:midPoint + halfWindowLength,fInc)';
        
        offFeats      = cat(1,offFeats,currentFeats - min(currentFeats));
        offTS         = cat(1,offTS,timeStamps(midPoint));
      catch
        removeOffs(eInc) = true;
      end
    end
    
    %% Add the features to the feature set.
    currentFeatures = prtDataSetClass;
    
    if ~isempty(onFeats) && ~isempty(offFeats)
      currentFeatures.data            = cat(1,onFeats,offFeats);
      currentFeatures.targets         = inputFeatureInfo(fInc).pecanClass * ...
        ones(currentFeatures.nObservations,1);
      currentFeatures.classNames      = ds.getFeatureNames(fInc);
      
      onOrOff                         = cat(1,ones(size(onFeats,1),1),zeros(size(offFeats,1),1));
      onOffTS                         = cat(1,onTS,offTS);
      
      obsInfo                         = struct('on',num2cell(onOrOff),'times',num2cell(onOffTS));
      currentFeatures                 = currentFeatures.setObservationInfo(obsInfo);
    elseif ~isempty(onFeats)
      currentFeatures.data            = onFeats;
      currentFeatures.targets         = inputFeatureInfo(fInc).pecanClass * ...
        ones(currentFeatures.nObservations,1);
      currentFeatures.classNames      = ds.getFeatureNames(fInc);

      
      onOrOff                         = ones(size(onFeats,1),1);
      onOffTS                         = onTS;
      
      obsInfo                         = struct('on',num2cell(onOrOff),'times',num2cell(onOffTS));
      currentFeatures                 = currentFeatures.setObservationInfo(obsInfo);
    elseif ~isempty(offFeats)
      currentFeatures.data            = offFeats;
      currentFeatures.targets         = inputFeatureInfo(fInc).pecanClass * ...
        ones(currentFeatures.nObservations,1);
      currentFeatures.classNames      = ds.getFeatureNames(fInc);
      
      onOrOff                         = zeros(size(offFeats,1),1);
      onOffTS                         = offTS;
      
      obsInfo                         = struct('on',num2cell(onOrOff),'times',num2cell(onOffTS));
      currentFeatures                 = currentFeatures.setObservationInfo(obsInfo);
    end
    
    %% Add to the overall feature set.
    if currentFeatures.nObservations >0
      energyFeats = catObservations(energyFeats,currentFeatures);
      
    end
    
    
    
    
    
    
  else
    for eInc = 1:size(eventTimes(fInc).onEventsTimes,1)
      try
        midPoint      = find(timeStamps == eventTimes(fInc).onEventsTimes(eInc));
        currentFeats  = ds.data(midPoint - halfWindowLength:midPoint + halfWindowLength,fInc)';
        
        onFeats       = cat(1,onFeats,currentFeats);
        onTS          = cat(1,onTS,timeStamps(midPoint));
      catch
        removeOns(eInc) = true;
      end
    end
    
    for eInc = 1:size(eventTimes(fInc).offEventsTimes,1)
      try
        midPoint      = find(timeStamps == eventTimes(fInc).offEventsTimes(eInc));
        currentFeats  = ds.data(midPoint - halfWindowLength:midPoint + halfWindowLength,fInc)';
        
        offFeats      = cat(1,offFeats,currentFeats);
        offTS         = cat(1,offTS,timeStamps(midPoint));
      catch
        removeOffs(eInc) = true;
      end
    end
    
    %% Add the features to the feature set.
    currentFeatures = prtDataSetClass;
    
    if ~isempty(onFeats) && ~isempty(offFeats)
      currentFeatures.data            = cat(1,onFeats,offFeats);
      currentFeatures.targets         = inputFeatureInfo(fInc).pecanClass * ...
        ones(currentFeatures.nObservations,1);
      
      onOrOff                         = cat(1,ones(size(onFeats,1),1),zeros(size(offFeats,1),1));
      onOffTS                         = cat(1,onTS,offTS);
      currentFeatures.classNames      = ds.getFeatureNames(fInc);
      
      obsInfo                         = struct('on',num2cell(onOrOff),'times',num2cell(onOffTS),'className',className);
      currentFeatures                 = currentFeatures.setObservationInfo(obsInfo);
    elseif ~isempty(onFeats)
      currentFeatures.data            = onFeats;
      currentFeatures.targets         = inputFeatureInfo(fInc).pecanClass * ...
        ones(currentFeatures.nObservations,1);
      
      onOrOff                         = ones(size(onFeats,1),1);
      onOffTS                         = onTS;
      currentFeatures.classNames      = ds.getFeatureNames(fInc);
      
      obsInfo                         = struct('on',num2cell(onOrOff),'times',num2cell(onOffTS),'className',className);
      currentFeatures                 = currentFeatures.setObservationInfo(obsInfo);
    elseif ~isempty(offFeats)
      currentFeatures.data            = offFeats;
      currentFeatures.targets         = inputFeatureInfo(fInc).pecanClass * ...
        ones(currentFeatures.nObservations,1);
      
      onOrOff                         = zeros(size(offFeats,1),1);
      onOffTS                         = offTS;
      currentFeatures.classNames      = ds.getFeatureNames(fInc);
      
      obsInfo                         = struct('on',num2cell(onOrOff),'times',num2cell(onOffTS),'className',className);
      currentFeatures                 = currentFeatures.setObservationInfo(obsInfo);
    end
    
    %% Add to the overall feature set.
    if currentFeatures.nObservations >0
      energyFeats = catObservations(energyFeats,currentFeatures);
    end
  end
end

end
% 
% function S = roundodd(S)
% % This local function rounds the input to nearest odd integer.
% idx = mod(S,2)<1;
% S = floor(S);
% S(idx) = S(idx)+1;
% end

