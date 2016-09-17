# step.py

# stepper simulation for labelling machine
# a stepper class can step as many motors as we like

from random import randint

class Stepper():

    def __init__(self,nameStepLis):
        self.nameStepDict = {}
        for pr in nameStepLis:
            countDict={}
            #countDict['stepping'] = False]
            countDict['nbSteps']  = pr[1]
            countDict['stepsLeft'] = 0
            self.nameStepDict[pr[0]]= countDict

    def update(self):
        res = []
        for k in self.nameStepDict.keys():
            if self.nameStepDict[k]['stepsLeft']:
                res.append(k)
                self.nameStepDict[k]['stepsLeft'] -=1
        return res

    def startStepping(self,name):
        self.nameStepDict[name]['stepsLeft'] = self.nameStepDict[name]['nbSteps']
        
    def stopStepping(self, name):
        self.nameStepDict[name]['stepsLeft'] = 0

    def stepsLeft(self, name):
        return self.nameStepDict[name]['stepsLeft']
        
    def isStepping(self, name):
        return (self.nameStepDict[name]['stepsLeft'] > 0)

    def forceStep(self,name):
        self.nameStepDict[name]['stepsLeft'] +=1
        
        

class Detector():
    """
    simulator a detector of labels or tags
    """

    def __init__(self,detectionSteps, spacingSteps, spacingStepsError):
        """
        error is +/- steps range for random number
        """
        self.stepLength = detectionSteps
        self.spacingSteps = spacingSteps
        self.spacingStepsError = spacingStepsError
        self.detected = False
        self.stepsSinceDetection =  0
        self.setSpacing()
        self.labelCleared = False

    def setSpacing(self):
        self.spacing = self.spacingSteps + randint(-self.spacingStepsError, self.spacingStepsError)
        
    def step(self):
        self.stepsSinceDetection += 1
        if self.detected:
            # then we step towards length
            if self.stepsSinceDetection == self.stepLength + self.spacing:
                # if we stepped the lenght of the label, then detecion is over
                self.detected = False
                self.setSpacing()
                self.stepsSinceDetection = 0
                self.labelCleared = True
        else:
            if self.stepsSinceDetection == self.spacing:
                self.detected = True
                self.labelCleared = False


labelLength = 10
labelSpacing = 20
labelSpacingError = 0


class App():

    def __init__(self):
        self.detector = Detector(labelLength,labelSpacing,labelSpacingError)
        self.stepper = Stepper((('Label',labelLength),('Backing',labelLength)))

    def algo(self):
        """
        if the label is not stepping, 
           start it
        if the lable is stepping, and detected,
           start backing
        if the lable is cleared,
           stop it
        
        """
        if not self.stepper.isStepping('Label'):
            self.stepper.startStepping('Label')
            if self.detector.detected:
                self.stepper.startStepping('Backing')
        if self.detector.labelCleared:
            self.stepper.stopStepping('Label')
        
        
    def update(self):
        self.algo()
        self.detector.step()
        print(self.stepper.update())
                
