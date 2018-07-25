function [ fname ] = oc_url(t,var,varargin)
% oc_url
% -------------------------------------------------------------------------
% construncts netCDF filename for NASA Ocean Color OpenDAP server
% link - http://oceandata.sci.gsfc.nasa.gov/opendap/
% -------------------------------------------------------------------------
% USAGE:
% -------------------------------------------------------------------------
% [fname] = oc_url(t,'par')
% 
% [fname] = oc_url(t,'par','sensor','VIIRS','trange','DAY','res','4km')
%
% -------------------------------------------------------------------------
% INPUTS:
% -------------------------------------------------------------------------
% Required
% t:        datetime or datenum time input - vector or scalar
% var:      string of input variable
% 
% Optional parameters
% NAME      DEFAULT
%  --        -----
% sensor:   'MODISA'    
% level:    'L3SMI'     
% trange:   '8D'        temporal option
% res:      '9km'       spatial resolution
% -------------------------------------------------------------------------
% OUTPUTS:
% -------------------------------------------------------------------------
% fname:  full opendap address of requested file
%
% -------------------------------------------------------------------------
% ABOUT:  David Nicholson // dnicholson@whoi.edu // 29 JUN 2015
% -------------------------------------------------------------------------

froot = 'https://oceandata.sci.gsfc.nasa.gov:443/opendap';
%% parse inputs
defaultLevel = 'L3SMI';
expectedLevel = {'L3SMI'};
defaultSensor = 'MODISA';
expectedSensor = {'MODISA','MODIST','VIIRS','SeaWiFS','Aquarius'};
defaultTrange = '8D';
expectedTrange = {'8D','R32','DAY','MO','YR'};
defaultRes = '9km';
expectedRes = {'4km','9km'};
%%% parse input parameters
persistent p
if isempty(p)
    p = inputParser;
    
    addRequired(p,'t',@(x) isnumeric(x) || isdatetime(x));
    addRequired(p,'var',@isstr);
    
    addParameter(p,'trange',defaultTrange,@(x) any(validatestring(x,expectedTrange)));
    addParameter(p,'res',defaultRes,@(x) any(validatestring(x,expectedRes)));
    addParameter(p,'sensor',defaultSensor,@(x) any(validatestring(x,expectedSensor)));
    addParameter(p,'level',defaultLevel,@(x) any(validatestring(x,expectedLevel)));
end
parse(p,t,var,varargin{:});
inputs = p.Results;

% OPENDAP root directory for sensor and level
sensor = inputs.sensor;
level = inputs.level;
res = inputs.res;
trange = inputs.trange;

sensorCode = {'A','T','V','S','Q'};
sensor2code = containers.Map(expectedSensor,sensorCode);


%% clean up t and construct full filename

% determine variable suite from variable name
% valid suites are RRS, CHL, KD490, PAR, PIC, POC, FLH, SST, SST4, and NSST
% !!! sst shows up twice !!!
switch var
    case {'chl_ocx','chlor_a'}
        suite = 'CHL';
    case {'ipar','nflh'}
        suite = 'FLH';
    case {'a_','adg_','aph_','bb_','bbp_'}
        suite = 'IOP';
    case {'Kd_490'}
        suite = 'KD490';
    case 'nsst'
        % call 'nsst' to get 'sst' var from NSST suite
        suite = 'NSST';
        var = 'sst';
    case 'par'
        suite = 'PAR';
    case 'pic'
        suite = 'PIC';
    case 'poc'
        suite = 'POC';
    case strncmpi(var,'RRS_',4)
        suite = 'RRS';
    case 'sst4'
        suite = 'SST4';
    case 'sst'
        suite = 'SST';
    otherwise
        if strncmpi(var,'Rrs_',4)
            suite = 'RRS';
        elseif ismember(var(1:3),{'a_4','a_5','a_6','adg','aph','bb_','bbp'})
            suite = 'IOP';
        else
            error('unsuported/invalid variable name');
        end
end

% append NPP prefix to VIIRS file path
if strcmpi(sensor,'VIIRS')
    suite = ['SNPP_' suite];
end

% time in datetime - dateshift ensures there are not artifacts from
% numerical rounding errors in conversion from datenum
if ~isdatetime(t)
    dtm = datetime(t, 'ConvertFrom', 'datenum');
else
    dtm = t;
end
dtm = dateshift(dtm,'start','second','nearest');

% adjust time to nearest date with available data
sCode = sensor2code(sensor);
switch trange
    case {'8D','R32'}
        % round to 8th days (1,9,17,25,....)
        t1 = dtm-rem(day(dtm,'dayofyear'),8) + 1;
        if strcmpi(trange,'8D')
            tStr = [sCode,dstr(t1),dstr(t1+7)];
        else
            tStr = [sCode,dstr(t1),dstr(t1+31)];
        end
    case 'DAY'
        t1 = dtm;
        tStr = [sCode,dstr(dtm)];
    case 'MO'
        t1 = dateshift(dtm,'start','month');
        t2 = dateshift(dtm,'end','month');
        tStr = [sCode,dstr(t1),dstr(t2)];
    case 'YR'
        t1 = dateshift(dtm,'start','year');
        t2 = dateshift(dtm,'end','year');
        tStr = [sCode,dstr(t1),dstr(t2)];
    otherwise
        error('time string is invalid');
end


% construct OPENDAP address string for first file
fname = fullfile(froot,sensor,level,num2str(year(t1)),...
    num2str(day(t1,'dayofyear'),'%03d'),...
    [tStr,'.L3m_',trange,'_',suite,'_',var,'_',res,'.nc']);
end
function [outstr] = dstr(t)
    outstr = [num2str(year(t)), num2str(day(t,'dayofyear'),'%03d')];
end




