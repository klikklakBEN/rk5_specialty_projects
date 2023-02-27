function x = f_m_Gaussa(b,c)
% a - расширенная матрица
% k - шаги метода Гаусса

% 
%b = [2 1; 1 -2]
%c = [-15; 34]


n=length(c);

a = zeros(n,n+1);

for i=1:n
    a(i,n+1)=c(i);
    for j=1:n
        a(i,j)=b(i,j);
    end
end

% Прямой ход метода Гаусса
for i=1:n
    a_max=a(i,i);
    i_max=i;
    for l=(i+1):n
        if abs(a(l,i))>abs(a_max)
           a_max=a(l,i);
           i_max=l;  
        end
    end

    for j=i:(n+1)
        r=a(i,j);
        a(i,j)=a(i_max,j);
        a(i_max,j)=r;
    end
    
    r=a(i,i); 

    if r ~= 0
        
        for j=i:(n+1)
             a(i,j)=a(i,j)/r;   
        end 

    else
        continue
    end
    
    for l=i+1:n
        r=a(l,i); 
        for j=i:n+1
            a(l,j)=a(l,j)-a(i,j)*r;  
        end
    end
    
%    k=i
%    a=a
%    disp(['Press any key to continue...'])
%    pause 
    
end

% Обратный ход метода Гаусса
x(n)=a(n,n+1);  
for i=1:(n-1)
    n_i=n-i;  
    sum=0;  
    for j=(n_i+1):n
        sum=sum+x(j)*a(n_i,j);  
    end    
    x(n_i)=a(n_i,n+1)-sum;
end
end