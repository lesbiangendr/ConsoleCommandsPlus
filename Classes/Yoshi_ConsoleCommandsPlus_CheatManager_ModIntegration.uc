//Cheat Managers are now separated to help make maintaining them easier. 
//This class contains all commands dedicated to integrating or relating to other Mods
class Yoshi_ConsoleCommandsPlus_CheatManager_ModIntegration extends Yoshi_ConsoleCommandsPlus_CheatManager_Hat
    abstract;

struct SavePosStruct {
	var Vector Location;
	var Rotator Rotation;
	var Vector Velocity;
	var Vector Acceleration;
	var EHatKidMoveType Physics;
};

struct CarryPosStruct {
	var Hat_CarryObject CarryObject;
	var Actor BaseActor;
	var Vector Location;
	var Rotator Rotation;
	var Vector Velocity;
	Var Vector Acceleration;
};

//Metro Time Piece Reset
struct ActorPosStruct {
	var Name ActorName;
	var Vector Location;
};
var array<ActorPosStruct> MetroTimePieces;

const NumSafeSpots = 10;

//Speedrun Tools vars for SavePos/LoadPos
var SavePosStruct SavedPositions[NumSafeSpots];

var SavePosStruct SavedPlayerCarryPos;
var array<CarryPosStruct> SavedCarryPos;

//Speedrun Tools command integration. Credit to doesthisusername and wooferzfg
exec function SavePos(optional int index = 0) {
	local Hat_Player playerPawn;
	local SavePosStruct NewSavePos;

	if(index < 0 || index >= NumSafeSpots) {
		Print("Invalid index (indices are 0-9)");
	}

	playerPawn = Hat_Player(Hat_PlayerController(GetALocalPlayerController()).Pawn);

	NewSavePos.Location = playerPawn.Location;
	NewSavePos.Rotation = playerPawn.Rotation;
	NewSavePos.Velocity = playerPawn.Velocity;
	NewSavePos.Acceleration = playerPawn.Acceleration;
	NewSavePos.Physics = playerPawn.m_iHatKidMove;

	SavedPositions[index] = NewSavePos;
}

exec function LoadPos(optional int index = 0) {
	local Hat_Player playerPawn;

	if(index < 0 || index >= NumSafeSpots) {
		Print("Invalid index (indices are 0-9)");
	}

	if(SavedPositions[index].Location != vect(0,0,0)) {
		playerPawn = Hat_Player(Hat_PlayerController(GetALocalPlayerController()).Pawn);

		playerPawn.SetLocation(SavedPositions[index].Location);
		playerPawn.SetRotation(SavedPositions[index].Rotation);
		playerPawn.Velocity = SavedPositions[index].Velocity;
		playerPawn.Acceleration = SavedPositions[index].Acceleration;
		playerPawn.m_iHatKidMove = SavedPositions[index].Physics;
	}
}

exec function SaveHover() {
	local Hat_Player playerPawn;
	local SavePosStruct NewSavePos;
	local CarryPosStruct NewCarryObjectPos;
	local Hat_CarryObject obj;

	playerPawn = Hat_Player(Hat_PlayerController(GetALocalPlayerController()).Pawn);

	NewSavePos.Location = playerPawn.Location;
	NewSavePos.Rotation = playerPawn.Rotation;
	NewSavePos.Velocity = playerPawn.Velocity;
	NewSavePos.Acceleration = playerPawn.Acceleration;
	NewSavePos.Physics = playerPawn.m_iHatKidMove;

	SavedPlayerCarryPos = NewSavePos;

	SavedCarryPos.length = 0;

	foreach class'WorldInfo'.static.GetWorldInfo().DynamicActors(class'Hat_CarryObject', obj) {
		if(obj == None) continue;

		NewCarryObjectPos.CarryObject = obj;
		NewCarryObjectPos.Location = obj.Location;
		NewCarryObjectPos.Rotation = obj.Rotation;
		NewCarryObjectPos.Velocity = obj.Velocity;
		NewCarryObjectPos.Acceleration = obj.Acceleration;
		NewCarryObjectPos.BaseActor = obj.Base;

		SavedCarryPos.AddItem(NewCarryObjectPos);
	}
}

