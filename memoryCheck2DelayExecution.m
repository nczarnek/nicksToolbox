% Nicholas Czarnek
% SSPACISS Lab, Duke University
% 8 February 2013

% Source: Jordan Malof
% Halts the program if it detects there is very little RAM remaining
% It checks the memory every 5 minutes to see if the condition has
% improved and the program will continue if the condition has
% in fact improved:  the available memory becomes greater than the
% memoryCutoff value.

function [] = memoryCheck2DelayExecution(memoryCutoff)

% Typical memory cutoff is 500100100
% This is half of a GB of RAM remaining
%% MEMORY PROTECTION
[~,memStats]=memory;
if memStats.PhysicalMemory.Available <=memoryCutoff % if only 0.3 GB of memory remaining
    goFlag=0;
    sendmail('nmc22@duke.edu','Memory limit exceeded','');
    %Wait until memory becomes available
    while goFlag==0
        disp('MEMORY RUNNING LOW!')
        keyboard
        [~,memStats]=memory;
        if memStats.PhysicalMemory.Available > memoryCutoff
            goFlag=1;
            disp('CONTINUING...')
        end
    end
end