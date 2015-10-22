%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 29 April 2015
%
% adjustPower(maxPower,powerSignal)
% The purpose of this function is to adjust the input power signal
% (powerSignal) such that it never exceeds the aggregate power (maxPower).

function adjustedPower = adjustPowerToMax(maxPower,powerSignal)

greaterThanIdx = powerSignal>maxPower;

adjustedPower = powerSignal;

adjustedPower(greaterThanIdx) = maxPower(greaterThanIdx);

end