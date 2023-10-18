function yfind = find_EF_2()
    
    interval = linspace(0.01,200)
    old_root = mtx_EF_1(interval(1))
    
    i = 2
    while (mtx_EF_2(interval(i)) * old_root > 0) && (i <= length(interval))
        old_root = mtx_EF_2(interval(i))
        i = i + 1
    end
    
    if i < length(interval) then
        yRoot1 = interval(i)
    else
        yRoot1 = 0
    end
    
    
    if i+1 <= length(interval) then
        old_root = mtx_EF_2(interval(i))
        i = i + 1
        
        while (mtx_EF_2(interval(i)) * old_root > 0) && (i <= length(interval))
        old_root = mtx_EF_1(interval(i))
        i = i + 1
        end
    end


    if i < length(interval) then
        yRoot2 = interval(i)
    else
        yRoot2 = 0
    end

    yFindMtx = [yRoot1, yRoot2]
    
    yfind = yFindMtx

    
endfunction
