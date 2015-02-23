%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 24 September 2014
%
% checkEventTimes.m
% The purpose of this function is to visually check the marked values of 
% the event times that were found by either manually marking the data or by
% a detection algorithm.

function checkEventTimes(energyDataSet,eventTimes)

xT = [energyDataSet.getObservationInfo.times]';

xTimes = xT - min(xT);

for deviceInc = 1:energyDataSet.nFeatures
  figure;
  plot(xTimes,energyDataSet.data(:,deviceInc))
  hold on
  xlabel('Time (UTC)')
  ylabel('Power (W)')
  
  onEventsIdx = timeFinder(xT,eventTimes(deviceInc).onEventsTime);
  offEventsIdx = timeFinder(xT,eventTimes(deviceInc).offEventsTime);
  
  plot(xTimes(onEventsIdx),energyDataSet.data(onEventsIdx,deviceInc),'go')
  plot(xTimes(offEventsIdx),energyDataSet.data(offEventsIdx,deviceInc),'r*')
  
  title(energyDataSet.getFeatureNames(deviceInc))
end