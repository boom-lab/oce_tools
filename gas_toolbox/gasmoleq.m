% =========================================================================
% [sol] = gasmoleq(SP,pt,gas)
%
% GASMOLEQ.M - calculates equilibrium solubility of a dissolved gas
% in mol/m^3 at an absolute pressure of 101325 Pa (sea pressure of 0 
% dbar) including saturated water vapor. 
%
% This is a wrapper function. See individual solubility functions for more
% details.
%
% -------------------------------------------------------------------------
% USAGE:
% -------------------------------------------------------------------------
% [O2eq]    = gasmoleq(35,20,'O2')
% O2eq      = 0.2311
%
% -------------------------------------------------------------------------
% INPUTS:
% -------------------------------------------------------------------------
% SP        Practical salinity [PSS-78]
% pt        Potential temperature [degC]
% gas       gas string: He, Ne, Ar, Kr, Xe, O2 or N2
%
% -------------------------------------------------------------------------
% OUTPUTS:
% -------------------------------------------------------------------------
% sol       gas equilibrium solubility in mol/m^3
%
% -------------------------------------------------------------------------
% REFERENCES:
% -------------------------------------------------------------------------
%  IOC, SCOR and IAPSO, 2010: The international thermodynamic equation of 
%   seawater - 2010: Calculation and use of thermodynamic properties.  
%   Intergovernmental Oceanographic Commission, Manuals and Guides No. 56,
%   UNESCO (English), 196 pp.  Available from http://www.TEOS-10.org
%
%  See also the references within each solubility function.
%
% -------------------------------------------------------------------------
% AUTHORS:
% -------------------------------------------------------------------------
% Cara Manning, cmanning@whoi.edu
% David Nicholson, dnicholson@whoi.edu
%
% -------------------------------------------------------------------------
% LICENSE:
% -------------------------------------------------------------------------
% Copyright 2015 Cara Manning and David Nicholson 
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

function [sol] = gasmoleq(SP,pt,gas)

% Calculate potential density at surface
SA = SP.*35.16504./35;
CT = gsw_CT_from_pt(SA,pt);
rho = gsw_sigma0(SA,CT)+1000;

% calculate equilibrium solubility gas concentration in micro-mol/kg
if strcmpi(gas, 'He')
    sol_umolkg = gsw_Hesol_SP_pt(SP,pt);
elseif strcmpi(gas, 'Ne')
    % note bug in gsw_Nesol... returns nmol kg-1 instead of umol kg-1
    sol_umolkg = gsw_Nesol_SP_pt(SP,pt)./1000;
elseif strcmpi(gas, 'Ar')
    sol_umolkg = gsw_Arsol_SP_pt(SP,pt);
elseif strcmpi(gas, 'Kr')
    sol_umolkg = gsw_Krsol_SP_pt(SP,pt);
elseif strcmpi(gas, 'Xe')
    sol_umolkg = Xesol(SP,pt);
elseif strcmpi(gas, 'N2')
    sol_umolkg = gsw_N2sol_SP_pt(SP,pt);
elseif strcmpi(gas, 'O2')
    sol_umolkg = gsw_O2sol_SP_pt(SP,pt);
else
    error('Gas name must be He, Ne, Ar, Kr, Xe, O2 or N2');
end

% convert from micro-mol/kg to mol/m3
sol = rho.*sol_umolkg./1e6;