%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 11 February 2015
%
% markingGui.m
% This is a functionalized version of ex40_modifiedReddTruthing.m
% The purpose of this function is to create a semi gui that allows truthing
% of the REDD data sets. This is not actually a gui, but rather just a for
% loop that goes through the data.
%
% If a marking is made in error, simply Ctrl+C'ing out of the operation
% will take care of the problem.  Each time a mark is made, it is saved to
% the folder that is sent in.
%
% Changes from the original file:
%   - instead of sending in a folder, just send in an energyDataSet
%
%
% Inputs:
%   energyDataSet - energyDataSet
%   saveDir - where do you want to save the results?


function energyEventMarkingGui(energyDataSet,saveDir,varargin)

[dT,specificDevices,truthFromBeginning,iterationsBeforeSave,startTimeInHrs,maxDiff] = ...
    parseStuff(energyDataSet,varargin);

if ~exist(saveDir,'dir')
    mkdir(saveDir)
end

%% Only mark up times.
keepLogicals = logical([energyDataSet.observationInfo.keepLogicals]');

energyDataSet = energyDataSet.retainObservations(keepLogicals);


%% Get the times in seconds.  Round xT for easier accsesing of points later.
samplesPerHour = round(1/24/dT);
xT = energyDataSet.getTimesFromUTC('timeScale','hrs');
xT = round(xT*samplesPerHour)/samplesPerHour;
xTimes = energyDataSet.getTimesFromUTC('timeScale','days','zeroTimes',false);

eventTimes = repmat(energyEventClass,energyDataSet.nFeatures,1);

if exist(fullfile(saveDir,'eventTimes.mat'),'file')
    load(fullfile(saveDir,'eventTimes.mat'))
end

%% Add the timestamps and keeplogicals
for subInc = 1:max(size(specificDevices))
    currentDevice = specificDevices(subInc);
    eventTimes(currentDevice).timeStamps = xTimes;
    eventTimes(currentDevice).keepLogicals = keepLogicals;
end


%% Go through each of the subfiles.  Skip 'use' since the sum of the components comprises use
for subInc = 1:max(size(specificDevices))
    
    currentDevice = specificDevices(subInc);
    
    %% Plot the current feature, then pause to allow selection of how to truth.
    figure;
    plot(xT,energyDataSet.data(:,currentDevice))
    
    if ~isempty(eventTimes(currentDevice).onEventsTimes)
        fprintf('\nThis device has already been truthed to some extent.\n')
        
        hold on
        
        if ~isempty(xT(eventTimes(currentDevice).onEventsIndex))
            plot(xT(eventTimes(currentDevice).onEventsIndex),energyDataSet.data(eventTimes(currentDevice).onEventsIndex,currentDevice),'go')
        end
        
        if ~isempty(xT(eventTimes(currentDevice).offEventsIndex))
            plot(xT(eventTimes(currentDevice).offEventsIndex),energyDataSet.data(eventTimes(currentDevice).offEventsIndex,currentDevice),'r*')
        end
    end
    
    
    xlabel('Time (hours)')
    ylabel('Power (W)')
    title(energyDataSet.getFeatureNames(currentDevice))
    fprintf(1,'Check out the plot and choose how you want to proceed.\n\nZoom in to determine where to place the threshold\n\n');
    
    
    skipThis = input([energyDataSet.getFeatureNames{currentDevice},'. Enter 1 if you''d like to skip this appliance and 0 otherwise:\n']);
    if skipThis == 1
        repeatLoop = 0;
    else
        repeatLoop = 1;
    end
    
    while repeatLoop == 1
        
        markType = input('Enter 1 to use a threshold (binary events) or 2 to manually mark events:\n');
        
        
        %% Switch the different types of events.
        switch markType
            case 1
                %% Threshold
                repeatLoop = 0;
                
                figure('units','normalized','outerposition',[0 0 1 1]);
                plot(xT,energyDataSet.data(:,currentDevice))
                xlabel('Time (hours)')
                ylabel('Power (W)')
                title(energyDataSet.getFeatureNames(currentDevice))
                
                fprintf('Adjust as neceesary')
                keyboard
                
                fprintf('Please select a threshold on the plot.\n')
                
                %% Get the threshold from the figure;
                manualInput = ginput;
                
                %% Only take the first input if there were multiple
                inputThreshold = manualInput(1,2);
                
                hold on
                line([xT(1) xT(end)],[inputThreshold inputThreshold],'color','r')
                
                continueCheck = input('Is this the correct threshold? (1 yes, 0 no)\n');
                
                if continueCheck ~= 1
                    repeatLoop = 1;
                end
                
                if ~repeatLoop
                    %% Mark on events.
                    aboveThreshold = energyDataSet.data(:,currentDevice)>inputThreshold;
                    
                    diffAbove = cat(1,0,diff(aboveThreshold));
                    
                    onEventsIndex = find(diffAbove == 1);
                    offEventsIndex = find(diffAbove == -1);
                    
                    eventTimes(currentDevice).onEventsIndex = onEventsIndex;
                    eventTimes(currentDevice).offEventsIndex = offEventsIndex;
                    
                    eventTimes(currentDevice).onEventsTimes = xTimes(onEventsIndex);
                    eventTimes(currentDevice).offEventsTimes = xTimes(offEventsIndex);
                    
                    eventTimes(currentDevice).classNumber = energyDataSet.featureInfo(currentDevice).pecanClass;
                    eventTimes(currentDevice).className = energyDataSet.featureInfo(currentDevice).deviceName;
                    
                    %% Save the times
                    save(fullfile(saveDir,'eventTimes.mat'),'eventTimes')
                    
                    
                end
                
            case 2
                %% Manual markings
                repeatLoop = 0;
                
                %% Show one hour blocks at a time
                numHours = ceil(energyDataSet.nObservations/samplesPerHour);
                
                
                %% Check the existing eventTimes file
                if ~isempty(eventTimes(currentDevice).offEventsIndex)
                    startOver = input('Enter 1 to start over and 0 to continue truthing:\n');
                    
                    %% Add on to existing times
                    if startOver == 0
                        %% Determine where to start truthing
                        if truthFromBeginning
                            hourStart = 0 + startTimeInHrs;
                        else
                            obsPerHour = 1/24/dT;
                            hourStart = ceil(max(eventTimes(currentDevice).offEventsIndex)/obsPerHour);
                        end
                        
                        %% Initialize the on and off times.
                        onTimes = eventTimes(currentDevice).onEventsTimes;
                        offTimes = eventTimes(currentDevice).offEventsTimes;
                        
                        %% Create a new times structure
                    else
                        onTimes = [];
                        offTimes = [];
                        
                        hourStart = 0;
                        
                        %% Zero everything out
                        eventTimes(currentDevice).onEventsTimes    = [];
                        eventTimes(currentDevice).className        = [];
                        eventTimes(currentDevice).classNumber      = [];
                        eventTimes(currentDevice).offEventsTimes   = [];
                        eventTimes(currentDevice).onEventsIndex            = [];
                        eventTimes(currentDevice).offEventsIndex           = [];
                    end
                else
                    onTimes = [];
                    offTimes = [];
                    
                    hourStart = 0;
                end
                
                %% Select a for loop or a while loop.
                % For would be good for devices that change a lot, like lights.
                % While would be good for devices which only occur occasionally.
                
                
                forOrWhile = input('Enter 0 for a while loop and 1 for a for loop:\n');
                
                currentIt = 0;
                
                if forOrWhile == 0
                    findMore = 1;
                    while findMore
                        bP = figure('units','normalized','outerposition',[0 0 1 1]);
                        plot(xT,energyDataSet.data(:,currentDevice))
                        xlabel('Time (hr)')
                        ylabel('Power (W)')
                        title(['Device ',energyDataSet.getFeatureNames(currentDevice)])
                        
                        hold on
                        if ~isempty(xT(eventTimes(currentDevice).onEventsIndex))
                            plot(xT(eventTimes(currentDevice).onEventsIndex),energyDataSet.data(eventTimes(currentDevice).onEventsIndex,currentDevice),'go')
                        end
                        
                        if ~isempty(xT(eventTimes(currentDevice).offEventsIndex))
                            plot(xT(eventTimes(currentDevice).offEventsIndex),energyDataSet.data(eventTimes(currentDevice).offEventsIndex,currentDevice),'r*')
                        end
                        
                        fprintf('Zoom in where you want to mark events. Press F10 to continue.\n')
                        h = zoom;
                        h.Enable = 'on';
                        h.Motion = 'Horizontal';
                        %% Add a size check to make sure that each on has a corresponding off
                        if size(eventTimes(currentDevice).onEventsIndex,1)~=size(eventTimes(currentDevice).offEventsIndex,1)
                            fprintf('Check your last marking\nYou have %d on events and %d off events\n',...
                                size(eventTimes(currentDevice).onEventsIndex,1),size(eventTimes(currentDevice).offEventsIndex,1));
                        end
                        
                        keyboard
                        
                        fprintf('Mark on times\n\n')
                        newOns = ginput;
                        try
                            newOns = newOns(:,1);
                            newOns = round(newOns*samplesPerHour)/samplesPerHour;
                        catch
                        end
                        
                        onTimes = cat(1,onTimes,xTimes(ismember(xT,newOns)));
                        
                        
                        fprintf('Mark off times\n\n\n')
                        newOffs = ginput;
                        try
                            newOffs = newOffs(:,1);
                            newOffs = round(newOffs*samplesPerHour)/samplesPerHour;
                        catch
                        end
                        
                        offTimes = cat(1,offTimes,xTimes(ismember(xT,newOffs)));
                        
                        onEventsIndex = find(ismember(xTimes,onTimes));
                        offEventsIndex = find(ismember(xTimes,offTimes));
                        
                        
                        %% Add to the eventTimes structure.
                        eventTimes(currentDevice).onEventsIndex = onEventsIndex;
                        eventTimes(currentDevice).offEventsIndex = offEventsIndex;
                        eventTimes(currentDevice).onEventsTimes = xTimes(onEventsIndex);
                        eventTimes(currentDevice).offEventsTimes = xTimes(offEventsIndex);
                        eventTimes(currentDevice).classNumber = energyDataSet.featureInfo(currentDevice).pecanClass;
                        eventTimes(currentDevice).className = energyDataSet.featureInfo(currentDevice).deviceName;
                        
                        findMore = input('Enter 1 to keep going, 0 to stop:\n');
                        
                        if isempty(findMore)
                            while isempty(findMore)
                                findMore = input('Enter 1 to keep going, 0 to stop:\n');
                            end
                        end
                        
                        close(bP)
                        
                        currentIt = currentIt + 1;
                        
                        if mod(currentIt,iterationsBeforeSave) == 0
                            %% Save after marking every feature.
                            save(fullfile(saveDir,'eventTimes.mat'),'eventTimes')
                        end
                        
                    end
                    
                    
                else
                    
                    timeIncrement = input('How many hours do you want to display at a time?\n');
                    
                    for hourInc = hourStart:timeIncrement:numHours
                        startIdx = max(1,samplesPerHour*(hourInc - 5) + 1);
                        endIdx = min(energyDataSet.nObservations,samplesPerHour*(hourInc+5));
                        
                        
                        
                        %%
                        startIdxSub = samplesPerHour*(hourInc) + 1;
                        endIdxSub = min(startIdxSub + timeIncrement*samplesPerHour - 1,energyDataSet.nObservations);
                        
                        %% Determine the max difference between data points.
                        focusPoints = energyDataSet.data(startIdxSub:endIdxSub,currentDevice);
                        winDiff = max(focusPoints) - min(focusPoints);
                        if winDiff>maxDiff
                            
                            bigP = figure('units','normalized','outerposition',[0 0 1 1]);
                            subplot(211)
                            plot(xT(startIdx:endIdx),energyDataSet.data(startIdx:endIdx,currentDevice));
                            xlabel('Time (hr)')
                            ylabel('Power (W)')
                            xlim([xT(startIdx) xT(endIdx)])
                            title('The big picture')
                            
                            hold on
                            if ~isempty(xT(eventTimes(currentDevice).onEventsIndex))
                                plot(xT(eventTimes(currentDevice).onEventsIndex),energyDataSet.data(eventTimes(currentDevice).onEventsIndex,currentDevice),'go')
                            end
                            
                            if ~isempty(xT(eventTimes(currentDevice).offEventsIndex))
                                plot(xT(eventTimes(currentDevice).offEventsIndex),energyDataSet.data(eventTimes(currentDevice).offEventsIndex,currentDevice),'r*')
                            end
                            
                            h = zoom;
                            h.Enable = 'on';
                            h.Motion = 'Horizontal';
                            
                            hold off
                            
                            subplot(212)
                            plot(xT(startIdxSub:endIdxSub),energyDataSet.data(startIdxSub:endIdxSub,currentDevice))
                            try
                                xlim([xT(startIdxSub) xT(endIdxSub)])
                            catch
                            end
                            xlabel('Time (hr)')
                            ylabel('Power (W)')
                            title(['MARK ON for hours ',num2str(hourInc - 1),' to ',num2str(hourInc)])
                            
                            hold on
                            if ~isempty(xT(eventTimes(currentDevice).onEventsIndex))
                                plot(xT(eventTimes(currentDevice).onEventsIndex),energyDataSet.data(eventTimes(currentDevice).onEventsIndex,currentDevice),'go')
                            end
                            
                            if ~isempty(xT(eventTimes(currentDevice).offEventsIndex))
                                plot(xT(eventTimes(currentDevice).offEventsIndex),energyDataSet.data(eventTimes(currentDevice).offEventsIndex,currentDevice),'r*')
                            end
                            
                            h = zoom;
                            h.Enable = 'on';
                            h.Motion = 'Horizontal';
                            
                            hold off
                            
                            
                            fprintf('Mark on times\n\n')
                            newOns = ginput;
                            
                            findOff = true;
                            
                            try
                                newOns = newOns(:,1);
                                newOns = round(newOns*samplesPerHour)/samplesPerHour;
                                
                                onTimes = cat(1,onTimes,xTimes(ismember(xT,newOns)));
                                
                            catch
                                useLine = input('Enter 9 to use a threshold or 0 to continue:\n');
                                
                                if isempty(useLine)
                                    useLine = 0;
                                end
                                
                                switch useLine
                                    case 9
                                        inputThreshold = ginput;
                                        if ~isempty(inputThreshold)
                                            % Only use the first y coordinate
                                            inputThreshold = inputThreshold(1,2);
                                            
                                            aboveThreshold = energyDataSet.data(startIdxSub:endIdxSub,currentDevice)>inputThreshold;
                                            
                                            diffPoints = diff(aboveThreshold);
                                            
                                            onPoints = find(diffPoints == 1);
                                            offPoints = find(diffPoints == -1);
                                            
                                            onTimes = cat(1,onTimes,xTimes(startIdxSub+onPoints));
                                            offTimes = cat(1,offTimes,xTimes(startIdxSub+offPoints));
                                        end
                                        findOff = false;
                                        %                                 otherwise
                                        %                                     continue;
                                end
                            end
                            
                            if findOff
                                title(['MARK OFF for hours ',num2str(hourInc - 1),' to ',num2str(hourInc)])
                                
                                fprintf('Mark off times\n\n\n')
                                newOffs = ginput;
                                try
                                    newOffs = newOffs(:,1);
                                    newOffs = round(newOffs*samplesPerHour)/samplesPerHour;
                                catch
                                end
                                
                                offTimes = cat(1,offTimes,xTimes(ismember(xT,newOffs)));
                            end
                            close(bigP)
                            
                            onEventsIndex = find(ismember(xTimes,onTimes));
                            offEventsIndex = find(ismember(xTimes,offTimes));
                            
                            
                            %% Add on to the eventTimes object.
                            eventTimes(currentDevice).onEventsIndex = onEventsIndex;
                            eventTimes(currentDevice).offEventsIndex = offEventsIndex;
                            eventTimes(currentDevice).onEventsTimes = xTimes(onEventsIndex);
                            eventTimes(currentDevice).offEventsTimes = xTimes(offEventsIndex);
                            eventTimes(currentDevice).classNumber = energyDataSet.featureInfo(currentDevice).pecanClass;
                            eventTimes(currentDevice).className = energyDataSet.featureInfo(currentDevice).deviceName;
                            
                        end
                        %% Save events every 10th hour in case you need to append later.
                        if mod(currentIt,iterationsBeforeSave) == 0
                            % Old savings code 2
                            %% Save after marking every feature.
                            save(fullfile(saveDir,'eventTimes.mat'),'eventTimes')
                        end
                        
                        currentIt = currentIt + 1;
                        
                    end
                end
                
                %% Save after marking every feature.
                % Insert old saving code 1
                save(fullfile(saveDir,'eventTimes'),'eventTimes')
                
                
                
                
            otherwise
                % Request another input
                markType = input('Please try again.  1 for threshold, 2 for manual markings:\n');
                repeatLoop = 1;
        end
        
        
    end
    
    close all
    
end


end

function [dT,specificDevices,truthFromBeginning,iterationsBeforeSave,startTimeInHrs,maxDiff] = ...
    parseStuff(energyDataSet,varIn)
%% Establish defaults
options.dT = energyDataSet.observationInfo(2).times - energyDataSet.observationInfo(1).times;
options.specificDevices = 2:energyDataSet.nFeatures;
options.truthFromBeginning = false;
options.iterationsBeforeSave = 3;
options.startTimeInHrs = 0;
options.maxDiff = 35;

parsedOut = prtUtilSimpleInputParser(options,varIn);

%% Find the outputs
dT = parsedOut.dT;
specificDevices = parsedOut.specificDevices;
truthFromBeginning = parsedOut.truthFromBeginning;
iterationsBeforeSave = parsedOut.iterationsBeforeSave;
startTimeInHrs = parsedOut.startTimeInHrs;
maxDiff = parsedOut.maxDiff;
end













%% Old saving code 1:
% Old saving code, no longer necessary
%
%                 %% Find the indices of the marked times.
%                 onTimes = round(onTimes*3600)/3600;
%                 offTimes = round(offTimes*3600)/3600;
%
%                 onEventsIndex = find(ismember(xT,onTimes));
%                 offEventsIndex = find(ismember(xT,offTimes));
%
%                 %% Set up the eventTimes structure.
%                 eventTimes(currentDevice).onEventsIndex = onEventsIndex;
%                 eventTimes(currentDevice).offEventsIndex = offEventsIndex;
%                 eventTimes(currentDevice).onEventsTimes = xTimes(onEventsIndex);
%                 eventTimes(currentDevice).offEventsTimes = xTimes(offEventsIndex);
%                 eventTimes(currentDevice).classNumber = energyDataSet.featureInfo(currentDevice).pecanClass;
%                 eventTimes(currentDevice).className = energyDataSet.featureInfo(currentDevice).deviceName;
%


%% Old saving code 2:
%                             %% Find the indices of the marked times.
%                             onTimes = round(onTimes*3600)/3600;
%                             offTimes = round(offTimes*3600)/3600;
%
%                             newonEventsIndex = find(ismember(xT,onTimes));
%                             newoffEventsIndex = find(ismember(xT,offTimes));
%
%                             onEventsIndex = unique(cat(1,eventTimes(currentDevice).onEventsIndex,newonEventsIndex));
%                             offEventsIndex = unique(cat(1,eventTimes(currentDevice).offEventsIndex,newoffEventsIndex));
%
%                             %% Set up the eventTimes structure.
%                             eventTimes(currentDevice).onEventsIndex = onEventsIndex;
%                             eventTimes(currentDevice).offEventsIndex = offEventsIndex;
%                             eventTimes(currentDevice).onEventsTimes = xTimes(onEventsIndex);
%                             eventTimes(currentDevice).offEventsTimes = xTimes(offEventsIndex);
%                             eventTimes(currentDevice).classNumber = energyDataSet.featureInfo(currentDevice).pecanClass;
%                             eventTimes(currentDevice).className = energyDataSet.featureInfo(currentDevice).deviceName;
