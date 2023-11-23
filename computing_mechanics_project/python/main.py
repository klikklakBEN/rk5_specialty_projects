import funcDefs
import numpy as np
import matplotlib.pyplot as plt

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

    elemData[i][0] = int(elemTable[i][0])
    elemData[i][1] = int(elemTable[i][1])
    elemData[i][2] = int(elemTable[i][2])
    elemData[i][3] = int(elemTable[i][3])
    elemData[i][4] = int(elemTable[i][4])
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

# loads and boundaries

maxNode = 0

for i in range(1,5):
    for j in range(elemData.shape[0]):
        if (elemData[j][i] > maxNode):

            maxNode = elemData[j][i]

systemKNum = int(maxNode)

systemK = funcDefs.systemK(elemData, elemD, systemKNum)

nodeBC = np.loadtxt("BC.txt")

# Unloaded system
nodeLoadsInput = np.zeros((2*systemKNum,1))
#nodeLoads = funcDefs.systemP(nodeLoadsInput)

for node in nodeBC:

    systemK[2*int(node[0]-1) + int(node[1] - 1), 2*int(node[0]-1) + int(node[1] - 1)] *= 1E8
    nodeLoadsInput[2*int(node[0]-1) + int(node[1] - 1) ] = node[2] * systemK[2*int(node[0]-1) + int(node[1] - 1), 2*int(node[0]-1) + int(node[1] - 1)] 

systemDisp = np.linalg.solve(systemK, nodeLoadsInput)

# Plotting

plotFigure, deformedAxes = plt.subplots()

funcDefs.elemPlot(elemData, '--', 'red', deformedAxes)

elemDeformedData = elemData.copy()
for elem in elemDeformedData:
    for nodeCount in range(4):
        elem[5 + 2*nodeCount] = systemDisp[int(2*(elem[1 + nodeCount] - 1))][0]
        elem[6 + 2*nodeCount] = systemDisp[int(2*(elem[1 + nodeCount] - 1) + 1)][0]

for elemI in range(elemInputCount):
    for i in range(5,13):
        elemData[elemI][i] += elemDeformedData[elemI][i]

funcDefs.elemPlot(elemData, '-', 'blue', deformedAxes)

plotFigure.show()

