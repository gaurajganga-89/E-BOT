#property strict
#property version   "1.36"
#property description "USMF MTF v1.36 (MTF+MinSL+MinRR guards)"

#include <Trade/Trade.mqh>
CTrade trade;

// =====================================================
// INPUTS
// =====================================================

// ====== SYMBOL (OPTIONAL SAFETY) ======
input string InpTradeSymbol                 = "";    // "" = chart symbol; or set exact symbol name to lock. If set and chart differs -> trading blocked (panel still runs).

// --- Strategy mode ---
enum ENUM_STRATEGY_MODE { MODE_AUTO=0, MODE_TREND=1, MODE_RANGE=2, MODE_IMPULSE=3 };
input ENUM_STRATEGY_MODE InpStrategyMode = MODE_AUTO;

// --- Core / safety ---
input ulong  InpMagic                        = 260313;
input bool   InpNoHedgeOneSideOnly           = true;
input bool   InpNoOrderSendWhenTradeDisabled = true;

input int    InpMaxSpreadPoints              = 1500;
input int    InpSlippagePoints               = 50;
input int    InpCooldownSec                  = 3;

input int    InpManageIntervalSec            = 10;
input int    InpLinesSyncIntervalSec         = 1;

input int    InpMaxPositionsPerSide          = 2;
input int    InpMaxEntriesPerDay             = 40;

// --- Respect manual positions ---
input bool   InpRespectManualPositions       = true;

// --- Lots / risk ---
input bool   InpUseRiskLotSizing             = true;
input double InpRiskPercentPerEntry          = 0.25;
input double InpMaxRiskPercentPerSide        = 0.80;
input bool   InpForceMinLotIfRiskTooSmall    = true;

input double InpBaseLot                      = 0.01;
input double InpLotStep                      = 0.01;
input double InpMaxLotPerPosition            = 0.02;

input double InpMinAddDist_ATRMult           = 0.35;

// --- Daily stop (base fallback) ---
input double InpDailyStopLossUSD             = 100.0;
input bool   InpCloseAllOnDailyStop          = true;

// --- Auto Daily StopLoss based on R ---
input bool   InpUseAutoDailySL               = true;
input double InpAutoDailySL_R                = 3.0;

// --- Basket DayPnL Trail in R-units ---
input bool   InpUseBasketDayPnLTrail_R       = true;
input double InpBasketTrailStartR            = 2.0;
input double InpBasketTrailGivebackR         = 0.8;

// --- Post basket-trail cooldown ---
input bool   InpUsePostTrailCooldown         = true;
input int    InpPostTrailCooldownMin         = 45;

// --- Sessions ---
input bool   InpUseSessions                  = false;
input bool   InpUseSession2                  = false;
input int    InpS1StartHour                  = 7;
input int    InpS1StartMinute                = 0;
input int    InpS1EndHour                    = 12;
input int    InpS1EndMinute                  = 0;
input int    InpS2StartHour                  = 13;
input int    InpS2StartMinute                = 0;
input int    InpS2EndHour                    = 17;
input int    InpS2EndMinute                  = 0;

// --- News filter (entries only) ---
input bool   InpUseNewsFilter                = false;
input int    InpNewsBlockMinBefore           = 20;
input int    InpNewsBlockMinAfter            = 20;
input string InpNewsKeywords                 = "usd;fomc;cpi;nfp;fed;powell;rate;inflation;employment;boj;ecb;gdp;ppi;bitcoin;btc;crypto";

// --- Indicators (chart TF) ---
input int    InpFastMAPeriod                 = 20;
input int    InpSlowMAPeriod                 = 50;
input ENUM_MA_METHOD     InpMAMethod         = MODE_EMA;
input ENUM_APPLIED_PRICE InpPrice            = PRICE_CLOSE;

input int    InpRSIPeriod                    = 14;
input double InpRSIBullMin                   = 51.0;
input double InpRSIBearMax                   = 49.0;

input int    InpADXPeriod                    = 14;
input double InpADXTrendMin                  = 14.0;
input double InpADXRangeMax                  = 16.0;

input int    InpATRPeriod                    = 14;

input double InpSARStep                      = 0.02;
input double InpSARMax                       = 0.2;

// --- MTF range context (H1/H4/D1) ---
input bool            InpUseRangeTF2          = true;
input bool            InpUseRangeTF3_D1       = true;

input ENUM_TIMEFRAMES InpRangeTF1            = PERIOD_H1;
input int             InpRangeBarsTF1        = 48;

input ENUM_TIMEFRAMES InpRangeTF2            = PERIOD_H4;
input int             InpRangeBarsTF2        = 42;

input int             InpRangeBarsTF3_D1     = 60;

input int    InpRangeATRPeriod_TF1           = 14;
input int    InpRangeATRPeriod_TF2           = 14;
input int    InpRangeATRPeriod_TF3_D1        = 14;

input double InpRangeEdge_ATRMult_TF1        = 0.50;
input double InpRangeEdge_ATRMult_TF2        = 0.50;
input double InpRangeEdge_ATRMult_TF3_D1     = 0.60;

input double InpRangeEdge_SpreadMult         = 2.00;

input bool   InpRangeRequireRSI              = false;
input double InpRangeRSIBuyMax               = 55.0;
input double InpRangeRSISellMin              = 45.0;

// --- Impulse + continuation ---
input int    InpImpulseLookbackMin           = 90;
input double InpImpulseATRMult               = 2.0;
input bool   InpImpulseRequireADXUp          = false;

input bool   InpRequireContinuation          = false;
input double InpContMargin_ATRMult           = 0.12;
input double InpScoreContBonus               = 0.90;
input double InpScoreContPenalty             = 1.60;

// --- Stops & management ---
input bool   InpUseATRStops                  = true;
input double InpATRSL_Mult                   = 1.30;
input double InpMinSL_ATRMult                = 0.80;
input double InpMaxSL_ATRMult                = 6.00;

// ===== Filters =====
input bool   InpUseConfirmFilter             = true;
input double InpConfirmMinBody_ATR           = 0.15;

input bool   InpUseSwingWickSL               = true;
input int    InpSwingLookbackBars            = 12;
input double InpSwingBuffer_ATRMult          = 0.10;

input bool   InpUseRangeRejection            = true;
input double InpRejectWickMin_ATR            = 0.12;

// ===== Impulse retest/delay =====
input bool   InpUseImpulseRetest             = true;
input int    InpImpulseDelayBars             = 1;
input double InpRejectWickMin_ATR_Impulse    = 0.12;

// --- Break-even / trailing ---
input bool   InpUseBreakEven                 = true;
input double InpBE_Trigger_R                 = 0.90;
input double InpBE_Lock_ATRMult              = 0.10;

input bool   InpUseATRTrail                  = true;
input double InpTrailStartR                  = 1.40;
input double InpATRTrail_Mult                = 1.20;

// --- Profit Mode Trail ---
input bool   InpUseProfitModeTrail           = true;
input double InpProfitModeStartR             = 1.0;
input double InpProfitMode_ATRMult           = 0.85;

// --- Anti-modify spam ---
input int    InpModifyCooldownSec            = 60;
input int    InpModifyErrorBackoffSec        = 300;
input double InpMinSLStep_ATRMult            = 0.08;

// --- Partial close + TP-to-trail switch ---
input bool   InpUsePartialClose              = true;
input double InpPartialCloseTriggerR         = 1.0;
input int    InpPartialClosePercent          = 50;

input bool   InpTPToTrailSwitch              = true;
input double InpTPRemoveAfterR               = 1.2;

// --- Manual SL baseline mode ---
input bool   InpRespectManualSL              = true;
input int    InpManualSLDetectMinPoints      = 2;
input int    InpManualSLDetectGraceSec       = 5;

// --- Scoring weights ---
input double InpMinScoreToTrade              = 3.2;
input double InpScoreTrendWeight             = 1.00;
input double InpScoreRangeWeight             = 1.10;
input double InpScoreImpulseWeight           = 1.25;
input double InpScoreHTFWeight               = 1.00;

// --- D1 trend filter ---
input bool   InpUseD1TrendFilter             = true;
input bool   InpD1HardBlock                  = false;
input double InpD1TrendBonusPoints           = 1.5;
input double InpD1TrendPenaltyPoints         = 2.0;
input double InpScoreD1TrendWeight           = 1.00;

// --- HTF filter ---
input bool            InpUseHTFTrend          = true;
input bool            InpUseFixedHTF          = true;
input ENUM_TIMEFRAMES InpFixedHTF             = PERIOD_H1;
input bool            InpHTFHardBlock         = false;

// --- Take Profit (R-multiple TP) ---
input bool   InpUseTakeProfit                 = true;
input double InpTPTrend_R                     = 2.0;
input double InpTPImpulse_R                   = 1.6;
input bool   InpTPRangeToOppositeEdge_TF1     = true;
input bool   InpTPRangeToMid_TF1              = true;

// --- Auto-tune per symbol type ---
input bool   InpUseAutoTuneByCalcMode         = true;
input bool   InpAutoTuneOverrideInputs        = false; // if true: use tuned values as effective filters/SL; if false: only show in panel.
input double InpAutoTuneStrength              = 1.0;  // 0..1 (future blend), currently informational if override=false

// --- Risk guards (NEW v1.35) ---
input bool   InpUseLossStreakGuard            = true;
input int    InpLossStreakLookbackTrades      = 12;    // rolling window size to scan (EA-only)
input int    InpMaxConsecutiveLosses          = 3;     // stop entries after N losses in a row
input int    InpLossStreakCooldownMin         = 90;    // cooldown minutes after loss streak hit
input bool   InpLossCalcIncludeCommSwap       = true;  // compute PnL incl commission+swap (net)
input bool   InpResetLossStreakOnNewDay       = false; // if true: loss streak only counts within current day

// --- Min SL distance guard (NEW v1.36) ---
input bool   InpUseMinSLDistanceGuard         = true;
input double InpMinSLDistance_ATRMult         = 1.0;  // minimum SL distance as multiple of ATR

// --- Min RR guard (NEW v1.36) ---
input bool   InpUseMinRRGuard                 = true;
input double InpMinRR                         = 1.5;  // minimum risk-reward ratio
input bool   InpMinRR_DisableTPOnly           = false; // if true: allow entry but set TP=0; if false: block entry

// --- OrderSend retry (NEW v1.35) ---
input bool   InpUseOrderSendRetry             = true;
input int    InpOrderSendMaxTries             = 3;
input int    InpOrderSendRetryDelayMs         = 250;

// --- Panel ---
input bool   InpShowPanel                     = true;
input int    InpPanelCorner                   = 0;
input int    InpPanelX                        = 10;
input int    InpPanelY                        = 30;
input int    InpPanelFontSize                 = 11;
input int    InpPanelLineSpacingPx            = 16;
input string InpPanelFont                     = "Consolas";
input color  InpPanelColorOK                  = clrLime;
input color  InpPanelColorBlocked             = clrTomato;
input color  InpPanelColorInfo                = clrSilver;
input int    InpPanelUpdateMs                 = 250;

// --- Trade lines (NEW v1.35 reinstated full module) ---
input bool   InpDrawTradeLines                = true;
input bool   InpDeleteLinesOnClose            = true;
input bool   InpDrawEntryLine                 = true;
input bool   InpDrawSLLine                    = true;
input bool   InpDrawTP123Lines                = true;

input double InpTP1_R                         = 1.0;
input double InpTP2_R                         = 2.0;
input double InpTP3_R                         = 3.0;

input color  InpLineColorEntry                = clrSilver;
input color  InpLineColorSL                   = clrTomato;
input color  InpLineColorTP                   = clrLime;
input ENUM_LINE_STYLE InpLineStyle            = STYLE_DOT;
input int    InpLineWidth                     = 1;

// =====================================================
// GLOBALS
// =====================================================
string BOT_NAME="UNIFIED_SUPREME_MASTERS_FUSION_MTF";

int hFastMA=INVALID_HANDLE, hSlowMA=INVALID_HANDLE, hRSI=INVALID_HANDLE, hADX=INVALID_HANDLE, hATR=INVALID_HANDLE, hSAR=INVALID_HANDLE;

datetime g_lastBarTime=0;
datetime g_lastActionTime=0;
datetime g_lastManageTime=0;

int      g_lastDayYMD=0;
bool     g_dailyStopHit=false;
int      g_entriesToday=0;

double   g_dayPeakPnL=0.0;
datetime g_postTrailCooldownUntil=0;

int  g_lastPeriod=0;
long g_lastChartId=0;

// Panel
#define PANEL_LINES 160
string g_panelObj[PANEL_LINES];
ulong  g_lastPanelUpdateMs=0;

// trade lines / modify tracking / risk guards
#define MAX_TRACK 300
ulong    g_trackedTickets[MAX_TRACK];
datetime g_lastModifyTime[MAX_TRACK];
datetime g_lastModifyFailTime[MAX_TRACK];
bool     g_partialClosed[MAX_TRACK];

// manual SL baseline tracking
double   g_lastKnownSL[MAX_TRACK];
bool     g_manualSLDetected[MAX_TRACK];

int      g_trackedCount=0;
datetime g_lastLinesSyncTime=0;

// last order debug
int      g_lastOrderRetcode=0;
int      g_lastOrderErr=0;
string   g_lastOrderComment="";
datetime g_lastOrderTime=0;
int      g_lastOrderTries=0;

// impulse memory
datetime g_lastImpulseDetectedBarTime=0;

// loss streak guard state
int      g_lossStreak=0;
double   g_lastClosedPnL=0.0;
datetime g_lastClosedTime=0;
datetime g_lossCooldownUntil=0;

// v1.36 guard diagnostics
string   g_lastMinSLWhy="";
string   g_lastMinRRWhy="";

