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

%% Parse varargin
options.haloInS = 61;
options.truthTimes = [];
parsedOut = prtUtilSimpleInputParser(options,varargin);
haloInS = parsedOut.haloInS;
truthTimes = parsedOut.truthTimes;

%% Ignore any events within a given halo.
ignoredStart = ignoredTimes - haloInS * tRes;
ignoredEnd = ignoredTimes + haloInS * tRes;

if ~isempty(truthTimes)
    trueStart = truthTimes - haloInS * tRes;
    trueEnd = truthTimes + haloInS * tRes;
end

tossEvent = false(numel(eventTimes),1);

for igInc = 1:numel(ignoredTimes)
    %     startTime = ignoredTimes(igInc) - haloInS * tRes;
    %     endTime = ignoredTimes(igInc) + haloInS * tRes;
    
    %% Check if the event is within the halo of another event
    tossIdx = find(eventTimes>ignoredStart(igInc) & eventTimes<ignoredEnd(igInc));
    
    if ~isempty(truthTimes)
        %% Check each of the events to make sure that it is not also beside a true event
        if any(tossIdx)
            
            for tInc = 1:numel(tossIdx)
                newTruth = trueStart<eventTimes(tossIdx(tInc)) & trueEnd>eventTimes(tossIdx(tInc));
                
                % If any indices were found for newTruth, then don't toss out
                % the current index.
                if any(newTruth)
                    tossIdx(tInc) = 0;
                end
            end
            
            tossIdx(tossIdx == 0) = [];
            
            tossEvent(tossIdx) = true;
        end
    end
    
end

cleanedTimes = eventTimes(~tossEvent);
%
% if ~isempty(varargin)
%     %% ignore any events within a given halo
%     haloInS = varargin{1};
%
%     if ~isempty(ignoredTimes)
%         for igInc = 1:numel(ignoredTimes)
%             startTime = ignoredTimes(igInc)-haloInS*tRes;
%             endTime = ignoredTimes(igInc)+haloInS*tRes;
%             tossIdx = eventTimes>startTime&eventTimes<endTime;
%
%             eventTimes(tossIdx) = [];
%         end
%     end
%     cleanedTimes = eventTimes;
% else
%     %% ignore only the exact times
%     [~,intersectedIdx] = intersect(eventTimes,ignoredTimes);
%
%     eventTimes(intersectedIdx) = [];
%
%     cleanedTimes = eventTimes;
% end
%
