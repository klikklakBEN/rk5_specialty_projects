import numpy as np

#assuming there's a fucntion harvesting the node information from input txt/xls/spreadsheet file

def checkEqNodes(elemCoord1, elemCoord2):

    equalX = (elemCoord1[0] == elemCoord2[0])
    equalY = (elemCoord1[1] == elemCoord2[1])

    return (equalX & equalY)

def createNodes(elemCoord):
    
    count = elemCoord.shape[0]
    nodeTable = np.zeros((count,3))

    nodeTable[0][0] = 0
    nodeTable[0][1] = elemCoord[i][0]
    nodeTable[0][2] = elemCoord[i][1]
    
    i = 1
    index_i = 1
    while (i<count)
        
        i +=1
        if checkEqNodes(elemCoord[i], elemCoord[i-1]:
            continue
        nodeTable[i][0] = i
        nodeTable[i][1] = elemCoord[i][0]
        nodeTable[i][2] = elemCoord[i][1]
        
        index_i += 1

    return nodeTable, index_i


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


#tableOfNodes = txt.to.list.or.smth("ElemCoords")

# make the damn program as easy as possible, do not make rocket science off of it!
# if the file returns some data, adjust the code to be able to read it! 
