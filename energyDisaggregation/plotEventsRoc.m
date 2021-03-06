%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 24 February 2015
%
% plotEventRoc.m
% The purpose of this function is to plot the performance based on the
% output structure from the event detector.

function plotEventsRoc(performanceStruct,varargin)

options.XL = [0 1];
options.deviceName = [];
options.marker = '--';
parsedOut = prtUtilSimpleInputParser(options,varargin);
XL = parsedOut.XL;
deviceName = parsedOut.deviceName;
rocMarker = parsedOut.marker;

figure;
plot(performanceStruct.onFa,performanceStruct.onPd,['g',rocMarker])
if isfield(performanceStruct,'offPd')
    hold on
    plot(performanceStruct.offFa,performanceStruct.offPd,['r',rocMarker])
end

xlabel('FA/hr')
ylabel('Pd')
title('Event detection ROC')
if ~isempty(deviceName)
    title(['Event detection ROC for ',deviceName])
end

legend('On events','Off events')

xlim([XL(1) XL(2)])
ylim([0 1])

grid on
end