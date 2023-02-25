import numpy as np
import matplotlib.pyplot as plt
import scipy

# Given                    MPa - N - mm - kg
p_b = 120.0              # MPa
p_c = 40.0               # MPa
t_0 = 100.0              # deg C
t_1 = 150.0              # deg C
r_1 = 80.0               # mm
r_m = 660.0              # mm      
mu  = 0.3                # -
ro  = 8.0*np.power(10.0,-9) # tonne/mm^3
n   = 10000.0            # 1/min
w   = 2.0*np.pi*n/60.0   # rad/sec

# Thickness              # mm
def h(r):
    return 134.0 - np.heaviside(r-120.0, 1)*134.0 + np.heaviside(r-120.0, 1) * (75.0 + (134.0-75.0)/(120.0-135.0)*(r-135.0)) - np.heaviside(r-135.0, 1) * (75.0 + (134.0-75.0)/(120.0-135.0)*(r-135.0)) + np.heaviside(r-135.0, 1) * (13.0 + (75.0-13.0)/(135.0-600.0)*(r-600.0)) - np.heaviside(r-600.0, 1) * (13.0 + (75.0-13.0)/(135.0-600.0)*(r-600.0)) + np.heaviside(r-600.0, 1)*28.0


# Temperature              # deg C
def t_init(r):
    return t_1 + 450.0*np.power(r/r_m,2)

# Temperature alteration   # deg C
def t(r):
    return t_init(r) - t_0

# Elasticity modulus       # MPa
def E(r):
    return 2.1*np.power(10.0,5)*(1.1-0.1*(t(r)/t_1))

# Thermal expansion coefficient
def alpha(r):              # 1 / (deg C)
    return 0.5*np.power(10.0,-6)*(35.0+t(r)/t_0)


# Discretization
r_divide = 500
r_points = np.linspace(r_1,r_m,r_divide)
r_span = [r_1,r_m]
t_r = t(r_points)
E_r = E(r_points)
alpha_r = alpha(r_points)


# Graphical output of E and t
fig_e, ax_e = plt.subplots()
ax_e.plot(r_points,E_r)
ax_e.set(xlabel='r, mm',ylabel='E, MPa')
ax_e.grid()
plt.savefig('../output/E.svg')

fig_t, ax_t = plt.subplots()
ax_t.plot(r_points,t_r)
ax_t.set(xlabel='r, mm',ylabel='t, deg. C')
ax_t.grid()
plt.savefig('../output/t.svg')



# System of 2 ODE's 
def F(r):
    return np.array([[-(1+mu)/r , (1-mu**2)/(E(r)*h(r)*r)], [E(r)*h(r)/r, -(1-mu)/r]])

def g(r):
    return np.array([((1+mu)/r)*alpha(r)*t(r), -(E(r)*h(r)/r)*alpha(r)*t(r) - ro*h(r)*r*np.power(w,2) ])


# Initial conditions
y_10 = np.array([1.0, 0.0])
y_00 = np.array([0.0, - p_c * h(r_1)])

# Homogenous
def ode_o(r, f):
    return F(r).dot(f)

# Non-homogenous
def ode_n(r, f):
    return F(r).dot(f) + g(r)


# Integration
y_1 = scipy.integrate.solve_ivp(ode_o, r_span, y_10, max_step = 5)
y_0 = scipy.integrate.solve_ivp(ode_n, r_span, y_00, max_step = 5)



# Solving C_1, C-2 for final integration
C_2 = - p_c * h(r_1)
C_1 = (p_b * h(r_m) - y_0.y[1][len(y_0.y[1])-1])/y_1.y[1][len(y_1.y[1])-1]



# Final integration
y_init = np.array([C_1, C_2])
y_final = scipy.integrate.solve_ivp(ode_n, r_span, y_init, max_step = 5)



# Problem solution
r_steps = y_final.t
epsilon_2, T_1 = y_final.y
T_2  = mu * T_1 + E(r_steps)*h(r_steps)*(epsilon_2 - alpha(r_steps)*t(r_steps))



# Stress components (in MPa)
sigma_1  = T_1 / h(r_steps)
sigma_2  = T_2 / h(r_steps)
sigma_eq = max(np.sqrt(np.power(sigma_1, 2) + np.power(sigma_2, 2) - sigma_1 * sigma_2))

print(sigma_eq)



# Displacement
u = epsilon_2 * r_steps



# Graphical output of sigma_1
fig_s1, ax_s1 = plt.subplots()
ax_s1.stem(r_steps,sigma_1,linefmt='k-',markerfmt='k-')
ax_s1.set(xlabel='r, mm',ylabel='sigma_1, MPa',title='sigma_1')
ax_s1.grid()
plt.savefig('../output/sigma_1_w.svg')



# Graphical output of sigma_2
fig_s2, ax_s2 = plt.subplots()
ax_s2.stem(r_steps,sigma_2,linefmt='k-',markerfmt='k-')
ax_s2.set(xlabel='r, mm',ylabel='sigma_2, MPa',title='sigma_2')
ax_s2.grid()
plt.savefig('../output//sigma_2_w.svg')



# Graphical output of displacement
fig_su, ax_su = plt.subplots()
ax_su.stem(r_steps,u,linefmt='k-',markerfmt='k-')
ax_su.set(xlabel='r, mm',ylabel='u, mm',title='Displacement')
ax_su.grid()
plt.savefig('../output/u_w.svg')