// auto-tune recommended (computed)
string g_tuneType="NONE";
double g_tuneConfirmMinBody_ATR=0;
double g_tuneRejectWick_ATR=0;
double g_tuneRejectWickImpulse_ATR=0;
double g_tuneSwingBuffer_ATR=0;
double g_tuneATRSL_Mult=0;
int    g_tuneImpulseDelayBars=0;

// =====================================================
// SYMBOL / PRICE HELPERS
// =====================================================
int SymDigits(){ return (int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS); }

double SymPoint()
{
  double p=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
  return (p>0? p : 0.0);
}

double SymTickSize()
{
  double ts=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
  if(ts<=0) ts=SymPoint();
  return ts;
}

double NormalizePrice(const double price)
{
  if(price<=0) return price;
  double ts=SymTickSize();
  if(ts<=0) return NormalizeDouble(price, SymDigits());

  double steps=MathRound(price/ts);
  double out=steps*ts;
  return NormalizeDouble(out, SymDigits());
}

int SpreadPoints(){ return (int)SymbolInfoInteger(_Symbol,SYMBOL_SPREAD); }

double SpreadPrice()
{
  int sprPts=SpreadPoints();
  double pt=SymPoint();
  if(sprPts<=0 || pt<=0) return 0.0;
  return sprPts*pt;
}

double StopLevelPrice()
{
  int stops=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
  double pt=SymPoint();
  if(stops<=0 || pt<=0) return 0.0;
  return stops*pt;
}

double FreezeLevelPrice()
{
  int freeze=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL);
  double pt=SymPoint();
  if(freeze<=0 || pt<=0) return 0.0;
  return freeze*pt;
}

// pre-trade check for entry SL/TP validity vs stops/freeze levels
bool CanPlaceStopsForEntry(const ENUM_ORDER_TYPE orderType,const double entry,const double sl,const double tp,string &why)
{
  why="";

  int stops=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
  int freeze=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL);
  int levelPts=MathMax(stops,freeze);
  if(levelPts<=0) return true;

  double pt=SymPoint();
  if(pt<=0) return true;
  if(entry<=0) return true;

  double minDist = levelPts*pt;

  if(sl>0)
  {
    if(orderType==ORDER_TYPE_BUY)
    {
      if((entry-sl) < minDist){ why="SL_TOO_CLOSE(stop/freeze)"; return false; }
    }
    else
    {
      if((sl-entry) < minDist){ why="SL_TOO_CLOSE(stop/freeze)"; return false; }
    }
  }

  if(tp>0)
  {
    if(orderType==ORDER_TYPE_BUY)
    {
      if((tp-entry) < minDist){ why="TP_TOO_CLOSE(stop/freeze)"; return false; }
    }
    else
    {
      if((entry-tp) < minDist){ why="TP_TOO_CLOSE(stop/freeze)"; return false; }
    }
  }

  return true;
}

bool SpreadOK(){ return SpreadPoints() <= InpMaxSpreadPoints; }

// =====================================================
// UTILS
// =====================================================
int YMD(datetime t){ MqlDateTime dt; TimeToStruct(t,dt); return dt.year*10000 + dt.mon*100 + dt.day; }
datetime DayStart(datetime t){ MqlDateTime dt; TimeToStruct(t,dt); dt.hour=0; dt.min=0; dt.sec=0; return StructToTime(dt); }
double ClampD(const double v,const double lo,const double hi){ if(v<lo) return lo; if(v>hi) return hi; return v; }
string AddReason(string s,const string r){ if(r=="") return s; if(s!="") s+=" | "; s+=r; return s; }

double EquityNow()
{
  double eq=AccountInfoDouble(ACCOUNT_EQUITY);
  if(eq<=0) eq=AccountInfoDouble(ACCOUNT_BALANCE);
  return eq;
}

bool TradeSymbolOK(string &why)
{
  why="";
  if(StringLen(InpTradeSymbol)<=0) return true;
  if(_Symbol==InpTradeSymbol) return true;
  why="WRONG_SYMBOL chart="+_Symbol+" need="+InpTradeSymbol;
  return false;
}

bool IsNewBar()
{
  datetime t=iTime(_Symbol,_Period,0);
  if(t!=g_lastBarTime){ g_lastBarTime=t; return true; }
  return false;
}

bool CooldownOK(){ return (InpCooldownSec<=0) ? true : ((TimeCurrent()-g_lastActionTime) >= InpCooldownSec); }
bool IsConnected(){ return (bool)TerminalInfoInteger(TERMINAL_CONNECTED); }

int ServerMinutesNow(){ MqlDateTime dt; TimeToStruct(TimeCurrent(),dt); return dt.hour*60 + dt.min; }
bool MinuteInWindow(int cur,int start,int end){ if(start<=end) return (cur>=start && cur<=end); return (cur>=start || cur<=end); }

bool SessionOK(string &why)
{
  why="";
  if(!InpUseSessions) return true;

  int cur=ServerMinutesNow();
  int s1Start=InpS1StartHour*60 + InpS1StartMinute;
  int s1End  =InpS1EndHour*60   + InpS1EndMinute;
  if(MinuteInWindow(cur,s1Start,s1End)) return true;

  if(InpUseSession2)
  {
    int s2Start=InpS2StartHour*60 + InpS2StartMinute;
    int s2End  =InpS2EndHour*60   + InpS2EndMinute;
    if(MinuteInWindow(cur,s2Start,s2End)) return true;
  }

  why="Outside sessions";
  return false;
}

string ToLowerStr(const string s)
{
  string out=s;
  for(int i=0;i<StringLen(out);i++)
  {
    ushort c=(ushort)StringGetCharacter(out,i);
    if(c>='A' && c<='Z') StringSetCharacter(out,i,(ushort)(c - 'A' + 'a'));
  }
  return out;
}

bool KeywordMatch(const string name,const string keywordsSemi)
{
  string n=ToLowerStr(name);
  string keys=ToLowerStr(keywordsSemi);

  int start=0;
  while(true)
  {
    int sep=StringFind(keys,";",start);
    string k=(sep<0) ? StringSubstr(keys,start) : StringSubstr(keys,start,sep-start);

    while(StringLen(k)>0 && StringGetCharacter(k,0)==' ') k=StringSubstr(k,1);
    while(StringLen(k)>0 && StringGetCharacter(k,StringLen(k)-1)==' ') k=StringSubstr(k,0,StringLen(k)-1);

    if(k!="" && StringFind(n,k) >= 0) return true;
    if(sep<0) break;
    start=sep+1;
  }
  return false;
}

bool IsNewsBlockedNow(string &status)
{
  if(!InpUseNewsFilter){ status="NEWS=OFF"; return false; }

  datetime now=TimeCurrent();
  datetime from= now - InpNewsBlockMinBefore*60;
  datetime to  = now + InpNewsBlockMinAfter*60;

  MqlCalendarValue values[];
  ResetLastError();
  int cnt=CalendarValueHistory(values, from, to);
  if(cnt<=0)
  {
    int err=GetLastError();
    status=(err==0) ? "NEWS=NONE" : "NEWS=ERR";
    return false;
  }

  for(int i=0;i<cnt;i++)
  {
    MqlCalendarEvent ev;
    if(!CalendarEventById(values[i].event_id, ev)) continue;
    if(!KeywordMatch(ev.name, InpNewsKeywords)) continue;
    status="NEWS=BLOCK";
    return true;
  }

  status="NEWS=OK";
  return false;
}

string SymbolTradeModeText()
{
  ENUM_SYMBOL_TRADE_MODE mode=(ENUM_SYMBOL_TRADE_MODE)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_MODE);
  switch(mode)
  {
    case SYMBOL_TRADE_MODE_DISABLED:  return "DISABLED";
    case SYMBOL_TRADE_MODE_LONGONLY:  return "LONGONLY";
    case SYMBOL_TRADE_MODE_SHORTONLY: return "SHORTONLY";
    case SYMBOL_TRADE_MODE_CLOSEONLY: return "CLOSEONLY";
    case SYMBOL_TRADE_MODE_FULL:      return "FULL";
  }
  return "UNKNOWN";
}

string RetcodeText(const uint rc)
{
  switch(rc)
  {
    case TRADE_RETCODE_REQUOTE:            return "REQUOTE";
    case TRADE_RETCODE_REJECT:             return "REJECT";
    case TRADE_RETCODE_CANCEL:             return "CANCEL";
    case TRADE_RETCODE_PLACED:             return "PLACED";
    case TRADE_RETCODE_DONE:               return "DONE";
    case TRADE_RETCODE_DONE_PARTIAL:       return "DONE_PARTIAL";
    case TRADE_RETCODE_ERROR:              return "ERROR";
    case TRADE_RETCODE_TIMEOUT:            return "TIMEOUT";
    case TRADE_RETCODE_INVALID:            return "INVALID";
    case TRADE_RETCODE_INVALID_VOLUME:     return "INVALID_VOLUME";
    case TRADE_RETCODE_INVALID_PRICE:      return "INVALID_PRICE";
    case TRADE_RETCODE_INVALID_STOPS:      return "INVALID_STOPS";
    case TRADE_RETCODE_TRADE_DISABLED:     return "TRADE_DISABLED";
    case TRADE_RETCODE_MARKET_CLOSED:      return "MARKET_CLOSED";
    case TRADE_RETCODE_NO_MONEY:           return "NO_MONEY";
    case TRADE_RETCODE_PRICE_CHANGED:      return "PRICE_CHANGED";
    case TRADE_RETCODE_PRICE_OFF:          return "PRICE_OFF";
    case TRADE_RETCODE_CONNECTION:         return "CONNECTION";
    case TRADE_RETCODE_ONLY_REAL:          return "ONLY_REAL";
    case TRADE_RETCODE_TOO_MANY_REQUESTS:  return "TOO_MANY_REQ";
    case TRADE_RETCODE_NO_CHANGES:         return "NO_CHANGES";
    case TRADE_RETCODE_SERVER_DISABLES_AT: return "SERVER_DISABLES";
    case TRADE_RETCODE_CLIENT_DISABLES_AT: return "CLIENT_DISABLES";
    case TRADE_RETCODE_LOCKED:             return "LOCKED";
    case TRADE_RETCODE_FROZEN:             return "FROZEN";
    default:                               return "RC_"+IntegerToString((int)rc);
  }
}

// =====================================================
// AUTO-TUNE
// =====================================================
string CalcModeText(const long calcMode)
{
  switch((ENUM_SYMBOL_CALC_MODE)calcMode)
  {
    case SYMBOL_CALC_MODE_FOREX:             return "FOREX";
    case SYMBOL_CALC_MODE_FUTURES:           return "FUTURES";
    case SYMBOL_CALC_MODE_CFD:               return "CFD";
    case SYMBOL_CALC_MODE_CFDINDEX:          return "CFDINDEX";
    case SYMBOL_CALC_MODE_CFDLEVERAGE:       return "CFDLEV";
    case SYMBOL_CALC_MODE_EXCH_STOCKS:       return "STOCKS";
    case SYMBOL_CALC_MODE_EXCH_FUTURES:      return "EXCH_FUT";
    default:                                 return "OTHER";
  }
}

void ComputeAutoTune()
{
  g_tuneType="OFF";
  g_tuneConfirmMinBody_ATR    = InpConfirmMinBody_ATR;
  g_tuneRejectWick_ATR        = InpRejectWickMin_ATR;
  g_tuneRejectWickImpulse_ATR = InpRejectWickMin_ATR_Impulse;
  g_tuneSwingBuffer_ATR       = InpSwingBuffer_ATRMult;
  g_tuneATRSL_Mult            = InpATRSL_Mult;
  g_tuneImpulseDelayBars      = InpImpulseDelayBars;

  if(!InpUseAutoTuneByCalcMode){ g_tuneType="OFF"; return; }

  long cm=(long)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_CALC_MODE);
  string symL=ToLowerStr(_Symbol);

  bool looksCrypto = (StringFind(symL,"btc")>=0 || StringFind(symL,"eth")>=0 || StringFind(symL,"crypto")>=0);
  bool looksMetal  = (StringFind(symL,"xau")>=0 || StringFind(symL,"xag")>=0 || StringFind(symL,"gold")>=0 || StringFind(symL,"silver")>=0);
  bool looksIndex  = (StringFind(symL,"us30")>=0 || StringFind(symL,"de40")>=0 || StringFind(symL,"dax")>=0 ||
                      StringFind(symL,"nas")>=0  || StringFind(symL,"sp")>=0   || StringFind(symL,"uk")>=0);

  string cmTxt=CalcModeText(cm);

  if(looksCrypto)
  {
    g_tuneType="CRYPTO";
    g_tuneConfirmMinBody_ATR    = 0.18;
    g_tuneRejectWick_ATR        = 0.13;
    g_tuneRejectWickImpulse_ATR = 0.14;
    g_tuneSwingBuffer_ATR       = 0.12;
    g_tuneATRSL_Mult            = 1.45;
    g_tuneImpulseDelayBars      = 1;
  }
  else if(looksMetal)
  {
    g_tuneType="METAL";
    g_tuneConfirmMinBody_ATR    = 0.16;
    g_tuneRejectWick_ATR        = 0.12;
    g_tuneRejectWickImpulse_ATR = 0.13;
    g_tuneSwingBuffer_ATR       = 0.11;
    g_tuneATRSL_Mult            = 1.35;
    g_tuneImpulseDelayBars      = 1;
  }
  else if(looksIndex || cmTxt=="CFDINDEX")
  {
    g_tuneType="INDEX";
    g_tuneConfirmMinBody_ATR    = 0.17;
    g_tuneRejectWick_ATR        = 0.12;
    g_tuneRejectWickImpulse_ATR = 0.13;
    g_tuneSwingBuffer_ATR       = 0.10;
    g_tuneATRSL_Mult            = 1.30;
    g_tuneImpulseDelayBars      = 1;
  }
  else
  {
    g_tuneType="FX/CFD";
    g_tuneConfirmMinBody_ATR    = 0.14;
    g_tuneRejectWick_ATR        = 0.11;
    g_tuneRejectWickImpulse_ATR = 0.12;
    g_tuneSwingBuffer_ATR       = 0.09;
    g_tuneATRSL_Mult            = 1.25;
    g_tuneImpulseDelayBars      = 0;
  }
}

