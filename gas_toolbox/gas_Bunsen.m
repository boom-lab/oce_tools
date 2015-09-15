% beta = gas_Bunsen(SP,pt,gas)
% Function to calculate Bunsen coefficient
%
% USAGE:-------------------------------------------------------------------
% beta=gas_Bunsen(SP,pt,gas)
%
% DESCRIPTION:-------------------------------------------------------------
% Calculate the Bunsen coefficient, which is defined as the volume of pure
% gas at standard temperature and pressure (273.15 K, 1 atm) that will
% dissolve into a volume of water at equilibrium exposed to a partial
% pressure of 1 atm of the gas. The Bunsen coefficient is unitless
%
% INPUTS:------------------------------------------------------------------
% SP:    Practical salinity (PSS)
% pt:    Potential temperature (deg C)
% gas:  code for gas (He, Ne, Ar, Kr, Xe, N2, or O2)
%
% OUTPUTS:-----------------------------------------------------------------
% beta: Bunsen coefficient                  (unitless)
%
% REFERENCE:---------------------------------------------------------------
%
% See references for individual gas solubility functions.
%
% AUTHOR:------------------------------------------------------------------
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

function beta=gas_Bunsen(SP,pt,gas)

% calculate potential density referenced to surface
SA = SP.*35.16504./35;
CT = gsw_CT_from_pt(SA,pt);
rho = gsw_sigma0(SA,CT)+1000;
pdry = 1 - vpress(SP,pt); % pressure of dry air for 1 atm total pressure

% equilib solubility in mol kg-1
Geq = 1e-6.*gasmoleq(SP,pt,gas);

% calc beta
beta = gas_mol_vol(gas).*(rho./1000).*Geq./(pdry.*gasmolfract(gas));
end
