# stepper.py
"""
Algo 0:
Init:
1. put tag at start position
1. put label at start position
Loop
1. put tag at starting position
2. put tag at start position,
2. put backer to label positon - (labelLenght-tagLenth)/2
3. put label at start position
3. put backer at end positon


Algo 1:
constants:
TagLength
TagDp
LabelLenght
LabelDp
TagLabelDistance
InterLabelOutputDistance (5mm translated into steps)
TagLabelAdvanceDistance = TagLabelDistance - LabelDp - LabelLength/2.0




0123456789012345678901234567890123456789012345678901234567890123456789
ttttt
-----ttttt    LLLLLLLLLLL
-----------------ttttt                         
"""

import random

# constants
tagLength   = 5    # steps
tagSpace    = 10
tagCycleDistance = tagLength + tagSpace 
labelLength = 11
labelSpace  = 11
labelCycleDistance = labelLength + labelSpace 
distanceTag2Label = 20
backerCycleDistance = distanceTag2Label -(labelLength-tagLength)/2.0

maxStickers = 10


IDs = ['Tag','Backer','Label']
PINs = [50,51,52]

# stepper simulation for labelling machine
# a stepper class can step as many motors as we like

debug = False
#from random import randint
def delay(n):
    debug and print('delay',n)
def setPinHigh(p):
    debug and print('Pin: %s\tHIGH'%str(p))
def setPinLow(p):
    debug and print('Pin: %s\tLOW'%str(p))

pinHighDelay = 500
pinLowDelay  = 100

class Stepper():
    """
    controls one stepper motor,
    maintains:
    * id
    * nbStepsTaken?
    * nbStepsRemaining?
    * isStepping?
    offers:
    * update() - updates state
    * reset()  - put state to init values
    * addSteps(nbNewSteps=1) - increases nbStepsRemaining by nbNewSteps
    * step(n=1) - make n steps
    """

    def __init__(self,id):
        self.id=id
        self.resetC()

    def resetC(self):
        self.nbStepsTaken = self.nbStepsRemaining = self.isStepping = 0

    def addSteps(self,nbNewSteps=1):
        self.nbStepsRemaining += nbNewSteps

    def step(self,n=1):
        self.nbStepsRemaining -= n
        self.nbStepsTaken += n

    def update(self):
        self.isStepping = (self.nbStepsRemaining > 0)
        return self.isStepping
    
    def __repr__(self):
        return 'Stepper:\t%s\n\tnbStepsTaken\t:\t%d\n\tnbStepsRemaining:\t%d\n\tisStepping\t:\t%d'\
            %(str(self.id),self.nbStepsTaken, self.nbStepsRemaining,self.isStepping)
      
class StickerStepper(Stepper):
    def __init__(self,id,stickerNbSteps,nbStickers=maxStickers):
        Stepper.__init__(self,id)
        self.maxStickers = nbStickers
        self.stepLength  = stickerNbSteps
        self.reset()
        
    def reset(self):
        Stepper.resetC(self)
        self.stepsAtLastDetection = 0
        self.endOfStickerDetected = False
        self.nbStickersDetected   = 0
        self.setSpaceSteps()
            
    def setSpaceSteps(self):
        delta = round(self.stepLength/2.0)
        self.spaceSteps = 2*self.stepLength + random.randint(-delta,+delta)

    def detectStickerEnd(self):
        if self.nbStepsTaken - self.stepsAtLastDetection >= self.spaceSteps:
            self.endOfStickerDetected = True
            self.nbStickersDetected += 1
            self.stepsAtLastDetection = self.nbStepsTaken
            self.setSpaceSteps()
        return self.endOfStickerDetected

    def detectEndOfStickers(self):
        return self.nbStickersDetected >= self.maxStickers
    
    def step(self):
        Stepper.step(self)
        res = self.detectStickerEnd()
        self.endOfStickerDetected = False
        return res

class StepperMgr():
    """
    manages a bunch of steppers, optimizing and controlling steps
    """
    
    def __init__(self,motorIdLis, pinIdLis):
        self.steppers = {}
        for mot,pin in map(lambda x,y:(x,y),motorIdLis,pinIdLis):
            self.steppers[mot] = [False,pin,Stepper(mot)]
        self.motLis = motorIdLis

    def addSteps(self,id,nbSteps):
        self.steppers[id][2].addSteps(nbSteps)

    def resetAll(self):
        for s in self.steppers.values():
            s[2].resetC()
        
    def stepAll(self):
        for k in self.motLis:
            self.steppers[k][0] = self.steppers[k][2].update()
        if not any([v[0] for v in self.steppers.values()]):
            # no work to do, so return!
            return False

        for k in self.motLis:
            if self.steppers[k][0]:
                setPinHigh(self.steppers[k][1])
        delay(pinHighDelay)
        for k in self.motLis:
            if self.steppers[k][0]:
                setPinLow(self.steppers[k][1])
        delay(pinLowDelay)
        for k in self.motLis:
            if self.steppers[k][0]:
                self.steppers[k][2].step()
        return True
    
mgr = StepperMgr(IDs,PINs)
                              
def cycle(m,nbTags2Go):
    # assume init
    m.resetAll()
    tagCount = 0
    labelCount = 0
    nbLabels2Go = nbTags2Go
    tagsOnBacker = []
    labelsOnBacker = []
    while nbTags2Go > 0 or nbLabels2Go > 0 :
        # loop step #2:
        if nbTags2Go>0:
            m.addSteps('Tag',tagCycleDistance)
            nbTags2Go -=1
            print('Tag %d transferring to backer...'%tagCount)
            tagsOnBacker.append(tagCount)
            tagCount+=1
        m.addSteps('Backer',backerCycleDistance)
        print('Backer advancing carrying Tags: %s, Labels: %s...'%(str(tagsOnBacker),str(labelsOnBacker)))
        while m.stepAll():
            counts = ('Tag: %d'%m.steppers['Tag'][2].nbStepsTaken,
                      'Backer: %d'%m.steppers['Backer'][2].nbStepsTaken,
                      'Label: %d'%m.steppers['Label'][2].nbStepsTaken,)
            debug and print (counts)
            pass

        # loop step #3
        if nbTags2Go>0:
            m.addSteps('Tag',tagCycleDistance)
            nbTags2Go -=1
            print('Tag %d transferring to backer...'%tagCount)
            tagsOnBacker.append(tagCount)
            tagCount+=1
        m.addSteps('Label',labelCycleDistance)
        m.addSteps('Backer',backerCycleDistance) 
        print('Label %d transferring to backer'%labelCount)
        labelsOnBacker.append(labelCount)
        print('Backer advancing carrying Tags: %s, Labels: %s...'%(str(tagsOnBacker),str(labelsOnBacker)))
        labelCount += 1
        nbLabels2Go -=1
        while m.stepAll():
            counts = ('Tag: %d'%m.steppers['Tag'][2].nbStepsTaken,
                      'Backer: %d'%m.steppers['Backer'][2].nbStepsTaken,
                      'Label: %d'%m.steppers['Label'][2].nbStepsTaken,)
            debug and print (counts)
            pass
        
    
    