// Effective values used in logic (override optional)
double EffConfirmMinBodyATR(){ return InpAutoTuneOverrideInputs ? g_tuneConfirmMinBody_ATR : InpConfirmMinBody_ATR; }
double EffRejectWickATR(){ return InpAutoTuneOverrideInputs ? g_tuneRejectWick_ATR : InpRejectWickMin_ATR; }
double EffRejectWickImpulseATR(){ return InpAutoTuneOverrideInputs ? g_tuneRejectWickImpulse_ATR : InpRejectWickMin_ATR_Impulse; }
double EffSwingBufferATR(){ return InpAutoTuneOverrideInputs ? g_tuneSwingBuffer_ATR : InpSwingBuffer_ATRMult; }
double EffATRSLMult(){ return InpAutoTuneOverrideInputs ? g_tuneATRSL_Mult : InpATRSL_Mult; }
int    EffImpulseDelayBars(){ return InpAutoTuneOverrideInputs ? g_tuneImpulseDelayBars : InpImpulseDelayBars; }

// =====================================================
// LOTS / POSITIONS
// =====================================================
double NormalizeLots(double lots)
{
  double minLot=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
  double maxLot=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
  double step  =SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
  if(step<=0) step=0.01;

  if(lots>InpMaxLotPerPosition) lots=InpMaxLotPerPosition;
  if(lots>maxLot) lots=maxLot;
  if(lots<minLot) lots=minLot;

  double out=MathFloor(lots/step)*step;
  if(out<minLot) out=minLot;
  if(out>InpMaxLotPerPosition) out=InpMaxLotPerPosition;
  return out;
}

double NormalizeVolumeStep(const double vol)
{
  double minV=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
  double maxV=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
  double step=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
  if(step<=0) step=0.01;

  double v=MathMax(minV, MathMin(maxV, vol));
  double out=MathFloor(v/step)*step;
  if(out<minV) out=minV;
  if(out>maxV) out=maxV;
  return out;
}

int CountPositionsByType_Symbol(const long type,const bool onlyEA)
{
  int c=0;
  for(int i=0;i<(int)PositionsTotal();i++)
  {
    ulong tk=(ulong)PositionGetTicket(i);
    if(tk==0 || !PositionSelectByTicket(tk)) continue;

    if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
    if((long)PositionGetInteger(POSITION_TYPE)!=type) continue;

    if(onlyEA)
    {
      if((ulong)PositionGetInteger(POSITION_MAGIC)!=InpMagic) continue;
    }
    c++;
  }
  return c;
}

bool GetLastEntryPriceForSide_EAOnly(const long type,double &px)
{
  px=0; datetime last=0;
  for(int i=0;i<(int)PositionsTotal();i++)
  {
    ulong tk=(ulong)PositionGetTicket(i);
    if(tk==0 || !PositionSelectByTicket(tk)) continue;
    if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
    if((ulong)PositionGetInteger(POSITION_MAGIC)!=InpMagic) continue;
    if((long)PositionGetInteger(POSITION_TYPE)!=type) continue;

    datetime t=(datetime)PositionGetInteger(POSITION_TIME);
    if(t>=last){ last=t; px=PositionGetDouble(POSITION_PRICE_OPEN); }
  }
  return last!=0;
}

bool MinAddDistanceOK_EAOnly(const long type,const double atr1)
{
  if(atr1<=0) return true;
  double minDist=atr1*InpMinAddDist_ATRMult;
  if(minDist<=0) return true;

  double lastPx=0;
  if(!GetLastEntryPriceForSide_EAOnly(type,lastPx)) return true;

  double price=(type==POSITION_TYPE_BUY) ? SymbolInfoDouble(_Symbol,SYMBOL_BID)
                                        : SymbolInfoDouble(_Symbol,SYMBOL_ASK);
  return MathAbs(price-lastPx) >= minDist;
}

// =====================================================
// PnL / DAILY STOP (EA-only) + LOSS STREAK GUARD
// =====================================================
double DealNetProfit(const ulong dealTicket)
{
  double p=HistoryDealGetDouble(dealTicket,DEAL_PROFIT);
  if(!InpLossCalcIncludeCommSwap) return p;
  p += HistoryDealGetDouble(dealTicket,DEAL_COMMISSION);
  p += HistoryDealGetDouble(dealTicket,DEAL_SWAP);
  return p;
}

double MyBasketFloatingUSD_EAOnly()
{
  double sum=0.0;
  for(int i=0;i<(int)PositionsTotal();i++)
  {
    ulong tk=(ulong)PositionGetTicket(i);
    if(tk==0 || !PositionSelectByTicket(tk)) continue;
    if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
    if((ulong)PositionGetInteger(POSITION_MAGIC)!=InpMagic) continue;
    sum += PositionGetDouble(POSITION_PROFIT);
  }
  return sum;
}

double TodayClosedNetPnL_EAOnly()
{
  double closed=0.0;
  datetime now=TimeCurrent();
  if(HistorySelect(DayStart(now), now))
  {
    for(int i=0;i<(int)HistoryDealsTotal();i++)
    {
      ulong d=(ulong)HistoryDealGetTicket(i);
      if(d==0) continue;
      if((string)HistoryDealGetString(d,DEAL_SYMBOL)!=_Symbol) continue;
      if((ulong)HistoryDealGetInteger(d,DEAL_MAGIC)!=InpMagic) continue;

      long entry=(long)HistoryDealGetInteger(d,DEAL_ENTRY);
      if(entry!=DEAL_ENTRY_OUT && entry!=DEAL_ENTRY_INOUT) continue;

      closed += DealNetProfit(d);
    }
  }
  return closed;
}

double TodayEquityPnL_EAOnly()
{
  return TodayClosedNetPnL_EAOnly() + MyBasketFloatingUSD_EAOnly();
}

void UpdateLossStreak_EAOnly()
{
  g_lossStreak=0;
  g_lastClosedPnL=0.0;
  g_lastClosedTime=0;

  if(!InpUseLossStreakGuard) return;

  datetime now=TimeCurrent();
  datetime from = (InpResetLossStreakOnNewDay ? DayStart(now) : (now - 30*24*3600)); // scan range wide enough
  if(!HistorySelect(from, now)) return;

  // iterate backwards deals to find last N closed OUT deals
  int counted=0;
  for(int i=(int)HistoryDealsTotal()-1; i>=0; i--)
  {
    ulong d=(ulong)HistoryDealGetTicket(i);
    if(d==0) continue;

    if((string)HistoryDealGetString(d,DEAL_SYMBOL)!=_Symbol) continue;
    if((ulong)HistoryDealGetInteger(d,DEAL_MAGIC)!=InpMagic) continue;

    long entry=(long)HistoryDealGetInteger(d,DEAL_ENTRY);
    if(entry!=DEAL_ENTRY_OUT && entry!=DEAL_ENTRY_INOUT) continue;

    double pnl=DealNetProfit(d);
    datetime t=(datetime)HistoryDealGetInteger(d,DEAL_TIME);

    if(g_lastClosedTime==0){ g_lastClosedTime=t; g_lastClosedPnL=pnl; }

    // consecutive losses from most recent backwards
    if(pnl < 0.0) g_lossStreak++;
    else break;

    counted++;
    if(counted>=InpLossStreakLookbackTrades) break;
  }
}

bool LossGuardBlocked(string &why)
{
  why="";
  if(!InpUseLossStreakGuard) return false;

  if(g_lossCooldownUntil>TimeCurrent())
  {
    why="LossCooldown";
    return true;
  }

  if(InpMaxConsecutiveLosses>0 && g_lossStreak>=InpMaxConsecutiveLosses)
  {
    // trigger cooldown
    if(InpLossStreakCooldownMin>0)
      g_lossCooldownUntil = TimeCurrent() + InpLossStreakCooldownMin*60;
    why="LossStreak";
    return true;
  }

  return false;
}

// =====================================================
// MIN SL DISTANCE GUARD (NEW v1.36)
// =====================================================
bool MinSLDistanceOK(const bool isBuy, const double entry, const double sl, const double atr1, string &why)
{
  why="";
  if(!InpUseMinSLDistanceGuard) return true;
  if(atr1<=0)                   return true;  // cannot evaluate without ATR

  double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
  if(tickSize<=0) tickSize = SymbolInfoDouble(_Symbol, SYMBOL_POINT);

  double minDist  = NormalizeDouble(InpMinSLDistance_ATRMult * atr1, _Digits);
  double slDist   = MathAbs(entry - sl);

  if(slDist < minDist)
  {
    why = StringFormat("MinSLDist:%.5f<%.5f(%.1fxATR)", slDist, minDist, InpMinSLDistance_ATRMult);
    return false;
  }
  return true;
}

// =====================================================
// MIN RR GUARD (NEW v1.36)
// =====================================================
// Returns true if entry is OK to proceed.
// If InpMinRR_DisableTPOnly=true and RR is too low: sets tp=0 and returns true (entry allowed, no TP).
// If InpMinRR_DisableTPOnly=false and RR is too low: sets why and returns false (entry blocked).
// If tp<=0: guard is skipped (cannot compute RR without TP).
bool MinRROK(const bool isBuy, const double entry, const double sl, double &tp, string &why)
{
  why="";
  if(!InpUseMinRRGuard) return true;
  if(tp<=0)             return true;  // no TP -> cannot compute RR, skip guard (Option 1)

  double risk   = MathAbs(entry - sl);
  if(risk<=0)   return true;  // degenerate case

  double reward = MathAbs(tp - entry);
  double rr     = reward / risk;

  if(rr < InpMinRR)
  {
    if(InpMinRR_DisableTPOnly)
    {
      tp  = 0.0;
      why = StringFormat("MinRR:%.2f<%.2f->NoTP", rr, InpMinRR);
      return true;   // entry allowed, TP removed
    }
    else
    {
      why = StringFormat("MinRR:%.2f<%.2f->Block", rr, InpMinRR);
      return false;  // entry blocked
    }
  }
  return true;
}

// =====================================================
// CLOSE ALL
// =====================================================
void CloseAllMyPositions_EAOnly(const string why)
{
  Print("CloseAllMyPositions_EAOnly: ", why);

  for(int pass=0; pass<3; pass++)
  {
    bool any=false;
    for(int i=(int)PositionsTotal()-1; i>=0; i--)
    {
      ulong tk=(ulong)PositionGetTicket(i);
      if(tk==0 || !PositionSelectByTicket(tk)) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC)!=InpMagic) continue;

      any=true;

      long type=(long)PositionGetInteger(POSITION_TYPE);
      double vol=PositionGetDouble(POSITION_VOLUME);
      if(vol<=0) continue;

      MqlTradeRequest req;
      MqlTradeResult  res;
      ZeroMemory(req);
      ZeroMemory(res);

      req.action    = TRADE_ACTION_DEAL;
      req.symbol    = _Symbol;
      req.magic     = InpMagic;
      req.volume    = vol;
      req.position  = tk;
      req.deviation = InpSlippagePoints;

      if(type==POSITION_TYPE_BUY)
      {
        req.type  = ORDER_TYPE_SELL;
        req.price = SymbolInfoDouble(_Symbol,SYMBOL_BID);
      }
      else
      {
        req.type  = ORDER_TYPE_BUY;
        req.price = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
      }

      ResetLastError();
      bool ok=OrderSend(req,res);
      if(!ok) continue;
      if(res.retcode!=TRADE_RETCODE_DONE && res.retcode!=TRADE_RETCODE_DONE_PARTIAL) continue;
    }
    if(!any) break;
  }

  g_lastActionTime=TimeCurrent();
}

// =====================================================
// PARTIAL CLOSE
// =====================================================
bool ClosePartialByTicket(const ulong posTicket,const long posType,const double volumeToClose)
{
  if(volumeToClose<=0) return false;

  MqlTradeRequest req;
  MqlTradeResult  res;
  ZeroMemory(req);
  ZeroMemory(res);

  req.action    = TRADE_ACTION_DEAL;
  req.position  = posTicket;
  req.symbol    = _Symbol;
  req.magic     = InpMagic;
  req.volume    = volumeToClose;
  req.deviation = InpSlippagePoints;

  if(posType==POSITION_TYPE_BUY)
  {
    req.type  = ORDER_TYPE_SELL;
    req.price = SymbolInfoDouble(_Symbol,SYMBOL_BID);
  }
  else
  {
    req.type  = ORDER_TYPE_BUY;
    req.price = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
  }

  ResetLastError();
  bool ok=OrderSend(req,res);
  if(!ok) return false;

  return (res.retcode==TRADE_RETCODE_DONE || res.retcode==TRADE_RETCODE_DONE_PARTIAL);
}

// =====================================================
// RISK SIZING (strict tick model)
// =====================================================
bool PriceDistanceToMoneyPerLot_Strict(const double priceDist,double &moneyPerLot)
{
  moneyPerLot=0.0;
  if(priceDist<=0) return false;

  double tick_size  = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
  double tick_value = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
  if(tick_size<=0 || tick_value<=0) return false;

  double ticks = priceDist / tick_size;
  if(ticks<=0) return false;

  moneyPerLot = ticks * tick_value;
  return (moneyPerLot>0.0);
}

