//Cheat Managers are now separated to help make maintaining them easier. 
//This class contains all base commands contained in Hat_CheatManager in old/new versions
//These are included in this mod to ensure all are unlocked for non-editor final release use.
class Yoshi_ConsoleCommandsPlus_CheatManager_Hat extends Yoshi_ConsoleCommandsPlus_CheatManager_Unreal
    abstract;

var int ChokeGameCount;

//Hat_CheatManager
exec function SetAct(int act)
{
    `GameManager.SetCurrentAct(act);
}

exec function OpenControllerUnpluggedWarn()
{
	Hat_PlayerController(Outer).OpenControllerUnpluggedWarn();
}

exec function CloseControllerUnpluggedWarn()
{
	Hat_PlayerController(Outer).CloseControllerUnpluggedWarn();
}

exec function CamMode()
{
	local bool b;
	local Hat_CamMode CameraMode;
	b = Hat_PlayerController(Outer).InCamMode;
	b = !b;
	Hat_PlayerController(Outer).InCamMode = b;
	
	SetViewTarget(Pawn);
	CameraMode = Hat_PlayerCamera(PlayerCamera).GetCameraModeClass(class'Hat_CamMode_InstantCamera');
	if (CameraMode != None)
	{
		Hat_CamMode_InstantCamera(CameraMode).ForcedCamMode = b;
		Hat_CamMode_InstantCamera(CameraMode).Unbound = b;
	}

    if (b)
    {
        Pawn.SetPhysics(Phys_None);
    }
    else
    {
        Pawn.SetPhysics(Phys_Falling);
    }

    //Pawn.SetHidden(b);

}

exec function CamModeSpeed(float InSpeed)
{
	local Hat_CamMode CameraMode;

	CameraMode = Hat_PlayerCamera(PlayerCamera).GetCameraModeClass(class'Hat_CamMode_InstantCamera');
	if (CameraMode != None)
	{
		Hat_CamMode_InstantCamera(CameraMode).MoveSpeedMultiplier = InSpeed;
	}
}

exec function tposeme()
{
    Pawn.Mesh.SetAnimTreeTemplate(None);
}

exec function GiveKey()
{
    Pawn.CreateInventory(class<Inventory>(InventoryClassFromName("Hat_Inventory_Key")));
}

exec function DoTaunt()
{
    Hat_Player(Pawn).Taunt("taunt");
}

exec function IsTaunting()
{
    Print("IsTaunting: " $ Hat_Player(Pawn).IsTaunting());
}

exec function ItemTaunt()
{
    Hat_Player(Pawn).OnItemObtained();
}

exec function StopTaunt()
{
    Hat_Player(Pawn).EndItemObtained();
    Hat_Player(Pawn).EndTaunt();
}

/* SAVE DATA */
exec function ResetInventory()
{
	local Hat_PlayerController pc;
	local Hat_Loadout l;

    `SaveManager.GetCurrentSaveData().ResetBackpack();

	pc = Hat_PlayerController(Outer);

	l = new class'Hat_Loadout';
	l.PlayerOwner = pc;
	pc.GetLoadout().Copy(l);

	if (Pawn != None)
		Pawn.AddDefaultInventory();
}

exec function AddDefaultInventory()
{
	if (Pawn != None)
		Pawn.AddDefaultInventory();
}

