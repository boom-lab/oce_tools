% Function to calculate air-sea bubble flux
%
% USAGE:-------------------------------------------------------------------
% 
% [Fd, Fp, Fc, Deq] = fas_L13(0.282,10,35,10,1,'O2')
%   >Fd = -1.0478e-09
%   >Fp = 5.7115e-08
%   >Fc = 2.9978e-08
%   >Deq = 0.0070
%
% DESCRIPTION:-------------------------------------------------------------
%
% Calculate air-sea fluxes and steady-state supersat based on:
% Liang, J.-H., C. Deutsch, J. C. McWilliams, B. Baschek, P. P. Sullivan, 
% and D. Chiba (2013), Parameterizing bubble-mediated air-sea gas exchange 
% and its effect on ocean ventilation, Global Biogeochem. Cycles, 27, 
% 894?905, doi:10.1002/gbc.20080.
%
% INPUTS:------------------------------------------------------------------
% C:    gas concentration (mol m-3)
% u10:  10 m wind speed (m/s)
% S:    Sea surface salinity (PSS)
% T:    Sea surface temperature (deg C)
% pslp: sea level pressure (atm)
% gas:  two letter code for gas (He, Ne, Ar, Kr, Xe, N2, or O2)  
% rh:   relative humidity as a fraction of saturation (0.5 = 50% RH)
%       rh is an optional but recommended argument. If not provided, it
%       will be automatically set to 0.8.
%
%       Code    Gas name        Reference
%       ----   ----------       -----------
%       He      Helium          Weiss 1971
%       Ne      Neon            Hamme and Emerson 2004
%       Ar      Argon           Hamme and Emerson 2004
%       Kr      Krypton         Weiss and Keiser 1978
%       Xe      Xenon           Wood and Caputi 1966
%       N2      Nitrogen        Hamme and Emerson 2004   
%       O2      Oxygen          Garcia and Gordon 1992  
%
% OUTPUTS:-----------------------------------------------------------------
%
% Fd:   Surface gas flux                              (mol m-2 s-1)
% Fp:   Flux from partially collapsing large bubbles  (mol m-2 s-1)
% Fc:   Flux from fully collapsing small bubbles      (mol m-2 s-1)
% Deq:  Equilibrium supersaturation                   (unitless (%sat/100))
%
% REFERENCE:---------------------------------------------------------------
%
% Liang, J.-H., C. Deutsch, J. C. McWilliams, B. Baschek, P. P. Sullivan, 
%   and D. Chiba (2013), Parameterizing bubble-mediated air-sea gas 
%   exchange and its effect on ocean ventilation, Global Biogeochem. Cycles, 
%   27, 894?905, doi:10.1002/gbc.20080.
%
% AUTHOR:---------------------------------------------------------------
% Written by David Nicholson dnicholson@whoi.edu
% Modified by Cara Manning cmanning@whoi.edu
% Woods Hole Oceanographic Institution
% Version: 2.0 // September 2015
%
% COPYRIGHT:---------------------------------------------------------------
%
% Copyright 2015 David Nicholson and Cara Manning 
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License, which 
% is available at http://www.apache.org/licenses/LICENSE-2.0
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ Fd, Fp, Fc, Deq, Ks] = fas_L13(C,u10,S,T,pslp,gas,rh)
% -------------------------------------------------------------------------
% Conversion factors
% -------------------------------------------------------------------------
m2cm = 100; % cm in a meter
h2s = 3600; % sec in hour
L2ml = 1000; % ml in liter
atm2Pa = 1.01325e5; % Pascals per atm

% -------------------------------------------------------------------------
% Calculate water vapor pressure and adjust sea level pressure
% -------------------------------------------------------------------------

% if humidity is not provided, set to 0.8 for all values
if nargin == 6
    rh =0.8.*ones(size(C));
end;

ph2oveq = vpress(S,T);
ph2ov = rh.*ph2oveq;

% slpc = (observed dry air pressure)/(reference dry air pressure)
% see Description section in header of fas_N11.m
pslpc = (pslp - ph2ov)./(1 - ph2oveq);

% -------------------------------------------------------------------------
% Parameters for COARE 3.0 calculation
% -------------------------------------------------------------------------
rhow = gsw_sigma0(S,T)+1000;
rhoa = 1.0;

lam = 13.3;
A = 1.3;
phi = 1;
tkt = 0.01;
hw=lam./A./phi;
ha=lam;

% air-side schmidt number
ScA = 0.9;

R = 8.314;  % units: m3 Pa K-1 mol-1

% -------------------------------------------------------------------------
% Calculate gas physical properties
% -------------------------------------------------------------------------
xG = gasmolfract(gas);
Geq = gasmoleq(S,T,gas);
alc = (Geq/atm2Pa).*R.*(T+273.15);

Gsat = C./Geq;
[~, ScW] = gasmoldiff(S,T,gas);

% -------------------------------------------------------------------------
% Calculate COARE 3.0 
% -------------------------------------------------------------------------

% ustar
cd10 = cdlp81(u10);
ustar = u10.*sqrt(cd10);

% water side ustar
ustarw = ustar./sqrt(rhow./rhoa);
rwt = sqrt(rhow./rhoa).*(hw.*sqrt(ScW)+(log(.5./tkt)/.4));
rat = ha.*sqrt(ScA)+1./sqrt(cd10)-5+.5*log(ScA)/.4; %air side

% bubble transfer velocity
Kb = 1.98e6.*ustarw.^2.76.*(ScW./660).^(-2/3)./(m2cm.*h2s);
% overpressure dependence on windspeed (eq 16)
dP = 1.5244.*ustarw.^1.06;

% -------------------------------------------------------------------------
% Calculate air-sea fluxes
% -------------------------------------------------------------------------
% 
%Ks= 1./(1./(ustar./rwt./sqrt(ScW./660)+Kb)+1./(ustar./(rat.*alc)));
Ks= 1./(1./(ustar./rwt+Kb)+1./(ustar./(rat.*alc)));


Fd = Ks.*Geq.*(pslpc-Gsat);
Fp = Kb.*Geq.*((1+dP).*pslpc-Gsat);
Fc = xG.*5.56.*ustarw.^3.86;

% -------------------------------------------------------------------------
% Calculate steady-state supersaturation
% -------------------------------------------------------------------------
Deq = (Kb.*Geq.*dP.*pslpc+Fc)./((Kb+Ks).*Geq.*pslpc);

end

function [ cd ] = cdlp81( u10)
% Calculates drag coefficient from u10, wind speed at 10 m height

cd = (4.9e-4 + 6.5e-5 * u10);
cd(u10 <= 11) = 0.0012;
cd(u10 >= 20) = 0.0018;

end