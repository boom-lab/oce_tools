% =========================================================================
% GASMOLEQ.M - calculates equilibrium solubility of a dissolved gas
% in mol m-3 (equilibrium conc. @ 1 atm incl. H2O partial P)
%
% This is a wrapper function. See individual solubility functions for more
% details.
%
% [sol] = gasmoleq(S,T,gas)
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
% sol       gas equilibrium solubility in mol m-3
%
% -------------------------------------------------------------------------
% USGAGE:
% -------------------------------------------------------------------------
% [O2eq] = gasmoleq(35,20,'O2')
% O2eq = 0.2311
%
% Author: David Nicholson dnicholson@whoi.edu
% Also see: gas_mol_fract.m, gasmolsol.m
% =========================================================================

function [sol] = gasmoleq(S,T,gas)

rho = gsw_sigma0(S,T)+1000;
if strcmpi(gas, 'He')
    gasmolsol = Hesol(S,T);
elseif strcmpi(gas, 'Ne')
    gasmolsol = Nesol(S,T);
elseif strcmpi(gas, 'Ar')
    gasmolsol = Arsol(S,T);
elseif strcmpi(gas, 'Ar36')
    gasmolsol = Ar36sol(S,T);   
elseif strcmpi(gas, 'Kr')
    gasmolsol = Krsol(S,T);
elseif strcmpi(gas, 'Xe')
    gasmolsol = Xesol(S,T);
elseif strcmpi(gas, 'N2')
    gasmolsol = N2sol(S,T);
elseif strcmpi(gas, 'O2')
    gasmolsol = O2sol(S,T);
elseif strcmpi(gas, 'O17')
    gasmolsol = O2sol(S,T);
%elseif strcmpi(gas, 'O18')
%    gasmolsol = O2sol(S,T);
%elseif strcmpi(gas, 'O36')
%    gasmolsol = O2sol(S,T);
%elseif strcmpi(gas, 'O35')
%    gasmolsol = O2sol(S,T);
else
    error('Gas name must be He, Ne, Ar, Kr, Xe, O2 or N2');
end
sol = rho.*gasmolsol./1e6;