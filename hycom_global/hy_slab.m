function [ slab,lon,lat,z,t] = hy_slab(latRng,lonRng,zRng,tRng,varName)

% hy_url
% -------------------------------------------------------------------------
% accesses hycom.org thredds server to retrieve slab of data that can span
% two files and/or wrap around 360/0 longitude edge
% -------------------------------------------------------------------------
% USAGE:
% -------------------------------------------------------------------------
% [ssh, lonh, lath] = hy_slab(latrng,lonrng,NaN,[t,t],'surf_el');
%
% -------------------------------------------------------------------------
% INPUTS:
% -------------------------------------------------------------------------
% Required
% lonRng:   range of longitude to retrieve [W_edge E_edge]
% latRng:   range of latitude to retrieve [S_edge N_edge]
% zRng:     depth range to achieve (positive down) [shallow_edge deep_egdge]
% tRng:     datenum or datetime range to retrieve - can span between two
%           HYCOM experiments (e.g. 91.0 to 91.1)
% varName:  string name of variable
%
% -------------------------------------------------------------------------
% OUTPUTS:
% -------------------------------------------------------------------------
% url:  full opendap/thredds address of requested file
%
% -------------------------------------------------------------------------
% ABOUT:  David Nicholson // dnicholson@whoi.edu // 01 JUL 2015
% -------------------------------------------------------------------------
%%% parse input parameters
p = inputParser;

expectedVarName = {'surf_el','water_u','water_v','water_t','salinity'};

defaultSensor = 'MODISA';
expectedSensor = {'MODISA','MODIST','VIIRS','SeaWiFS','Aquarius'};
defaultTrange = '8D';
expectedTrange = {'8D','R32','DAY','MO','YR'};
defaultRes = '9km';
expectedRes = {'4km','9km'};

addRequired(p,'lonRng',@(x) isnumeric(x) & length(x) == 2);
addRequired(p,'latRng',@(x) isnumeric(x) & length(x) == 2);
addRequired(p,'zRng',@isnumeric);
addRequired(p,'tRng',@(x) (isnumeric(x) || isdatetime(x)) & length(x) == 2);
addRequired(p,'varName',@(x) any(validatestring(x,expectedVarName)));

parse(p,lonRng,latRng,zRng,tRng,varName);
inputs = p.Results;

% validated inputs
lonRng = inputs.lonRng;
latRng = inputs.latRng;
zRng = inputs.zRng;
tRng = inputs.tRng;
varName = inputs.varName;

isSSH = strcmpi(varName,'surf_el');

if ~isdatetime(tRng)
    tRng = datetime(tRng, 'ConvertFrom', 'datenum');
end
tRng = dateshift(tRng,'start','second','nearest');

% read url for start and end times
url1 = hy_url(tRng(1),varName);
url2 = hy_url(tRng(2),varName);

hylon = ncread(url1,'lon');
hylat = ncread(url1,'lat');


% get requested lat range
ilat = find(hylat >= latRng(1) & hylat <= latRng(2));
nlat = length(ilat);
lat = hylat(ilat);

% get requested depth range
if ~isSSH
    hyz = ncread(url1,'depth');
    iz = find(hyz >= zRng(1) & hyz <= zRng(2));
    nz = length(iz);
    z = hyz(iz);
else
    z = 0;
end

% check if tRng is entirely within one experiment, or if it bridges two
hyt1 = ncread(url1,'time');
% hycom time is hours since 01 JAN 2000
hydtm1 = datetime(2000,1,1,hyt1,0,0);
it1 = find(hydtm1 <= tRng(2) & hydtm1 >= tRng(1));
if isempty(it1)
    [mint,it1] = min(abs(hydtm1-tRng(1)));
    if mint > 3
        error('no data found within 3 days')
    end
