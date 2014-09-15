function nickPath(varargin)
% utilPATH  Add the all subdirectories of util to the MATLAB path.
%   This excludes sub directories which start with a "."
%   This also excludes sub directories that start with a "]" these can be
%   selectively added by specfying the remainder of the name of the folder
%   as inputs to this function.

P = genpath(nickRoot);
addpath(P);

%Remove some paths we don't need (we remove all directories that start with
% a . or a ]
removePath = [];
[string,remString] = strtok(P,pathsep);
while ~isempty(string);
    if ~isempty(strfind(string,[filesep '.'])) || ~isempty(strfind(string,[filesep ']']))
        removePath = cat(2,removePath,pathsep,string);
    end
    [string,remString] = strtok(remString,pathsep); %#ok
end
if ~isempty(removePath)
    rmpath(removePath);
end

% Parse arguments and add things to the path that were specified
for iArg = 1:length(varargin)
    cArg = varargin{iArg};
    cDir = fullfile(nickRoot,cat(2,']',cArg));
    assert(logical(exist(cDir,'file')),']%s is not a directory in %s',cArg,nickRoot);
    P = genpath(cDir);
    addpath(P);
    
    % Remove subfodlers that start with a .
    removePath = [];
    [string,remString] = strtok(P,pathsep);
    while ~isempty(string);
        if ~isempty(strfind(string,[filesep '.']))
            removePath = cat(2,removePath,pathsep,string);
        end
        [string,remString] = strtok(remString,pathsep); %#ok
    end
    if ~isempty(removePath)
        rmpath(removePath);
    end
end