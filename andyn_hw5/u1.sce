function y = u1(x)
    detRoots = find_EF_1()
    
    y = K2(detRoots(1)*x)-K2(detRoots(1)*2)/K4(detRoots(1)*2)*K4(detRoots(1)*x)
    
endfunction
