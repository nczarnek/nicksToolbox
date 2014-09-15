%UTC_TIME - Get the System Time in UTC (Universal Time Convention)
% UTC replaces the older convention of GMT.
% Reference- US Navy Time Services Department- http://tycho.usno.navy.mil/
% UTC is the standard in C programming for time. Number of seconds since
% 1970 in UTC (NOT local time). Matlab time functions are all in local
% time.
%
% TM = UTC_TIME
%
% Input(s):
%  N/A
%
% Output(s):
%  TM - time value cast to double. This is not the same as a matlab serial
%  date number (date numbers are in units of days since 1-jan-0000 in local
%  time, TM is in units of seconds since 1-jan-1970 in UTC time not the
%  local time zone).
%
% See also UTC2DATENUM, DATENUM

% Author(s): Abraham Cohn, March 2005

% Reference(s): http://www.cplusplus.com/ref/ctime/

% Copyright Philips Medical Systems
error('MEX file required.');
