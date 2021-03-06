function detectedEvents = detectEventConfidences(ds,varargin)
% DETECTEVENTTHRESHOLDS - confidences for events
% Nick Czarnek
% Original author of detectEvents: Kyle Bradbury
% This code is an edited version of the detectEvents function.
%
% This code performs event detection on an input 1-D dataseries.  An
% edge-detecting filter is used on smoothed data to detect state changes in
% the input time series.
%
% Important changes:
% This function focuses on a time window, based on number of seconds 
% surrounding and event, rather than the number of data points surrounding
% an event.  This change was made to be flexible to different inputs.
%
% INPUTS: ds
% This should be a structure containing the following:
%   data              - the [Nx1] time series data
%   windowInS         - the size of the window in seconds surrounding an event
%   bufferLength      - the size of a buffer surrounding an event, in seconds
%   threshold         - threshold for one event
%   smoothFactor      - to increase the filter size
%   timeStamps        - the corresponding time stamps for each data point
% varargin:
%   'sobel'           - if this is present, use the sobel edge detector
%                       instead of Kyle's detector
% OUPUTS:
%   detectedEvents    - events in the data according to the input
%                     - this structure contains the confidences from all
%                       data and the timestamps from the data, along with
%                       marked events based on the input threshold
%
% DEFAULT INPUTS:
% ds.data = energyDataSet.data(:,1);
% ds.halfWindowInS = 120;
% ds.threshold = 0.2;
% ds.smoothFactor = 0.5;
% ds.timeStamps = [energyDataSet.observationInfo.times]';
% ds.bufferLength = 30;


options.detectorType = 'glr';
parsedOut = prtUtilSimpleInputParser(options,varargin);
detectorType = parsedOut.detectorType;

if strcmp(detectorType,'sobel')
    useSobel = 1;
else
    useSobel = 0;
end

% %% Check if anything else was sent in.
% if ~isempty(varargin)
%   if strcmp(varargin{1},'sobel')
%     useSobel = 1;
%   end
% else
%   useSobel = 0;
% end

%% Extract data from the input structure
data                    = ds.data;
halfWindowInS           = ds.halfWindowInS ;
bufferLength            = ds.bufferLength ;
threshold               = ds.threshold ;
smoothFactor            = ds.smoothFactor ;
timeStamps              = ds.timeStamps ;
extraSmooth             = ds.extraSmooth ;
extraSmoothWindowInS    = ds.extraSmoothWindowInS ;

%% Adjust the windowInS so that it's in UTC format.
windowUTC = halfWindowInS/86400;
bufferUTC = bufferLength/86400;

%% Determine the window size in terms of number of samples.
intervalBetweenSamples = timeStamps(2) - timeStamps(1);

bufferLength = floor(bufferUTC/intervalBetweenSamples);

windowLength = floor(2*round(windowUTC/intervalBetweenSamples));

windowLength = roundodd(windowLength);
midPoint = (windowLength + 1)/2;

%% Create the filter.
bufferRange             = midPoint - bufferLength:midPoint + bufferLength ;
filter                  = nan(windowLength,1) ;
filter(1:midPoint-1)    = -1 ;
filter(midPoint+1:end)  =  1 ;
filter(bufferRange)     =  0 ;

% Evaluate filter output - smooth first, then convolve with edge detector
hFilterSize = roundodd(windowLength*smoothFactor) ;
hFilter = fspecial('average', [hFilterSize 1]) ;
smoothData = imfilter(data,hFilter) ;

%% Add an additional smoothing step if desired.
if extraSmooth
    smoothUTC = extraSmoothWindowInS/86400;
    smoothWindowLength = floor(2*round(smoothUTC/intervalBetweenSamples));
    
    smoothWindowLength = roundodd(smoothWindowLength);
    
    midPoint = (windowLength + 1)/2;
    
    hFilterSize = roundodd(smoothWindowLength*smoothFactor);
    hFilter = fspecial('average',[hFilterSize 1]);
    
    smoothData = imfilter(smoothData,hFilter);
end


filteredData = imfilter(smoothData,filter) ;

% Normalize by the length of the window
filteredData = filteredData / windowLength ;


% Threshold data to determine the events
% threshold = 1 ;
events = zeros(size(filteredData)) ;
events(filteredData >=  threshold)  =  1 ;
events(filteredData <= -threshold)  = -1 ;

% For the regions with potential events, identify the max value
maxima = imregionalmax(filteredData) ;
minima = imregionalmin(filteredData) ;

% Output on/off event values, indices, and timestamps
onIndex     = logical(maxima .* (events ==  1)) ;
offIndex    = logical(minima .* (events == -1)) ;

if useSobel
  [~,sobelThresh,~,sobelConfidences] = edge(data,'sobel');
  
  onLogicals = sobelConfidences<-sobelThresh;
  offLogicals = sobelConfidences>sobelThresh;
  
  onIndex = [false;diff(onLogicals)>0];
  offIndex = [false;diff(offLogicals)>0];
end

%% Change made on 7 January 2015
detectedEvents = energyEventClass;

detectedEvents.onEvents         = data(onIndex) ;
detectedEvents.offEvents        = data(offIndex) ;
detectedEvents.onEventsIndex    = find(onIndex) ;
detectedEvents.offEventsIndex   = find(offIndex) ;
detectedEvents.onEventsTimes    = timeStamps(detectedEvents.onEventsIndex) ;
detectedEvents.offEventsTimes   = timeStamps(detectedEvents.offEventsIndex) ;
% Add the confidences themselves to allow scoring later.
if useSobel
  detectedEvents.confidences    = -sobelConfidences;
else
  detectedEvents.confidences      = filteredData ;
end
detectedEvents.timeStamps       = timeStamps;

end

function S = roundodd(S)
% This local function rounds the input to nearest odd integer.
idx = mod(S,2)<1;
S = floor(S);
S(idx) = S(idx)+1;
end






