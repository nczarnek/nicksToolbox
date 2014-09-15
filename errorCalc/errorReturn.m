%% Nicholas Czarnek
% 21 February 2014
% SSPACISS Laboratory, Duke University
%
% errorCheck
% This class can be used to generate different errors for the Parson
% analysis.

classdef errorReturn
  %% Define the real signal and the signal that was measured.
  properties
    % if row length > column length and user does not want to transpose
    % matrix
    dontSwap = 0;
    value;
  end
  
  methods
    function rmsError = errorReturn(trueSignal,measuredSignal)
      %% Make sure that something was sent in.
      if nargin ~=2
        trueSignal = 0;
        measuredSignal = 0;
      end
      
      %% Check the dimensions
      if ~all(size(trueSignal) == size(measuredSignal))
        error('Please make sure that your dimensions are equal');
      end
      
      if ~ismatrix(trueSignal)
        error('Send in a two dimensional array');
      end
      
      %% Make sure that RMSE is calculated on the columns.
      if size(trueSignal,2)>size(trueSignal,1)
        if ~rmsError.dontSwap
          trueSignal = trueSignal';
          measuredSignal = measuredSignal';
        end
      end
      
      nDataPoints = size(trueSignal,1);
      
      rmsError.value = sqrt(1/nDataPoints*sum((trueSignal - measuredSignal).^2));
    end
    
  end
  
  
end