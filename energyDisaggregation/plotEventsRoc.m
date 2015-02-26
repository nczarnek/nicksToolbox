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
parsedOut = prtUtilSimpleInputParser(options,varargin);
XL = parsedOut.XL;
deviceName = parsedOut.deviceName;

figure;
plot(performanceStruct.onFa,performanceStruct.onPd,'g--')
hold on
plot(performanceStruct.offFa,performanceStruct.offPd,'r--')

xlabel('FA/hr')
ylabel('Pd')
title('Event detection ROC')
if ~isempty(deviceName)
    title(['Event detection ROC for ',deviceName])
end

legend('On events','Off events')

xlim([XL(1) XL(2)])
ylim([0 1])


end