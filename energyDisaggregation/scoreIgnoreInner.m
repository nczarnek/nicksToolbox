%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 15 September 2014
%
% scoreIgnoreInner.m
% outROC = scoreIgnoreInner(eventsTruth,eventsDetected,haloInS)
% This function takes an input truth sequence of events and a detected
% series of events, removes the detected events within the input truth
% sequence, then determines performance of the detector.
% Inputs:
%   eventsTruth     - manually marked truth, which should include pairs of
%                     on/off times
%   eventsDetected  - detected events from given detector
%   haloInS         - for generating the ROC
%
% If the inputs truth times are not in pairs, that means that the device
% was on during a start or end point.

function outROC = scoreIgnoreInner(eventsTruth,eventsDetected,haloInS)

keyboard