%% Nicholas Czarnek
% SSPACISS Laboratory, Duke University
% 28 June 2014
%
% combinePecanStreetMonths.m
% Pecan street data sets couldn't be extracted as one large dataset, so
% this function was written to combine the multiple extracts for a given
% house.
%
% This function takes two input folders and one output folder where the
% combined results should be written.
%
% This function assumes that the measurements were continuous between files
%
function combinePecanStreetMonths(f1,f2,fOut)

%% Determine the folder contents.
fContents{1} = dir([f1,'\*.mat']);
fContents{2} = dir([f2,'\*.mat']);

%% Go through each and only keep the numbers.
houseIds{1} = zeros(max(size(fContents{1})),1);
houseIds{2} = zeros(max(size(fContents{2})),1);

% Folder 1
for fileInc = 1:max(size(fContents{1}))
  fileName = fContents{1}(fileInc).name;
  
  fileName(ismember(fileName,'house_.mat')) = [];
  
  houseIds{1}(fileInc) = str2double(fileName);
  
end


% Folder 2
for fileInc = 1:max(size(fContents{2}))
  fileName = fContents{2}(fileInc).name;
  
  fileName(ismember(fileName,'house_.mat')) = [];
  
  houseIds{2}(fileInc) = str2double(fileName);
  
end

%% Combine shared houses. Use the larger of the two folders for the ismember check.
if size(houseIds{1},1)>size(houseIds{2},1)
  bigHouse = 1;
  smallHouse = 2;
  bigFolder = f1;
  smallFolder = f2;
else
  bigHouse = 2;
  smallHouse = 1;
  bigFolder = f2;
  smallFolder = f1;
end

houseLogicals = ismember(houseIds{bigHouse},houseIds{smallHouse});
otherLogicals = ismember(houseIds{smallHouse},houseIds{bigHouse});

%% Go through the houses that are not shared and save them to the output folder
% Larger folder
badBig = find(~houseLogicals);
for bInc = 1:size(badBig,1)
  load(fullfile(bigFolder,['\house_',num2str(houseIds{bigHouse}(badBig(bInc)))]));
  
  % Add observation info to the houseData.
  if isfield(houseData.userData,'times')
    obsInfo = struct('times',num2cell(datenum(houseData.userData.times))',...
      'units',repmat({'kW'},1,houseData.nObservations));
    
    houseData.observationInfo = obsInfo;
    
    houseData.userData = rmfield(houseData.userData,'times');
    
    % If time has already been removed, we can just set hData to houseData
    % and not worry about it.
  end
  
  % Save into the combined folder as long as the combined folder is not one
  % of the inputs.
  try
    save(fullfile(fOut,['\house_',num2str(houseIds{bigHouse}(badBig(bInc)))]),'houseData');
  catch
    save(fullfile(fOut,['\house_',num2str(houseIds{bigHouse}(badBig(bInc)))]),'houseData','-v7.3');
  end
end

badSmall = find(~otherLogicals);
for bInc = 1:size(badSmall,1)
  load(fullfile(smallFolder,['\house_',num2str(houseIds{smallHouse}(badSmall(bInc)))]));
  
  if isfield(houseData.userData,'times')
    obsInfo = struct('times',num2cell(datenum(houseData.userData.times))',...
      'units',repmat({'kW'},1,houseData.nObservations));
    
    houseData.observationInfo = obsInfo;
    
    houseData.userData = rmfield(houseData.userData,'times');
  end
  
  % Save into the combined folder.
  try
    save(fullfile(fOut,['\house_',num2str(houseIds{smallHouse}(badSmall(bInc)))]),'houseData');
  catch
    save(fullfile(fOut,['\house_',num2str(houseIds{smallHouse}(badSmall(bInc)))]),'houseData','-v7.3');
  end
end


%% Go through the houses that are shared and save the combination of their
% data to the output folder. Make sure to check that which data goes first
% when concatenating the data and user data together.
sharedHouses = find(houseLogicals);

%% Which houses were not monitored with a consistent number of sensors?
problemHouses = [];

for hInc = 1:size(sharedHouses,1)
  %% load the houses from each folder
  houseNumber = houseIds{bigHouse}(sharedHouses(hInc));
  load(fullfile(bigFolder,['\house_',num2str(houseNumber)]));
  
  % Fix observation info
  hData{1} = houseData;
  
  %%
  if isfield(houseData.userData,'times')
    obsInfo = struct('times',num2cell(datenum(houseData.userData.times))',...
      'units',repmat({'kW'},1,houseData.nObservations));
    
    hData{1}.observationInfo = obsInfo;
    
    hData{1}.userData = rmfield(hData{1}.userData,'times');
    
    % If time has already been removed, we can just set hData to houseData
    % and not worry about it.
  end
  
  %% House 2
  load(fullfile(smallFolder,['\house_',num2str(houseNumber)]));
  % Fix observation info
  hData{2} = houseData;
  
  if isfield(houseData.userData,'times')
    obsInfo = struct('times',num2cell(datenum(houseData.userData.times))',...
      'units',repmat({'kW'},1,houseData.nObservations));
    
    hData{2}.observationInfo = obsInfo;
    
    hData{2}.userData = rmfield(hData{2}.userData,'times');
  end
  
  clear('obsInfo')
  
  try
    % Concatenate everything together and sort by date.
    houseData = catObservations(hData{1},hData{2});
    
    %% Save it.
    try
      save(fullfile(fOut,['\house_',num2str(houseNumber)]),'houseData')
    catch
      save(fullfile(fOut,['\house_',num2str(houseNumber)]),'houseData','-v7.3')
    end
  catch
    
    problemHouses = cat(1,problemHouses,houseNumber);
    
    % keep the bigger file
    if hData{1}.nFeatures>hData{2}.nFeatures
      houseData = hData{1};
    else
      houseData = hData{2};
    end
    
    %% Save it.
    try
      try
        save(fullfile(fOut,['\house_',num2str(houseNumber)]),'houseData')
      catch
        save(fullfile(fOut,['\house_',num2str(houseNumber)]),'houseData','-v7.3')
      end
    catch
      continue
    end
    
    beep;
  end
end

timeS = clock;
timeS = timeS(end);
timeS = round(mod(timeS,1)*100000);

pHs = fullfile(fOut,'problemHouses');

if ~exist(pHs)
  mkdir(pHs)
end
save(fullfile(pHs,['problemHouses_',num2str(timeS)]),'problemHouses')