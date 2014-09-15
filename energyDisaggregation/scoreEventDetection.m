function scoredOutputs = scoreEventDetection(detectedConfidences,trueTimes,haloInS,varargin)
% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 6 August 2014
%
% scoreEventDetection.m
% The purpose of this script is to determine how well different event
% detection modules worked.
%
% INPUTS: Some fields of the input structures are not used
%   detectedConfidences:     structure with the following important information
%     confidences               - confidence outputs from event detection module
%     timeStamps                - time stamps for all of the confidences
%
%   trueTimes:                structure containing the following
%     onEventsTimes             - times marked as on
%     offEventsTimes            - times marked as off
%
%   haloInS:                  margin in s allowed for considering an event as a 
%                             true event.  If the margin is 5 s, a true event at 10
%                             s would be found if the detection module identified
%                             an event anywhere within 5-15 s.
%   varargin:                 quick option
%                             - set to 0 to use all unique confidences
%                             - set to 1 to use 1000 unique between 0 and
%                               max
%
% OUTPUTS:
%   scoredOutputs:
%     onRoc                     - Nx2 matrix of Pd and FA/hr for on events
%     offRoc                    - Nx2 matrix of Pd and FA/hr for off events

%% Find the unique values in the input confidences
onLogicals = detectedConfidences.confidences >= 0 ;
offLogicals = detectedConfidences.confidences <= 0 ;

uniqueOns = unique(detectedConfidences.confidences(onLogicals));
uniqueOffs = unique(detectedConfidences.confidences(offLogicals));

if ~isempty(varargin)
  uniqueOns = linspace(0,max(detectedConfidences.confidences),1000)';
  uniqueOffs = linspace(0,min(detectedConfidences.confidences),1000)';
end


uniqueOns = cat(1,uniqueOns,max(uniqueOns)+.01);
uniqueOffs = -cat(1,min(uniqueOffs)-.01,uniqueOffs);

uniqueOns = sort(uniqueOns);
uniqueOffs = sort(uniqueOffs);

utcHalo = haloInS/86400;

utcHour = 1/24;

nHours = (max(detectedConfidences.timeStamps) - min(detectedConfidences.timeStamps))/utcHour;

% Initialize the rocs.  First column is false alarm rate, second is
% sensitivity.
onRoc = zeros(size(uniqueOns,1),2);
offRoc = zeros(size(uniqueOffs,1),2);

%%
%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%
% ON PERFORMANCE
%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%

onDone = zeros(size(uniqueOns,1),1);
nOns = max(size(uniqueOns));
onPercent = [1:nOns]'/nOns;

figure;
fH = plot(onPercent,onDone,'YDataSource','onDone');

tStart = tic;
for onInc = 1:size(uniqueOns,1)
  
  % Current threshold
  onThreshold = uniqueOns(onInc);
  
  % Which points are above the current threshold?
  detectedOn = zeros(size(detectedConfidences.confidences));
  
  detectedOn(detectedConfidences.confidences >= onThreshold) = 1 ;
  
  % Find the regional max
  onMax = imregionalmax(detectedConfidences.confidences);
  
  % Limit them to those points above the current threshold.
  onIdx = logical(onMax .* (detectedOn == 1));
  
  % Keep the time stamps
  detectedOnTS = detectedConfidences.timeStamps(onIdx);
  
  % When were the true events
  trueOn = trueTimes.onEventsTimes;
  
  %% Score it with a sparse matrix.
  nAlarms = size(detectedOnTS,1);
  nTrue = size(trueOn,1);
  
  alarmTruthPairings = sparse(nAlarms,nTrue);
  
  % Check with the halo
  for alarmInc = 1:nAlarms
    for truthInc = 1:nTrue
      % If an event is detected within the halo of a true event, mark that
      % alarm as successful.
      if abs(detectedOnTS(alarmInc) - trueOn(truthInc)) < utcHalo
        alarmTruthPairings(alarmInc,truthInc) = 1;
      end
    end
  end
  
  % How many alarms were in the halo of a true event?
  nAlarmsWithinHaloOfTruth = full(sum(alarmTruthPairings,1));
  truthHits = sum(nAlarmsWithinHaloOfTruth>0);
  
  nTruthWithinHaloOfAlarm = full(sum(alarmTruthPairings,2));
  nFalseAlarms = sum(nTruthWithinHaloOfAlarm == 0);
  
  %% Find the sensitivity and false alarm rate for the current threshold.
  % FAR
  onRoc(onInc,1) = nFalseAlarms/nHours;
  onRoc(onInc,2) = truthHits/nTrue;
  
  %% Progress bar
  onDone(onInc) = 1;
  refreshdata(fH,'caller')
  drawnow
  
end
tStop = toc(tStart);




%%
%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%
% OFF PERFORMANCE
%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%
% For this, negate the off confidences to deal with only positives
tStart = tic;

offDone = zeros(size(uniqueOffs,1),1);
nOffs = max(size(uniqueOffs));
offPercent = [1:nOffs]'/nOffs;

figure;
fH = plot(offPercent,offDone,'YDataSource','offDone');


for offInc = 1:size(uniqueOffs,1)
  % Current threshold
  offThreshold = uniqueOffs(offInc);
  
  % Which points are above the current threshold?
  detectedOff = zeros(size(detectedConfidences.confidences));
  
  detectedOff(-detectedConfidences.confidences >= offThreshold) = 1 ;
  
  % Find the regional max
  offMax = imregionalmax(-detectedConfidences.confidences);
  
  % Limit them to those points above the current threshold.
  offIdx = logical(offMax .* (detectedOff == 1));
  
  % Keep the time stamps
  detectedOffTS = detectedConfidences.timeStamps(offIdx);
  
  % When were the true events
  trueOff = trueTimes.offEventsTimes;
  
  %% Score it with a sparse matrix.
  nAlarms = size(detectedOffTS,1);
  nTrue = size(trueOff,1);
  
  alarmTruthPairings = sparse(nAlarms,nTrue);
  
  % Check with the halo
  for alarmInc = 1:nAlarms
    for truthInc = 1:nTrue
      % If an event is detected within the halo of a true event, mark that
      % alarm as successful.
      if abs(detectedOffTS(alarmInc) - trueOff(truthInc)) < utcHalo
        alarmTruthPairings(alarmInc,truthInc) = 1;
      end
    end
  end
  
  % How many alarms were in the halo of a true event?
  nAlarmsWithinHaloOfTruth = full(sum(alarmTruthPairings,1));
  truthHits = sum(nAlarmsWithinHaloOfTruth>0);
  
  nTruthWithinHaloOfAlarm = full(sum(alarmTruthPairings,2));
  nFalseAlarms = sum(nTruthWithinHaloOfAlarm == 0);
  
  %% Find the sensitivity and false alarm rate for the current threshold.
  % FAR
  offRoc(offInc,1) = nFalseAlarms/nHours;
  offRoc(offInc,2) = truthHits/nTrue;
  
  %% Progress bar
  offDone(offInc) = 1;
  refreshdata(fH,'caller')
  drawnow
end
tStop = toc(tStart);

scoredOutputs.onRoc = onRoc;
scoredOutputs.offRoc = offRoc;
scoredOutputs.onThresholds = uniqueOns;
scoredOutputs.offThresholds = uniqueOffs;