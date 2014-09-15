%% Nicholas Czarnek
% 7 August 2014
% SSPACISS Laboratory, Duke University
%
% assignEnergy.m
% The purpose of this function is to assign energy to the classified
% events.
% 
% Inputs:
%   timeStamps:         array of timestamps for assignment for all
%                       observations
%   onOuts:             structure containing the following
%                       - assignments - how the classifier assigned the
%                         event
%                       - truth - what the event actually was
%                       - timeStamps - when the event occurred
%                       - classNames - types of events
% Outputs:
%   energyAssigned:     - prtDataSet containing the time series of assigned
%                         power
%   energyFromTruth:    - prtDataSet containing the time series based on
%                         known events

function [energyAssigned,energyFromTruth] = assignPower(timeStamps,onOuts,offOuts,onOffLevels)

debugMode = 0;

uniqueClasses = unique(onOuts.truth);

nObservations = max(size(timeStamps));

energyAssigned = prtDataSetClass('data',zeros(nObservations,max(size(uniqueClasses))));
energyFromTruth = prtDataSetClass('data',zeros(nObservations,max(size(uniqueClasses))));

energyAssigned = energyAssigned.setFeatureNames(onOuts.classNames);
energyFromTruth = energyFromTruth.setFeatureNames(onOuts.classNames);

onOffClasses = [onOffLevels.class]';

%% Go through each unique class
for classInc = 1:size(uniqueClasses,1)
  currentClass = uniqueClasses(classInc);
  
  onOffIdx = find(onOffClasses == currentClass);
  
  %% TRUTH - make assignments based on known events.
  %%%%%
  %%%%%
  %%%%%
  %%%%%
  onIdx = onOuts.truth == currentClass;
  offIdx = offOuts.truth == currentClass;
  
  onTimes = sort(onOuts.timeStamps(onIdx));
  offTimes = sort(offOuts.timeStamps(offIdx));
  
  % Was the device on or off initially?
  minOn = min(onTimes);
  minOff = min(offTimes);
  
  if minOn<minOff % first event is on
    onStart = 1;
    lastOn = minOn;
    lastOff = inf;
    
    energyFromTruth.data(timeStamps<=lastOn,classInc) = onOffLevels(onOffIdx).off;
  else % first event is off
    onStart = 0;
    lastOn = inf;
    lastOff = minOff;
    
    energyFromTruth.data(timeStamps<=lastOff,classInc) = onOffLevels(onOffIdx).on;
  end
  
  keepGoing = 1;
  
  iteration = 0;
  
  if debugMode
    figure; %#ok<*UNRCH>
    yPlot = energyFromTruth.data(:,classInc);
    fH = plot(timeStamps,yPlot,'YDataSource','yPlot');
  end

  while keepGoing && iteration<100000
    if onStart
      % last event was an on, so now we need to find the next off.
      lastOff = offTimes(find(offTimes>lastOn,1,'first'));

      %% Set the time between lastOn and lastOff to the on state.
      if ~isempty(lastOff)
        energyFromTruth.data(timeStamps>lastOn & timeStamps<=lastOff,classInc) = onOffLevels(onOffIdx).on;
      else
        energyFromTruth.data(timeStamps>lastOn & timeStamps<= max(timeStamps),classInc) = onOffLevels(onOffIdx).on;
        keepGoing = 0;
      end
      % switch onStart
      onStart = ~onStart;
    else
      % last event was an off, so now we need to find the next on.
      lastOn = onTimes(find(onTimes>lastOff,1,'first'));
      
      %% Set the time between lastOff and lastOn to the off state.
      if ~isempty(lastOn)
        energyFromTruth.data(timeStamps>lastOff & timeStamps<=lastOn,classInc) = onOffLevels(onOffIdx).off;
      else
        energyFromTruth.data(timeStamps>lastOff & timeStamps<=max(timeStamps),classInc) = onOffLevels(onOffIdx).off;
        keepGoing = 0;
      end
      
      % switch onStart
      onStart = ~onStart;
    end
    
    %% Progress bar
    if debugMode
      yPlot = energyFromTruth.data(:,classInc); %#ok<*NASGU>
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
  onIdx = onOuts.assignments == currentClass;
  offIdx = offOuts.assignments == currentClass;
  
  onTimes = sort(onOuts.timeStamps(onIdx));
  offTimes = sort(offOuts.timeStamps(offIdx));
  
  % Was the device on or off initially?
  minOn = min(onTimes);
  minOff = min(offTimes);
  
  if minOn<minOff % first event is on
    onStart = 1;
    lastOn = minOn;
    lastOff = inf;
    
    if ~isempty(lastOn)
      energyAssigned.data(timeStamps<=lastOn,classInc) = onOffLevels(onOffIdx).off;
    end
  else % first event is off
    onStart = 0;
    lastOn = inf;
    lastOff = minOff;
    
    if ~isempty(lastOff)
      energyAssigned.data(timeStamps<=lastOff,classInc) = onOffLevels(onOffIdx).on;
    end
  end
  
  keepGoing = 1;
  
  iteration = 0;
  
  if debugMode
    figure;
    yPlot = energyAssigned.data(:,classInc);
    fH = plot(timeStamps,yPlot,'YDataSource','yPlot');
  end

  while keepGoing && iteration<100000
    if onStart
      % last event was an on, so now we need to find the next off.
      if ~isempty(lastOn)
        lastOff = offTimes(find(offTimes>lastOn,1,'first'));
      end

      %% Set the time between lastOn and lastOff to the on state.
      if ~isempty(lastOff) && ~isempty(lastOn)
        energyAssigned.data(timeStamps>lastOn & timeStamps<=lastOff,classInc) = onOffLevels(onOffIdx).on;
      else
        if ~isempty(lastOn)
          energyAssigned.data(timeStamps>lastOn & timeStamps<= max(timeStamps),classInc) = onOffLevels(onOffIdx).on;
        end
        keepGoing = 0;
      end
      % switch onStart
      onStart = ~onStart;
    else
      % last event was an off, so now we need to find the next on.
      if ~isempty(lastOff)
        lastOn = onTimes(find(onTimes>lastOff,1,'first'));
      end
      
      %% Set the time between lastOff and lastOn to the off state.
      if ~isempty(lastOn) && ~isempty(lastOff)
        energyAssigned.data(timeStamps>lastOff & timeStamps<=lastOn,classInc) = onOffLevels(onOffIdx).off;
      else
        if ~isempty(lastOff)
          energyAssigned.data(timeStamps>lastOff & timeStamps<=max(timeStamps),classInc) = onOffLevels(onOffIdx).off;
        end
        keepGoing = 0;
      end
      
      % switch onStart
      onStart = ~onStart;
    end
    
    %% Progress bar
    if debugMode
      yPlot = energyAssigned.data(:,classInc);
      refreshdata(fH,'caller')
      drawnow
    end

    iteration = iteration + 1;
  end
end