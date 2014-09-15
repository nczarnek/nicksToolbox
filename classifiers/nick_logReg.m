%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 5 April 2014
%
% nick_logReg.m
% This class implements logistic regression.

classdef nick_logReg
  %% Define the properties
  properties
    %% Training data and targets.
    trainData;
    trainTargets;
    
    %% Testing data.
    testData;
    
    %% Output confidences.
    lambda;
    
    %% Input data concatenated with ones vector.
    x;
    
    %% Weight matrix.
    w;
    diagBias;
    
    %% Probability vector
    p;
    
    %% Beta values.
    betaOld;
    betaNew;
    
    %% Classifier setup.
    betaTolerance;
    maxIterations;
    isTrained;
    isConverged;
    iterationsToConverge;
    stepSize;
  end
  
  methods
    %% Construct it.
    function obj = nick_logReg(trainData,trainTargets)
      %       keyboard
      
      %% Nothing was sent in.
      if (nargin == 0)
        
        obj.trainData = [];
        obj.trainTargets = [];
        
        obj.testData = [];
        
        obj.lambda = [];
        
        obj.x = [];
        
        obj.w = [];
        obj.diagBias = 0; % set later if you want to incorporate a bias
        
        obj.betaTolerance = 1e-2;
        obj.maxIterations = 10000;
        obj.stepSize = 0.01;
        obj.isTrained = 0;
        obj.isConverged = 0;
        obj.iterationsToConverge = 1e6;
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
            
            obj.testData = [];
            
            obj.lambda = [];
            
            obj.x = cat(2,ones(size(trainTargets,1),1),trainData);
            
            obj.w = [];
            obj.diagBias = 0;
            
            obj.isTrained = 0;
            obj.maxIterations = 1000;
            
            obj.betaTolerance = 1e-2;
            obj.stepSize = 1;
            obj.isConverged = 0;
            obj.iterationsToConverge = 1e6;
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
      %       keyboard
      sigFunc = @(x) 1./(1 + exp(-x));
      
      %% Construct it.
      if nargin == 3
        obj = nick_logReg(trainData,trainTargets);
        
        %% Training for logistic regression consists of finding beta.
        % Initialize with fld.
        fldClass = nick_fld(obj.trainData,obj.trainTargets);
        
        fldClass = fldClass.train;
        
        betaInit = [1 fldClass.w]';
        
        %% After initialization, train on input data.
        obj.betaOld = betaInit;
        
        obj.x = cat(2,ones(size(obj.trainData,1),1),obj.trainData);
        
        %% Calculate the probability vector.
        innerProd = obj.x * obj.betaOld;
        
        obj.p = sigFunc(innerProd);
        
        %% Calculate the weight matrix from the probabilities.
        obj.w = diag(obj.p.*(1-obj.p));
        
        % Add a bias term to account for any zeros or ones in the
        % probability vector.
        %         obj.w = diag(diag(obj.w) + obj.diagBias);
        
        %% Calculate the new beta values and iterate until convergence.
        % Use right divide for speed. inv(A)*b = A\b
        % x - Nx(p+1)
        % w - NxN
        % betaOld - (p+1)x1
        % y - Nx1
        % p - Nx1
        
        convergenceError = zeros(obj.maxIterations,1);
        
        %         keyboard
        
        
        for betaInc = 1:obj.maxIterations
          obj.betaNew = (obj.x' * obj.w * obj.x)^-1 * ...
            obj.x' * obj.w * ...
            (obj.x * obj.betaOld + obj.w\(obj.trainTargets - obj.p));
          
          convergenceError(betaInc) = norm(obj.betaOld - obj.betaNew);
          
          obj.iterationsToConverge = betaInc;
          
          if convergenceError(betaInc) < obj.betaTolerance
            %             keyboard;
            
            % Break the loop
            break
            
          end
          
          %% Reassign betaOld.
          obj.betaOld = obj.betaNew;
          
          %% Recalculate p and w.
          innerProd = obj.x * obj.betaOld;
          
          obj.p = sigFunc(innerProd);
          
          %% Calculate the weight matrix from the probabilities.
          obj.w = diag(obj.p.*(1-obj.p));
          
          % Add a bias term to account for any zeros or ones in the
          % probability vector.
          obj.w = diag(diag(obj.w) + obj.diagBias);
          
        end
        
        %         keyboard;
        
        
      elseif nargin == 1
        %% Training for logistic regression consists of finding beta.
        % Initialize with fld.
        fldClass = nick_fld(obj.trainData,obj.trainTargets);
        
        fldClass = fldClass.train;
        
        betaInit = [1 fldClass.w]';
        
        obj.betaOld = betaInit;
        
        obj.x = cat(2,ones(size(obj.trainData,1),1),obj.trainData);
        
        %% Calculate the probability vector.
        innerProd = obj.x * obj.betaOld;
        
        obj.p = sigFunc(innerProd);
        
        %% Calculate the weight matrix from the probabilities.
        obj.w = diag(obj.p.*(1-obj.p));
        
        % Add a bias term to account for any zeros or ones in the
        % probability vector.
        %         obj.w = diag(diag(obj.w) + obj.diagBias);
        
        %% Calculate the new beta values and iterate until convergence.
        % Use right divide for speed. inv(A)*b = A\b
        % x - Nx(p+1)
        % w - NxN
        % betaOld - (p+1)x1
        % y - Nx1
        % p - Nx1
        
        convergenceError = zeros(obj.maxIterations,1);
        
        %         keyboard
        
        for betaInc = 1:obj.maxIterations
          obj.betaNew = (obj.x' * obj.w * obj.x)^-1 * ...
            obj.x' * obj.w * ...
            (obj.x * obj.betaOld + obj.w\(obj.trainTargets - obj.p));
          
          convergenceError(betaInc) = norm(obj.betaOld - obj.betaNew);
          
          obj.iterationsToConverge = betaInc;
          
          if convergenceError(betaInc) < obj.betaTolerance
            %             keyboard;
            
            % Break the loop
            break
            
          end
          
          %% Reassign betaOld.
          obj.betaOld = obj.betaNew;
          
          %% Recalculate p and w.
          innerProd = obj.x * obj.betaOld;
          
          obj.p = sigFunc(innerProd);
          
          %% Calculate the weight matrix from the probabilities.
          obj.w = diag(obj.p.*(1-obj.p));
          
          % Add a bias term to account for any zeros or ones in the
          % probability vector.
          obj.w = diag(diag(obj.w) + obj.diagBias);
          
        end
        
        %         keyboard;
        
        
      else
        error('Please send in training and testing data')
      end
      
    end
    
    function testConfidences = test(obj,testData)
      sigFunc = @(x) 1./(1 + exp(-x));
      
      %% Add a constant column onto the testData.
      testData = cat(2,ones(size(testData,1),1),testData);
      
      %% Run it through the sigmoid function.
      testConfidences = sigFunc(testData*obj.betaNew);
      
    end
    
  end
  
end