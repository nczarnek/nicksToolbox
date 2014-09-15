%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 11 August 2014
%
% truthEventsToStruct.m
% The purpose of this function is to convert the truthed events from the
% folder created by Mohammad and Guojing into a usable structure for energy
% assignment.
%

function eventTimes = eventTruthToStruct(energyDataSet,truthDir)

%% How many components were there?
nFeatures = energyDataSet.nFeatures;

classNumbers = [energyDataSet.getFeatureInfo.pecanClass]';

%% Create the structure
eventTimes = struct('onEventsTimes',cell(nFeatures,1),...
  'offEventsTimes',cell(nFeatures,1),'onIdx',cell(nFeatures,1),...
  'offIdx',cell(nFeatures,1),'classNumber',num2cell(zeros(nFeatures,1)),...
  'className',cell(nFeatures,1));

%% Go through each class
for cInc = 1:energyDataSet.nFeatures
  eventTimes(cInc).classNumber = classNumbers(cInc);
  eventTimes(cInc).className   = energyDataSet.getFeatureNames(cInc);
  
  if exist(fullfile(truthDir,[eventTimes(cInc).className{1},'.mat']))
    load(fullfile(truthDir,eventTimes(cInc).className{1}))
    eventTimes(cInc).onEventsTimes    = trueTimes.onTimes;
    eventTimes(cInc).offEventsTimes   = trueTimes.offTimes;
    eventTimes(cInc).onIdx            = trueTimes.onIdx;
    eventTimes(cInc).offIdx           = trueTimes.offIdx;
  end
end