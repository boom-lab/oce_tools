function [ outvar,latout,lonout,tout] = nr_2obs(lat,lon,t,var,subDir)
% hy_2obs
% -------------------------------------------------------------------------
% extracts ncep reanalysis output nearest to inputted lat/lon/t vectors
% 
% -------------------------------------------------------------------------
% USAGE:
% -------------------------------------------------------------------------
% [ssh] = nr_2obs(lat,lon,t,'uwnd.10m','surface_gauss');
% -------------------------------------------------------------------------
% INPUTS:
% -------------------------------------------------------------------------
% lat:      vector of observed latitudes
% lon:      vector of observed longitudes (between [-180 and +360])
% t:        datetime or datenum time input - vector or scalar
% var:      string of input variable e.g. 'uwnd' or 'slp'
% subdir:   subDirectory for variable e.g., 'surface' or 'surface_gauss'
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
% nr_url.m
% nr_slab.m
%
% -------------------------------------------------------------------------
% ABOUT: Dnrid Nicholson // dnicholson@whoi.edu // 14 NOV 2015
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

latrng = [min(lat) max(lat)];
% 0 - 360 range
lonrng1 = [min(lon) max(lon)];
lon2 = lon;
% -180 - 180
lon2(lon > 180) = lon(lon > 180) - 360;
lonrng2 = [floor(min(lon2)) ceil(max(lon2))];
if abs(diff(lonrng1)) <= abs(diff(lonrng2))
     % within 0 - 360 range
     lonrng = lonrng1;
 else
     % wrap around prime meridian
     lonrng = lonrng2;
end
trng = [min(dtm) max(dtm)];

[slab,latnr,lonnr,tnr] = nr_slab(latrng,lonrng,trng,var,subDir);


%% Initialize output and get nearest datapoint to each obs point
NV = nan(nobs,1);
outvar = NV;
latout = NV;
lonout = NV;
tout = datetime(NV,'ConvertFrom','datenum');

for ii = 1:nobs
    [~,ilat] = min(abs(lat(ii) - latnr));
    [~,ilon] = min(abs(lon(ii) - lonnr));
    [~,it] = min(abs(tnr-dtm(ii)));
    outvar(ii) = slab(ilat,ilon,it);
    latout(ii) = latnr(ilat);
    lonout(ii) = lonnr(ilon);
    tout(ii) = tnr(it);
end


end

