function [ url ] = hy_url(t,varName,varargin)

% hy_url
% -------------------------------------------------------------------------
% constructs netCDF filename for hycom.org thredds server
% link - http://hycom.org/dataserver
% -------------------------------------------------------------------------
% USAGE:
% -------------------------------------------------------------------------
% [url] = hy_url(t,'surf_el')
% 
% [url] = hy_url(datetime(2015,7,1),'surf_el')
%
% -------------------------------------------------------------------------
% INPUTS:
% -------------------------------------------------------------------------
% Required
% t:        datetime or datenum time input - vector or scalar
% var:      string of variable name
% 
%
% -------------------------------------------------------------------------
% OUTPUTS:
% -------------------------------------------------------------------------
% url:  full opendap/thredds address of requested file
%
% -------------------------------------------------------------------------
% ABOUT:  David Nicholson // dnicholson@whoi.edu // 01 JUL 2015
% -------------------------------------------------------------------------

threddsRoot = 'http://tds.hycom.org/thredds/';
config = 'GLBu0.08';

% time in datetime - dateshift ensures there are not artifacts from
% numerical rounding errors in conversion from datenum
if ~isdatetime(t)
    dtm = datetime(t, 'ConvertFrom', 'datenum');
else
    dtm = t;
end
dtm = dateshift(dtm,'start','second','nearest');


% identify which file the variable is in

suite = [];
% identify experiment date range
if dtm(1) < datetime(2012,05,01)
    % reanalysis has all variables lumped into one netcdf file - easy!
    % this is daily (00:00Z) 3-hourly also available but implemented here
    expt = 'reanalysis';
    config = 'GLBa0.08';
elseif dtm(1) < datetime(2013,08,01)
    expt = 'expt_90.9';
elseif dtm(1) < datetime(2014,04,07)
    expt = 'expt_91.0';
elseif dtm(1) < datetime(2016,04,18)
    expt = 'expt_91.1';
else
    expt = 'expt_91.2';
    switch varName
        case 'surf_el'
            suite = 'ssh';
        case {'water_u','water_v'}
            suite = 'uv3z';
        case {'water_temp','salinity'}
            suite = 'ts3z';
        otherwise
            error('invalid variable name');
    end
end

% construct url
url = fullfile(threddsRoot,'dodsC',config,expt,suite);




end

