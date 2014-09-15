%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 18 August 2014
%
% detectEnergyEvents.m
% Based on code originally from Kyle Bradbury, PhD, Duke University.
% The purpose of this function is to detect events from energyDataSets.
%
% This function just wraps detectEventConfidencs.

function detectedEvents = detectEnergyEvents(energyDS,eventParameters,varargin)

ds = eventParameters;

if isempty(varargin)
  for deviceInc = 1:energyDS.nFeatures
    ds.data = energyDS.data(:,deviceInc);
    detectedEvents(deviceInc) = detectEventConfidences(ds);
  end
else
  if strcmp(varargin{1},'sobel')
    for deviceInc = 1:energyDS.nFeatures
      ds.data = energyDS.data(:,deviceInc);
      detectedEvents(deviceInc) = detectEventConfidences(ds,'sobel');
    end
  else
    for deviceInc = 1:energyDS.nFeatures
      ds.data = energyDS.data(:,deviceInc);
      detectedEvents(deviceInc) = detectEventConfidences(ds);
    end
  end
end