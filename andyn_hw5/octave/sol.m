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
syms k alpha x p

K1 = sym(1)/2*(cosh(alpha*x) + cos(alpha*x));
K4 = simplify(diff(K1, x)/alpha);
K3 = simplify(diff(K4, x)/alpha);
K2 = simplify(diff(K3, x)/alpha);

alpha11 = sym(pi)/2;
alpha12 = sym(pi);
alpha21 = sym(2347)/1000;
alpha22 = sym(3927)/1000;

u1 = simplify(subs(K2,alpha,alpha11) - subs(K2,[alpha, x],[alpha11, 2]) / subs(K4,[alpha, x],[alpha11, 2]) * subs(K4,alpha,alpha11));

u2 = simplify(subs(K2,alpha,alpha12) - subs(K2,[alpha, x],[alpha12, 2]) / subs(K4,[alpha, x],[alpha12, 2]) * subs(K4,alpha,alpha12));

v1 = simplify(subs(K3,alpha,alpha21) - subs(K1,[alpha, x],[alpha21, 1]) / subs(K2,[alpha, x],[alpha21, 1]) * subs(K4,alpha,alpha21));

v2 = simplify(subs(K3,alpha,alpha22) - subs(K1,[alpha, x],[alpha22, 1]) / subs(K2,[alpha, x],[alpha22, 1]) * subs(K4,alpha,alpha22));

uMtx = [u1, u2; v1, v2];



