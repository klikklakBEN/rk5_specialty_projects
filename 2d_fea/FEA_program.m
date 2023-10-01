clc;
clearvars;
close all;


%% Ввод данных

% выбор типа КЭ
% - 1 - КЭ на раст./сж.
% - 2 - КЭ на изгиб
%
% КЭ на изгиб должен учитывать растяжение/сжатие, иначе ошибка
beam_style = input('Bыбор типа КЭ:\n 1 - КЭ на раст./сж.,\n 2 - КЭ на изгиб.\n');

% инициализация узлов и КЭ
input_data = readmatrix("SMM_DZ1_input.xlsx","Range","A3");
temp_array = zeros(height(input_data),2);

% координаты узлов, мм
i = 1;
while (i<=height(input_data))&&(~isnan(input_data(i,1)))
    temp_array(i,1:2) = input_data(i,1:2);
    i = i + 1;
end
i = i - 1;

% количество узлов
node_amount = i;
node_x = zeros(node_amount,1);
node_y = zeros(node_amount,1);

for i = 1:node_amount
    node_x(i,1) = temp_array(i,1);
    node_y(i,1) = temp_array(i,2);
end


% нумерация узлов
node_index = zeros(node_amount, 1);

for i = 1:node_amount
    node_index(i,1) = i;
end

% нумерация узлов КЭ

i = 1;
while (i<=height(input_data))&&(~isnan(input_data(i,3)))
    temp_array(i,1:2) = input_data(i,3:4);
    i = i + 1;
end

i = i - 1;

% количество КЭ
beam_amount = i;

beam_node_index = zeros(beam_amount,2);
for i=1:beam_amount
    beam_node_index(i,1) = temp_array(i,1);
    beam_node_index(i,2) = temp_array(i,2);
end

% нумерация КЭ
beam_index = zeros(beam_amount, 1);

for i = 1:beam_amount
    beam_index(i,1) = i;
end

% координаты узлов КЭ
beam_x1 = zeros(beam_amount, 1);
beam_y1 = zeros(beam_amount, 1);
beam_x2 = zeros(beam_amount, 1);
beam_y2 = zeros(beam_amount, 1);

for i = 1:beam_amount

    beam_x1(i,1) = node_x(beam_node_index(i,1), 1);
    beam_y1(i,1) = node_y(beam_node_index(i,1), 1);
    beam_x2(i,1) = node_x(beam_node_index(i,2), 1);
    beam_y2(i,1) = node_y(beam_node_index(i,2), 1);

end

%% Исходные характеристики конструктивных элементов

% необходимо работать в размерах [Н - мм - кг - МПа]
% для каждого элемента пусть будут свои размеры

% конструкция имеет 8 пролетов, т.о. ее длина
% w = 8 * 5 m = 40 m

beam_diameter  = zeros(beam_amount,1);
beam_thickness = zeros(beam_amount,1);

% диаметр и толщина сечений каждого КЭ, мм
for i = 1:beam_amount
    beam_diameter(i)  = input_data(i,14);
    beam_thickness(i) = input_data(i,15);
end

A = zeros(beam_amount,1);
J = zeros(beam_amount,1);
W = zeros(beam_amount,1);


% площадь сечения, мм в 2
for i = 1:beam_amount
    A(i) = (beam_diameter(i)^2 - (beam_diameter(i) - 2 * beam_thickness(i))^2) /4 * pi;
end
% момент инерции, мм в 4
for i = 1:beam_amount
    J(i) = (beam_diameter(i)^4 - (beam_diameter(i) - 2 * beam_thickness(i))^4) /64 * pi;
end
% момент сопротивления изгибу, мм в 3
for i = 1:beam_amount
    W(i) = J(i) * 2 / beam_diameter(i);
end
% модуль упругости 1 рода, МПа
%E = 2.1 * 10^5;
E = 1;
% 
% % объемная плотность стали 10 при 20 градусах Цельсия, кг/мм^3
% beam_density = 7850 * 10^(-9);

% предел пропорциональности sigma_0.2, МПа
steel_elasticity_limit = 260;


%% Характеристики КЭ:


% длины и углы поворотов элементов
beam_length_x = beam_x2 - beam_x1;
beam_length_y = beam_y2 - beam_y1;