double CurrentBasket1RMoney_EAOnly()
{
  double sum=0.0; int n=0;

  for(int i=0;i<(int)PositionsTotal();i++)
  {
    ulong tk=(ulong)PositionGetTicket(i);
    if(tk==0 || !PositionSelectByTicket(tk)) continue;
    if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
    if((ulong)PositionGetInteger(POSITION_MAGIC)!=InpMagic) continue;

    double open=PositionGetDouble(POSITION_PRICE_OPEN);
    double sl=PositionGetDouble(POSITION_SL);
    double vol=PositionGetDouble(POSITION_VOLUME);
    if(open<=0 || sl<=0 || vol<=0) continue;

    double moneyPerLot=0.0;
    if(!PriceDistanceToMoneyPerLot_Strict(MathAbs(open-sl), moneyPerLot)) continue;

    sum += moneyPerLot * vol;
    n++;
  }

  if(n>0) return sum / n;

  double eq=EquityNow();
  return (eq>0 ? eq*(InpRiskPercentPerEntry/100.0) : 0.0);
}

double OpenRiskMoneyForSide_EAOnly(const long type)
{
  double sum=0.0;
  for(int i=0;i<(int)PositionsTotal();i++)
  {
    ulong tk=(ulong)PositionGetTicket(i);
    if(tk==0 || !PositionSelectByTicket(tk)) continue;
    if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
    if((ulong)PositionGetInteger(POSITION_MAGIC)!=InpMagic) continue;
    if((long)PositionGetInteger(POSITION_TYPE)!=type) continue;

    double sl=PositionGetDouble(POSITION_SL);
    double open=PositionGetDouble(POSITION_PRICE_OPEN);
    double vol=PositionGetDouble(POSITION_VOLUME);
    if(sl<=0 || open<=0 || vol<=0) continue;

    double dist=MathAbs(open-sl);
    double moneyPerLot=0.0;
    if(!PriceDistanceToMoneyPerLot_Strict(dist,moneyPerLot)) continue;
    sum += moneyPerLot * vol;
  }
  return sum;
}

double LotsByRisk_Strict_ForceMin_EAOnly(const double entry,const double sl,const long sideType,
                                        double &entryRiskMoney,double &sideRiskMoney,double &sideCapMoney,
                                        bool &forcedMinLot)
{
  entryRiskMoney=0.0; sideRiskMoney=0.0; sideCapMoney=0.0; forcedMinLot=false;
  if(sl<=0 || entry<=0) return 0.0;

  double eq=EquityNow();
  if(eq<=0) return 0.0;

  double riskMoney = eq * (InpRiskPercentPerEntry/100.0);
  sideCapMoney     = eq * (InpMaxRiskPercentPerSide/100.0);
  sideRiskMoney    = OpenRiskMoneyForSide_EAOnly(sideType);

  double left = sideCapMoney - sideRiskMoney;
  if(left<=0.0) return 0.0;

  double moneyPerLot=0.0;
  if(!PriceDistanceToMoneyPerLot_Strict(MathAbs(entry-sl), moneyPerLot)) return 0.0;

  double allowedRisk = MathMin(riskMoney, left);
  double rawLots = (moneyPerLot>0.0) ? (allowedRisk/moneyPerLot) : 0.0;

  double brokerMin=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);

  if(InpForceMinLotIfRiskTooSmall && rawLots>0.0 && rawLots<brokerMin)
  {
    forcedMinLot=true;
    rawLots=brokerMin;
    entryRiskMoney = moneyPerLot * rawLots;
  }
  else entryRiskMoney=allowedRisk;

  return NormalizeLots(rawLots);
}

// =====================================================
// MTF RANGE HELPERS
// =====================================================
bool ReadATR_TF(const ENUM_TIMEFRAMES tf,const int period,double &atrOut)
{
  atrOut=0.0;
  if(period<=0) return false;
  if(Bars(_Symbol,tf) < period+5) return false;

  int h=iATR(_Symbol,tf,period);
  if(h==INVALID_HANDLE) return false;

  double a[];
  ArraySetAsSeries(a,true);
  ArrayResize(a,2);

  bool ok=(CopyBuffer(h,0,0,2,a)>=2);
  IndicatorRelease(h);
  if(!ok) return false;

  atrOut=a[1];
  return (atrOut>0);
}

bool RangeLevelsTF(const ENUM_TIMEFRAMES tf,const int lookbackBars,double &hi,double &lo,double &mid)
{
  hi=0; lo=0; mid=0;
  if(lookbackBars<10) return false;
  if(Bars(_Symbol,tf) < lookbackBars+5) return false;

  int hiIdx=iHighest(_Symbol,tf,MODE_HIGH,lookbackBars,1);
  int loIdx=iLowest (_Symbol,tf,MODE_LOW ,lookbackBars,1);
  if(hiIdx<0 || loIdx<0) return false;

  hi=iHigh(_Symbol,tf,hiIdx);
  lo=iLow (_Symbol,tf,loIdx);
  mid=(hi+lo)/2.0;
  return (hi>lo && hi>0 && lo>0);
}

double SpreadEdgeWidthPrice()
{
  double spr=SpreadPrice();
  return (spr>0 ? spr*InpRangeEdge_SpreadMult : 0.0);
}

double EdgeWidth_TF(const double atrTF,const double atrMult)
{
  double edgeATR = (atrTF>0 ? atrTF*atrMult : 0.0);
  double edgeSpr = SpreadEdgeWidthPrice();
  return MathMax(edgeATR, edgeSpr);
}

// =====================================================
// INDICATOR READS
// =====================================================
bool Copy3(const int handle,const int buffer,double &v1,double &v2,double &v3,int &errOut,int &copiedOut)
{
  errOut=0; copiedOut=0;
  double a[];
  ArraySetAsSeries(a,true);
  ArrayResize(a,3);

  ResetLastError();
  int c=CopyBuffer(handle,buffer,0,3,a);
  copiedOut=c;
  if(c<3){ errOut=GetLastError(); return false; }

  v1=a[1]; v2=a[2]; v3=a[0];
  return true;
}

bool ReadAllIndicators(
  double &fast1,double &fast2,double &slow1,double &slow2,
  double &rsi1,
  double &adx1,double &pdi1,double &mdi1,double &adx2,
  double &atr1,
  double &sar1,
  string &failWhat,
  int &failErr,
  int &failCopied
)
{
  failWhat=""; failErr=0; failCopied=0;

  double tmp=0;
  int err=0,cop=0;

  if(!Copy3(hFastMA,0,fast1,fast2,tmp,err,cop)){ failWhat="FastMA"; failErr=err; failCopied=cop; return false; }
  if(!Copy3(hSlowMA,0,slow1,slow2,tmp,err,cop)){ failWhat="SlowMA"; failErr=err; failCopied=cop; return false; }
  if(!Copy3(hRSI,0,rsi1,tmp,tmp,err,cop)){ failWhat="RSI"; failErr=err; failCopied=cop; return false; }

  if(!Copy3(hADX,0,adx1,adx2,tmp,err,cop)){ failWhat="ADX"; failErr=err; failCopied=cop; return false; }
  if(!Copy3(hADX,1,pdi1,tmp,tmp,err,cop)){ failWhat="+DI";  failErr=err; failCopied=cop; return false; }
  if(!Copy3(hADX,2,mdi1,tmp,tmp,err,cop)){ failWhat="-DI";  failErr=err; failCopied=cop; return false; }

  if(!Copy3(hATR,0,atr1,tmp,tmp,err,cop)){ failWhat="ATR"; failErr=err; failCopied=cop; return false; }
  if(!Copy3(hSAR,0,sar1,tmp,tmp,err,cop)){ failWhat="SAR"; failErr=err; failCopied=cop; return false; }

  return true;
}

// =====================================================
// HTF TREND
// =====================================================
ENUM_TIMEFRAMES AutoHTF(const ENUM_TIMEFRAMES tf)
{
  switch(tf)
  {
    case PERIOD_M1:  return PERIOD_M5;
    case PERIOD_M5:  return PERIOD_M15;
    case PERIOD_M15: return PERIOD_H1;
    case PERIOD_H1:  return PERIOD_H4;
    case PERIOD_H4:  return PERIOD_D1;
    case PERIOD_D1:  return PERIOD_W1;
    default:         return tf;
  }
}

ENUM_TIMEFRAMES SelectHTF()
{
  if(InpUseFixedHTF) return InpFixedHTF;
  return AutoHTF((ENUM_TIMEFRAMES)_Period);
}

bool GetHTFTrend(const ENUM_TIMEFRAMES htf,bool &htfBull,bool &htfBear)
{
  htfBull=false; htfBear=false;

  int bars=Bars(_Symbol,htf);
  if(bars < MathMax(InpFastMAPeriod,InpSlowMAPeriod)+5) return false;

  int hFast=iMA(_Symbol,htf,InpFastMAPeriod,0,InpMAMethod,InpPrice);
  int hSlow=iMA(_Symbol,htf,InpSlowMAPeriod,0,InpMAMethod,InpPrice);
  if(hFast==INVALID_HANDLE || hSlow==INVALID_HANDLE) return false;

  double f[], s[];
  ArraySetAsSeries(f,true); ArraySetAsSeries(s,true);
  ArrayResize(f,3); ArrayResize(s,3);

  bool ok=(CopyBuffer(hFast,0,0,3,f)>=3) && (CopyBuffer(hSlow,0,0,3,s)>=3);
  IndicatorRelease(hFast);
  IndicatorRelease(hSlow);
  if(!ok) return false;

  htfBull=(f[1] > s[1]);
  htfBear=(f[1] < s[1]);
  return true;
}

// =====================================================
// Strategy primitives + filters
// =====================================================
bool IsBullRegime(const double fast1,const double slow1,const double pdi1,const double mdi1,const double rsi1,const double sar1)
{
  if(!(fast1>slow1)) return false;
  if(!(pdi1>mdi1)) return false;
  if(!(rsi1>InpRSIBullMin)) return false;
  double c1=iClose(_Symbol,_Period,1);
  if(!(sar1<c1)) return false;
  return true;
}

bool IsBearRegime(const double fast1,const double slow1,const double pdi1,const double mdi1,const double rsi1,const double sar1)
{
  if(!(fast1<slow1)) return false;
  if(!(mdi1>pdi1)) return false;
  if(!(rsi1<InpRSIBearMax)) return false;
  double c1=iClose(_Symbol,_Period,1);
  if(!(sar1>c1)) return false;
  return true;
}

bool RSIPause(const double rsi1){ return (rsi1<=InpRSIBullMin && rsi1>=InpRSIBearMax); }

int BarsFromMinutes(const int minutes)
{
  int ps=PeriodSeconds(_Period);
  if(ps<=0) ps=60;
  int bars=(minutes*60)/ps;
  if(bars<3) bars=3;
  return bars;
}

double ContMarginFromATR(const double atr1){ return (atr1>0?atr1*InpContMargin_ATRMult:0.0); }

bool ContinuationBuy(const double fast2,const double fast1,const double atr1)
{
  double margin=ContMarginFromATR(atr1);
  return (iClose(_Symbol,_Period,2) < (fast2+margin) && iClose(_Symbol,_Period,1) > fast1);
}

bool ContinuationSell(const double fast2,const double fast1,const double atr1)
{
  double margin=ContMarginFromATR(atr1);
  return (iClose(_Symbol,_Period,2) > (fast2-margin) && iClose(_Symbol,_Period,1) < fast1);
}

bool ImpulseDetectedATR(const double atr1,const double adx1,const double adx2,double &rangeNow,double &threshold)
{
  rangeNow=0; threshold=0;
  int n=BarsFromMinutes(InpImpulseLookbackMin);
  if(Bars(_Symbol,_Period) < n+5) return false;
  if(atr1<=0 || InpImpulseATRMult<=0) return false;

  int hiIdx=iHighest(_Symbol,_Period,MODE_HIGH,n,1);
  int loIdx=iLowest (_Symbol,_Period,MODE_LOW ,n,1);
  if(hiIdx<0 || loIdx<0) return false;

  double hi=iHigh(_Symbol,_Period,hiIdx);
  double lo=iLow (_Symbol,_Period,loIdx);
  rangeNow=hi-lo;
  threshold=atr1*InpImpulseATRMult;

  if(InpImpulseRequireADXUp && !(adx1>adx2)) return false;
  return (rangeNow>=threshold);
}

bool BuildSL_ByATR(const bool isBuy,const double entry,const double atr1,double &sl)
{
  sl=0;
  if(!InpUseATRStops) return false;
  double mult=EffATRSLMult();
  if(atr1<=0 || mult<=0) return false;
  double dist=atr1*mult;
  dist=ClampD(dist, atr1*InpMinSL_ATRMult, atr1*InpMaxSL_ATRMult);
  sl=isBuy ? (entry-dist) : (entry+dist);
  return (sl>0);
}

bool ConfirmEntryCandle(const bool isBuy,const double atr1,const double fast1,string &why)
{
  why="";
  if(!InpUseConfirmFilter) return true;
  if(atr1<=0) return true;

  double o=iOpen(_Symbol,_Period,1);
  double c=iClose(_Symbol,_Period,1);
  double body=MathAbs(c-o);

  if(body < atr1*EffConfirmMinBodyATR()){ why="CONF_BODY_SMALL"; return false; }

  if(isBuy && !(c>fast1)){ why="CONF_CLOSE_NOT_ABOVE_FAST"; return false; }
  if(!isBuy && !(c<fast1)){ why="CONF_CLOSE_NOT_BELOW_FAST"; return false; }

  return true;
}

bool RejectionWickOK(const bool isBuy,const double atr1,const double minWickATR,string &why)
{
  why="";
  if(atr1<=0) return true;

  double o=iOpen(_Symbol,_Period,1);
  double c=iClose(_Symbol,_Period,1);
  double h=iHigh(_Symbol,_Period,1);
  double l=iLow (_Symbol,_Period,1);

  double upper=h-MathMax(o,c);
  double lower=MathMin(o,c)-l;

  double need=atr1*minWickATR;

  if(isBuy)
  {
    if(lower < need){ why="NO_BUY_REJECT"; return false; }
  }
  else
  {
    if(upper < need){ why="NO_SELL_REJECT"; return false; }
  }
  return true;
}

