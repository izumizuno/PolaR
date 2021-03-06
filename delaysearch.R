#-------------------------------------- Function to calculate cross spectrum from correlation function
corr2spec <- function( corr ){
	nspec <- length(corr)/2
	spec <- fft(corr)[1:nspec]
	return(spec)
}
#-------------------------------------- Function to calculate correlation function from cross spectrum
spec2corr <- function(spec){
	nspec <- length(spec)
	tmpspec <- c(spec, 0, Conj(spec[nspec:2]))
	corr <- Re(fft(tmpspec, inverse=TRUE) / nspec)
	return(c(corr[(nspec+1):(2*nspec)], corr[1:nspec]))
}

#-------------------------------------- Delay Search
delay_search <- function( spec ){
	nspec <- length( spec )
	#-------- Search for delay
	delay <- which.max(Mod(spec2corr(spec))) - nspec - 1	# Coarse Delay
	trial_delay <- delay + seq(-1, 1, by=0.5); trial_amp <- numeric(0)
	for(i in 1:5){ trial_amp[i] <- Mod(sum(delay_cal(spec, trial_delay[i]))) }
	fit <- lm( formula = trial_amp ~ trial_delay + I(trial_delay^2) )
	return(-fit[[1]][[2]] / (2.0* fit[[1]][[3]]))
}

#-------------------------------------- Delay calibration
delay_cal <- function( spec, delay ){
	# spec : input spectrum (complex)
	# delay_cal() returns delay-calibrated spectrum
	#
	nspec <- length( spec )
	twiddle <- complex(modulus=rep(1, nspec), argument = delay* pi* seq((-nspec/2), (nspec/2 - 1), by=1) / nspec)
	return( spec * twiddle )
}

#-------------------------------------- Delay and Phase calibration
delayPhase_cal <- function( spec, delay, phase ){
	nspec <- length( spec )
	twiddle <- complex(modulus=rep(1, nspec), argument = phase + delay* pi* seq((-nspec/2), (nspec/2 - 1), by=1) / nspec)
	return( spec* twiddle )
}