beam_length   = sqrt(beam_length_x.^2+beam_length_y.^2);

beam_sin = beam_length_y ./ beam_length ;
beam_cos = beam_length_x ./ beam_length ;

% гибкость КЭ в квадрате
beam_slenderness_squared(:) = beam_length(:).^2 / J(:) * A(:);


%% Матрица жесткости элемента


% задание МЖ КЭ на рсж 6x6
if beam_style==1
    
    beam_stiffness_matrix = zeros(6, 6, beam_amount);

    for i = 1 : beam_amount
        beam_stiffness_matrix(:,:,i) = (E.*A(i) ./ beam_length(i)) .* [1, 0,0, - 1,0,0;
            0, 0, 0, 0, 0, 0;
            0, 0, 0, 0, 0, 0;
            - 1, 0,0, 1,0,0;
            0, 0, 0, 0, 0, 0;
            0, 0, 0, 0, 0, 0];
    end
else

    % задание обобщенной МЖ 6х6
    beam_stiffness_matrix = zeros(6, 6, beam_amount);

    for i = 1 : beam_amount
        beam_stiffness_matrix(:,:,i) = (E.*J(i) ./ (beam_length(i)).^3) .* [beam_slenderness_squared(i), 0,0, - beam_slenderness_squared(i),0,0;
            0, 12, 6 .* beam_length(i), 0, -12, 6 .* beam_length(i);
            0, 6 .* beam_length(i) , 4 .* (beam_length(i).^2), 0, -6 .* beam_length(i) , 2 .* (beam_length(i).^2);
            - beam_slenderness_squared(i), 0,0, beam_slenderness_squared(i),0,0;
            0, -12, - 6 .* beam_length(i), 0, 12, - 6 .* beam_length(i);
            0, 6 .* beam_length(i) , 2 .* (beam_length(i).^2), 0, - 6 .* beam_length(i) , 4 .* (beam_length(i).^2)];
    end
end

%% Перевод МЖ из ЛСК в ГСК

% матрица направлений стержня с обобщенной МЖ
transform_matrix = zeros(3, 3, beam_amount);

for i = 1 : beam_amount
    
    transform_matrix(:,:,i) = [ beam_cos(i), beam_sin(i), 0;
                                    - beam_sin(i), beam_cos(i), 0;
                                    0,0,1];

end


% матрица перехода в ГСК из ЛСК

beam_transform_matrix = zeros(6, 6,beam_amount);

for k = 1 : beam_amount
    
    beam_transform_matrix(1:3,1:3,k) = transform_matrix(:,:,k);

    beam_transform_matrix(4:6,4:6,k) = transform_matrix(:,:,k);

end

beam_global_stiffness_matrix = zeros(6,6,beam_amount);

for i = 1 : beam_amount
        
    beam_global_stiffness_matrix(:,:,i) = beam_transform_matrix(:,:,i).' *  beam_stiffness_matrix(:,:,i) * beam_transform_matrix(:,:,i);

end


%% Ансамблирование глобальной матрицы жесткости

stiffness_matrix = zeros(3*node_amount,3*node_amount);

for i = 1 : beam_amount

    first_node = beam_node_index(i,1);
    second_node = beam_node_index(i,2);
   
    for j = 1 : 3
        
        for k = 1 : 3

            stiffness_matrix(3*(first_node - 1)  + j,3*(first_node - 1) + k) = stiffness_matrix(3*(first_node - 1) + j,3*(first_node - 1) + k) + beam_global_stiffness_matrix(j,k,i);
            stiffness_matrix(3*(second_node - 1) + j,3*(second_node - 1) + k) = stiffness_matrix(3*(first_node - 1) + j,3*(second_node - 1) + k) + beam_global_stiffness_matrix(3 + j,3 + k,i);
            stiffness_matrix(3*(first_node - 1)  + j,3*(second_node - 1) + k) = stiffness_matrix(3*(first_node - 1) + j,3*(second_node - 1) + k) + beam_global_stiffness_matrix(j,3 + k,i); 
            
            stiffness_matrix(3*(second_node - 1) + k,3*(first_node - 1) + j) = stiffness_matrix(3*(first_node - 1) + j,3*(second_node - 1) + k);

        end

    end

