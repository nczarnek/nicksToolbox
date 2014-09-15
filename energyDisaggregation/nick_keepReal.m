%% Nicholas Czarnek
% 2 June 2014
% SSPACISS Laboratory, Duke University
%
% nick_keepReal.m
% This function outputs cells containing the non constant portions of the
% REDD dataset.  Similar to nick_removeConstantPortions, except that the
% outputs are not concatenated together, but rather separated into blocks.

function outputData = nick_keepReal(inputData,numSecs)

constantFilter = ones(numSecs,1);

% The absolute value here is very important. Otherwise, this will not work
% properly.
filteredInput = conv(abs(diff(inputData)),constantFilter,'same');
