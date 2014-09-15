%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 26 March 2014
%
% nick_fld.m
% This is the nick's toolbox version of fld. For now, this only deals with
% binary classification.

classdef nick_fld
  
  properties
    mu1;
    mu0;
    cov1;
    cov0;
    s_w;
    w;
    trainData;
    trainTargets;
    testData;
    testTargets;
    fldConfidences;
    isTrained; % logical to indicate whether or not the classifier was trained
  end
  
  methods
    function obj = nick_fld(trainData,trainTargets)
%       keyboard
      
      %% Nothing was sent in.
      if (nargin == 0)
        
        obj.trainData = [];
        obj.trainTargets = [];
        obj.testData = [];
        obj.testTargets = [];
        obj.fldConfidences = [];
        obj.mu0 = [];
        obj.mu1 = [];
        obj.cov0 = [];
        obj.cov1 = [];
        obj.w = [];
        obj.isTrained = 0;
        % warning('Nothing was sent in.  Please define your training data and targets.')
        
      elseif (nargin == 2)
        %%
        % Check to make sure that the trainData and trainTargets have the
        % same dimensions
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
            obj.isTrained = 0;
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
        obj = nick_fld(trainData,trainTargets);
        
        uniqueTargets = sort(unique(trainTargets));
        
        obj.mu0 = mean(trainData(trainTargets == uniqueTargets(1),:));
        obj.mu1 = mean(trainData(trainTargets == uniqueTargets(2),:));
        
        obj.cov0 = cov(trainData(trainTargets == uniqueTargets(1),:));
        obj.cov1 = cov(trainData(trainTargets == uniqueTargets(2),:));
        
        obj.s_w = obj.cov0 + obj.cov1;
        
        % Calculate the weight vector.
        obj.w = (obj.s_w\(obj.mu1 - obj.mu0)')';
        
        obj.isTrained = 1;
      elseif nargin == 1
        if  ~isempty(obj.trainData) && ~isempty(obj.trainTargets)
          uniqueTargets = sort(unique(obj.trainTargets));
          
          obj.mu0 = mean(obj.trainData(obj.trainTargets == uniqueTargets(1),:));
          obj.mu1 = mean(obj.trainData(obj.trainTargets == uniqueTargets(2),:));
          
          obj.cov0 = cov(obj.trainData(obj.trainTargets == uniqueTargets(1),:));
          obj.cov1 = cov(obj.trainData(obj.trainTargets == uniqueTargets(2),:));
          
          obj.s_w = obj.cov0 + obj.cov1;
          
          % Calculate the weight vector.
          obj.w = (obj.s_w\(obj.mu1 - obj.mu0)')';
          
          obj.isTrained = 1;
          
        else
          error('Please define your training data and targets.')
        end
      else
        error('Please send in training data and targets.')
      end
      
    end
    
    
    
    
    
    
    function fldConfidences = test(obj,testData)
      if obj.isTrained
        obj.testData = testData;
        
        %% Check data dimensionality
        if size(obj.testData,2)~=size(obj.trainData,2)
          error('The dimensionality of your training and testing data is different')
        end
        
        fldConfidences = obj.testData*obj.w';
        
      else
        error('Please train your classifier')
      end
    
    end
    
    
    
  end
  
end