%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 23 March 2015
%
% cleanStrings.m
% The purpose of this function is to clean strings so that they can be
% saved properly.

function cleanString = cleanStrings(inString)

cleanString = inString;
cleanString(regexp(cleanString,'_')) = '';
cleanString(regexp(cleanString,'/')) = '';
cleanString(regexp(cleanString,'\')) = '';
cleanString(regexp(cleanString,'-')) = '';
cleanString(regexp(cleanString,' ')) = '';
cleanString(regexp(cleanString,'(')) = '';
cleanString(regexp(cleanString,')')) = '';