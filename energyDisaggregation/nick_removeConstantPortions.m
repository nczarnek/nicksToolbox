%% Nicholas Czarnek
% 21 May 2014
% SSPACISS Laboratory, Duke University
%
% outputData = nick_removeConstantPortions(inputData,numSecs)
% The purpose of the function is to remove portions of a dataset which are
% constant for numSecs.

function [outputData,keepIdx,killIdx] = nick_removeConstantPortions(inputData,numSecs)

constantFilter = ones(numSecs,1);

% The absolute value here is very important. Otherwise, this will not work
% properly.
filteredInput = conv(abs(diff(inputData)),constantFilter,'same');

keepIdx = find(filteredInput ~= 0);

killIdx = find(filteredInput == 0);

outputData = inputData(find(filteredInput ~= 0));