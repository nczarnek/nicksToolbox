% Nicholas Czarnek
% ROC calculator
% Base threshold on data rather than arbitrary moving points
%
% data = [values labels]. labels: 0-noise,1-signal
% function [Pf,Pd] =...
%    nickROC(data,plotOptionLin,plotOptionNorm,plotColor,plotSymbol,linHandle,normHandle);
%
% Use figure('units','normalized','outerposition',[0 0 1 1])
% for a full screen figure
%
% Add the following to improve the normal plots.
% p = [0.001 0.003 0.01 0.02 0.05 0.10 0.25 0.5 ...
%     0.75 0.9 0.95 0.98 0.99 0.997 0.999];
% label = {'.001','.003', '.01','.02','.05','.10','.25','.50', ...
%     '.75','.90','.95','.98','.99','.997', '.999'};
% tick  = norminv(p,0,1);
% set(gca,'YTick',tick,'YTickLabel',label,'XTick',tick,'XTickLabel',label);

function [Pf,Pd] =...
    nickROC(data,plotOptionLin,plotOptionNorm,plotColor,plotSymbol,linHandle,normHandle)

% # of inputs with s&n vs # with only n
totalSigs = sum(data(:,2));
totalNoise = size(data,1) - totalSigs;

% Sort by input vale
sortedData = sortrows(data);

% Initialize linear and normal Pf and Pd
Pf = zeros(size(data,1),1);
Pd = zeros(size(data,1),1);
xPf = zeros(size(data,1),1);
xPd = zeros(size(data,1),1);

% labelMat used for comparison against data labels
labelMat = zeros(size(data,1),1);

for threshInc = 1:size(data,1)
    % Sequential data points serve as thresholds
    currentThreshhold = sortedData(threshInc,1);
    labelMat(sortedData(:,1) >= currentThreshhold) = 1;
    labelMat(sortedData(:,1) < currentThreshhold) = 0;
    
    % Pd = detection probability
    detectedSigs = sum(labelMat == 1 & sortedData(:,2) == 1);
    Pd(threshInc,1) = min(detectedSigs/totalSigs,.999);% log protection
    xPd(threshInc,1) = (2^.5)*erfinv(2*Pd(threshInc,1)-1);
    
    % Pf =  false alarm probability
    falseSigs = sum(labelMat == 1 & sortedData(:,2) == 0);
    Pf(threshInc,1) = min(falseSigs/totalNoise,.999);
    xPf(threshInc,1) = (2^.5)*erfinv(2*Pf(threshInc,1)-1);
end

if plotOptionLin == 1
    % Linear ROC
    figure(linHandle);hold on;
    plot(Pf,Pd,[plotColor,plotSymbol])
    title('ROC')
    xlabel('Pf')
    ylabel('Pd','Rotation',0,'HorizontalAlignment','right')
    grid on
end
   
if plotOptionNorm == 1
    % Normal Normal ROC
    figure(normHandle);hold on;
    plot(xPf,xPd,[plotColor,plotSymbol])
    title('Normal normal ROC')
    xlabel('Normal Pf')
    ylabel('Normal Pd','Rotation',0,'HorizontalAlignment','right')
    grid on
end

return