function utilDir = nickRoot
% utilROOT  Tells the location of this file.
%   This file should remain in the util root directory to inform other util
%   functions of their location
%
% Syntax: utilDir = utilRoot
%
% Inputs: 
%   none
%
% Outputs:
%   utilDir - A string containing the path to this file.
%
% Examples:
%   utilRoot
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: util

% Author: Kenneth D. Morton Jr.
% Duke University, Department of Electrical and Computer Engineering
% Email Address: collinslab@gmail.com
% Created: 07-Mar-2007

utilDir = fileparts(mfilename('fullpath'));