exec function SaveGame()
{
	if (`SaveManager.SaveToFile(true))
	{
		Print("Game successfully saved");
	}
	else
	{
		Print("Error while saving");
	}
}

exec function ResetCheckpoint()
{
	`GameManager.SetCurrentCheckpoint(0, false);
}

/* UNLOCKABLES */

exec function UnlockUmbrella()
{
	local Hat_PlayerController pc;

	pc = Hat_PlayerController(Outer);
	if (!pc.GetLoadout().AddBackpack(class'Hat_Loadout'.static.MakeLoadoutItem(InventoryClassFromName("Hat_Weapon_Umbrella")), true))
	{
		Print("Unable to add Hat_Weapon_Umbrella!");
		return;
	}
}

function bool DoRequiresEditor()
{
	// WorldInfo.NetMode == NM_Standalone is for testing ItemQuality replication
	if (class'Engine'.static.IsUsingSeekFreeLoading() && WorldInfo.NetMode == NM_Standalone)
	{
		Print(class'Hat_Localizer'.static.GetSystem("cheats", "disallowed_outside_editor"));
		return false;
	}
	return true;
}

exec function GiveCosmetic(class<Hat_CosmeticItem> c, optional bool equip = true)
{
	local Hat_PlayerController pc;

	pc = Hat_PlayerController(Outer);
	pc.GetLoadout().AddBackpack(class'Hat_Loadout'.static.MakeLoadoutItem(c), equip);
}

exec function GiveSkin(String CollectibleSkinClass, optional bool equip = true)
{
	local Hat_PlayerController pc;
	local class<Object> c;


	c = class'Hat_ClassHelper'.static.ClassFromName(CollectibleSkinClass);
	if (class<Hat_Collectible_Skin>(c) == None)
	{
		Print("Invalid class: " $ CollectibleSkinClass);
		return;
	}

	pc = Hat_PlayerController(Outer);
	pc.GetLoadout().AddBackpack(class'Hat_Loadout'.static.MakeLoadoutItem(c), equip);
}

simulated function AddToBackpack(class<Actor> i, optional class<Hat_CosmeticItemQualityInfo> ItemQualityInfo)
{
	local Hat_PlayerController pc;
	pc = Hat_PlayerController(Outer);
	
	if (Role != Role_Authority && WorldInfo.NetMode != NM_Standalone)
		Hat_Player(Pawn).ServerAddToBackpack(i, ItemQualityInfo);
	else
		pc.GetLoadout().AddBackpack(class'Hat_Loadout'.static.MakeLoadoutItem(i, ItemQualityInfo), true, ,Hat_Player(Pawn));
}

function GiveCollectible(String str, int amount = 1)
{
	local class<Object> c;
	local Hat_PlayerController pc;
	pc = Hat_PlayerController(Outer);

	c = class'Hat_ClassHelper'.static.ClassFromName(str);
	if (c == None)
	{
		Print("Invalid class: " $ str);
		return;
	}
	
	pc.GetLoadout().AddCollectible(c, amount);
}

function class<Actor> InventoryClassFromName(String str)
{
	return class'Hat_ClassHelper'.static.InventoryClassFromName(str);
}

function class<Object> ClassFromName(String str)
{
	return class'Hat_ClassHelper'.static.ClassFromName(str);
}
function class<Actor> ActorClassFromName(String str)
{
	return class'Hat_ClassHelper'.static.ActorClassFromName(str);
}

exec function StartMusic()
{
	`MusicManager.SetPlaying(true);
}

exec function StopMusic()
{
	`MusicManager.SetPlaying(false);
}

exec function ShowMusic()
{
	OpenHUD("Hat_HUDElementDebugMusic");
}

exec function CriticalHealth()
{
	Pawn.Health = 1;
}

exec function DestroyCPUActors()
{
	`GameManager.DestroyCPUActors();
}

exec function DestroyControllerActors()
{
	`GameManager.DestroyControllerActors();
}

exec function PrintBase()
{
	Print("Base: " $ Pawn.Base);
}

exec function GPHandshake()
{
	local Hat_GhostPartyPlayerState playerstate;
	playerstate = Hat_GhostPartyPlayerState(class'Hat_GhostPartyPlayerStateBase'.static.GetLocalPlayerState(Hat_Player(Pawn).GetPlayerIndex()));
	if (playerstate == None)
	{
		Print("no playerstate");
		return;
	}
	Print("SendLocalActState");
	playerstate.SendLocalActState();
}

exec function GPBotExecCommand(string TargetName, string Command)
{
    local int SubID;
    local Hat_PlayerController PC;
    local Hat_GhostPartyPlayerStateBase Target;

    PC = Hat_PlayerController(Outer);
    SubID = PC.GetPlayerIndex();
    Target = class'Hat_GhostPartyPlayerState'.static.FindAPlayerStateWithDisplayName(PC, TargetName);
    if (Target == None) {
        Print("No such player with name" @ TargetName);
        return;
    }

    class'Hat_GhostPartyPlayerBase'.static.SendBotControl(SubID, Target, "EXEC_COMMAND", Command);
}


exec function GPJoinLobbyAuto()
{
    Print("nope");
}

exec function GCTest()
{
	WorldInfo.ForceGarbageCollection( TRUE );
}

exec function HasLevelIntro()
{
    Print("HasLevelIntro: " $ `GameManager.HasLevelIntro());
}

exec function PrintLoadout()
{
	local Array< Hat_BackpackItem > l;
	local Hat_BackpackItem Inv;
	if (Hat_PlayerController(Outer).MyLoadout == None)
	{
		Print("=No loadout=");
		return;
	}
	l = Hat_PlayerController(Outer).MyLoadout.GetLoadoutList();
	
	Print("=My Loadout=");
	foreach l(Inv)
	{
		Print("Loadout item: " $ inv.BackpackClass);
	}
}

exec function ClearPlayerLoadouts()
{
	`SaveManager.ClearPlayerLoadouts();
}

exec function PrintInventory()
{
	local Inventory Inventory;
	Print("=My Inventory=");
	foreach Pawn.InvManager.InventoryActors(class'Inventory', Inventory)
	{
		Print("Inventory item: " $ Inventory);
	}
}

exec function AddLevelBit(string id, int value)
{
	class'Hat_SaveBitHelper'.static.AddLevelBit(Id, Value);
}

exec function RemoveLevelBit(string id, int value)
{
	class'Hat_SaveBitHelper'.static.RemoveLevelBit(Id, Value);
}

exec function AddActBit(string id, int Value)
{
	class'Hat_SaveBitHelper'.static.AddActBit(Id, Value);
}

exec function RemoveActBit(string id, int Value)
{
	class'Hat_SaveBitHelper'.static.RemoveActBit(Id, Value);
}

exec function HasRainManager()
{
	Print("Has rain manager: " $ (Hat_PlayerController(Pawn.Controller).RainManager != None));
}

exec function StopRainManager()
{
	Hat_PlayerController(Outer).RainManager.CleanUp(true);
	Hat_PlayerController(Outer).RainManager = None;
}

exec function PrintDetailMode()
{
	Print("Detail mode: " $ WorldInfo.GetDetailMode());
}

exec function PrintMapName()
{
	Print("Map: '" $ `GameManager.GetCurrentMapFilename() $ "'");
}

exec function PrintLevelBits()
{
	PrintLevelBits2(class'Hat_SaveBitHelper'.static.GetCorrectedMapFilename());
}

exec function PrintSubconLevelBits()
{
	PrintLevelBits2("subconforest");
}

function PrintLevelBits2(optional string map)
{
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
		Print("(" $ Locs(map) $ ") bit: " $ SaveData.LevelSaveInfo[i].LevelBits[j].Id $ ": " $ SaveData.LevelSaveInfo[i].LevelBits[j].Bits);
	}
}

exec function ShortDrawDistance()
{
	ConsoleCommand("SCALE SET " $ "MaxDrawDistanceScale" $ " " $ "0.01");
}

exec function NormalDrawDistance()
{
	ConsoleCommand("SCALE SET " $ "MaxDrawDistanceScale" $ " " $ "1.0");
}

exec function ResetLevel()
{
	`GameManager.ResetLevel();
}

exec function PrintState()
{
	Print("Physics: " $ Pawn.Physics);
}

exec function StateInfo()
{
	Print("State: " $ GetStateName());
	Print("Physics: " $ Pawn.Physics);
	Print("PhysicsVolume: " $ Pawn.PhysicsVolume);
	Print("m_iHatKidMove: " $ Hat_Player(Pawn).m_iHatKidMove);
	Print("m_iPlatformMove: " $ Hat_Player(Pawn).m_iPlatformMove);
}

exec function enemyfreeze()
{
	WorldInfo.SetPauseEnemies(!WorldInfo.bPauseEnemies);
}

exec function GiveEnergyBits()
{
	`GameManager.AddEnergyBits(1000);
}

exec function DebugLoadingScreen()
{
	OpenHUD("Hat_HUDElementLoadingScreen", "testmap");
}

exec function Turn45Degrees()
{
	local Rotator r;

	r = Pawn.Rotation;
	r.Yaw += 65536/8;
	Pawn.SetRotation(r);
}

exec function CreateLoadingScreen()
{
	class'Hat_GlobalDataInfo'.static.CreateLoadingScreen();
}

exec function ClearPlacedDecorations()
{

	`SaveManager.GetCurrentSaveData().HUBDecorations.Length = 0;
	`SaveManager.SaveToFile();
	ConsoleCommand("RestartLevel");
}

exec function GiveDecorations()
{
	GiveCollectible("Hat_Collectible_Decoration_BurgerBottom", 1);
	GiveCollectible("Hat_Collectible_Decoration_BurgerTop", 1);
	GiveCollectible("Hat_Collectible_Decoration_CrayonBox", 1);
	GiveCollectible("Hat_Collectible_Decoration_CrayonRed", 1);
	GiveCollectible("Hat_Collectible_Decoration_CrayonGreen", 1);
	GiveCollectible("Hat_Collectible_Decoration_CrayonBlue", 1);
	GiveCollectible("Hat_Collectible_Decoration_UFO", 1);
	GiveCollectible("Hat_Collectible_Decoration_ToyCowA", 1);
	GiveCollectible("Hat_Collectible_Decoration_ToyCowB", 1);
	GiveCollectible("Hat_Collectible_Decoration_ToyCowC", 1);
	GiveCollectible("Hat_Collectible_Decoration_Train", 1);
	GiveCollectible("Hat_Collectible_Decoration_TrainTracks", 1);
	GiveCollectible("Hat_Collectible_Decoration_CakeTower", 1);
	GiveCollectible("Hat_Collectible_Decoration_CakeA", 1);
	GiveCollectible("Hat_Collectible_Decoration_CakeB", 1);
	GiveCollectible("Hat_Collectible_Decoration_CakeC", 1);
	GiveCollectible("Hat_Collectible_Decoration_GoldNecklace", 1);
	GiveCollectible("Hat_Collectible_Decoration_JewelryDisplay", 1);
	`SaveManager.SaveToFile();
}

exec function TutorialScene()
{
	local Actor a;
	local Hat_TutorialScene_Base ts;
	
	a = Hat_PlayerController(Outer).InteractionTarget;
	if (!a.IsA('Hat_NPC')) a = None;
	if (a == None) return;

	ts = Hat_TutorialScene_Base(Spawn(ActorClassFromName("Hat_TutorialScene"),,,Pawn.Location, Rotator(Vector(Pawn.Rotation)*vect(1,1,0))));
	ts.DoAppear(a);
}

exec function PrintWorldInfoTime()
{
	Print("Time Seconds: " $ WorldInfo.TimeSeconds);
}

exec function GiveStatusEffect(string StatusEffectClassName, optional float OverrideDuration = -1)
{
	local class EffectClass;

	EffectClass = ClassFromName(StatusEffectClassName);
	Hat_PawnCombat(Pawn).GiveStatusEffect(class<Hat_StatusEffect>(EffectClass), OverrideDuration);
}

exec function TestItemQuality()
{
	local int i, j;
	local Array< class<Object> > ItemQualityClasses;
	local Array< string > HatNames;
	local class<Hat_CosmeticItemQualityInfo> ItemQualityInfo;
	local class<Hat_CosmeticItem> CosmeticItem;
	
	ItemQualityClasses = class'Hat_ClassHelper'.static.GetAllScriptClasses("Hat_CosmeticItemQualityInfo");
	ItemQualityClasses.InsertItem(0,None);
	HatNames.AddItem("Hat_Ability_Help");
	HatNames.AddItem("Hat_Ability_TimeStop");
	HatNames.AddItem("Hat_Ability_FoxMask");
	HatNames.AddItem("Hat_Ability_Chemical");
	HatNames.AddItem("Hat_Ability_StatueFall");
	HatNames.AddItem("Hat_Ability_Sprint");
	

	for (i = 0; i < HatNames.Length; i++)
	{
		CosmeticItem = class<Hat_CosmeticItem>(InventoryClassFromName(HatNames[i]));
		for (j = 0; j < ItemQualityClasses.Length; j++)
		{
			ItemQualityInfo = class<Hat_CosmeticItemQualityInfo>(ItemQualityClasses[j]);
			if (!CosmeticItem.static.SupportsItemQuality(ItemQualityInfo)) continue;
			AddToBackpack(CosmeticItem, ItemQualityInfo);
		}
	}
}

exec function RemoveItemQualities()
{
	local int i, j;
	local Array< class<Object> > ItemQualityClasses;
	local Array< string > HatNames;
	local class<Hat_CosmeticItemQualityInfo> ItemQualityInfo;
	local class<Hat_CosmeticItem> CosmeticItem;
	
	ItemQualityClasses = class'Hat_ClassHelper'.static.GetAllScriptClasses("Hat_CosmeticItemQualityInfo");
	HatNames.AddItem("Hat_Ability_Help");
	HatNames.AddItem("Hat_Ability_TimeStop");
	HatNames.AddItem("Hat_Ability_FoxMask");
	HatNames.AddItem("Hat_Ability_Chemical");
	HatNames.AddItem("Hat_Ability_StatueFall");
	HatNames.AddItem("Hat_Ability_Sprint");
	

	for (i = 0; i < HatNames.Length; i++)
	{
		CosmeticItem = class<Hat_CosmeticItem>(InventoryClassFromName(HatNames[i]));
		for (j = 0; j < ItemQualityClasses.Length; j++)
		{
			ItemQualityInfo = class<Hat_CosmeticItemQualityInfo>(ItemQualityClasses[j]);
			if (!CosmeticItem.static.SupportsItemQuality(ItemQualityInfo)) continue;
			Hat_PlayerController(Outer).GetLoadout().RemoveBackpack(class'Hat_Loadout'.static.MakeLoadoutItem(CosmeticItem, ItemQualityInfo));
		}
	}
}

exec function DizzyExpression()
{
	Hat_Player(Pawn).SetExpression(EExpressionType_Dizzy, 15.0);
}

exec function MischievousExpression()
{
	Hat_Player(Pawn).SetExpression(EExpressionType_Mischievous, 15.0);
	Hat_Player(Pawn).ExpressionComponent.Eyes.ForcedLookVector = vect(0.1,-0.7,0.0);
}

exec function FlinchExpression()
{
	Hat_Player(Pawn).SetExpression(EExpressionType_Flinch, 15.0);
}
exec function FlinchOneEyeExpression()
{
	Hat_Player(Pawn).SetExpression(EExpressionType_Flinch_OneEye, 15.0);
}
exec function NostalgicExpression()
{
	Hat_Player(Pawn).SetExpression(EExpressionType_Nostalgic, 15.0);
}
exec function DeterminedExpression()
{
	Hat_Player(Pawn).SetExpression(EExpressionType_Determined, 15.0);
}

exec function SavePostIntro()
{
	if (`SaveManager.SaveData == None) return;
	
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.MafiaTown', false);
	`GameManager.GiveTimePiece("chapter1_tutorial", true);
	AddToBackpack(InventoryClassFromName("Hat_Ability_Sprint"));
	AddToBackpack(InventoryClassFromName("Hat_Weapon_Umbrella"));
	AddToBackpack(InventoryClassFromName("Hat_CosmeticItem_KidHat"));
	`SaveManager.SaveToFile(true);
}

exec function ClearChapter1()
{
	if (`SaveManager.SaveData == None) return;
	
	`GameManager.GiveTimePiece("chapter1_tutorial", true);
	`GameManager.GiveTimePiece("chapter1_barrelboss", true);
	`GameManager.GiveTimePiece("chapter1_cannon_repair", true);
	`GameManager.GiveTimePiece("chapter1_boss", true);
	AddToBackpack(InventoryClassFromName("Hat_Ability_Sprint"));
	AddToBackpack(InventoryClassFromName("Hat_Weapon_Umbrella"));
	AddToBackpack(InventoryClassFromName("Hat_CosmeticItem_KidHat"));
	`SaveManager.SaveToFile(true);
}

exec function ClearChapter1Fully()
{
	if (`SaveManager.SaveData == None) return;
	
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.MafiaTown', true);
	`SaveManager.SaveToFile(true);
}


exec function Give15TimePieces()
{
	local int i;
	if (`SaveManager.SaveData == None) return;
	
	`GameManager.GiveTimePiece("chapter1_tutorial", true);
	for (i = 0; i < 14; i++)
		`GameManager.GiveTimePiece("debug_timepiece_" $ i, false);
	`SaveManager.SaveToFile(true);
}

exec function Hat_HUDElement OpenHUD(string HudClassName, optional string Command)
{
	local class HudClass;
	
	HudClass = class'Hat_ClassHelper'.static.ClassFromName(HudClassName);
	return Hat_HUD(MyHUD).OpenHUD(class<Hat_HUDElement>(HudClass), Command);
}

exec function Gamble()
{
	OpenHUD("Hat_HUDMenuTimeRiftRoulette");
}

exec function GiveContract(string ContractClassName)
{
	local class ContractClass;
	ContractClass = ClassFromName(ContractClassName);
	if (ContractClass == None)
	{
		Print("Invalid contract class: " $ ContractClassName);
		return;
	}
	`SaveManager.GetCurrentSaveData().GiveContract(class<Hat_SnatcherContract_Act>(ContractClass), Outer);
}

exec function GiveAllContracts()
{
	GiveContract("Hat_SnatcherContract_IceWall");
	GiveContract("Hat_SnatcherContract_Vanessa");
	GiveContract("Hat_SnatcherContract_Bonfires");
	GiveContract("Hat_SnatcherContract_MailDelivery");
	GiveContract("Hat_SnatcherContract_Toilet");
}

exec function PrintContracts()
{
	local Hat_SaveGame sg;
	local int i;
	
	sg = `SaveManager.GetCurrentSaveData();
	
	for (i = 0; i < sg.SnatcherContracts.Length; i++)
	{
		Print(string(sg.SnatcherContracts[i]));
	}
}

exec function RemoveAllContracts()
{
	local Hat_SaveGame sg;
	local int i;
	local Array< class<Object> > AllDeathWishes;

	sg = `SaveManager.GetCurrentSaveData();
	for (i = 0; i < sg.SnatcherContracts.Length; i++)
	{
		sg.SnatcherContracts[i].static.DebugResetObjectives();
	}
	for (i = 0; i < sg.CompletedSnatcherContracts.Length; i++)
	{
		sg.CompletedSnatcherContracts[i].static.DebugResetObjectives();
	}
	for (i = 0; i < sg.TurnedInSnatcherContracts.Length; i++)
	{
		sg.TurnedInSnatcherContracts[i].static.DebugResetObjectives();
	}
	AllDeathWishes = class'Hat_ClassHelper'.static.GetAllScriptClasses("Hat_SnatcherContract_DeathWish");
	for (i = 0; i < AllDeathWishes.Length; i++)
	{
		class<Hat_SnatcherContract_DeathWish>(AllDeathWishes[i]).static.DebugResetObjectives();
	}
	sg.SnatcherContracts.Length = 0;
	sg.CompletedSnatcherContracts.Length = 0;
	sg.TurnedInSnatcherContracts.Length = 0;
}

exec function SpawnScooter()
{
	Spawn(ActorClassFromName("Hat_VehicleScooter"),,, Pawn.Location + vect(0,0,1)*300, Pawn.Rotation);
}

exec function ResetTimeRiftDetection()
{
	
	ResetTimeRiftDetection2("secretlevel_demo_07");
	ResetTimeRiftDetection2("secretlevel_demo_05");
	ResetTimeRiftDetection2("cavedream_introdream");
	ResetTimeRiftDetection2("cavedream_sleepyraccoon");
	
	`SaveManager.GetCurrentSaveData().RemoveTimePiece("secretlevel_demo_07");
	`SaveManager.GetCurrentSaveData().RemoveTimePiece("secretlevel_demo_05");
	`SaveManager.GetCurrentSaveData().RemoveTimePiece("cavedream_introdream");
	`SaveManager.GetCurrentSaveData().RemoveTimePiece("cavedream_sleepyraccoon");
}

function ResetTimeRiftDetection2(string hourglass)
{
	class'Hat_SaveBitHelper'.static.RemoveLevelBit("ActSelectAnimation_Unlock_" $ hourglass, 1, "hub_spaceship");
}

exec function LookAtCamera()
{
	Hat_Player(Pawn).ExpressionComponent.ForcedViewTarget = PlayerCamera;
	Hat_Player(Pawn).ExpressionComponent.UpdateEyes(0);
}

exec function CycleExpression()
{
	if (ExpressionTestIndex == 3)
		Hat_Player(Pawn).SetExpression(EExpressionType_Dizzy, 25);
	else if (ExpressionTestIndex == 2)
		Hat_Player(Pawn).SetExpression(EExpressionType_Confused, 25);
	else if (ExpressionTestIndex == 1)
		Hat_Player(Pawn).SetExpression(EExpressionType_Stretching, 25);
	else
		Hat_Player(Pawn).SetExpression(EExpressionType_Sleepy, 25);
	
	ExpressionTestIndex++;
	ExpressionTestIndex = ExpressionTestIndex % 4;
}

exec function HurtAllEnemies()
{
	local Hat_Enemy e;
	local class DamageTypeClass;

	DamageTypeClass = ClassFromName("Hat_DamageType_UmbrellaSlash");

	foreach DynamicActors(class'Hat_Enemy', e)
	{
		e.TakeDamage(1, Outer, e.Location, vect(0,0,0), class<DamageType>(DamageTypeClass),, Pawn);
	}
}

exec function StartIdiotBot(optional int SimulationSpeed = 1)
{
	local Hat_IdiotBot ib;

	ib = Hat_IdiotBot(Spawn(ActorClassFromName("Hat_IdiotBot")));
	ib.Init(Outer);
	if (SimulationSpeed > 1)
		Slomo(Min(SimulationSpeed, 4));
}

exec function MuMission()
{
	local Hat_HUDElementLoadingScreen_Base ls;
	ls = Hat_HUDElementLoadingScreen_Base(OpenHUD("Hat_HUDElementLoadingScreen", "mafia_town"));
	ls.TransitionToMuMission = true;
}

exec function MusicSpeed(float speed)
{
	`MusicManager.MusicTreeInstance.PitchMultiplier = FMin(speed,2);
}

exec function UnlockEverything()
{
	GiveAllTimePieces();
	GiveAllHats();
	GiveAllBadges();
	UnlockUmbrella();
	SaveGame();
}

exec function UnlockEverythingBaseGameOnly()
{
	GiveAllTimePieces(false);
	GiveAllHats();
	GiveAllBadges();
	UnlockUmbrella();
	SaveGame();
}

exec function UnlockEverythingExceptAlpineRifts()
{
	GiveAllTimePieces(false);
	`SaveManager.GetCurrentSaveData().RemoveTimePiece("TimeRift_Cave_Alps");
	`SaveManager.GetCurrentSaveData().RemoveTimePiece("TimeRift_Water_AlpineSkyline_Cats");
	`SaveManager.GetCurrentSaveData().RemoveTimePiece("TimeRift_Water_Alp_Goats");
	SaveGame();
}

exec function GiveAllTimePieces(optional bool DLCIncluded = true)
{
	if (`SaveManager.SaveData == None) return;
	
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.MafiaTown', true,false,DLCIncluded);
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.subconforest', true,false,DLCIncluded);
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.trainwreck_of_science', true,false,DLCIncluded);
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.Sand_and_Sails', true,false,DLCIncluded);
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.Mu_Finale', true,false,DLCIncluded);
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.hub_spaceship', true,false,DLCIncluded);
	if (DLCIncluded)
	{
		UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo_DLC1.ChapterInfos.ChapterInfo_Cruise', true);
		UnlockEverythingChapter(Hat_ChapterInfo'hatintime_chapterinfo_dlc2.ChapterInfos.ChapterInfo_Metro', true);
	}
	`SaveManager.SaveToFile(true);
}

function UnlockEverythingChapter(Hat_ChapterInfo ci, bool Unlock, optional bool PowerPanelOnly, optional bool DLCIncluded = true, optional bool TimeRiftsIncluded = true)
{
	local int i;
	if (!PowerPanelOnly)
	{
		ci.ConditionalUpdateActList();
		for (i = 0; i < ci.ChapterActInfo.Length; i++)
		{
			if (ci.ChapterActInfo[i].IsBonus && !TimeRiftsIncluded) continue;			
			if (ci.ChapterActInfo[i].RequiredDLC != None && !DLCIncluded) continue;			
			if (Unlock)
			{
				`GameManager.GiveTimePiece(ci.ChapterActInfo[i].Hourglass, true);
				if (ci.ChapterActInfo[i].HourglassUncanny != "")
				{
					`GameManager.GiveTimePiece(ci.ChapterActInfo[i].HourglassUncanny, true);
				}
			}
			else
			{
				`SaveManager.GetCurrentSaveData().RemoveTimePiece(ci.ChapterActInfo[i].Hourglass);
				if (ci.ChapterActInfo[i].HourglassUncanny != "")
				{
					`SaveManager.GetCurrentSaveData().RemoveTimePiece(ci.ChapterActInfo[i].HourglassUncanny);
				}
			}
		}
	}
	if (Unlock)
		class'Hat_SaveBitHelper'.static.AddLevelBit(class'Hat_SpaceshipPowerPanel'.const.ActivatedLevelBit, ci.ChapterID);
	else
		class'Hat_SaveBitHelper'.static.RemoveLevelBit(class'Hat_SpaceshipPowerPanel'.const.ActivatedLevelBit, ci.ChapterID);
}

