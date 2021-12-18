//Created by EpicYoshiMaster
//Keep in mind that Cheat Manager Mods aren't compatible with each other.
//PLEASE consider asking me before making another Cheat Manager, chances are what you want can be added into mine without ruining the compatibility of other mods.
class Yoshi_ConsoleCommandsPlus_Mod extends GameMod;
var config int ConsoleAlwaysEnabled;

const VANESSAS_CURSE_MAP = "1VCMansion";
const TEMPERATURE_CLASH_MAP = "firebattlearena";

var Yoshi_ConsoleCommandsPlus_CheatManager_CCP CM;

//Man I love fake configs
var config int DoubleRestart; //Metro sucks, Free Roam needs to be overridden twice.
var config int ActForRestart; //Self explanatory
var config int ShouldSoftChangeLevel; //0 for no, 1 for yes

var config int JewelrySpawn; //0 for no, 1 for yes

//Variables for proper Metro RestartIL
var string InitialLevel;
var Hat_ChapterInfo InitialChapter;
var int InitialAct;

var Vector DoneLocation;
var float DoneRadius;
var bool JustResetTimer;

event OnModLoaded() {
	if(`GameManager.GetCurrentMapFilename() ~= VANESSAS_CURSE_MAP || `GameManager.GetCurrentMapFilename() ~= TEMPERATURE_CLASH_MAP) return;

	HookActorSpawn(class'Hat_Player', 'Hat_Player');
	SetManager();

	if(`GameManager.GetCurrentMapFilename() ~= `GameManager.HubMapName || `GameManager.GetCurrentMapFilename() ~= `GameManager.TitlescreenMapName) {
		ResetMultiLevel();
	}

	if(DoubleRestart == 1) {
		class'Yoshi_ConsoleCommandsPlus_CheatManager_CCP'.static.RestartIL();
	}

}

event OnHookedActorSpawn(Object NewActor, Name Identifier) {
	if(Identifier == 'Hat_Player') {
		SetManager();
	} 
}



event Tick(float delta) {
	local GameViewportClient GVC;
	local Hat_Player Kid;
	if(`GameManager.GetCurrentMapFilename() ~= VANESSAS_CURSE_MAP || `GameManager.GetCurrentMapFilename() ~= TEMPERATURE_CLASH_MAP) return;

	if(GetMultiBit("MILActive") == 1) TickMultiLevel();

	if(GetALocalPlayerController() == None) return;

	Kid = Hat_Player(Hat_PlayerController(GetALocalPlayerController()).Pawn);

	if(JustResetTimer && VSizeSq(Kid.Velocity) > 10.0f)
	{
		class'Hat_GlobalTimer'.static.Unpause(true);
		JustResetTimer = false;
	}
	
	if(DoneLocation != vect(0,0,0) && Abs(Kid.Location.X - DoneLocation.X) < DoneRadius && Abs(Kid.Location.Y - DoneLocation.Y) < DoneRadius && Abs(Kid.Location.Z - DoneLocation.Z) < DoneRadius)
	{
		class'Hat_GlobalTimer'.static.GotTimePiece();
	}

	//0 is Always Active, 1 is While Open
	if(ConsoleAlwaysEnabled == 0) {
		if(Hat_PlayerController(GetALocalPlayerController()).CheatClass != class'Yoshi_ConsoleCommandsPlus_CheatManager_CCP' || Hat_PlayerController(GetALocalPlayerController()).CheatManager == None) {
			SetManager();
		}
	}
	else if(ConsoleAlwaysEnabled == 1) {
		GVC = class'Engine'.static.GetEngine().GameViewport;
		if(GVC.isConsoleOpen() && Hat_PlayerController(GetALocalPlayerController()).CheatManager == None) {
			SetManager();
		}

		if(!GVC.isConsoleOpen() && Hat_PlayerController(GetALocalPlayerController()).CheatManager != None) {
			Hat_PlayerController(GetALocalPlayerController()).CheatManager = None;
		}
	}
}

event OnModUnloaded() {
	Hat_PlayerController(GetALocalPlayerController()).CheatClass = class'Hat_CheatManager';
}

//2 is Manual
function SetManager() {
	if(`GameManager.GetCurrentMapFilename() ~= VANESSAS_CURSE_MAP || `GameManager.GetCurrentMapFilename() ~= TEMPERATURE_CLASH_MAP) return;
	if(GetALocalPlayerController() == None) return;

	Hat_PlayerController(GetALocalPlayerController()).CheatClass = class'Yoshi_ConsoleCommandsPlus_CheatManager_CCP';
	if(ConsoleAlwaysEnabled == 2) return;
	Hat_PlayerController(GetALocalPlayerController()).CheatManager = new(Hat_PlayerController(GetALocalPlayerController())) class'Yoshi_ConsoleCommandsPlus_CheatManager_CCP';
	CM = Yoshi_ConsoleCommandsPlus_CheatManager_CCP(Hat_PlayerController(GetALocalPlayerController()).CheatManager);
	Hat_PlayerController(GetALocalPlayerController()).CheatManager.InitCheatManager();
}

