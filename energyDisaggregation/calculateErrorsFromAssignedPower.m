%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 13 August 2014
%
% calculateErrorsFromAssignedPower.m
% The purpose of this function is to calculate various error metrics based
% on assiged power.
%
% Inputs:
%   truePower:           prtDataSet with the true power of
%                        different devices held within data
%
%   assignedPower:       prtDataSet with assigned power
%
% Note that the number of features in truePower and assignedPower do not
% have to be equal if power was only assigned to a few devices.
%
% Outputs:
%   errorSet:            prtDataSet containing the following
%                        - errors stored in "data"
%                        - error type in "targets" and "classNames"
%                        - feature type in "featureInfo" and "featureNames"


function errorSet = calculateErrorsFromAssignedPower(truePower,assignedPower)

percentEnergyExplained = zeros(assignedPower.nFeatures,1);
absError = zeros(assignedPower.nFeatures,1);

errorSet = prtDataSetClass('data',zeros(4,assignedPower.nFeatures),...
  'targets',[1:4]','featureInfo',assignedPower.featureInfo,...
  'featureNames',assignedPower.getFeatureNames);

errorSet.classNames = {'RMS','percentEnergyExplained','meanNormError','chanceRMS'};

aggregateTotalEnergy = sum(truePower.data(:,1));

trueClasses = [truePower.featureInfo.pecanClass];
assignedClasses = [assignedPower.featureInfo.pecanClass];

% What time was spanned in seconds?
timeSpanned = min(diff([truePower.observationInfo.times])) * truePower.nObservations * 86400;

for fInc = 1:assignedPower.nFeatures
  %% Find the same class in both assigned and true.
  trueClassIdx = find(trueClasses == assignedClasses(fInc));
  
  %% Calculate RMS
  errorSet.data(1,fInc) = sqrt(1/timeSpanned * ...
      sum((truePower.data(:,trueClassIdx) - assignedPower.data(:,fInc)).^2));
  
  %% Calculate percent energy explained
  errorSet.data(2,fInc) = sum(assignedPower.data(:,fInc))/aggregateTotalEnergy;
  
  %% Calculate the mean normalized error.
  errorSet.data(3,fInc) = abs(sum(truePower.data(:,trueClassIdx)) - ...
      sum(assignedPower.data(:,fInc)))/sum(truePower.data(:,trueClassIdx));
  
  %% Calculate chance RMS according to the mean of the current device's true power.
  meanDeviceSignal = ones(truePower.nObservations,1) * ...
      mean(truePower.data(:,trueClassIdx));
  
  errorSet.data(4,fInc) = sqrt(1/timeSpanned * ...
      sum((truePower.data(:,trueClassIdx) - meanDeviceSignal).^2));
end