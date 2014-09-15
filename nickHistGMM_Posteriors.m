% Nicholas Czarnek
% 22 February 2013
% SSPACISS Laboratory, Duke University

function nickHistGMM_Posteriors(originalData,posteriors,numOClusters,numOBins)
%% DESCRIPTION
% The purpose of this function is to plot a histogram of the maximum
% membership for each cluster of the posterior probabilities.

%% INPUTS
% original data: structure with the following fields:
%              : dataFileName- location of file in system
%              : processedDataStartEndDateTime- recording limits
%              : channels- channel under analysis
%              : algorithmName- subject_date_parameter_channel
%              : algorithmDescriptor- string with 'Hjorth "type" (window
%                length)
%              : sampleTimes- end time for each sequential parameter
%                calculation
%              : decisionStatistic- parameters calculated
% posteriors   : calculated based on GMM clustering of decisionStatistic
% numOClusters : number of clusters used in calculations
% numOBins     : user specified number of bins

%% Window length for parameter calculation.
dataInfo.hjorthWinLength = originalData(1,1).sampleTimes(1,1);
%% Start and end times of measurement

