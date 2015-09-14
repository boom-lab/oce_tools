% =========================================================================
% X = gas_mole_fract(gas) 
% -------------------------------------------------------------------------
% mole fraction in dry atmosphere of a well mixed atmospheric gas
%
% -------------------------------------------------------------------------
% INPUTS:
% -------------------------------------------------------------------------
% gas:      name of the gas (see below)
%
% Helium:       'He'
% Neon:         'Ne'
% Argon:        'Ar'
% Krypton:      'Kr'
% Xenon:        'Xe'
% Nitrogen:     'N2'
% Oxygen:       'O2'
% Argon-36:     'Ar36'
%
% -------------------------------------------------------------------------
% OUTPUTS:
% -------------------------------------------------------------------------
% Xg        mole fraction of the gas in dry atmosphere (mixing ratio)
%
% -------------------------------------------------------------------------
% USAGE:
% -------------------------------------------------------------------------
% Xg = gas_mol_fract('Ar')
% Xg = 0.009332
%
% -------------------------------------------------------------------------
% REFERENCE:
% -------------------------------------------------------------------------
% Tables of Physical & Chemical Constants. 3.1.4. Composition of the
% Earth's Atmosphere. Kaye & Laby Online. Version 2.0 (16 October 2012)
% www.kayelaby.npl.co.uk and references therein.
%
% -------------------------------------------------------------------------
% AUTHORS:
% -------------------------------------------------------------------------
% Written by David (Roo) Nicholson 08/03/08  dnicholson@whoi.edu
% Updated by Cara Manning to change some mole fractions, September 2015
%
% -------------------------------------------------------------------------
% COPYRIGHT:
% -------------------------------------------------------------------------
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
% =========================================================================

function [Xg] = gas_mole_fract(gas)

if strcmpi(gas, 'He')
    Xg = 0.00000524;
elseif strcmpi(gas, 'Ne')
    Xg = 0.00001818;
elseif strcmpi(gas, 'Ar')
    Xg = 0.009332;
elseif strcmpi(gas, 'Kr')
    Xg = 0.00000114;
elseif strcmpi(gas, 'Xe')
    Xg = 87e-8;
elseif strcmpi(gas, 'N2')
    Xg = 0.78082;
elseif strcmpi(gas, 'Ar36')
    Xg = 0.009332.*0.003651267;
elseif strcmpi(gas, 'O2')
    Xg = 0.20945;
else
    error('Gas name must be Ne, Ar, Kr, Xe, N2, O2 or Ar36');
end