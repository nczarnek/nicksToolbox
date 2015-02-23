%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 24 September 2014
%
% tossDefectiveMeasurements.m
% The purpose of this function is to only retain observations which were
% properly measured, as marked by the keepLogicals parameter within
% observationInfo of the energyDataSets.

function energyDataSet = tossDefectiveMeasurements(energyDataSet)

energyDataSet = energyDataSet.select(@(s)(s.keepLogicals == 1));