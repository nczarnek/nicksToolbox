%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 3 March 2015
%
% makeSaveDir(directoryName)
% The purpose of this function is to make a directory if it doesn't already 
% exist.

function makeSaveDir(dirName)

if ~exist(dirName,'dir')
    mkdir(dirName)
end