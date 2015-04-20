%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 1 April 2014
% 
% 
function zmedData = zmuv(inputData)

inputData = prtDataSetClass(inputData);

zmuv = prtPreProcZmuv;
zmuv = zmuv.train(inputData);

zmData = zmuv.run(inputData);
zmedData = zmData.data;

