%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 25 May 2014
%
% nick_keepFolders.m
% This function takes in a directory and spits out a cell array of the
% folder names
function folders = nick_keepFolders(inputDir)

folders = dir(inputDir);

% Only keep the folders.
rDirs = [folders(:).isdir]; % logicals
folders = {folders(rDirs).name}';

folders(ismember(folders,{'.','..'})) = [];