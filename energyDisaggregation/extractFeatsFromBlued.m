%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 18 November 2014
%
% extractRawEnergyFeaturesBlued.m
% The purpose of this function is to extract features from the BLUED
% dataset and any other datasets which have aggregate data and events 
% rather than submetered data.
%
% Inputs:
%   ds:                       - energyDataSet
%   eventTimes:               - structure with:
%                               - onEventsTimes
%                               - offEventsTimes
%                               - classLabel - type of event
%                               - 
%   halfWindowInS:            - how much to the left and right of the event
%                               is desired
%   varargin:                 - 0 or 1 to indicate baseline subtraction
%                             - default is 1
% Outputs:
%   eventFeats:               - structure containing prtDataSets with
%                               features from each of the features within
%                               the input energyDataSet.
%
% Much of this code is similar to that found in
% extractRawEnergyFeaturesFull

function energyFeats = extractFeatsFromBlued(ds,eventTimes,halfWindowInS,varargin)

%% Check if the baseline should be removed.
if ~isempty(varargin)
  removeBaseline = varargin{1};
else
  removeBaseline = 1;
end

%% Create the output feature set.
energyFeats = repmat(struct('eDS',prtDataSetClass),ds.nFeatures,1);

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
    
%     ds.userData.eventTypes = ds.userData.eventTypes(~removeOns);
    
    eventTypes = ds.userData.eventTypes(~removeOns);
    
    if ~isempty(onFeats) && ~isempty(offFeats)
      currentFeatures.data            = cat(1,onFeats,offFeats);
      currentFeatures.targets         = inputFeatureInfo(fInc).pecanClass * ...
        ones(currentFeatures.nObservations,1);
%       currentFeatures.classNames      = ds.getFeatureNames(fInc);
      
      onOrOff                         = cat(1,ones(size(onFeats,1),1),zeros(size(offFeats,1),1));
      onOffTS                         = cat(1,onTS,offTS);
      
      obsInfo                         = struct('on',num2cell(onOrOff),'times',num2cell(onOffTS));
      currentFeatures                 = currentFeatures.setObservationInfo(obsInfo);
    elseif ~isempty(onFeats)
      currentFeatures.data            = onFeats;
      currentFeatures.targets         = reshape(eventTypes,max(size(eventTypes)),1);
      
%       currentFeatures.targets         = reshape(ds.userData.eventTypes,max(size(ds.userData.eventTypes)),1);
%       inputFeatureInfo(fInc).pecanClass * ...
%         ones(currentFeatures.nObservations,1);
%       currentFeatures.classNames      = ds.getFeatureNames(fInc);

      
      onOrOff                         = ones(size(onFeats,1),1);
      onOffTS                         = onTS;
      
      obsInfo                         = struct('on',num2cell(onOrOff),'times',num2cell(onOffTS));
      currentFeatures                 = currentFeatures.setObservationInfo(obsInfo);
    elseif ~isempty(offFeats)
      currentFeatures.data            = offFeats;
      currentFeatures.targets         = inputFeatureInfo(fInc).pecanClass * ...
        ones(currentFeatures.nObservations,1);
%       currentFeatures.classNames      = ds.getFeatureNames(fInc);
      
      onOrOff                         = zeros(size(offFeats,1),1);
      onOffTS                         = offTS;
      
      obsInfo                         = struct('on',num2cell(onOrOff),'times',num2cell(onOffTS));
      currentFeatures                 = currentFeatures.setObservationInfo(obsInfo);
    end
    
    %% Add to the overall feature set.
    if currentFeatures.nObservations >0
      energyFeats(fInc).eDS = currentFeatures;
      
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
    
%     ds.userData.eventTypes = ds.userData.eventTypes(~removeOns);
    
    eventTypes = ds.userData.eventTypes(~removeOns);

    if ~isempty(onFeats) && ~isempty(offFeats)
      currentFeatures.data            = cat(1,onFeats,offFeats);
      currentFeatures.targets         = inputFeatureInfo(fInc).pecanClass * ...
        ones(currentFeatures.nObservations,1);
      
      onOrOff                         = cat(1,ones(size(onFeats,1),1),zeros(size(offFeats,1),1));
      onOffTS                         = cat(1,onTS,offTS);
%       currentFeatures.classNames      = ds.getFeatureNames(fInc);
      
      obsInfo                         = struct('on',num2cell(onOrOff),'times',num2cell(onOffTS),'className',className);
      currentFeatures                 = currentFeatures.setObservationInfo(obsInfo);
    elseif ~isempty(onFeats)
      currentFeatures.data            = onFeats;
      currentFeatures.targets         = reshape(eventTypes,max(size(eventTypes)),1);
      
      onOrOff                         = ones(size(onFeats,1),1);
      onOffTS                         = onTS;
%       currentFeatures.classNames      = ds.getFeatureNames(fInc);
      
      obsInfo                         = struct('on',num2cell(onOrOff),'times',num2cell(onOffTS),'className',className);
      currentFeatures                 = currentFeatures.setObservationInfo(obsInfo);
    elseif ~isempty(offFeats)
      currentFeatures.data            = offFeats;
      currentFeatures.targets         = inputFeatureInfo(fInc).pecanClass * ...
        ones(currentFeatures.nObservations,1);
      
      onOrOff                         = zeros(size(offFeats,1),1);
      onOffTS                         = offTS;
%       currentFeatures.classNames      = ds.getFeatureNames(fInc);
      
      obsInfo                         = struct('on',num2cell(onOrOff),'times',num2cell(onOffTS),'className',className);
      currentFeatures                 = currentFeatures.setObservationInfo(obsInfo);
    end
    
    %% Add to the overall feature set.
    if currentFeatures.nObservations >0
      energyFeats(fInc).eDS = currentFeatures;
    end
  end
end

end