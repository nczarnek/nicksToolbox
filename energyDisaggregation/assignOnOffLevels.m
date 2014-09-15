%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 11 August 2014
%
% assignOnOffLevels.m
% The purpose of this function is to assign on and off levels from the
% extracted energy features.  This is based on a simple average before the
% midpoint and after the midpoint.
%
% Inputs:
%   featureSet:           prtDataSet containing labeled features and
%                         timestamps
%   bufferInS:            number of seconds before and after the midpoint
%                         to ignore to account for ramp up and ramp down
%
% Outputs:
%   onOffLevels:          prtDataSet containing labeled on and off energy 
%                         levels
%                         - column 1: on
%                         - column 2: off

function onOffLevels = assignOnOffLevels(featureSet,timeInterval,bufferInS)

midIdx = ceil(featureSet.nFeatures/2);

utcBuffer = bufferInS/86400;

bufferLength = roundodd(utcBuffer/timeInterval);

%% Reverse the order of features for all off events.
onOffLogicals = [featureSet.observationInfo.on]';

featureSet.data(~onOffLogicals,:) = featureSet.data(~onOffLogicals,end:-1:1);

onOffLevels = prtDataSetClass('data',zeros(featureSet.nClasses,2));

onOffLevels.targets = ones(featureSet.nClasses,1) * featureSet.uniqueClasses(1);

%% Go through each class.
for cInc = 1:featureSet.nClasses
  onFocus                       = featureSet.data(featureSet.targets == featureSet.uniqueClasses(cInc),midIdx + bufferLength:end);
  % on
  onOffLevels.data(cInc,1)      = mean(onFocus(:));
  
  offFocus                      = featureSet.data(featureSet.targets == featureSet.uniqueClasses(cInc),1:midIdx - bufferLength);
  % off
  onOffLevels.data(cInc,2)      = mean(offFocus(:));
  % class
  onOffLevels.targets(cInc)     = featureSet.uniqueClasses(cInc);
  
  onOffLevels.classNames(cInc)  = featureSet.classNames(cInc);
end

featureNames = {'on','off'};

onOffLevels = onOffLevels.setFeatureNames(featureNames);

fInfo = struct('onLogical',{1 0});
onOffLevels = onOffLevels.setFeatureInfo(fInfo);

end


function S = roundodd(S)
% This local function rounds the input to nearest odd integer.
idx = mod(S,2)<1;
S = floor(S);
S(idx) = S(idx)+1;
end