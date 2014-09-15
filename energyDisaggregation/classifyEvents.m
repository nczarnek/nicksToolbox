%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 7 August 2014
% 
% classifyEvents.m
% The purpose of this function is to classify the features extracted from
% different devices.
%
% Inputs:
%   featureSet:               - input feature set with different types of
%                               energy events
%   classifier:               - string, 'SVM' or 'KNN'
%   nFolds:                   - number of desired folds for classification
% 
% Outputs:
%   cOuts:                    prtDataSet with data containing assignments,
%                             targets containing truth, and observationInfo
%                             containing info about whether the event was
%                             on or off and the associated event times.

function cOuts = classifyEvents(featureSet,classifier,nFolds,varargin)

classifier = lower(classifier);

switch classifier
  case 'svm'
    classifier = prtClassBinaryToMaryOneVsAll + prtDecisionMap;
    classifier.actionCell{1}.baseClassifier = prtClassLibSvm;
  case 'knn'
    classifier = prtClassKnn + prtDecisionMap;
    
    if ~isempty(varargin)
      classifier.actionCell{1}.k = varargin{1};
    end
  otherwise
    classifier = prtClassBinaryToMaryOneVsAll + prtDecisionMap;
    classifier.actionCell{1}.baseClassifier = prtClassLibSvm;
end

cOuts = classifier.kfolds(featureSet,nFolds);
cOuts.observationInfo = featureSet.observationInfo;

%% Make the assignment based on the maximum confidences.
% [~,maxIdx] = max(cOuts.data,[],2);
% 
% targetAssignments = featureSet.uniqueClasses(maxIdx);
% 
% uniqueTargets = sort(unique(targetAssignments),'ascend');
% 
% targetLabels = featureSet.classNames(ismember(featureSet.uniqueClasses,uniqueTargets));

figure;
% prtScoreConfusionMatrix(targetAssignments,featureSet.targets)
prtScoreConfusionMatrix(cOuts,featureSet)

plotLabels = featureSet.classNames;

set(gca,'YTickLabel',plotLabels)
set(gca,'XTickLabel',plotLabels)