bool SwingStopPrice(const bool isBuy,const int lookbackBars,double &swingSL)
{
  swingSL=0.0;
  if(lookbackBars<3) return false;
  if(Bars(_Symbol,_Period) < lookbackBars+10) return false;

  int idx = isBuy ? iLowest(_Symbol,_Period,MODE_LOW,lookbackBars,1)
                  : iHighest(_Symbol,_Period,MODE_HIGH,lookbackBars,1);
  if(idx<0) return false;

  if(isBuy) swingSL=iLow(_Symbol,_Period,idx);
  else      swingSL=iHigh(_Symbol,_Period,idx);

  return (swingSL>0.0);
}

double ChooseEntrySL(const bool isBuy,const double entry,const double atr1,const double atrSL)
{
  double sl=atrSL;
  if(!InpUseSwingWickSL || atr1<=0) return sl;

  double swing=0.0;
  if(!SwingStopPrice(isBuy, InpSwingLookbackBars, swing)) return sl;

  double buffer = atr1*EffSwingBufferATR();
  double swingSL = isBuy ? (swing - buffer) : (swing + buffer);

  if(isBuy) sl = MathMin(sl, swingSL);
  else      sl = MathMax(sl, swingSL);

  return sl;
}

// =====================================================
// SCORING
// =====================================================
struct ScoreBreakdown{ double base, adx, di, rsi, htf, cont, edge, imp, d1; };
struct ScoreCandidate{ string name; bool isBuy; double score; ScoreBreakdown bd; };
void BDReset(ScoreBreakdown &bd){ bd.base=0; bd.adx=0; bd.di=0; bd.rsi=0; bd.htf=0; bd.cont=0; bd.edge=0; bd.imp=0; bd.d1=0; }

double ScoreHTF(const bool wantBuy,const bool wantSell,const bool htfBull,const bool htfBear,const bool htfOK)
{
  if(!InpUseHTFTrend) return 0.0;
  if(!htfOK) return 0.0;

  if(wantBuy && htfBull) return +2.0*InpScoreHTFWeight;
  if(wantSell && htfBear) return +2.0*InpScoreHTFWeight;

  if(wantBuy && htfBear) return -2.0*InpScoreHTFWeight;
  if(wantSell && htfBull) return -2.0*InpScoreHTFWeight;

  return 0.0;
}

double ScoreD1Trend(const bool wantBuy,const bool wantSell,const bool d1Bull,const bool d1Bear,const bool d1OK)
{
  if(!InpUseD1TrendFilter) return 0.0;
  if(!d1OK) return 0.0;

  if(wantBuy && d1Bull)  return +InpD1TrendBonusPoints  * InpScoreD1TrendWeight;
  if(wantSell && d1Bear) return +InpD1TrendBonusPoints  * InpScoreD1TrendWeight;

  if(wantBuy && d1Bear)  return -InpD1TrendPenaltyPoints* InpScoreD1TrendWeight;
  if(wantSell && d1Bull) return -InpD1TrendPenaltyPoints* InpScoreD1TrendWeight;

  return 0.0;
}

double ScoreTrendCandidate(const bool bull,const bool bear,const double adx1,const double pdi1,const double mdi1,const double rsi1, ScoreBreakdown &bd)
{
  BDReset(bd);
  if(!(bull||bear)) return 0.0;

  double s=0.0;
  bd.base=2.0*InpScoreTrendWeight; s+=bd.base;
  bd.adx =ClampD((adx1-InpADXTrendMin)/10.0,0.0,2.0)*InpScoreTrendWeight; s+=bd.adx;

  if(bull)
  {
    bd.di =ClampD((pdi1-mdi1)/10.0,0.0,2.0)*InpScoreTrendWeight;
    bd.rsi=ClampD((rsi1-InpRSIBullMin)/10.0,0.0,2.0)*InpScoreTrendWeight;
  }
  else
  {
    bd.di =ClampD((mdi1-pdi1)/10.0,0.0,2.0)*InpScoreTrendWeight;
    bd.rsi=ClampD((InpRSIBearMax-rsi1)/10.0,0.0,2.0)*InpScoreTrendWeight;
  }
  s+=bd.di+bd.rsi;
  return s;
}

double ScoreRangeCandidate_TF(const bool nearSupport,const bool nearResist,const double adx1,
                             const double bid,const double ask,const double rLo,const double rHi,
                             const double edgeWidthPrice,
                             ScoreBreakdown &bd)
{
  if(edgeWidthPrice<=0) return 0.0;
  if(!(nearSupport||nearResist)) return 0.0;

  double s=0.0;
  double base=2.0*InpScoreRangeWeight;
  double adxScore=ClampD((InpADXRangeMax-adx1)/5.0,0.0,2.0)*InpScoreRangeWeight;

  bd.base += base; s+=base;
  bd.adx  += adxScore; s+=adxScore;

  double ew=edgeWidthPrice + 1e-8;
  if(nearSupport)
  {
    double dist=MathAbs(bid-rLo);
    double edgeScore=ClampD(1.5 - dist/ew, 0.0, 1.5)*InpScoreRangeWeight;
    bd.edge += edgeScore; s+=edgeScore;
  }
  if(nearResist)
  {
    double dist=MathAbs(rHi-ask);
    double edgeScore=ClampD(1.5 - dist/ew, 0.0, 1.5)*InpScoreRangeWeight;
    bd.edge += edgeScore; s+=edgeScore;
  }
  return s;
}

double ScoreImpulseCandidate(const bool impulseOn,const double rangeNow,const double threshold,const double adx1,const double adx2, ScoreBreakdown &bd)
{
  BDReset(bd);
  if(!impulseOn) return 0.0;

  double s=0.0;
  bd.base=2.0*InpScoreImpulseWeight; s+=bd.base;

  if(threshold>0)
  {
    bd.imp=ClampD((rangeNow/threshold)-1.0,0.0,2.0)*InpScoreImpulseWeight;
    s+=bd.imp;
  }
  if(adx1>adx2)
  {
    bd.adx=0.5*InpScoreImpulseWeight;
    s+=bd.adx;
  }
  return s;
}

// =====================================================
// PANEL (no-flicker)
// =====================================================
#define PANEL_TEXT_EMPTY " "
void PanelInit()
{
  if(!InpShowPanel) return;
  for(int i=0;i<PANEL_LINES;i++)
  {
    string name=BOT_NAME+"_L"+IntegerToString(i);
    g_panelObj[i]=name;
    if(ObjectFind(0,name)>=0) ObjectDelete(0,name);
    ObjectCreate(0,name,OBJ_LABEL,0,0,0);
    ObjectSetInteger(0,name,OBJPROP_CORNER,InpPanelCorner);
    ObjectSetInteger(0,name,OBJPROP_XDISTANCE,InpPanelX);
    ObjectSetInteger(0,name,OBJPROP_YDISTANCE,InpPanelY + i*InpPanelLineSpacingPx);
    ObjectSetInteger(0,name,OBJPROP_FONTSIZE,InpPanelFontSize);
    ObjectSetString (0,name,OBJPROP_FONT,InpPanelFont);
    ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
    ObjectSetInteger(0,name,OBJPROP_HIDDEN,false);
    ObjectSetInteger(0,name,OBJPROP_BACK,false);
    ObjectSetString (0,name,OBJPROP_TEXT,PANEL_TEXT_EMPTY);
  }
  g_lastPanelUpdateMs=0;
}

void PanelDeinit()
{
  if(!InpShowPanel) return;
  for(int i=0;i<PANEL_LINES;i++) ObjectDelete(0,g_panelObj[i]);
}

void PanelSetLine(const int idx,const color c,const string text)
{
  if(!InpShowPanel) return;
  if(idx<0 || idx>=PANEL_LINES) return;
  if(ObjectFind(0,g_panelObj[idx])<0) return;
  ObjectSetInteger(0,g_panelObj[idx],OBJPROP_COLOR,c);
  ObjectSetString(0,g_panelObj[idx],OBJPROP_TEXT,(text==""?PANEL_TEXT_EMPTY:text));
}

bool PanelShouldUpdate(const bool force)
{
  if(!InpShowPanel) return false;
  if(force) return true;
  ulong now=(ulong)GetTickCount();
  if(InpPanelUpdateMs<=0) return true;
  if(g_lastPanelUpdateMs==0) return true;
  return (now - g_lastPanelUpdateMs) >= (ulong)InpPanelUpdateMs;
}

void PanelMarkUpdated(){ g_lastPanelUpdateMs=(ulong)GetTickCount(); }

// =====================================================
// TRADE LINES MODULE (v1.35)
// =====================================================
string LinePrefix(const ulong posTicket)
{
  return BOT_NAME + "_" + _Symbol + "_" + IntegerToString((int)InpMagic) + "_PT" + (string)posTicket + "_";
}

bool CreateOrUpdateHLine(const string name,const double price,const color c)
{
  if(price<=0) return false;
  double p=NormalizePrice(price);

  if(ObjectFind(0,name) < 0)
  {
    if(!ObjectCreate(0,name,OBJ_HLINE,0,0,p)) return false;
    ObjectSetInteger(0,name,OBJPROP_STYLE,InpLineStyle);
    ObjectSetInteger(0,name,OBJPROP_WIDTH,InpLineWidth);
    ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
    ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
  }
  ObjectSetDouble(0,name,OBJPROP_PRICE,p);
  ObjectSetInteger(0,name,OBJPROP_COLOR,c);
  return true;
}

void DeleteLinesForTicket(const ulong posTicket)
{
  string p=LinePrefix(posTicket);
  ObjectDelete(0,p+"ENTRY");
  ObjectDelete(0,p+"SL");
  ObjectDelete(0,p+"TP1");
  ObjectDelete(0,p+"TP2");
  ObjectDelete(0,p+"TP3");
}

int TrackIndex(const ulong posTicket)
{
  for(int i=0;i<g_trackedCount;i++)
    if(g_trackedTickets[i]==posTicket) return i;
  return -1;
}

void EnsureTracked(const ulong posTicket)
{
  int idx=TrackIndex(posTicket);
  if(idx>=0) return;
  if(g_trackedCount>=MAX_TRACK) return;

  g_trackedTickets[g_trackedCount]=posTicket;
  g_lastModifyTime[g_trackedCount]=0;
  g_lastModifyFailTime[g_trackedCount]=0;
  g_partialClosed[g_trackedCount]=false;

  g_lastKnownSL[g_trackedCount]=0.0;
  g_manualSLDetected[g_trackedCount]=false;

  g_trackedCount++;
}

void UntrackTicketAt(const int idx)
{
  if(idx<0 || idx>=g_trackedCount) return;
  for(int i=idx;i<g_trackedCount-1;i++)
  {
    g_trackedTickets[i]=g_trackedTickets[i+1];
    g_lastModifyTime[i]=g_lastModifyTime[i+1];
    g_lastModifyFailTime[i]=g_lastModifyFailTime[i+1];
    g_partialClosed[i]=g_partialClosed[i+1];

    g_lastKnownSL[i]=g_lastKnownSL[i+1];
    g_manualSLDetected[i]=g_manualSLDetected[i+1];
  }
  g_trackedCount--;
}

void DrawLinesForPositionTicket_EAOnly(const ulong posTicket)
{
  if(!InpDrawTradeLines) return;
  if(posTicket==0) return;
  if(!PositionSelectByTicket(posTicket)) return;

  if(PositionGetString(POSITION_SYMBOL)!=_Symbol) return;
  if((ulong)PositionGetInteger(POSITION_MAGIC)!=InpMagic) return;

  long type=(long)PositionGetInteger(POSITION_TYPE);
  double entry=PositionGetDouble(POSITION_PRICE_OPEN);
  double sl=PositionGetDouble(POSITION_SL);
  if(entry<=0) return;

  double R = (sl>0 ? MathAbs(entry-sl) : 0.0);

  string p=LinePrefix(posTicket);
  if(InpDrawEntryLine) CreateOrUpdateHLine(p+"ENTRY", entry, InpLineColorEntry);
  if(InpDrawSLLine && sl>0) CreateOrUpdateHLine(p+"SL", sl, InpLineColorSL);

  if(InpDrawTP123Lines && sl>0 && R>0)
  {
    bool isBuy=(type==POSITION_TYPE_BUY);
    double tp1 = isBuy ? entry + InpTP1_R*R : entry - InpTP1_R*R;
    double tp2 = isBuy ? entry + InpTP2_R*R : entry - InpTP2_R*R;
    double tp3 = isBuy ? entry + InpTP3_R*R : entry - InpTP3_R*R;

    CreateOrUpdateHLine(p+"TP1", tp1, InpLineColorTP);
    CreateOrUpdateHLine(p+"TP2", tp2, InpLineColorTP);
    CreateOrUpdateHLine(p+"TP3", tp3, InpLineColorTP);
  }

  EnsureTracked(posTicket);
}

void SyncTradeLines_EAOnly()
{
  if(!InpDrawTradeLines) return;

  for(int i=0;i<(int)PositionsTotal();i++)
  {
    ulong tk=(ulong)PositionGetTicket(i);
    if(tk==0) continue;
    if(!PositionSelectByTicket(tk)) continue;
    if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
    if((ulong)PositionGetInteger(POSITION_MAGIC)!=InpMagic) continue;
    DrawLinesForPositionTicket_EAOnly(tk);
  }

  if(!InpDeleteLinesOnClose) return;

  for(int i=g_trackedCount-1;i>=0;i--)
  {
    ulong tk=g_trackedTickets[i];
    if(tk==0){ UntrackTicketAt(i); continue; }
    if(!PositionSelectByTicket(tk))
    {
      DeleteLinesForTicket(tk);
      UntrackTicketAt(i);
    }
  }
}

