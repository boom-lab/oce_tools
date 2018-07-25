function [ url ] = av_url(varn,varargin )
% av_url
% -------------------------------------------------------------------------
% constructs netCDF filename for aviso thredds server
% link - opendap.aviso.altimetry.fr
% -------------------------------------------------------------------------
% USAGE:
% -------------------------------------------------------------------------
% [url] = av_url(t,'msla')
% 
%
% -------------------------------------------------------------------------
% INPUTS:
% -------------------------------------------------------------------------
% Required
% t:        datetime or datenum time input - vector or scalar
% var:      string of variable name
% 
%
% -------------------------------------------------------------------------
% OUTPUTS:
% -------------------------------------------------------------------------
% url:  full opendap/thredds address of requested file
%
% -------------------------------------------------------------------------
% ABOUT:  David Nicholson // dnicholson@whoi.edu // 01 SEP 2015
% -------------------------------------------------------------------------
defaultDT = 'dt';
expectedDT = {'dt','nrt'};
defaultSat = 'allsat';
expectedSat = {'allsat','twosat'};

validVar = {'msla','sla','madt','u','v','uv','uwind','vwind','mwind','mswh','fsle_max','theta_max'};


%%% parse input parameters
persistent p
if isempty(p)
    p = inputParser;
    
    addRequired(p,'varname',@(x) any(validatestring(x,validVar)));
    addParameter(p,'delayMode',defaultDT,@(x) any(validatestring(x,expectedDT)));
    addParameter(p,'sat',defaultSat,@(x) any(validatestring(x,expectedSat)));
    

end
parse(p,varn,varargin{:});
inputs = p.Results;

% OPENDAP root directory for sensor and level
varn = inputs.varname;
dt = inputs.delayMode;
sat = inputs.sat;

uname = 'aviso-users';
pswd = 'grid2010';
threddsroot = 'opendap.aviso.oceanobs.com/thredds/dodsC/dataset';

%'http://aviso-users:grid2010@opendap.aviso.oceanobs.com/thredds/dodsC/dataset-duacs-dt-global-allsat-msla-h';
areaStr = 'global';
duacsStr = 'duacs-';
switch varn
    case {'u','v','uv'}
        varstr = 'msla-uv';
     case {'uwind','vwind','mwind'}
        varstr = 'mwind';
        duacsStr = [];
        sat = 'merged';
    case 'mswh'
        varstr = 'merged-mswh';
        duacsStr = [];
    case {'msla','sla'}
        varstr = 'msla-h';
    case {'fsle_max','theta_max'}
        varstr = 'madt-fsle';
end

if strcmpi(dt,'nrt') && ismember(varn,{'sla','msla','madt'})
    dt = 'nrt-over30d';
end

url = ['http://' uname ':' pswd '@' threddsroot '-' duacsStr dt '-' areaStr '-' sat '-' varstr];

% some example valid urls
% http://opendap.aviso.altimetry.fr/thredds/dodsC/dataset-duacs-nrt-over30d-global-allsat-madt-h
% http://opendap.aviso.altimetry.fr/thredds/dodsC/dataset-nrt-global-merged-mwind
% http://opendap.aviso.altimetry.fr/thredds/dodsC/dataset-nrt-global-merged-mswh
% http://opendap.aviso.altimetry.fr/thredds/dodsC/dataset-duacs-dt-global-allsat-madt-h
% http://opendap.aviso.altimetry.fr/thredds/dodsC/dataset-duacs-dt-global-allsat-madt-uv
% http://opendap.aviso.altimetry.fr/thredds/dodsC/dataset-duacs-dt-global-twosat-madt-h
% http://opendap.aviso.oceanobs.com/thredds/dodsC/dataset-duacs-dt-global-allsat-msla-uv
% http://opendap.aviso.oceanobs.com/thredds/dodsC/dataset-duacs-dt-global-allsat-madt-fsle



end

