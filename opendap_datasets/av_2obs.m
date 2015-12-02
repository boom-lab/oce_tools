function [ outvar,latout,lonout,tout] = av_2obs(lat,lon,t,var,varargin)
% hy_2obs
% -------------------------------------------------------------------------
% extracts aviso output nearest to inputted lat/lon/t vectors
% 
% -------------------------------------------------------------------------
% USAGE:
% -------------------------------------------------------------------------
% [ssh] = av_2obs(lat,lon,t,'sla');
% -------------------------------------------------------------------------
% INPUTS:
% -------------------------------------------------------------------------
% lat:      vector of observed latitudes
% lon:      vector of observed longitudes (between [-180 and +360])
% t:        datetime or datenum time input - vector or scalar
% var:      string of input variable
% varargin: optional variables passed through to av_url.m
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
% av_url.m
% av_slab.m
%
% -------------------------------------------------------------------------
% ABOUT: David Nicholson // dnicholson@whoi.edu // 9 NOV 2015
% -------------------------------------------------------------------------

nobs = length(lat);
% check if t is scalar and resize to match lat and lon
if length(t) == 1
    t = repmat(t,nobs,1);
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

latrng = [floor(min(lat)) ceil(max(lat))];
% 0 - 360 range
lonrng1 = [floor(min(lon)) ceil(max(lon))];
lon2 = lon;
lon2(lon > 180) = lon(lon > 180) - 360;
lonrng2 = [floor(min(lon2)) ceil(max(lon2))];
if diff(lonrng1) <= diff(lonrng2)
    % within 0 - 360 range
    lonrng = lonrng1;
else
    % wrap around prime meridian
    lonrng = lonrng2;
end
trng = [min(dtm) max(dtm)];

[slab,latAv,lonAv,tAv] = av_slab(latrng,lonrng,trng,var,varargin{:});


%% Initialize output and get nearest datapoint to each obs point
NV = nan(nobs,1);
outvar = NV;
latout = NV;
lonout = NV;
tout = datetime(NV,'ConvertFrom','datenum');

for ii = 1:nobs
    [~,ilat] = min(abs(lat(ii) - latAv));
    [~,ilon] = min(abs(lon(ii) - lonAv));
    [~,it] = min(abs(tAv-dtm(ii)));
    outvar(ii) = slab(ilat,ilon,it);
    latout(ii) = latAv(ilat);
    lonout(ii) = lonAv(ilon);
    tout(ii) = tAv(it);
end


end

