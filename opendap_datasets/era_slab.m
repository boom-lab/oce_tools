function [ slab,lat,lon,dtmout] = era_slab(latRng,lonRng,tRng,varName)

% era_slab
% -------------------------------------------------------------------------
% accesses era opendap server maintained by u.hawaii to retrieve slab of 
% data that can span two files and/or wrap around 360/0 longitude edge
% -------------------------------------------------------------------------
% USAGE:
% -------------------------------------------------------------------------
% trng = [datenum(2018,6,1) datenum(2018,7,1)];
% [t2m,lat,lon,t] = era_slab([50 51],[200 201],trng,'2m_temperature');
%
% -------------------------------------------------------------------------
% INPUTS:
% -------------------------------------------------------------------------
% Required
% lonRng:   range of longitude to retrieve [W_edge E_edge]
% latRng:   range of latitude to retrieve [S_edge N_edge]
% tRng:     datenum or datetime range to retrieve 
% varName:  long string name of variable - see era_url
%
% -------------------------------------------------------------------------
% OUTPUTS:
% -------------------------------------------------------------------------
% slab:     hyperslab of requested data [lat x lon x t]
% latout:   corresponding lats
% lonout:   corresponding lons
% tout:     corresponding datenums
%
% -------------------------------------------------------------------------
% ABOUT:  David Nicholson // dnicholson@whoi.edu // 12 AUG 2020
% -------------------------------------------------------------------------
%%% parse input parameters
p = inputParser;

addRequired(p,'lonRng',@(x) isnumeric(x) & length(x) == 2);
addRequired(p,'latRng',@(x) isnumeric(x) & length(x) == 2);
addRequired(p,'tRng',@(x) (isnumeric(x) || isdatetime(x)) & length(x) == 2);
addRequired(p,'varName',@(x) ischar(x));


parse(p,lonRng,latRng,tRng,varName);
inputs = p.Results;

% validated inputs
lonRng = inputs.lonRng;
latRng = inputs.latRng;
tRng = inputs.tRng;
varName = inputs.varName;


if ~isdatetime(tRng)
    tRng = datetime(tRng, 'ConvertFrom', 'datenum');
end
tRng = dateshift(tRng,'start','second','nearest');

% read url for start and end times
[url,shortname] = era_url(varName);

eralon = ncread(url,'lon');
eralat = ncread(url,'lat');

% get requested lat range
ilat = find(eralat >= latRng(1) & eralat <= latRng(2));
ilat = [min(ilat)-1; ilat; max(ilat)+1]; % Add points just outside the extremes
ilat(ilat<1 | ilat>length(eralat)) = [];
nlat = length(ilat);
lat = eralat(ilat);

% lon is on 0 to 360 scale
lonRng = mod(lonRng,360);
eralon = mod(eralon,360);

if lonRng(1) > lonRng(2)
    isLonSplit = 1;
    ilon1 = find(eralon >= lonRng(1)); % Add point just outside the extreme
    ilon1 = [min(ilon1)-1; ilon1];
    nlon1 = length(ilon1);
    ilon2 = find(eralon <= lonRng(2)); % Add point just outside the extreme
    ilon2 = [ilon2; max(ilon2)+1];
    if max(ilon2) == min(ilon1)
        ilon2(end) = [];
    end
    nlon2 = length(ilon2);
    lon = [eralon(ilon1);eralon(ilon2)];
else
    isLonSplit = 0;
    ilon = find(eralon >= lonRng(1) & eralon <= lonRng(2));
    if isempty(ilon)
        [~,ilon] = min(abs(mean(lonRng)-eralon));
    end
    ilon = [min(ilon)-1; ilon; max(ilon)+1]; % Add points just outside the extremes
    ilon(ilon<1 | ilon>length(eralon)) = [];
    lon = eralon(ilon);
end
nlon = length(lon);


t = ncread(url,'time');
% note - seems to be a bug in reading the time? manually recreating the
% time vector (hourly since 00z01jan1979)
nta = length(t);
dtm = datetime(1979,1,1,0:nta-1,0,0)';
%dtm = datetime(t, 'ConvertFrom', 'datenum');
it = find(dtm > tRng(1) & dtm < tRng(2));
it = [min(it)-1; it; max(it)+1]; % Add points just outside the extremes
it(it<1 | it>length(dtm)) = [];
nt = length(it);
slab = nan(nlon,nlat,nt);
if isLonSplit
    slab(1:nlon1,:,:) = ncread(url,shortname,[ilon1(1),ilat(1),it(1)],...
        [nlon1,nlat,nt]);
    slab(nlon1+1:end,:,:) = ncread(url,shortname,[1,ilat(1),it(1)],...
        [nlon2,nlat,nt]);
else
    slab = ncread(url,shortname,[ilon(1),ilat(1),it(1)],[nlon,nlat,nt]);
    
end

dtmout = dtm(it);

% lat lon t order
slab = permute(double(slab),[2,1,3]);


