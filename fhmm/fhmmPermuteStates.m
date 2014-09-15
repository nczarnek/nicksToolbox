%% Nicholas Czarnek
% 17 May 2014
% SSPACISS Laboratory, Duke University
%
% This function permutes all of the possible state combinations for the M
% chains and K states of an fhmm.
%
% Inputs:
%   M                   - number of chains
%   K                   - number of states per chain
%                       - scalar value assumes an equal number of states
%                         per chain
%                       - vector value assumes an unequal number of states
%                         per chain
%
% Outputs:
%   permMat             - prod(K) x M matrix of all possible state
%                         combinations

function permMat = fhmmPermuteStates(M,K)

%% If K is a scalar, this assumes an equal number of states per chain.
% Make it a vector for later convenience.
if isscalar(K)
  K = K*ones(M,1);
else
  % If a vector, make sure that K has M values
  if max(size(K))~=M
    error('Please input a vector of length M for the number of states per chain')
  end
end

% This assumes that all of the chains have the same number of states.
permMat = zeros(prod(K),M);

for m = M:-1:1
  % How many states are there for the current chain?
  nStates = K(m);
  
  % How many times should they be repeated?  Look to the right.
  if m == M
    numStateReps = 1;
  else
    numStateReps = prod(K(m+1:end));
  end
  
  % Initialize the vector to be repeated.
  compVect = [];
  for k = 1:K(m)
    compVect = cat(1,compVect,k*ones(numStateReps,1));
  end
  
  % Repmat it to be size prod(K) x M.  Look to the left.
  numVectReps = prod(K(1:m-1));
  baseVect = repmat(compVect,[numVectReps,1]);
  
  permMat(:,m) = baseVect;
  
end
