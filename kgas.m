% =========================================================================
% KGAS - gas transfer coefficient for a range of windspeed based
% parameterizations
%
% [kv] = kgas(u10,Sc,param)
%
% -------------------------------------------------------------------------
% INPUTS:
% -------------------------------------------------------------------------
% u10       10-m windspeed (m/s)
% Sc        Schmidt number 
% param     abbreviation for parameterization:
%           W92a = Wanninkof 1992 - averaged winds
%           W92b = Wanninkof 1992 - instantaneous or steady winds
%           Sw07 = Sweeney et al. 2007
%           Ho06 = Ho et al. 2006
%           Ng00 = Nightingale 2000
%           LM86 = Liss and Merlivat 1986
%
% -------------------------------------------------------------------------
% OUTPUTS:
% -------------------------------------------------------------------------
% kv       Gas transfer velocity in m s-1
%
% -------------------------------------------------------------------------
% USGAGE:
% -------------------------------------------------------------------------
% k = kgas(10,1000,'W92b')
% k = 6.9957e-05
%
% Author: David Nicholson dnicholson@whoi.edu
% Also see: schmidt.m
% =========================================================================

function [kv] = kgas(u10,Sc,param)

quadratics = {'W92a','W92b','Sw07','Ho06'};
% should be case insensitive
if ismember(upper(param),upper(quadratics))
    if strcmpi(param,'W92a')
        A = 0.39;
    elseif strcmpi(param,'W92b')
        A = 0.31;
    elseif strcmpi(param,'Sw07')
        A = 0.27;
    elseif strcmpi(param,'Ho06')
        A = 0.266;
    else
        error('parameterization not found');
    end
    k_cm = A*u10.^2.*(Sc./660).^-0.5;
    kv = k_cm./(100*60*60);
elseif strcmpi(param,'Ng00')
    k600 = 0.222.*u10.^2 + 0.333.*u10;
    k_cm = k600.*(Sc./600).^-0.5;
    % cm/h to m/s
    kv = k_cm./(100*60*60);
elseif strcmpi(param,'LM86')
    k600 = zeros(1,length(u10));   
    
    l = find(u10 <= 3.6);
    k600(l) = 0.17.*u10(l);
   
    m = find(u10 > 3.6 & u10 <= 13);
    k600(m) = 2.85.*u10(m)-9.65;
    
    h = find(u10 > 13);
    k600(h) = 5.9.*u10(h)-49.3;
    
    k_cm = k600.*(Sc./600).^-0.5;
    k_cm(l) = k600(l).*(Sc./600).^(-2/3);
    kv = k_cm./(100*60*60);
end