%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 29 January 2015
%
% ignoreSpecificEvents.m
% The purpose of this function is to ignore specific events within an input
% time series.
%
% function cleanedTimes = ...
%   ignoreSpecificEvents(eventTimes,ignoredTimes,tRes,varargin)
%
% eventTimes:               - original times
% ignoredTimes:             - times that you want to remove from eventTimes
% tRes:                     - length of a second for the given time scale
% varargin:                 - halo in s such that events within the halo
%                             are ignored


function cleanedTimes = ignoreSpecificEvents(eventTimes,ignoredTimes,tRes,varargin)

if ~isempty(varargin)
    %% ignore any events within a given halo
    haloInS = varargin{1};
    
    if ~isempty(ignoredTimes)
        for igInc = 1:max(size(ignoredTimes))
            startTime = ignoredTimes(igInc)-haloInS*tRes;
            endTime = ignoredTimes(igInc)+haloInS*tRes;
            tossIdx = eventTimes>startTime&eventTimes<endTime;
            
            eventTimes(tossIdx) = [];
        end
    end
    cleanedTimes = eventTimes;
else
    %% ignore only the exact times
    [~,intersectedIdx] = intersect(eventTimes,ignoredTimes);
    
    eventTimes(intersectedIdx) = [];
    
    cleanedTimes = eventTimes;
end