end
            

%% Задание граничных условий и нагрузок

% 1 кгс/м2 = 9.80665 * 10 в (-6) МПа

node_load_array  = zeros(node_amount,3);
beam_load_array  = zeros(node_amount,3);

i = 1;
while (i<=height(input_data))&&(~isnan(input_data(i,5)))
    node_load_array(i,1:3) = input_data(i,5:7);
    i = i + 1;
end

i = 1;
while (i<=height(input_data))&&(~isnan(input_data(i,8)))
    beam_load_array(i,1:3) = input_data(i,8:10);
    i = i + 1;
end

boundary_conditions = input_data(:,11:13);

%% Приведение нагрузок к узлаm КЭ

% нагрузка в узле в ГСК
    node_load = zeros(3*node_amount,1);

    % задание сил в ЛСК

    % сосредоточенных силовых факторов проекции на оси х,у,z
    for i = 1 : node_amount
        node_load(3*(i - 1) + 1) = node_load_array(i,1);
        node_load(3*(i - 1) + 2) = node_load_array(i,2);
        node_load(3*(i - 1) + 3) = node_load_array(i,3);
    end


% нагрузка от снегового покрова
is_snow_load = input_data(1,16);

for i = 1 : beam_amount

    first_node = beam_node_index(i,1);
    second_node = beam_node_index(i,2);

    % коэффициент снегового покрова
    if is_snow_load
    
        if abs(beam_sin(i)) < 0.5

            snow_load_coefficient = 1;

        else

            if abs(beam_sin(i)) > sqrt(3) / 2

                snow_load_coefficient = 0;

            else

                snow_load_coefficient = 1 - (2 * abs(beam_sin(i)) - 1) / (sqrt(3) - 1);

            end

        end
    else
        snow_load_coefficient = 1;
    end

    % разделение распределенной нагрузки по узлам КЭ
    % сосредоточенные силы на узлах ql/2
    node_load(3*(first_node - 1) + 1)  = node_load(3*(first_node - 1) + 1)  + 1/2    * beam_load_array(i, 1) * beam_length(i)    * snow_load_coefficient;
    node_load(3*(first_node - 1) + 2)  = node_load(3*(first_node - 1) + 2)  + 1/2    * beam_load_array(i, 2) * beam_length(i)    * snow_load_coefficient;
    node_load(3*(second_node - 1) + 1) = node_load(3*(second_node - 1) + 1) + 1/2    * beam_load_array(i, 1) * beam_length(i)    * snow_load_coefficient;
    node_load(3*(second_node - 1) + 2) = node_load(3*(second_node - 1) + 2) + 1/2    * beam_load_array(i, 2) * beam_length(i)    * snow_load_coefficient;
    
    % сосредоточенные моменты на узлах ql^2/12    
    node_load(3*(first_node - 1) + 3)  = node_load(3*(first_node - 1) + 3)   - 1/12  * beam_load_array(i, 1) * beam_length(i)^2  * snow_load_coefficient * beam_sin(i);
    node_load(3*(second_node - 1) + 3) = node_load(3*(second_node - 1) + 3)  + 1/12  * beam_load_array(i, 1) * beam_length(i)^2  * snow_load_coefficient * beam_sin(i);
    node_load(3*(first_node - 1) + 3)  = node_load(3*(first_node - 1) + 3)   + 1/12  * beam_load_array(i, 2) * beam_length(i)^2  * beam_cos(i);
    node_load(3*(second_node - 1) + 3) = node_load(3*(second_node - 1) + 3)  - 1/12  * beam_load_array(i, 2) * beam_length(i)^2  * beam_cos(i);
end

% 
% % учет веса КЭ - распределенная сила тяжести q_m = A * g вниз оси ОY
% % F_m = mg = pVg = A*l*p*g
% % q_m = A*p*g
% % Н/мм

%% Учёт граничных условий

counter = 1;

% в случае фермы учтём отсутствия поперечных перемещений
% сечений в узлах КЭ и поворотов.
% метод Пейна-Айронса (1963)

