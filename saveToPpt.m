%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 24 March 2015
%
% saveToPpt.m
% The purpose of this function is to save the current figure to a
% powerpoint.  The directory of the powerpoint and the type of figure can
% be specified.
%
% citation: based on Jordan Malof's jUtil_saveThisFigure.m

function saveToPpt(saveName,varargin)

options.figureHandle = gcf;
options.saveDir = 'C:\Users\Nick\Desktop';
options.titleStr = [];
parsedOuts = prtUtilSimpleInputParser(options,varargin);
figureHandle = parsedOuts.figureHandle;
saveDir = parsedOuts.saveDir;
titleStr = parsedOuts.titleStr;

figure(figureHandle)

saveppt2(fullfile(saveDir,saveName),'columns',1,'text',...
    titleStr,'halign','center','valign','center','stretch',false,'scale',false);