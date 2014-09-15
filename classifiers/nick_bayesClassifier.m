%% Nicholas Czarnek
% 24 March 2014
% SSPACISS Laboratory, Duke University
%
% nick_bayesClassifier
% This is Bayes classifier, implemented for ECE681 assignment 3.  Currently
% set up for only binary classification.

classdef nick_bayesClassifier
  %% Define the properties of the class.
  properties
    trainData;
    trainTargets;
    testData;
    testTargets;
    bConfidences; % output confidence vector for the test inputs
    mu0;  % mean of class 0
    mu1;  % mean of class 1
    cov0; % covariance of class 0
    cov1; % covariance of class 1
    w0;   % prior weight of class 0
    w1;   % prior weight of class 1
  end
  properties (SetAccess = protected)
    isTrained; % logical indicator whether or not the classifier was trained
  end
  
  methods
    %% Create the class constructor.
    function obj = nick_bayesClassifier(trainData,trainTargets)
%       keyboard;
      
      %% Nothing was sent in.
      if (nargin == 0)
        
        obj.trainData = [];
        obj.trainTargets = [];
        obj.testData = [];
        obj.testTargets = [];
        obj.bConfidences = [];
        obj.mu0 = [];
        obj.mu1 = [];
        obj.cov0 = [];
        obj.cov1 = [];
        obj.isTrained = 0;
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
            error('Please send in 1d target values')
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
      %%
      % Training for bayes classifier consists of finding the class means
      % and covariances.
      if nargin == 3
        % Construct it.
        obj = nick_bayesClassifier(trainData,trainTargets);
        
        uniqueTargets = sort(unique(trainTargets));
        
        obj.mu0 = mean(trainData(trainTargets == uniqueTargets(1),:));
        obj.mu1 = mean(trainData(trainTargets == uniqueTargets(2),:));
        
        obj.cov0 = cov(trainData(trainTargets == uniqueTargets(1),:));
        obj.cov1 = cov(trainData(trainTargets == uniqueTargets(2),:));
        
        w0Logical = sum(trainTargets == uniqueTargets(1));
        w1Logical = sum(trainTargets == uniqueTargets(1));
        
        obj.w0 = w0Logical/(w0Logical + w1Logical);
        obj.w1 = w1Logical/(w0Logical + w1Logical);
        
        obj.isTrained = 1;
      elseif nargin == 1
        if  ~isempty(obj.trainData) && ~isempty(obj.trainTargets)
          uniqueTargets = sort(unique(obj.trainTargets));
          
          obj.mu0 = mean(obj.trainData(obj.trainTargets == uniqueTargets(1),:));
          obj.mu1 = mean(obj.trainData(obj.trainTargets == uniqueTargets(2),:));
          
          obj.cov0 = cov(obj.trainData(obj.trainTargets == uniqueTargets(1),:));
          obj.cov1 = cov(obj.trainData(obj.trainTargets == uniqueTargets(2),:));
          
          w0Logical = sum(obj.trainTargets == uniqueTargets(1));
          w1Logical = sum(obj.trainTargets == uniqueTargets(1));
          
          obj.w0 = w0Logical/(w0Logical + w1Logical);
          obj.w1 = w1Logical/(w0Logical + w1Logical);
          
          obj.isTrained = 1;
          
        else
          error('Please define your training data and targets.')
        end
      else
        error('Please send in training data and targets.')
      end
    end
    
    
    
    function bConfidences = test(obj,testData)
%       keyboard;
      
      if obj.isTrained
        
        obj.testData = testData;
        
        %%
        % Check the dimenionality of the testData.
        if size(obj.testData,2)~=size(obj.trainData,2)
          error('The dimensionality of your data is different')
        end

        % Note that these calculations do not account for dimensionality
        % since the normalization term cancels out.
        g_1 = sum((-1/2*bsxfun(@minus,obj.testData,obj.mu1)*inv(obj.cov1)).*...
          bsxfun(@minus,obj.testData,obj.mu1),2);
        
        g_1 = bsxfun(@minus,g_1,1/2*log(det(obj.cov1)));
        g_1 = bsxfun(@plus,g_1,log(obj.w1));
        
        g_0 = sum((-1/2*bsxfun(@minus,obj.testData,obj.mu0)*inv(obj.cov0)).*...
          bsxfun(@minus,obj.testData,obj.mu0),2);
        
        g_0 = bsxfun(@minus,g_0,1/2*log(det(obj.cov0)));
        g_0 = bsxfun(@plus,g_0,log(obj.w0));
        
        bConfidences = g_1 - g_0;
        
      else
        error('Please train your classifier')
      end
    end
    
    
    
    
    
    function cvConfidences = kFolds(obj,trainData,trainTargets,numFolds)
%       keyboard;
      
%       %% Construct it.
%       obj = nick_bayesClassifier(trainData,trainTargets);
      
      %% Split up the data into five different groups.
      foldIds = randi(numFolds,size(obj.trainData,1),1);
      
      cvConfidences = zeros(size(trainTargets,1),1);
      
      %% Create the training set.
      for foldId = 1:size(unique(foldIds),1)
        trainFold = trainData(foldIds ~= foldId,:);
        trainFoldTargets = trainTargets(foldIds ~= foldId,:);
        testFold = trainData(foldIds == foldId,:);
        
        obj = nick_bayesClassifier;
        
        obj = obj.train(trainFold,trainFoldTargets);
        
        dataOut = obj.test(testFold);
        
        cvConfidences(foldIds == foldId,:) = dataOut;
      end
      
      
    end
  end
  
end