%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 7 August 2014
%
% getOnOffLevels.m
% The purpose of this function is to establish the energies that should be
% assigned to the on and off periods during the energy assignment phase.
%
% Inputs:
%   eventFeatures:    matrix of features all ordered as on then off or vice
%                     versa
%   bufferSize:       number of samples around the midpoint to ignore in
%                     the level calculation
%
% Outputs:
%   levels:           structure with
%                     - on    - assumed to be the max
%                     - off   - assumed to be the min


function levels = getOnOffLevels(eventFeatures,bufferSize,classLabel)

midPoint        = floor(size(eventFeatures,2)/2) + 1;

beforeFeatures  = eventFeatures(:,1:midPoint-1-bufferSize);
afterFeatures   = eventFeatures(:,midPoint+1+bufferSize:end);

beforeMean      = mean(beforeFeatures(:));
afterMean       = mean(afterFeatures(:));

levels.on       = max(beforeMean,afterMean);
levels.off      = min(beforeMean,afterMean);
levels.class    = classLabel;