// =====================================================
// ANTI-MODIFY SPAM (as in v1.27) + manual SL detect
// =====================================================
bool CanModifyStopsNow(const long posType,const double newSL,const double newTP)
{
  int stopsLevel=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
  int freezeLevel=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL);
  int levelPts=MathMax(stopsLevel,freezeLevel);
  if(levelPts<=0) return true;

  double point=SymPoint();
  if(point<=0) return true;

  double bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
  double ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
  double cur=(posType==POSITION_TYPE_BUY)?bid:ask;

  if(newSL>0)
  {
    double distPts=MathAbs(cur-newSL)/point;
    if(distPts < levelPts) return false;
  }
  if(newTP>0)
  {
    double distPts=MathAbs(cur-newTP)/point;
    if(distPts < levelPts) return false;
  }
  return true;
}

bool ShouldModifySL(const ulong posTicket,const long type,const double oldSL,const double newSL,const double atr1)
{
  if(newSL<=0 || oldSL<=0) return false;
  if(atr1<=0) return false;

  if(type==POSITION_TYPE_BUY){ if(newSL <= oldSL) return false; }
  else                       { if(newSL >= oldSL) return false; }

  double minStep=atr1*InpMinSLStep_ATRMult;
  if(minStep>0 && MathAbs(newSL-oldSL) < minStep) return false;

  int idx=TrackIndex(posTicket);
  if(idx>=0)
  {
    if(InpModifyCooldownSec>0 && g_lastModifyTime[idx]>0)
      if((TimeCurrent()-g_lastModifyTime[idx]) < InpModifyCooldownSec) return false;

    if(InpModifyErrorBackoffSec>0 && g_lastModifyFailTime[idx]>0)
      if((TimeCurrent()-g_lastModifyFailTime[idx]) < InpModifyErrorBackoffSec) return false;
  }
  return true;
}

bool ModifyPositionSLTP_ByTicket(const ulong position_ticket,const double sl,const double tp)
{
  if(!PositionSelectByTicket(position_ticket)) return false;
  long type=(long)PositionGetInteger(POSITION_TYPE);

  if(!CanModifyStopsNow(type, sl, tp))
    return false;

  MqlTradeRequest req;
  MqlTradeResult  res;
  ZeroMemory(req);
  ZeroMemory(res);

  req.action   = TRADE_ACTION_SLTP;
  req.position = position_ticket;
  req.symbol   = _Symbol;
  req.sl       = NormalizePrice(sl);
  req.tp       = (tp>0? NormalizePrice(tp):0.0);
  req.magic    = InpMagic;

  ResetLastError();
  bool ok=OrderSend(req,res);

  int idx=TrackIndex(position_ticket);
  if(!ok || (res.retcode!=TRADE_RETCODE_DONE && res.retcode!=TRADE_RETCODE_DONE_PARTIAL))
  {
    if(idx>=0) g_lastModifyFailTime[idx]=TimeCurrent();
    return false;
  }

  if(idx>=0) g_lastModifyTime[idx]=TimeCurrent();
  return true;
}

void ManualSLBaselineDetect_Update(const int idx,const double sl)
{
  if(idx<0) return;
  if(!InpRespectManualSL) return;
  if(sl<=0) return;

  double point=SymPoint();
  if(point<=0) point=0.00001;

  if(g_lastKnownSL[idx]<=0.0)
  {
    g_lastKnownSL[idx]=sl;
    return;
  }

  double diffPts=MathAbs(sl - g_lastKnownSL[idx]) / point;
  bool changedEnough = (diffPts >= InpManualSLDetectMinPoints);

  bool withinGrace = (g_lastModifyTime[idx]>0 && (TimeCurrent()-g_lastModifyTime[idx]) < InpManualSLDetectGraceSec);

  if(changedEnough && !withinGrace)
    g_manualSLDetected[idx]=true;

  g_lastKnownSL[idx]=sl;
}

// =====================================================
// POSITION MANAGEMENT (EA-only)
// =====================================================
void ManageOpenPositions_EAOnly(const double atr1)
{
  if(atr1<=0) return;

  for(int i=(int)PositionsTotal()-1; i>=0; i--)
  {
    ulong tk=(ulong)PositionGetTicket(i);
    if(tk==0 || !PositionSelectByTicket(tk)) continue;
    if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
    if((ulong)PositionGetInteger(POSITION_MAGIC)!=InpMagic) continue;

    EnsureTracked(tk);
    int idx=TrackIndex(tk);

    long type=(long)PositionGetInteger(POSITION_TYPE);
    double openPrice=PositionGetDouble(POSITION_PRICE_OPEN);
    double sl=PositionGetDouble(POSITION_SL);
    double tp=PositionGetDouble(POSITION_TP);

    if(openPrice<=0) continue;

    ManualSLBaselineDetect_Update(idx, sl);

    if(sl<=0) continue;
    double risk=MathAbs(openPrice-sl);
    if(risk<=0) continue;

    double bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
    double ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
    double cur=(type==POSITION_TYPE_BUY)?bid:ask;

    double profit=(type==POSITION_TYPE_BUY)?(cur-openPrice):(openPrice-cur);
    double R=profit/risk;

    // Partial close at +1R
    if(InpUsePartialClose && InpPartialClosePercent>0 && InpPartialClosePercent<100 && R>=InpPartialCloseTriggerR)
    {
      if(idx>=0 && !g_partialClosed[idx])
      {
        double vol=PositionGetDouble(POSITION_VOLUME);
        double minV=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);

        double wantClose = vol * (InpPartialClosePercent/100.0);
        double closeVol  = NormalizeVolumeStep(wantClose);

        if(closeVol>=minV && (vol-closeVol)>=minV)
        {
          if(ClosePartialByTicket(tk,type,closeVol))
          {
            g_partialClosed[idx]=true;
            g_lastActionTime=TimeCurrent();
          }
        }
      }
    }

    // Remove TP after 1.2R
    if(InpTPToTrailSwitch && tp>0 && R>=InpTPRemoveAfterR)
    {
      if(CanModifyStopsNow(type, sl, 0.0))
      {
        bool canTry=true;
        if(idx>=0 && InpModifyCooldownSec>0 && g_lastModifyTime[idx]>0)
          if((TimeCurrent()-g_lastModifyTime[idx]) < InpModifyCooldownSec) canTry=false;

        if(canTry)
          ModifyPositionSLTP_ByTicket(tk, sl, 0.0);
      }
    }

    // Break-even
    if(InpUseBreakEven && R>=InpBE_Trigger_R)
    {
      double lock=atr1*InpBE_Lock_ATRMult;
      double newSL=sl;

      if(type==POSITION_TYPE_BUY)
      {
        double beSL=openPrice+lock;
        if(sl<beSL) newSL=beSL;
      }
      else
      {
        double beSL=openPrice-lock;
        if(sl>beSL) newSL=beSL;
      }

      if(ShouldModifySL(tk,type,sl,newSL,atr1))
      {
        if(ModifyPositionSLTP_ByTicket(tk,newSL,PositionGetDouble(POSITION_TP)))
          sl=newSL;
      }
    }

    // ATR trail
    if(InpUseATRTrail && InpATRTrail_Mult>0 && R>=InpTrailStartR)
    {
      double trailMult = InpATRTrail_Mult;
      if(InpUseProfitModeTrail && R>=InpProfitModeStartR)
        trailMult = MathMin(trailMult, InpProfitMode_ATRMult);

      double trailDist=atr1*trailMult;
      double newSL=sl;

      if(type==POSITION_TYPE_BUY)
      {
        double trailSL=bid-trailDist;
        if(trailSL>newSL) newSL=trailSL;
      }
      else
      {
        double trailSL=ask+trailDist;
        if(trailSL<newSL) newSL=trailSL;
      }

      if(ShouldModifySL(tk,type,sl,newSL,atr1))
        ModifyPositionSLTP_ByTicket(tk,newSL,PositionGetDouble(POSITION_TP));
    }
  }
}

// =====================================================
// ORDER SEND RETRY (v1.35)
// =====================================================
bool IsRetryRetcode(const uint rc)
{
  return (rc==TRADE_RETCODE_REQUOTE ||
          rc==TRADE_RETCODE_PRICE_CHANGED ||
          rc==TRADE_RETCODE_PRICE_OFF ||
          rc==TRADE_RETCODE_TIMEOUT ||
          rc==TRADE_RETCODE_CONNECTION ||
          rc==TRADE_RETCODE_TOO_MANY_REQUESTS);
}

bool OrderSendWithRetry(MqlTradeRequest &req, MqlTradeResult &res, const int maxTries, const int delayMs)
{
  g_lastOrderTries=0;

  int tries = MathMax(1, maxTries);
  for(int t=1; t<=tries; t++)
  {
    // refresh price for market orders
    double bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
    double ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);

    if(req.type==ORDER_TYPE_BUY)  req.price = NormalizePrice(ask);
    if(req.type==ORDER_TYPE_SELL) req.price = NormalizePrice(bid);

    req.sl = (req.sl>0? NormalizePrice(req.sl):0.0);
    req.tp = (req.tp>0? NormalizePrice(req.tp):0.0);

    ResetLastError();
    bool ok = OrderSend(req,res);
    g_lastOrderTries=t;

    if(ok && (res.retcode==TRADE_RETCODE_DONE || res.retcode==TRADE_RETCODE_DONE_PARTIAL))
      return true;

    if(!InpUseOrderSendRetry) return ok;

    if(!IsRetryRetcode((uint)res.retcode)) return ok;

    if(delayMs>0) Sleep(delayMs);
  }
  return false;
}

// =====================================================
// INIT / DEINIT
// =====================================================
int OnInit()
{
  trade.SetExpertMagicNumber((long)InpMagic);

  hFastMA=iMA(_Symbol,_Period,InpFastMAPeriod,0,InpMAMethod,InpPrice);
  hSlowMA=iMA(_Symbol,_Period,InpSlowMAPeriod,0,InpMAMethod,InpPrice);
  hRSI=iRSI(_Symbol,_Period,InpRSIPeriod,InpPrice);
  hADX=iADX(_Symbol,_Period,InpADXPeriod);
  hATR=iATR(_Symbol,_Period,InpATRPeriod);
  hSAR=iSAR(_Symbol,_Period,InpSARStep,InpSARMax);

  if(hFastMA==INVALID_HANDLE || hSlowMA==INVALID_HANDLE || hRSI==INVALID_HANDLE ||
     hADX==INVALID_HANDLE || hATR==INVALID_HANDLE || hSAR==INVALID_HANDLE)
  {
    Print("Init failed (indicator handle). err=", GetLastError());
    return INIT_FAILED;
  }

  g_lastDayYMD=YMD(TimeCurrent());
  g_dailyStopHit=false;
  g_entriesToday=0;
  g_dayPeakPnL=0.0;
  g_postTrailCooldownUntil=0;

  g_lastManageTime=0;
  g_lastActionTime=0;

  g_trackedCount=0;
  for(int i=0;i<MAX_TRACK;i++)
  {
    g_trackedTickets[i]=0;
    g_lastModifyTime[i]=0;
    g_lastModifyFailTime[i]=0;
    g_partialClosed[i]=false;
    g_lastKnownSL[i]=0.0;
    g_manualSLDetected[i]=false;
  }
  g_lastLinesSyncTime=0;

  g_lastOrderRetcode=0;
  g_lastOrderErr=0;
  g_lastOrderComment="";
  g_lastOrderTime=0;
  g_lastOrderTries=0;

  g_lastImpulseDetectedBarTime=0;

  g_lossStreak=0;
  g_lastClosedPnL=0;
  g_lastClosedTime=0;
  g_lossCooldownUntil=0;

  g_lastPeriod=(int)_Period;
  g_lastChartId=(long)ChartID();

  ComputeAutoTune();
  UpdateLossStreak_EAOnly();

  PanelInit();
  return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
  if(hFastMA!=INVALID_HANDLE) IndicatorRelease(hFastMA);
  if(hSlowMA!=INVALID_HANDLE) IndicatorRelease(hSlowMA);
  if(hRSI!=INVALID_HANDLE) IndicatorRelease(hRSI);
  if(hADX!=INVALID_HANDLE) IndicatorRelease(hADX);
  if(hATR!=INVALID_HANDLE) IndicatorRelease(hATR);
  if(hSAR!=INVALID_HANDLE) IndicatorRelease(hSAR);

  if(InpDrawTradeLines)
  {
    for(int i=0;i<g_trackedCount;i++)
      DeleteLinesForTicket(g_trackedTickets[i]);
  }

  PanelDeinit();
}

