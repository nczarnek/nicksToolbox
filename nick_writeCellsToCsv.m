%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 3 June 2014
%
% nick_writeCellsToCSV.m
% The purpose of this script is to write a cell array to a csv file.  This
% code is based on:
% http://stackoverflow.com/questions/6752102/outputing-cell-array-to-csv-file-matlab

function nick_writeCellsToCsv(inputCells,csvFilename)

%% build cellarray of lines, values are comma-separated
[m n] = size(inputCells);
CC = cell(m,n+n-1);
CC(:,1:2:end) = inputCells;
CC(:,2:2:end,:) = {','};
CC = arrayfun(@(i) [CC{i,:}], 1:m, 'UniformOutput',false)';

%% write lines to file
fid = fopen(csvFilename,'wt');
fprintf(fid, '%s\n',CC{:});
fclose(fid);