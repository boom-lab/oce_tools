
function [velout,uout,vout,latout,lonout,tout] = ow_2obs(latobs,lonobs,tobs)
% ow_2obs
% -------------------------------------------------------------------------
% extracts seawinds blended winds from noaa ncdc
% 
% -------------------------------------------------------------------------
% USAGE:
% -------------------------------------------------------------------------
% [velout,uout,vout,latout,lonout,tout] = ow_2obs(lat,lon,dn);
% -------------------------------------------------------------------------
% INPUTS:
% -------------------------------------------------------------------------
% lat:      vector of observed latitudes
% lon:      vector of observed longitudes 
% t:        datenum time input - vector 
%
% 
% -------------------------------------------------------------------------
% OUTPUTS:
% -------------------------------------------------------------------------
% velout:   wind velocity (m/s)
% uout:     eastward component
% vout:     northward compoent
% lonout:   vector of longitudes corresponding to matched grid cells
% latout:   vector of latitudes corresponding to matched grid cells
% tout:     vector of datenum's corresponding to matched time grid
%
%
%
% -------------------------------------------------------------------------
% ABOUT: David Nicholson // dnicholson@whoi.edu // 12 NOV 2015
% -------------------------------------------------------------------------
% reference: http://www.ncdc.noaa.gov/oa/rsad/air-sea/seawinds.html
threddsroot = 'http://www.ncdc.noaa.gov/thredds/dodsC/oceanwinds6hr';
nobs = length(latobs+lonobs+tobs);
lonobs = mod(lonobs,360);

lat = ncread(threddsroot,'lat');
%lat  = -89.75:0.25:89.75;
% note: lon is 0:360
lon = ncread(threddsroot,'lon');
%lon = 0:0.25:359.99;
time = double(ncread(threddsroot,'time'));
% time is in hours since 01 Jan, 1978
dntime = datenum(1978,1,1,time,0,0);

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
ug = ncread(threddsroot,'u',[ilo(1),ila(1),1,it(1)],[nlo,nla,1,nt]);
vg = ncread(threddsroot,'v',[ilo(1),ila(1),1,it(1)],[nlo,nla,1,nt]);
velg = sqrt(ug.^2+vg.^2);
latg = lat(ila);
long = lon(ilo);
tg = dntime(it);

latout = nan(nobs,1);
lonout = nan(nobs,1);
tout = nan(nobs,1);
velout = nan(nobs,1);
uout = nan(nobs,1);
vout = nan(nobs,1);

for ii = 1:nobs
    [~,ilat] = min(abs(latg-latobs(ii)));
    [~,ilon] = min(abs(long-lonobs(ii)));
    [~,it] = min(abs(tg-tobs(ii)));
    
    latout(ii) = latg(ilat);
    lonout(ii) = long(ilon);
    tout(ii) = tg(it);
    velout(ii) = velg(ilon,ilat,1,it);
    uout(ii) = ug(ilon,ilat,1,it);
    vout(ii) = vg(ilon,ilat,1,it);
end



%


