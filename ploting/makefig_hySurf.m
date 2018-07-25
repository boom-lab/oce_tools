
function [f1,f2] = makefig_hySurf(latrng,lonrng,daterng,z)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

uvScaleFac = 3;
% step for quiver vectors
st = 2;


u = squeeze(mean(hy_slab(latrng,lonrng,[z z],[daterng daterng],'water_u'),uvScaleFac));
v = squeeze(mean(hy_slab(latrng,lonrng,[z z],[daterng daterng],'water_v'),uvScaleFac));

[SSS,~,~] = hy_slab(latrng,lonrng,[z z],[daterng daterng],'salinity');
[SST,lath,lonh] = hy_slab(latrng,lonrng,[z z],[daterng daterng],'water_temp');
[LA, LO] = meshgrat(lath,lonh);

figure;
f1 = worldmap(latrng,lonrng);

cmT = cmocean('thermal');
cmS = cmocean('haline');


pcolorm(lath,lonh,SST);
colorbar;
colormap(cmT);
q1 = quiverm(LA(1:st:end,1:st:end),LO(1:st:end,1:st:end),v(1:st:end,1:st:end),u(1:st:end,1:st:end),'w',3);

figure;
f2 = worldmap(latrng,lonrng);

pcolorm(lath,lonh,SSS);
colorbar;
colormap(cmS);
q2 = quiverm(LA(1:st:end,1:st:end),LO(1:st:end,1:st:end),v(1:st:end,1:st:end),u(1:st:end,1:st:end),'w',3);

end