max_SM_component = max(max(stiffness_matrix));
if beam_style == 1
    boundary_conditions(:,3) = 0;
end

for i = 1 : node_amount
    
    for k = 1 : 3

        if isnan(boundary_conditions(i,k))

            continue;

        else

            stiffness_matrix(3*(i - 1) + k, 3*(i - 1) + k) = max_SM_component * 10^3;
            node_load(3*(i - 1) + k) = stiffness_matrix(3*(i - 1) + k, 3*(i - 1) + k) * boundary_conditions(i,k);

        end

    end

end


%% Решение СЛАУ

% [K]{w} = {f} - {r}
% {w} = 

%displacement = transpose(f_m_Gaussa(stiffness_matrix,node_load));
displacement = stiffness_matrix \ node_load;

%%  Изображение перемещений

figure
hold on;
xlim([min(node_x)-1, max(node_x)+1]);
ylim([min(node_y)-1, max(node_y)]+1);

plot(node_x,node_y,'b.');

for i = 1 : beam_amount

    plot(node_x(beam_node_index(i,:)), node_y(beam_node_index(i,:)), 'b--');

end


% подпись номера узла рядом
for k=1:node_amount
text(node_x(k)*(0.98), ...
    node_y(k)*(0.98), ...
    num2str(k), ...
    'FontSize', ...
    8)
end

for i = 1 : node_amount

    node_x(i) = node_x(i) + displacement(3 * (i-1) + 1);
    node_y(i) = node_y(i) + displacement(3 * (i-1) + 2);

end


plot(node_x,node_y,'r.');


for i = 1 : beam_amount

    plot(node_x(beam_node_index(i,:)) , node_y(beam_node_index(i,:)) , 'r');

end

% подпись номера узла рядом
for k=1:node_amount
text(node_x(k)*(1.02), ...
    node_y(k)*(1.02), ...
    num2str(k), ...
    'FontSize', ...
    8)
end


legend('initial nodes', 'initial construction');

hold off;

%% Расчёт напряжений

% вычисление силовых факторов, используя матрицы в ГСК,
% даeт компоненты в ГСК: Nx, Qy, Mz

% в ЛСК:

beam_force_component = zeros(6,1,beam_amount);

beam_node_displacement = zeros(6,1,i);

% расчет силовых факторов в сечении
for i = 1 : beam_amount

    for k = 1 : 3

        beam_node_displacement(k,1,i) = displacement(3*(beam_node_index(i,1)-1) + k);

    end
    
    for k = 4 : 6

        beam_node_displacement(k,1,i) = displacement(3*(beam_node_index(i,2)-1) + k - 3);

    end

    % возврат перемещений в ЛСК
    beam_node_displacement(:,:,i) = transpose(beam_transform_matrix(:,:,i)) * beam_node_displacement(:,:,i);

    beam_force_component(:,:,i) = beam_stiffness_matrix(:,:,i) * beam_node_displacement(:,:,i);

end



% перевод сил в напряжения s
beam_stress_component = zeros(6,1,beam_amount);

for i=1:beam_amount
    
    beam_stress_component(1,1,i) = beam_force_component(1,1,i) / A(i);
    beam_stress_component(4,1,i) = beam_force_component(4,1,i) / A(i);
    
    beam_stress_component(2,1,i) = beam_force_component(2,1,i) / A(i);
    beam_stress_component(5,1,i) = beam_force_component(5,1,i) / A(i);

    beam_stress_component(3,1,i) = beam_force_component(3,1,i) / W(i);
    beam_stress_component(6,1,i) = beam_force_component(6,1,i) / W(i);
end

% в зависимости от НС КЭ расчеты на прочность должны быть проведены
% по-разному

% для ферм необходимо найти максимальные растягивающие / сжимающие
% напряжения, найти коэффициенты запаса прочности и 
% по устойчивости из условий:
%
% 1) [G] <= G_t / n
% 2) n_y <= F_E / F_szh

