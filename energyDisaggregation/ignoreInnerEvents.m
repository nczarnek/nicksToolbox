%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 15 September 2014
%
% ignoreInnerEvents.m
% The purpose of this function is to return events which are outside of on
% off pairs.  This will allow us to get a better sense for
%
% outerEvents = ignoreInnerEvents(trueEvents,markedEvents,haloInS,tRes)
%
% Inputs:
%   trueEvents:             - event labels for the true times
%       onEventsTimes       - true on times
%       offEventsTimes      - true off times
%   markedEvents:           - alarms within the signal
%       onEventsTimes       - marked on times
%       offEventsTimes      - marked off times
%   haloInS                 - the time included to ignore events
%   tRes                    - equivalent of 1 s in the given time units
% Outputs:
%   outerEvents:            - the structure of markedEvents not including
%                             the events within true on and off times
%

function outerEvents = ignoreInnerEvents(trueEvents,markedEvents,haloInS,tRes,varargin)

[energyDataSet,plotStuff,removeConfidences] = parseStuff(varargin);



if ~isempty(energyDataSet)
    xT_original = [energyDataSet.observationInfo.times]';
    xT = energyDataSet.getTimesFromUTC('timeScale','hrs');
else
    xT_original = trueEvents(1).timeStamps;
    xT = (xT_original - min(xT_original))*24;
end

if all(size(trueEvents)~=size(markedEvents))
    error('Please ensure that you''re dealing with the same house\n')
end

numDevices = size(trueEvents,1);

outerEvents = markedEvents;

haloFactor = haloInS*tRes;

for dInc = 1:numDevices
    
    numOn = size(trueEvents(dInc).onEventsTimes,1);
    numOff = size(trueEvents(dInc).offEventsTimes,1);
    
    numMin = min(numOn,numOff);
    
    
    if numMin > 0
        
        
    
        if plotStuff
            if ~isempty(energyDataSet)
                deviceFig = figure;
                %% plot the device signal
                plot(xT,energyDataSet.data(:,dInc))
                hold on
                
                %% Plot the true times
                [~,onIdx] = intersect(xT_original,trueEvents(dInc).onEventsTimes);
                [~,offIdx] = intersect(xT_original,trueEvents(dInc).offEventsTimes);
                onIdx = cat(1,onIdx,offIdx);
                plot(xT(onIdx),energyDataSet.data(onIdx,dInc),'go')
                
                %% Plot the marked times
                [~,onIdx] = intersect(xT_original,markedEvents(dInc).onEventsTimes);
                [~,offIdx] = intersect(xT_original,markedEvents(dInc).offEventsTimes);
                onIdx = cat(1,onIdx,offIdx);
                plot(xT(onIdx),energyDataSet.data(onIdx,dInc),'rv')
                
                hold off
            end
            
            confidenceFig = figure;
            plot(xT,markedEvents(dInc).confidences)
            
            
        end
        
        deletedOnEvents = 0;
        deletedOffEvents = 0;
        
        %% Go through each on event
        % If removeConfidences is set, also remove the confidences bewteen
        % on and off events
        for eventInc = 1:numOn
            startOn = trueEvents(dInc).onEventsTimes(eventInc) + haloFactor;
            endOffIdx = find(trueEvents(dInc).offEventsTimes>...
                trueEvents(dInc).onEventsTimes(eventInc),1,'first');
            
            [~,trueOnIdx] = intersect(xT_original,trueEvents(dInc).onEventsTimes(eventInc));
            [~,trueOffIdx] = intersect(xT_original,trueEvents(dInc).offEventsTimes(endOffIdx));
            
            if plotStuff
                figure(confidenceFig);
                hold on
                
                plot(xT(trueOnIdx),markedEvents(dInc).confidences(trueOnIdx),'go')
                plot(xT(trueOffIdx),markedEvents(dInc).confidences(trueOffIdx),'ro')
                hold off
                
                startXLim = max(0,trueOnIdx - 100);
                endXLim = min(trueOffIdx+100,size(markedEvents(dInc).confidences,1));
                
                xlim([xT(startXLim) xT(endXLim)])
                hold off
            end
            
            if ~isempty(endOffIdx)
                endOff = trueEvents(dInc).offEventsTimes(endOffIdx) - haloFactor;
                
                %% Take out the inner events for the current startOn and endOff
                onT = outerEvents(dInc).onEventsTimes;
                
                onInner = onT>startOn&onT<endOff;
                deletedOnEvents = deletedOnEvents + sum(onInner);
                
                outerEvents(dInc).onEventsTimes(onT>startOn&onT<endOff) = [];
                if isfield(outerEvents(dInc),'onEvents')||isprop(outerEvents(dInc),'onEvents')
                    outerEvents(dInc).onEvents(onT>startOn&onT<endOff) = [];
                end
                if isfield(outerEvents(dInc),'onEventsIndex')||isprop(outerEvents(dInc),'onEventsIndex')
                    outerEvents(dInc).onEventsIndex(onT>startOn&onT<endOff) = [];
                end
                
                offT = outerEvents(dInc).offEventsTimes;
                
                offInner = offT>startOn&offT<endOff;
                deletedOffEvents = deletedOffEvents + sum(offInner);
                
                outerEvents(dInc).offEventsTimes(offT>startOn&offT<endOff) = [];
                if isfield(outerEvents(dInc),'offEvents')||isprop(outerEvents(dInc),'offEvents')
                    outerEvents(dInc).offEvents(offT>startOn&offT<endOff) = [];
                end
                if isfield(outerEvents(dInc),'offEventsIndex')||isprop(outerEvents(dInc),'offEventsIndex')
                    outerEvents(dInc).offEventsIndex(offT>startOn&offT<endOff) = [];
                end
                
                %% Remove the inner confidences if necessary.
                betweenTimes = xT_original>startOn & xT_original<endOff;
                
