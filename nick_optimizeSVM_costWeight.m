%% Nicholas Czarnek
% 19 June 2014
% SSPACISS Laboratory, Duke University
%
% nick_optimizeSVM_costWeight.m
% The purpose of this script is to use a grid search to select the optimum
% svm cost and weight parameters for an SVM with the given data.

function [bestCost, bestWeight] = nick_optimizeSVM_costWeight(inputData)

numRuns = 5;

svmCosts = 2:2:10;
svmWeights = 2:2:10;

cwAucScores = zeros(size(svmCosts,2),size(svmWeights,2));

for runInc = 1:numRuns
  for cInc = 1:max(size(svmCosts))
    for wInc = 1:max(size(svmWeights))
      currentWeight = [svmWeights(wInc) 1];
      classifier = prtClassLibSvm('cost',svmCosts(cInc),'weight',currentWeight);
      
      cwAucScores(cInc,wInc) = cwAucScores(cInc,wInc) + ...
        prtScoreAuc(classifier.kfolds(inputData,5));
    end
  end
end

%% Find the best cost and weight.
maxAuc = max(cwAucScores(:));

[cIdx,wIdx] = find(cwAucScores == maxAuc,1,'first');

bestCost = svmCosts(cIdx);
bestWeight = [svmWeights(wIdx) 1];