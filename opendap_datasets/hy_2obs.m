function [ outvar,latout,lonout,tout,zout] = hy_2obs(lat,lon,z,t,var,varargin)
% hy_2obs
% -------------------------------------------------------------------------
% extracts HYCOM model output nearest to inputted lat/lon/t/z vectors
% 
% -------------------------------------------------------------------------
% USAGE:
% -------------------------------------------------------------------------
% [ssh] = hy_2obs(lat,lon,z,t,'surf_el');
% -------------------------------------------------------------------------
% INPUTS:
% -------------------------------------------------------------------------
% lat:      vector of observed latitudes
% lon:      vector of observed longitudes (between [-180 and +360])
% t:        datetime or datenum time input - vector or scalar
% var:      string of input variable
% varargin: optional variables passed through to hy_url.m
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
% hy_url.m
% hy_slab.m
%
% -------------------------------------------------------------------------
% ABOUT: David Nicholson // dnicholson@whoi.edu // 29 JUN 2015
% -------------------------------------------------------------------------

nobs = length(lat);
% check if t is scalar and resize to match lat and lon
if length(t) == 1
    t = repmat(t,nobs,1);
end
if length(z) == 1
    z = repmat(z,nobs,1);
end
if ~isdatetime(t)
    dtm = datetime(t, 'ConvertFrom', 'datenum');
else
    dtm = t;
end
dtm = dateshift(dtm,'start','day');

if length(lon) ~= nobs || length(t) ~= nobs
    error('lat,lon and t must be the same length or scalar');
end

lon = mod(lon,360);
% clean up lon, t and construct full filename      

latrng = [min(lat) max(lat)];
% 0 - 360 range
lonrng1 = [min(lon) max(lon)];
lon2 = lon;
lon2(lon > 180) = lon(lon > 180) - 360;
lonrng2 = [min(lon2) max(lon2)];
if diff(lonrng1) < diff(lonrng2)
    % if data falls within 0 - 360 range
    lonrng = lonrng1;
else
    % if it is better to wrap around prime meridian
    lonrng = lonrng2;
end
trng = [min(dtm) max(dtm)];
zrng = [floor(min(z)) ceil(max(z))];

[slab,latHy,lonHy,zHy,tHy] = hy_slab(latrng,lonrng,zrng,trng,var);


%% Initialize output and get nearest datapoint to each obs point
NV = nan(nobs,1);
outvar = NV;
latout = NV;
lonout = NV;
tout = datetime(NV,'ConvertFrom','datenum');
zout = NV;
for ii = 1:nobs
    [~,ilat] = min(abs(lat(ii) - latHy));
    [~,ilon] = min(abs(lon(ii) - lonHy));
    [~,it] = min(abs(tHy-dtm(ii)));
    [~,iz] = min(abs(zHy-z(ii)));
    outvar(ii) = slab(ilat,ilon,it,iz);
    latout(ii) = latHy(ilat);
    lonout(ii) = lonHy(ilon);
    tout(ii) = tHy(it);
    zout(ii) = zHy(iz);
end


end