exec function LoadHover() {
	local Hat_Player playerPawn;
	local int i;

	if(SavedPlayerCarryPos.Location != vect(0,0,0)) {
		playerPawn = Hat_Player(Hat_PlayerController(GetALocalPlayerController()).Pawn);

		playerPawn.SetLocation(SavedPlayerCarryPos.Location);
		playerPawn.SetRotation(SavedPlayerCarryPos.Rotation);
		playerPawn.Velocity = SavedPlayerCarryPos.Velocity;
		playerPawn.Acceleration = SavedPlayerCarryPos.Acceleration;
		playerPawn.m_iHatKidMove = SavedPlayerCarryPos.Physics;

		for(i = 0; i < SavedCarryPos.length; i++) {
			if(SavedCarryPos[i].CarryObject != None) {
				SavedCarryPos[i].CarryObject.SetLocation(SavedCarryPos[i].Location);
				SavedCarryPos[i].CarryObject.SetRotation(SavedCarryPos[i].Rotation);
				SavedCarryPos[i].CarryObject.Velocity = SavedCarryPos[i].Velocity;
				SavedCarryPos[i].CarryObject.Acceleration = SavedCarryPos[i].Acceleration;
				SavedCarryPos[i].CarryObject.SetBase(SavedCarryPos[i].BaseActor);

			}
		}
	}
}

exec static function StartContract(class<Hat_SnatcherContract_Act> contractClass) {
	local Hat_SaveGame save;
	save = `SaveManager.GetCurrentSaveData();
	save.SnatcherContracts.AddItem(contractClass);
	save.TurnedInSnatcherContracts.RemoveItem(contractClass);
}

exec static function FinishContract(class<Hat_SnatcherContract_Act> contractClass) {
	local Hat_SaveGame save;
	save = `SaveManager.GetCurrentSaveData();
	save.SnatcherContracts.RemoveItem(contractClass);
	save.TurnedInSnatcherContracts.AddItem(contractClass);
}

exec static function RemoveContract(class<Hat_SnatcherContract_Act> contractClass) {
	local Hat_SaveGame save;
	save = `SaveManager.GetCurrentSaveData();
	save.SnatcherContracts.RemoveItem(contractClass);
	save.TurnedInSnatcherContracts.RemoveItem(contractClass);
}

exec static function RemoveAllSnatcherContracts() {
	local Hat_SaveGame save;
	save = `SaveManager.GetCurrentSaveData();
	save.SnatcherContracts.Length = 0;
	save.TurnedInSnatcherContracts.Length = 0;
	save.CompletedSnatcherContracts.Length = 0;
}

exec function ResetMetroTimePieces() {
	local Hat_TimeObject_Base A;
	local int i;

	foreach class'WorldInfo'.static.GetWorldInfo().AllActors(class'Hat_TimeObject_Base', A) {
		for(i = 0; i < MetroTimePieces.length; i++) {
			if(A.Name == MetroTimePieces[i].ActorName) {
				A.SetLocation(MetroTimePieces[i].Location);
			}
		}
	}
}

