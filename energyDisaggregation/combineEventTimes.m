%% Nicholas Czarnek
% SSPACISS laboratory, Duke University
% 24 August 2014
%
% combineEventTimes.m
% The purpose of this function is to combine the event times from a
% structure into just one aggregate.

function combinedTimes = combineEventTimes(timeStruct)

combinedTimes = struct('onIdx',[],'offIdx',[],'onEventsTimes',[],'offEventsTimes',[],'classNumber',[],'className',[]);

for fInc = 1:max(size(timeStruct))
  combinedTimes.onIdx = cat(1,combinedTimes.onIdx,timeStruct(fInc).onIdx);
  combinedTimes.offIdx = cat(1,combinedTimes.offIdx,timeStruct(fInc).offIdx);
  
  combinedTimes.onEventsTimes = cat(1,combinedTimes.onEventsTimes,timeStruct(fInc).onEventsTimes);
  combinedTimes.offEventsTimes = cat(1,combinedTimes.offEventsTimes,timeStruct(fInc).offEventsTimes);
  
  
end

combinedTimes.classNumber = 1;

combinedTimes.className = 'use';