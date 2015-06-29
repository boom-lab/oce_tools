% Function to calculate air-sea bubble flux
%
% USAGE:-------------------------------------------------------------------
%  
% [Fi Fe] = Fbub_N11(8,35,20,1,'O2')
%
%  > Fi = 9.8910e-08
%  > Fe = 2.3665e-08
%
% DESCRIPTION:-------------------------------------------------------------
%
% Calculates the equilibrium concentration of gases as a function of
% temperature and salinity (equilibrium concentration is at 1 atm including
% atmospheric pressure
%
% Finj = Ainj * slp * Xg * u3
% Fex = Aex * slp * Geq * D^n * u3
%
% where u3 = (u-2.27)^3 (and zero for  u < 2.27)
%
% INPUTS:------------------------------------------------------------------
% 
% C:    gas concentration in mol m-3
% u10:  10 m wind speed (m/s)
% S:    Sea surface salinity
% T:    Sea surface temperature (deg C)
% slp:  sea level pressure (atm)
%
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
% OUTPUTS:------------------------------------------------------------------
%
% Finj and Fex,  Injection and exchange bubble flux in mol m-2 s-1
% Fas: surface air-sea flux based on Sweeney et al. 2007
% Deq: steady-state supersaturation
% REFERENCE:---------------------------------------------------------------
%
% Nicholson, D., S. Emerson, S. Khatiwala, R. C. Hamme. (2011)
%   An inverse approach to estimate bubble-mediated air-sea gas flux from 
%   inert gas measurements.  Proceedings on the 6th International Symposium
%   on Gas Transfer at Water Surfaces.  Kyoto University Press.
%
% AUTHOR:---------------------------------------------------------------
% David Nicholson dnicholson@whoi.edu
% Woods Hole Oceanographic Institution
% Version: September 2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Fas, Finj, Fex, Deq] = fas_N11(C,u10,S,T,slp,gas)


Ainj = 2.357e-9;
Aex = 1.848e-5;

u3 = (u10-2.27).^3;
u3(u3 < 0) = 0;

[D,Sc] = gasmoldiff(S,T,gas);
Geq = gasmoleq(S,T,gas);

k = kgas(u10,Sc,'Sw07');
Fas = -k.*(C-slp.*Geq);
Finj = Ainj.*slp.*gas_mole_fract(gas).*u3;
Fex = Aex.*slp.*Geq.*D.^0.5.*u3;
Deq = ((Finj+Fex)./k)./Geq;