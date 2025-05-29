import numpy
import dd 
import kk 
import scipy.interpolate
import IPython
import scipy

class fastECE:
	def __init__( self ,  Experiment = 'AUGD', Diagnostic = 'RMD', Shotnumber = None ):
		self.Status_RMD = False
		self.Status_RMC = False
		self.Status = False
		if Shotnumber != None :
			self.Load( Shotnumber )
		

	def __del__( self ):
		self.Unload( )
		del self.Status

	def Load( self , Shotnumber, Experiment = 'AUGD', Edition = 0L, tBegin=-1.0, tEnd=12.0 ):
		self.Unload()		
	

		try:
			sf_RMD = dd.shotfile( 'RMD' , Shotnumber, Experiment, Edition)
       
		except:
			print "Error reading RMD shotfile" 
			return
		

#			read availability and freqency first for sorting
		avail  = sf_RMD.getParameter('parms-A', 'AVAILABL',dtype=numpy.float64).data
		self.Freq = sf_RMD.getParameter('parms-A', 'f',dtype=numpy.float64).data
		
#			high frequencies first (HFS)
		SortIndex =  numpy.argsort( self.Freq )[::-1]
			# remove bad channels in the sort index
		SortIndex = SortIndex[numpy.where( avail[SortIndex] == 1 )]

		self.Freq = self.Freq[SortIndex]
		self.ChannelNr =  numpy.arange(1,numpy.size(avail)+1)[SortIndex]
	       	self.nChannels = numpy.size(SortIndex)

		self.test_time = sf_RMD.getTimeBase( 'Trad-A', tBegin=tBegin, tEnd=tEnd)
		self.test_Te = sf_RMD( 'Trad-A', tBegin=tBegin, tEnd=tEnd ).data[:,SortIndex]
			
		self.z = sf_RMD( 'z-A', tBegin=tBegin, tEnd=tEnd ).data[:,SortIndex]
		self.R = sf_RMD( 'R-A', tBegin=tBegin, tEnd=tEnd ).data[:,SortIndex]
		self.rztime = sf_RMD.getTimeBase( 'R-A', tBegin=tBegin, tEnd=tEnd )	       	
		
		self.Btot = sf_RMD.getParameter('parms-A', 'Btot',dtype=numpy.float64).data[SortIndex]
		self.Ifgroup = sf_RMD.getParameter('parms-A', 'IFGROUP',dtype=numpy.float64).data[SortIndex]
		self.Calfact = sf_RMD.getParameter('parms-A', 'calfact',dtype=numpy.float64).data[SortIndex]
		self.Shift = sf_RMD.getParameter('parms-A', 'shift',dtype=numpy.float64).data[SortIndex]
	
		self.Multi00 = numpy.concatenate( (sf_RMD.getParameter('eCAL-A1', 'MULTIA00',dtype=numpy.float64).data,sf_RMD.getParameter('eCAL-A2', 'MULTIA00',dtype=numpy.float64 ).data),axis=0)[SortIndex]
		self.Shift00 = numpy.concatenate( (sf_RMD.getParameter('eCAL-A1', 'SHIFTB00',dtype=numpy.float64).data,sf_RMD.getParameter('eCAL-A2', 'SHIFTB00',dtype=numpy.float64).data),axis=0)[SortIndex]

		self.Sideband = sf_RMD.getParameter('METHODS', 'SIDEBAND').data
		self.Freqlo = sf_RMD.getParameter('METHODS', 'FREQLO',dtype=numpy.float64).data
		self.nIfgroups = int(sf_RMD.getParameter('METHODS', 'IFGROUPS',dtype=numpy.float64).data)
		
		self.Status_RMD = True
		self.Shotnumber = Shotnumber
				
	       	sf_RMD.close()

		#reading RMC data

		try:
			sf_RMC = dd.shotfile( 'RMC' , Shotnumber, Experiment, Edition)
       
		except:
			print "Error reading RMC shotfile" 
			return
			
		self.time = sf_RMC.getTimeBase( 'Trad-A1', tBegin=tBegin, tEnd=tEnd)
		self.ntimes = numpy.size(self.time)

		self.samplingrate = 1.0/numpy.mean(numpy.diff(self.time))
		
			# read raw rmc data Trad-A1 and Trad-A2 and sort it			
		self.Te = numpy.concatenate( (sf_RMC('Trad-A1', tBegin=tBegin, tEnd=tEnd,dtype=numpy.float64).data,sf_RMC('Trad-A2',tBegin=tBegin,tEnd=tEnd,dtype=numpy.float64).data),axis=1 )[:,SortIndex]
		sf_RMC.close()
		print "RMC read"


		self.Te = numpy.multiply(self.Multi00,self.Te,dtype=numpy.float64)
