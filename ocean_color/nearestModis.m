function [ outvar,units,fname] = nearestModis(lat,lon,t,var,varargin)
% nearestModis
% -------------------------------------------------------------------------
% extracts MODISA observations nearest to inputted lat/lon/t vectors
% link - http://oceandata.sci.gsfc.nasa.gov/opendap/
% -------------------------------------------------------------------------
% USAGE:
% -------------------------------------------------------------------------
% [PAR] = nearestModis(lat,lon,t,'par')
%
% -------------------------------------------------------------------------
% INPUTS:
% -------------------------------------------------------------------------
% lat:      vector of observed latitudes
% lon:      vector of observed longitudes (between [-180 and +360]
% t:        datetime or datenum time input - vector or scalar
% var:      string of input variable
% 
% -------------------------------------------------------------------------
% OUTPUTS:
% -------------------------------------------------------------------------
% outvar:   vector of requested data
% units:    string with units for outvar
% fname:    opendap addresses for files that were accesed
%
%
% -------------------------------------------------------------------------
% ALSO SEE: 
% -------------------------------------------------------------------------
% ocFileString.m
%
% -------------------------------------------------------------------------
% ABOUT: David Nicholson // dnicholson@whoi.edu // 29 JUN 2015
% -------------------------------------------------------------------------

% clean up lon, t and construct full filename      
% MODISA used -180:180 longitude range
lon(lon > 180) = lon(lon > 180) - 360;

nobs = length(lat);

% check if t is scalar and resize to match lat and lon
if length(t) == 1
    t = repmat(t,nobs,1);
end
if length(lon) ~= nobs || length(t) ~= nobs
    error('lat,lon and t must be the same length or scalar');
end

% construct OPENDAP address string for first file
fname = ocFileString(t(1),var,varargin{:});

units = ncreadatt(fname,var,'units');
m = ncreadatt(fname,var,'scale_factor');
b = ncreadatt(fname,var,'add_offset');
latv = ncread(fname,'lat');
lonv = ncread(fname,'lon');

%% Initialize output and get nearest datapoint to each obs point
outvar = nan(nobs,1);
fname = cell(nobs,1);
for ii = 1:nobs
    [~,ilat] = min(abs(lat(ii) - latv));
    [~,ilon] = min(abs(lon(ii) - lonv));
    fname{ii} = ocFileString(t(ii),var,varargin{:});
    v = ncread(fname{ii},var,[ilon,ilat],[1,1]);
    outvar(ii) = m.*v + b;
end


end

