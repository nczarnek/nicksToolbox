%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 3 March 2015
%
% makeSaveDir
% The purpose of this function is to make a directory.

function makeSaveDir(dirName)

if ~exist(dirName,'dir')
    mkdir(dirName)
end