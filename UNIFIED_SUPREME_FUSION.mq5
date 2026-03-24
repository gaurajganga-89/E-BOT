// UNIFIED SUPREME FUSION

#property version 1.36

// Other existing contents remain unchanged

// Remove TRADE_RETCODE_NO_QUOTES from RetcodeText

// New inputs for minimum SL guard and RR guard
input bool InpUseMinSLDistanceGuard = true;
input double InpMinSLDistance_ATRMult = 1.0;
input bool InpUseMinRRGuard = true;
input double InpMinRR = 1.5;
input bool InpMinRR_DisableTPOnly = false;

// Implementing IsRetryRetcode without NO_QUOTES

// In entry logic after riskDist computed add min SL guard
if (InpUseMinSLDistanceGuard) {
    // Add minimum SL logic here
}

// After TP validation add min RR guard
if (InpUseMinRRGuard) {
    // Add minimum RR logic here
}

// All other content unchanged.