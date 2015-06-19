% Function to calculate air-sea bubble flux
%
% USAGE:-------------------------------------------------------------------
% 
% [ Fs, Fp, Fc, Deq] = fas_L13(0.282,10,35,10,1,'O2')
%
% >Fs = -1.0478e-09
% >Fp = 5.7115e-08
% >Fc = 2.9978e-08
% >Deq = 0.0070
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
% S:    Sea surface salinity
% T:    Sea surface temperature (deg C)
% slp:  sea level pressure (atm)
% gas:  two letter code for gas
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
% Fs:   Surface gas flux                              (mol m-2 s-1)
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
% David Nicholson dnicholson@whoi.edu
% Woods Hole Oceanographic Institution
% Version: 1.2 // September 2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ Fs, Fp, Fc, Deq, Ks] = fas_L13(C,u10,S,T,pslp,gas )
% -------------------------------------------------------------------------
% Conversion factors
% -------------------------------------------------------------------------
m2cm = 100; % cm in a meter
h2s = 3600; % sec in hour
L2ml = 1000; % ml in liter
lpmol = 22.414; % liters of ideal gas in a mole at STP
atm2Pa = 1.01325e5; % Pascals per atm
if strcmpi(gas, 'O2')
    lpmol = 22.393;
end

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

R = 8.314;  % units: m3?Pa?K?1?mol?1

% -------------------------------------------------------------------------
% Calculate gas physical properties
% -------------------------------------------------------------------------
%
xG = gas_mole_fract(gas);
Geq = gasmoleq(S,T,gas);
%Gsol = gasmolsol(S,T,gas);  % solubility in mol m-3 atm
alc = (Geq/atm2Pa).*R.*(T+273.15);


Gsat = C./Geq;
[~, ScW] = gasmoldiff(S,T,gas);

% -------------------------------------------------------------------------
% Calculate COARE 3.0 
% -------------------------------------------------------------------------
%[ustar, rwt, rat,alpha] = cor30_ks_gas(u10,S,T,pslp,gas);
cd10 = cdlp81(u10);
ustar = u10.*sqrt(cd10);
% water side ustar
ustarw = ustar./sqrt(rhow./rhoa);
rwt = sqrt(rhow./rhoa).*(hw.*sqrt(ScW)+(log(.5./tkt)/.4));
rat = ha.*sqrt(ScA)+1./sqrt(cd10)-5+.5*log(ScA)/.4; %air side
%rw=1./(1./rwt+1.8*kbb);
% bubble transfer velocity
Kb = 1.98e6.*ustarw.^2.76.*(ScW./660).^(-2/3)./(m2cm.*h2s);
% overpressure dependence on windspeed (eq 16)
dP = 1.5244.*ustarw.^1.06;

% -------------------------------------------------------------------------
% Calculate air-sea fluxes
% -------------------------------------------------------------------------
% 
%Ks = ustar./((rwt+alc.*rat));
Ks= 1./(1./(ustar./rwt./sqrt(ScW./660)+Kb)+1./(ustar./(rat.*alc)));

Fs = Ks.*Geq.*(pslp-Gsat);
Fp = Kb.*Geq.*((1+dP).*pslp-Gsat);
Fc = xG.*5.56.*ustarw.^3.86;

% -------------------------------------------------------------------------
% Calculate steady-state supersaturation
% -------------------------------------------------------------------------
Deq = (Kb.*Geq.*dP.*pslp+Fc)./((Ks).*Geq.*pslp);


end

function [ cd ] = cdlp81( u10)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

cd = (4.9e-4 + 6.5e-5 * u10);
cd(u10 <= 11) = 0.0012;
cd(u10 >= 20) = 0.0018;

end