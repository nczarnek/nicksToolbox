%UTC2DATENUM - Convert UTC time into a matlab serial date number.
%  UTC2DATENUM(UTC_TIME) should be the same as DATENUM(NOW)
%
% [DN, TZONE] = UTC2DATENUM(TM)
%
% Input(s):
%  TM - UTC time value (see UTC_TIME). This may be a vector.
%  In units of seconds since 1-jan-1970 in UTC time not the local time zone
%
% Output(s):
%  DN - matlab serial Date Number
%  DN is in units of days since 1-jan-0000 in local time 
%  The local time will be compensated for Daylight Savings Time.
%
%  !! If the time is off by an integer number of hours, it is likely that
%  your system is not properly configured for the Time Zone and Daylight
%  Savings Time settings. On Windows, check the Control Panel: Date and
%  Time Properties: Time Zone tab. 
%
%  TZONE - use this output to verify the local calculated time zone 
%  difference from UTC (in hours). If this value is wrong, then your system
%  is not configured properly (see note above). This vector will be the
%  same size as DN, and is calculated for each element of DN respectively.
%
%  Reference: US Navy Time Services Department - http://tycho.usno.navy.mil/
%
% See also UTC_TIME, DATENUM

% Author(s): Abraham Cohn, March 2005 / updated June 2006

% Reference(s): http://www.cplusplus.com/ref/ctime/

% Copyright Philips Medical Systems. Company Confidential.
error('MEX file required.');
