%% gmmHjorthParameters
% Nicholas Czarnek
% 14 February 2013
% SSPACISS Lab

(startTime,endTime,timeIncrement,data,numOClusters)

% This function plots the GMM posteriors of the Hjorth parameters
function gmmPosteriors = gmmHjorthParameters(hjorthStruct, numOClusters,...
    selectors, desiredChannel)

%% Parameters
% hjorthStruct: structure from eegExtractFeatures,
% numOClusters: number of desired clusters
% selectors(1,1): typeSelector: choose PRT (1) or Matlab (2) based gmm
% selectors(2,1): displaySelector: choose display posteriors area plot
% numOClusters: number of desired clusters
% desiredChannel: string array of any type of channel
% gmmPosteriors: cell array of posteriors returned from calculation.
% Cell numbers for gmmPosteriors match with column numbers of
% decisionStatistic s.t. the channels match.

%% Note about hjorthStruct fields
% dataFileName: original edf file that parameters were extracted from
% processedDataStartEnd: Example (21-Jul-2011 13:33:5222-Jul-2011 06:01:02)
%                       no space between times, so work out extract for
%                       plots
% channels: gives channels from sample
% algorithmName: subject_date_HjorthType_channel
% algorithmDescriptor: Hjorth Type
% sampleTimes: sample time in seconds from beginning of file
% decisionStatistic: hjorth parameters for each sample time

paramName = cell(3,1);

%% Channels used and date extraction
% Use first parameter of hjorthStruct, whatever it is since all will have
% the same channel and date info.
startAbsTime = dateNum(hjorthStruct(1,1).processedDataStartEndDateTime(1:20));
endAbsTime = dateNum(hjorthStruct(1,1).processedDataStartEndDateTime(22:41));

%% Main loop
for typeInc = 1:length(hjorthStruct)
    %% Extract parameter name. 2nd name in algorithmDescriptor
    [tempName,remainder] = strtok(hjorthStruct(typeInc,1).algorithmDescriptor);
    paramName{typeInc,1} = strtok(remainder);
    
    
end

%% Plotting section
