//EpicYoshiMaster
//Keep in mind that Cheat Manager Mods aren't compatible with each other.
//If you want to see something else, I'll gladly consider new commands which contribute to this mod's usability.
class Yoshi_ConsoleCommandsPlus_CheatManager_CCP extends Yoshi_ConsoleCommandsPlus_CheatManager_ModIntegration;

var Yoshi_ComboCommands CCs;

var CameraActor SpectatingCamera;
var Hat_GhostPartyPlayer SpectatingPlayer;

const CCPMap = "Yoshi_CCPLevelBitMap";

////
//// All commands below are created for CCP
////

//
//Actors
//

exec function GetNumberOfActors() {
	local int TotalStatic;
	local int TotalDynamic;
	local Actor a;
	foreach AllActors(class'Actor', a) {
		if(a != None) {
			TotalStatic++;
		}
	}

	foreach DynamicActors(class'Actor', a) {
		if(a != None) {
			TotalDynamic++;
		}
	}

	Print("Total Actors: " $ TotalStatic $ "\nTotal Dynamic Actors: " $ TotalDynamic $ "\nTotal Static Actors: " $ (TotalStatic - TotalDynamic));
}

exec function GetNumberOfActorsByClass(String ActorClass) {
	local Actor A;
	local int Num;
	foreach class'WorldInfo'.static.GetWorldInfo().AllActors(class'Actor', A) {
		if(A.isA(Name(ActorClass))) {
			Num++;
		}
	}
	Print("There are" @ Num @ ActorClass @ "actors.");
}

exec function GetNearbyActorsByClass(string ActorClass, optional float Distance = 1000) {
	local Actor a;
	local string s;
	local float dist;

	s = "Nearby Actors of Class " $ ActorClass $ ":\n";

	foreach class'WorldInfo'.static.GetWorldInfo().AllActors(class'Actor', a) {
		if(a.isA(Name(ActorClass))) {

			dist = Abs(VSize(Hat_Player(Outer.Pawn).Location) - VSize(a.Location));

			if(dist <= Distance) {
				s $= a.Name @ "Distance:" @ dist $ "\n";
			}
		}
	}
	Print(s);	
}

exec function GetNearbyVolumes(optional float Distance = 1000) {
	local Volume V;
	local string s;
	s = "Nearby Volumes:\n";
	foreach class'WorldInfo'.static.GetWorldInfo().AllActors(class'Volume', V) {
		if(V != None) {
			if(Abs(VSize(Hat_Player(Outer.Pawn).Location) - VSize(V.Location)) <= Distance) {
				s $= V.Name $ "\n";
			}
		}
	}
	Print(s);
}

exec function GetActorLocationByName(string ActorName) {
	local Actor A;
	foreach class'WorldInfo'.static.GetWorldInfo().AllActors(class'Actor', A) {
		if(A.Name == Name(ActorName)) {
			Print("Location of " $ A.Name $ " is " $ A.Location.X @ A.Location.Y @ A.Location.Z);
			return;
		}
	}
	Print("Actor not found!");
}

exec function GetActorClassLocation(string ActorClass) {
	local Actor A;
	local string CopyString;

	foreach class'WorldInfo'.static.GetWorldInfo().AllActors(class'Actor', A) {
		if(A.isA(Name(ActorClass))) {
			CopyString $= A.Name $ ": (X=" $ A.Location.X $ ", Y=" $ A.Location.Y $ ", Z=" $ A.Location.Z $ ")\n";
			Print(A.Name $ ": " $ A.Location);
		}
	}

	Hat_PlayerController(Pawn.Controller).CopyToClipboard(CopyString);
}

exec function SetActorClassHidden(string ActorClass, bool HiddenState) {
	local Actor A;

	foreach class'WorldInfo'.static.GetWorldInfo().AllActors(class'Actor', A) {
		if(A.isA(Name(ActorClass))) {
			a.SetHidden(HiddenState);
		}
	}
}

//Changes actual sizes
exec function SetDrawScaleClass(string ActorClass, float Size) {
	local Actor a;

	foreach class'WorldInfo'.static.GetWorldInfo().AllActors(class'Actor', a) {
		if(A.isA(Name(ActorClass))) {
			a.CollisionComponent.SetScale(size);
			a.SetDrawScale(size);
			a.SetLocation(a.Location);
		}
	}
}

//Changes positions, but why would you do this
exec function SetLocationScaleClass(string ActorClass, float Size) {
	local Actor a;

	foreach class'WorldInfo'.static.GetWorldInfo().AllActors(class'Actor', a) {
		if(A.isA(Name(ActorClass))) {
			a.SetLocation(a.Location * Size);
		}
	}	
}

exec function KillAllEnemies()
{
	local Hat_Enemy e;

	foreach DynamicActors(class'Hat_Enemy', e)
	{
		e.Died(Outer, None, e.Location);
	}
}

exec function DistBetween(string Actor1, string Actor2) {
	local Actor a, FirstActor, SecondActor;
	
	foreach class'WorldInfo'.static.GetWorldInfo().AllActors(class'Actor', A) {
		if(A.Name == Name(Actor1)) {
			FirstActor = a;
		}
		else if(A.Name == Name(Actor2)) {
			SecondActor = a;
		}
	}

	PrintDistBetween(FirstActor, SecondActor);
}

exec function DistBetweenCoopPlayers() {
	PrintDistBetween(Pawn, Hat_Player(Pawn).GetOtherPlayer());
}

function PrintDistBetween(Actor FirstActor, Actor SecondActor) {
	local float distance, distanceNoZ;
	local Vector firstActorLoc, secondActorLoc;

	if(FirstActor != None && SecondActor != None) {

		firstActorLoc = FirstActor.Location;
		secondActorLoc = SecondActor.Location;

		distance = Abs(VSize(firstActorLoc - secondActorLoc));

		firstActorLoc.Z = 0;
		secondActorLoc.Z = 0;
		distanceNoZ = Abs(VSize(firstActorLoc - secondActorLoc));

		Print("Distance Between: " @ `ShowVar(FirstActor) @ "and" @ `ShowVar(SecondActor) $ "\nDistance:" @ distance $ "\nDistanceNoZ:" @ distanceNoZ);

	}
	else {
		Print("ERROR: All Actors Not Found! " @ `ShowVar(FirstActor) @ `ShowVar(SecondActor));
	}
}

//
//Player Effects
//

exec function SetPos(float x, float y, float z) {
	local Vector Loc;
	local Hat_Player playerPawn;

	Loc.X = x;
	Loc.Y = y;
	Loc.Z = z;
	playerPawn = Hat_Player(Hat_PlayerController(GetALocalPlayerController()).Pawn);
	playerPawn.SetLocation(Loc);
}

exec function GetPos() {
	Print("Player Position: " $ Pawn.Location);
}

exec function SetRot(float Pitch, float Yaw, float Roll) {
	local Rotator NewRot;

	NewRot.Pitch = Pitch;
	NewRot.Yaw = Yaw;
	NewRot.Roll = Roll;
	Pawn.SetRotation(NewRot);
}

exec function GetRot() {
	Print("Player Rotation: " $ Pawn.Rotation);
}

exec function SetHealth(int health) {
	health = FMax(health, 0);
	Pawn.Health = health;
}

exec function SetHidden(bool NewHidden) {
	Pawn.SetHidden(NewHidden);	
}

exec function SetBlinkTime(float Time) {
	Hat_Player(Pawn).BlinkTime = Time;
}

exec function SetGroundSpeed(float Speed) {
	Pawn.GroundSpeed = Speed;
}

exec function SetWaterSpeed(float Speed) {
	Pawn.WaterSpeed = Speed;
}

exec function SetAirSpeed(float Speed) {
	Pawn.AirSpeed = Speed;
}

exec function SetLadderSpeed(float Speed) {
	Pawn.LadderSpeed = Speed;
}

exec function SetAirControl(float NewAirControl) {
	Pawn.AirControl = NewAirControl;
}

exec function SetAccelRate(float AccelerationRate) {
	Pawn.AccelRate = AccelerationRate;
}

exec function SetOutOfWaterZ(float Height) {
	Pawn.OutOfWaterZ = Height;
}

exec function SetAirFriction(float NewFriction) {
	Pawn.AirFriction = NewFriction;
}

exec function SetJumpDiveVelocity(optional float X = 650, optional float Z = 250) {
	Hat_Player(Pawn).JumpDiveVelocity.X = X;
	Hat_Player(Pawn).JumpDiveVelocity.Z = Z;
}

exec function SetWallJumpVelocity(optional float JumpX = 300.0, optional float JumpZ = 450.0) {
	Hat_Player(Pawn).m_vWallSlideJump.X = JumpX;
	Hat_Player(Pawn).m_vWallSlideJump.Z = JumpZ;
}

exec function SetWallSlideVelocity(optional float WallSlideVelocity = 500.f) {
	Hat_Player(Pawn).m_fWallSlideVelocity = WallSlideVelocity;
}

exec function SetWallSlideDistance(optional float WallDistanceInitiate = 40.f, optional float WallDistanceSustain = 120.f) {
	Hat_Player(Pawn).m_fWallDistanceInitiate = WallDistanceInitiate;
	Hat_Player(Pawn).m_fWallDistanceSustain = WallDistanceSustain;
}

