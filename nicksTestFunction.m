%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 5 July 2013
% The purpose of this function is to act as an intermediate test function
% to determine if certain operations are viable or not.

function [output,output2,output3] = nicksTestFunction(varargin);

%%%%%%%%%%%
%%%%%%%%%%%
%%%%%%%%%%%
%% 5 July 2013
% Take the input and return a classifier.  The purpose is to see if objects
% can easily be passed back and forth between functions.

% output = prtClassLibSvm;

% Result: it is possible to pass objects back and forth.

%%%%%%%%%%%
%%%%%%%%%%%
%%%%%%%%%%%
%% 9 July 2013
% Test what happens with varargin.
if isempty(varargin)
  output = 'Empty';
else
  output.class = class(varargin);
  output.sumData = sum(varargin{:});
end

output2 = 1;

output3 = 2;