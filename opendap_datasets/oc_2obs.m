function [ outvar,units,fname,latout,lonout] = oc_2obs(lat,lon,t,var,varargin)
% oc_2obs
% -------------------------------------------------------------------------
% extracts NASA L3smi ocean color observations nearest to inputted lat/lon/t 
% from netCDFs in NASA ocean color opendap server
% link - http://oceandata.sci.gsfc.nasa.gov/opendap/
% -------------------------------------------------------------------------
% USAGE:
% -------------------------------------------------------------------------
% [PAR] = oc_2obs(lat,lon,t,'par');
% [PAR,units,fnames] = oc_2obs(lat,lon,t,'par','res','4km','sensor','VIIRS');
% -------------------------------------------------------------------------
% INPUTS:
% -------------------------------------------------------------------------
% lat:      vector of observed latitudes
% lon:      vector of observed longitudes (between [-180 and +360]
% t:        datetime or datenum time input - vector or scalar
% var:      string of input variable
% varargin: optional variables passed through to oc_url.m
% 
% -------------------------------------------------------------------------
% OUTPUTS:
% -------------------------------------------------------------------------
% outvar:   vector of requested data
% units:    string with units for outvar
% fname:    opendap addresses for files that were accesed
% lonout:   vector of longitudes corresponding to matched NASA grid cell
% latout:   vector of latitudes corresponding to matched NASA grid cell
%
%
% -------------------------------------------------------------------------
% ALSO SEE: 
% -------------------------------------------------------------------------
% oc_url.m
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
fname = oc_url(t(1),var,varargin{:});

units = ncreadatt(fname,var,'units');
m = ncreadatt(fname,var,'scale_factor');
b = ncreadatt(fname,var,'add_offset');
latv = ncread(fname,'lat');
lonv = ncread(fname,'lon');

%% Initialize output and get nearest datapoint to each obs point
outvar = nan(nobs,1);
latout = outvar;
lonout = outvar;
fname = cell(nobs,1);
lastFname = '';
for ii = 1:nobs
    [~,ilat] = min(abs(lat(ii) - latv));
    [~,ilon] = min(abs(lon(ii) - lonv));
    fname{ii} = oc_url(t(ii),var,varargin{:});
    try
%         if ~strcmpi(fname{ii},lastFname)
%             v = ncread(fname{ii},var,[ilon,ilat],[1,1]);
%         end
        v = ncread(fname{ii},var,[ilon,ilat],[1,1]);
        outvar(ii) = v;
    catch
        disp(['error accessing' fname{ii}]);
        outvar(ii) = NaN;
        continue
    end
    latout(ii) = latv(ilat);
    lonout(ii) = lonv(ilon);
    lastFname = fname{ii};
end


end

