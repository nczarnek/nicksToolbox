%% Nicholas Czarnek
% 15 August 2014
% SSPACISS Laboratory, Duke University
%
% powerVisualization.m
% The purpose of this function is to visualize energyDataSets.

function visualizePower(energyDS,varargin)

if ~isempty(varargin)
  visualizationType = lower(varargin{1});
else
  visualizationType = 'barchart';
end

switch visualizationType
  case 'barchart'
    % Note that sometimes the sum of the components use less power than 
    % the sum of the mains due to unmetered appliances.
    
    useIdx = find(strcmp(energyDS.getFeatureNames,'use'));
    
    logicalKeep = true(energyDS.nFeatures,1);
    logicalKeep(useIdx) = false;
    
    % Not reliant on time since we're just looking at the ratio of energy
    % used.
    totalEnergy = trapz(energyDS.data(:,useIdx));
    
    percentEnergyUsed = trapz(energyDS.data(:,logicalKeep))/totalEnergy;
    
    [sortedEnergy,sortedIdx] = sort(percentEnergyUsed,'descend');
    axisLabels = energyDS.getFeatureNames(logicalKeep);
    axisLabels = axisLabels(sortedIdx);
    
    
    %% Make the bar chart
    figure;
    bar(sortedEnergy * 100)
    ylabel('Percent energy used by appliance')
    xticklabel_rotate(1:energyDS.nFeatures-1,90,axisLabels,'interpreter','none');
    grid on
    grid minor
    title('Percent of total energy used by appliance type')
    
    
  case 'area'
    %% Display a stacked area chart 
    useIdx = find(strcmp(energyDS.getFeatureNames,'use'));
    
    logicalKeep = true(energyDS.nFeatures,1);
    logicalKeep(useIdx) = false;
    
    % Not reliant on time since we're just looking at the ratio of energy
    % used.
    totalEnergy = trapz(energyDS.data(:,useIdx));
    
    percentEnergyUsed = trapz(energyDS.data(:,logicalKeep))/totalEnergy;
    
    [~,sortedIdx] = sort(percentEnergyUsed,'descend');

    timeX = [energyDS.getObservationInfo.times]';
    timeX = (timeX - min(timeX))*1440;
    
    %% To avoid computer freeze, only visualize one day of data
    timeOneDay = timeX(timeX<1440);
    
    energyDS = energyDS.retainObservations(1:size(timeOneDay,1));
    
    figure;
    plot(timeOneDay,energyDS.data(:,useIdx),'g--')
    
    subSet = energyDS.retainFeatures(logicalKeep);
    hold on
    area(timeOneDay,subSet.data(:,sortedIdx))
    xlabel('Time (min)')
    ylabel('Power (W)')
    title('Stacked area plot of power ordered by total energy used')
    xlim([min(timeOneDay) max(timeOneDay)])
    
    legendNames = cat(1,'use',subSet.getFeatureNames(sortedIdx)');
    
    legend(legendNames)
    
  otherwise
    %% Default to bar chart
    % Note that sometimes the sum of the components use less power than 
    % the sum of the mains due to unmetered appliances.
    
    useIdx = find(strcmp(energyDS.getFeatureNames,'use'));
    
    logicalKeep = true(energyDS.nFeatures,1);
    logicalKeep(useIdx) = false;
    
    % Not reliant on time since we're just looking at the ratio of energy
    % used.
    totalEnergy = trapz(energyDS.data(:,useIdx));
    
    percentEnergyUsed = trapz(energyDS.data(:,logicalKeep))/totalEnergy;
    
    [sortedEnergy,sortedIdx] = sort(percentEnergyUsed,'descend');
    axisLabels = energyDS.getFeatureNames(logicalKeep);
    axisLabels = axisLabels(sortedIdx);
    
    
    %% Make the bar chart
    figure;
    bar(sortedEnergy * 100)
    ylabel('Percent energy used by appliance')
    xticklabel_rotate(1:energyDS.nFeatures-1,90,axisLabels,'interpreter','none');
    grid on
    grid minor
    title('Percent of total energy used by appliance type')
    
end