exec function MarkAllContractsActive()
{
	local Hat_SaveGame SaveGame;
	local class<Hat_SnatcherContract_Act> ContractClass;

	SaveGame = Hat_SaveGame(`SaveManager.SaveData);

	while (SaveGame.CompletedSnatcherContracts.Length > 0)
	{
		ContractClass = SaveGame.CompletedSnatcherContracts[0];
		SaveGame.CompletedSnatcherContracts.RemoveItem(ContractClass);
		SaveGame.SnatcherContracts.AddItem(ContractClass);
	}

	while (SaveGame.TurnedInSnatcherContracts.Length > 0)
	{
		ContractClass = SaveGame.TurnedInSnatcherContracts[0];
		SaveGame.TurnedInSnatcherContracts.RemoveItem(ContractClass);
		SaveGame.SnatcherContracts.AddItem(ContractClass);
	}

	Print(SaveGame.SnatcherContracts.Length $ " contracts active");
}

exec function MarkAllContractsCompleted()
{
	local Hat_SaveGame SaveGame;
	local class<Hat_SnatcherContract_Act> ContractClass;

	SaveGame = Hat_SaveGame(`SaveManager.SaveData);

	while (SaveGame.SnatcherContracts.Length > 0)
	{
		ContractClass = SaveGame.SnatcherContracts[0];
		SaveGame.SnatcherContracts.RemoveItem(ContractClass);
		SaveGame.CompletedSnatcherContracts.AddItem(ContractClass);
	}

	while (SaveGame.TurnedInSnatcherContracts.Length > 0)
	{
		ContractClass = SaveGame.TurnedInSnatcherContracts[0];
		SaveGame.TurnedInSnatcherContracts.RemoveItem(ContractClass);
		SaveGame.CompletedSnatcherContracts.AddItem(ContractClass);
	}

	Print(SaveGame.CompletedSnatcherContracts.Length $ " contracts completed");
}

