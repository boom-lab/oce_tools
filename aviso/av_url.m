function [ url ] = av_url( t,varname,varargin )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% av_url
% -------------------------------------------------------------------------
% constructs netCDF filename for hycom.org thredds server
% link - opendap.aviso.altimetry.fr
% -------------------------------------------------------------------------
% USAGE:
% -------------------------------------------------------------------------
% [url] = hy_url(t,'surf_el')
% 
% [url] = hy_url(datetime(2015,7,1),'surf_el')
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
% ABOUT:  David Nicholson // dnicholson@whoi.edu // 01 JUL 2015
% -------------------------------------------------------------------------


threddsroot = 'http://aviso-users:grid2010@opendap.aviso.altimetry.fr/thredds/dodsC/dataset';


areastr = 'global';

url = [threddsroot timestr areastr satstr varstr
http://opendap.aviso.altimetry.fr/thredds/dodsC/dataset-duacs-nrt-over30d-global-allsat-madt-h
http://opendap.aviso.altimetry.fr/thredds/dodsC/dataset-nrt-global-merged-mwind
http://opendap.aviso.altimetry.fr/thredds/dodsC/dataset-nrt-global-merged-mswh
http://opendap.aviso.altimetry.fr/thredds/dodsC/dataset-duacs-dt-global-allsat-madt-h
http://opendap.aviso.altimetry.fr/thredds/dodsC/dataset-duacs-dt-global-allsat-madt-uv
http://opendap.aviso.altimetry.fr/thredds/dodsC/dataset-duacs-dt-global-twosat-madt-h
http://opendap.aviso.oceanobs.com/thredds/dodsC/dataset-duacs-dt-global-allsat-msla-uv


config = 'GLBu0.08';

% time in datetime - dateshift ensures there are not artifacts from
% numerical rounding errors in conversion from datenum
if ~isdatetime(t)
    dtm = datetime(t, 'ConvertFrom', 'datenum');
else
    dtm = t;
end
dtm = dateshift(dtm,'start','second','nearest');





dataset-duacs-dt-global-allsat-msla-h';

end

