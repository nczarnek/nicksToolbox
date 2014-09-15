%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 26 March 2014
%
% nick_kFolds.m
% This is the cross val function for all classifiers.  Note that this
% simply calls the 'test' method from any classifier given the number of
% folds.
%
% Inputs:
%   classifier          - classifier with specified training data
%   numFolds            - number of folds of cross val
%
% Outputs:
%   cvConfidences       - cross validated confidences

function cvConfidences = nick_kFolds(classifier,numFolds)

  if ~isempty(classifier.trainData)
    if ~isempty(classifier.trainTargets)
      
      trainData = classifier.trainData;
      trainTargets = classifier.trainTargets;
      
      %% Split up the data into five different groups.
      foldIds = randi(numFolds,size(classifier.trainData,1),1);
      
      cvConfidences = zeros(size(trainTargets,1),1);
      
      %% Create the training set.
      for foldId = 1:size(unique(foldIds),1)
        trainFold = trainData(foldIds ~= foldId,:);
        trainFoldTargets = trainTargets(foldIds ~= foldId,:);
        testFold = trainData(foldIds == foldId,:);
        
        classifier.trainData = trainFold;
        classifier.trainTargets = trainFoldTargets;
        
        classifier = classifier.train;
        
        cvConfidences(foldIds == foldId) = classifier.test(testFold);
        
      end
      
      
    else
      error('Please specify trainTargets.');
      
    end
  else
    error('Please specify trainData.');
    
  end
end