exec function DoPlayerTaunt(string TauntName, optional float Duration = 3.f, optional bool PlayerCanExit = false, 
optional float TimeBeforePlayerCanExit = 1.f, optional bool AnyButtonExits = false, optional bool freeze = false) {
	local PlayerTauntInfo Taunt;

	Taunt.TauntName = TauntName;
	Taunt.TauntDuration = Duration;
	Taunt.PlayerCanExit = PlayerCanExit;
	Taunt.TimeBeforePlayerCanExit = TimeBeforePlayerCanExit;
	Taunt.AnyButtonExits = AnyButtonExits;
	Hat_Player(Pawn).Taunt(TauntName,Taunt,freeze);
}

exec function DamagePlayer(int DamageAmount, optional string DamageTypeClass = "Hat_DamageType_Flamethrower") {
	local Hat_Player ply;
	local class TypeOfDamage;
	ply = Hat_Player(Hat_PlayerController(Outer).Pawn);

	TypeOfDamage = class'Hat_ClassHelper'.static.ClassFromName(DamageTypeClass);

	if(ply != None && class<DamageType>(TypeOfDamage) != None) {
		ply.TakeDamage(DamageAmount, Outer, ply.Location, Vect(0,0,0),class<DamageType>(TypeOfDamage));
	}
}

exec function SpeedBoost() {
	GiveStatusEffect("Hat_StatusEffect_SpeedBoost");
}

//
//Physics Effects
//

exec function SetGroundFriction(float NewFriction) {
	local PhysicsVolume PV;
	local WorldInfo wi;
	wi = class'WorldInfo'.static.GetWorldInfo();
	foreach wi.AllActors(class'PhysicsVolume', PV) {
		PV.GroundFriction = NewFriction;
	}
}

exec function SetTerminalVelocity(float NewTerminalVelocity) {
	local PhysicsVolume PV;
	local WorldInfo wi;
	wi = class'WorldInfo'.static.GetWorldInfo();
	foreach wi.AllActors(class'PhysicsVolume', PV) {
		PV.TerminalVelocity = NewTerminalVelocity;
	}
}

exec function SetFluidFriction(float NewFluidFriction) {
	local PhysicsVolume PV;
	local WorldInfo wi;
	wi = class'WorldInfo'.static.GetWorldInfo();
	foreach wi.AllActors(class'PhysicsVolume', PV) {
		PV.FluidFriction = NewFluidFriction;
	}	
}

//
// Online Party
//

exec function ToggleOnlineParty() {
	local bool IsOnline;
	local string LobbyName;

	IsOnline = class'Hat_GhostPartyPlayerStateBase'.static.ConfigGetUseOnlineFunctionality();
	IsOnline = !IsOnline;
	class'Hat_GhostPartyPlayerStateBase'.static.ConfigSetUseOnlineFunctionality(IsOnline);

	if(IsOnline) {
		LobbyName = class'Hat_GhostPartyPlayerStateBase'.static.ConfigGetLobbyName();

		if(LobbyName != "") {
			class'Hat_GhostPartyPlayerStateBase'.static.LobbyJoinByName(LobbyName);
		}
		else {
			class'Hat_GhostPartyPlayerStateBase'.static.LobbyJoinPublic();
		}
	}
	else {
		class'Hat_GhostPartyPlayerStateBase'.static.LobbyExit();
	}
}

exec function SetLobbyName(string LobbyName) {
	class'Hat_GhostPartyPlayerStateBase'.static.ConfigSetLobbyName(LobbyName);

	if(class'Hat_GhostPartyPlayerStateBase'.static.ConfigGetUseOnlineFunctionality()) {
		if(LobbyName != "") {
			class'Hat_GhostPartyPlayerStateBase'.static.LobbyJoinByName(LobbyName);
		}
		else {
			class'Hat_GhostPartyPlayerStateBase'.static.LobbyJoinPublic();
		}
	}
}

exec function Spectate(string PlayerName) {
	local Hat_GhostPartyPlayer gpp;
	local Hat_GhostPartyPlayerState GPPS;
	GPPS = Hat_GhostPartyPlayerState(class'Hat_GhostPartyPlayerState'.static.FindAPlayerStateWithDisplayName(Hat_PlayerController(Pawn.Controller), PlayerName));

	if(GPPS != None) {
		gpp = Hat_GhostPartyPlayer(GPPS.GhostActor);
		StopSpectate();
	
		SpectatingCamera = Pawn.Spawn(class'DynamicCameraActor',,, gpp.CameraLocation[0],gpp.CameraRotation[0],,true);
		gpp.SpectatingCameraActor = SpectatingCamera;
		SpectatingCamera.bIgnoreBaseRotation = true;
		SpectatingCamera.SetHardAttach(true);
		SpectatingCamera.SetBase(gpp);
		Hat_PlayerController(Pawn.Controller).SetViewTarget(SpectatingCamera);
		SpectatingPlayer = gpp;
	}

}

