function dety = mtx_EF_2(x)
    
    _mtx_EF_2 = [K1(x), K2(x); K4(x), K1(x)]
    dety = det(_mtx_EF_2)
    
    
endfunction
