% =========================================================================
% GASMOLEQ.M - calculates Henry's Law solubility (for a pure gas)
% in mol m-3 atm-1 
%
% This is a wrapper function. See individual solubility functions for more
% details.
%
% [sol] = gasmolsol(S,T,gas)
%
% -------------------------------------------------------------------------
% INPUTS:
% -------------------------------------------------------------------------
% S         Salinity
% T         Temperature
% gas       gas string: He, Ne, Ar, Kr, Xe, O2 or N2
%
% -------------------------------------------------------------------------
% OUTPUTS:
% -------------------------------------------------------------------------
% sol       Henry's Law solubility in mol m-3 atm-1
%
% -------------------------------------------------------------------------
% USGAGE:
% -------------------------------------------------------------------------
% [KH_O2] = gasmolsol(35,20,'O2')
% KH_O2 = 1.1034
%
% Author: David Nicholson dnicholson@whoi.edu
% Also see: gas_mol_fract.m, gasmoleq.m
%
% !!!!! needs water vapor pressure correction????
% =========================================================================

function [sol] = gasmolsol(S,T,gas)

rho = sw_dens0(S,T);
if strcmpi(gas, 'He')
    gasmolsol = Hesol(S,T)./gas_mole_fract('He');
elseif strcmpi(gas, 'Ne')
    gasmolsol = Nesol(S,T)./gas_mole_fract('Ne');
elseif strcmpi(gas, 'Ar')
    gasmolsol = Arsol(S,T)./gas_mole_fract('Ar');
elseif strcmpi(gas, 'Ar36')
    gasmolsol = Ar36sol(S,T)./gas_mole_fract('Ar36');   
elseif strcmpi(gas, 'Kr')
    gasmolsol = Krsol(S,T)./gas_mole_fract('Kr');
elseif strcmpi(gas, 'Xe')
    gasmolsol = Xesol(S,T)./gas_mole_fract('Xe');
elseif strcmpi(gas, 'N2')
    gasmolsol = N2sol(S,T)./gas_mole_fract('N2');
elseif strcmpi(gas, 'O2')
    gasmolsol = O2sol(S,T)./gas_mole_fract('O2');
elseif strcmpi(gas,'CO2')
    gasmolsol = co2_k0(S,T);
else
    error('Gas name must be He, Ne, Ar, Kr, Xe, O2 or N2');
end
if ~strcmpi(gas,'co2')
    sol = rho.*gasmolsol./1e6;
else
    sol = gasmolsol;
end