%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 7 August 2014
%
% establishFeatureSet.m
% The purpose of this function is to establish a set of features based on
% input event times and on an energyDataSet.  Each appliance corresponds to
% a separate class
%
% Inputs:
%   energyDataSet:          the dataset from which you're extracting
%                           devices
%
%   eventTimes:             for an energyDataSet with N devices, eventTimes
%                           is an Nx1 structure with one column 
%                           corresponding to on events and the other
%                           to off events
%                           - the fields for each structure are 
%                             onEventsTime and offEventsTime
%                           - if this is an Nx1 cell matrix, it is assumed
%                             that we are only dealing with on events
%   extractionParameters:   structure with the following
%                           - halfWindowInS
%                           - zeroMin
% 
% Outputs:
%   onFeatureSet:           prtDataSet containing on features
%   offFeatureSet:          prtDataSet containing off features


function [onFeatureSet,offFeatureSet] = establishFeatureSet(energyDataSet,eventTimes,extractionParameters)

if energyDataSet.nFeatures ~= size(eventTimes,1)
  error('Please send in a cell array with an equal size as the number of features being analyzed.')
end

%% Establish the datasets.
onFeatureSet = prtDataSetClass;
offFeatureSet = prtDataSetClass;

eClasses = [energyDataSet.getFeatureInfo.pecanClass]';

%% Go through each of the appliances, and extract data.
for fInc = 1:energyDataSet.nFeatures
  onTimes = eventTimes(fInc).onEventsTime;
  offTimes = eventTimes(fInc).offEventsTime;
  
  %% Set everything up to extract data
  ds.data = energyDataSet.data(:,fInc);
  ds.timeStamps = [energyDataSet.observationInfo.times]';
  
  if isfield(extractionParameters,'halfWindowInS')
    halfWindowInS = extractionParameters.halfWindowInS;
  else
    halfWindowInS = 240;
  end
  
  if isfield(extractionParameters,'zeroMin')
    subtractBaseline = extractionParameters.zeroMin;
  else
    zeroMin = 1;
  end
  
  currentClass = eClasses(fInc);
  
  %% On events
  onEvents = extractRawEnergyFeatures(ds,onTimes,halfWindowInS,subtractBaseline);
  offEvents = extractRawEnergyFeatures(ds,offTimes,halfWindowInS,subtractBaseline);
  
  onDS = prtDataSetClass('data',onEvents.eventFeatures,...
    'targets',currentClass*ones(size(onEvents.eventFeatures,1),1));
  obsInfo = struct('times',num2cell(onEvents.eventTimes));
  onDS = onDS.setObservationInfo(obsInfo);
  onDS = onDS.setClassNames(energyDataSet.getFeatureNames(fInc));
  
  offDS = prtDataSetClass('data',offEvents.eventFeatures,...
    'targets',currentClass*ones(size(offEvents.eventFeatures,1),1));
  obsInfo = struct('times',num2cell(offEvents.eventTimes));
  offDS = offDS.setObservationInfo(obsInfo);
  offDS = offDS.setClassNames(energyDataSet.getFeatureNames(fInc));
  
  if onDS.nObservations>0
    onFeatureSet = catObservations(onFeatureSet,onDS);
  end
  
  if offDS.nObservations>0
    offFeatureSet = catObservations(offFeatureSet,offDS);
  end
  
end





% onClass = eClasses(fInc) - 1;
% offClass = eClasses(fInc);
% onDS = prtDataSetClass('data',onEvents.eventFeatures,'targets',onClass*ones(size(onEvents.eventFeatures,1),1));
% obsInfo = struct('times',num2cell(onEvents.eventTimes));
% onDS = onDS.setObservationInfo(obsInfo);
% onDS = onDS.setClassNames(strcat(energyDataSet.getFeatureNames(fInc),'_on'));

% if onDS.nObservations>0 & offDS.nObservations>0
%   %% Concatenate everything with the original dataset.
%   if fInc == 1
%     energyFeatureSet = catObservations(onDS,offDS);
%   else
%     energyFeatureSet = catObservations(energyFeatureSet,onDS,offDS);
%   end
% elseif onDS.nObservations>0
%   
%   if fInc == 1
%     energyFeatureSet = onDS;
%   else
%     energyFeatureSet = catObservations(energyFeatureSet,onDS);
%   end
% elseif offDS.nObservations>0
%   if fInc == 1
%     energyFeatureSet = offDS;
%   else
%     energyFeatureSet = catObservations(energyFeatureSet,offDS);
%   end
% end
