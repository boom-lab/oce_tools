function [ slab,lat,lon,dtmout] = nr_slab(latRng,lonRng,tRng,varName,subdir)

% nr_url
% -------------------------------------------------------------------------
% accesses nrcom.org thredds server to retrieve slab of data that can span
% two files and/or wrap around 360/0 longitude edge
% -------------------------------------------------------------------------
% USAGE:
% -------------------------------------------------------------------------
% [slp,latout,lonout,tout] = nr_slab(latrng,lonrng,[t1,t2],'slp');
%
% -------------------------------------------------------------------------
% INPUTS:
% -------------------------------------------------------------------------
% Required
% lonRng:   range of longitude to retrieve [W_edge E_edge]
% latRng:   range of latitude to retrieve [S_edge N_edge]
% tRng:     datenum or datetime range to retrieve - can span multiple yrs
% varName:  string name of variable
%
% -------------------------------------------------------------------------
% OUTPUTS:
% -------------------------------------------------------------------------
% slab:     hyperslab of requested data [lat x lon x t]
% lat:      corresponding lats
% lon:      corresponding lons
% t:        corresponding datenums
%
% -------------------------------------------------------------------------
% ABOUT:  David Nicholson // dnicholson@whoi.edu // 01 JUL 2015
% -------------------------------------------------------------------------
%%% parse input parameters
p = inputParser;

%expectedVarName = {'nswrs','nlwrs','shtfl','lhtfl','prate','vflx','uflx',...
%    'rhum','air','uwnd','vwnd','pottmp','omega','lftx','lftx4','pres.sfc',...
%    'topo.sfc','hqt.sfc','slp','pr_wtr'};
expectedLevel = {'surface','surface_gauss','other_gauss','pressure','spectral','tropopause'};

addRequired(p,'lonRng',@(x) isnumeric(x) & length(x) == 2);
addRequired(p,'latRng',@(x) isnumeric(x) & length(x) == 2);
addRequired(p,'tRng',@(x) (isnumeric(x) || isdatetime(x)) & length(x) == 2);
addRequired(p,'varName',@(x) ischar(x));
addRequired(p,'subDir',@(x) any(validatestring(x,expectedLevel)));

parse(p,lonRng,latRng,tRng,varName,subdir);
inputs = p.Results;

% validated inputs
lonRng = inputs.lonRng;
latRng = inputs.latRng;
tRng = inputs.tRng;
varName = inputs.varName;
subdir = inputs.subDir;


if ~isdatetime(tRng)
    tRng = datetime(tRng, 'ConvertFrom', 'datenum');
end
tRng = dateshift(tRng,'start','second','nearest');

% read url for start and end times
yrs = year(tRng(1)):year(tRng(2));
nyrs = length(yrs);
urls = cell(nyrs,1);
for ii = 1:nyrs
    urls{ii} = nr_url(varName,subdir,yrs(ii));
end
nrlon = ncread(urls{1},'lon');
nrlat = ncread(urls{1},'lat');

% get requested lat range
ilat = find(nrlat >= latRng(1) & nrlat <= latRng(2));
nlat = length(ilat);
lat = nrlat(ilat);

% lon is on 0 to 360 scale
lonRng = mod(lonRng,360);
nrlon = mod(nrlon,360);

if lonRng(1) > lonRng(2)
    isLonSplit = 1;
    ilon1 = find(nrlon >= lonRng(1));
    nlon1 = length(ilon1);
    ilon2 = find(nrlon <= lonRng(2));
    nlon2 = length(ilon2);
    lon = [nrlon(ilon1);nrlon(ilon2)];
else
    isLonSplit = 0;
    ilon = find(nrlon >= lonRng(1) & nrlon <= lonRng(2));
    lon = nrlon(ilon);   
end
nlon = length(lon);

% initialize output slab
slab = [];
dtmout = [];

% if level is included - seperate
% .e.g.  uwnd.u10m --> variable name is uwnd
varc = strsplit(varName,'.');

for ii = 1:nyrs
    t = ncread(urls{ii},'time');
    dtm = datetime(1800,1,1,t,0,0);
    it = find(dtm > tRng(1) & dtm < tRng(2));
    nt = length(it);
    yrslab = nan(nlon,nlat,nt);
    if isLonSplit
        yrslab(1:nlon1,:,:) = ncread(urls{ii},varc{1},[ilon1(1),ilat(1),it(1)],...
            [nlon1,nlat,nt]);
        yrslab(nlon1+1:end,:,:) = ncread(urls{ii},varc{1},[1,ilat(1),it(1)],...
            [nlon2,nlat,nt]);
    else
        yrslab = ncread(urls{ii},varc{1},[ilon(1),ilat(1),it(1)],[nlon,nlat,nt]);
        
    end
    slab = cat(3,slab,yrslab);
    dtmout = [dtmout;dtm(it)];
end
slab = permute(double(slab),[2,1,3]);


