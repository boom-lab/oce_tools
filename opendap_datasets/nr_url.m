function [ url ] = nr_url(varName,yr)
% nr_url
% -------------------------------------------------------------------------
% constructs netCDF filename for ncep reanalysis thredds server
% link - http://www.esrl.noaa.gov/psd/data/gridded/data.ncep.reanalysis.html
% -------------------------------------------------------------------------
% USAGE:
% -------------------------------------------------------------------------
% [url] = nr_url('uwnd.10m')
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

switch varName
    case {'uwnd.10m','vwnd.10m'}
        fileDir = 'surface_gauss';
        lev = '.gauss.';
    case {'nswrs','nlwrs','shtfl','lhtfl','prate','vflx','uflx'}
        fileDir = 'surface_gauss';
        lev = '.sfc.gauss.';
    case {'rhum.sig995','air.sig995','uwnd.sig995','vwnd.sig995',...
            'pottmp.sig995','omega.sig995.','lftx.sfc','lftx4.sfc',...
            'pres.sfc','topo.sfc','hqt.sfc','slp','pr_wtr.eatm'}
        fileDir = 'surface';
        lev = '.';
    case {'varName','topo','hqt','land'}
        fileDir = 'surface';
        yrStr = '';
    otherwise
        error(['invalid variable: ' varName '. must be one of: uwnd.10m,'...
            'vwnd.10m,nswrs,nlwrs,shtfl,lhtfl,prate,vflx,uflx,rhum.sig995'...
            'air.sig995,uwnd.sig995,vwnd.sig995,pottmp.sig995,omega.sig995'...
            'lftx.sfc,lftx4.sfc,pres.sfc,topo.sfc,hqt.sfc,slp,pr_wtr.eatm'...
            'topo,hqt or land']);

end
        
url = fullfile(threddsroot,fileDir,[varName,lev,yrStr,'.nc']);

end

