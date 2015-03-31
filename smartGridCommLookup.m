%% Nick Czarnek
% SSPACISS Laboratory, Duke University
% 24 March 2015
%
% smartGridCommLookupTable.m
% The purpose of this file is to make a lookup table for the smartGridComm
% outputs

function outputString = smartGridCommLookup(inputString)

switch inputString(1)
    case 'a'
        outputString = 'truth';
    case 'b'
        outputString = 'glr';
    case 'c'
        outputString = 'sobel';
    case ' '
        outputString = '';
    otherwise
        error('Not a valid detector\n');
end

if ~isempty(outputString)
    outputString = cat(2,outputString,' detector used for classification');
    if numel(inputString)>=2
        if ~strcmp(inputString(2),' ')
            outputString = cat(2,outputString,', ');
        end
    end
end

if numel(inputString)>=2
    switch inputString(2)
        case 'a'
            outputString = cat(2,outputString,'truth');
        case 'b'
            outputString = cat(2,outputString,'knn');
        case 'c'
            outputString = cat(2,outputString,'rf');
        case 'd'
            outputString = cat(2,outputString,'svm');
        case 'e'
            outputString = cat(2,outputString,'rbf svm');
        case ' '
            
        otherwise
            error('Not a valid classifier\n')
    end
    if ~strcmp(inputString(2),' ')
        outputString = cat(2,outputString,' classifier used for assignment');
        if numel(inputString) == 3
            if ~strcmp(inputString(3),' ')
                outputString = cat(2,outputString,', ');
            end
        end
    end
    
    if numel(inputString) == 3
        switch inputString(3)
            case 'a'
                outputString = cat(2,outputString,'submetered average assignment');
            case 'b'
                outputString = cat(2,outputString,'aggregate average assignment');
            case ' '
                
            otherwise
                error('Not a valid assignment method\n');
        end
    end
end

end