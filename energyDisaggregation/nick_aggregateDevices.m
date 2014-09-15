%% Nicholas Czarnek
% 23 May 2014
% SSPACISS Laboratory, Duke University
%
% nick_aggregateDevices.m
% The purpose of this function is to aggregate all devices with the same
% name into one column.

function newHouse = nick_aggregateDevices(houseData)

%% Find the unique class labels.
classLabels = unique(houseData.userData.components);

%% Go through each label and add together the columns with the given label.
timeIndicator = 0;

newHouse = prtDataSetClass(zeros(houseData.nObservations,max(size(classLabels))));

for uniqueClass = 1:max(size(classLabels))
  classIdx = find(strcmp(houseData.userData.components,classLabels{uniqueClass}));
  
  aggregateSum = sum(houseData.data(:,classIdx),2);
  
  if strcmp(classLabels{uniqueClass},'time')
    timeIndicator = 1;
    continue
  end
  
  if timeIndicator
    newHouse.userData.components{uniqueClass-1,1} = classLabels{uniqueClass};
    newHouse.data(:,uniqueClass - 1) = aggregateSum;
  else
    newHouse.data(:,uniqueClass) = aggregateSum;
    newHouse.userData.components{uniqueClass,1} = classLabels{uniqueClass};
  end
end

newHouse.data(:,end) = houseData.data(:,end);

newHouse.userData.components{uniqueClass,1} = 'time';

newHouse.observationInfo = houseData.observationInfo;