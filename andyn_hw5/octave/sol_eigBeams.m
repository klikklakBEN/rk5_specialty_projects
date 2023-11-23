points_num = 1000;
x_points = linspace(-5,5,points_num);
expr1_sol = zeros(1,points_num);
expr2_sol = zeros(1,points_num);
for i = 1:points_num
	expr1_sol(i) = fsolve(@expr1, x_points(i));
	expr2_sol(i) = fsolve(@expr2, x_points(i));
end

figure
plot(x_points, expr1_sol)
figure
plot(x_points, expr2_sol)