// =====================================================
// ONTICK
// =====================================================
void OnTick()
{
  // keep panel alive on TF/chart change
  if((int)_Period!=g_lastPeriod || (long)ChartID()!=g_lastChartId)
  {
    g_lastPeriod=(int)_Period;
    g_lastChartId=(long)ChartID();
    ComputeAutoTune();
    PanelInit();
  }

  // throttle trade lines sync
  if(InpDrawTradeLines && (InpLinesSyncIntervalSec<=0 || (TimeCurrent()-g_lastLinesSyncTime) >= InpLinesSyncIntervalSec))
  {
    g_lastLinesSyncTime=TimeCurrent();
    SyncTradeLines_EAOnly();
  }

  // daily reset
  int ymd=YMD(TimeCurrent());
  if(ymd!=g_lastDayYMD)
  {
    g_lastDayYMD=ymd;
    g_dailyStopHit=false;
    g_entriesToday=0;
    g_dayPeakPnL=0.0;
    g_postTrailCooldownUntil=0;
    g_lastImpulseDetectedBarTime=0;

    if(InpResetLossStreakOnNewDay)
    {
      g_lossStreak=0;
      g_lossCooldownUntil=0;
    }
  }

  // compute tune and loss streak periodically (cheap enough)
  ComputeAutoTune();
  UpdateLossStreak_EAOnly();

  // dayPnL
  double todayClosed=TodayClosedNetPnL_EAOnly();
  double dayPnl = todayClosed + MyBasketFloatingUSD_EAOnly();

  // computed DailySL
  double oneR=CurrentBasket1RMoney_EAOnly();
  double dsl=InpDailyStopLossUSD;
  if(InpUseAutoDailySL && oneR>0.0) dsl = InpAutoDailySL_R * oneR;
  if(dsl<=0.0) dsl=InpDailyStopLossUSD;

  // Daily stop hit?
  if(!g_dailyStopHit && dsl>0.0 && dayPnl <= -dsl)
  {
    g_dailyStopHit=true;
    if(InpCloseAllOnDailyStop) CloseAllMyPositions_EAOnly("Daily SL hit");
  }

  // basket trailing
  if(InpUseBasketDayPnLTrail_R && !g_dailyStopHit)
  {
    if(dayPnl > g_dayPeakPnL) g_dayPeakPnL = dayPnl;

    if(oneR>0.0)
    {
      double startUSD    = InpBasketTrailStartR   * oneR;
      double givebackUSD = InpBasketTrailGivebackR* oneR;

      if(g_dayPeakPnL >= startUSD)
      {
        double giveback = g_dayPeakPnL - dayPnl;
        if(giveback >= givebackUSD)
        {
          CloseAllMyPositions_EAOnly("DayPnL Trail(R) hit");
          if(InpUsePostTrailCooldown && InpPostTrailCooldownMin>0)
            g_postTrailCooldownUntil = TimeCurrent() + InpPostTrailCooldownMin*60;
          g_dayPeakPnL = dayPnl;
        }
      }
    }
  }

  // gates
  bool canTrade=true;
  string blocked="";

  string symWhy="";
  if(!TradeSymbolOK(symWhy)){ canTrade=false; blocked=AddReason(blocked,"TradeSymbol"); }

  if(g_dailyStopHit){ canTrade=false; blocked=AddReason(blocked,"DailySL"); }
  if(!SpreadOK()){ canTrade=false; blocked=AddReason(blocked,"Spread"); }
  if(!CooldownOK()){ canTrade=false; blocked=AddReason(blocked,"Cooldown"); }
  if(InpMaxEntriesPerDay>0 && g_entriesToday>=InpMaxEntriesPerDay){ canTrade=false; blocked=AddReason(blocked,"MaxDay"); }

  if(InpUsePostTrailCooldown && g_postTrailCooldownUntil>TimeCurrent())
  {
    canTrade=false;
    blocked=AddReason(blocked,"PostTrailCooldown");
  }

  string lossWhy="";
  if(LossGuardBlocked(lossWhy))
  {
    canTrade=false;
    blocked=AddReason(blocked,lossWhy);
  }

  string sessWhy="";
  if(!SessionOK(sessWhy)){ canTrade=false; blocked=AddReason(blocked,"Session"); }

  string newsStatus="";
  if(IsNewsBlockedNow(newsStatus)){ canTrade=false; blocked=AddReason(blocked,"News"); }

  bool connected = IsConnected();
  bool termOK = (bool)TerminalInfoInteger(TERMINAL_TRADE_ALLOWED);
  bool mqlOK  = (bool)MQLInfoInteger(MQL_TRADE_ALLOWED);
  bool accOK  = (bool)AccountInfoInteger(ACCOUNT_TRADE_ALLOWED);

  string symMode=SymbolTradeModeText();
  bool symOK = !(symMode=="DISABLED" || symMode=="CLOSEONLY");

  if(!connected){ canTrade=false; blocked=AddReason(blocked,"NoConnection"); }
  if(!termOK) { canTrade=false; blocked=AddReason(blocked,"TerminalTradeOFF"); }
  if(!mqlOK)  { canTrade=false; blocked=AddReason(blocked,"MQLTradeOFF"); }
  if(!accOK)  { canTrade=false; blocked=AddReason(blocked,"AccountTradeOFF"); }
  if(!symOK)  { canTrade=false; blocked=AddReason(blocked,"SymbolTradeMode"); }

  // indicators
  double fast1=0,fast2=0,slow1=0,slow2=0,rsi1=0,adx1=0,adx2=0,pdi1=0,mdi1=0,atr1=0,sar1=0;
  string indFail=""; int indErr=0; int indCopied=0;
  bool okInd=ReadAllIndicators(fast1,fast2,slow1,slow2,rsi1,adx1,pdi1,mdi1,adx2,atr1,sar1, indFail,indErr,indCopied);
  if(!okInd){ canTrade=false; blocked=AddReason(blocked,"Indicators"); }

  // manage positions
  if(okInd && (InpManageIntervalSec<=0 || (TimeCurrent()-g_lastManageTime) >= InpManageIntervalSec))
  {
    g_lastManageTime=TimeCurrent();
    ManageOpenPositions_EAOnly(atr1);
  }

  bool newBar=IsNewBar();

  // positions count
  bool onlyEA = !InpRespectManualPositions;
  int buysNow  = CountPositionsByType_Symbol(POSITION_TYPE_BUY,  onlyEA);
  int sellsNow = CountPositionsByType_Symbol(POSITION_TYPE_SELL, onlyEA);

  if(InpNoHedgeOneSideOnly && buysNow>0 && sellsNow>0)
  {
    canTrade=false;
    blocked=AddReason(blocked,"HedgeDetected");
  }

  // =========================
  // Build PLAN on new bar (panel intent)
  // =========================
  ScoreCandidate best; best.name="NONE"; best.isBuy=true; best.score=-1e9; BDReset(best.bd);

  // MTF range context
  bool have1=false, have2=false, have3=false;
  double hi1=0,lo1=0,mid1=0, hi2=0,lo2=0,mid2=0, hi3=0,lo3=0,mid3=0;

  double atrTF1=0,atrTF2=0,atrTF3=0;
  bool atrTF1OK=false, atrTF2OK=false, atrTF3OK=false;

  have1=RangeLevelsTF(InpRangeTF1, InpRangeBarsTF1, hi1,lo1,mid1);
  have2=(InpUseRangeTF2 ? RangeLevelsTF(InpRangeTF2, InpRangeBarsTF2, hi2,lo2,mid2) : false);
  have3=(InpUseRangeTF3_D1 ? RangeLevelsTF(PERIOD_D1, InpRangeBarsTF3_D1, hi3,lo3,mid3) : false);

  atrTF1OK=ReadATR_TF(InpRangeTF1, InpRangeATRPeriod_TF1, atrTF1);
  atrTF2OK=(InpUseRangeTF2 ? ReadATR_TF(InpRangeTF2, InpRangeATRPeriod_TF2, atrTF2) : false);
  atrTF3OK=(InpUseRangeTF3_D1 ? ReadATR_TF(PERIOD_D1, InpRangeATRPeriod_TF3_D1, atrTF3) : false);

  double bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
  double ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);

  bool sup1=false,res1=false,sup2=false,res2=false,sup3=false,res3=false;
  double edge1=0,edge2=0,edge3=0;
  if(have1 && atrTF1OK){ edge1=EdgeWidth_TF(atrTF1, InpRangeEdge_ATRMult_TF1); sup1=(bid<=lo1+edge1); res1=(ask>=hi1-edge1); }
  if(have2 && atrTF2OK){ edge2=EdgeWidth_TF(atrTF2, InpRangeEdge_ATRMult_TF2); sup2=(bid<=lo2+edge2); res2=(ask>=hi2-edge2); }
  if(have3 && atrTF3OK){ edge3=EdgeWidth_TF(atrTF3, InpRangeEdge_ATRMult_TF3_D1); sup3=(bid<=lo3+edge3); res3=(ask>=hi3-edge3); }

  bool nearSupport = sup1 || sup2 || sup3;
  bool nearResist  = res1 || res2 || res3;

  // regimes
  bool bull=false, bear=false, rsiPause=false;
  bool contBuy=false, contSell=false;
  bool impOn=false; double impRange=0, impThr=0;

  if(okInd)
  {
    bull=IsBullRegime(fast1,slow1,pdi1,mdi1,rsi1,sar1);
    bear=IsBearRegime(fast1,slow1,pdi1,mdi1,rsi1,sar1);
    rsiPause=RSIPause(rsi1);

    contBuy=ContinuationBuy(fast2,fast1,atr1);
    contSell=ContinuationSell(fast2,fast1,atr1);

    impOn=ImpulseDetectedATR(atr1,adx1,adx2,impRange,impThr);
    if(impOn)
    {
      datetime barTime1=iTime(_Symbol,_Period,1);
      if(g_lastImpulseDetectedBarTime!=barTime1)
        g_lastImpulseDetectedBarTime=barTime1;
    }
  }

  // HTF/D1
  ENUM_TIMEFRAMES htf=SelectHTF();
  bool htfBull=false, htfBear=false;
  bool htfOK=(!InpUseHTFTrend) ? false : GetHTFTrend(htf, htfBull, htfBear);

  bool htfBlocksBuy  = (InpUseHTFTrend && InpHTFHardBlock && htfOK && htfBear);
  bool htfBlocksSell = (InpUseHTFTrend && InpHTFHardBlock && htfOK && htfBull);

  bool d1Bull=false, d1Bear=false;
  bool d1OK = GetHTFTrend(PERIOD_D1, d1Bull, d1Bear);

  bool d1BlocksBuy  = (InpUseD1TrendFilter && InpD1HardBlock && d1OK && d1Bear);
  bool d1BlocksSell = (InpUseD1TrendFilter && InpD1HardBlock && d1OK && d1Bull);

  bool allowTrend   = (InpStrategyMode==MODE_AUTO || InpStrategyMode==MODE_TREND);
  bool allowRange   = (InpStrategyMode==MODE_AUTO || InpStrategyMode==MODE_RANGE);
  bool allowImpulse = (InpStrategyMode==MODE_AUTO || InpStrategyMode==MODE_IMPULSE);

  if(allowTrend && okInd && !rsiPause)
  {
    if(bull && !htfBlocksBuy && !d1BlocksBuy)
    {
      ScoreBreakdown bd; double s=ScoreTrendCandidate(true,false,adx1,pdi1,mdi1,rsi1,bd);
      bd.htf=ScoreHTF(true,false,htfBull,htfBear,htfOK); s+=bd.htf;
      bd.d1 =ScoreD1Trend(true,false,d1Bull,d1Bear,d1OK); s+=bd.d1;
      if(InpRequireContinuation){ bd.cont=(contBuy?+InpScoreContBonus:-InpScoreContPenalty); s+=bd.cont; }
      if(s>best.score){ best.name="TREND_BUY"; best.isBuy=true; best.score=s; best.bd=bd; }
    }
    if(bear && !htfBlocksSell && !d1BlocksSell)
    {
      ScoreBreakdown bd; double s=ScoreTrendCandidate(false,true,adx1,pdi1,mdi1,rsi1,bd);
      bd.htf=ScoreHTF(false,true,htfBull,htfBear,htfOK); s+=bd.htf;
      bd.d1 =ScoreD1Trend(false,true,d1Bull,d1Bear,d1OK); s+=bd.d1;
      if(InpRequireContinuation){ bd.cont=(contSell?+InpScoreContBonus:-InpScoreContPenalty); s+=bd.cont; }
      if(s>best.score){ best.name="TREND_SELL"; best.isBuy=false; best.score=s; best.bd=bd; }
    }
  }

  if(allowRange && okInd && (have1 || have2 || have3))
  {
    bool rsiOKBuy  = !InpRangeRequireRSI || (rsi1 <= InpRangeRSIBuyMax);
    bool rsiOKSell = !InpRangeRequireRSI || (rsi1 >= InpRangeRSISellMin);

    if(nearSupport && rsiOKBuy && !htfBlocksBuy && !d1BlocksBuy)
    {
      ScoreBreakdown bd; BDReset(bd); double s=0.0;
      if(have1 && atrTF1OK && sup1) s += ScoreRangeCandidate_TF(true,false,adx1,bid,ask,lo1,hi1,edge1,bd);
      if(have2 && atrTF2OK && sup2) s += 0.50*InpScoreRangeWeight;
      if(have3 && atrTF3OK && sup3) s += 0.70*InpScoreRangeWeight;
      bd.htf=ScoreHTF(true,false,htfBull,htfBear,htfOK)*0.5; s+=bd.htf;
      bd.d1 =ScoreD1Trend(true,false,d1Bull,d1Bear,d1OK)*0.7; s+=bd.d1;
      if(s>best.score){ best.name="RANGE_BUY"; best.isBuy=true; best.score=s; best.bd=bd; }
    }

    if(nearResist && rsiOKSell && !htfBlocksSell && !d1BlocksSell)
    {
      ScoreBreakdown bd; BDReset(bd); double s=0.0;
      if(have1 && atrTF1OK && res1) s += ScoreRangeCandidate_TF(false,true,adx1,bid,ask,lo1,hi1,edge1,bd);
      if(have2 && atrTF2OK && res2) s += 0.50*InpScoreRangeWeight;
      if(have3 && atrTF3OK && res3) s += 0.70*InpScoreRangeWeight;
      bd.htf=ScoreHTF(false,true,htfBull,htfBear,htfOK)*0.5; s+=bd.htf;
      bd.d1 =ScoreD1Trend(false,true,d1Bull,d1Bear,d1OK)*0.7; s+=bd.d1;
      if(s>best.score){ best.name="RANGE_SELL"; best.isBuy=false; best.score=s; best.bd=bd; }
    }
  }

  if(allowImpulse && okInd && impOn && !rsiPause)
  {
    bool wantBuy = bull || (fast1>slow1);
    bool wantSell= bear || (fast1<slow1);

    if(wantBuy && !htfBlocksBuy && !d1BlocksBuy)
    {
      ScoreBreakdown bd; double s=ScoreImpulseCandidate(true,impRange,impThr,adx1,adx2,bd);
      bd.htf=ScoreHTF(true,false,htfBull,htfBear,htfOK); s+=bd.htf;
      bd.d1 =ScoreD1Trend(true,false,d1Bull,d1Bear,d1OK); s+=bd.d1;
      if(s>best.score){ best.name="IMPULSE_BUY"; best.isBuy=true; best.score=s; best.bd=bd; }
    }
    if(wantSell && !htfBlocksSell && !d1BlocksSell)
    {
      ScoreBreakdown bd; double s=ScoreImpulseCandidate(true,impRange,impThr,adx1,adx2,bd);
      bd.htf=ScoreHTF(false,true,htfBull,htfBear,htfOK); s+=bd.htf;
      bd.d1 =ScoreD1Trend(false,true,d1Bull,d1Bear,d1OK); s+=bd.d1;
      if(s>best.score){ best.name="IMPULSE_SELL"; best.isBuy=false; best.score=s; best.bd=bd; }
    }
  }

  // Panel update
  if(PanelShouldUpdate(newBar))
  {
    color pc=(canTrade?InpPanelColorOK:InpPanelColorBlocked);
    int cdLeft = (g_postTrailCooldownUntil>TimeCurrent()) ? (int)((g_postTrailCooldownUntil-TimeCurrent())/60) : 0;
    int lossCDLeft = (g_lossCooldownUntil>TimeCurrent()) ? (int)((g_lossCooldownUntil-TimeCurrent())/60) : 0;

    double spP=SpreadPrice();
    double last=(SymbolInfoDouble(_Symbol,SYMBOL_BID)+SymbolInfoDouble(_Symbol,SYMBOL_ASK))*0.5;
    double spPct=(last>0? (spP/last*100.0) : 0.0);

    double tickSize=SymTickSize();
    double tickVal =SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
    double pt=SymPoint();
    int digits=SymDigits();

    int stops=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
    int freeze=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL);

    double vMin=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
    double vMax=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
    double vStep=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);

    double dslR = (oneR>0.0 ? dsl/oneR : 0.0);

    int partialDone=0;
    int manualSLCount=0;
    for(int i=0;i<g_trackedCount;i++)
    {
      if(g_partialClosed[i]) partialDone++;
      if(g_manualSLDetected[i]) manualSLCount++;
    }

    long cm=(long)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_CALC_MODE);
    string cmTxt=CalcModeText(cm);

    int ln=0;
    PanelSetLine(ln++, pc, BOT_NAME+" v1.36");
    PanelSetLine(ln++, InpPanelColorInfo, StringFormat("%s %s | MODE=%s | symMode=%s | calc=%s",
      _Symbol, EnumToString(_Period), EnumToString(InpStrategyMode), symMode, cmTxt));
    PanelSetLine(ln++, InpPanelColorInfo, (StringLen(InpTradeSymbol)>0 ? ("TRADE_SYMBOL="+InpTradeSymbol) : "TRADE_SYMBOL=CHART"));
    if(symWhy!="") PanelSetLine(ln++, InpPanelColorBlocked, symWhy);

    PanelSetLine(ln++, pc, StringFormat("STATUS=%s | WHY=%s", (canTrade?"OK":"BLOCKED"), (blocked==""?"none":blocked)));
    PanelSetLine(ln++, InpPanelColorInfo, StringFormat("ClosedToday=%.2f | Float=%.2f | DayPnL=%.2f | Peak=%.2f",
      todayClosed, MyBasketFloatingUSD_EAOnly(), dayPnl, g_dayPeakPnL));
    PanelSetLine(ln++, InpPanelColorInfo, StringFormat("1R=%.2f | DailySL=%.2fR ($%.2f) | cooldownLeft=%dmin",
      oneR, dslR, dsl, cdLeft));

    PanelSetLine(ln++, InpPanelColorInfo, StringFormat("LOSS GUARD: streak=%d/%d cdLeft=%dmin lastPnL=%.2f at=%s",
      g_lossStreak, InpMaxConsecutiveLosses, lossCDLeft, g_lastClosedPnL,
      (g_lastClosedTime>0?TimeToString(g_lastClosedTime,TIME_MINUTES):"none")));

    {
      string minSLState = (InpUseMinSLDistanceGuard ? StringFormat("ON mult=%.1f", InpMinSLDistance_ATRMult) : "OFF");
      string minSLLast  = (g_lastMinSLWhy!="" ? g_lastMinSLWhy : "OK");
      string minRRState = (InpUseMinRRGuard ? StringFormat("ON min=%.2f tpOnly=%s", InpMinRR, (InpMinRR_DisableTPOnly?"Y":"N")) : "OFF");
      string minRRLast  = (g_lastMinRRWhy!="" ? g_lastMinRRWhy : "OK");
      PanelSetLine(ln++, InpPanelColorInfo, StringFormat("MinSLDist: %s last=%s | MinRR: %s last=%s",
        minSLState, minSLLast, minRRState, minRRLast));
    }

    PanelSetLine(ln++, InpPanelColorInfo, StringFormat("SPREAD: %d pts | %.8f price | %.3f%% | max=%d pts",
      SpreadPoints(), spP, spPct, InpMaxSpreadPoints));
    PanelSetLine(ln++, InpPanelColorInfo, StringFormat("PRICE: digits=%d point=%.8f tick=%.8f tickVal=%.2f",
      digits, pt, tickSize, tickVal));
    PanelSetLine(ln++, InpPanelColorInfo, StringFormat("LEVELS: stops=%dpts(%.8f) freeze=%dpts(%.8f)",
      stops, StopLevelPrice(), freeze, FreezeLevelPrice()));
    PanelSetLine(ln++, InpPanelColorInfo, StringFormat("VOLUME: min=%.2f step=%.2f max=%.2f | capMaxLot=%.2f",
      vMin, vStep, vMax, InpMaxLotPerPosition));

    PanelSetLine(ln++, InpPanelColorInfo, StringFormat("AUTO-TUNE: %s override=%s | eff: conf=%.2f rej=%.2f impRej=%.2f swingBuf=%.2f atrSL=%.2f impDelay=%d",
      g_tuneType, (InpAutoTuneOverrideInputs?"Y":"N"),
      EffConfirmMinBodyATR(), EffRejectWickATR(), EffRejectWickImpulseATR(), EffSwingBufferATR(), EffATRSLMult(), EffImpulseDelayBars()));

    PanelSetLine(ln++, InpPanelColorInfo, StringFormat("POS buy=%d sell=%d | entriesToday=%d/%d | ManualSLdet=%d | partial=%d",
      buysNow, sellsNow, g_entriesToday, InpMaxEntriesPerDay, manualSLCount, partialDone));

    PanelSetLine(ln++, pc, StringFormat("BEST=%s %s score=%.2f (min=%.2f)",
      best.name, (best.isBuy?"BUY":"SELL"), best.score, InpMinScoreToTrade));

    PanelSetLine(ln++, InpPanelColorInfo, StringFormat("LAST ORDER: tries=%d rc=%s(%d) err=%d time=%s",
      g_lastOrderTries, RetcodeText((uint)g_lastOrderRetcode), g_lastOrderRetcode, g_lastOrderErr,
      (g_lastOrderTime>0?TimeToString(g_lastOrderTime,TIME_SECONDS):"none")));

    for(int i=ln;i<PANEL_LINES;i++) PanelSetLine(i, InpPanelColorInfo, "");
    PanelMarkUpdated();
  }

  // =========================
  // Trade only on new bar
  // =========================
  if(!newBar) return;

  if(InpNoOrderSendWhenTradeDisabled && (!connected || !termOK || !mqlOK || !accOK || !symOK))
    return;
  if(!canTrade) return;
  if(!okInd) return;

  if(best.name=="NONE") return;
  if(best.score < InpMinScoreToTrade) return;

  // hedge protection
  if(InpNoHedgeOneSideOnly)
  {
    if(best.isBuy && sellsNow>0) return;
    if(!best.isBuy && buysNow>0) return;
  }

  // per-side limit
  int sideCount = best.isBuy ? buysNow : sellsNow;
  if(sideCount >= InpMaxPositionsPerSide) return;

  if(!MinAddDistanceOK_EAOnly(best.isBuy ? POSITION_TYPE_BUY : POSITION_TYPE_SELL, atr1)) return;

  // confirm candle
  string whyConf="";
  if(!ConfirmEntryCandle(best.isBuy, atr1, fast1, whyConf)) return;

  // range rejection
  if(InpUseRangeRejection && (best.name=="RANGE_BUY" || best.name=="RANGE_SELL"))
  {
    string whyRej="";
    if(!RejectionWickOK(best.isBuy, atr1, EffRejectWickATR(), whyRej)) return;
  }

  // impulse retest + delay
  if(best.name=="IMPULSE_BUY" || best.name=="IMPULSE_SELL")
  {
    int delayBars=EffImpulseDelayBars();
    if(delayBars>0)
    {
      datetime barTime2=iTime(_Symbol,_Period,2);
      if(g_lastImpulseDetectedBarTime!=barTime2) return;
    }

    if(InpUseImpulseRetest)
    {
      string whyImp="";
      if(!RejectionWickOK(best.isBuy, atr1, EffRejectWickImpulseATR(), whyImp)) return;
    }
  }

  // entry/sl/tp
  double entry = best.isBuy ? SymbolInfoDouble(_Symbol,SYMBOL_ASK) : SymbolInfoDouble(_Symbol,SYMBOL_BID);

  double atrSL=0.0;
  if(!BuildSL_ByATR(best.isBuy, entry, atr1, atrSL)) return;

  double sl = ChooseEntrySL(best.isBuy, entry, atr1, atrSL);
  double riskDist=MathAbs(entry-sl);
  if(riskDist<=0) return;

  double tp=0.0;
  if(InpUseTakeProfit)
  {
    if(best.name=="RANGE_BUY" || best.name=="RANGE_SELL")
    {
      if(InpTPRangeToOppositeEdge_TF1 && have1 && atrTF1OK)
      {
        double e=edge1;
        tp = best.isBuy ? (hi1 - e) : (lo1 + e);
      }
      else if(InpTPRangeToMid_TF1 && have1)
      {
        tp = mid1;
      }
    }
    else if(best.name=="TREND_BUY" || best.name=="TREND_SELL")
    {
      tp = best.isBuy ? entry + InpTPTrend_R*riskDist : entry - InpTPTrend_R*riskDist;
    }
    else if(best.name=="IMPULSE_BUY" || best.name=="IMPULSE_SELL")
    {
      tp = best.isBuy ? entry + InpTPImpulse_R*riskDist : entry - InpTPImpulse_R*riskDist;
    }

    if(tp>0)
    {
      if(best.isBuy && tp<=entry) tp=0.0;
      if(!best.isBuy && tp>=entry) tp=0.0;
    }
  }

  // normalize to tick size
  entry = NormalizePrice(entry);
  sl    = NormalizePrice(sl);
  if(tp>0) tp = NormalizePrice(tp);

  // min SL distance guard (NEW v1.36)
  string whyMinSL="";
  if(!MinSLDistanceOK(best.isBuy, entry, sl, atr1, whyMinSL))
  {
    g_lastMinSLWhy=whyMinSL;
    return;
  }
  g_lastMinSLWhy=whyMinSL; // may be "" if guard passed

  // min RR guard (NEW v1.36) — tp may be set to 0 if InpMinRR_DisableTPOnly=true
  string whyMinRR="";
  if(!MinRROK(best.isBuy, entry, sl, tp, whyMinRR))
  {
    g_lastMinRRWhy=whyMinRR;
    return;
  }
  g_lastMinRRWhy=whyMinRR; // may contain info if TP was disabled

  // stops/freeze check
  string whyStops="";
  ENUM_ORDER_TYPE ordType = (best.isBuy ? ORDER_TYPE_BUY : ORDER_TYPE_SELL);
  if(!CanPlaceStopsForEntry(ordType, entry, sl, tp, whyStops))
    return;

  // lots
  double lots=0.0;
  double entryRisk=0.0, sideRisk=0.0, sideCap=0.0;
  bool forced=false;

  if(InpUseRiskLotSizing)
  {
    long sideType = best.isBuy ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
    lots = LotsByRisk_Strict_ForceMin_EAOnly(entry, sl, sideType, entryRisk, sideRisk, sideCap, forced);
    if(lots<=0.0) return;
  }
  else
  {
    lots = NormalizeLots(InpBaseLot + sideCount*InpLotStep);
  }

  // send order (retry)
  MqlTradeRequest req;
  MqlTradeResult  res;
  ZeroMemory(req); ZeroMemory(res);

  req.action    = TRADE_ACTION_DEAL;
  req.symbol    = _Symbol;
  req.magic     = InpMagic;
  req.volume    = lots;
  req.deviation = InpSlippagePoints;
  req.type      = ordType;
  req.price     = entry;
  req.sl        = sl;
  req.tp        = tp;
  req.comment   = BOT_NAME+" "+best.name+" sc="+DoubleToString(best.score,2)+" v1.36";

  ResetLastError();
  bool ok = OrderSendWithRetry(req,res,InpOrderSendMaxTries,InpOrderSendRetryDelayMs);

  g_lastOrderTime=TimeCurrent();
  g_lastOrderRetcode=(int)res.retcode;
  g_lastOrderErr=GetLastError();
  g_lastOrderComment=req.comment;

  if(ok && (res.retcode==TRADE_RETCODE_DONE || res.retcode==TRADE_RETCODE_DONE_PARTIAL))
  {
    g_entriesToday++;
    g_lastActionTime=TimeCurrent();
    SyncTradeLines_EAOnly();
  }
}