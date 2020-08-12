function [url,varn] = era_url(varName,varargin)

% era_url
% -------------------------------------------------------------------------
% constructs netCDF filename for opendap era5 server 
% ONLY HOURLY SUPPORTED SO FAR
% -------------------------------------------------------------------------
% USAGE:
% -------------------------------------------------------------------------
% [url] = 
%
% -------------------------------------------------------------------------
% INPUTS:
% -------------------------------------------------------------------------
% Required
%
% var:      string of variable name
% 
%
% -------------------------------------------------------------------------
% OUTPUTS:
% -------------------------------------------------------------------------
% url:  full opendap/thredds address of requested file
%
% -------------------------------------------------------------------------
% ABOUT:  David Nicholson // dnicholson@whoi.edu // 10 Aug 2020
% -------------------------------------------------------------------------
%% parse inputs
defaultTimeGrid = 'hourly';
validTimeGrid = {'hourly','monthly_2d','monthly_3d'};

validVars = {   '2m_temperature',...
                'Boundary_layer_height',...
                'Specific_humidity_1000mb',...
                'Surface_net_solar_radiation',...
                'Surface_pressure',...
                'Surface_solar_radiation_downwards',...
                'Surface_thermal_radiation_downwards',...
                'Surface_total_precipitation',...
                'U_wind_component_10m',...
                'V_wind_component_10m'...
                };
            


%%% parse input parameters

p = inputParser;    
addRequired(p,'var',@(x) any(validatestring(x,validVars)));  
addParameter(p,'tgrid',defaultTimeGrid,@(x) any(validatestring(x,validTimeGrid)));
    %addParameter(p,'level',defaultLevel,@(x) any(validatestring(x,expectedLevel)));


    
parse(p,varName,varargin{:});
inputs = p.Results;
tstr = inputs.tgrid;
varstr = inputs.var;

varnames = {'t2','blm','q','ssrsfc','sp','ssrd','strd','tp','u10','v10'};
longvar2var = containers.Map(validVars,varnames);
varn = longvar2var(varstr);

thredds_root = 'http://apdrc.soest.hawaii.edu:80/dods/public_data/Reanalysis_Data/ERA5/';

url = fullfile(thredds_root,tstr,varstr);
end

