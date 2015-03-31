%% Jordan Malof
% SSPACISS Laboratory, Duke University
% 24 March 2015
%
% jUtil_saveThisFigure.m
% [] = jUtil_saveThisFigure(titleStr)
% Saves the current figure using the 'titleStr' input to label the figure and
% also to name the file where the figure is stored
% Automatically creates a 'tempFig' directory in the current working
% directory....does formatting first

function [] = jUtil_saveThisFigure(titleStr)

homeDir = 'C:\Users\Nick\Desktop';
flag = exist('tempFig','dir');
if flag~=7
    mkdir(fullfile(homeDir,'tempFig'))
end
% title(titleStr)
% dateStr = [num2str(year(date)) num2str(month(date)) num2str(day(date)) '_'];
dateStr = sprintf('%04d%02d%02d_',year(date),month(date),day(date));
% nameStr = ['tempFig\' dateStr titleStr];
nameStr = fullfile(assertDir(homeDir,'tempFig'),[ dateStr titleStr]);
% saveas(gcf, nameStr)
% export_fig(nameStr,'-png','-transparent','-r500')
s2(gcf,{'png','fig'},nameStr,'qualityFactor',2); % Higher Quality

%% powerpoint save
saveppt2(fullfile(homeDir,'matlabFigureDump.ppt'),'columns',1,'text',titleStr,'halign','center','valign','center','stretch',false,'scale',false);

% 'columns',columns,'title',slideTitle,'halign','center','valign','center','stretch',false)

% saveppt2('test.ppt','text',sprintf('Hello World!\nLine Two'));
% NOTE: A higher quality factor is not necessarily better
% Choosing a higher value actually tends to blur some details
% but making it too small begins to make things look bad too

% s2('png','test','qualityFactor',6); % Higher Quality
% s2(gcf,'png','test','whiteSpaceMargin',100); % Add a margin
%   s2('png','test','trimWhiteSpace',false); % Leave the big margin

% set(gca,'FontSize',12)
% set(gca,'FontWeigh','bold')
% saveas(gcf,[pwd '\tempFig\' title '.fig'])
% title(gca,'hello')