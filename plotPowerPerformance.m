%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 24 March 2015
%
% plotPowerPerformance.m
% The purpose of this function is to plot the outputs from the
% calculateAssignmentErrors method of energyDataSetClass

function fHandles = plotPowerPerformance(performanceObject,varargin)

options.titleStr = [];
parsedOuts = prtUtilSimpleInputParser(options,varargin);
titleStr = parsedOuts.titleStr;

fHandles = [];

%% Go through each of the error types.
for eType = 1:performanceObject.nObservations
    errorType = performanceObject.observationInfo(eType).errorType;
    
    if strcmp(errorType,'RMS')
        rmsFig = figure;
        fHandles = cat(1,fHandles,rmsFig);
        plot(performanceObject.data(eType,:),'ro')
        
        %% Change the axes labels
        ax = gca;
        ax.XTick = 1:performanceObject.nFeatures;
        xlim([0 performanceObject.nFeatures + 1])
        xLabels = performanceObject.getFeatureNames;
        ax.XTickLabel = xLabels;
        xticklabel_rotate;
        
        
        ylabel('RMS error')
        title(['RMS error by device ',titleStr])
        grid on
    elseif strcmp(errorType,'chanceRMS')
        figure(rmsFig)
        hold on
        plot(performanceObject.data(eType,:),'gx')
        legend('RMS','Chance RMS')
        YL = ylim;
        ylim([-10 YL(2)+10])
    else
        h = figure;
        fHandles = cat(1,fHandles,h);
        plot(performanceObject.data(eType,:),'o')
        %% Change the axes labels
        ax = gca;
        ax.XTick = 1:performanceObject.nFeatures;
        xlim([0 performanceObject.nFeatures + 1])
        xLabels = performanceObject.getFeatureNames;
        ax.XTickLabel = xLabels;
        xticklabel_rotate;
        
        YL = ylim;
        rangeVals = range(performanceObject.data(eType,:));
        if rangeVals<1
            ylim([-.1 1.1])
        else
            ylim([-rangeVals/10 YL(2)])
        end
        ylabel(performanceObject.observationInfo(eType).errorType)
        title([performanceObject.observationInfo(eType).errorType,...
            ' error by device ',titleStr])
        
        grid on
    end
end