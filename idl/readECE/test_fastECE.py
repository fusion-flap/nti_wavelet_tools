#!/usr/bin/env python

import matplotlib.pylab as plt
import fastECE
import IPython
import numpy

ECE=fastECE.fastECE()
#ECE.Load(30416)
#ECE.Binning(samplefreq = 8.0)

## Lazlos super routines
##
##example, assume you will get following numbers
#selectedChannel= 20
#selectedtime = 1.0 + 1e-4*numpy.arange(1e4)

#rhop = ECE.MapToRhop(selectedtime)
#Te = ECE(selectedtime)
#print rhop[selectedChannel]
#print "This is ECE Channel number: ",ECE.ChannelNr[selectedChannel]
#Please use this command to test your Program..., so you do not have read RMC several times
IPython.embed()

ECE.Unload()

