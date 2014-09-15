%% Nicholas Czarnek
% 7 August 2014, modified 13 August 2014
% SSPACISS Laboratory, Duke University
%
% assignEnergy.m
% The purpose of this function is to assign energy to the classified
% events.
%
% NOTE: The use of the term "truth" is somewhat loose here.  Truth refers
% to true times, as marked by human observers.
% 
% Inputs:
%   timeStamps:         array of timestamps for assignment for all
%                       observations
%
%   eventAssignments:   prtDataSet containing information about the 
%                       assigned class for a given event
%                       - observationInfo contains the timestamps for
%                         events along with whether the event was an on or
%                         off event
%                       - data contains the assignments
%                       - targets contains the truth
%
%   onOffLevels:        prtDataSet with power assignments for on and off
%                       state assignments for different devices
%
% Outputs:
%   energyAssigned:     - prtDataSet containing the time series of assigned
%                         power
%
%   energyFromTruth:    - prtDataSet containing the time series based on
%                         known events

function [powerAssigned,powerFromTruth,ratioAssignedToTrueTime] = assignPower(timeStamps,onOffEvents,onOffLevels)

debugMode = 0;

uniqueClasses = onOffEvents.uniqueClasses;

nObservations = max(size(timeStamps));

powerAssigned = prtDataSetClass('data',zeros(nObservations,max(size(uniqueClasses))));
powerFromTruth = prtDataSetClass('data',zeros(nObservations,max(size(uniqueClasses))));

powerAssigned = powerAssigned.setFeatureNames(onOffEvents.classNames);
powerFromTruth = powerFromTruth.setFeatureNames(onOffEvents.classNames);

onOffClasses = onOffLevels.uniqueClasses;

trueTimeUp = zeros(nObservations,max(size(uniqueClasses)));
assignedTimeUp = zeros(nObservations,max(size(uniqueClasses)));

assignedClasses = [];

plotTimes = (timeStamps - min(timeStamps))*1440;