#		self.Te = numpy.add(self.Shift00,self.Te,dtype=numpy.float64)

		#IPython.embed()
		
		if (tBegin < -0.1):
			SelectTime = numpy.where( self.time <= 0.0 ) 
			CalcShift = numpy.reshape(numpy.mean(self.Te[SelectTime,:],axis=1,dtype=numpy.float64),(self.nChannels))
			self.Te = numpy.add(-CalcShift,self.Te,dtype=numpy.float64)
		else:
			self.Te = numpy.add(self.Shift00,self.Te,dtype=numpy.float64)

		#self.Te = numpy.add(-self.Shift,self.Te)
	#	self.Te = numpy.add(-CalcShift,self.Te,dtype=numpy.float64)
	
		

		self.Status_RMC = True

		if self.Status_RMC & self.Status_RMD:
			self.Status = True
		
		#IPython.embed()

	def Unload( self ):
		
		if self.Status_RMD:
			self.Status_RMD = False
			
			del self.test_time	
			del self.test_Te	
			del self.R
			del self.z
			del self.rztime
			del self.Shotnumber

			del self.Freq
			del self.Btot
			del self.Ifgroup
			del self.Calfact
			del self.Shift
			del self.nIfgroups
			del self.Sideband
			del self.Freqlo
			del self.ChannelNr
			del self.nChannels

		if self.Status_RMC:
			self.Status_RMC = False
			del self.time
			del self.ntimes
			del self.Te
			del self.samplingrate

		if self.Status: 
			self.Status = False



	def MapToRhop( self , timepoints, Experiment = 'AUGD', Diagnostic='EQH' ):
		ntimes = 0
		if self.Status:
			ntimes = numpy.size(timepoints)			
			rhop = numpy.zeros((ntimes,len(self.R[0,:])))
			try:
				for i in range(ntimes):
					rz_idx = numpy.argmin( numpy.abs( self.rztime - timepoints[i] ) )
					output = kk.KK().kkrzptfn( self.Shotnumber, self.rztime[rz_idx], self.R[rz_idx,:], self.z[rz_idx,:], exp= Experiment, diag=Diagnostic, ed=0)
					rhop[i,:] = output.rho_p
			except Exception:
				rz_idx = numpy.argmin(numpy.abs(self.rztime-timepoints))
				output = kk.KK().kkrzptfn( self.Shotnumber, self.rztime[rz_idx], self.R[rz_idx,:], self.z[rz_idx,:], exp= Experiment, diag=Diagnostic, ed=0)
				pass
			
			if ntimes > 1: 	
				return rhop 
			else: 
				return output.rho_p

	
	def getR( self , timepoints ):
		ntimes = 0
		if self.Status:
			ntimes = numpy.size(timepoints)			
			R = numpy.zeros((ntimes,numpy.size(self.R[0,:])))
			try:
				for i in range(ntimes):
					rz_idx = numpy.argmin( numpy.abs( self.rztime - timepoints[i] ) )
					R[i,:] = self.R[rz_idx,:]
			except Exception:
				rz_idx = numpy.argmin(numpy.abs(self.rztime-timepoints))
				output = self.R[rz_idx,:]
				pass
			
			if ntimes > 1: 	
				return R
			else: 
				return output

	def getZ( self , timepoints ):
		ntimes = 0
		if self.Status:
			ntimes = numpy.size(timepoints)			
			Z = numpy.zeros((ntimes,numpy.size(self.z[0,:])))
			try:
				for i in range(ntimes):
					rz_idx = numpy.argmin( numpy.abs( self.rztime - timepoints[i] ) )
					Z[i,:] = self.z[rz_idx,:]
			except Exception:
				rz_idx = numpy.argmin(numpy.abs(self.rztime-timepoints))
				output = self.z[rz_idx,:]
				pass
			
			if ntimes > 1: 	
				return Z
			else: 
				return output				

	def getTime( self , tBegin = -1.0, tEnd = 12.0 ):
		if self.Status:
			id0 = numpy.argmin( numpy.abs( self.time - tBegin ) )
			id1 = numpy.argmin( numpy.abs( self.time - tEnd ) )
			Te_time = self.time[id0:id1]

			return Te_time

	def __call__( self , tBegin = -1.0, tEnd = 12.0 ):
		if self.Status:
			id0 = numpy.argmin( numpy.abs( self.time - tBegin ) )
			id1 = numpy.argmin( numpy.abs( self.time - tEnd ) )
			Te_temp = self.Te[id0:id1, :]

			return Te_temp
