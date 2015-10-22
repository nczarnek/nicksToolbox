%% Nichoals Czarnek
% SSPACISS laboratory, Duke University
% 17 March 2015
%
% addToTitle.m
% The purpose of this function is to add on to the current figure's title.
% This is especially useful for figure outputs from the prt in case you
% want to add additional information to a plot.

function addToTitle(addOn)
%% Get the current title
h = get(gca,'Title');
t = get(h,'String');

%% Add on to the title
if numel(t) == 1
    newTitle = [t,', ',addOn];
else
    t{end} = [t{end},', ',addOn];
    newTitle = t;
end
title(newTitle)



end