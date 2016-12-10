function [ url ] = nr_url(varName,subdir,yr)
% nr_url
% -------------------------------------------------------------------------
% constructs netCDF filename for ncep reanalysis thredds server
% link - http://www.esrl.noaa.gov/psd/data/gridded/data.ncep.reanalysis.html
% -------------------------------------------------------------------------
% USAGE:
% -------------------------------------------------------------------------
% [url] = nr_url('uwnd','surface_gauss')
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
% ABOUT:  David Nicholson // dnicholson@whoi.edu // 13 NOV 2015
% -------------------------------------------------------------------------
threddsroot = 'http://www.esrl.noaa.gov/psd/thredds/dodsC/Datasets/ncep.reanalysis/';

if isnumeric(yr)
    yrStr = num2str(yr,'%.0f');
else
    yrStr = yr;
end

middle = '';
append = '.';
switch subdir
    case {'surface_gauss','other_gauss'}
        append = '.gauss.';
        switch varName
            case {'uwnd','vwnd'}
                middle = '.10m';
            case {'air','shum','tmax'}
                middle = '.2m';
            case {'cfnlf','cprat','csdlf','csusf','dlwrf','dswrf',...
                    'gflux','icec','lhtfl','nbdsf','nddsf','nlwrs',...
                    'nswrs','pevpr','prate','pres','runof','sfcr',...
                    'shtfl','skt','uflx','ugwd','ulwrf','vbdsf',...
                    'vddsf','vlwrf','vflx','vgwd','weasd'}
                middle = '.sfc';
            otherwise
                middle = '';
        end
                    
    case 'surface'
        switch varName
            case {'lftx','lftx4','pres'}
                middle = '.sfc';
            case {'air','omega','pottemp','rhum','uwnd','vwnd'}
                middle = '.sig995';
            case {'pr_wtr'}
                middle = '.eatm';
            case {'topo','hqt','land'}
                yrStr = '';
                middle = '';
        end
    % 'sfc' variables exist in both directories
    case 'spectral'
        append = '.spec.';
    case 'tropopause'
        append = '.tropp.';
    otherwise
        error(['invalid sub directory: ' subdir '. must be one of: '...
            'surface ','surface_gauss ','other_gauss ','tropopause ','pressure']);

end

        
url = fullfile(threddsroot,subdir,[varName,middle,append,yrStr,'.nc']);

end

