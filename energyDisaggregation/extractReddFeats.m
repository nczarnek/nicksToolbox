%% Nicholas Czarnek
% 14 March 2014
% SSPACISS Laboratory, Duke University
%
% extractReddFeats.m
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
%   timeBuffer        - do you want to leave any space between the event and
%                       the calculation windows?
%                     - this is in units of seconds
%   calculationWindow - how many samples are needed per feature?
%   keepTargets       - logical 1 to maintain targets from input data
%                     - 0 to reassign
%                     - note that this requires a singular colsOfInterest
%
% Outputs:
%   houseFeats        - prtDataSet
%                     - column 1: difference of gaussian means before and after
%                     - column 2: gaussian mean before
%                     - column 3: gaussian std dev before
%                     - column 4: gaussian mean after
%                     - column 5: gaussian std dev before
%                     - column 6: max absolute difference from Gaussian
%                                 means. useful for transients
%                     - column 7: times

function houseFeats = extractReddFeats(houseData,colsOfInterest,eventTimes,...
  timeBuffer,calculationWindow,keepTargets)

houseFeats = prtDataSetClass;

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

%% Create arrays of the last events.
nearestLast = [min(houseData.data(:,end));eventTimes(1:end-1)];
nearestNext = [eventTimes(2:end);max(houseData.data(:,end))];

[lastId,~] = ismember(houseData.data(:,end),nearestLast);
lastId = find(lastId);

[nextId,~] = ismember(houseData.data(:,end),nearestNext);
nextId = find(nextId);


for colOfInterest = colsOfInterest
  %% Loop through all of the events.
  for eventIdx = 1:max(size(lastId))
%     ticStart = tic;
    
    dataIndex = dataIdx(eventIdx);
    
    lastPoint = lastId(eventIdx);
    nextPoint = nextId(eventIdx);
    
    % Calculate the features before and after the event
    %% Gaussian mean and std before the event
    beforeEnd = max(dataIndex - timeBuffer - 1,1);
    beforeStart = max(beforeEnd - calculationWindow,1);
    
    meanBefore = mean(houseData.data(beforeStart:beforeEnd,colOfInterest));
    stdBefore  = std(houseData.data(beforeStart:beforeEnd,colOfInterest));
    
    %% Gaussian mean and std after the event.
    afterStart = dataIndex + timeBuffer + 1;
    afterEnd   = min(afterStart + calculationWindow,dataIdx(end));
    
    meanAfter = mean(houseData.data(afterStart:afterEnd,colOfInterest));
    stdAfter  = std(houseData.data(afterStart:afterEnd,colOfInterest));
    
    %% Gaussian difference.
    meanDiff =  meanAfter - meanBefore;
    
    %% Max spike level - could be useful for transients.
    maxData = max(houseData.data(beforeStart:afterEnd,colOfInterest));
    maxSpike = max(maxData - meanBefore,maxData - meanAfter);
    
    %% Fill in the dataset.
    currentFeats.data = [meanDiff meanBefore stdBefore meanAfter stdAfter maxSpike eventTimes(eventIdx)];
    
    if ~keepTargets && ~isempty(houseData.targets)
      currentFeats.targets = colOfInterest*ones(currentFeats.nObservations);
    end
    
    %% Concatenate onto the full dataset.
    houseFeats = catObservations(houseFeats,currentFeats);
    
%     ticStop = toc(ticStart);
  end
end

if keepTargets && ~isempty(houseData.targets)
  houseFeats.targets = newTargets(1:houseFeats.nObservations);
end