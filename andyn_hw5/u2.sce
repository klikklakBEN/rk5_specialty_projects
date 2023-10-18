function y = u2(x)
    detRoots = find_EF_1()
    
    y = K2(detRoots(2)*x)-K2(detRoots(2)*2)/K4(detRoots(2)*2)*K4(detRoots(2)*x)
    
endfunction
