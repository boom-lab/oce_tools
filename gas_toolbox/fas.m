% =========================================================================
% FAS - wrapper function for calculating air-sea gas transfer using a
% specific GE parameterization
%
% [Fs, Fc, Fp, Deq] = fas(C,u10,S,T,slp,gas,param,rh)
%
% -------------------------------------------------------------------------
% USAGE:
% -------------------------------------------------------------------------
% [Fd, Fc, Fp, Deq] = fas(C,u10,S,T,slp,gas,param,rh)
% [Fd, Fc, Fp, Deq] = fas(0.01410,5,35,10,1,'Ar','N11',0.9)
%    > Fd = -4.4859e-09
%    > Fc = 4.4807e-10
%    > Fp = 2.1927e-10
%    > Deq = -0.0168
%
% -------------------------------------------------------------------------
% INPUTS:
% -------------------------------------------------------------------------
% C:        gas concentration (mol m-3)
% u10:      10 m wind speed (m/s)
% S:        Sea surface salinity (PSS)
% T:        Sea surface temperature (deg C)
% slp:      sea level pressure (atm)
% gas:      two letter code for gas (He, Ne, Ar, Kr, Xe, O2, or N2)
% sol:      choice of solubility function
% param:    abbreviation for parameterization:
%               Sw07 = Sweeney et al. 2007
%               S09 = Stanley et al. 2009
%               N11 = Nicholson et al. 2011 
%               L13 = Liang et al. 2013 
% rh:       relative humidity expressed as the fraction of saturation 
%           (0.5 = 50% RH).
%           rh is an optional but recommended argument. If not provided, it
%           will be set to 0.8 within the function.
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
% -------------------------------------------------------------------------
% OUTPUTS:
% -------------------------------------------------------------------------
% Fd        Diffusive flux                                (mol m-2 s-1)
% Fc:       Flux from fully collapsing small bubbles      (mol m-2 s-1)
% Fp:       Flux from partially collapsing large bubbles  (mol m-2 s-1)
% Deq:      Equilibrium supersaturation                   (unitless (%sat/100))
%
% -------------------------------------------------------------------------
% AUTHOR:
% -------------------------------------------------------------------------
% Author: Cara Manning cmanning@whoi.edu 
%
% COPYRIGHT:---------------------------------------------------------------
%
% Copyright 2015 David Nicholson and Cara Manning 
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
% =========================================================================

function [Fd, Fc, Fp, Deq] = fas(C,u10,S,T,slp,gas,param,varargin)

% if humidity is not provided, set to 0.8 for all values

if nargin == 8
    rh = varargin{1};
else
    rh =0.8.*ones(size(C));
end
    

switch upper(param)
    case 'S09'
        [Fd, Fc, Fp, Deq] = fas_S09(C,u10,S,T,slp,gas,rh);
    case 'N11'
        [Fd, Fc, Fp, Deq] = fas_N11(C,u10,S,T,slp,gas,rh);
    case 'SW07'
        [Fd, Fc, Fp, Deq] = fas_Sw07(C,u10,S,T,slp,gas,rh);
    case 'L13'
        [Fd, Fp, Fc, Deq] = fas_L13(C,u10,S,T,slp,gas,rh);
    otherwise
        error('only S09,N11,Sw07 and L13 are supported');
end


end