exec function MarkAllContractsTurnedIn()
{
	local Hat_SaveGame SaveGame;
	local class<Hat_SnatcherContract_Act> ContractClass;

	SaveGame = Hat_SaveGame(`SaveManager.SaveData);

	while (SaveGame.SnatcherContracts.Length > 0)
	{
		ContractClass = SaveGame.SnatcherContracts[0];
		SaveGame.SnatcherContracts.RemoveItem(ContractClass);
		SaveGame.TurnedInSnatcherContracts.AddItem(ContractClass);
	}

	while (SaveGame.CompletedSnatcherContracts.Length > 0)
	{
		ContractClass = SaveGame.CompletedSnatcherContracts[0];
		SaveGame.CompletedSnatcherContracts.RemoveItem(ContractClass);
		SaveGame.TurnedInSnatcherContracts.AddItem(ContractClass);
	}

	Print(SaveGame.TurnedInSnatcherContracts.Length $ " contracts turned in");
}

exec function DecorationResetPaid()
{
	class'Hat_SaveBitHelper'.static.SetLevelBits("DecorationStandPaid", 0);
}

exec function MafiaTownBossUnlock()
{

	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.MafiaTown', true);
	`SaveManager.GetCurrentSaveData().RemoveTimePiece("harbor_impossible_race");
	`SaveManager.GetCurrentSaveData().RemoveTimePiece("mafiatown_lava");
	`SaveManager.GetCurrentSaveData().RemoveTimePiece("mafiatown_goldenvault");
}

exec function ResetSubconFinaleUnlock()
{

	`SaveManager.GetCurrentSaveData().RemoveTimePiece("vanessa_manor_attic");
	`SaveManager.GetCurrentSaveData().RemoveTimePiece("subcon_maildelivery");
	`SaveManager.GetCurrentSaveData().RemoveTimePiece("subcon_purple_bonfire");
	`SaveManager.GetCurrentSaveData().RemoveTimePiece("snatcher_boss");
}

exec function TrainwreckFinaleStart()
{

	`SaveManager.GetCurrentSaveData().RemoveTimePiece("chapter3_secret_finale");
	`SaveManager.GetCurrentSaveData().RemoveTimePiece("award_ceremony");
	`SaveManager.GetCurrentSaveData().GiveTimePiece("DeadBirdStudio", true);
	`SaveManager.GetCurrentSaveData().GiveTimePiece("trainwreck_selfdestruct", true);
	`SaveManager.GetCurrentSaveData().GiveTimePiece("moon_camerasnap", true);
	`SaveManager.GetCurrentSaveData().GiveTimePiece("chapter3_murder", true);
	`SaveManager.GetCurrentSaveData().GiveTimePiece("moon_parade", true);
}

exec function TrainwreckBeforeParade()
{
	`SaveManager.GetCurrentSaveData().RemoveTimePiece("chapter3_secret_finale");
	`SaveManager.GetCurrentSaveData().RemoveTimePiece("trainwreck_selfdestruct");
	`SaveManager.GetCurrentSaveData().GiveTimePiece("DeadBirdStudio", true);
	`SaveManager.GetCurrentSaveData().GiveTimePiece("moon_camerasnap", true);
	`SaveManager.GetCurrentSaveData().GiveTimePiece("chapter3_murder", true);
	`SaveManager.GetCurrentSaveData().RemoveTimePiece("moon_parade");
}

exec function TrainwreckFinaleComplete()
{

	`SaveManager.GetCurrentSaveData().RemoveTimePiece("chapter3_secret_finale");
	`SaveManager.GetCurrentSaveData().GiveTimePiece("DeadBirdStudio", true);
	`SaveManager.GetCurrentSaveData().GiveTimePiece("trainwreck_selfdestruct", true);
	`SaveManager.GetCurrentSaveData().GiveTimePiece("moon_camerasnap", true);
	`SaveManager.GetCurrentSaveData().GiveTimePiece("chapter3_murder", true);
	`SaveManager.GetCurrentSaveData().GiveTimePiece("moon_parade", true);
	`SaveManager.GetCurrentSaveData().GiveTimePiece("award_ceremony", true);
	
	`SaveManager.GetCurrentSaveData().SetTimePieceHighscore("trainwreck_selfdestruct", 453);
	`SaveManager.GetCurrentSaveData().SetTimePieceHighscore("moon_camerasnap", 316);
	`SaveManager.GetCurrentSaveData().SetTimePieceHighscore("chapter3_murder", 267);
	`SaveManager.GetCurrentSaveData().SetTimePieceHighscore("moon_parade", 572);
}

exec function TrainwreckSecretComplete()
{

	`SaveManager.GetCurrentSaveData().GiveTimePiece("DeadBirdStudio", true);
	`SaveManager.GetCurrentSaveData().GiveTimePiece("trainwreck_selfdestruct", true);
	`SaveManager.GetCurrentSaveData().GiveTimePiece("moon_camerasnap", true);
	`SaveManager.GetCurrentSaveData().GiveTimePiece("chapter3_murder", true);
	`SaveManager.GetCurrentSaveData().GiveTimePiece("moon_parade", true);
	`SaveManager.GetCurrentSaveData().GiveTimePiece("award_ceremony", true);
	`SaveManager.GetCurrentSaveData().GiveTimePiece("chapter3_secret_finale", true);
}

exec function TrainwreckPostDeadBird()
{

	`SaveManager.GetCurrentSaveData().GiveTimePiece("DeadBirdStudio", true);
	`SaveManager.GetCurrentSaveData().GiveTimePiece("trainwreck_selfdestruct", true);
	`SaveManager.GetCurrentSaveData().GiveTimePiece("moon_camerasnap", true);
	`SaveManager.GetCurrentSaveData().RemoveTimePiece("chapter3_murder");
	`SaveManager.GetCurrentSaveData().RemoveTimePiece("moon_parade");
	`SaveManager.GetCurrentSaveData().RemoveTimePiece("award_ceremony");
	`SaveManager.GetCurrentSaveData().RemoveTimePiece("chapter3_secret_finale");
}

exec function CookingCatJustUnlocked()
{
	if (`SaveManager.SaveData == None) return;
	
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.MafiaTown', true);
	class'Hat_IntruderInfo_MafiaBoss'.static.MarkAlertAsSeen();
	`SaveManager.SaveToFile(true);
	Print("Reopen Play-In-Editor for the change to take effect");
}

exec function SubconJustUnlocked()
{
	if (`SaveManager.SaveData == None) return;
	
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.MafiaTown', true);
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.subconforest', false);
	class'Hat_IntruderInfo_CookingCat'.static.MarkAlertAsSeen();
	`SaveManager.SaveToFile(true);
	Print("Reopen Play-In-Editor for the change to take effect");
}

exec function TrainwreckJustUnlocked()
{
	if (`SaveManager.SaveData == None) return;
	
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.MafiaTown', true);
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.subconforest', true);
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.trainwreck_of_science', false);
	class'Hat_IntruderInfo_CookingCat'.static.MarkAlertAsSeen();
	class'Hat_IntruderInfo_MafiaBoss'.static.MarkAlertAsSeen();
	`SaveManager.SaveToFile(true);
	Print("Reopen Play-In-Editor for the change to take effect");
}

exec function AlpsJustUnlocked()
{
	if (`SaveManager.SaveData == None) return;
	
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.MafiaTown', true);
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.subconforest', true);
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.trainwreck_of_science', true, true);
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.Sand_and_Sails', false);
	class'Hat_IntruderInfo_CookingCat'.static.MarkAlertAsSeen();
	class'Hat_IntruderInfo_MafiaBoss'.static.MarkAlertAsSeen();
	class'Hat_IntruderInfo_Modding'.static.MarkAlertAsSeen();
	`SaveManager.SaveToFile(true);
	Print("Reopen Play-In-Editor for the change to take effect");
}
exec function CruiseJustUnlocked()
{
	if (`SaveManager.SaveData == None) return;
	
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.MafiaTown', true);
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.subconforest', true);
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.trainwreck_of_science', true, true);
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.Sand_and_Sails', true);
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo_DLC1.ChapterInfos.ChapterInfo_Cruise', false);
	class'Hat_IntruderInfo_CookingCat'.static.MarkAlertAsSeen();
	class'Hat_IntruderInfo_MafiaBoss'.static.MarkAlertAsSeen();
	class'Hat_IntruderInfo_Modding'.static.MarkAlertAsSeen();
	`SaveManager.SaveToFile(true);
	Print("Reopen Play-In-Editor for the change to take effect");
}

exec function FinaleJustUnlocked()
{
	if (`SaveManager.SaveData == None) return;
	
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.MafiaTown', true);
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.subconforest', true);
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.trainwreck_of_science', false);
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.trainwreck_of_science', true, true);
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.Sand_and_Sails', true);
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.Mu_Finale', false);
	class'Hat_IntruderInfo_CookingCat'.static.MarkAlertAsSeen();
	class'Hat_IntruderInfo_MafiaBoss'.static.MarkAlertAsSeen();
	class'Hat_IntruderInfo_Modding'.static.MarkAlertAsSeen();
	`SaveManager.SaveToFile(true);
	Print("Reopen Play-In-Editor for the change to take effect");
}

exec function DeathWishUnlocked()
{
	if (`SaveManager.SaveData == None) return;
	
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.MafiaTown', true);
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.subconforest', true);
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.trainwreck_of_science', true);
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.Sand_and_Sails', true);
	class'Hat_IntruderInfo_CookingCat'.static.MarkAlertAsSeen();
	class'Hat_IntruderInfo_MafiaBoss'.static.MarkAlertAsSeen();
	class'Hat_IntruderInfo_Modding'.static.MarkAlertAsSeen();
	class'Hat_IntruderInfo_SpeedrunHat'.static.MarkAlertAsSeen();
	class'Hat_IntruderInfo_SupporterHat'.static.MarkAlertAsSeen();
	class'Hat_IntruderInfo_ExpressBand'.static.MarkAlertAsSeen();
	`SaveManager.SaveToFile(true);
	Print("Reopen Play-In-Editor for the change to take effect");
}

exec function MetroFinaleJustUnlocked()
{
	if (`SaveManager.SaveData == None) return;
	
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.MafiaTown', true);
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.subconforest', true);
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.trainwreck_of_science', true, true);
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.Sand_and_Sails', true);
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo_DLC1.ChapterInfos.ChapterInfo_Cruise', true);
	UnlockEverythingChapter(Hat_ChapterInfo'hatintime_chapterinfo_dlc2.ChapterInfos.ChapterInfo_Metro', true);
	`SaveManager.GetCurrentSaveData().RemoveTimePiece("Metro_Escape");
	class'Hat_IntruderInfo_CookingCat'.static.MarkAlertAsSeen();
	class'Hat_IntruderInfo_MafiaBoss'.static.MarkAlertAsSeen();
	class'Hat_IntruderInfo_Modding'.static.MarkAlertAsSeen();
	`SaveManager.SaveToFile(true);
	Print("Reopen Play-In-Editor for the change to take effect");
}

exec function MetroTimeRiftJustUnlocked()
{
	if (`SaveManager.SaveData == None) return;
	
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.MafiaTown', true);
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.subconforest', true);
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.trainwreck_of_science', true, true);
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.Sand_and_Sails', true);
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo_DLC1.ChapterInfos.ChapterInfo_Cruise', true);
	UnlockEverythingChapter(Hat_ChapterInfo'hatintime_chapterinfo_dlc2.ChapterInfos.ChapterInfo_Metro', true);
	`SaveManager.GetCurrentSaveData().RemoveTimePiece("Metro_Escape");
	`SaveManager.GetCurrentSaveData().RemoveTimePiece("Metro_CaveRift_RumbiFactory");
	class'Hat_IntruderInfo_CookingCat'.static.MarkAlertAsSeen();
	class'Hat_IntruderInfo_MafiaBoss'.static.MarkAlertAsSeen();
	class'Hat_IntruderInfo_Modding'.static.MarkAlertAsSeen();
	`SaveManager.SaveToFile(true);
	Print("Reopen Play-In-Editor for the change to take effect");
}

exec function ActSelectAnimations()
{
	if (`SaveManager.SaveData == None) return;
	
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.MafiaTown', false); // lock everything
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.MafiaTown', true, true); // unlock power panel
	`GameManager.GiveTimePiece("chapter1_tutorial", true);
	
	class'Hat_IntruderInfo_CookingCat'.static.MarkAlertAsSeen();
	class'Hat_IntruderInfo_MafiaBoss'.static.MarkAlertAsSeen();
	class'Hat_IntruderInfo_Modding'.static.MarkAlertAsSeen();
	`SaveManager.SaveToFile(true);
	Print("Reopen Play-In-Editor for the change to take effect");
}

exec function ResetActSelectFinaleAnimations()
{
	local int i;
	if (`SaveManager.SaveData == None) return;
	
	for (i = 0; i < 4; i++)
		class'Hat_SaveBitHelper'.static.SetLevelBits("ActSelectAnimation_FinaleFill_" $ i, 0);
	
	`SaveManager.SaveToFile(true);
}

exec function TogglePostProcessing()
{

	ConsoleCommand("SCALE TOGGLE bAllowPostProcessing");
}

exec function FullyRestartLevel()
{
	`GameManager.SetCurrentCheckpoint(0, false);
	ConsoleCommand("RestartLevel");
}

exec function SteamGenerateDebugItems()
{
	local OnlineSubsystem OnlineSubsystem;
	
	OnlineSubsystem = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSubsystem == None)
	{
		Print("Steam is not active. Run in non-editor.");
		return;
	}
	OnlineSubsystemCommonImpl(OnlineSubsystem).InventoryGenerateDebugItems();
}

exec function SteamUndoStickerFind()
{
	local OnlineSubsystem OnlineSubsystem;
	
	OnlineSubsystem = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSubsystem == None)
	{
		Print("Steam is not active. Run in non-editor.");
		return;
	}
	OnlineSubsystemCommonImpl(OnlineSubsystem).ExchangeItem(7,20007);
}

exec function SteamDoStickerFind()
{
	local OnlineSubsystem OnlineSubsystem;
	
	OnlineSubsystem = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSubsystem == None)
	{
		Print("Steam is not active. Run in non-editor.");
		return;
	}
	OnlineSubsystemCommonImpl(OnlineSubsystem).ExchangeItem(20007,7);
}

exec function SteamCacheInventory()
{
	local OnlineSubsystem OnlineSubsystem;
	
	OnlineSubsystem = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSubsystem == None)
	{
		Print("Steam is not active. Run in non-editor.");
		return;
	}
	OnlineSubsystemCommonImpl(OnlineSubsystem).InventoryCacheItems();
}

exec function GiveBadgePoints()
{
	`GameManager.AddBadgePoints(10);
}

exec function ClearMountain()
{
	local Hat_MountainInfo_Base mi, ClosestMountainInfo;
	local float distance, closestdistance;
	
	ClosestMountainInfo = None;
	foreach AllActors(class'Hat_MountainInfo_Base', mi)
	{
		distance = VSize(Pawn.Location - mi.Location);
		if (ClosestMountainInfo != None && Distance >= ClosestDistance) continue;
		
		closestdistance = distance;
		ClosestMountainInfo = mi;
	}
	
	if (ClosestMountainInfo != None)
	{
		if (ClosestMountainInfo.PlayersOnMountain.Find(Pawn) == INDEX_NONE)
			ClosestMountainInfo.PlayersOnMountain.AddItem(Pawn);
		ClosestMountainInfo.AllLootCompleted = false;
		ClosestMountainInfo.CheckAllLootCompleted(false);
	}
}

exec function CameraYOffset(float input)
{
	Hat_PlayerCamera(PlayerCamera).DebugCameraOffset.Y = input;
}

exec function CameraZOffset(float input)
{
	Hat_PlayerCamera(PlayerCamera).DebugCameraOffset.Z = input;
}

exec function CleanBackpack()
{
	`SaveManager.ClearLevelSpecificCollectibles(true);
}

exec function PrintMyCollision()
{
	Print("bCollideActors: " $ Pawn.bCollideActors);
	Print("bBlockActors: " $ Pawn.bBlockActors);
}
exec function PrintCheckpoint()
{
	Print("Checkpoint: " $ string(`GameManager.GetCurrentCheckpoint()));
}
exec function PrintAct()
{
	Print("ActID: " $ string(`GameManager.GetCurrentAct()));
}
exec function PrintChapter()
{
	Print("ChapterID: " $ string(`SaveManager.GetCurrentSaveData().CurrentChapter));
}

exec function ShowHelperHatObjectives()
{
	local Hat_ObjectiveActor obj;

	foreach DynamicActors(class'Hat_ObjectiveActor', obj)
	{
		obj.HelperHatExclusive = false;
	}
}

exec function FinaleMuMission()
{
	ClearChapter1Fully();
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.subconforest', true);
	UnlockEverythingChapter(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.trainwreck_of_science', true);
	class'Hat_SaveBitHelper'.static.RemoveLevelBit("MuMission_Finale", 1, "hub_spaceship");
}

exec function CompositeShadow()
{
	DynamicLightEnvironmentComponent(Hat_Pawn(Pawn).LightEnvironment).bForceCompositeAllLights = !DynamicLightEnvironmentComponent(Hat_Pawn(Pawn).LightEnvironment).bForceCompositeAllLights;
}

exec function ToggleMirrorMode()
{
	local Engine Engine;
	Engine = class'Engine'.static.GetEngine();
	Engine.bMirrorMode = !Engine.bMirrorMode;
}

exec function GiveAllHats()
{
	GiveCosmetic(class'Hat_Ability_Help', false);
	GiveCosmetic(class'Hat_Ability_Sprint', false);
	GiveCosmetic(class'Hat_Ability_Chemical', false);
	GiveCosmetic(class'Hat_Ability_StatueFall', false);
	GiveCosmetic(class'Hat_Ability_FoxMask', false);
	GiveCosmetic(class'Hat_Ability_TimeStop', false);
}

//Changed to add DLC 2 Badges
exec function GiveAllBadges()
{
	GiveCosmetic(class'Hat_Ability_Hookshot', false);
	GiveCosmetic(class'Hat_Ability_NoBonk', false);
	GiveCosmetic(class'Hat_Ability_HatCooldownBonus', false);
	GiveCosmetic(class'Hat_Ability_Camera', false);
	GiveCosmetic(class'Hat_Badge_Scooter', false);
	GiveCosmetic(class'Hat_Badge_SuckInOrbs', false);
	GiveCosmetic(class'Hat_Badge_FindRelics', false);
	GiveCosmetic(class'Hat_Ability_NoFallDamage', false);
	GiveCosmetic(class'Hat_Badge_Weapon_Projectile', false);
	GiveCosmetic(class'Hat_Badge_OneHitDeath', false);
	GiveCosmetic(class'Hat_Ability_Mumble', false);
	GiveCosmetic(class'Hat_Ability_Nostalgia', false);
	GiveCosmetic(class'Hat_Ability_Mirror', false);
	GiveCosmetic(class'Hat_Ability_PeacefulBadge', false);
	GiveCosmetic(class'Hat_Ability_RetroHandheld', false);
	GiveCosmetic(class'Hat_Ability_RedtroVR', false);
	GiveCollectible("Hat_Collectible_BadgeSlot", 1);
	GiveCollectible("Hat_Collectible_BadgeSlot2", 1);
}

exec function RemoveBadgeSlots()
{
	GiveCollectible("Hat_Collectible_BadgeSlot", -99);
	GiveCollectible("Hat_Collectible_BadgeSlot2", -99);
	`GameManager.AddBadgeSlots(-3);
}

exec function TauntDance()
{
	Hat_Player(Pawn).Taunt("Victory");
}

function LocalizationTest_sub(Font InFont, string FontName, string InString)
{
	local string result;
	result = class'Hat_FontInfo_Base'.static.Debug_ContainsString(InFont, InString);
	Print(FontName $ " contains '"$InString$"': " $ (result == "" ? "YES" : "'" $ result $ "'"));
}

exec function LocalizationTest()
{
	local string msg;
	
	
	//msg = class'Hat_Localizer'.static.GetSystem("levels", "Chapter");
	//msg $= " " $ 1 $ ": ";
	//msg = class'Hat_Localizer'.static.GetGame("levels", "Act_1_2");
	msg = "语言";
	
	//LocalizationTest_sub(Font'HatInTime_Fonts.CurseCasual.CurseCasualBig', "Curse casual", "Hello World");
	//LocalizationTest_sub(Font'HatInTime_Fonts.CurseCasual.CurseCasualBig', "Curse casual", "겨");
	//LocalizationTest_sub(Font'HatInTime_Fonts.Unicode.DefaultFontKO', "DefaultFontKO", "겨");
	//LocalizationTest_sub(Font'HatInTime_Fonts.Unicode.DefaultFontRU', "DefaultFontRU", "겨");
	//LocalizationTest_sub(Font'HatInTime_Fonts.Unicode.DefaultFontJP', "DefaultFontJP", "겨");
	//LocalizationTest_sub(Font'HatInTime_Fonts.CurseCasual.CurseCasualBig', "Curse casual", "マ");
	//LocalizationTest_sub(Font'HatInTime_Fonts.Unicode.DefaultFontKO', "DefaultFontKO", "マ");
	//LocalizationTest_sub(Font'HatInTime_Fonts.Unicode.DefaultFontRU', "DefaultFontRU", "マ");
	LocalizationTest_sub(Font'HatInTime_Fonts.Unicode.DefaultFontCHN', "DefaultFontCHN", msg);
	Print(msg $ " results in font: " $ class'Hat_FontInfo'.static.GetDefaultFont(msg));
}

exec function KillBoss()
{
	local Hat_Enemy_Boss boss;

	foreach DynamicActors(class'Hat_Enemy_Boss', boss)
	{
		boss.Died(Outer, None, boss.Location);
	}
}

exec function ShaderCacheFly()
{
	Hat_HUD(MyHUD).OpenHUD(class'Hat_HUDElementShaderCacheTool');
}

exec function ChokeGame()
{
	ChokeGameCount = 0;
	Outer.SetTimer(0.05f, true, NameOf(self.ChokeGameSub), self);
}

function ChokeGameSub()
{
	local int i;
	
	ChokeGameCount++;
	if (ChokeGameCount >= 5)
	{
		Outer.ClearTimer(NameOf(self.ChokeGameSub), self);
		return;
	}
	for (i = 0; i < 50; i++)
	{
		class'Hat_ClassHelper'.static.GetAllObjectsExpensive("Object");
	}
}

exec function HelperHatDebug()
{
	Print("CurrentPointOfInterest: " $ Hat_Ability_Help(Hat_InventoryManager(Pawn.InvManager).Hat).CurrentPointOfInterest);
}

static function Hat_PlayerController GetKeyboardPlayer(optional Controller CallingController)
{
	local Array<Player> GamePlayers;
	local int i;

	GamePlayers = class'Engine'.static.GetEngine().GamePlayers;

	if (GamePlayers.Length > 1)
	{
		for (i = 0; i < GamePlayers.Length; i++)
		{
			if (GamePlayers[i].Actor == None || GamePlayers[i].Actor.Pawn == None) continue;
			if (LocalPlayer(GamePlayers[i]).ControllerId >= 0) continue;
			return Hat_PlayerController(GamePlayers[i].Actor);
		}
	}

	return CallingController != None ? Hat_PlayerController(CallingController) : None;
}

// MEKU-ADD: Added support for walk/ghost in coop. Now whoever is keyboard gets the ghost.
exec function Walk()
{
	local Hat_PlayerController TargetPlayer;

	TargetPlayer = GetKeyboardPlayer(Outer);
	TargetPlayer.bCheatFlying = false;

	if (TargetPlayer.Pawn != None && TargetPlayer.Pawn.CheatWalk())
	{
		TargetPlayer.Restart(false);
	}
}

exec function Ghost()
{
	local Hat_PlayerController TargetPlayer;

	TargetPlayer = GetKeyboardPlayer(Outer);

	if ( (TargetPlayer.Pawn != None) && TargetPlayer.Pawn.CheatGhost() )
	{
		TargetPlayer.bCheatFlying = true;
		TargetPlayer.GotoState('PlayerFlying');
	}
	else
	{
		TargetPlayer.bCollideWorld = false;
	}

	//ClientMessage("You feel ethereal");
};

exec function God()
{
	local Hat_PlayerController TargetPlayer;

	TargetPlayer = GetKeyboardPlayer(Outer);

	if ( TargetPlayer.bGodMode )
	{
		TargetPlayer.bGodMode = false;
		//ClientMessage("God mode off");
		return;
	}

	TargetPlayer.bGodMode = true;
	//ClientMessage("God Mode on");
}

exec function ToggleSplitscreen()
{
	local Array<Player> GamePlayers;
	local Player ply;
	local GameViewportClient viewport;

	GamePlayers = class'Engine'.static.GetEngine().GamePlayers;

	foreach GamePlayers(ply)
	{
		if (LocalPlayer(ply) == None) continue;
		viewport = localPlayer(ply).ViewportClient;
		if (viewport == None) continue;
		Hat_GameViewportClient(viewport).ForceSingleScreen = !Hat_GameViewportClient(viewport).ForceSingleScreen;
		Print("Splitscreen is now: " $ (Hat_GameViewportClient(viewport).ForceSingleScreen ? "OFF" : "ON"));
		break;
	}
}

exec function DLCMetroPlaytest()
{
	if (!class'Hat_GameDLCInfo'.static.IsGameDLCInfoInstalled(class'Hat_GameDLCInfo_DLC2'))
	{
		ClientMessage("DLC2 not installed");
		return;
	}

	ClearMetroTickets();
	`SaveManager.GetCurrentSaveData().RemoveTimePiece("Metro_Intro");
	`SaveManager.GetCurrentSaveData().RemoveTimePiece("Metro_RouteA");
	`SaveManager.GetCurrentSaveData().RemoveTimePiece("Metro_RouteB");
	`SaveManager.GetCurrentSaveData().RemoveTimePiece("Metro_RouteC");
	`SaveManager.GetCurrentSaveData().RemoveTimePiece("Metro_RouteD");
	`SaveManager.GetCurrentSaveData().RemoveTimePiece("Metro_ManholeA");
	`SaveManager.GetCurrentSaveData().RemoveTimePiece("Metro_ManholeB");
	`SaveManager.GetCurrentSaveData().RemoveTimePiece("Metro_ManholeC");
	`SaveManager.GetCurrentSaveData().RemoveTimePiece("Metro_Escape");
	ResetCheckpoint();
	`GameManager.SetCurrentAct(99);
	
	class'Hat_SaveBitHelper'.static.ResetLevelBitsForLevel("dlc_metro");
	`SaveManager.OnNewActLoaded();
	
	ConsoleCommand("open DLC_Metro");
	class'Hat_GlobalTimer'.static.RestartActTimer();
}

exec function DLCMetroFinale_Pre()
{
	GiveMetroTickets();
	`GameManager.GiveTimePiece("Metro_Intro", true);
	`GameManager.GiveTimePiece("Metro_RouteA", true);
	`SaveManager.GetCurrentSaveData().RemoveTimePiece("Metro_RouteB");
	`GameManager.GiveTimePiece("Metro_RouteC", true);
	`GameManager.GiveTimePiece("Metro_RouteD", true);
	`GameManager.GiveTimePiece("Metro_ManholeA", true);
	`GameManager.GiveTimePiece("Metro_ManholeB", true);
	`GameManager.GiveTimePiece("Metro_ManholeC", true);
	`SaveManager.GetCurrentSaveData().RemoveTimePiece("Metro_Escape");
	ResetCheckpoint();
	`GameManager.SetCurrentAct(98);
	`SaveManager.OnNewActLoaded();
	ConsoleCommand("open DLC_Metro");
	class'Hat_GlobalTimer'.static.RestartActTimer();
}
exec function DLCMetroFinale()
{
	GiveMetroTickets();
	`GameManager.GiveTimePiece("Metro_Intro", true);
	`GameManager.GiveTimePiece("Metro_RouteA", true);
	`GameManager.GiveTimePiece("Metro_RouteB", true);
	`GameManager.GiveTimePiece("Metro_RouteC", true);
	`GameManager.GiveTimePiece("Metro_RouteD", true);
	`GameManager.GiveTimePiece("Metro_ManholeA", true);
	`GameManager.GiveTimePiece("Metro_ManholeB", true);
	`GameManager.GiveTimePiece("Metro_ManholeC", true);
	`SaveManager.GetCurrentSaveData().RemoveTimePiece("Metro_Escape");
	ResetCheckpoint();
	`GameManager.SetCurrentAct(8);
	`SaveManager.OnNewActLoaded();
	ConsoleCommand("open DLC_Metro");
	class'Hat_GlobalTimer'.static.RestartActTimer();
}
exec function GiveMetroTickets()
{
	local Hat_MetroTicketGate_Base gate;
	ClearMetroTickets();
	Hat_PlayerController(Outer).GetLoadout().AddCollectible(class'Hat_Collectible_MetroTicket_RouteA', 1);
	Hat_PlayerController(Outer).GetLoadout().AddCollectible(class'Hat_Collectible_MetroTicket_RouteB', 1);
	Hat_PlayerController(Outer).GetLoadout().AddCollectible(class'Hat_Collectible_MetroTicket_RouteC', 1);
	Hat_PlayerController(Outer).GetLoadout().AddCollectible(class'Hat_Collectible_MetroTicket_RouteD', 1);
	`SaveManager.SaveToFile();
	
	foreach AllActors(class'Hat_MetroTicketGate_Base', gate)
	{
		gate.DelayedInit();
	}
}

exec function ClearMetroTickets()
{
	local Hat_SaveGame SaveData;
	local int i;
	class'Hat_Collectible_MetroTicket_Base'.static.StaticRemoveFromBackpack();
	class'Hat_Collectible_MetroGuide'.static.StaticRemoveFromBackpack();
	class'Hat_Collectible_Sticker'.static.StaticRemoveFromBackpack();
	
	SaveData = `SaveManager.GetCurrentSaveData();
	for (i = 0; i < SaveData.Loadouts.Length; i++)
	{
		SaveData.Loadouts[i].Stickers.Length = 0;
	}
	Hat_PlayerController(Outer).GetLoadout().MyLoadout.Stickers.Length = 0;
}

exec function GiveDLC2Outfits()
{
	AddToBackpack(class'Hat_Collectible_Skin_Obnoxious');
	AddToBackpack(class'Hat_Collectible_Skin_TheJustice');
	AddToBackpack(class'Hat_Collectible_Skin_Ribbit');
	AddToBackpack(class'Hat_Collectible_Skin_Pizza');
	AddToBackpack(class'Hat_Collectible_Skin_MixedBerries');
	AddToBackpack(class'Hat_Collectible_Skin_MilkyWay');
	AddToBackpack(class'Hat_Collectible_Skin_Hamburger');
	AddToBackpack(class'Hat_Collectible_Skin_GreenBean');
	AddToBackpack(class'Hat_Collectible_Skin_Fortress');
	AddToBackpack(class'Hat_Collectible_Skin_Flames');
	AddToBackpack(class'Hat_Collectible_Skin_Edgy');
	AddToBackpack(class'Hat_Collectible_Skin_Dignified');
	AddToBackpack(class'Hat_Collectible_Skin_CoffeeCream');
	AddToBackpack(class'Hat_Collectible_Skin_Citrus');
	AddToBackpack(class'Hat_Collectible_Skin_Cherry');
	AddToBackpack(class'Hat_Collectible_Skin_Bee');
	AddToBackpack(class'Hat_Collectible_Skin_Battlements');
	AddToBackpack(class'Hat_Collectible_Skin_Anarchy');
	AddToBackpack(class'Hat_Collectible_Skin_BigSweater');
	AddToBackpack(class'Hat_Collectible_Skin_Nyakuza');
	AddToBackpack(class'Hat_Collectible_Skin_Wireframe');
	
	AddToBackpack(class'Hat_Ability_Help', class'Hat_CosmeticItemQualityInfo_Help_FlowerCrown');
	AddToBackpack(class'Hat_Ability_Chemical', class'Hat_CosmeticItemQualityInfo_Chemical_BurgerCap');
	AddToBackpack(class'Hat_Ability_FoxMask', class'Hat_CosmeticItemQualityInfo_FoxMask_Beret');
	AddToBackpack(class'Hat_Ability_Sprint', class'Hat_CosmeticItemQualityInfo_Sprint_BallCap');
	AddToBackpack(class'Hat_Ability_TimeStop', class'Hat_CosmeticItemQualityInfo_TimeStop_Headphones');
	AddToBackpack(class'Hat_Ability_TimeStop', class'Hat_CosmeticItemQualityInfo_TimeStop_SpaceHelmet');
	AddToBackpack(class'Hat_Ability_TimeStop', class'Hat_CosmeticItemQualityInfo_TimeStop_YeeHaw');
	AddToBackpack(class'Hat_Ability_Chemical', class'Hat_CosmeticItemQualityInfo_Chemical_NyakuzaCatEars');
	`SaveManager.SaveToFile();
}

exec function BenchCamera()
{
	local Hat_BenchCinematics bc;
	local int i;
	local DynamicCameraActor CameraActor;
	local Array<CameraActor> CameraActors;
	local Vector StartLocation, EndLocation, HitNormal, HitLocation;
	local Rotator r;
	
	if (class'Hat_BenchCinematics'.static.DestroyMyBenchCinematic(Outer)) return;
	
	for (i = 0; i < 5; i++)
	{
		r.Yaw = Pawn.Rotation.Yaw + 65536/2 + RandRange(-7000, 7000);
		r.Pitch = RandRange(-7000, 4000);
		
		StartLocation = Pawn.Location;
		EndLocation = Pawn.Location - Vector(r)*RandRange(200,700);
		
		if (class'Hat_PlayerCamera_Base'.static.CamTrace(StartLocation, EndLocation, HitLocation, HitNormal))
			EndLocation = HitLocation;
		
		CameraActor = Outer.Spawn(class'DynamicCameraActor',,,EndLocation,r,,true);
		if (CameraActor == None) continue;
		CameraActors.AddItem(CameraActor);
	}
	
	bc = Outer.Spawn(class'Hat_BenchCinematics');
	bc.PlayerController = Outer;
	bc.Cameras = CameraActors;
	bc.BenchWantsMusicTransition = false;
}

exec function SkipForward()
{
	local Hat_PlayerStart ps;
	local int CurrentActID;
	local int NewCheckpoint;
	local Hat_ChapterActInfo cai;
	local bool FirstFail;
	local Hat_ChapterInfo ci;
	
	cai = `GameManager.GetChapterActInfo();
	ci = `GameManager.GetChapterInfo();
	if (ci == None)
	{
		Print("No chapterinfo");
		return;
	}
	/*
	if (cai == None)
	{
		Print("No chapteractinfo");
		return;
	}
	*/
	CurrentActID = `GameManager.GetCurrentAct();
	NewCheckpoint = `GameManager.GetCurrentCheckpoint()+1;
	
	// Free roam: If we have this act's Time Piece, move to the next act
	FirstFail = true;
	if (ci != None && ci.IsActless)
	{
		while (cai == None || (cai != None && cai.Hourglass != "" && `GameManager.HasTimePiece(cai.Hourglass)))
		{
			if (FirstFail)
			{
				CurrentActID = 1;
			}
			else
				CurrentActID++;
			FirstFail = false;
			cai = `GameManager.GetChapterActInfo(CurrentActID);
			NewCheckpoint = 0;
			if (cai == None) break;
		}
	}
	
	// Find playerstart with our exact act & checkpoint
	foreach AllActors(class'Hat_PlayerStart', ps)
	{
		if (ps.GetActRelevance() != CurrentActID) continue;
		if (Max(ps.Checkpoint,0) != NewCheckpoint) continue;
		
		Hat_Player(Pawn).DoJumpFailRecovery(0, ps);
		`GameManager.SetCurrentAct(CurrentActID);
		`GameManager.SetCurrentCheckpoint(NewCheckpoint, false);
		return;
	}
	// Find playerstart with no specified act & our exact checkpoint
	foreach AllActors(class'Hat_PlayerStart', ps)
	{
		if (ps.GetActRelevance() >= 0) continue;
		if (Max(ps.Checkpoint,0) != NewCheckpoint) continue;
		
		Hat_Player(Pawn).DoJumpFailRecovery(0, ps);
		`GameManager.SetCurrentAct(CurrentActID);
		`GameManager.SetCurrentCheckpoint(NewCheckpoint, false);
		return;
	}
	Print("Unable to skip");
}

exec function StartMimic()
{
	class'Hat_GhostPartyPlayerBase'.static.SetMimickSubID(0);
}
exec function StopMimic()
{
	class'Hat_GhostPartyPlayerBase'.static.SetMimickSubID(INDEX_NONE);
}

exec function FlickerZ()
{
	local Hat_CommandRunner Runner;
	Runner = Spawn(class'Hat_CommandRunner');
	Runner.Commands.AddItem("scale set bUseEarlyZ false");
	Runner.Commands.AddItem("scale set bUseEarlyZ true");
	Runner.LoopCount = 5;
}

exec function SetSkinColor(String BodyPart, int R, int G, int B)
{
	Hat_Player(Pawn).SetMaterialVectorValue(Name(class'Hat_Collectible_Skin'.const.ColorGradientPrefix$BodyPart), MakeLinearColor((float(R)/255.f)**2, (float(G)/255.f)**2, (float(B)/255.f)**2, -1));
}

exec function OpenSkinEditor()
{
	Hat_HUD(MyHUD).OpenHUD(class'Hat_HUDElementSkinEditor');
}

exec function PrintAllChapterInfo()
{
	local Array<Hat_ChapterInfo> AllChapterInfo;
	local int i;
	
	Print("PrintAllChapterInfo");
	AllChapterInfo = class'Hat_ChapterInfo'.static.GetAllChapterInfo();
	for (i = 0; i < AllChapterInfo.Length; i++)
	{
		Print("AllChapterInfo[" $ i $ "] = " $ AllChapterInfo[i]);
	}
}

exec function PrintTitlecard()
{
	Print("BarrelBattle titlecard: " $ Hat_ChapterActInfo'HatinTime_ChapterInfo.MafiaTown.MafiaTown_BarrelBattle'.GetTitleCardBackground());
}	

exec function ToggleFreezeTickOptimize()
{
	if (`NPCManager.NPCManager.FreezeTickGroups)
	{
		`NPCManager.NPCManager.FreezeTickGroups = false;
		Print("Tick Optimize updates ENABLED");
	}
	else
	{
		`NPCManager.NPCManager.FreezeTickGroups = true;
		Print("Tick Optimize updates DISABLED");
	}
}

exec function ToggleTrainHeadlightSprites()
{
	local Hat_TrainHeadlight Headlight;
	local bool bSetEnabled, bEnabled;

	foreach DynamicActors(class'Hat_TrainHeadlight', Headlight)
	{
		if (!bSetEnabled)
		{
			bEnabled = !Headlight.bShowSprite;
			bSetEnabled = true;
		}

		Headlight.bShowSprite = bEnabled;
	}

	Print("Headlight Sprites " $ (bEnabled ? "ENABLED" : "DISABLED"));
}

exec function ToggleTrainHeadlights()
{
	local Hat_TrainHeadlight Headlight;
	local bool bSetEnabled, bEnabled;

	foreach DynamicActors(class'Hat_TrainHeadlight', Headlight)
	{
		if (!bSetEnabled)
		{
			bEnabled = !Headlight.bEnableLight;
			bSetEnabled = true;
		}

		Headlight.bEnableLight = bEnabled;
	}

	Print("Headlights " $ (bEnabled ? "ENABLED" : "DISABLED"));
}

exec function TickTrace(class<Actor> InClass)
{
	local Actor ActorIt;
	local Array<Name> ListedGroups;
	local string ActorName;
	local Name ActorTickOptimizationGroup;
	foreach DynamicActors(InClass, ActorIt)
	{
		if (!ActorIt.IsTicking()) continue;
		ActorTickOptimizationGroup = ActorIt.TickOptimizationGroup;
		if (ListedGroups.Find(ActorTickOptimizationGroup) != INDEX_NONE) continue;
		ActorName = string(ActorIt);
		if (ActorTickOptimizationGroup == 'Hat_TrainPoint_150') continue;

		Print("Actor " $ ActorName $ " is ticking. TickOptimizationGroup: " $ ActorTickOptimizationGroup);
		ListedGroups.AddItem(ActorTickOptimizationGroup);
		//break;
	}
}

//Old Hat_CheatManager commands
exec function tofade()
{
	Hat_PlayerController(Outer).TimeObjectFade();
}

exec function CreatePlayer()
{
    local PlayerController a;
	if(`GameManager.isCoop()) return;

    a = `GameManager.CreatePlayer(1, 1);
    a.Pawn.SetLocation(Pawn.Location + vect(0,0,1)*400);
    a.Pawn.SetRotation(Pawn.Rotation);
}

exec function pitch()
{
    local Rotator r;

    r = Rotation;
    r.Pitch = 65536.0/4.0;

    Pawn.SetRotation(r);
}

exec function DestroyRopeActors()
{
	`GameManager.DestroyRopeActors();
}

exec function StartSketching()
{
    OpenHUD("Hat_HUDMenuSketching");
}

exec function ThrowTrash()
{
	local Projectile p;
	local Vector v;
	local Rotator r;

	v = Pawn.Location + vect(0,0,1)*10;
	
	r = Pawn.Rotation;
	r.Pitch = 0;
	r.Roll = 0;
	v += Vector(r)*20;
	
	p = Projectile(Pawn.Spawn(ActorClassFromName("Hat_ProjectileTrash"),,, v, r));
	if (p != None)
	{
		p.Instigator = Pawn;
		p.Speed = RandRange(500,1000);
		p.Init(Vector(r));
	}
}

exec function CaveProgress()
{
	OpenHUD("Hat_HUDElementTimeRiftSpooling");
}

exec function Photobomb()
{
	OpenHUD("Hat_HUDElementPhotobomb");
}

exec function CheckpointHUD()
{
	Print("Hat_HUDElementCheckpoint");
	OpenHUD("Hat_HUDElementCheckpoint");
}

exec function MakeMuddy()
{
	GiveStatusEffect("Hat_StatusEffect_Muddy");
}

exec function SnatcherContractHUD()
{
	OpenHUD("Hat_HUDElementContract");
}

exec function ContractInfo()
{
	local Hat_SaveGame SaveGame;
	SaveGame = Hat_SaveGame(`SaveManager.SaveData);

	Print(SaveGame.SnatcherContracts.Length $ " active contracts");
	Print(SaveGame.CompletedSnatcherContracts.Length $ " completed contracts");
	Print(SaveGame.TurnedInSnatcherContracts.Length $ " turned-in contracts");
}

exec function PingPlayers()
{
	local PlayerController pc;
	foreach DynamicActors(class'PlayerController', pc)
	{
		Print("Player ping: " $ (pc.PlayerReplicationInfo.Ping*4) $ "ms (" $ pc.PlayerReplicationInfo.Ping $ "ms actual)");
	}
}

exec function StitchHatAnimation()
{
	local Hat_HUDElement element;
	
	element = Hat_HUD(MyHUD).OpenHUD(class'Hat_HUDElementStitchNewHat');
	Hat_HUDElementStitchNewHat(element).SetItemInfo(MyHUD, class'Hat_Loadout'.static.MakeLoadoutItem(class'Hat_Ability_Help'));
}
