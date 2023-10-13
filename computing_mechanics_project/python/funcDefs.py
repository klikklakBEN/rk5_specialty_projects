import numpy as np

#assuming there's a fucntion harvesting the node information from input txt/xls/spreadsheet file

# defining form functions

def N1(xi, eta):

    return 1./4 * (1 - xi) * (1 - eta);

def N2(xi, eta):

    return 1./4 * (1 + xi) * (1 - eta);

def N3(xi, eta):

    return 1./4 * (1 + xi) * (1 + eta);

def N4(xi, eta):

    return 1./4 * (1 - xi) * (1 + eta);


def dN1dxi(xi, eta):

    return -1./4*(1 - eta)

def dN1deta(xi, eta):

    return -1./4*(1 - xi)

def dN2dxi(xi, eta):

    return 1./4*(1 - eta)


def dN2deta(xi, eta):

    return -1./4*(1 + xi)

def dN3dxi(xi, eta):

    return 1./4*(1 + eta)

def dN3deta(xi, eta):

    return 1./4*(1 + xi)

def dN4dxi(xi, eta):

    return -1./4*(1 + eta)

def dN4deta(xi, eta):

    return 1./4*(1 - xi)

# define form function matrix


def NMatrix(xi, eta):

    n_mtx = np.zeros((2,8))
    
    n_mtx[0][0] = N1(xi, eta)
    n_mtx[1][1] = N1(xi, eta)
 
    n_mtx[0][2] = N2(xi, eta)
    n_mtx[1][3] = N2(xi, eta)
   
    n_mtx[0][4] = N3(xi, eta)
    n_mtx[1][5] = N3(xi, eta)

    n_mtx[0][6] = N4(xi, eta)
    n_mtx[1][7] = N4(xi, eta)

    return n_mtx;

def dNdxiMatrix(xi, eta):

    n_mtx = np.zeros((2,8))
    
    n_mtx[0][0] = dN1dxi(xi, eta)
    n_mtx[1][1] = dN1dxi(xi, eta)
 
    n_mtx[0][2] = dN2dxi(xi, eta)
    n_mtx[1][3] = dN2dxi(xi, eta)
   
    n_mtx[0][4] = dN3dxi(xi, eta)
    n_mtx[1][5] = dN3dxi(xi, eta)

    n_mtx[0][6] = dN4dxi(xi, eta)
    n_mtx[1][7] = dN4dxi(xi, eta)

    return n_mtx;


def dNdetaMatrix(xi, eta):

    n_mtx = np.zeros((2,8))
    
    n_mtx[0][0] = dN1deta(xi, eta)
    n_mtx[1][1] = dN1deta(xi, eta)
 
    n_mtx[0][2] = dN2deta(xi, eta)
    n_mtx[1][3] = dN2deta(xi, eta)
   
    n_mtx[0][4] = dN3deta(xi, eta)
    n_mtx[1][5] = dN3deta(xi, eta)

    n_mtx[0][6] = dN4deta(xi, eta)
    n_mtx[1][7] = dN4deta(xi, eta)

    return n_mtx;


# Jacobian matrix
def J(elemCoords, xi, eta):

    return
# make the damn program as easy as possible, do not make rocket science off of it!
# if the file returns some data, adjust the code to be able to read it! 
