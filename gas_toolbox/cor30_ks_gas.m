function [usr, rwo, ra, alc] = cor30_ks_gas(u10,S,T,pslp,gas)
%version with shortened iteration
%x=[1 0 30. 29.8 18.5 419 1010 15 .3 5 100];
% u=x(1);
% ts=x(2);
% t=x(3);ta=t;
% Q=x(4)/1000;
% Rl=x(5);
% zi=x(6);
% P=x(7);
% zu=x(8);
% usr=x(9);
% hsb=x(10);
% hlb=x(11);
% Aoz=x(12);
% alph=x(13);
% scw=x(14);

u = u10;            % 10m wind speed
zu = 10;            % 10m ref height
Cdn = cdlp81(u);

%usr = 0.3;            % ???
t = T;              % SST
ts = T;
ta = T;
P = pslp.*1013.25;  % convert atm --> mb
% downward longave flux W/m2
Rl = 18.5;
% %bulk water spec hum (g/kg)
Q = 419./1000;

hlb = NaN;
hsb = NaN;

%xG = gas_mole_fract(gas);
Gsol = gasmolsol(S,T,gas);
%Gsat = C/Geq;
[~, Sc_w] = gasmoldiff(S,T,gas);
%Sc_ca = 0.9;
%rho_w = sw_dens0(S,T);
%rho_a = pslp.*100./(Rspec.*(T+273.15).*(1+xH2O));


     %***********   set constants *************
     Beta=1.25;
     von=0.4;
     fdg=1.00;
     tdk=273.16;
     grav=9.82;
     %*************  air constants ************
     Rgas=287.1;
     Le=(2.501-.00237*ts)*1e6;
     cpa=1004.67;
     cpv=cpa*(1+0.84*Q);
     rhoa=P.*100./(Rgas.*(t+tdk).*(1+0.61.*Q));
     visa=1.325e-5*(1+6.542e-3*t+8.301e-6*t.^2-4.8e-9*t.^3);
     %************  cool skin constants  *******
     Al=2.1e-5*(ts+3.2).^0.79;
     be=0.026;
     cpw=4000;
     rhow=1022;
     visw=1e-6;
     tcw=0.6;
     bigc=16.*grav.*cpw.*(rhow.*visw)^3./(tcw.*tcw.*rhoa.*rhoa);
     
     usr = u10.*sqrt(rhoa.*Cdn./rhow);
     %usr = u10.*sqrt(rhoa./rhow);
     
     %**************  compute aux stuff *******
    if Rl>0
        Rnl=0.97.*(5.56e-8*(ts+tdk).^4-Rl);
    else
        Rnl=50;
    end;
     du=u;
     %***************   Begin bulk loop *******
     wt=hsb./rhoa./cpa;
     wq=hlb./rhoa./Le;
     
     tsr=-wt./usr;
     qsr=-wq./usr;
     Bf=-grav./ta.*usr.*(tsr+.61.*ta.*qsr);
     if Bf>0
     ug=Beta.*(Bf*zi).^.333;
     else
     ug=.2;
     end;
     ut=sqrt(du.*du+ug.*ug);
     qout=Rnl+hsb+hlb;
     dels=0;%ignore sw effect
     qcol=qout-dels;
     alq=Al.*qcol+be.*hlb.*cpw./Le;					% Eq. 7 Buoy flux water

     if alq>0;
     		xlamx=6./(1+(bigc.*alq./usr.^4).^.75).^.333;				% Eq 13 Saunders
     else
     		xlamx=6+zeros(size(u10));	% Eq 13 Saunders;
     end;
      tkt=xlamx.*visw./(sqrt(rhoa./rhow).*usr);			%Eq.11 Sub. thk
      dter=qcol.*tkt./tcw;%  Eq.12 Cool skin
   
     
     %****************   Webb et al. correection  ************
     wbar=1.61.*hlb./rhoa./Le+(1+1.61.*Q).*hsb./rhoa./cpa./ta;
     
     %**************   compute transfer coeffs relative to du @meas. ht **********
     Cd=(usr./du).^2;
     Cd = Cdn;
     
lam=13.3;
A=.63;
B=2.0;
% gas variables
%s=solco2(ts);
sol=Gsol;%mole/m^3/atm
alc=Gsol.*22.414./1000;%dimensionless
scwc=Sc_w;%schmidt #, water
scac=0.9;%schmidt #, air

%Woolf bubble parameterization
f=3.8e-6*u.^3.4;%whitecap fraction
fd=alc.*(1+1./(14.*alc./scwc.^.5).^(1/1.2)).^1.2;%Woolf equation
kbb=B.*2450*f./fd/3600/100;%m/s units

%Fairall et al. 1999 parameterization
ha=lam;%neglect air side sublayer buoyancy effects
hw=lam./A./6.*xlamx;%includes water side buoyancy effect
rwo=sqrt(rhow./rhoa).*(hw.*sqrt(scwc)+(log(.5./tkt)/.4));%water side
ra=ha*sqrt(scac)+1./sqrt(Cd)-5+.5*log(scac)/.4; %air side
%vtc=usr/(vs1+alc*vs2);%non-bubble xfer velocity
%vtcT=vtc+kbb;%

%Fairall et al. 1999 parameterization

usw=usr./sqrt(rhow./rhoa)*6./xlamx;
rw=1./(1./rwo+1.8*kbb);
vtc=usr./(rw+ra.*alc);%bubble xfer velocity
vtco=usr./(rwo+ra.*alc);%non-bubble xfer velocity
vtc2=vtco+kbb;

y=[rwo ra rw vtco vtc 6./xlamx sol alc scwc vtc2];
%   1  2  3   4    5   6       7   8     9   0   1    2    3   4   5      6  7  8   9   10      11      12     13     14