exec function SpectateAny() {
	local Hat_GhostPartyPlayer gpp;
	foreach `GameManager.DynamicActors(class'Hat_GhostPartyPlayer', gpp)
	{
		SpectatingCamera = Pawn.Spawn(class'DynamicCameraActor',,, gpp.CameraLocation[0],gpp.CameraRotation[0],,true);
		gpp.SpectatingCameraActor = SpectatingCamera;
		SpectatingCamera.bIgnoreBaseRotation = true;
		SpectatingCamera.SetHardAttach(true);
		SpectatingCamera.SetBase(gpp);
		Hat_PlayerController(Pawn.Controller).SetViewTarget(SpectatingCamera);
		SpectatingPlayer = gpp;
		break;
	}
}

exec function StopSpectate() {
	if (SpectatingCamera != None) {

		if(SpectatingPlayer != None) {
			SpectatingPlayer.SpectatingCameraActor = None;
		}
			
		Hat_PlayerController(Pawn.Controller).SetViewTarget(Pawn);
		SpectatingCamera.Destroy();
		SpectatingCamera = None;
	}
}

exec function SendOnlinePartyCommand(string ModClass, string Command, optional string Channel = "", optional int SubID = -1, optional string OnlineSteamID = "")
{
    local GameMod inst;
    local Pawn Player1, Player2;
    local Hat_GhostPartyPlayerState OnlinePlayer;
    foreach `GameManager.AllActors(class'GameMod', inst)
    {
        if (locs(String(inst.Class)) == locs(ModClass))
        {
            OnlinePlayer = FindPlayerBySteamID(OnlineSteamID);
            if (SubID == 1 && `GameManager.IsCoop())
            {
                Player2 = class'Hat_PlayerController'.static.GetPlayer2().Pawn;
                inst.SendOnlinePartyCommand(Command, Name(Channel), Player2, OnlinePlayer);
            }
            else if (SubID == 0)
            {
                Player1 = class'Hat_PlayerController'.static.GetPlayer1().Pawn;
                inst.SendOnlinePartyCommand(Command, Name(Channel), Player1, OnlinePlayer);
            }
            else
                inst.SendOnlinePartyCommand(Command, Name(Channel), None, OnlinePlayer);
            return;
        }
    }
}

function Hat_GhostPartyPlayerState FindPlayerBySteamID(string OnlineSteamID)
{
    local Array<Object> PlayerStates;
    local Hat_GhostPartyPlayerState PlayerState;
    local string SteamID;
	local int i;

    if (OnlineSteamID == "")
        return None;
    Hat_PlayerController(Outer).GetGhostPartyPlayerStates(PlayerStates);
    for (i = 0; i < PlayerStates.Length; i++)
    {
        PlayerState = Hat_GhostPartyPlayerState(PlayerStates[i]);
        if (PlayerState != None)
        {
            SteamID = PlayerState.GetNetworkingIDString();
            if (locs(SteamID) == locs(OnlineSteamID))
                return PlayerState;
        }
    }
    return None;
}

//
// Time Pieces
//

exec function PrintTimePieceIDs(int chapter) {
	local string IDs;

	switch(chapter) {
		case 0: IDs = PrintChapterTimePieceInfo(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.hub_spaceship', "Spaceship"); break;
		case 1: IDs = PrintChapterTimePieceInfo(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.MafiaTown', "Mafia Town"); break;
		case 2: IDs = PrintChapterTimePieceInfo(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.trainwreck_of_science', "Battle of the Birds"); break;
		case 3: IDs = PrintChapterTimePieceInfo(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.subconforest', "Subcon Forest"); break;
		case 4: IDs = PrintChapterTimePieceInfo(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.Sand_and_Sails', "Alpine Skyline"); break;
		case 5: IDs = PrintChapterTimePieceInfo(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.Mu_Finale', "Finale"); break;
		case 6: IDs = PrintChapterTimePieceInfo(Hat_ChapterInfo'HatinTime_ChapterInfo_DLC1.ChapterInfos.ChapterInfo_Cruise', "Arctic Cruise"); break;
		case 7: IDs = PrintChapterTimePieceInfo(Hat_ChapterInfo'hatintime_chapterinfo_dlc2.ChapterInfos.ChapterInfo_Metro', "Nyakuza Metro"); break;
		default: IDs = "Invalid Chapter. Enter a chapter 0-7 (0 is Spaceship).";
	}

	Print(IDs);
}

function string PrintChapterTimePieceInfo(Hat_ChapterInfo ci, string ChapterName) {
	local int i;
	local string IDs;
	IDs $= ChapterName $ ": ";
	ci.ConditionalUpdateActList();
	for(i = 0; i < ci.ChapterActInfo.Length; i++) {
		IDs $= "\n" $ (i + 1) $ ". " $ ci.ChapterActInfo[i].Hourglass;
	}
	return IDs;
}

exec function GiveTimePiece(string str) {
	local int isAct;
	if (`SaveManager.SaveData == None) return;

	isAct = CheckForTimePieceStr(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.MafiaTown', str);
	if(isAct == -1) isAct = CheckForTimePieceStr(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.trainwreck_of_science', str);
	if(isAct == -1) isAct = CheckForTimePieceStr(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.subconforest', str);
	if(isAct == -1) isAct = CheckForTimePieceStr(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.Sand_and_Sails', str);
	if(isAct == -1) isAct = CheckForTimePieceStr(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.Mu_Finale', str);
	if(isAct == -1) isAct = CheckForTimePieceStr(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.hub_spaceship', str);
	if(isAct == -1) isAct = CheckForTimePieceStr(Hat_ChapterInfo'HatinTime_ChapterInfo_DLC1.ChapterInfos.ChapterInfo_Cruise', str);
	if(isAct == -1) isAct = CheckForTimePieceStr(Hat_ChapterInfo'hatintime_chapterinfo_dlc2.ChapterInfos.ChapterInfo_Metro', str);

	if(isAct == -1) {
		Print(str $ " is not a valid Time Piece.");
		return;
	}
	else if(isAct == 0) {
		`GameManager.GiveTimePiece(str, false);
	}
	else {
		`GameManager.GiveTimePiece(str, true);
	}
	
	Print("Successfully gave " $ str $ " Time Piece.");
	`SaveManager.SaveToFile(true);
}

exec function RemoveTimePiece(string str) {
	if (`SaveManager.SaveData == None) return;

	if(`GameManager.HasTimePiece(str)) {
		`SaveManager.GetCurrentSaveData().RemoveTimePiece(str);
		Print("Successfully removed " $ str $ " Time Piece.");
		return;
	}
	else {
		Print(str $ " is not a collected Time Piece.");
	}
}

exec function GiveDummyTimePieces(int num) {
	local int i;
	if (`SaveManager.SaveData == None || num <= 0) return;
	for (i = 0; i < num; i++) {

		if(`GameManager.HasTimePiece("debug_timepiece_" $ i)) {
			num++;
		}
		else {
			`GameManager.GiveTimePiece("debug_timepiece_" $ i, false);
		}
	}
		
	`SaveManager.SaveToFile(true);
	Print("File now has " $ num $ " Dummy Time Pieces.");
}

exec function RemoveAllDummyTimePieces() {
	local int i;
	local int num;
	num = 1;
	if (`SaveManager.SaveData == None) return;
	for (i = 0; i < num; i++) {

		if(`GameManager.HasTimePiece("debug_timepiece_" $ i)) {
			num++;
		}
		else {
			`SaveManager.GetCurrentSaveData().RemoveTimePiece("debug_timepiece_" $ i);
		}
	}
	Print("File cleared of Dummy Time Pieces.");
	`SaveManager.SaveToFile(true);
}

//Returns -1 If not found, 0 if found, 1 if found and is an act.
function int CheckForTimePieceStr(Hat_ChapterInfo ci, string str) {
	local int i;

	ci.ConditionalUpdateActList();
	for(i = 0; i < ci.ChapterActInfo.length; i++) {
		if(ci.ChapterActInfo[i].Hourglass == str) {
			if(ci.ChapterActInfo[i].IsBonus) {
				return 0;
			}
			else {
				return 1;
			}

		}
	}
	return -1;
}

//
// Death Wish
//

exec function GiveAllDeathWishStamps() {
	local Array< Class<Object> > AllDeathWishes;
	local int i;
	local int j;
	
	AllDeathWishes = class'Hat_ClassHelper'.static.GetAllScriptClasses("Hat_SnatcherContract_DeathWish");
	for (i = 0; i < AllDeathWishes.Length; i++)
	{
		for(j = 0; j < class<Hat_SnatcherContract_DeathWish>(AllDeathWishes[i]).default.Objectives.Length; j++) {
			class'Hat_SaveBitHelper'.static.AddLevelBit(class<Hat_SnatcherContract_DeathWish>(AllDeathWishes[i]).static.GetObjectiveBitID(), j+1, class<Hat_SnatcherContract_DeathWish>(AllDeathWishes[i]).default.ObjectiveMapName);
		}
	}
}

exec function GiveAllDeathWishStampsForContract(string ContractName) {
	local Array< Class<Object> > AllDeathWishes;
	local int i;
	local int j;
	
	AllDeathWishes = class'Hat_ClassHelper'.static.GetAllScriptClasses("Hat_SnatcherContract_DeathWish");
	for (i = 0; i < AllDeathWishes.Length; i++)
	{
		if(string(class<Hat_SnatcherContract_DeathWish>(AllDeathWishes[i]).default.class) ~= ContractName) {
			for(j = 0; j < class<Hat_SnatcherContract_DeathWish>(AllDeathWishes[i]).default.Objectives.Length; j++) {
				class'Hat_SaveBitHelper'.static.AddLevelBit(class<Hat_SnatcherContract_DeathWish>(AllDeathWishes[i]).static.GetObjectiveBitID(), j+1, class<Hat_SnatcherContract_DeathWish>(AllDeathWishes[i]).default.ObjectiveMapName);
			}
			return;
		}
	}
}

exec function RemoveAllDeathWishStamps() {
	local Array< Class<Object> > AllDeathWishes;
	local int i;
	local int j;
	
	AllDeathWishes = class'Hat_ClassHelper'.static.GetAllScriptClasses("Hat_SnatcherContract_DeathWish");
	for (i = 0; i < AllDeathWishes.Length; i++)
	{
		for(j = 0; j < class<Hat_SnatcherContract_DeathWish>(AllDeathWishes[i]).default.Objectives.Length; j++) {
			class'Hat_SaveBitHelper'.static.RemoveLevelBit(class<Hat_SnatcherContract_DeathWish>(AllDeathWishes[i]).static.GetObjectiveBitID(), j+1, class<Hat_SnatcherContract_DeathWish>(AllDeathWishes[i]).default.ObjectiveMapName);
		}
	}
}

//
//General Collectibles
//

exec function AddPons(int num) {
	`GameManager.AddEnergyBits(num);
}

exec function SetPons(int num) {
	if(`SaveManager.SaveData == None) return;

	`SaveManager.GetCurrentSaveData().MyEnergyBits = num;
}

exec function AddYarn(int num) {
	`GameManager.AddBadgePoints(num);
}

exec function SetYarn(int num) {
	if(`SaveManager.SaveData == None) return;

	`SaveManager.GetCurrentSaveData().MyBadgePoints = num;
}

exec function GiveNextRelic() {
	local int i;
	local Array< class< Hat_Collectible_Decoration > > DecorationPriorities;
	local Hat_PlayerController pc;

	DecorationPriorities.AddItem(class'Hat_Collectible_Decoration_BurgerBottom');
	DecorationPriorities.AddItem(class'Hat_Collectible_Decoration_TrainTracks');
	DecorationPriorities.AddItem(class'Hat_Collectible_Decoration_Train');
	DecorationPriorities.AddItem(class'Hat_Collectible_Decoration_UFO');
	DecorationPriorities.AddItem(class'Hat_Collectible_Decoration_ToyCowA');
	DecorationPriorities.AddItem(class'Hat_Collectible_Decoration_ToyCowB');
	DecorationPriorities.AddItem(class'Hat_Collectible_Decoration_ToyCowC');
	DecorationPriorities.AddItem(class'Hat_Collectible_Decoration_CrayonBox');
	DecorationPriorities.AddItem(class'Hat_Collectible_Decoration_CrayonBlue');
	DecorationPriorities.AddItem(class'Hat_Collectible_Decoration_CrayonGreen');
	DecorationPriorities.AddItem(class'Hat_Collectible_Decoration_CrayonRed');
	DecorationPriorities.AddItem(class'Hat_Collectible_Decoration_GoldNecklace');
	DecorationPriorities.AddItem(class'Hat_Collectible_Decoration_JewelryDisplay');
	DecorationPriorities.AddItem(class'Hat_Collectible_Decoration_CakeA');
	DecorationPriorities.AddItem(class'Hat_Collectible_Decoration_CakeTower');
	DecorationPriorities.AddItem(class'Hat_Collectible_Decoration_CakeB');
	DecorationPriorities.AddItem(class'Hat_Collectible_Decoration_CakeC');

	i = GetDecorationPriorityIndex(class'Engine'.static.GetEngine().GamePlayers[0].Actor.Pawn, DecorationPriorities);
	pc = Hat_PlayerController(class'Hat_PlayerController'.static.GetPlayer1());

	if (i == INDEX_NONE) {
		pc.GetLoadout().AddCollectible(class'Hat_Collectible_RouletteToken', 1);
	}
	else {
		pc.GetLoadOut().AddCollectible(DecorationPriorities[i], 1);
	}
}

function bool IsValidDecoration(int i, Hat_Loadout lo, Array< class< Hat_Collectible_Decoration > > DecorationPriorities)
{
	if (lo.HasCollectible(DecorationPriorities[i], 1, false)) return false;
	
	// Do not reward DLC relics
	if (DecorationPriorities[i].default.RequiredDLC != None && !class'Hat_GameDLCInfo'.static.IsGameDLCInfoInstalled(DecorationPriorities[i].default.RequiredDLC)) return false;
	
	// Do not reward already placed relics
	if (class'Hat_SeqCond_IsDecorationPlaced'.static.GetResult(DecorationPriorities[i], class'WorldInfo'.static.GetWorldInfo().NetMode != NM_Standalone)) return false;
	
	return true;
}

simulated function int GetDecorationPriorityIndex(Actor Collector, Array< class< Hat_Collectible_Decoration > > DecorationPriorities)
{
	local int i;
	local Hat_PlayerController pc;
	local Hat_Loadout lo;
	
	i = 0;
	
	if (Pawn(Collector) != None) Collector = Pawn(Collector).Controller;
	Pc = Hat_PlayerController(Collector);
    if (Pc == None) return INDEX_NONE;
	if (class'WorldInfo'.static.GetWorldInfo().WorldInfo.NetMode != NM_Standalone && Hat_Player(Collector) != None)
		lo = Hat_PlayerReplicationInfo(Hat_Player(Collector).PlayerReplicationInfo).MyLoadout;
	else
		lo = pc.GetLoadout();
	
	while (i < DecorationPriorities.Length && !IsValidDecoration(i, lo, DecorationPriorities))
		i++;
	
	// No more relics to give, give Roulette Tokens instead
	if (i >= DecorationPriorities.Length)
		i = INDEX_NONE;
	
	return i;
}

exec function GiveBadgeSlots() {
	GiveCollectible("Hat_Collectible_BadgeSlot", 1);
	GiveCollectible("Hat_Collectible_BadgeSlot2", 1);
}

exec function UnlockBaseballBat() {
	local Hat_PlayerController pc;

	pc = Hat_PlayerController(Outer);
	if (!pc.GetLoadout().AddBackpack(class'Hat_Loadout'.static.MakeLoadoutItem(InventoryClassFromName("Hat_Weapon_Nyakuza_BaseballBat")), true))
	{
		Print("Unable to add Hat_Weapon_BaseballBat!");
		return;
	}
}

exec function GiveDebugUmbrella() {
	local Hat_PlayerController pc;

	pc = Hat_PlayerController(Outer);
	if (!pc.GetLoadout().AddBackpack(class'Hat_Loadout'.static.MakeLoadoutItem(InventoryClassFromName("Hat_Weapon_Umbrella_Debug")), true))
	{
		Print("Unable to add Hat_Weapon_Umbrella_Debug!");
		return;
	}
}

//
// Cosmetics
//

exec function GiveSingleShades() {
	if(Pawn.FindInventoryType(class'Hat_CosmeticItem_DoubleShades', false) != None) {
		Hat_Pawn(Pawn).RemoveInventory(class'Hat_CosmeticItem_DoubleShades', false);
	}
	Pawn.CreateInventory(class'Hat_CosmeticItem_SingleShades');
}

exec function GiveDoubleShades() {
	if(Pawn.FindInventoryType(class'Hat_CosmeticItem_SingleShades', false) != None) {
		Hat_Pawn(Pawn).RemoveInventory(class'Hat_CosmeticItem_SingleShades', false);
	}
	Pawn.CreateInventory(class'Hat_CosmeticItem_DoubleShades');
}

exec function GiveBaseGameOutfits() {
	AddtoBackPack(class'Hat_Collectible_Skin_BlueYellow');
	AddtoBackPack(class'Hat_Collectible_Skin_GreenGold');
	AddtoBackPack(class'Hat_Collectible_Skin_Minty');
	AddtoBackPack(class'Hat_Collectible_Skin_Freedom');
	AddtoBackPack(class'Hat_Collectible_Skin_MarginOfNight');
	AddtoBackPack(class'Hat_Collectible_Skin_BloodMoon');
	AddtoBackPack(class'Hat_Collectible_Skin_CookieDough');
	AddtoBackPack(class'Hat_Collectible_Skin_Sailor');
	AddtoBackPack(class'Hat_Collectible_Skin_Girly');
	AddtoBackPack(class'Hat_Collectible_Skin_Wahoo');
	AddToBackpack(class'Hat_Collectible_Skin_Black');

	
	AddToBackpack(class'Hat_Ability_Help', class'Hat_CosmeticItemQualityInfo_Help_Ribbon');
	AddToBackpack(class'Hat_Ability_Help', class'Hat_CosmeticItemQualityInfo_Help_Stripes');
	AddToBackpack(class'Hat_Ability_Help', class'Hat_CosmeticItemQualityInfo_Help_Rose');
	AddToBackpack(class'Hat_Ability_Help', class'Hat_CosmeticItemQualityInfo_Help_Completionist');

	AddToBackpack(class'Hat_Ability_Help', class'Hat_CosmeticItemQualityInfo_Help_Gold');

	AddToBackpack(class'Hat_Ability_Sprint', class'Hat_CosmeticItemQualityInfo_Sprint_Ladybug');
	AddToBackpack(class'Hat_Ability_Sprint', class'Hat_CosmeticItemQualityInfo_Sprint_Dino');
	AddToBackpack(class'Hat_Ability_Sprint', class'Hat_CosmeticItemQualityInfo_Sprint_Chicken');
	AddToBackpack(class'Hat_Ability_Sprint', class'Hat_CosmeticItemQualityInfo_Sprint_Thor');

	AddToBackpack(class'Hat_Ability_Chemical', class'Hat_CosmeticItemQualityInfo_Chemical_Pink');	

	AddToBackpack(class'Hat_Ability_StatueFall', class'Hat_CosmeticItemQualityInfo_IceHat_Holiday');
	AddToBackpack(class'Hat_Ability_StatueFall', class'Hat_CosmeticItemQualityInfo_IceHat_CatBeanie');	
	AddToBackpack(class'Hat_Ability_StatueFall', class'Hat_CosmeticItemQualityInfo_IceHat_FuzzyHorn');	
	AddToBackpack(class'Hat_Ability_StatueFall', class'Hat_CosmeticItemQualityInfo_IceHat_SnailHat');	

	AddToBackpack(class'Hat_Ability_FoxMask', class'Hat_CosmeticItemQualityInfo_FoxMask_Cat');	
	AddToBackpack(class'Hat_Ability_FoxMask', class'Hat_CosmeticItemQualityInfo_FoxMask_Bull');	
	AddToBackpack(class'Hat_Ability_FoxMask', class'Hat_CosmeticItemQualityInfo_FoxMask_Bunny');

	AddToBackpack(class'Hat_Ability_TimeStop', class'Hat_CosmeticItemQualityInfo_TimeStop_PandaSquid');		
	AddToBackpack(class'Hat_Ability_TimeStop', class'Hat_CosmeticItemQualityInfo_TimeStop_TinFoil');	
}

exec function GiveDLC1Outfits() {

	AddtoBackPack(class'Hat_Collectible_Skin_Cardboard');
	AddtoBackPack(class'Hat_Collectible_Skin_Detective');
	AddtoBackPack(class'Hat_Collectible_Skin_Parade');
	AddtoBackPack(class'Hat_Collectible_Skin_Hiking');
	AddtoBackPack(class'Hat_Collectible_Skin_Raincoat');
	AddtoBackPack(class'Hat_Collectible_Skin_WitchDress');
	AddtoBackPack(class'Hat_Collectible_Skin_QueenDress_Green');
	AddtoBackPack(class'Hat_Collectible_Skin_HatKid64');
	AddtoBackPack(class'Hat_Collectible_Skin_BodyMaterial_Metal');
	AddtoBackPack(class'Hat_Collectible_Skin_BodyMaterial_Gold');
	AddtoBackPack(class'Hat_Collectible_Skin_BodyMaterial_Space');
	AddtoBackPack(class'Hat_Collectible_Skin_BodyMaterial_Shadow');

	//You're welcome.
	AddToBackpack(class'Hat_Ability_Help', class'Hat_CosmeticItemQualityInfo_Help_Detective');
	AddToBackpack(class'Hat_Ability_Help', class'Hat_CosmeticItemQualityInfo_Help_Parade');

	AddToBackpack(class'Hat_Ability_Sprint', class'Hat_CosmeticItemQualityInfo_Sprint_Ribbon');
	AddToBackpack(class'Hat_Ability_Sprint', class'Hat_CosmeticItemQualityInfo_Sprint_Captain');	

	AddToBackpack(class'Hat_Ability_Chemical', class'Hat_CosmeticItemQualityInfo_Chemical_ChefHat');	

	AddToBackpack(class'Hat_Ability_StatueFall', class'Hat_CosmeticItemQualityInfo_IceHat_Knight');	
}

exec function GiveAllOutfits() {
	GiveBaseGameOutfits();
	GiveDLC1Outfits();
	GiveDLC2Outfits();
}

//This is actually just a subset of what would be in GiveAllOutfits, but it was requested.
exec function GiveAllFlairs() {
	//Base Game
	AddToBackpack(class'Hat_Ability_Help', class'Hat_CosmeticItemQualityInfo_Help_Ribbon');
	AddToBackpack(class'Hat_Ability_Help', class'Hat_CosmeticItemQualityInfo_Help_Stripes');
	AddToBackpack(class'Hat_Ability_Help', class'Hat_CosmeticItemQualityInfo_Help_Rose');
	AddToBackpack(class'Hat_Ability_Help', class'Hat_CosmeticItemQualityInfo_Help_Completionist');
	AddToBackpack(class'Hat_Ability_Help', class'Hat_CosmeticItemQualityInfo_Help_Gold');
	AddToBackpack(class'Hat_Ability_Sprint', class'Hat_CosmeticItemQualityInfo_Sprint_Ladybug');
	AddToBackpack(class'Hat_Ability_Sprint', class'Hat_CosmeticItemQualityInfo_Sprint_Dino');
	AddToBackpack(class'Hat_Ability_Sprint', class'Hat_CosmeticItemQualityInfo_Sprint_Chicken');
	AddToBackpack(class'Hat_Ability_Sprint', class'Hat_CosmeticItemQualityInfo_Sprint_Thor');
	AddToBackpack(class'Hat_Ability_Chemical', class'Hat_CosmeticItemQualityInfo_Chemical_Pink');	
	AddToBackpack(class'Hat_Ability_StatueFall', class'Hat_CosmeticItemQualityInfo_IceHat_Holiday');
	AddToBackpack(class'Hat_Ability_StatueFall', class'Hat_CosmeticItemQualityInfo_IceHat_CatBeanie');	
	AddToBackpack(class'Hat_Ability_StatueFall', class'Hat_CosmeticItemQualityInfo_IceHat_FuzzyHorn');	
	AddToBackpack(class'Hat_Ability_StatueFall', class'Hat_CosmeticItemQualityInfo_IceHat_SnailHat');	
	AddToBackpack(class'Hat_Ability_FoxMask', class'Hat_CosmeticItemQualityInfo_FoxMask_Cat');	
	AddToBackpack(class'Hat_Ability_FoxMask', class'Hat_CosmeticItemQualityInfo_FoxMask_Bull');	
	AddToBackpack(class'Hat_Ability_FoxMask', class'Hat_CosmeticItemQualityInfo_FoxMask_Bunny');
	AddToBackpack(class'Hat_Ability_TimeStop', class'Hat_CosmeticItemQualityInfo_TimeStop_PandaSquid');		
	AddToBackpack(class'Hat_Ability_TimeStop', class'Hat_CosmeticItemQualityInfo_TimeStop_TinFoil');	

	//DLC 1
	//You're welcome.
	AddToBackpack(class'Hat_Ability_Help', class'Hat_CosmeticItemQualityInfo_Help_Detective');
	AddToBackpack(class'Hat_Ability_Help', class'Hat_CosmeticItemQualityInfo_Help_Parade');
	AddToBackpack(class'Hat_Ability_Sprint', class'Hat_CosmeticItemQualityInfo_Sprint_Ribbon');
	AddToBackpack(class'Hat_Ability_Sprint', class'Hat_CosmeticItemQualityInfo_Sprint_Captain');	
	AddToBackpack(class'Hat_Ability_Chemical', class'Hat_CosmeticItemQualityInfo_Chemical_ChefHat');	
	AddToBackpack(class'Hat_Ability_StatueFall', class'Hat_CosmeticItemQualityInfo_IceHat_Knight');	

	//DLC 2
	AddToBackpack(class'Hat_Ability_Chemical', class'Hat_CosmeticItemQualityInfo_Chemical_BurgerCap');
	AddToBackpack(class'Hat_Ability_FoxMask', class'Hat_CosmeticItemQualityInfo_FoxMask_Beret');
	AddToBackpack(class'Hat_Ability_Sprint', class'Hat_CosmeticItemQualityInfo_Sprint_BallCap');
	AddToBackpack(class'Hat_Ability_TimeStop', class'Hat_CosmeticItemQualityInfo_TimeStop_Headphones');
	AddToBackpack(class'Hat_Ability_TimeStop', class'Hat_CosmeticItemQualityInfo_TimeStop_SpaceHelmet');
	AddToBackpack(class'Hat_Ability_TimeStop', class'Hat_CosmeticItemQualityInfo_TimeStop_YeeHaw');
	AddToBackpack(class'Hat_Ability_Chemical', class'Hat_CosmeticItemQualityInfo_Chemical_NyakuzaCatEars');	
}

exec function GiveAllCameraFilters() {
	AddToBackpack(class'Hat_Collectible_CameraFilter_Poster');
	AddToBackpack(class'Hat_Collectible_CameraFilter_Manga');

	AddToBackpack(class'Hat_Collectible_CameraFilter_Kaleidoscope');
	AddToBackpack(class'Hat_Collectible_CameraFilter_PopArt');
	
}

exec function GiveAllRemixes() {
	local int i;
	local Array< class<Object> > RemixClasses;
	local class<Object> Remix;

	RemixClasses = class'Hat_ClassHelper'.static.GetAllScriptClasses("Hat_Collectible_Remix");
	for(i = 0; i < RemixClasses.Length; i++) {
		Remix = RemixClasses[i];
		Hat_PlayerController(Outer).GetLoadout().AddBackpack(class'Hat_Loadout'.static.MakeLoadoutItem(Remix), false);
	}
}

exec function GiveAllStickers() {
	local int i;
	local Array< class<Object> > StickerClasses;
	local class<Object> Sticker;

	StickerClasses = class'Hat_ClassHelper'.static.GetAllScriptClasses("Hat_Collectible_Sticker");
	for(i = 0; i < StickerClasses.Length; i++) {
		Sticker = StickerClasses[i];
		Hat_PlayerController(Outer).GetLoadout().AddBackpack(class'Hat_Loadout'.static.MakeLoadoutItem(Sticker), false);
	}
}

exec function RemoveFromBackpack(class<Object> item, optional class<Hat_CosmeticItemQualityInfo> ItemQualityInfo)
{
	local Hat_PlayerController pc;
	pc = Hat_PlayerController(Outer);
	
	pc.GetLoadout().RemoveBackpack(class'Hat_Loadout'.static.MakeLoadoutItem(item, ItemQualityInfo));
}

//hatintimegamecontent.hatintimeclass -> PackageName.Collectible
exec function RemoveCollectible(string PackageName, string Collectible, optional int Amount = 1) {
	local class<Object> RemoveColl;
	local Hat_PlayerController pc;
	local Hat_SaveGame sg;
	local Hat_CollectibleBackpackItem c;
	local int i;

	pc = Hat_PlayerController(Outer);

	RemoveColl = class'Hat_ClassHelper'.static.ClassFromName(PackageName $ "." $ Collectible);
	if (RemoveColl == None)
	{
		Print("Invalid class: " $ PackageName $ "." $ Collectible);
		return;
	}

	sg = pc.GetLoadout().GetSaveGame();

	for (i = 0; i < sg.MyBackpack2017.Collectibles.Length; i++)
	{
		c = sg.GetCollectible(i);

		if (c.BackpackClass == None) continue;
		if (c.BackpackClass != RemoveColl) continue;
		
		sg.MyBackpack2017.Collectibles[i].Amount = Max(c.Amount - amount,0);

		return;
	}
}

exec function UnlockAbsolutelyEverything() {
	//UnlockEverything and more
	GiveAllTimePieces();
	GiveAllDeathWishStamps();
	GiveAllHats();
	GiveAllBadges();
	UnlockUmbrella();

	//Unlock the cosmetics too!

	GiveAllOutfits();
	GiveAllRemixes();
	UnlockBaseballBat();
	GiveAllCameraFilters();
	GiveAllStickers();
}

//
//Timer Control
//

exec function ResetGameTime() {
	if (`SaveManager.SaveData == None) return;
	class'Hat_GlobalTimer'.static.Restart();
}

exec function ResetActTime() {
	if (`SaveManager.SaveData == None) return;
	class'Hat_GlobalTimer'.static.RestartActTimer();
}

exec function StartTimer() {
	if (`SaveManager.SaveData == None) return;
	class'Hat_GlobalTimer'.static.Start();
}

exec function PauseTimer() {
	if (`SaveManager.SaveData == None) return;
	class'Hat_GlobalTimer'.static.Pause();
}

exec function UnpauseTimer() {
	if (`SaveManager.SaveData == None) return;
	class'Hat_GlobalTimer'.static.Unpause();
}

exec function TimerCredits() {
	if (`SaveManager.SaveData == None) return;
	class'Hat_GlobalTimer'.static.Credits();
}

//
//Level/Act Bit Control
//

exec function ResetAllActBits() {
	local Hat_SaveGame Data;
	local int i;
	if (`SaveManager.SaveData == None) return;
	Data = `SaveManager.GetCurrentSaveData();
	for(i = 0; i < Data.ActBits.Length; i++) {
		Data.ActBits[i].Bits = 0;
	}
}

exec function PrintMapLevelBits(string map) {
	PrintLevelBits2(map);
}

exec function ResetLevelBits() {
	ResetMapLevelBits(class'Hat_SaveBitHelper'.static.GetCorrectedMapFilename());
}

exec function ResetMapLevelBits(string map) {
	local int i,j;
	local Hat_SaveGame SaveData;
	
	SaveData = `SaveManager.GetCurrentSaveData();

	i = SaveData.GetLevelSaveInfoIndex(map);
	if (i < 0)
	{
		Print("Unable to find level bits for: " $ map);
		return;
	}
	if (SaveData.LevelSaveInfo[i].LevelBits.Length <= 0)
	{
		Print("Map has no level bits");
		return;
	}
	
	for (j = 0; j < SaveData.LevelSaveInfo[i].LevelBits.Length; j++)
	{
		SaveData.LevelSaveInfo[i].LevelBits[j].Bits = 0;
	}
}

exec function SetLevelBit(string map, string id, optional int bit = 0) {
	local int i,j;
	local Hat_SaveGame SaveData;
	
	SaveData = `SaveManager.GetCurrentSaveData();

	i = SaveData.GetLevelSaveInfoIndex(map);
	if (i < 0)
	{
		Print("Unable to find level bits for: " $ map);
		return;
	}
	if (SaveData.LevelSaveInfo[i].LevelBits.Length <= 0)
	{
		Print("Map has no level bits");
		return;
	}
	
	for (j = 0; j < SaveData.LevelSaveInfo[i].LevelBits.Length; j++)
	{
		if(SaveData.LevelSaveInfo[i].LevelBits[j].id == id) {
			SaveData.LevelSaveInfo[i].LevelBits[j].Bits = bit;
			return;
		}
	}
	Print("Unable to find level bit " $ id);
}

exec function AddLevelBitMap(string ID, int value, string MapName) {
	class'Hat_SaveBitHelper'.static.AddLevelBit(Id, Value, Mapname);
}

//
//Utilities
//

exec function SetCheckpoint(int checkpoint) {
	`GameManager.SetCurrentCheckpoint(checkpoint, false);
}

exec function SwitchCoopControllers() {
	local Array<Player> GamePlayers;

	GamePlayers = class'Engine'.static.GetEngine().GamePlayers;
	if (GamePlayers.Length != 2) return;

	// SetControllerId handles the swapping
	if (LocalPlayer(GamePlayers[1]).ControllerId >= 0)
		LocalPlayer(GamePlayers[0]).SetControllerId(LocalPlayer(GamePlayers[1]).ControllerId);
	else
		LocalPlayer(GamePlayers[1]).SetControllerId(LocalPlayer(GamePlayers[0]).ControllerId);
}

//0 = Draw, 1 = Conductor, 2 = DJ Grooves
exec function SetBirdAwardWinner(int winner) {
	//Ensures the winner is in the range.
	winner = FMax(winner, 0);
	winner = FMin(winner, 2);
	class'Hat_SeqCond_DeadBirdWinner'.static.SetDeadBirdWinner(winner);
}

exec function GetControllerInfo(optional float delay = 0) {

	if(delay > 0) {
		class'Worldinfo'.static.GetWorldInfo().Game.SetTimer(delay, false, NameOf(PrintControllerInfo), self);
	}
	else {
		PrintControllerInfo();
	}
}

function PrintControllerInfo() {
	local string s;
	local Hat_PlayerInput_Base PIB;
	PIB = Hat_PlayerInput_Base(Hat_PlayerController(Outer).PlayerInput);
	s = "Player: " $ PIB.GetPlayerID();
	s $= "\nGamepad Type: " $ PIB.GetCurrentGamepadType();
	s $= "\nGamepad ID: " $ PIB.GetCurrentGamepadID();
	s $= "\nGamepad Name: " $ PIB.GetGamepadName();
	Print(s);
}

exec function GetWorldStats() {
	local string s;
	local WorldInfo wi;
	wi = class'WorldInfo'.static.GetWorldInfo();
	s $= "Time Dilation: " $ wi.TimeDilation;
	s $= "\nTime Seconds: " $ wi.TimeSeconds;
	s $= "\nReal-Time Seconds: " $ wi.RealTimeSeconds;
	s $= "\nAudio-Time Seconds: " $ wi.AudioTimeSeconds;
	s $= "\nWorldGravityZ: " $ wi.WorldGravityZ;
	s $= "\nDefaultGravityZ: " $ wi.DefaultGravityZ;
	s $= "\nGlobalGravityZ: " $ wi.GlobalGravityZ;
	Print(s);
}

exec function GetBuildNumber() {
	Print("Current Build Number: " $ GetBuildChangelistNumber());
}

exec function PrintVariable(string Object, string VariableName) {
	Print("Value of" @ VariableName @ "for" @ Object $ ":" @ GetVariable(PlayerController(Pawn.Controller), Object, VariableName));
}

static function string GetVariable(PlayerController pc, string Object, string VariableName) {
	local bool reachedValue;
	local string ObjectNum;
	local string ObjectClass;
	local string VariableValue;
	local array<string> arr;
	local Console ViewportConsole;
	local int i;

	reachedValue = false;

	VariableValue = "";
	ViewportConsole = LocalPlayer(pc.Player).ViewportClient.ViewportConsole;
	ObjectNum = GetRightMost(Object);
	ObjectClass = Left(Object, InStr(Object, "_" $ ObjectNum));

	pc.ConsoleCommand("getall" @ ObjectClass @ VariableName, false);

	for(i = ViewportConsole.Scrollback.length - 1; i > -1; i--) {
		if(InStr(ViewportConsole.Scrollback[i], "." $ Object $ ".") > -1) {
			arr = SplitString(ViewportConsole.Scrollback[i], "= ");
			if(arr.length >= 2) {
				VariableValue = arr[1];
			}
		}

		if(InStr(ViewportConsole.Scrollback[i], ")") > -1 && int(Left(ViewportConsole.Scrollback[i], InStr(ViewportConsole.Scrollback[i], ")"))) >= 0) {
			ViewportConsole.Scrollback.Remove(i,1);
			ViewportConsole.SBHead -= 1;
			reachedValue = true;
		}
		else if(reachedValue) {
			break;
		}
	}

	return VariableValue;
}

static function SetVariable(PlayerController pc, string Object, string VariableName, string Value) {
	pc.ConsoleCommand("set" @ Object @ VariableName @ Value, false);
}

exec function PrintAllScriptClasses(string ClassName) {
	local Array< class<Object> > Classes;
	local int i;
	local string ClassString;

	Classes = class'Hat_ClassHelper'.static.GetAllScriptClasses(ClassName);
	for(i = 0; i < Classes.length; i++) {

		if(Classes[i] == None) continue;

		ClassString = string(Classes[i]);
		Print(ClassString);

	}
	Print("Total Classes: " $ Classes.length);
}

exec function PrintAllObjects(String ClassName) {
	local Array<Object> Classes;
	local int i;
	local string ClassString;

	Classes = class'Hat_ClassHelper'.static.GetAllObjectsExpensive(ClassName);
	for(i = 0; i < Classes.length; i++) {
		if(Classes[i] == None) continue;

		ClassString = string(Classes[i]);
		Print(ClassString);

	}
	Print("Total Objects: " $ Classes.length);	
}

exec function PackageExists(string PackageName) {
	local bool IsPackageReal;
	IsPackageReal = class'Hat_ClassHelper'.static.PackageExists(PackageName);
	Print("Package" @ PackageName @ "exists:" @ IsPackageReal);
}

exec function CheckDWIsExcluded() {
	Print("IsExcluded: " $ class'Hat_SnatcherContract_DeathWish'.static.IsExcluded());
}

exec function PrintSoundCueTree(SoundCue Cue) {
	local string SoundCueStr;

	SoundCueStr = "Tree for " $ Cue $ "\n";

	SoundCueStr = RecursiveSoundCueTree(Cue.FirstNode, SoundCueStr, ">");
	Print(SoundCueStr);
}

function string RecursiveSoundCueTree(SoundNode node, string SoundCueStr, string recursiveStr) {
	local SoundNode nextNode;

	SoundCueStr $= recursiveStr @ node $ "\n";

	foreach node.ChildNodes(nextNode) {
		SoundCueStr = RecursiveSoundCueTree(nextNode, SoundCueStr, recursiveStr $ ">");
	}

	return SoundCueStr;
}

exec function GoToBossState(Name StateName, optional Name Label) {
	local Hat_Enemy_Boss boss;

	foreach class'WorldInfo'.static.GetWorldInfo().DynamicActors(class'Hat_Enemy_Boss', boss) {
		if(boss != None && boss.Controller != None) {
			boss.Controller.GoToState(StateName, Label);
		}
	}
}

//Mini Mission
exec function IsMiniMissionActive(Name MiniMissionClass) {
	Print(Hat_GameMissionManager(class'WorldInfo'.static.GetWorldInfo().game).GetMiniMissionByName(MiniMissionClass) != None ? "Mini Mission is Active" : "Mini Mission is Not Active");
}

exec function CompleteMiniMission() {
	local array<Hat_MiniMission> MM;
	local class<Hat_MiniMission> M;
	local int i;
	M = class<Hat_MiniMission>(class'Hat_ClassHelper'.static.ClassFromName("Hat_MiniMission"));

	MM = Hat_GameMissionManager(`GameManager).GetMiniMissions(M, true);
	for(i = 0; i < MM.Length; i++) {
		MM[i].TriggerComplete();
	}

}

exec function FailMiniMission() {
	local array<Hat_MiniMission> MM;
	local class<Hat_MiniMission> M;
	local int i;
	M = class<Hat_MiniMission>(class'Hat_ClassHelper'.static.ClassFromName("Hat_MiniMission"));

	MM = Hat_GameMissionManager(`GameManager).GetMiniMissions(M, true);
	for(i = 0; i < MM.Length; i++) {
		MM[i].TriggerFail();
	}

}

exec function TimerSetTimeLimit(float Time) {
	local Hat_MiniMissionTimeLimit_Base T;
	T = Hat_MiniMissionTimeLimit_Base(Hat_GameMissionManager(class'WorldInfo'.static.GetWorldInfo().game).GetMiniMissionByName('Hat_MiniMissionTimeLimit_Base', true));
	if(T != None) {
		T.SetTimeLimit(Time);
	}		
}

exec function ParadeEnableStagelights() {
	local Hat_MiniMissionParade T;
	T = Hat_MiniMissionParade(Hat_GameMissionManager(class'WorldInfo'.static.GetWorldInfo().game).GetMiniMissionByName('Hat_MiniMissionParade', false));
	if(T != None) {
		T.EnableStagelights();
	}	
}

exec function ParadeEnableFireworks() {
	local Hat_MiniMissionParade T;
	T = Hat_MiniMissionParade(Hat_GameMissionManager(class'WorldInfo'.static.GetWorldInfo().game).GetMiniMissionByName('Hat_MiniMissionParade', false));
	if(T != None) {
		T.EnableRooftopFireworks();
	}		
}

exec function ParadeEndWave() {
	local Hat_MiniMissionParade T;
	T = Hat_MiniMissionParade(Hat_GameMissionManager(class'WorldInfo'.static.GetWorldInfo().game).GetMiniMissionByName('Hat_MiniMissionParade', false));
	if(T != None) {
		T.OnWaveEnd();
	}	
}

exec function MailDeliveryCollect(optional int CollectedNum = 1) {
	local Hat_MiniMissionMailDelivery T;
	local int i;
	T = Hat_MiniMissionMailDelivery(Hat_GameMissionManager(class'WorldInfo'.static.GetWorldInfo().game).GetMiniMissionByName('Hat_MiniMissionMailDelivery', false));
	if(T != None) {
		for(i = 0; i < CollectedNum; i++) {
			T.OnCollectedLetter();
		}
	}	
}

exec function TaskmasterGetTaskCap() {
	local Hat_MiniMissionTaskmaster T;
	T = Hat_MiniMissionTaskMaster(Hat_GameMissionManager(class'WorldInfo'.static.GetWorldInfo().game).GetMiniMissionByName('Hat_MiniMissionTaskMaster', false));
	if(T != None) {
		Print("The Task Cap is currently: " $ T.GetTaskCap());
	}		
}

exec function TaskmasterFailAllTasks() {
	local Hat_MiniMissionTaskmaster T;
	local int i;
	local int ti;
	T = Hat_MiniMissionTaskMaster(Hat_GameMissionManager(class'WorldInfo'.static.GetWorldInfo().game).GetMiniMissionByName('Hat_MiniMissionTaskMaster', false));
	if(T != None) {
		for(i = 0; i < T.ActiveTasks.Length; i++) {
			ti = T.ActiveTasks[i];
			T.CurTask(ti).Fail(ti);
		}
	}		
}

exec function TaskmasterCompleteAllTasks() {
	local Hat_MiniMissionTaskmaster T;
	local int i;
	local int ti;
	T = Hat_MiniMissionTaskMaster(Hat_GameMissionManager(class'WorldInfo'.static.GetWorldInfo().game).GetMiniMissionByName('Hat_MiniMissionTaskMaster', false));
	if(T != None) {
		for(i = 0; i < T.ActiveTasks.Length; i++) {
			ti = T.ActiveTasks[i];
			T.CurTask(ti).Complete(ti);
		}
	}		
}

exec function TaskmasterNewTask(optional bool UntilSpent = false) {
	local Hat_MiniMissionTaskmaster T;
	T = Hat_MiniMissionTaskMaster(Hat_GameMissionManager(class'WorldInfo'.static.GetWorldInfo().game).GetMiniMissionByName('Hat_MiniMissionTaskMaster', false));
	if(T != None) {
		if(UntilSpent) {
			T.StartTasksUntilSpent();
		}
		else {
			T.StartTaskForAllPlayers();
		}
		
	}		
}

exec function TaskmasterGlobalDifficulty(float Difficulty) {
	local Hat_MiniMissionTaskmaster T;
	T = Hat_MiniMissionTaskMaster(Hat_GameMissionManager(class'WorldInfo'.static.GetWorldInfo().game).GetMiniMissionByName('Hat_MiniMissionTaskMaster', false));
	if(T != None) {
		T.GlobalDifficultyMultiplier = Difficulty;
	}	
}

exec function TaskmasterScore(int TasksCompleted) {
	local Hat_MiniMissionTaskmaster T;
	T = Hat_MiniMissionTaskMaster(Hat_GameMissionManager(class'WorldInfo'.static.GetWorldInfo().game).GetMiniMissionByName('Hat_MiniMissionTaskMaster', false));
	if(T != None) {
		T.Score = TasksCompleted;
	}
}

//
//Challenge Roads
//

exec function GetCurrentChallengeRoadID() {
	Print("Current Challenge Road ID: " $ class'GameMod'.static.GetChallengeRoadID());
}

exec function NumberOfChallengeRoadIDs() {
	Print("Number of Challenge Road IDs: " $ Hat_SaveGame(`SaveManager.SaveData).ChallengeRoadIDs.Length);
}

exec function PrintChallengeRoadID(int Index) {
	if(Hat_SaveGame(`SaveManager.SaveData).ChallengeRoadIDs.Length > Index) {
		Print("Challenge Road Index " $ Index $ ": " $ Hat_SaveGame(`SaveManager.SaveData).ChallengeRoadIDs[Index]);
	}
	else {
		Print("Invalid Index!");
	}
}

exec function PrintCRID(int Index) {
	PrintChallengeRoadID(Index);
}

exec function HasChallengeRoadID(string ChallengeRoadID) {
	if(Hat_SaveGame(`SaveManager.SaveData).ChallengeRoadIDs.Find(ChallengeRoadID) != INDEX_NONE) {
		Print("Challenge Road ID " $ ChallengeRoadID $ " found at index " $ Hat_SaveGame(`SaveManager.SaveData).ChallengeRoadIDs.Find(ChallengeRoadID));
	}
	else {
		Print("Challenge Road ID " $ ChallengeRoadID $ " not found.");
	}
}

exec function AddChallengeRoadID(string ChallengeRoadID, optional bool Force = false) {
	if (Hat_SaveGame(`SaveManager.SaveData).ChallengeRoadIDs.Find(ChallengeRoadID) == INDEX_NONE || Force) {
		Hat_SaveGame(`SaveManager.SaveData).ChallengeRoadIDs.AddItem(ChallengeRoadID);
		Print("Added Challenge Road ID " $ ChallengeRoadID $ ". ");
	}
	else {
		Print("Challenge Road ID " $ ChallengeRoadID $ " is already on this file. If you're sure you want to add this ID please set Force to true.");
	}
}

exec function RemoveChallengeRoadID(string ChallengeRoadID) {
	if(Hat_SaveGame(`SaveManager.SaveData).ChallengeRoadIDs.Find(ChallengeRoadID) != INDEX_NONE) {
		Hat_SaveGame(`SaveManager.SaveData).ChallengeRoadIDs.RemoveItem(ChallengeRoadID);
		Print("Removed Challenge Road ID " $ ChallengeRoadID $ ". ");
	}
	else {
		Print("Challenge Road ID " $ ChallengeRoadID $ " not found.");
	}
	
}

//
//Summon Shortcuts
//

//I don't know why you would want this if you can just set your pon counter but hey, we don't judge.
exec function Pon(optional int num = 1) {
	local int i;
	num = FMax(num, 0);
	for(i = 0; i < num; i++) {
		Summon("HatinTimeGameContent.Hat_Collectible_EnergyBit");
	}
}

exec function HealthPon(optional int num = 1) {
	local int i;
	num = FMax(num, 0);
	for(i = 0; i < num; i++) {
		Summon("HatinTimeGameContent.Hat_Collectible_HealthBit_Dynamic");
	}	
}

exec function RiftPon(optional int num = 1) {
	local int i;
	num = FMax(num, 0);
	for(i = 0; i < num; i++) {
		Summon("HatinTimeGameContent.Hat_Collectible_TreasureBit");
	}		
}

exec function PowerPon(optional int num = 1) {
	local int i;
	num = FMax(num, 0);
	for(i = 0; i < num; i++) {
		Summon("HatinTimeGameContent.Hat_Collectible_PowerBit");
	}		
}

exec function StorybookPage(optional int num = 1) {
	local int i;
	num = FMax(num, 0);
	for(i = 0; i < num; i++) {
		Summon("HatinTimeGameContent.Hat_Collectible_StoryBookPage");
	}		
}

exec function MurderClue(optional int num = 1) {
	local int i;
	num = Fmax(num, 0);
	for(i = 0; i < num; i++) {
		Summon("HatinTimeGameContent.Hat_Collectible_MurderClue");
	}		
}

exec function RiftToken(optional int num = 1) {
	local int i;
	num = FMax(num, 0);
	for(i = 0; i < num; i++) {
		Summon("HatinTimeGameContent.Hat_Collectible_RouletteToken");
	}
}

exec function CrabBucket(optional int num = 1) {
	local int i;
	num = Fmax(num, 0);
	for(i = 0; i < num; i++) {
		Summon("HatinTimeGameContent.Hat_CarryObject_CrabBucket");
	}
}

exec function BeachBall(optional int num = 1) {
	local int i;
	num = Fmax(num, 0);
	for(i = 0; i < num; i++) {
		Summon("HatinTimeGameContent.Hat_CarryObject_BeachBall");
	}
}

exec function Cherry(optional int num = 1) {
	local int i;
	num = Fmax(num, 0);
	for(i = 0; i < num; i++) {
		Summon("HatinTimeGameContent.Hat_DwellerFruit");
	}
}

exec function TimePieceShard(optional int num = 1) {
	local int i;
	num = Fmax(num, 0);
	for(i = 0; i < num; i++) {
		Summon("HatinTimeGameContent.Hat_Collectible_TimePieceShard");
	}		
}

//
//HUDs
//

exec function Crosshair() {
	OpenHUD("Hat_HUDElementCrosshair");
}

exec function MountainApproach() {
	OpenHUD("Hat_HUDElementTwilightTitleCard");
}

exec function LocationBannerMetro() {
	OpenHUD("Hat_HUDElementLocationBanner_Metro");
}

exec function MurderClock() {
	OpenHUD("Hat_HUDElementMurderClock");
}

exec function FinaleTicket() {
	OpenHUD("Hat_HUDElementCastleNumberTicket");
}

exec function DisplayMainMenu() {
	OpenHUD("Hat_HUDMenuMainMenu");
}

exec function DisplayCredits() {
	OpenHUD("Hat_HUDMenuEndingCredits");
}

exec function DisplayDeathWishMap() {
	OpenHUD("Hat_HUDMenuDeathWish");
}

//
//Location Shortcuts
//

//Modified version of restartIL which accepts input instead of using the current level.
function CustomRestart(string level, Hat_ChapterInfo chapter, int act, optional Texture2D textureOverride) {
	local string chapterOverride;
	local string actOverride;
	local int chapterIdOverride;

	chapterIdOverride = INDEX_NONE;

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
		// main acts that change map mid-act (and yes I could do this more efficient but it looks nicer like this)
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

	class'Hat_SeqAct_ChangeScene_Act'.static.DoTransitionStatic(level, chapter, act, textureOverride, chapterOverride, actOverride, chapterIdOverride);
	class'Hat_GlobalTimer'.static.RestartActTimer();
}

exec function MafiaBossFight() {
	CustomRestart("mafia_hq", Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.MafiaTown', 4, Texture2D'HatInTime_Titlecards_Ch1.Textures.chapter1_4');
	`GameManager.SetCurrentCheckpoint(2, false);
}

exec function BirdsFight() {
	local Texture2D WinnerTitlecard;
	if(class'Hat_SeqCond_DeadBirdWinner'.static.GetDeadBirdWinner() <= 1) {
		WinnerTitlecard = Texture2D'HatInTime_Titlecards_Ch3.Textures.chapter3_6_conductor';
	}
	else {
		WinnerTitlecard = Texture2D'HatInTime_Titlecards_Ch3.Textures.chapter3_6_dj';
	}
	CustomRestart("djgrooves_boss", Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.trainwreck_of_science', 6, WinnerTitlecard);
}

exec function ToiletFight() {
	CustomRestart("subconforest", Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.subconforest', 3, Texture2D'HatInTime_Titlecards_Ch2.Textures.chapter2_3');
	`GameManager.SetCurrentCheckpoint(1, false);
}

exec function SnatcherFight() {
	CustomRestart("subconforest", Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.subconforest', 6, Texture2D'HatInTime_Titlecards_Ch2.Textures.chapter2_7');
	`GameManager.SetCurrentCheckpoint(1, false);
}

exec function MustacheGirlFight() {
	CustomRestart("castle_mu", Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.Mu_Finale', 1, Texture2D'HatInTime_Titlecards_Ch5.Textures.chapter5_1');
	`GameManager.SetCurrentCheckpoint(8, false);
}

exec function MustacheGirlHyperzone() {
	CustomRestart("castle_mu", Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.Mu_Finale', 1, Texture2D'HatInTime_Titlecards_Ch5.Textures.chapter5_1');
	`GameManager.SetCurrentCheckpoint(10, false);
}

exec function AlpineIntro() {
	CustomRestart("alpsandsails", Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.Sand_and_Sails', 99, Texture2D'HatInTime_Titlecards_Ch4.Textures.Chapter4_1');
}

exec function MetroIntro() {
	CustomRestart("dlc_metro", Hat_ChapterInfo'hatintime_chapterinfo_dlc2.ChapterInfos.ChapterInfo_Metro', 99, Texture2D'HatInTime_Titlecards_Metro.Textures.Metro_FreeRoam');
}

exec function MetroJewelry() {
	
	`GameManager.SoftChangeLevel("dlc_metro");
	class'Hat_GlobalTimer'.static.RestartActTimer();

	class'GameMod'.static.SaveConfigValue(class'Yoshi_ConsoleCommandsPlus_Mod', 'JewelrySpawn', 1);
}

exec function MultiIL(optional int NumberOfILs = 10, optional bool ResetCollectibles = false) {
	ResetGameTime();

	SetMultiILLevelBit("MILCount", 0);
	SetMultiILLevelBit("MILGoal", NumberOfILs);
	SetMultiILLevelBit("MILActive", 1);
	SetMultiILLevelBit("MILResetCollectibles", ResetCollectibles ? 1 : 0);

	if(ResetCollectibles) {
		ResetMapCollectibles();
	}
	
	RestartIL();
}

static function SetMultiILLevelBit(string ID, int Bit) {
	class'Hat_SaveBitHelper'.static.SetLevelBits(ID, Bit, CCPMap);
}

static function int GetMultiILLevelBit(string ID) {
	return class'Hat_SaveBitHelper'.static.GetLevelBits(ID, CCPMap);
}

//
//Combo Commands
//

exec function AddCombo(String ComboName, String ComboCommand) {
	local int i;
	for(i = 0; i < CCs.Combos.Length; i++) {
		if(ComboName == CCs.Combos[i].ComboName) {
			Print("Whoops! There is already a Combo named " $ ComboName $ "!");
			return;
		}
	}

	CCs.Combos.Add(1);
	CCs.Combos[CCs.Combos.Length - 1].ComboName = ComboName;
	CCs.Combos[CCs.Combos.Length - 1].ComboCommand = ComboCommand;
	Print("Added Combo " $ ComboName);
	SaveCombos();
}

exec function ac(String ComboName, String ComboCommand) {
	AddCombo(ComboName, ComboCommand);
}

exec function ComboCommand(String ComboName) {
	local int i;
	local int k;
	local Array<string> CommandParts;
	for(i = 0; i < CCs.Combos.Length; i++) {
		if(ComboName == CCs.Combos[i].ComboName) {
			CommandParts = SplitString(CCs.Combos[i].ComboCommand, "+");
			for(k = 0; k < CommandParts.Length; k++) {
				ConsoleCommand(CommandParts[k]);
			}
			return;
		}
	}
}

exec function cc(String ComboName) {
	ComboCommand(ComboName);
}

exec function ListCombos() {
	local int i;
	local string ComboNames;
	ComboNames $= "Current Registered Combos:\n";
	for(i = 0; i < CCs.Combos.Length; i++) {
		ComboNames $= CCs.Combos[i].ComboName $ "\n";
	}
	Print(ComboNames);
}

exec function lc() {
	ListCombos();
}

exec function RemoveCombo(String ComboName) {
	local int i;
	for(i = 0; i < CCs.Combos.Length; i++) {
		if(ComboName == CCs.Combos[i].ComboName) {
			CCs.Combos.Remove(i,1);
			SaveCombos();
			Print("Combo " $ ComboName $ " was removed.");
			return;
		}
	}
	Print("There is no registered Combo named " $ ComboName);
}

exec function rc(String ComboName) {
	RemoveCombo(ComboName);
}

//
// Extra Command Features
//

exec function SetInitCommand(string Command) {
	CCs.InitCommand = Command;
	Print("Set Initialization Command to " $ Command);
	SaveCombos();
}

exec function RemoveInitCommand() {
	if(CCs.InitCommand != "") {
		CCs.InitCommand = "";
		Print("Removed Initialization Command");
		SaveCombos();
	}
	else {
		Print("No Initialization Command was set!");
	}
}

function SaveCombos() {
	if(!class'Engine'.static.BasicSaveObject(CCs, "ConsoleCommandsPlus/ComboCommands.combos", false, 1))
    {
		Print("Failed to save Combo Commands!");
    }
}

function InitCheatManager() {
	Super.InitCheatManager();

	CCs = new class'Yoshi_ComboCommands';
	class'Engine'.static.BasicLoadObject(CCs, "ConsoleCommandsPlus/ComboCommands.combos", false, 1);
}

function OnPostInitGame() {
	if(CCs == None) return;

	if(CCs.InitCommand != "") {
		ConsoleCommand(CCs.InitCommand);
	}
}

exec function ConsoleCommandsPlus() {
	Print("Looks like someone took the Mod Icon seriously.\nThanks for downloading this mod, you're pretty cool.\nIf you have any suggestions for commands, message me on Discord (EpicYoshiMaster#0693)!");
}
