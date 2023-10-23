import funcDefs as fd
import numpy as np


# node input file: 1st column - node number, 2nd-4th - x,y,z global coords
nodeTable = np.loadtxt('nodeInput.txt')

# elem input file: 1st column - elem number, 2nd-5th - 1st-4th nodes
elemInputTable = np.loadtxt('elemInput.txt')
elemInputCount = elemInputTable.shape[0]
elemTable = np.zeros((elemInputCount, 5))

matTable = np.loadtxt('matInput.txt')
elemE    = matTable[0]
elemPR   = matTable[1]

for i in range(elemInputCount):

    elemTable[i][0] = elemInputTable[i][0]
    elemTable[i][1] = elemInputTable[i][6]
    elemTable[i][2] = elemInputTable[i][7]
    elemTable[i][3] = elemInputTable[i][8]
    elemTable[i][4] = elemInputTable[i][9]

elemData = np.zeros((elemInputCount, 13))

for i in range(elemInputCount):

    elemData[i][0] = elemTable[i][0]
    elemData[i][1] = elemTable[i][1]
    elemData[i][2] = elemTable[i][2]
    elemData[i][3] = elemTable[i][3]
    elemData[i][4] = elemTable[i][4]
    elemData[i][5]  = nodeTable[int(elemTable[i][1]) - 1][1]
    elemData[i][6]  = nodeTable[int(elemTable[i][1]) - 1][2]
    elemData[i][7]  = nodeTable[int(elemTable[i][2]) - 1][1]
    elemData[i][8]  = nodeTable[int(elemTable[i][2]) - 1][2]
    elemData[i][9]  = nodeTable[int(elemTable[i][3]) - 1][1]
    elemData[i][10] = nodeTable[int(elemTable[i][3]) - 1][2]
    elemData[i][11] = nodeTable[int(elemTable[i][4]) - 1][1]
    elemData[i][12] = nodeTable[int(elemTable[i][4]) - 1][2]

# Material matrix, ps - plain strain

E_ps  = elemE/(1 - np.power(elemPR,2))
PR_ps = elemPR/(1 - elemPR)

elemD = E_ps/(1-np.power(PR_ps,2)) * np.array([[1, PR_ps, 0],[PR_ps, 1, 0],[0, 0, (1-PR_ps)/2]])


