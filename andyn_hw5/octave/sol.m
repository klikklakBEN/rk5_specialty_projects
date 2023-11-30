clc
clearvars
close

pkg load symbolic

a  = 0.1;
b  = 0.05;
m  = 1;
M  = 0.25;
mu = 0.3;
h  = 0.001;
E  = 73e9;
D  = (E*h^3)/(12*(1-mu^2));
syms k alpha x y p

K1 = sym(1)/2*(cosh(alpha*x) + cos(alpha*x));
K4 = simplify(diff(K1, x)/alpha);
K3 = simplify(diff(K4, x)/alpha);
K2 = simplify(diff(K3, x)/alpha);

% insert found alpha_ij

alpha11 = sym(pi)/2;
alpha12 = sym(pi);
alpha21 = sym(2347)/1000;
alpha22 = sym(3927)/1000;

u1S = subs(K2,alpha,alpha11) - subs(K2,[alpha, x],[alpha11, 2]) / subs(K4,[alpha, x],[alpha11, 2]) * subs(K4,alpha,alpha11);

u2S = subs(K2,alpha,alpha12) - subs(K2,[alpha, x],[alpha12, 2]) / subs(K4,[alpha, x],[alpha12, 2]) * subs(K4,alpha,alpha12);

v1S = subs(K3,alpha,alpha21) - subs(K1,[alpha, y],[alpha21, 1]) / subs(K2,[alpha, y],[alpha21, 1]) * subs(K4,alpha,alpha21);

v2S = subs(K3,alpha,alpha22) - subs(K1,[alpha, y],[alpha22, 1]) / subs(K2,[alpha, y],[alpha22, 1]) * subs(K4,alpha,alpha22);

u1    = @(numX) double(subs(u1S,x,numX)
du1   = @(numX) double(subs(diff(u1S,x,1),x,numX)
d2u1  = @(numX) double(subs(diff(u1S,x,2),x,numX)

v1    = @(numY) double(subs(v1S,y,numY)
dv1   = @(numY) double(subs(diff(v1S,y,1),y,numY)
d2v1  = @(numY) double(subs(diff(v1S,y,2),y,numY)

u2    = @(numX) double(subs(u2S,x,numX)
du2   = @(numX) double(subs(diff(u2S,x,1),x,numX)
d2u2  = @(numX) double(subs(diff(u2S,x,2),x,numX)

v2    = @(numY) double(subs(v2S,y,numY)
dv2   = @(numY) double(subs(diff(v2S,y,1),y,numY)
d2v2  = @(numY) double(subs(diff(v2S,y,2),y,numY)



% Kinetic and potential energies

M = zeros(2,2)
K = zeros(2,2)

mFunc = 
kFunc = @(x1,x2) d2u1(x1)*d2u1(j)*vMtx(i)*vMtx(j) + d2vMtx(i)*d2vMtx(j)*uMtx(i)*uMtx(j) + mu * (d2uMtx(i)*vMtx(i)*uMtx(j)*d2vMtx(j) + d2uMtx(j)*vMtx(j)*uMtx(i)*d2vMtx(i)) + 2*(1-mu)*(duMtx(i)*duMtx(j)*dvMtx(i)*dvMtx(j))

for i=1:2
	for j=1:2
		M(i,j) = integral2(uMtx(i)*uMtx(j)*vMtx(i)*vMtx(j),0,2,0,1);
		K(i,j) = integral2(d2uMtx(i)*d2uMtx(j)*vMtx(i)*vMtx(j) + d2vMtx(i)*d2vMtx(j)*uMtx(i)*uMtx(j) + mu * (d2uMtx(i)*vMtx(i)*uMtx(j)*d2vMtx(j) + d2uMtx(j)*vMtx(j)*uMtx(i)*d2vMtx(i)) + 2*(1-mu)*(duMtx(i)*duMtx(j)*dvMtx(i)*dvMtx(j)),0,2,0,1);

	end;
end;

pMtx = K - p^2 * M
