import numpy as np

def createNodes(elemCoord):
    
    count = elemCoord.shape[0]
    nodeTable = np.zeros((count,3))

    for i in range(count):
        nodeTable[i][0] = i
        nodeTable[i][1] = elemCoord[i][0]
        nodeTable[i][2] = elemCoord[i][1]


    return nodeTable


def createElem(nodes, nodeNum, matProp):
    
    n1 = nodes[nodeNum[0]]
    n2 = nodes[nodeNum[1]]
    n3 = nodes[nodeNum[2]]
    n4 = nodes[nodeNum[3]]

    elemNodes = [n1, n2, n3, n4]
    
    elemE   = matProp[0]
    elemPR  = matProp[1]

    return elemNodes, elemE, elemPR

def elemNormCoord(elem):

    return

