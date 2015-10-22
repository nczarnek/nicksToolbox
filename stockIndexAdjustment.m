%% Nicholas Czarnek
% Personal Finance
% 16 May 2016
%
% stockIndexAdjustment.m
% The purpose of this function is to take in stock data from an index fund
% and shift it by a day.  This is done so that we can analyze how today's
% SP500 price affects tomorrows N225 price.
%
% Rules:
% In the adjusted csv file, where each previous day's stock is shifted to
% the next day, only move the stock's price to the next day if the current
% day is monday through thursday.
% 
% adjustedDetails = stockIndexAdjustment(fullDetails)
%
% Input:
% Cell array from reading in a csv file.
%
% fullDetails = {Date Open High Low Close Volume AdjClose}
%
% Output:
% Cell array from shifting the stock prices.


function adjustedDetails = stockIndexAdjustment(fullDetails)

%% Set up the necessary variables.
Date = fullDetails{1};
Open = fullDetails{2};
High = fullDetails{3};
Low = fullDetails{4};
Close = fullDetails{5};
Volume = fullDetails{6};
AdjClose = fullDetails{7};

dateNums = datenum(Date);

minDate = min(dateNums);
maxDate = max(dateNums);

%% Note that this assumes that daily inputs are provided
newDates = minDate:maxDate;

newDateCells = datestr(newDates,'yyyy-mm-dd');

newDateCells = cellstr(newDateCells);

newOpenCells = zeros(numel(newDateCells),1);
oldOpenCells = newOpenCells;
newHighCells = newOpenCells;
newLowCells = newOpenCells;
newCloseCells = newOpenCells;
newVolumeCells = newOpenCells;
newAdjCloseCells = newOpenCells;

%% Go through all of the dates and move today's values to tomorrow's values
for dInc = 1:numel(Date)
    %% Find the corresponding date in the new date cell array.
    dateIndex = find(strcmp(Date{dInc},newDateCells));
    
    oldOpenCells(dateIndex) = Open(dInc);
    
    %% Move today's information to tomorrow.
    if dateIndex<numel(newOpenCells)
        newOpenCells(dateIndex+1) = Open(dInc);
        newHighCells(dateIndex+1) = High(dInc);
        newLowCells(dateIndex+1) = Low(dInc);
        newCloseCells(dateIndex+1) = Close(dInc);
        newVolumeCells(dateIndex+1) = Volume(dInc);
        newAdjCloseCells(dateIndex+1) = AdjClose(dInc);
    end
end

newOpenCells = num2cell(newOpenCells);
newHighCells = num2cell(newHighCells);
newLowCells = num2cell(newLowCells);
newCloseCells = num2cell(newCloseCells);
newVolumeCells = num2cell(newVolumeCells);
newAdjCloseCells = num2cell(newAdjCloseCells);

adjustedDetails = [newDateCells newOpenCells newHighCells newLowCells newCloseCells newVolumeCells newAdjCloseCells];

adjustedDetails = cat(1,[{'Date'} {'Open'} {'High'} {'Low'} {'Close'} {'Volume'} {'Adj Close'}],adjustedDetails);

