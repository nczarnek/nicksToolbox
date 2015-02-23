%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 24 September 2014
%
% timeFinder.m
% eventIdx = timeFinder(dataTimes,eventTimes)
% The purpose of this function is to find the indices of the event times
% based on the input time.  This is useful in case we retain certain
% observations from a prtDataSet, rather than the full file that was
% originally used to truth the data.

function eventIdx = timeFinder(dataTimes,eventTimes)

eventIdx = find(ismember(dataTimes,eventTimes));