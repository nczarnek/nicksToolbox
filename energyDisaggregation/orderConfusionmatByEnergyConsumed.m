%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 9 April 2015
%
% orderConfusionmatByEnergyConsumed.m
% The purpose of this function is to order the confusion matrix based on
% the order of most to least power consumed.  Therefore, both 
% classification performance and an energyDataSet need to be sent in.
%
% The order of the confusion matrix is dictated by the targets in
% increasing order.
%
% orderedClassificationResult = ...
%   orderConfusionmatByEnergyConsumed(classificationPerformance,energyDataSet)

function orderedClassificationResult = ...
    orderConfusionmatByEnergyConsumed(classificationPerformance,energyDataSet)


%% Get the order of energy consumed from greatest to least
[~,~,c] = energyDataSet.rankComponentsByEnergy;

%% Reorder the features
energyDataSet = energyDataSet.retainFeatures(c);

%% Assign new classes in order of decreasing energy
orderedClasses = [energyDataSet.getFeatureInfo.pecanClass];
orderedClassNames = energyDataSet.getFeatureNames;

maxClass = max(orderedClasses);

orderedClassificationResult = classificationPerformance;

for cInc = 1:numel(orderedClasses)
    newClass = maxClass + cInc;
    
    targetIdx = orderedClassificationResult.targets == ...
        orderedClasses(cInc);
    orderedClassificationResult.targets(targetIdx) = newClass;
    
    dataIdx = orderedClassificationResult.data == ...
        orderedClasses(cInc);
    orderedClassificationResult.data(dataIdx) = newClass;
    
    nameIdx = orderedClassificationResult.uniqueClasses == newClass;
    
    if any(nameIdx)
        orderedClassificationResult.classNames{nameIdx} = orderedClassNames{cInc};
    end
    
end