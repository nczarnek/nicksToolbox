%% Nicholas Czarnek
% 22 June 2014
% SSPACISS Laboratory, Duke University
%
% nick_boostFigFonts.m
% This function boosts the size of the title, xlabel, and ylabel to Font
% size 16.
function nick_boostFigFonts(fontSize)

t = get(get(gca,'Title'),'String');
title(t,'FontSize',fontSize)

xL = get(get(gca,'xlabel'),'String');
xlabel(xL,'FontSize',fontSize)

yL = get(get(gca,'ylabel'),'String');
ylabel(yL,'FontSize',fontSize)

lHandle = legend;
set(lHandle,'FontSize',14)