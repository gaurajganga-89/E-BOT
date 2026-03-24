// The updated content according to the requested changes

// File: UNIFIED_SUPREME_FUSION.mq5

#define EA_VERSION "2.0"
#define EA_TAG ("v"+EA_VERSION)

#property version "2.0"
#property description "USMF MTF v2.0 (MTF+MinSL+MinRR guards)"

string LogPfx(){ return BOT_NAME+" "+EA_TAG+" | "; };

// Update panel header line
panelHeader = BOT_NAME + " " + EA_TAG;

// Update req.comment suffix
req.comment += " " + EA_TAG;

// Prefix existing Print statements
Print(LogPfx() + "Some message");
// Add similar LogPfx() prefixing in CloseAllMyPositions_EAOnly and OnInit init-failed

// Other existing code
