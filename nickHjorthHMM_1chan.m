%% Nicholas Czarnek
% 6 March 2013
% SSPACISS Laboratory, Duke University
%
% Hjorth HMM calculator
% Inputs:   hjDir: Directory of Hjorth parameters calculated from Mikati EDF
%           data. Note that the files must have the same base name.
%
%           dataHeader: includes all information about EDF file
%
%           hjBaseName: base of all Hjorth parameter files
%               Should be of form ['hjOut',window,'s',overlap]
%
%           hjChan: name of hjorth parameter file for specific channel
%
%           numStatesHMM: number of states to train HMM.
%
%           pointsPerFig: number of points specifying resolution of output
%           plots
%
%           chnlPerFig: number of channels per figure, allowing closer
%           inspection with lower value and a broader overview of the
%           seizure with higher values
%
% Outputs:  Plot of state probabilities
%           sDN: start date num
%           eDN: end date num
%           nPP: number of x points
%
% Example
% hjDir = 'C:\Users\Nick\Documents\MATLAB\]tasksOutputs\S002_20jul_hjExt\';
% hjBaseName = 'hjOut20s0';
% hjChan = 'hjOut20s0LG10';
% numStatesHMM = 3;
%
% dataDir = 'C:\Users\Nick\Documents\localizedSeizureEDFs\';
% dataFile = dir([dataDir,'*Merge*.edf']);
% dataHeader = eegReadEdfHeader([dataDir,dataFile.name]);
%
% pointsPerFig = 500;
% chnlPerFig = 10;

function [sDN,eDN,nPP] = nickHjorthHMM_1chan(numStatesHMM,hjBaseName,...
    hjDir,dataHeader,pointsPerFig,chnlPerFig,hjChan)

prtPath( 'alpha', 'beta' ); %for prtDataSetTimeSeries

%% Extract all .mat files and info from the directory
files = dir([hjDir,hjChan,'*.mat']);

%% Create HMM cell array.
clear('hjParams');

% load each channel's info
load([hjDir,files(1,1).name])

% Rename for easier manipulation.
evalExp = ['hjParams = ',hjBaseName,';'];
eval(evalExp)

% Get the channel names for later use.
chnlNames{1,1} = hjParams(1,1).channels;

% Add to the cell array.
hmmCells{1,1} = [zscore(log10(hjParams(1,1).decisionStatistic(:,1))),...
    zscore(log10(hjParams(2,1).decisionStatistic(:,1))),...
    zscore(log10(hjParams(3,1).decisionStatistic(:,1)))];
nPP = size(hjParams(1,1).decisionStatistic,1);

% Make a prt time series data set.
hmmDs = prtDataSetTimeSeries(hmmCells(:,1));

% Initialize Gaussians. %%%%%%%%%TOOK OUT ('covarianceBias',1)
gaussiansLearn = repmat(prtRvMvn('covarianceBias',1e-10),numStatesHMM,1);
learnHmm = prtRvHmm('components',gaussiansLearn);

learnHmm = learnHmm.mle(hmmDs);

[logPdf, stateLogPdf] = learnHmm.logPdf(hmmDs);

%% Plot it
sDN = dataHeader.startEndDateTimeNum(1,1);
eDN = dataHeader.startEndDateTimeNum(1,2);
xData = linspace(sDN,eDN,nPP);xData = xData';

% Groups of 10 channels/figure.
% 500 Data points per figure
% For a measurement with 71 channels and 3000 data points, this would yeild
% 8 sets of channels and 6 figures per set.  Use and 8x6 matrix for figure
% handles.
numChnlSets = ceil(size(chnlNames,1)/chnlPerFig);
figPerSet = ceil(nPP/pointsPerFig);

%%
for setInc = 1:numChnlSets
    for figInc = 1:figPerSet
        % Full screen and background
        figH(setInc,figInc) = figure('color','w');hold on
        set(figH(setInc,figInc),'units','normalized','outerposition',[0 0 1 1]);
        
        % Define starting and ending channels to reduce clutter.
        chnlStart = ((setInc-1)*chnlPerFig+1);
        chnlEnd = min(setInc*chnlPerFig,size(hmmCells,1));
        
        % Define starting and ending data points.
        dataStart = ((figInc-1)*pointsPerFig)+1;
        dataEnd = min(figInc*pointsPerFig,nPP);
        
        % Go through the channels in the set, plotting only the current
        % necessary points for each of the channels.
        for iSeq = chnlStart:chnlEnd
            stateMembership = exp(bsxfun(@minus, stateLogPdf{iSeq}(:,dataStart:dataEnd),...
                prtUtilSumExp(stateLogPdf{iSeq}(:,dataStart:dataEnd)))');
            
            h(iSeq,1) = subplot(chnlPerFig,1,iSeq-chnlStart+1);
            
            area(xData(dataStart:dataEnd,:),...
                stateMembership,'edgeColor','none')
            
            colormap(summer)
            if iSeq ~= chnlEnd
                set(h(iSeq,1),'XTickLabel',[])
            end
            ylim([0 1])
            
            set(h(iSeq,1),'YTickLabel',[]);
            
            ylabel(chnlNames(iSeq,1),'FontSize',8,'Rotation',0,...
                'HorizontalAlignment','right',...
                'VerticalAlignment','middle')
        end
        suptitle(['HMM trained with ',num2str(numStatesHMM),' states for ',hjBaseName])
        set(h(chnlStart:chnlEnd-1),'box','off')
        datetick('x','HH:MM')
        xlim([min(xData(dataStart:dataEnd,:)) max(xData(dataStart:dataEnd,:))])
        % set(h(1:size(hmmCells)-1),'xcolor','w')
        linkaxes(h(chnlStart:chnlEnd)');
        keyboard
        hold off
    end
end
