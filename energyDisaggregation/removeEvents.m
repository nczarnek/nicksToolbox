%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 16 February 2015
%
% removeEvents.m
% The purpose of this function is to remove events that were improperly
% marked from the eventTimes structures.

function eventTimes = removeEvents(energyDataSet,eventTimes,varargin)

specificDevices = parseStuff(varargin,energyDataSet);


%% Go through each device with a while loop.
for dInc = 1:numel(specificDevices)
    currentDevice = specificDevices(dInc);

    eT = eventTimes(currentDevice);
    
    repeatLoop = 1;
    
    xT = energyDataSet.getTimesFromUTC('timeScale','hrs','zeroTimes',true);
    xTimes = energyDataSet.getTimesFromUTC('timeScale','days','zeroTimes',false);
    
    while repeatLoop
        eventFig = figure('units','normalized','outerposition',[0 0 1 1]);
        plot(xT,energyDataSet.data(:,currentDevice))
        xlabel('Time (hrs)')
        ylabel('Power (W)')
        title(energyDataSet.getFeatureNames(currentDevice))
        
        hold on
        [~,onIdx] = intersect(xTimes,eT.onEventsTimes);
        [~,offIdx] = intersect(xTimes,eT.offEventsTimes);
        
        plot(xT(onIdx),energyDataSet.data(onIdx,currentDevice),'go')
        plot(xT(offIdx),energyDataSet.data(offIdx,currentDevice),'ro')
        
        
        fprintf(1,'Zoom in on what you want\n');
        
        h = zoom;
        h.Enable = 'on';
        h.Motion = 'Horizontal';
        
        keyboard
        
        fprintf(1,'Choose your x bounds for the event that you want to remove\n');
        
        xBounds = ginput;
        
        %% Find the corresponding indices for the zerod times.
        includeIdx = xT>xBounds(1,1)&xT<xBounds(2,1);
        
        if any(includeIdx)
            utcTimes = xTimes(includeIdx);
            
            onOut = eT.onEventsTimes>=utcTimes(1)&eT.onEventsTimes<=utcTimes(end);
            offOut = eT.offEventsTimes>=utcTimes(1)&eT.offEventsTimes<=utcTimes(end);
            
            if ~isempty(eT.onEvents)
                eT.onEvents = eT.onEvents(~onOut);
            end
            
            if ~isempty(eT.onEventsIndex)
                eT.onEventsIndex = eT.onEventsIndex(~onOut);
            end
            
            if ~isempty(eT.onEventsTimes)
                eT.onEventsTimes = eT.onEventsTimes(~onOut);
            end
            
            if ~isempty(eT.offEvents)
                eT.offEvents = eT.offEvents(~offOut);
            end
            
            if ~isempty(eT.offEventsIndex)
                eT.offEventsIndex = eT.offEventsIndex(~offOut);
            end
            
            if ~isempty(eT.offEventsTimes)
                eT.offEventsTimes = eT.offEventsTimes(~offOut);
            end
            
        end
        close(eventFig)
        
        repeatLoop = input('Enter 1 to continue or 0 to quit:\n');
    end
    
    eventTimes(currentDevice) = eT;
end

end

function specificDevices = parseStuff(varIn,eDS)

options.specificDevices = 2:eDS.nFeatures;

optionsOut = prtUtilSimpleInputParser(options,varIn);

specificDevices = optionsOut.specificDevices;

end