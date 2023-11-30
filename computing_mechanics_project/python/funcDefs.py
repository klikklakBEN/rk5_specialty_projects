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
def J(elem, xi, eta):

    elemNodeCoords = np.zeros(8)
    for i in range(8):

        elemNodeCoords[i] = elem[5+i]
    
    dxdxi,  dydxi  = np.dot(dNdxiMatrix(xi, eta), elemNodeCoords)
    dxdeta, dydeta = np.dot(dNdetaMatrix(xi, eta), elemNodeCoords)

    J_mtx = np.array([[dxdxi, dydxi], [dxdeta, dydeta]])
    

    return  J_mtx

# Jacobian determinant
def detJ(elem, xi, eta):

    return J(elem, xi, eta)[0][0] * J(elem, xi, eta)[1][1] - J(elem, xi, eta)[0][1] * J(elem, xi, eta)[1][0]

# Inverted Jacobian matrix
def invJ(elem, xi, eta):

    invJ_mtx = np.zeros((2,2))

    invJ_mtx[0][0] =  J(elem, xi, eta)[1][1]
    invJ_mtx[0][1] = -J(elem, xi, eta)[0][1]
    invJ_mtx[1][0] = -J(elem, xi, eta)[1][0]
    invJ_mtx[1][1] =  J(elem, xi, eta)[0][0]

    return 1./detJ(elem, xi, eta) * invJ_mtx

# Form functions derivatives from (x,y)
def dNdxy(elem, xi, eta):

    dNdxy_mtx = np.zeros((2,4))
    
    dN1dxieta = np.array([dN1dxi(xi, eta), dN1deta(xi, eta)])
    dN2dxieta = np.array([dN2dxi(xi, eta), dN2deta(xi, eta)])
    dN3dxieta = np.array([dN3dxi(xi, eta), dN3deta(xi, eta)])
    dN4dxieta = np.array([dN4dxi(xi, eta), dN4deta(xi, eta)])
    
    dNdxy_mtx[0][0], dNdxy_mtx[1][0] = np.dot( invJ(elem, xi, eta), dN1dxieta)
    dNdxy_mtx[0][1], dNdxy_mtx[1][1] = np.dot( invJ(elem, xi, eta), dN2dxieta)
    dNdxy_mtx[0][2], dNdxy_mtx[1][2] = np.dot( invJ(elem, xi, eta), dN3dxieta)
    dNdxy_mtx[0][3], dNdxy_mtx[1][3] = np.dot( invJ(elem, xi, eta), dN4dxieta)

    return dNdxy_mtx

# Strain form functions matrix [B]
def elemB(elem, xi, eta):

    B_mtx = np.zeros((3,8))

    for i in range(4):
        B_mtx[0][2*i]   = dNdxy(elem, xi, eta)[0][i]
        B_mtx[2][2*i+1] = dNdxy(elem, xi, eta)[0][i]
        B_mtx[1][2*i+1] = dNdxy(elem, xi, eta)[1][i]
        B_mtx[2][2*i]   = dNdxy(elem, xi, eta)[1][i]
        
    return B_mtx
    
# Finite element stiffness matrix non-integrated
def elemKMtx(elem, elemD, xi, eta):

    BD_mtx   = elemB(elem, xi, eta).transpose().dot(elemD)
    BDB_mtx  = BD_mtx.dot(elemB(elem, xi, eta))
    BDBJ_mtx = BDB_mtx * detJ(elem, xi, eta)

    return BDBJ_mtx

# Finite element stiffness matrix
def elemK(elem, elemD):
    
    xiEtaQuad = np.array([1/np.sqrt(3), -1/np.sqrt(3)])

    sumStiffness = 0

    for i in range(2):
        for j in range(2):

            sumStiffness += elemKMtx(elem, elemD, xiEtaQuad[i], xiEtaQuad[j])

    return sumStiffness

# Ansamble stiffness matrix
def systemK(elem, elemD, systemKNum):
    
    elemData = elem.copy();
        
    K_mtx = np.zeros((2*systemKNum, 2*systemKNum));
    
    for elemI in range(elemData.shape[0]):

            elemCurrent = elemData[elemI];
            elemIK   = elemK(elemCurrent, elemD);

            elemNodeRow    = 0;
            for globalNodeRowValue in elemCurrent[1:5]:

                elemNodeColumn = 0;
                for globalNodeColumnValue in elemCurrent[1:5]:


                    globalNodeRow    = int(globalNodeRowValue) - 1;
                    globalNodeColumn = int(globalNodeColumnValue) - 1;

                    K_mtx[2*globalNodeRow][2*globalNodeColumn]         += elemIK[2*elemNodeRow][2*elemNodeColumn];
                    K_mtx[2*globalNodeRow + 1][2*globalNodeColumn + 1] += elemIK[2*elemNodeRow + 1][2*elemNodeColumn + 1];
                    K_mtx[2*globalNodeRow][2*globalNodeColumn + 1] += elemIK[2*elemNodeRow][2*elemNodeColumn + 1];
                    K_mtx[2*globalNodeRow + 1][2*globalNodeColumn] += elemIK[2*elemNodeRow + 1][2*elemNodeColumn];

                    elemNodeColumn += 1;
                elemNodeRow += 1;



    return K_mtx

# System load
def systemP(loadData):
    
    xiEtaQuad = np.array([1/np.sqrt(3), -1/np.sqrt(3)])

    sumLoad = np.zeros(np.transpose(loadData).shape[0])

    for i in range(2):
        for j in range(2):

            sumLoad += np.dot(loadData, NMatrix(xiEtaQuad[i], xiEtaQuad[j]))

    return sumLoad

# Plotting node data
def elemPlot(elemData, elemLineStyle, elemLineColor, elemAxis):
    
    elemNum = elemData.shape[0]
    
    for i in range(elemNum):
        elemX = np.array([elemData[i][5], elemData[i][7],elemData[i][9],elemData[i][11], elemData[i][5]])
        elemY = np.array([elemData[i][6], elemData[i][8],elemData[i][10],elemData[i][12], elemData[i][6]])
        
        elemAxis.plot(elemX, elemY, linestyle = elemLineStyle, color = elemLineColor)
    
    return elemAxis


# make the damn program as easy as possible, do not make rocket science off of it!
# if the file returns some data, adjust the code to be able to read it! 
