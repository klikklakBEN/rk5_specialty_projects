function y = v2(x)
    detRoots = find_EF_2()
    
    y = K3(detRoots(2)*x)-K1(detRoots(2))/K2(detRoots(2))*K4(detRoots(2)*x)
    
endfunction