if beam_style == 1
    
    % определение коэффициента запаса 
    % прочности конструкции
    

    beam_max_stretch_stress = abs(beam_stress_component(1,1,1));
    
    for j = 2: beam_amount
    
        if abs(beam_stress_component(1,1,j)) > beam_max_stretch_stress
            
            beam_max_stretch_stress = abs(beam_stress_component(1,1,j)); 

        end

    end

    % расчет на прочность фермы:
    
    is_construction_safe = beam_max_stretch_stress < steel_elasticity_limit;

    if is_construction_safe
    
        stretch_safety_factor = steel_elasticity_limit / beam_max_stretch_stress;
    
    else

        stretch_safety_factor = -1;

    end

    % расчет коэффициента запаса по устойчивости

    % критическую силу потери устойчивости можно считать
    % такой же, как для стойки Эйлера
    %
    % расчет на устойчивость имеет место только для
    % сжатых балок. В МКЭ стержень сжат, если первая
    % компонента вектора внутренних сил "+"

    
    stability_safety_factor = 10000;
    

    for i = 1 : beam_amount
        
        if beam_force_component(1,1,i) > 0

            beam_euler_force = E*J(i)/(beam_length(i))^2 * pi^2;

            beam_stability_safety_factor = beam_euler_force / beam_force_component(1,1,i);

            if beam_stability_safety_factor < stability_safety_factor

                stability_safety_factor = beam_stability_safety_factor;
                
            end

        end
        
    end
    
else

% для рам необходимо найти либо максимальные 
% растягивающие / сжимающие напряжения, 
% найти коэффициенты запаса прочности или 
% 
% максимальные суммарные напряжения
%
% 1) [G_рсж] <= G_t / n
% 2) [G_ sum] <= G_t / n
    
    % определение коэффициента запаса 
    % прочности конструкции
    beam_max_stretch_stress = abs(beam_stress_component(1,1,1));    
    beam_max_sum_stress = abs(beam_stress_component(1,1,1)) + abs(beam_stress_component(3,1,1));      

    for j = 1: beam_amount
    
        % случай отсутствия изгибающих моментов
        if beam_stress_component(3,1,j) == 0
            
            if beam_max_stretch_stress < abs(beam_stress_component(1,1,j))
                beam_max_stretch_stress = abs(beam_stress_component(1,1,j));
            end
        else
            if beam_max_sum_stress < abs(beam_stress_component(3,1,1)) + abs(beam_stress_component(1,1,j))
                beam_max_sum_stress = abs(beam_stress_component(3,1,1)) + abs(beam_stress_component(1,1,j));
            end
            
        end

    end

    % расчет на прочность фермы:
    
    is_construction_safe = (beam_max_stretch_stress < steel_elasticity_limit)&(beam_max_sum_stress < steel_elasticity_limit);

    if is_construction_safe
    
        stretch_safety_factor = steel_elasticity_limit / beam_max_stretch_stress;
        sum_safety_factor = steel_elasticity_limit / beam_max_sum_stress;
    
    else
    
        stretch_safety_factor = -1;
        sum_safety_factor = -1;

    end
    
end

%% Bывод в файл
result_table_label = ["Неразрушение конструкции", ...
    "Максимальные растягивающие напряжения, МПа", ...
    "Максимальные суммарные напряжения (для рамы), МПа", ...
    "Коэффициент запаса прочности при растяжении", ...
    "Коэффициент запаса прочности при общем виде нагружения (для рамы)", ...
    "Коэффициент запаса по устойчивости (для фермы)";];
result_table = zeros(1, 6);

result_table(1,1) = is_construction_safe;
result_table(1,2) = beam_max_stretch_stress;
result_table(1,4) = stretch_safety_factor;

if beam_style == 1
    result_table(1,6) = stability_safety_factor;
else
    result_table(1,6) = -1;
end

if beam_style == 2
    result_table(1,3) = beam_max_sum_stress;
    result_table(1,5) = sum_safety_factor;
else
    result_table(1,3) = -1;
    result_table(1,5) = -1;
end

% вывод в файл
if beam_style == 1
    writematrix(result_table_label,'Результанты_ферма.xlsx','Range','A1:F1');
    writematrix(result_table,'Результанты_ферма.xlsx','Range','A2:F2');
end

if beam_style == 2
    writematrix(result_table_label,'Результанты_рама.xlsx','Range','A1:F1');
    writematrix(result_table,'Результанты_рама.xlsx','Range','A2:F2');
end
