% =========================================================================
% gas_mole_fract 
% -------------------------------------------------------------------------
% mole fraction in dry atmosphere of a well mixed atmospheric gas
% From Glueckauf 195X
%
% -------------------------------------------------------------------------
% INPUTS:
% -------------------------------------------------------------------------
% gas:      name of the gas (see below)
%
% Neon:         'Ne'
% Argon:        'Ar'
% Krypton:      'Kr'
% Xenon:        'Xe'
% Nitrogen:     'N2'
% Oxygen:       'O2'
%
% -------------------------------------------------------------------------
% OUTPUTS:
% -------------------------------------------------------------------------
% Xg        mole fraction of the gas in dry atm (mixing ratio)
%
% -------------------------------------------------------------------------
% USAGE:
% -------------------------------------------------------------------------
% X = gas_mol_fract('Ar')
% X = 0.00934
%
% written by Roo Nicholson 08/03/08
% Also see: gasmoleq.m, gasmolsol.m
% =========================================================================


function [Xg] = gas_mole_fract(gas)
if strcmpi(gas, 'He')
    Xg = 0.000524;
elseif strcmpi(gas, 'Ne')
    Xg = 0.00001818;
elseif strcmpi(gas, 'Ar')
    Xg = 0.00934;
elseif strcmpi(gas, 'Kr')
    Xg = 0.00000114;
elseif strcmpi(gas, 'Xe')
    Xg = 9e-8;%error('no data for Xe')
elseif strcmpi(gas, 'N2')
    Xg = 0.780840;
elseif strcmpi(gas, 'Ar36')
    Xg = 0.00934.*0.003651267;
elseif strcmpi(gas, 'O2')
    Xg = 0.209460;
else
    error('Gas name must be He, Ne, Ar, Kr, Xe, N2, O2 or Ar36');
end