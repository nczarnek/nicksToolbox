%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 26 March 2014
%
% nick_dlrt.m
% This is NMC's implementation of the distance-based likelihood ratio test.

classdef nick_dlrt
  
  properties
    trainData;
    trainTargets;
    testData;
    k;
    n0;
    n1;
    delta_k0;
    delta_k1;
    D; % dimensionality of data
    dlrtConfidences;
    isTrained;
  end
  
  methods
    %% Constructor
    function obj = nick_dlrt(trainData,trainTargets)
      %% Nothing was sent in.
      if (nargin == 0)
        
        obj.trainData = [];
        obj.trainTargets = [];
        obj.testData = [];
        obj.n0 = [];
        obj.n1 = [];
        obj.delta_k0 = [];
        obj.delta_k1 = [];
        obj.D = [];
        obj.k = 3;% change later
        obj.dlrtConfidences = [];
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
            obj.k = 3;
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
    
    
    
    
    
    
    function obj = train(obj,trainData,trainTargets,k)
%       keyboard;
      %%
      % Training for dlrt classifier consists of finding the class means
      % and covariances.
      if nargin == 3
        % Construct it.
        obj = nick_dlrt(trainData,trainTargets);
        
        uniqueTargets = sort(unique(trainTargets));
        
        obj.n0 = sum(trainTargets == uniqueTargets(1));
        obj.n1 = sum(trainTargets == uniqueTargets(2));
        
        obj.D = size(trainData,2);
        
        if exist(k,'var')
          obj.k = k;
        end
        
        
        obj.isTrained = 1;
      elseif nargin == 1
        if  ~isempty(obj.trainData) && ~isempty(obj.trainTargets)
          uniqueTargets = sort(unique(obj.trainTargets));
          
          obj.n0 = sum(obj.trainTargets == uniqueTargets(1));
          obj.n1 = sum(obj.trainTargets == uniqueTargets(2));
          
          obj.D = size(obj.trainData,2);
          
          obj.isTrained = 1;
          
        else
          error('Please define your training data and targets.')
        end
      else
        error('Please send in training data and targets.')
      end
      
      
    end
    
    function dlrtConfidences = test(obj,testData)
      if obj.isTrained
        obj.testData = testData;
        
        uniqueTargets = sort(unique(obj.trainTargets));

        
        %% Check the dimenionality of the testData.
        if size(obj.testData,2)~=size(obj.trainData,2)
          error('The dimensionality of your data is different')
        end
        
        %% H0 data.
        h0Train = obj.trainData(obj.trainTargets == uniqueTargets(1),:);
        
        %%
        % Repmat both the testing and the training matrices to form NxMxP
        % matrices, with N = # training, M = # dimensions, P = # testing.
        N = size(h0Train,1);
        M = size(h0Train,2);
        P = size(obj.testData,1);
        
        %% Check to make sure you don't go too high
        if N*M*P>1.5e8 % (800 MB)
          error('Please reduce the size of your test set.')
        end
        
        trainBlock = repmat(h0Train,[1 1 P]); % NxMxP
        
        %% THE DINGLE HERE IS IMPORTANT! DON'T ERASE IT!
        testBlock = reshape(obj.testData',[1,M,P]); % 1xMxP
        testBlock = repmat(testBlock,[N 1 1]); % NxMxP
        
        %% NxP distance block
        % Calculate the distances to each testing point to each training point
        distance0Block = squeeze(sqrt(sum((trainBlock - testBlock).^2,2)));
        
        %% Sort the block
        sorted0 = sort(distance0Block,1);
        
        
        
        
        
        %% H1 data.
        h1Train = obj.trainData(obj.trainTargets == uniqueTargets(2),:);
        
        %%
        % Repmat both the testing and the training matrices to form NxMxP
        % matrices, with N = # training, M = # dimensions, P = # testing.
        N = size(h1Train,1);
        M = size(h1Train,2);
        P = size(obj.testData,1);
        
        %% Check to make sure you don't go too high
        if N*M*P>1.5e8 % (800 MB)
          error('Please reduce the size of your test set.')
        end
        
        trainBlock = repmat(h1Train,[1 1 P]); % NxMxP
        
        %% THE DINGLE HERE IS IMPORTANT! DON'T ERASE IT!
        testBlock = reshape(obj.testData',[1,M,P]); % 1xMxP
        testBlock = repmat(testBlock,[N 1 1]); % NxMxP
        
        %% NxP distance block
        % Calculate the distances to each testing point to each training point
        distance1Block = squeeze(sqrt(sum((trainBlock - testBlock).^2,2)));
        
        %% Sort the block
        sorted1 = sort(distance1Block,1);
        
        
        
        
        %% Calculate the kth distance for each point. Add a bias in case incestuous training was used.
        biasTerm = 1e-10;
        
        obj.delta_k0 = sorted0(obj.k,:)' + biasTerm;
        obj.delta_k1 = sorted1(obj.k,:)' + biasTerm;
        
        dlrtConfidences = log(obj.n0/obj.n1) + obj.D*(log(obj.delta_k0) - log(obj.delta_k1));

        
      else
        error('Please train your classifier.')
      end
      
    end
    
  end
  
end