static exec function RestartIL(optional bool SoftChangeLevel = false) {
	local string level;
	local Hat_ChapterInfo chapter;
	local Hat_ChapterActInfo chapteract;
	local int act;
	local string chapterOverride;
	local string actOverride;
	local Texture2D textureOverride;
	local int chapterIdOverride;
	local bool blockInHub;
	local Yoshi_ConsoleCommandsPlus_Mod GM;
	local WorldInfo wi;
	local class<Hat_SnatcherContract_DeathWish> DW;

	wi = class'WorldInfo'.static.GetWorldInfo();

	level = Hat_GameManager(wi.Game).GetCurrentMapFilename();
	chapter = Hat_GameManager(wi.Game).GetChapterInfo();
	chapteract = Hat_GameManager(wi.Game).GetChapterActInfo();
	act = Hat_GameManager(wi.Game).GetCurrentAct();
	chapterIdOverride = INDEX_NONE;
	blockinHub = true;

	// we don't want it to work in hub (if option set), or titlescreen, or when the game is paused
	if(blockInHub ? level == "hub_spaceship" : false || level == "titlescreen_final" || Hat_PlayerController(class'Hat_PlayerController'.static.GetPlayer1()).IsPaused())
		return;
	
	// We want players to be restarted to the level they actually began in, Metro tries to mess with this.
	if(level == "dlc_metro") {
		GM = class'Yoshi_ConsoleCommandsPlus_Mod'.static.GetGameMod();
		if(GM != None) {
			level = GM.InitialLevel;
			chapter = GM.InitialChapter;
			act = GM.InitialAct;
			class'GameMod'.static.SaveConfigValue(class'Yoshi_ConsoleCommandsPlus_Mod', 'DoubleRestart', 1);
			class'GameMod'.static.SaveConfigValue(class'Yoshi_ConsoleCommandsPlus_Mod', 'ActForRestart', act);
			class'GameMod'.static.SaveConfigValue(class'Yoshi_ConsoleCommandsPlus_Mod', 'ShouldSoftChangeLevel', SoftChangeLevel ? 1 : 0);
		}

		if(class'GameMod'.static.GetConfigValue(class'Yoshi_ConsoleCommandsPlus_Mod', 'DoubleRestart') == 1) {
			class'GameMod'.static.SaveConfigValue(class'Yoshi_ConsoleCommandsPlus_Mod', 'DoubleRestart', 0);
			act = class'GameMod'.static.GetConfigValue(class'Yoshi_ConsoleCommandsPlus_Mod', 'ActForRestart');
			SoftChangeLevel = class'GameMod'.static.GetConfigValue(class'Yoshi_ConsoleCommandsPlus_Mod', 'ShouldSoftChangeLevel') == 1;
		}
	}

	// Override the act names, as they default to the first act name when it's a rift
	// also fix acts that load other maps mid-act
	switch(level) {
		// rifts and alps - names basically
		case "timerift_water_spaceship": actOverride = "The Gallery"; break;
		case "timerift_water_spaceship_mail": actOverride = "The Lab"; break;
		case "timerift_water_mafia_easy": actOverride = "Sewers"; break;
		case "timerift_water_mafia_hard": actOverride = "Bazaar"; break;
		case "timerift_cave_mafia": actOverride = "Mafia of Cooks"; break;
		case "timerift_water_twreck_panels": actOverride = "The Owl Express"; break;
		case "timerift_water_twreck_parade": actOverride = "The Moon"; break;
		case "timerift_cave_deadbird": actOverride = "Dead Bird Studio"; break;
		case "timerift_water_subcon_hookshot": actOverride = "Pipe"; break;
		case "timerift_water_subcon_dwellers": actOverride = "Village"; break;
		case "timerift_cave_raccoon": actOverride = "Sleepy Subcon"; break;
		case "timerift_water_alp_goats": actOverride = "Twilight Bell"; break;
		case "timerift_water_alp_cats": actOverride = "Curly Tail Trail"; break;
		case "timerift_cave_alps": actOverride = "Alpine Skyline"; break;
		case "timerift_cave_aquarium": actOverride = "Deep Sea"; break;
		case "timerift_cave_tour": actOverride = "Tour"; break;
		case "timerift_cave_rumbifactory": actOverride = "Rumbi Factory"; break;

		// main acts that change map mid-act (and yes I could do this more efficient but it looks nicer like this)
		case "mafia_hq": level = "mafia_town_night"; break;
		case "djgrooves_boss": level = "deadbirdstudio"; break;
		case "deadbirdbasement": level = "deadbirdstudio"; break;
		case "subcon_cave": level = "subconforest"; break;
		case "vanessa_manor": level = "subconforest"; break;
		case "ship_sinking": level = "ship_main"; break;
		default: actOverride = ""; break;
	}

	if(actOverride != "") {
		act = 99;
		chapterOverride = "TIME RIFT";
		chapterIdOverride = -2;

		// if the level name starts with timerift_cave_ (0 because that's the index of the string)
		if(InStr(level, "timerift_cave_") == 0) {
			textureOverride = Texture2D'HatinTime_Titlecards_Misc.Textures.TimeRift_Cave';
		}
		// same as above, but timerift_water_
		else if(InStr(level, "timerift_water_") == 0) {
			textureOverride = Texture2D'HatinTime_Titlecards_Misc.Textures.TimeRift_Water';
		}
	}

	if (chapter.ChapterName == "Chapter4_Sand") {
		if (act == 3)
			actOverride = "The Lava Cake";
		else if (act == 6)
			actOverride = "The Birdhouse";
		else if (act == 13)
			actOverride = "The Windmill";
		else if (act == 15)
			actOverride = "The Twilight Bell";
		else if (act == 1 || act == 99)
			actOverride = "Free Roam";
	}

	//By default, level mod restartILs look ugly.
	if(class'GameMod'.static.HasActiveLevelMod()) {
		chapterOverride = chapter != None ? chapter.ChapterName : "A Hat in Time";
		textureOverride = chapter != None ? chapter.Portrait : Texture2D'HatInTime_Titlecards_Ch1.Textures.chapter1_99';
		actOverride = chapteract != None ? chapteract.ActName : "Mod Level";

	}

	//Lets fix up the Death Wish RestartIL too!
	DW = class'Hat_SnatcherContract_DeathWish'.static.GetSingleActiveDeathWish();
	if(DW != None) {
		
	}

	if(level == "hub_spaceship") {

        `GameManager.SoftChangeLevel(level);
    }
    else if(!SoftChangeLevel) {

        class'Hat_SeqAct_ChangeScene_Act'.static.DoTransitionStatic(level, chapter, act, textureOverride, chapterOverride, actOverride, chapterIdOverride);
        class'Hat_GlobalTimer'.static.RestartActTimer();
    }
    else {

        `GameManager.SetCurrentCheckpoint(0, false, false);
        `GameManager.SoftChangeLevel(level, chapter, act);
        class'Hat_GlobalTimer'.static.RestartActTimer();
    }
}

static exec function ResetMapCollectibles() {
	local string chapterName;
	local int actNumber;
	local WorldInfo wi;
	local Array<string> ids;
	local Array<string> maps;

	wi = class'WorldInfo'.static.GetWorldInfo();

	chapterName = Hat_GameManager(wi.Game).GetChapterInfo().ChapterName;
	actNumber = Hat_GameManager(wi.Game).GetCurrentAct();
	maps = GetMapsForChapterAndAct(chapterName, actNumber);

	ids.AddItem("hat_collectible_badgepart");
	ids.AddItem("hat_collectible_decoration_mostsuitable");
	ids.AddItem("hat_collectible_roulettetoken");
	ids.AddItem("hat_treasurechest");
	ids.AddItem("hat_impactinteract_breakable_chemical_crate");
	ids.AddItem("hat_goodie_vault");
	ids.AddItem("hat_eyeblockade");

	RemoveMultipleFlags(ids, maps);
}

exec function SetGoalPos(optional float x = -1, optional float y = -1, optional float z = -1, optional float radius = 150) {
	local Yoshi_ConsoleCommandsPlus_Mod Tool;
	local Hat_Player Kid;

	Kid = Hat_Player(Hat_PlayerController(GetALocalPlayerController()).Pawn);

	foreach DynamicActors(class'Yoshi_ConsoleCommandsPlus_Mod', Tool)
	{
		if(x == -1 && y == -1 && z == -1) {
			Tool.DoneLocation = Kid.Location;
		}
		else {
			Tool.DoneLocation.X = x;
			Tool.DoneLocation.Y = y;
			Tool.DoneLocation.Z = z;
		}
		Tool.DoneRadius = radius;
		break;
	}
}

exec function StartGoalTiming() {
	local Yoshi_ConsoleCommandsPlus_Mod Tool;

	class'Hat_GlobalTimer'.static.Pause();
	class'Hat_GlobalTimer'.static.RestartActTimer();

	foreach DynamicActors(class'Yoshi_ConsoleCommandsPlus_Mod', Tool)
	{
		Tool.JustResetTimer = true;
		break;
	}
}

static function ClearAllContracts() {
	local Hat_SaveGame save;
	save = `SaveManager.GetCurrentSaveData();
	save.SnatcherContracts.Length = 0;
	save.TurnedInSnatcherContracts.Length = 0;
	save.CompletedSnatcherContracts.Length = 0;
}

exec function ResetSnatcherBag() {
	local Array<string> ids;
	local Array<string> maps;

	ClearAllContracts();

	maps.AddItem("subconforest");
	ids.AddItem("contract_unlock_actid");

	RemoveMultipleFlags(ids, maps);	
}

exec function ResetAllWalls() {
	ResetYellowWall();
	ResetBlueWall();
	ResetGreenWall();
}

exec function ResetYellowWall() {
	local Array<string> ids;
	local Array<string> maps;

	maps.AddItem("subconforest");

	ids.AddItem("hat_bonfire_yellow");
	ids.AddItem("hat_subconpainting_yellow");

	RemoveMultipleFlags(ids, maps);
}

exec function ResetBlueWall() {
	local Array<string> ids;
	local Array<string> maps;

	maps.AddItem("subconforest");

	ids.AddItem("hat_subconpainting_blue");
	ids.AddItem("hat_bonfire_blue");

	RemoveMultipleFlags(ids, maps);
}

exec function ResetGreenWall() {
	local Array<string> ids;
	local Array<string> maps;

	maps.AddItem("subconforest");

	ids.AddItem("hat_subconpainting_green");
	ids.AddItem("hat_bonfire_green");

	RemoveMultipleFlags(ids, maps);
}


static function SetFlag(String id, Array<string> maps, int value) {
	local int i;
	for (i = 0; i < maps.Length; i++) {
		class'Hat_SaveBitHelper'.static.SetLevelBits(id, value, maps[i]);
	}
}

static function RemoveFlag(String id, String mapName) {
	local int k;
	local int i;
	local Array<GenericSaveBit> a;
	k = `SaveManager.GetCurrentSaveData().GetLevelSaveInfoIndex(mapName);
	a = `SaveManager.GetCurrentSaveData().LevelSaveInfo[k].LevelBits;
	for (i = 0; i < a.Length; i++) {
		if (InStr(a[i].Id, id) >= 0) {
			`SaveManager.GetCurrentSaveData().LevelSaveInfo[k].LevelBits.RemoveItem(a[i]);
		}
	}
}

static function RemoveMultipleFlags(Array<string> ids, Array<string> maps) {
	local int i;
	local int j;
	for (i = 0; i < maps.Length; i++) {
		for (j = 0; j < ids.Length; j++) {
			RemoveFlag(ids[j], maps[i]);
		}
	}
}

static function Array<string> GetMapsForChapterAndAct(string chapterName, int actNumber) {
	local Array<string> maps;
	maps.Length = 0;

	if (chapterName == "Chapter1_MafiaTown") {
		maps.AddItem("mafia_town");
		if (actNumber == 4)
			maps.AddItem("mafia_hq");
	}
	else if (chapterName == "Chapter2_Subcon") {
		maps.AddItem("subconforest");
		if (actNumber == 2) {
 			maps.AddItem("subcon_cave");
			maps.AddItem("vanessa_manor");
		}
		else if (actNumber == 1 || actNumber == 4)
			maps.AddItem("vanessa_manor");
	}
	else if (chapterName == "Chapter3_Trainwreck") {
		if (actNumber == 1)
			maps.AddItem("deadbirdstudio");
		else if (actNumber == 2)
			maps.AddItem("chapter3_murder");
		else if (actNumber == 3 || actNumber == 5)
			maps.AddItem("themoon");
		else if (actNumber == 4)
			maps.AddItem("trainwreck_selfdestruct");
		else if (actNumber == 6) {
			maps.AddItem("deadbirdstudio");
			maps.AddItem("deadbirdbasement");
			maps.AddItem("djgrooves_boss");
		}
	}
	else if (chapterName == "Chapter4_Sand") {
		maps.AddItem("alpsandsails");
	}
	else if (chapterName == "Chapter5_Finale") {
		maps.AddItem("castle_mu");
	}

	return maps;
}

defaultproperties
{
	MetroTimePieces.Add((ActorName="Hat_TimeObject_Metro_0", Location=(X=3584.0723, Y=2097.1650, Z=-541.8320)));
	MetroTimePieces.Add((ActorName="Hat_TimeObject_Metro_1", Location=(X=-10497.1074, Y=-5466.7563, Z=5488.4463)));
	MetroTimePieces.Add((ActorName="Hat_TimeObject_Metro_3", Location=(X=-5594.9897, Y=-7195.6074, Z=3958.7378)));
	MetroTimePieces.Add((ActorName="Hat_TimeObject_Metro_4", Location=(X=-4516.9146, Y=-1234.9854, Z=3545.3354)));
	MetroTimePieces.Add((ActorName="Hat_TimeObject_Metro_5", Location=(X=-11376.5068, Y=10249.5479, Z=-1134.7566)));
	MetroTimePieces.Add((ActorName="Hat_TimeObject_Metro_6", Location=(X=10847.9141, Y=67494.6875, Z=1560.1387)));
	MetroTimePieces.Add((ActorName="Hat_TimeObject_Metro_7", Location=(X=11703.2646, Y=-8007.0654, Z=-3384.6919)));
	MetroTimePieces.Add((ActorName="Hat_TimeObject_Metro_8", Location=(X=-3836.6724, Y=-5725.0469, Z=672.2197)));
	MetroTimePieces.Add((ActorName="Hat_TimeObject_Metro_9", Location=(X=8177.3760, Y=216.5967, Z=-4586.4219)));
}