%% Nicholas Czarnek
% SSPACISS/Mazurowski Laboratories, Duke University
% Modified 3 August 2015
%
% balance_data_v2(X_train,Y_train,numObsPerClass,classLabels)
% This function outputs a subset of the input X_train and Y_train based on
% the inputs.
% Example:
% labeledSubset = balance_data(X_train,Y_train,5000*[10 1 1 1 1],[1 2 3 4 5])

function [xSubset,ySubset] = balance_data_v2(X_train,Y_train,numObsPerClass,classLabels)

xSubset = zeros(sum(numObsPerClass),size(X_train,2));
ySubset = zeros(sum(numObsPerClass),1);

dataIdxStart = 1;
dataIdxEnd = numObsPerClass(1);

for cInc = 1:numel(classLabels)
    classLogicals = Y_train == classLabels(cInc);
    classSubset = X_train(classLogicals,:);
    subsetLabels = Y_train(classLogicals);
    
    if numel(subsetLabels)>numObsPerClass(cInc)
        keepIdx = randsample(numel(subsetLabels),numObsPerClass(cInc));
    else
        keepIdx = 1:numel(subsetLabels);
        dataIdxEnd = dataIdxStart + numel(subsetLabels) - 1;
    end
    
    xSubset(dataIdxStart:dataIdxEnd,:) = classSubset(keepIdx,:);
    ySubset(dataIdxStart:dataIdxEnd) = subsetLabels(keepIdx);
    
    dataIdxStart = dataIdxEnd + 1;
    if cInc<numel(classLabels)
        dataIdxEnd = dataIdxStart + numObsPerClass(cInc + 1) - 1;
    end
end

%% If a class did not have enough observations, remove these.
xSubset = xSubset(ySubset ~= 0,:);
ySubset = ySubset(ySubset ~= 0);

end