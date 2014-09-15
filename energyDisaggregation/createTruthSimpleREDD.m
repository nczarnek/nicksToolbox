%% Nicholas Czarnek
% 14 March 2014
% SSPACISS Laboratory, Duke University
%
% createTruthSimple.m
% The purpose of this function is to detect events from the REDD
% prtDataSets.
%
% Inputs:
%   houseData     - prtDataSet of a REDD house
%   houseNum      - 1-6 so that we can have different thresholds for devices
%                   in different houses
%   deviceColumn  - which device would you like to analyze?
%                 - refer to houseData.userData.components to choose
%   varargin      - optional input to manually set threshold
%
% Output:
%   eventTimes    - cell array with device turn on (cell 1) and off (cell
%                   2)
%
% Example usage for refrigerator on and off times:
% testTimes = createTruthSimpleREDD(houseData,1,3)

function eventTimes = createTruthSimpleREDD(houseData,houseNum,deviceColumn,varargin)

switch houseNum
  case 1
    deviceThresholds = ...
      [600;600;150;150;0;0;15;200;700;1200;0;500;500;500;30;7;0;1000];
    
    deviceThreshold = deviceThresholds(deviceColumn);
    
    if ~isempty(varargin)
      deviceThreshold = varargin{1};
    end
  case 2
    % To be filled in later
    deviceThresholds = zeros(9,1);
    deviceThresholds(7) = 100;
    
    deviceThreshold = deviceThresholds(deviceColumn);
  case 3
    deviceThresholds = zeros(20,1);
    deviceThresholds(5) = 80;
    
    deviceThreshold = deviceThresholds(deviceColumn);
  case 4
  case 5
  case 6
  otherwise
    error('REDD only has 6 houses')
end

xTimes = [1:houseData.nObservations]';

% Use logical indexing to get around the problem.
deviceOn = houseData.data(:,deviceColumn)>=deviceThreshold;

deviceDiff = diff(deviceOn);

%% Visualize everything
figure;
plot(xTimes,houseData.data(:,deviceColumn))
hold on

plot(xTimes(deviceDiff == 1),houseData.data(deviceDiff == 1,deviceColumn),'go')
plot(xTimes(deviceDiff == -1),houseData.data(deviceDiff == -1,deviceColumn),'ro')

eventTimes{1} = houseData.data(deviceDiff == 1,end);
eventTimes{2} = houseData.data(deviceDiff == -1,end);