%% Nicholas Czarnek
% 13 May 2014
% SSPACISS Laboratory, Duke University
%
% prtFhmm.m
%
% The purpose of this code is to replicate Ghahramani's fhmm code in a prt
% framework.  Please refer to Ghahramani's seminal work in:
%
% Ghahramani, Zoubin, and Michael I. Jordan. "Factorial hidden Markov
% models." Machine learning 29.2-3 (1997): 245-273.
%
% Properties:
%   .X                    - data, Nxp
%   .breakPoints          - if you want to split the data into multiple
%                             observations, index the starting rows
%                         - default: 1
%   .M                    - number of chains
%                         - default: 2
%   .K                    - number of states per chain. if this is a
%                             single value, all chains have the same number
%                             of states.  If this is a vector, it must have
%                             length M, with each value indicating the
%                             number of states for a given chain
%                         - default: 4
%   .cyc                  - maximum number of cycles for Baum-Welch
%                         - default: 100
%   .tol                  - termination tolerance
%                         - default: 0.0001
%   .p                    - feature dimensionality
%   .hmmCells             - Mx1 cell array
%                         - each cell contains a structure with one chain's
%                           hmm parameters (k = # state for current chain):
%                           - mu:   state means                 - k x p
%                           - cov:  state covariance            - p x p x k
%                           - p:    transition matrix:          - k x k
%                           - pi:   initial state probabilities - k x 1
%
% Methods:
%   .train                  - OUTPUTS an fhmm organized as a structure of
%                               hmms as follows:
%           fhmmCells           - output cell of component HMMs, each
%                                       containing a structure with:
%             .mu                   - mean vectors per state
%             .cov                  - covariance matrices per state
%             .p                    - state transition matrix
%             .pi                   - initial state probabilities
%             .gamma                - state probabilities per observation based on
%                                       the product of the forward and backward
%                                       variables from the Baum-Welch algorithm
%           LL                  - log likelihoods per iteration
%
% Debug with:
% load('C:\Users\Nick\Documents\MATLAB\toolboxes\ghahramani\ftp\X');

classdef nick_fhmm < prtPreProc
  
  properties
    breakPoints = 1;
    M = 2;
    K = [4;4];
    cyc = 100;
    tol = 0.0001;
    hmmCells;
    p;
  end
  
  properties (SetAccess=private)
    name = 'Factorial hidden Markov model'
    nameAbbreviation = 'FHMM'
  end
  
  methods
    %% Constructor.
    function obj = nick_fhmm(varargin)
%       keyboard
      
      obj = prtUtilAssignStringValuePairs(obj,varargin{:});
      
      obj.hmmCells = cell(obj.M,1);
      
    end
    

  end
  
  methods (Access=protected,Hidden=true)
    
    function self = trainAction(self,ds)
      keyboard;
      
      self.p = ds.nFeatures;
      
      %% Find the covariance and the cross correlation of the data.
      % Assume independence.
      dataCov = diag(diag(cov(ds.data)));
      % Expected value of the variance.
      dataXX = ds.data'*ds.data/ds.nObservations;
      
      %% Initialize the parameters of each state
      for mInc = 1:self.M
        if size(self.K,1) == 1
          % All chains have the same number of states.
          
          % Mean: k x p normal, assuming data is within one standard
          %       deviation of the normalized mean for initialization
          self.hmmCells{mInc,1}.mu = randn(self.K,self.p)*sqrtm(dataCov)/self.M + ...
            ones(self.K,self.p)*mean(ds.data)/self.M;
          
          % Covariance: p x p x k
          self.hmmCells{mInc,1}.cov = repmat(dataCov,[1 1 self.K]);
          
          % Transition matrix: k x k
          transMat = rand(self.K);
          self.hmmCells{mInc,1}.p = bsxfun(@rdivide,transMat,sum(transMat,2));
          
          % Initial state probabilities: k x 1
          stateProbs = rand(self.K,1);
          self.hmmCells{mInc,1}.pi = stateProbs/sum(stateProbs,1);
        else
          % Each chain has a different number of states.
          
          % Check to make sure that each chain defines the number of
          % states.
          if size(self.K,1) ~= self.M
            error('Assign 1 values of K if you want an equal number of states per chain or M values of K if you want different numbers of states for each chain')
          end
          
          % Mean
          self.hmmCells{mInc,1}.mu = randn(self.K(mInc),self.p)*sqrtm(dataCov)/self.M + ...
            ones(self.K(mInc),self.p) * mean(ds.data)/self.M;
          
          % Covariance
          self.hmmCells{mInc,1}.cov = repmat(dataCov,[1 1 self.K(mInc)]);
          
          % Transition matrix
          transMat = rand(self.K(mInc));
          self.hmmCells{mInc,1}.p = bsxfun(@rdivide,transMat,sum(transMat,2));
          
          % Initial state probabilities: k x 1
          stateProbs = rand(self.K(mInc),1);
          self.hmmCells{mInc,1}.pi = stateProbs/sum(stateProbs,1);
        end
        
      end
      
      %% Build the meta hmm
      % All state combinations for the different chains.
      dd = fhmmPermuteStates(self.M,self.K);
      
      %% Put the data in cells based on the breakpoints.
      for breakInc = 1:max(size(self.breakPoints))
        if ~isscalar(self.breakPoints)
          startPoint = self.breakPoints(breakInc);
          if breakInc == max(size(self.breakPoints))
            endPoint = ds.nObservations;
          else
            endPoint = self.breakPoints(breakInc + 1);
          end
          
          dataCells{breakInc,1} = prtDataSetClass(ds.data(startPoint:endPoint,:));
          
        else
          % Only one sequence.
          dataCells{1} = prtDataSetClass(ds.data);
        end
      end
      
      %% Initialize the components of the forward backward algorithm.
      % In order to be flexible, these need to be stored in cell arrays for
      % each breakpoint.
      for breakInc = 1:size(self.breakPoints,1)
        T = dataCells{breakInc}.nObservations;
        kM = size(dd,1);
        
        % Forward variable
        alpha{breakInc,1} = zeros(T,kM);
        
        % Probability of current output with a given state.
        B{breakInc,1} = zeros(T,kM);  
        
        % Backward variable
        beta{breakInc,1} = zeros(T,kM);
        
        % Smoothed variable
        gamma{breakInc,1} = zeros(T,kM);

        % P(s_i,s_j|O)
%         eta{breakInc,1} = zeros(T
        
      end
      
      
      
      
      
    end
    
    function [fhmmCells,LL] = runAction(self,ds)
      keyboard
      fhmmCells = {};
      LL = [];
    end
    
  end
  
end

