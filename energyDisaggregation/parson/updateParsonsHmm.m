%% Nicholas Czarnek
% 27 January 2014
% SSPACISS Laboratory, Duke University
%
% The purpose of this function is to make analysis of Parson's window
% identification and training step simple given any house and any device
% prior and log likelihood
%
% Parson paper:
% scholar.google.com/citations?view_op=view_citation&hl=en&user=j4EQnpwAAAAJ&citation_for_view=j4EQnpwAAAAJ:d1gkVwhDpl0C
%
% Reference code:
% http://www.oliverparson.co.uk/publications, publication 2 under 2012
%
% inputs:
% houseData           - power levels for the house under analysis
% houseTime           - time for the house under analysis
% parsonPriorHmm      - prtRvHmm with the transition matrix and components set
%                       as specified in Parson's main code
% inputRes            - units = seconds
%                     - how many seconds are there between
%                     - should usually be 1 second if using the REDD data set
%                       mains power
% analysisRes         - units = seconds
%                     - what resolution do you want to analyze the data at?
% llThresh            - what is the log likelihood that is used as a
%                       threshold for acceptance or rejection of the
%                       window?
% windowLength        - what is the length of the window over which you are
%                       calculating the log likelihood?
% lengthAnalyzed      - how many data points do you want to analyze?
%                     - NOTE THAT THIS IS SET AFTER DOWNSAMPLING BASED ON
%                       analysisRes
% oneEM               - logical flag to indicate if you want to use only
%                       one iteration of EM as was done by Parson
%
% outputs:
% goodTS              - prtDataSetTimeSeries of the data that was sent in,
%                       split into blocks whose length is defined by the
%                       windowLength input parameter
% windowLLs           - array of the log likelihoods of the buffered data
%                       blocks in the prtHouseTS
% acceptFlags         - binary logical array defining which windows have
%                       acceptable windows for training the hmm
% updatedHmm          - hmm updated with the trained hmm after analysis of
%                       the flagged windows

function [goodTS,windowLLs,goodWindows,updatedHmm] = ....
  updateParsonsHmm(houseData,houseTime,parsonPriorHmm,inputRes,analysisRes,...
  lengthAnalyzed,llThresh,windowLength,oneEM)

%% Downsample the data appropriately
dnSampleFactor = analysisRes/inputRes;

dnSampledData = downsample(houseData,dnSampleFactor);
dnSampledTime = downsample(houseTime,dnSampleFactor);

%% Create a buffered data set.
bufferedTime = buffer(dnSampledTime(1:lengthAnalyzed,1),windowLength,windowLength - 1);
bufferedData = buffer(dnSampledData(1:lengthAnalyzed,1),windowLength,windowLength - 1);

%% Get rid of the starting and ending zeros.
bufferedTime = bufferedTime(:,windowLength - 1:end);
bufferedData = bufferedData(:,windowLength - 1:end);

%% Convert everything into cells.
bufferedData = (num2cell(bufferedData,1))';

ds = prtDataSetTimeSeries(bufferedData,'classNames',{'Mains 1'});

%% Define window likelihood badness.
badWindowPdf = -3e4;

%% Initialize arrays
badWins = [];
non1Wins = [];
windowLLs = [];

%%
% Ensure several conditions with this analysis.  Make sure first that the
% data in the window under analysis is not flat.  Otherwise, the trained
% HMM will yield a perfectly high likelihood, which is completely
% unreasonable.  Also, use a try/catch statement to ensure that if you do
% run into a bug along the way, you won't have to completely rerun your
% code.

startWin = 1;
endWin = lengthAnalyzed - 1;

for cellInc = startWin:ds.nObservations
  %% Make sure that the data is not flat
  if any(diff(ds.data{cellInc}))
    %% Try/catch for errors.
    try
      updatedHmm = parsonPriorHmm.mle(ds.data{cellInc});
      
      windowLLs(cellInc,1) = updatedHmm.logPdf(ds.data{cellInc});
      
      if updatedHmm.nComponents ~= 1
        non1Wins = cat(1,non1Wins,cellInc);
      else
        windowLLs(cellInc,1) = badWindowPdf;
      end
      
    catch
      badWins = cat(1,badWins,cellInc);
      windowLLs(cellInc,1) = badWindowPdf;
      
      fprintf(1,['Error in window ',num2str(cellInc)]);
      %       keyboard
    end
    
    %   lPdfArray(cellInc,1) = fridgeHmm.logPdf(ds.data{cellInc});
  else
    windowLLs(cellInc,1) = -3e4;
  end
  
  if mod(cellInc,1000) == 0
    fprintf(1,'\n%d\n',cellInc);
  end
  
end

stopVar = 1;

%% Perform the analysis.
goodWindows = find(windowLLs/windowLength>llThresh & ...
  windowLLs/windowLength<0);

%%
goodTS = ds.retainObservations(goodWindows);

%%
if ~isempty(goodTS.data)
  updatedHmm = parsonPriorHmm.train(goodTS);
end