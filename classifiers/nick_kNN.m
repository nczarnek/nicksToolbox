%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 24 March 2014
%
% nickKnn
% This function implements kNN.  As of now, it only works with binary data.
%
%
%
%
%
%
classdef nick_kNN
  
  %% Define the properties of the class.
  properties
    trainData;
    trainTargets;
    k;
    testData;
    testTargets;
    kConfidences;
  end
  
  methods
    %% Create the class constructor.
    function obj = nick_kNN(trainData,trainTargets)
      %       keyboard;
      
      %% Nothing was sent in.
      if (nargin == 0)
        
        obj.trainData = [];
        obj.trainTargets = [];
        obj.k = 3;% change later
        obj.testData = [];
        obj.testTargets = [];
        obj.kConfidences = [];
        warning('Nothing was sent in.  Please define your training data and targets.')
        
        %%
        % Check to make sure that the trainData and trainTargets have the
        % same dimensions
      elseif (nargin == 2)
        
        if size(trainData,1) == size(trainTargets,1)
          %% Check that it's binary.
          if size(unique(trainTargets),1) ~= 2
            error('As of now, only binary classification is allowed.')
          end
          
          %%
          % Make sure that the target array is 1d
          if size(trainTargets,2) == 1
            obj.trainData = trainData;
            obj.trainTargets = trainTargets;
          else
            error('Please send in singular target values')
          end
          
        else
          error('You have a different number of targets and observations')
        end
        
      else
        error('Send in training data and targets.')
      end
    end
    
    
    
    
    
    
    
    
    
    
    function obj = train(obj,trainData,trainTargets)
      %       keyboard;
      %% Training for kNN doesn't do anything except define the data.
      if nargin == 3
        obj = nick_kNN(trainData,trainTargets);
        
      else
        error('Please send in training data and targets.')
      end
    end
    
    function obj = test(obj,testData,testTargets,k)
      %       keyboard;
      
      obj.testData = testData;
      obj.testTargets = testTargets;
      obj.k = k;
      
      %%
      % Check the dimenionality of the testData.
      if size(obj.testData,2)~=size(obj.trainData,2)
        error('The dimensionality of your data is different')
      end
      
      %%
      % Repmat both the testing and the training matrices to form NxMxP
      % matrices, with N = # training, M = # dimensions, P = # testing.
      N = size(obj.trainData,1);
      M = size(obj.trainData,2);
      P = size(obj.testData,1);
      
      %% Check to make sure you don't go too high
      if N*M*P>1e8 % (800 MB)
        error('Please reduce the size of your test set.')
      end
      
      trainBlock = repmat(obj.trainData,[1 1 P]); % NxMxP
      
      %% THE DINGLE HERE IS IMPORTANT! DON'T ERASE IT!
      testBlock = reshape(obj.testData',[1,M,P]); % 1xMxP
      testBlock = repmat(testBlock,[N 1 1]); % NxMxP
      
      %% NxP distance block
      % Calculate the distances to each testing point to each training point
      distanceBlock = squeeze(sqrt(sum((trainBlock - testBlock).^2,2)));
      
      %%
      % Sort the block by distance
      [~,sortedIdx] = sort(distanceBlock);
      
      trainTargetBlock = repmat(obj.trainTargets,[1,P]);
      
      trainTargetBlock = trainTargetBlock(sortedIdx);
      
      keepTargets = trainTargetBlock(1:obj.k,:);
      
      uniqueTargets = unique(keepTargets);
      
      %% Change to 0/1 from whatever the target types are for easier processing.
      keepTargets(keepTargets == uniqueTargets(1)) = 0;
      keepTargets(keepTargets == uniqueTargets(2)) = 1;
      
      obj.kConfidences = (sum(keepTargets,1)/obj.k)';
    end
    
    
    
    
    
    function obj = kFolds(obj,trainData,trainTargets,k,numFolds)
%       keyboard;
      
      %% Construct it.
      obj = nick_kNN(trainData,trainTargets);
      
      %% Split up the data into five different groups.
      foldIds = randi(numFolds,size(obj.trainData,1),1);
      
      allConfidences = zeros(size(trainTargets,1),1);
      
      %% Create the training set.
      for foldId = 1:size(unique(foldIds),1)
        trainFold = trainData(foldIds ~= foldId,:);
        trainFoldTargets = trainTargets(foldIds ~= foldId,:);
        testFold = trainData(foldIds == foldId,:);
        testFoldTargets = trainTargets(foldIds == foldId,:);
        
        obj = nick_kNN(trainFold,trainFoldTargets);
        
        dataOut = obj.test(testFold,testFoldTargets,k);
        
        allConfidences(foldIds == foldId,:) = dataOut.kConfidences;
      end
      
      obj.kConfidences = allConfidences;
      obj.trainData = trainData;
      obj.trainTargets = trainTargets;
      obj.k = k;
      obj.testData = trainData;
      obj.testTargets = trainTargets;
      
    end
  end
  
end