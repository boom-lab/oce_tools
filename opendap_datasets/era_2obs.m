
function [varout,latout,lonout,tout] = era_2obs(varstr,latobs,lonobs,tobs)
% ow_2obs
% -------------------------------------------------------------------------
% extracts seawinds blended winds from noaa ncdc
% 
% -------------------------------------------------------------------------
% USAGE:
% -------------------------------------------------------------------------
% 
% -------------------------------------------------------------------------
% INPUTS:
% -------------------------------------------------------------------------
% varstr:   string of variable name
% lat:      vector of observed latitudes
% lon:      vector of observed longitudes 
% t:        datenum time input - vector 
%
% 
% -------------------------------------------------------------------------
% OUTPUTS:
% -------------------------------------------------------------------------
% varout:   output for requested variable
%
%
%
% -------------------------------------------------------------------------
% ABOUT: David Nicholson // dnicholson@whoi.edu // 10 Aug 2020
% -------------------------------------------------------------------------
% reference: http://www.ncdc.noaa.gov/oa/rsad/air-sea/seawinds.html
[url,varn] = era_url(varstr);
nobs = length(tobs);
lonobs = mod(lonobs,360);

lat = ncread(url,'lat');
%lat  = -90:0.25:90;
% note: lon is 0:360
lon = ncread(url,'lon');
%lon = 0:0.25:359.99;
dntime = double(ncread(url,'time'));


trng = [min(tobs)-1  max(tobs)+1];
latrng = [min(latobs)-1 max(latobs)+1];
lonrng = [min(lonobs)-1 max(lonobs)+1];

% time range 
it = find(dntime > trng(1) & dntime < trng(2));
nt = length(it);
ila = find(lat > latrng(1) & lat < latrng(2));
nla = length(ila);
ilo = find(lon > lonrng(1) & lon < lonrng(2));
nlo = length(ilo);

% create data slab that bounds observations
% u and v components
varg = ncread(url,varn,[ilo(1),ila(1),it(1)],[nlo,nla,nt]);

latg = lat(ila);
long = lon(ilo);
tg = dntime(it);

varout = nan(nobs,1);
latout = nan(nobs,1);
lonout = nan(nobs,1);
tout = nan(nobs,1);

for ii = 1:nobs
    [~,ilat] = min(abs(latg-latobs(ii)));
    [~,ilon] = min(abs(long-lonobs(ii)));
    [~,it] = min(abs(tg-tobs(ii)));
    
    latout(ii) = latg(ilat);
    lonout(ii) = long(ilon);
    tout(ii) = tg(it);
    varout(ii) = varg(ilon,ilat,it);

end



%


