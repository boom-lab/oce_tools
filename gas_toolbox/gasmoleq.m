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
% SP        Practical Salinity
% pt        Potential temperature
% gas       gas string: He, Ne, Ar, Kr, Xe, O2, N2 or N2O
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
% Also see: gasmolfract.m, gasmolsol.m
% =========================================================================

function [sol] = gasmoleq(SP,pt,gas)

SA = SP.*35.16504./35;
CT = gsw_CT_from_pt(SA,pt);
rho = gsw_sigma0(SA,CT)+1000;
if strcmpi(gas, 'He')
    gasmolsol = gsw_Hesol_SP_pt(SP,pt);
elseif strcmpi(gas, 'Ne')
    gasmolsol = gsw_Nesol_SP_pt(SP,pt);
elseif strcmpi(gas, 'Ar')
    gasmolsol = gsw_Arsol_SP_pt(SP,pt);
elseif strcmpi(gas, 'Ar36')
    gasmolsol = Ar36sol(SP,pt);   
elseif strcmpi(gas, 'Kr')
    gasmolsol = gsw_Krsol_SP_pt(SP,pt);
elseif strcmpi(gas, 'Xe')
    gasmolsol = Xesol(SP,pt);
elseif strcmpi(gas, 'N2')
    gasmolsol = gsw_N2sol_SP_pt(SP,pt);
elseif strcmpi(gas, 'O2')
    gasmolsol = gsw_O2sol_SP_pt(SP,pt);
elseif strcmpi(gas, 'N2O')
    gasmolsol = gsw_N2Osol_SP_pt(SP,pt);
else
    error('Gas name must be He, Ne, Ar, Kr, Xe, O2, N2O or N2');
end
sol = rho.*gasmolsol./1e6;