%                 firstOff = find(betweenTimes,1,'first');
%                 lastOff = find(betweenTimes,1,'last');
                
                if removeConfidences
                    outerEvents(dInc).confidences(betweenTimes) = 0;
                end
                
                if plotStuff
                    figure(confidenceFig)
                    hold on
                    
                    plot(xT,outerEvents(dInc).confidences,'k--')
                    
                    hold off
                end
            end
        end
        
        
        if plotStuff
            if ~isempty(energyDataSet)
                figure(deviceFig)
                hold on
                
                %% Plot the marked times
                [~,onIdx] = intersect(xT_original,outerEvents(dInc).onEventsTimes);
                [~,offIdx] = intersect(xT_original,outerEvents(dInc).offEventsTimes);
                onIdx = cat(1,onIdx,offIdx);
                plot(xT(onIdx),energyDataSet.data(onIdx,dInc),'ks')
                
                legend('Device power','True on/off events','Marked on/off events','Cleaned on/off events')
                xlabel('Time (hrs)')
                ylabel('Power (W)')
                title(trueEvents(dInc).className,'Interpreter','None')
            end
        end
    end
end


end

function [energyDataSet,includePlots,removeConfidences] = parseStuff(varIn)
    options.energyDataSet = [];
    options.includePlots = false;
    options.removeConfidences = false;
    
    parsedOut = prtUtilSimpleInputParser(options,varIn(:));
    
    energyDataSet = parsedOut.energyDataSet;
    includePlots = parsedOut.includePlots;
    removeConfidences = options.removeConfidences;
end


















%% Used to be right after if numMin>0 statement
        %% Go through each 'on' event within truth
        %         if trueEvents(dInc).onEventsTimes(1)>trueEvents(dInc).offEventsTimes(1);
        %             % This means that the first event is an off event
        %             startOn = trueEvents(dInc).timeStamps(1) + haloFactor;
        %             endOff = trueEvents(dInc).offEventsTimes(1) - haloFactor;
        %             onIdx = 0;
        %             offIdx = 1;
        %         else
        %             startOn = trueEvents(dInc).onEventsTimes(1) + haloFactor;
        %             endOff = trueEvents(dInc).offEventsTimes(1) - haloFactor;
        %             onIdx = 1;
        %             offIdx = 1;
        %         end

%% Right after establish next comment
        %                 onIdx = onIdx + 1;
        %                 offIdx = offIdx + 1;

        %                 startOn = trueEvents(dInc).onEventsTimes(onIdx) + haloFactor;
        %                 
        %                 endOff = trueEvents(dInc).offEventsTimes(offIdx) - haloFactor;