end
nt1 = length(it1);
if ~strcmp(url1,url2)
    istSplit = 1;
    hyt2 = ncread(url2,'time');
    % hycom time is hours since 01 JAN 2000
    hydtm2 = datetime(2000,1,1,hyt2,0,0);
    it2 = find(hydtm2 <= tRng(2) & hydtm2 >= tRng(1));
    nt2 = length(it2);
    t = [hydtm1(it1); hydtm2(it2)];
    nt = nt1+nt2;
else
    url = url1;
    istSplit = 0;
    it = it1;
    nt = nt1;
    t = hydtm1(it1);
end

% convert lons to -180 to 180 range
lonRng = mod(lonRng,360);
hylon = mod(hylon,360);
if lonRng(1) > lonRng(2)
    isLonSplit = 1;
    ilon1 = find(hylon >= lonRng(1));
    nlon1 = length(ilon1);
    ilon2 = find(hylon <= lonRng(2));
    nlon2 = length(ilon2);
    lon = [hylon(ilon1);hylon(ilon2)];
else
    isLonSplit = 0;
    ilon = find(hylon >= lonRng(1) & hylon <= lonRng(2));
    lon = hylon(ilon);   
end
nlon = length(lon);

if isSSH
    slab = nan(nlon,nlat,nt);
    if isLonSplit
        % both lon and t are split
        if istSplit
            slab(1:nlon1,:,1:nt1) = ncread(url1,varName,[ilon1(1),ilat(1),it1(1)],...
                [nlon1,nlat,nt1]);
            slab(nlon1+1:end,:,nt1+1:end) = ncread(url2,varName,[1,ilat(1),1],...
                [nlon2,nlat,nt2]);
            % lon is split only
        else
            slab(1:nlon1,:,:) = ncread(url,varName,[ilon1(1),ilat(1),it(1)],...
                [nlon1,nlat,nt]);
            slab(nlon1+1:end,:,:) = ncread(url,varName,[1,ilat(1),it(1)],...
                [nlon2,nlat,nt]);
        end
    else
        % t is split only
        if istSplit
            slab(:,:,1:nt1) = ncread(url1,varName,[ilon(1),ilat(1),it1(1)],...
                [nlon,nlat,nz,nt1]);
            slab(:,:,nt1+1:end) = ncread(url2,varName,[ilon(1),ilat(1),1],...
                [nlon,nlat,nt2]);
            % neither is split - yay!
        else
            slab = ncread(url,varName,[ilon(1),ilat(1),it(1)],[nlon,nlat,nt]);
        end
    end
else
    % preallocate slab
    slab = nan(nlon,nlat,nz,nt);
    if isLonSplit
        % both lon and t are split
        if istSplit
            slab(1:nlon1,:,:,1:nt1) = ncread(url1,varName,[ilon1(1),ilat(1),iz(1),it1(1)],...
                [nlon1,nlat,nz,nt1]);
            slab(nlon1+1:end,:,:,nt1+1:end) = ncread(url2,varName,[1,ilat(1),iz(1),1],...
                [nlon2,nlat,nz,nt2]);
            % lon is split only
        else
            slab(1:nlon1,:,:,:) = ncread(url,varName,[ilon1(1),ilat(1),iz(1),it(1)],...
                [nlon1,nlat,nz,nt]);
            slab(nlon1+1:end,:,:,:) = ncread(url,varName,[1,ilat(1),iz(1),it(1)],...
                [nlon2,nlat,nz,nt]);
        end
    else
        % t is split only
        if istSplit
            slab(:,:,:,1:nt1) = ncread(url1,varName,[ilon(1),ilat(1),iz(1),it1(1)],...
                [nlon,nlat,nz,nt1]);
            slab(:,:,:,nt1+1:end) = ncread(url2,varName,[ilon(1),ilat(1),iz(1),1],...
                [nlon,nlat,nz,nt2]);
            % neither is split - yay!
        else
            slab = ncread(url,varName,[ilon(1),ilat(1),iz(1),it(1)],[nlon,nlat,nz,nt]);
        end
    end
end
    
end

