function y = v1(x)
    detRoots = find_EF_2()
    
    y = K3(detRoots(1)*x)-K1(detRoots(1))/K2(detRoots(1))*K4(detRoots(1)*x)
    
endfunction
