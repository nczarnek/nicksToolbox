%% Nicholas Czarnek
% 23 February 2015
% SSPACISS Laboratory, Duke University
%
% getEventIdx
% The purpose of this function is to get event indices based on input time
% stamps and input event times.  This assumes that the input times are in
% UTC format

function eventIdx = getEventIdx(xT,eventTimes)

tDiff = xT(2) - xT(1);

%% Figure out how many time stamps there are per day based on the input time
% stamps
utcTRes = round(1/tDiff);

%% Adjust the timestamps so that they are not rounded.
xT = round(xT*utcTRes)/utcTRes;

%% Adjust the eventTimes accordingly so that they are in line with the time
% resolution of the input timestamps.
eventTimes = round(eventTimes*utcTRes)/utcTRes;

%% Find the indices for the events.  Since there may be repeated events, use
% a for loop for each event.
eventIdx = zeros(numel(eventTimes),1);

for eInc = 1:numel(eventTimes)
    eventIdx(eInc) = find(xT == eventTimes(eInc));
end

end