%% Nicholas Czarnek
% 23 February 2013
% SSPACISS Laboratory
%
% nickMakeFolders generates folders under C:\Users\Nick\Documents\MATLAB\
% for data required, functions specifically for the given task, and outputs
% for the task at hand.
%
% rootPath = nickMakeFolders(baseName);
% baseName = name given to task
% rootPath = 3x1 cell array for paths to tasksData, tasksFunctions, and
% tasksOutputs

function rootPath = nickMakeFolders(baseName)

rootPath{1,1} = ['C:\Users\Nick\Documents\MATLAB\]tasksData\',baseName,'\'];
rootPath{2,1} = ['C:\Users\Nick\Documents\MATLAB\]tasksFunctions\',baseName,'\'];
rootPath{3,1} = ['C:\Users\Nick\Documents\MATLAB\]tasksOutputs\',baseName,'\'];

%% Check to make sure that the folders do not exist before
dataFolderCheck = exist(rootPath{1,1});
functionsFolderCheck = exist(rootPath{2,1});
outputFolderCheck = exist(rootPath{3,1});

%% Generate the folders.
if dataFolderCheck == 0%folder does not exist
    mkdir(rootPath{1,1})
end
if functionsFolderCheck == 0%folder does not exist
    mkdir(rootPath{2,1})
end
if outputFolderCheck == 0%folder does not exist
    mkdir(rootPath{3,1})
end