static final function Print(const string msg)
{
    local WorldInfo wi;
    wi = class'WorldInfo'.static.GetWorldInfo();
    if (wi != None)
    {
        if (wi.GetALocalPlayerController() != None)
            wi.GetALocalPlayerController().TeamMessage(None, msg, 'Event', 6);
        else
            wi.Game.Broadcast(wi, msg);
    }
}
static function Yoshi_ConsoleCommandsPlus_Mod GetGameMod() {
	local Yoshi_ConsoleCommandsPlus_Mod GM;
	foreach class'WorldInfo'.static.GetWorldInfo().DynamicActors(class'Yoshi_ConsoleCommandsPlus_Mod', GM) {
		if(GM != None) {
			return GM;
		}
	}
	GM = None;
	return GM;
}

//
//Extras for Specific Commands
//

//MetroJewelry
function OnPostInitGame() {
	local Hat_PlayerStart HPS;
	local PlayerController PC;
	local Rotator r;

	if(`GameManager.GetCurrentMapFilename() ~= VANESSAS_CURSE_MAP || `GameManager.GetCurrentMapFilename() ~= TEMPERATURE_CLASH_MAP) return;

	if(CM != None) {
		CM.OnPostInitGame();
	}

	InitialLevel = Hat_GameManager(WorldInfo.Game).GetCurrentMapFilename();
	InitialChapter = Hat_GameManager(WorldInfo.Game).GetChapterInfo();
	InitialAct = Hat_GameManager(WorldInfo.Game).GetCurrentAct();

	PC = GetALocalPlayerController();

	if(JewelrySpawn == 1 && InitialLevel ~= "dlc_metro") {
		HPS = GetPlayerStart('Hat_PlayerStart_37');
		if(HPS != None) {
			foreach class'WorldInfo'.static.GetWorldInfo().DynamicActors(class'PlayerController', pc)
			{
				r = HPS.Rotation;
				r.Pitch = 0;
				r.Roll = 0;
			
				pc.Pawn.SetLocation(HPS.Location);
				pc.Pawn.SetRotation(r);
				pc.Pawn.SetCollision(true,true);
				pc.Pawn.bCollideWorld = true;
				r.Pitch = -65536/16;
				pc.SetRotation(r);
			
				if (`GameManager.IsCoop())
					Hat_Player(pc.Pawn).ApplyCoopLocationOffset();
			}
		}
	}
	class'GameMod'.static.SaveConfigValue(self.class, 'JewelrySpawn', 0);
}

function Hat_PlayerStart GetPlayerStart(Name PlayerStartName)
{
	local Hat_PlayerStart hps;
	
	foreach class'WorldInfo'.static.GetWorldInfo().AllActors(class'Hat_PlayerStart', hps)
	{
		if(hps.Name != PlayerStartName) continue;
		return hps;
	}
	
	return None;
}


//MultiIL

//These are redundant but typing so yeah
static function SetMultiBit(string ID, int Bit) {
	class'Yoshi_ConsoleCommandsPlus_CheatManager_CCP'.static.SetMultiILLevelBit(ID, Bit);
}

static function int GetMultiBit(string ID) {
	return class'Yoshi_ConsoleCommandsPlus_CheatManager_CCP'.static.GetMultiILLevelBit(ID);
}

static function ResetMultiLevel() {
	SetMultiBit("MILActive", 0);
	SetMultiBit("MILCount", 0);
	SetMultiBit("MILResetCollectibles", 0);
}

function TickMultiLevel() {
	local Hat_TimeObject_Base TimePiece;

	if(`GameManager.GetCurrentMapFilename() ~= `GameManager.HubMapName || `GameManager.GetCurrentMapFilename() ~= `GameManager.TitlescreenMapName) {
		ResetMultiLevel();
		return;
	}

	foreach DynamicActors(class'Hat_TimeObject_Base', TimePiece) {
        if(TimePiece != None) {
            if(TimePiece.Triggered) {
                class'Hat_GlobalTimer'.static.Pause();
            }
            if(TimePiece.FinalTimePiece) {
                TimePiece.FinalTimePiece = false;
            }
        }
    }
}

function OnTimePieceCollected(string Identifier) {
	local int LevelsCompleted;
	if(`GameManager.GetCurrentMapFilename() ~= VANESSAS_CURSE_MAP || `GameManager.GetCurrentMapFilename() ~= TEMPERATURE_CLASH_MAP) return;

	if(GetMultiBit("MILActive") == 1) {

		LevelsCompleted = GetMultiBit("MILCount");

		LevelsCompleted++;

		if(LevelsCompleted >= GetMultiBit("MILGoal")) {
			class'Hat_GlobalTimer'.static.Credits();
			ResetMultiLevel();
		}
		else {
			SetMultiBit("MILCount", LevelsCompleted);
			
			if(GetMultiBit("MILResetCollectibles") == 1) {
				class'Yoshi_ConsoleCommandsPlus_CheatManager_CCP'.static.ResetMapCollectibles();
			}

			class'Yoshi_ConsoleCommandsPlus_CheatManager_CCP'.static.RestartIL();
		}
	}
}