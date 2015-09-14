% beta = gas_Bunsen(S,T,gas)
% Function to calculate Bunsen coefficient
%
% USAGE:-------------------------------------------------------------------
% beta=gas_Bunsen(S,T,gas)
%
% DESCRIPTION:-------------------------------------------------------------
% Calculate the Bunsen coefficient, which is defined as the volume of pure
% gas at standard temperature and pressure (273.15 K, 1 atm) that will
% dissolve into a volume of water at equilibrium exposed to a partial
% pressure of 1 atm of the gas. The Bunsen coefficient is unitless
%
% INPUTS:------------------------------------------------------------------
% S:    Practical salinity (PSS)
% T:    Potential temperature (deg C)
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

function beta=gas_Bunsen(S,T,gas)

% calculate potential density referenced to 0 dbar
rho = sw_dens(S,T,0);
pdry = 1 - vpress(S,T); % pressure of dry air for 1 atm total pressure

% calc equilibrium conc in mol/kg
if strcmpi(gas,'He')
    Geq=gsw_Hesol_SP_pt(S,T)./1E6;
elseif strcmpi(gas,'Ne')
    Geq=gsw_Nesol_SP_pt(S,T)./1E6;
elseif strcmpi(gas,'Ar')
    Geq=gsw_Arsol_SP_pt(S,T)./1E6;
elseif strcmpi(gas,'Kr')
    Geq=gsw_Krsol_SP_pt(S,T)./1E6;
elseif strcmpi(gas,'Xe')
    Geq=hammeXesol(S,T)./1E6;
elseif strcmpi(gas,'N2')
    Geq=gsw_N2sol_SP_pt(S,T)./1E6;
elseif strcmpi(gas,'O2')
    Geq=gsw_O2sol_SP_pt(S,T)./1E6;  
else
    error('Gas name must be He, Ne, Ar, Kr, Xe, O2 or N2');
end;

% calc beta
beta = Geq.*gas_mol_vol(gas).*(rho./1000).*pdry./gas_mol_fract(gas);
end
