function dety = mtx_EF_1(x)
    
    _mtx_EF_1 = [K2(x), K4(x); K4(x), K2(x)]
    dety = det(_mtx_EF_1)
    
    
endfunction
