%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 19 October 2014
%
% catBlued.m
% The purpose of this function is to concatenate two BLUED energyDataSets
% together.  This was specifically made for BLUED since the sampling
% frequency was too high too allow everything to be stored in
% observationInfo and required the use of userData.

function newSet = catBlued(eds1,eds2)

userData(1) = eds1.userData;
userData(2) = eds2.userData;

edsDesc{1} = eds1.description;
edsDesc{2} = eds2.description;

%% Which one is first?
d1 = [userData(1).startDate,' ',userData(1).startTime];
d2 = [userData(2).startDate,' ',userData(2).startTime];
if datenum(d1)>datenum(d2)
  % second house happens first
  newSet = catObservations(eds2,eds1);
  firstHouse = 2;
  secondHouse = 1;
else
  newSet = catObservations(eds1,eds2);
  firstHouse = 1;
  secondHouse = 2;
end

%% Combine the userData.
newSet.userData = userData(firstHouse);

newSet.userData.eventIdx = cat(2,userData(firstHouse).eventIdx,userData(secondHouse).eventIdx);
newSet.userData.eventTypes = cat(2,userData(firstHouse).eventTypes,userData(secondHouse).eventTypes);
newSet.userData.phase = cat(2,userData(firstHouse).phase,userData(secondHouse).phase);
newSet.userData.eventTimes = cat(2,userData(firstHouse).eventTimes,userData(secondHouse).eventTimes);

newSet.name = 'BLUED';
newSet.description = [edsDesc{firstHouse},'+',edsDesc{secondHouse}];