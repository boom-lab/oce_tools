function [conc_Kr] = Krsol(S,T)

% Krsol   Solubility of Kr in sea water
%=========================================================================
% Krsol Version 1.1 4/4/2005
%          Author: Roberta C. Hamme (Scripps Inst of Oceanography)
%
% USAGE:  concKr = Krsol(S,T)
%
% DESCRIPTION:
%    Solubility (saturation) of krypton (Kr) in sea water
%    at 1-atm pressure of air including saturated water vapor
%
% INPUT:  (if S and T are not singular they must have same dimensions)
%   S = salinity    [PSS]
%   T = temperature [degree C]
%
% OUTPUT:
%   concKr = solubility of Kr  [umol/kg] 
% 
% AUTHOR:  Roberta Hamme (rhamme@ucsd.edu)
%
% REFERENCE:
%    Ray F. Weiss and T. Kurt Kyser (1978)
%       "Solubility of Krypton in Water and Seawater"
%       Journal of Chemical Thermodynamics, 23(1), 69-72.
%
% DISCLAIMER:
%    This software is provided "as is" without warranty of any kind.  
%=========================================================================

% CALLER: general purpose
% CALLEE: none

%----------------------
% Check input parameters
%----------------------
if nargin ~=2
   error('Krsol.m: Must pass 2 parameters')
end %if

% CHECK S,T dimensions and verify consistent
[ms,ns] = size(S);
[mt,nt] = size(T);

  
% Check that T&S have the same shape or are singular
if ((ms~=mt) | (ns~=nt)) & (ms+ns>2) & (mt+nt>2)
   error('Krsol: S & T must have same dimensions or be singular')
end %if

%------
% BEGIN
%------

% convert T to scaled temperature
temp_abs = T + 273.15;

% constants from Table 2 Weiss and Kyser for mL/kg
A1_krypton = -112.6840;
A2_krypton = 153.5817;
A3_krypton = 74.4690;
A4_krypton = -10.0189;
B1_krypton = -0.011213;
B2_krypton = -0.001844;
B3_krypton = 0.0011201;

% Eqn (7) of Weiss and Kyser
conc_Kr = exp(A1_krypton + A2_krypton*100./temp_abs + A3_krypton*log(temp_abs/100) + A4_krypton*temp_abs/100 + S.*(B1_krypton + B2_krypton*temp_abs/100 + B3_krypton*(temp_abs./100).^2));

% Convert concentration from mL/kg to umol/kg
% Molar volume at STP is calculated from Dymond and Smith (1980) "The virial coefficients of pure gases and mixtures", Clarendon Press, Oxford.
conc_Kr = conc_Kr / 22.3511e-3;

return