%% Go through each unique class
for classInc = 1:size(uniqueClasses,1)
  %% TRUTH - make assignments based on known events.
  %%%%%
  %%%%%
  %%%%%
  %%%%%
  % Only retain the timestamps corresponding to the current class.
  keepClass                     = onOffEvents.retainClasses(uniqueClasses(classInc));
  deviceOnOff                   = onOffLevels.retainClasses(uniqueClasses(classInc));
  
  %% Was the device on or off initially?
  eventTimes                    = [keepClass.observationInfo.times];
  [startTime,startIdx]          = min(eventTimes);
  
  onStart                       = keepClass.observationInfo(startIdx).on;
  
  onTimes                       = eventTimes(logical([keepClass.observationInfo.on]'));
  offTimes                      = eventTimes(~logical([keepClass.observationInfo.on]'));
  
  %% Initialize the assignments
  if onStart % first event is on
    lastOn = startTime;
    lastOff = inf;
    
    powerFromTruth.data(timeStamps<=lastOn,classInc) = deviceOnOff.data(1,2);
    trueTimeUp(timeStamps<=lastOn,classInc) = 0;
  else
    lastOn = inf;
    lastOff = startTime;
    
    powerFromTruth.data(timeStamps<=lastOff,classInc) = deviceOnOff.data(1,1);
    trueTimeUp(timeStamps<=lastOn,classInc) = 1;
  end
  
  keepGoing = 1;
  
  iteration = 0;
  
  if debugMode
    figure; %#ok<*UNRCH>
    yPlot = powerFromTruth.data(:,classInc);
    fH = plot(plotTimes,yPlot,'YDataSource','yPlot');
    
  end

  while keepGoing && iteration<100000
    if onStart
      % last event was an on, so now we need to find the next off.
      lastOff = offTimes(find(offTimes>lastOn,1,'first'));

      %% Set the time between lastOn and lastOff to the on state.
      if ~isempty(lastOff)
        powerFromTruth.data(timeStamps>lastOn & timeStamps<=lastOff,classInc) = deviceOnOff.data(1,1);
        trueTimeUp(timeStamps>lastOn & timeStamps<=lastOff,classInc) = 1;
      else
        powerFromTruth.data(timeStamps>lastOn & timeStamps<= max(timeStamps),classInc) = deviceOnOff.data(1,1);
        keepGoing = 0;
        trueTimeUp(timeStamps>lastOn & timeStamps<= max(timeStamps),classInc) = 1;
      end
      % switch onStart
      onStart = ~onStart;
    else
      % last event was an off, so now we need to find the next on.
      lastOn = onTimes(find(onTimes>lastOff,1,'first'));
      
      %% Set the time between lastOff and lastOn to the off state.
      if ~isempty(lastOn)
        powerFromTruth.data(timeStamps>lastOff & timeStamps<=lastOn,classInc) = deviceOnOff.data(1,2);
        trueTimeUp(timeStamps>lastOn & timeStamps<=lastOff,classInc) = 0;
      else
        powerFromTruth.data(timeStamps>lastOff & timeStamps<=max(timeStamps),classInc) = deviceOnOff.data(1,2);
        keepGoing = 0;
        trueTimeUp(timeStamps>lastOff & timeStamps<=max(timeStamps),classInc) = 0;
      end
      
      % switch onStart
      onStart = ~onStart;
    end
    
    %% Progress bar
    if debugMode
      yPlot = powerFromTruth.data(:,classInc); %#ok<*NASGU>
      refreshdata(fH,'caller')
      drawnow
    end

    iteration = iteration + 1;
  end
  
  
  
  
  
  
  
  
  %% Assigned - make assignments based on the input events.
  %%%%%
  %%%%%
  %%%%%
  %%%%%
  keepClass                      = onOffEvents.retainObservations(onOffEvents.data == uniqueClasses(classInc));
  
  %% Was the device on or off initially?
  eventTimes                    = [keepClass.observationInfo.times];
  if ~isempty(eventTimes) % account for the case in which nothing was assigned to the current device
    assignedClasses = cat(1,assignedClasses,uniqueClasses(classInc));
    
    [startTime,startIdx]          = min(eventTimes);
    
    onStart                       = keepClass.observationInfo(startIdx).on;
    
    onTimes                       = eventTimes(logical([keepClass.observationInfo.on]'));
    offTimes                      = eventTimes(~logical([keepClass.observationInfo.on]'));
    
    %% Initialize the assignments
    if onStart % first event is on
      lastOn = startTime;
      lastOff = inf;
      
      powerAssigned.data(timeStamps<=lastOn,classInc) = deviceOnOff.data(1,2);
      assignedTimeUp(timeStamps<=lastOn,classInc) = 0;

    else
      lastOn = inf;
      lastOff = startTime;
      
      powerAssigned.data(timeStamps<=lastOff,classInc) = deviceOnOff.data(1,1);
      assignedTimeUp(timeStamps<=lastOn,classInc) = 1;
    end
    
    keepGoing = 1;
    
    iteration = 0;
    
    if debugMode
      hold on
      yAssigned = powerAssigned.data(:,classInc);
      fH = plot(plotTimes,yAssigned,'g--','YDataSource','yAssigned');
      
    end
    
    while keepGoing && iteration<100000
      if onStart
        % last event was an on, so now we need to find the next off.
        lastOff = offTimes(find(offTimes>lastOn,1,'first'));
        
        %% Set the time between lastOn and lastOff to the on state.
        if ~isempty(lastOff)
          powerAssigned.data(timeStamps>lastOn & timeStamps<=lastOff,classInc) = deviceOnOff.data(1,1);
          assignedTimeUp(timeStamps>lastOn & timeStamps<=lastOff,classInc) = 1;

        else
          powerAssigned.data(timeStamps>lastOn & timeStamps<= max(timeStamps),classInc) = deviceOnOff.data(1,1);
          keepGoing = 0;
          assignedTimeUp(timeStamps>lastOn & timeStamps<= max(timeStamps),classInc) = 1;
        end
        % switch onStart
        onStart = ~onStart;
      else
        % last event was an off, so now we need to find the next on.
        lastOn = onTimes(find(onTimes>lastOff,1,'first'));
        
        %% Set the time between lastOff and lastOn to the off state.
        if ~isempty(lastOn)
          powerAssigned.data(timeStamps>lastOff & timeStamps<=lastOn,classInc) = deviceOnOff.data(1,2);
          assignedTimeUp(timeStamps>lastOn & timeStamps<=lastOff,classInc) = 0;
        else
          powerAssigned.data(timeStamps>lastOff & timeStamps<=max(timeStamps),classInc) = deviceOnOff.data(1,2);
          keepGoing = 0;
          assignedTimeUp(timeStamps>lastOff & timeStamps<=max(timeStamps),classInc) = 0;
        end
        
        % switch onStart
        onStart = ~onStart;
      end
      
      %% Progress bar
      if debugMode
        yAssigned = powerAssigned.data(:,classInc); %#ok<*NASGU>
        refreshdata(fH,'caller')
        drawnow
      end
      
      iteration = iteration + 1;
    end
  end
  
  if debugMode
    title(powerAssigned.getFeatureNames(classInc))
    xlabel('Time (min)')
    ylabel('Power (W)')
    legend('Power based on true events','Power assigned based on classified events')
    
%     keyboard
  end
end

%% Set times in observationInfo for both assigned and true power.
obsInfo = struct('times',num2cell(timeStamps));
powerAssigned.observationInfo = obsInfo;
powerFromTruth.observationInfo = obsInfo;

%% Fill out feature info with the device names, pecan street class, and unit.
featureInfo = struct('deviceName',powerFromTruth.getFeatureNames',...
  'pecanClass',num2cell(onOffClasses),'unit',repmat('W',powerFromTruth.nFeatures,1));

powerFromTruth = powerFromTruth.setFeatureInfo(featureInfo);
powerAssigned = powerAssigned.setFeatureInfo(featureInfo);



ratioAssignedToTrueTime = sum(assignedTimeUp,1)./sum(trueTimeUp,1);
