% -------------------------------------------------------------------------
% Reads WOA13v2 data via OPENDAP server
%
% INPUTS:
% -------------------------------------------------------------------------
% varname:      variable name string  (e.g. 'dissolved_oxygen')
% var_code:     WOA13 code for variable type (e.g. 'an')
% tspec:        time grid option             (e.g. '01')
%               00 = annual mean, 01-12 = corresponding month 13-16 = season 
% res:          grid horizontal resolution   (e.g. 1)
% varargin:     option to pass arguments to ncread (i.e. start,count,stride)
% 
% OUTPUTS:
% -------------------------------------------------------------------------
% data:         requested gridded dataset
% varargout:    optional dimension info (x,y,z,t)
%
% USAGE:
% [o2,x,y,z,t] = read_WOA13('dissolved_oxygen','an','03',1);
% 
% 
% AUTHOR: David Nicholson // dnicholson@whoi.edu // 05 OCT 2012
% -------------------------------------------------------------------------

function [data, varargout] = read_WOA13(varname,var_code,tspec,res,varargin)

% resolution
if res == 1
    res_str1 = '1.00';
    res_str2 = '01';
elseif res == 5
    res_str1 = '5deg';
    res_str2 = '5d';
else
    error('resolution must be 1 or 5');
end

% permitted variable names
variable_name = {'temperature','salinity','oxygen','o2sat','AOU','nitrate','phosphate','silicate'};
% corresponding WOA codes
nc_variable_name = {'t','s','o','O','A','n','p','i'};   
% map text file names to WOA variable codes
name2var = containers.Map(variable_name,nc_variable_name);

if ~ismember(varname,variable_name)
    error('invalid variable name');
end

% _on is the code for objectively analysed values
varn = strcat(name2var(varname),'_',var_code);

% root address for WOA09 server

thredds = 'http://data.nodc.noaa.gov/thredds/dodsC/woa/WOA13/DATAv2/';

% create file name to append
fname = strcat(thredds,varname,'/netcdf/all/',res_str1,'/woa13_all_',name2var(varname),tspec,'_',res_str2,'.nc');

if nargin == 4
    data = ncread(fname,varn);
    if nargout > 1
        t = ncread(fname,'time');
        z = ncread(fname,'depth');
        y = ncread(fname,'lat');
        x = ncread(fname,'lon');
    end
elseif nargin == 7
    start = varargin{1};
    count = varargin{2};
    stride = varargin{3};
    data = ncread(fname,varn,start,count,stride);
    if nargout > 1
        t = ncread(fname,'time',start(4),count(4),stride(4));
        z = ncread(fname,'depth',start(3),count(3),stride(3));
        y = ncread(fname,'lat',start(2),count(2),stride(2));
        x = ncread(fname,'lon',start(1),count(1),stride(1));
    end
end

switch nargout
    case 2
        varargout(1) = {x};
	case 3
		varargout(1) = {x};
		varargout(2) = {y};
	case 4	
		varargout(1) = {x};
		varargout(2) = {y};
		varargout(3) = {z};
	case 5
		varargout(1) = {x};
		varargout(2) = {y};
		varargout(3) = {z};
		varargout(4) = {t};
end