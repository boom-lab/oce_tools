% [Fd, Fc, Fp, Deq] = fas_S09(C,u10,S,T,slp,gas,rh)
% Function to calculate air-sea gas exchange flux using Stanley 09
% parameterization
%
% USAGE:-------------------------------------------------------------------
% [Fd, Fc, Fp, Deq] = fas_S09(C,u10,S,T,slp,gas,rh)
% [Fd, Fc, Fp, Deq] = fas_S09(0.01410,5,35,10,1,'Ar',0.9)
%   > Fd = -4.9960e-09
%   > Fc = 7.3493e-10
%   > Fp = 1.8653e-13
%   > Deq = 0.0027
%
% DESCRIPTION:-------------------------------------------------------------
% Calculate air-sea fluxes and steady-state supersaturation based on:
% Stanley, R.H., Jenkins, W.J., Lott, D.E., & Doney, S.C. (2009). Noble
% gas constraints on air-sea gas exchange and bubble fluxes. Journal of
% Geophysical Research: Oceans, 114(C11), doi: 10.1029/2009JC005396
%
% INPUTS:------------------------------------------------------------------
% C:    gas concentration (mol/m^3)
% u10:  10 m wind speed (m/s)
% S:    Sea surface salinity (PSS)
% T:    Sea surface temperature (deg C)
% slp:  sea level pressure (atm)
% gas:  two letter code for gas (He, Ne, Ar, Kr, Xe, N2, or O2)
% rh:   relative humidity as a fraction of saturation (0.5 = 50% RH).
%       rh is an optional but recommended argument. If not provided, it
%       will be automatically set to 0.8.
%
% OUTPUTS:-----------------------------------------------------------------
% Fd:   Diffusive air-sea flux                        (mol m-2 s-1)
% Fp:   Flux from partially collapsing large bubbles  (mol m-2 s-1)
% Fc:   Flux from fully collapsing small bubbles      (mol m-2 s-1)
% Deq:  Equilibrium supersaturation                   (unitless (%sat/100))
%
% REFERENCE:---------------------------------------------------------------
%
% Stanley, R.H., Jenkins, W.J., Lott, D.E., & Doney, S.C. (2009). Noble
% gas constraints on air-sea gas exchange and bubble fluxes. Journal of
% Geophysical Research: Oceans, 114(C11), doi: 10.1029/2009JC005396
%
% AUTHOR:------------------------------------------------------------------
%
% Cara Manning (cmanning@whoi.edu) Woods Hole Oceanographic Institution
% Version: 1.0 // September 2015
%
% COPYRIGHT:---------------------------------------------------------------
%
% Copyright 2015 Cara Manning 
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%    http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Fd, Fc, Fp, Deq] = fas_S09(C,u10,S,T,slp,gas,rh)
% -------------------------------------------------------------------------
% Conversion factors and constants
% -------------------------------------------------------------------------
atm2Pa = 1.01325e5; % Pascals per atm
R = 8.314;  % ideal gas constant in m3 Pa / (K mol)

% -------------------------------------------------------------------------
% Scaling factors for gas exchange coefficients
% -------------------------------------------------------------------------

Ac = 9.09E-11;
Ap = 2.29E-3;
gammaG = 0.97;
diffexp=2/3; betaexp=1;

% -------------------------------------------------------------------------
% Check for humidity
% -------------------------------------------------------------------------

% if humidity is not provided, set to 0.8 for all values
if nargin == 6
    rh =0.8.*ones(size(C));
end;

% -------------------------------------------------------------------------
% Calculate diffusive flux
% -------------------------------------------------------------------------

[D,Sc] = gasmoldiff(S,T,gas);
Geq = gasmoleq(S,T,gas);

k = gammaG*kgas(u10,Sc,'W92b'); % k_660 = 0.31 cm/hr

% Equilibrium gas conc is referenced to 1 atm total air pressure, 
% including saturated water vapor (rh=1).
% Calculate ratio (observed dry air pressure)/(reference dry air pressure).
ph2oveq = vpress(S,T);
ph2ov = rh.*ph2oveq;
slpc = (slp-ph2ov)./(1-ph2oveq);

% calculate diffusive flux with correction for local humidity
Fd = -k.*(C-Geq.*slpc);

% -------------------------------------------------------------------------
% Calculate complete trapping / air injection flux
% -------------------------------------------------------------------------

% air injection factor as a function of wind speed
% set to 0 below u10 = 2.27 m/s
wfact=(u10-2.27)^3; 
wfact(wfact<0) = 0;

% calculate dry atmospheric pressure in atm
patmdry=slp-ph2ov; % pressure of dry air in atm 

ai=gasmolfract(gas).*wfact.*patmdry*atm2Pa/(R*(273.15+T));
Fc = Ac*ai; 


% -------------------------------------------------------------------------
% Calculate partial trapping / exchange flux
% -------------------------------------------------------------------------

% calculate bubble penetration depth, Zbub, then calculate hydrostatic
% pressure in atm
Zbub = 0.15*u10 - 0.55;
Zbub(Zbub<0)=0; 
phydro=(gsw_sigma0(S,T)+1000)*9.81*Zbub/atm2Pa; 

% multiply by scaling factor Ap by beta raised to power betaexp and 
% diffusivity raised to power diffexp
apflux=ai.*Ap.*D.^diffexp.*(gasBunsen(S,T,gas).^betaexp); 
Fp=apflux.*(phydro./patmdry-C./Geq+1); 


% -------------------------------------------------------------------------
% Calculate steady-state supersaturation
% -------------------------------------------------------------------------
Deq = ((Fc+Fp)./k)./Geq;

end
