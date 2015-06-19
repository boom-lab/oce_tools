% Function returns the equilibrium 36Ar concentration (umol/kg)
% based on two experimental measurements of equilibrium del40/36
% at two temperatures.

% CHECK THIS FUNCTION

function [g] = Ar36sol(S,T)

% alpha experimentally determined
t_alpha = [2 25];
alpha = [1.00121 1.00105];

alpha_fit = polyval(polyfit(t_alpha,alpha,1),T);

X36 = gas_mole_fract('Ar36');
XAr = gas_mole_fract('Ar');
X40 = 0.996349;
g = Arsol(S,T)./((alpha_fit.*(XAr.*X40)./X36)+1); 
 