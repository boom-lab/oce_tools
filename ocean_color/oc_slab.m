function [slab, lonout,latout,t] = oc_slab( latRng,lonRng,t,varName,varargin )
% oc_slab
% -------------------------------------------------------------------------
% extracts a hyperslab of ocean color data from NASA ocean color opendap
% L3smi product.  if multiple time points are given, data is catted in t
% dimension.  longitude can wrap across -180/180.
% link - http://oceandata.sci.gsfc.nasa.gov/opendap/
% -------------------------------------------------------------------------
% USAGE:
% -------------------------------------------------------------------------
% latr = [20 40];
% lonr = [170 220];
% t = datetime(2015,5,30);
% [PAR] = oc_slab(latr,lonr,lt,'par');
% [PAR,lonout,latout] = oc_slab(latr,lonr,t,'par','sensor','VIIRS');
% -------------------------------------------------------------------------
% INPUTS:
% -------------------------------------------------------------------------
% lat:      vector of observed latitudes
% lon:      vector of observed longitudes [westedge --> eastedge] 
% t:        datetime or datenum time input - vector or scalar
% var:      string of input variable
% varargin: optional variables passed through to ocFileString.m
% 
% -------------------------------------------------------------------------
% OUTPUTS:
% -------------------------------------------------------------------------
% slab:     requested data: dims = [lon, lat, t]
% lonout:   vector of longitudes corresponding to output slab
% latout:   vector of latitudes corresponding to output slab
%
% -------------------------------------------------------------------------
% ALSO SEE: 
% -------------------------------------------------------------------------
% oc_url.m
%
% -------------------------------------------------------------------------
% ABOUT: David Nicholson // dnicholson@whoi.edu // 29 JUN 2015
% -------------------------------------------------------------------------
nt = length(t);
% convert lons to -180 to 180 range
lonRng = mod(lonRng,360);
lonRng(lonRng > 180) = lonRng(lonRng > 180) - 360;
if lonRng(1) > lonRng(2)
    isSplit = 1;
    lonRng1 = [lonRng(1) 180];
    lonRng2 = [-180 lonRng(2)];
else
    isSplit = 0;
end

[url] = oc_url(t(1),varName,varargin{:});
lat = ncread(url,'lat');
lon = ncread(url,'lon');

% patch to differentiate NSST_sst variable from SST_sst variable
if strcmp(varName,'nsst')
    varName = 'sst';
end

ilat = find(lat >= latRng(1) & lat <= latRng(2));
latout = lat(ilat);
nlat = length(ilat);
if isSplit
    ilon1 = find(lon >= lonRng1(1) & lon <= lonRng1(2));
    nlon1 = length(ilon1);
    ilon2 = find(lon >= lonRng2(1) & lon <= lonRng2(2));
    nlon2 = length(ilon2);
    lonout = lon([ilon1;ilon2]);   
else
    ilon = find(lon >= lonRng(1) & lon <= lonRng(2));
    lonout = lon(ilon);
end
nlon = length(lonout);

slab = nan(nlon,nlat,nt);

for ii = 1:length(t)
    [url] = oc_url(t(ii),varName,varargin{:});
    if isSplit
        slab(1:nlon1,:,ii) = ncread(url,varName,[ilon1(1),ilat(1)],...
            [nlon1,nlat]);
        slab(nlon1+1:end,:,ii) = ncread(url,varName,[1,ilat(1)],...
            [nlon2,nlat]);
    else
        slab(:,:,ii) = ncread(url,varName,[ilon(1),ilat(1)],...
            [nlon,nlat]);
    end
end
        
   
    
    
end

