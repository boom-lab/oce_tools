function [ slab,lat,lon,t] = av_slab(latRng,lonRng,tRng,varName,varargin)

% av_slab
% -------------------------------------------------------------------------
% accesses aviso thredds server to retrieve slab of data that can wrap 
% around 360/0 longitude edge
% -------------------------------------------------------------------------
% USAGE:
% -------------------------------------------------------------------------
% [ssh, lath, lonh] = av_slab(latrng,lonrng,NaN,[t,t],'sla');
%
% -------------------------------------------------------------------------
% INPUTS:
% -------------------------------------------------------------------------
% Required
% lonRng:   range of longitude to retrieve [W_edge E_edge]
% latRng:   range of latitude to retrieve [S_edge N_edge]
% zRng:     depth range to achieve (positive down) [shallow_edge deep_egdge]
% tRng:     datenum or datetime range to retrieve - 
% varName:  string name of variable
%
% Optional
% delayMode: option for delayed time ('dt') or near-realtime ('nrt') [default]
%
% -------------------------------------------------------------------------
% OUTPUTS:
% -------------------------------------------------------------------------
% url:  full opendap/thredds address of requested file
%
% -------------------------------------------------------------------------
% ABOUT:  David Nicholson // dnicholson@whoi.edu // 8 NOV 2015
% -------------------------------------------------------------------------
%%% parse input parameters
p = inputParser;

expectedVarName = {'sla','madt','u','v','uv','uwind','vwind','mwind','mswh'};
defaultDT = 'nrt';
expectedDT = {'dt','nrt'};

addRequired(p,'latRng',@(x) isnumeric(x) & length(x) == 2);
addRequired(p,'lonRng',@(x) isnumeric(x) & length(x) == 2);
addRequired(p,'tRng',@(x) (isnumeric(x) || isdatetime(x)) & length(x) == 2);
addRequired(p,'varName',@(x) any(validatestring(x,expectedVarName)));
addParameter(p,'delayMode',defaultDT,@(x) any(validatestring(x,expectedDT)));

parse(p,latRng,lonRng,tRng,varName,varargin{:});
inputs = p.Results;

% validated inputs
lonRng = inputs.lonRng;
latRng = inputs.latRng;
tRng = inputs.tRng;
varName = inputs.varName;
delayMode = inputs.delayMode;

if ~isdatetime(tRng)
    tRng = datetime(tRng, 'ConvertFrom', 'datenum','TimeZone','UTC');
end
tRng = dateshift(tRng,'start','day','nearest');

% if tRng(1) < datetime('now','TimeZone','UTC')
%     url1 = av_url(varn,'delayMode','dt');
% else
%     url1 = [];
% end
% 
% if tRng(2) > datetime('now','TimeZone','UTC')-calyears(1);
%     url2 = av_url(varn,'delayMode','dt');
% else
%     url2 = [];
% end
    
% read url for start and end times
url = av_url(varName,'delayMode',delayMode);

avlon = ncread(url,'lon');
avlat = ncread(url,'lat');

% get requested lat range
ilat = find(avlat >= latRng(1) & avlat <= latRng(2));
nlat = length(ilat);
lat = double(avlat(ilat));

% check if tRng is entirely within one experiment, or if it bridges two
avt = ncread(url,'time');
% aviso time is days since 01 JAN 1950
avdtm = datetime(1950,1,1+avt);
it = find(avdtm <= tRng(2) & avdtm >= tRng(1));
nt = length(it);
t = avdtm(it);

if isempty(it)
    [mint,it] = min(abs(avdtm-tRng(1)));
    if mint > 3
        error('no data found within 3 days')
    end
end

% lon is on 0 to 360 scale
lonRng = mod(lonRng,360);
avlon = mod(avlon,360);

if lonRng(1) > lonRng(2)
    ilon1 = find(avlon >= lonRng(1));
    nlon1 = length(ilon1);
    ilon2 = find(avlon <= lonRng(2));
    nlon2 = length(ilon2);
    lon = [avlon(ilon1);avlon(ilon2)];
    slab = nan(nlon1+nlon2,nlat,nt);
    slab(1:nlon1,:,:) = ncread(url,varName,[ilon1(1),ilat(1),it(1)],...
        [nlon1,nlat,nt]);
    slab(nlon1+1:end,:,:) = ncread(url,varName,[1,ilat(1),it(1)],...
        [nlon2,nlat,nt]);
else
    ilon = find(avlon >= lonRng(1) & avlon <= lonRng(2));
    lon = avlon(ilon);
    nlon = length(lon);
    slab = ncread(url,varName,[ilon(1),ilat(1),it(1)],[nlon,nlat,nt]);
end

% change to lat, lon, t
slab = double(permute(slab,[2,1,3]));
lon = double(lon);

end

