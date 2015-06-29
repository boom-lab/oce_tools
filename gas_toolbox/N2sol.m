function [conc_N2] = N2sol(S,T)

% N2sol   Solubility of N2 in sea water
%=========================================================================
% N2sol Version 1.2 4/4/2005
%          Author: Roberta C. Hamme (Scripps Inst of Oceanography)
%
% USAGE:  concN2 = N2sol(S,T)
%
% DESCRIPTION:
%    Solubility (saturation) of nitrogen (N2) in sea water
%    at 1-atm pressure of air including saturated water vapor
%
% INPUT:  (if S and T are not singular they must have same dimensions)
%   S = salinity    [PSS]
%   T = temperature [degree C]
%
% OUTPUT:
%   concN2 = solubility of N2  [umol/kg] 
% 
% AUTHOR:  Roberta Hamme (rhamme@ucsd.edu)
%
% REFERENCE:
%    Roberta Hamme and Steve Emerson, 2004.
%    "The solubility of neon, nitrogen and argon in distilled water and seawater."
%    Deep-Sea Research I, 51(11), p. 1517-1528.
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
   error('N2sol.m: Must pass 2 parameters')
end %if

% CHECK S,T dimensions and verify consistent
[ms,ns] = size(S);
[mt,nt] = size(T);

  
% Check that T&S have the same shape or are singular
if ((ms~=mt) | (ns~=nt)) & (ms+ns>2) & (mt+nt>2)
   error('N2sol: S & T must have same dimensions or be singular')
end %if

%------
% BEGIN
%------

% convert T to scaled temperature
temp_S = log((298.15 - T)./(273.15 + T));

% constants from Table 4 of Hamme and Emerson 2004
A0_n2 = 6.42931;
A1_n2 = 2.92704;
A2_n2 = 4.32531;
A3_n2 = 4.69149;
B0_n2 = -7.44129e-3;
B1_n2 = -8.02566e-3;
B2_n2 = -1.46775e-2;

% Eqn (1) of Hamme and Emerson 2004
conc_N2 = exp(A0_n2 + A1_n2*temp_S + A2_n2*temp_S.^2 + A3_n2*temp_S.^3 + S.*(B0_n2 + B1_n2*temp_S + B2_n2*temp_S.^2));

return
