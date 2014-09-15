%% Nicholas Czarnek
% 14 March 2014
% SSPACISS Laboratory, Duke University
%
% extractReddEventData.m
% The purpose of this function is to extract features surrounding events in
% REDD dataset based on events sent in.  It is assumed that the last
% columns of the input dataset is timestamps.
%
% Inputs:
%   houseData         - input dataset.  if this is the mains file, features
%                       will be extracted from the aggregate load. if this is
%                       the components file, features will be extracted from
%                       each component
%   colOfInterest     - which column do you want?
%                     - if this is a vector, the returned dataset has
%                       concatenated features with targets corresponding to
%                       column number
%   eventTimes        - what are the times of interest?
%                       these should be UTC format
%   calculationWindow - how many samples are needed per feature?
%   keepTargets       - logical 1 to maintain targets from input data
%                     - 0 to reassign
%                     - note that this requires a singular colsOfInterest
%
% Outputs:
%   houseFeats        - prtDataSet
%                     - data: central column is event

function houseFeats = extractReddEventData(houseData,colsOfInterest,eventTimes,...
  calculationWindow,keepTargets)

houseFeats = prtDataSetClass;

houseFeats.userData.eventTimes = eventTimes;
houseFeats.userData.device = houseData.userData.components{colsOfInterest(1)};

% Sort events for convenience.
eventTimes = sort(eventTimes);

[~,eventIndices] = ismember(houseData.data(:,end),eventTimes);

eventIndices = find(eventIndices);

if keepTargets && ~isempty(houseData.targets)
  newTargets = houseData.targets(eventIndices);
end

currentFeats = prtDataSetClass;


%% Label the indices of the events.
[dataIdx,~] = ismember(houseData.data(:,end),eventTimes);
dataIdx = find(dataIdx);

for colOfInterest = colsOfInterest
  %% Loop through all of the events.
  for eventIdx = 1:max(size(dataIdx))
%     ticStart = tic;
    
    dataIndex = dataIdx(eventIdx);
    
    currentFeats.data = houseData.data(dataIndex - calculationWindow:dataIndex + calculationWindow,colOfInterest)';
    
    if ~keepTargets && ~isempty(houseData.targets)
      currentFeats.targets = colOfInterest;
    end
    
    %% Concatenate onto the full dataset.
    houseFeats = catObservations(houseFeats,currentFeats);
    
%     ticStop = toc(ticStart);
  end
end

if keepTargets && ~isempty(houseData.targets)
  houseFeats.targets = newTargets(1:houseFeats.nObservations);
end