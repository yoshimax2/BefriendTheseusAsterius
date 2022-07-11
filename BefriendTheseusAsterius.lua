

ModUtil.RegisterMod("BefriendTheseusAsterius")

OnAnyLoad{ function()

	if GameState.BefriendPersistentVals then
		
		if GameState.BefriendPersistentVals.SavedTrait ~= nil then
			local notPlaced = true

			for i=1,999 do
				if notPlaced then
					if CurrentRun.Hero.Traits[i] ~= nil and CurrentRun.Hero.Traits[i].Title and  (CurrentRun.Hero.Traits[i].Title == "GodsFavorTrait" or CurrentRun.Hero.Traits[i].Title == "ExtraDashTrait") then
						if CurrentRun.Hero.TraitDictionary[GameState.BefriendPersistentVals.LastAwardTrait]==nil then
							CurrentRun.Hero.TraitDictionary[GameState.BefriendPersistentVals.SavedTrait.Name] = {GameState.BefriendPersistentVals.SavedTrait}
						end
						
						notPlaced = false
						GameState.BefriendPersistentVals.SavedTrait = nil
					elseif CurrentRun.Hero.Traits[i] == nil then
						CurrentRun.Hero.Traits[i] = GameState.BefriendPersistentVals.SavedTrait
						notPlaced = false
						if CurrentRun.Hero.TraitDictionary[GameState.BefriendPersistentVals.LastAwardTrait]==nil then
							CurrentRun.Hero.TraitDictionary[GameState.BefriendPersistentVals.SavedTrait.Name] = {GameState.BefriendPersistentVals.SavedTrait}
						end
						GameState.BefriendPersistentVals.SavedTrait = nil

					end
				else
					if CurrentRun.Hero.Traits[i] ~= nil and CurrentRun.Hero.Traits[i].Title and  (CurrentRun.Hero.Traits[i].Title == "GodsFavorTrait" or CurrentRun.Hero.Traits[i].Title == "ExtraDashTrait") then
						--Removes extra copies of trait
						CurrentRun.Hero.Traits[i] = nil
					end
				end
			end
		end

		if GameState.BefriendPersistentVals.LastAwardTrait then
			GameState.LastAwardTrait = GameState.BefriendPersistentVals.LastAwardTrait
		end


	else
		DebugPrint({"Setting up persistent values table"})
		GameState.BefriendPersistentVals = {
			TheseusGiftVal = 0,
			TheseusGiftNewTraits = GameState.Gift["Theseus"].NewTraits,
			AsteriusGiftVal = 0,
			AsteriusGiftNewTraits = GameState.Gift["Minotaur"].NewTraits,
			SavedTraitName = nil,
			SavedTrait = nil,
			LastAwardTrait = nil,
			TheseusRarity = "None",
			AsteriusRarity = "None",
		}

		if GameState.Gift.Theseus["Value"]==nil and GameState.Gift.Minotaur["Value"]==nil then
			GameState.Gift.Theseus["Value"] = 0
			GameState.Gift.Minotaur["Value"] = 0
			DebugPrint({Text = "Adding gift data for heroes"})
		end
		
	end

	for i, traitData in pairs( CurrentRun.Hero.Traits ) do
		if traitData.Name == "GodsFavorTrait" and traitData.Rarity ~= GameState.BefriendPersistentVals["TheseusRarity"] then
			GameState.BefriendPersistentVals["TheseusRarity"] = traitData.Rarity
		elseif traitData.Name == "ExtraDashTrait" and traitData.Rarity ~= GameState.BefriendPersistentVals["AsteriusRarity"] then
			GameState.BefriendPersistentVals["AsteriusRarity"] = traitData.Rarity
		end
	end

	GameState.Gift["Theseus"] = {
		Value =  GameState.BefriendPersistentVals["TheseusGiftVal"],
		NewTraits = GameState.BefriendPersistentVals["TheseusGiftNewTraits"],
	}
	GameState.Gift["Minotaur"] = {
		Value =  GameState.BefriendPersistentVals["AsteriusGiftVal"],
		NewTraits = GameState.BefriendPersistentVals["AsteriusGiftNewTraits"],
	}
end}

ModUtil.WrapBaseFunction( "EquipLastAwardTrait", function(baseFunc, args)
    baseFunc(args)
	traits = {}

	for i=1,999 do

		if CurrentRun.Hero.Traits[i] ~= nil and CurrentRun.Hero.Traits[i].Title then
			if traits[CurrentRun.Hero.Traits[i].Title] == nil then
				traits[CurrentRun.Hero.Traits[i].Title] = i
			else
				--Removes extra copies of trait
				local title = CurrentRun.Hero.Traits[i].Title
				CurrentRun.Hero.Traits[i] = nil
			end
		end
	end

end)

ModUtil.WrapBaseFunction( "GetTraitCount", function(baseFunc, unit, trait)
	if trait.Slot and trait.Slot == "Keepsake" and CurrentDeathAreaRoom and CurrentDeathAreaRoom.Name == "RoomPreRun" then
		if unit.TraitDictionary[trait.Title] ~= nil then
			return 1
		else
			return 0
		end
	else
		return baseFunc(unit, trait)
	end
end)

-- GiftData.lua - Add Theseus and Asterius entries

local mod = "BefriendTheseusAsterius"
local package = "HeroesIcons"

ModUtil.WrapBaseFunction( "SetupMap", function(baseFunc)
    DebugPrint({Text = "@"..mod.." Trying to load package "..package..".pkg"})
    LoadPackages({Name = package})
    return baseFunc()
end)

ModUtil.WrapBaseFunction( "Save", function(baseFunc)
	local traitPos = 0

	GameState.BefriendPersistentVals["TheseusGiftVal"] = GameState.Gift["Theseus"].Value
	GameState.BefriendPersistentVals["TheseusGiftNewTraits"] = GameState.Gift["Theseus"].NewTraits
	GameState.BefriendPersistentVals["AsteriusGiftVal"] = GameState.Gift["Minotaur"].Value
	GameState.BefriendPersistentVals["AsteriusGiftNewTraits"] = GameState.Gift["Minotaur"].NewTraits
	GameState.BefriendPersistentVals["SavedTraitName"] = nil
	GameState.BefriendPersistentVals["SavedTrait"] = nil
	GameState.BefriendPersistentVals["LastAwardTrait"] = nil

	GameState.Gift.Theseus = nil
	GameState.Gift.Minotaur = nil

	for i=1,999 do
		if CurrentRun.Hero.Traits[i] then
			if CurrentRun.Hero.Traits[i].Name then
				if CurrentRun.Hero.Traits[i].Name == "GodsFavorTrait" then
					traitPos = i
					GameState.BefriendPersistentVals.SavedTraitName = "GodsFavorTrait"
					GameState.BefriendPersistentVals.SavedTrait = CurrentRun.Hero.Traits[i]		
					GameState.BefriendPersistentVals.LastAwardTrait = GameState.BefriendPersistentVals.SavedTrait.Name				
					CurrentRun.Hero.Traits[i] = nil
					if CurrentRun.Hero.TraitDictionary["GodsFavorTrait"] then
						for k, existingTrait in pairs( CurrentRun.Hero.TraitDictionary["GodsFavorTrait"] ) do
							if existingTrait.AnchorId~=nil then
								GameState.BefriendPersistentVals.SavedTrait.AnchorId = existingTrait.AnchorId
							end
						end
					end
				elseif  CurrentRun.Hero.Traits[i].Name == "ExtraDashTrait" then
					traitPos = i
					GameState.BefriendPersistentVals.SavedTraitName = "ExtraDashTrait"
					GameState.BefriendPersistentVals.SavedTrait = CurrentRun.Hero.Traits[i]		
					GameState.BefriendPersistentVals.LastAwardTrait = GameState.BefriendPersistentVals.SavedTrait.Name				
					CurrentRun.Hero.Traits[i] = nil
					if CurrentRun.Hero.TraitDictionary["ExtraDashTrait"] then
						for k, existingTrait in pairs( CurrentRun.Hero.TraitDictionary["ExtraDashTrait"] ) do
							if existingTrait.AnchorId~=nil then
								GameState.BefriendPersistentVals.SavedTrait.AnchorId = existingTrait.AnchorId
							end
						end
					end
				end
			end
		end
	end


	if GameState.LastAwardTrait == "GodsFavorTrait" or GameState.LastAwardTrait == "ExtraDashTrait" then
		GameState.LastAwardTrait = nil
	end
		

    baseFunc()

	GameState.Gift["Theseus"] = {
		Value =  GameState.BefriendPersistentVals.TheseusGiftVal,
		NewTraits = GameState.BefriendPersistentVals.TheseusGiftNewTraits
	}
	GameState.Gift["Minotaur"] = {
		Value =  GameState.BefriendPersistentVals.AsteriusGiftVal,
		NewTraits = GameState.BefriendPersistentVals.AsteriusGiftNewTraits
	}
	if GameState.BefriendPersistentVals.SavedTraitName ~= nil then
		if CurrentRun.Hero.Traits then
			CurrentRun.Hero.Traits[traitPos] = GameState.BefriendPersistentVals.SavedTrait
		end
	end
	if GameState.BefriendPersistentVals.LastAwardTrait ~= nil then
		GameState.LastAwardTrait = GameState.BefriendPersistentVals.LastAwardTrait
	end
end)
	
ModUtil.WrapBaseFunction("SetCursorFrame", function(baseFunc, button)
	button = button or {}
	baseFunc(button)

	if button.Data.NPC == "Theseus" then
		if TextLinesRecord["TheseusGift08"] ~= nil then
			if GameState.BefriendPersistentVals.TheseusRarity then
				if GameState.BefriendPersistentVals.TheseusRarity == "Epic" then
					ModifyTextBox({ Id = button.DescriptionTextBoxId, Text = "TheseusSignoff_Max_Epic"})
				elseif GameState.BefriendPersistentVals.TheseusRarity == "Rare" then
					ModifyTextBox({ Id = button.DescriptionTextBoxId, Text = "TheseusSignoff_Max_Rare"})
				elseif GameState.BefriendPersistentVals.TheseusRarity == "Common" then
					ModifyTextBox({ Id = button.DescriptionTextBoxId, Text = "TheseusSignoff_Max_Common"})
				end
			end
		else
			if GameState.Gift.Theseus.Value and GameState.Gift.Theseus.Value > 0 then
				if GameState.BefriendPersistentVals.TheseusRarity then
					if GameState.BefriendPersistentVals.TheseusRarity == "Epic" then
						ModifyTextBox({ Id = button.DescriptionTextBoxId, Text = "TheseusSignoff_Epic"})
					elseif GameState.BefriendPersistentVals.TheseusRarity == "Rare" then
						ModifyTextBox({ Id = button.DescriptionTextBoxId, Text = "TheseusSignoff_Rare"})
					elseif GameState.BefriendPersistentVals.TheseusRarity == "Common" then
						ModifyTextBox({ Id = button.DescriptionTextBoxId, Text = "TheseusSignoff_Common"})
					end
				end
			end
		end

	elseif button.Data.NPC == "Minotaur" then
		if TextLinesRecord["AsteriusGift08"] ~= nil then
			if GameState.BefriendPersistentVals.AsteriusRarity then
				if GameState.BefriendPersistentVals.AsteriusRarity == "Epic" then
					ModifyTextBox({ Id = button.DescriptionTextBoxId, Text = "AsteriusSignoff_Max_Epic"})
				elseif GameState.BefriendPersistentVals.AsteriusRarity == "Rare" then
					ModifyTextBox({ Id = button.DescriptionTextBoxId, Text = "AsteriusSignoff_Max_Rare"})
				elseif GameState.BefriendPersistentVals.AsteriusRarity == "Common" then
					ModifyTextBox({ Id = button.DescriptionTextBoxId, Text = "AsteriusSignoff_Max_Common"})
				end
			end
		else
			if GameState.Gift.Minotaur.Value and GameState.Gift.Minotaur.Value > 0 then
				if GameState.BefriendPersistentVals.AsteriusRarity then
					if GameState.BefriendPersistentVals.AsteriusRarity == "Epic" then
						ModifyTextBox({ Id = button.DescriptionTextBoxId, Text = "AsteriusSignoff_Epic"})
					elseif GameState.BefriendPersistentVals.AsteriusRarity == "Rare" then
						ModifyTextBox({ Id = button.DescriptionTextBoxId, Text = "AsteriusSignoff_Rare"})
					elseif GameState.BefriendPersistentVals.AsteriusRarity == "Common" then
						ModifyTextBox({ Id = button.DescriptionTextBoxId, Text = "AsteriusSignoff_Common"})
					end
				end
			end
		end
	end

end)


GiftData["Theseus"] = {
		Gift = true,
		InheritFrom = {"DefaultGiftData"},
		MaxedIcon = "Keepsake_Theseus_Max",
		MaxedSticker = "Keepsake_TheseusSticker_Max",
		MaxedRequirement = { RequiredTextLines = { "TheseusGift08" } },
		Locked = 7,
		Maximum = 8,
		[1] = { Gift = "GodsFavorTrait" },
		[7] = { RequiredResource = "SuperGiftPoints" },
		[8] = { RequiredResource = "SuperGiftPoints" },
		UnlockGameStateRequirements = { RequiredTextLines = { "TheseusInsecurityQuest05"} }
}

GiftData["Minotaur"] = {
		Gift = true,
		InheritFrom = {"DefaultGiftData"},
		MaxedIcon = "Keepsake_Asterius_Max",
		MaxedSticker = "Keepsake_AsteriusSticker_Max",
		MaxedRequirement = { RequiredTextLines = { "AsteriusGift08" } },
		Locked = 7,
		Maximum = 8,
		[1] = { Gift = "ExtraDashTrait" },
		[7] = { RequiredResource = "SuperGiftPoints" },
		[8] = { RequiredResource = "SuperGiftPoints" },
		UnlockGameStateRequirements = { RequiredTextLines = { "AsteriusRomanceQuest05"} }
}


table.insert( GiftOrdering,
"ExtraDashTrait"
)
table.insert( GiftOrdering,
"GodsFavorTrait"
)

-- NPCData.lua - Add "NPC_Theseus_01" and "NPC_Asterius_01" to GameData.ConversationOrder

table.insert( GameData.ConversationOrder,
"NPC_Asterius_01"
)

table.insert( GameData.ConversationOrder,
"NPC_Theseus_01"
)

table.insert( GameData.ConversationOrder,
"Theseus"
)

table.insert( GameData.ConversationOrder,
"Minotaur"
)

-- AudioData.lua - Overwrite GlobalVoiceLines.BreakableDestroyedVoiceLines

GlobalVoiceLines.BreakableDestroyedVoiceLines =
{
	{
		RandomRemaining = true,
		BreakIfPlayed = true,
		PreLineWait = 0.35,
		CooldownTime = 60,
		RequiresInRun = true,
		RequiredUnitAlive = "NPC_Charon_01",
		SuccessiveChanceToPlay = 0.05,
		RequiredFalseRooms = {"C_PreBoss01"},
		

		-- Don't mind me, Charon.
		{ Cue = "/VO/ZagreusField_0884", CooldownName = "MentionedCharon", CooldownTime = 40 },
		-- Just tidying up a bit.
		{ Cue = "/VO/ZagreusField_0885" },
		-- Must have slipped.
		{ Cue = "/VO/ZagreusField_0886" },
		-- Wasn't me.
		{ Cue = "/VO/ZagreusField_1624" },
		-- Who keeps replacing those.
		{ Cue = "/VO/ZagreusField_1625", RequiredPlayed = { "/VO/ZagreusField_0884"} },
		-- Took care of those for you, mate.
		{ Cue = "/VO/ZagreusField_1626" },
		-- No need to thank me, mate.
		{ Cue = "/VO/ZagreusField_1627" },
		-- No urns permitted in this chamber.
		{ Cue = "/VO/ZagreusField_1628" },
	},
	{
		ObjectType = "NPC_Sisyphus_01",
		RequiredUnitAlive = "NPC_Sisyphus_01",
		RandomRemaining = true,
		BreakIfPlayed = true,
		PreLineWait = 0.25,
		PlayFromTarget = true,
		CooldownTime = 60,
		SuccessiveChanceToPlay = 0.01,

		-- Erm, Prince...?
		{ Cue = "/VO/Sisyphus_0088", Cooldowns = { { Name = "SisyphusSaidPrinceRecently", Time = 10 }, }, },
		-- You show those dusty pots!
		{ Cue = "/VO/Sisyphus_0371" },
		-- Nice shot, Prince Z.!
		{ Cue = "/VO/Sisyphus_0372", Cooldowns = { { Name = "SisyphusSaidPrinceRecently", Time = 10 }, }, },
		-- That sound never gets old!
		{ Cue = "/VO/Sisyphus_0373" },
		-- Thank you for picking up a bit!
		{ Cue = "/VO/Sisyphus_0374" },
		-- They keep replacing those.
		{ Cue = "/VO/Sisyphus_0375" },
		-- Nice shot, Prince Z.!
		{ Cue = "/VO/Sisyphus_0376", Cooldowns = { { Name = "SisyphusSaidPrinceRecently", Time = 10 }, }, },
		-- I'm glad that wasn't me!
		{ Cue = "/VO/Sisyphus_0377" },
		-- Break all the pots you like!
		{ Cue = "/VO/Sisyphus_0378" },
		-- Fraid those are empty, Prince!
		{ Cue = "/VO/Sisyphus_0379", Cooldowns = { { Name = "SisyphusSaidPrinceRecently", Time = 10 }, }, },
		-- Don't bother with those, Prince.
		{ Cue = "/VO/Sisyphus_0380", Cooldowns = { { Name = "SisyphusSaidPrinceRecently", Time = 10 }, }, },
	},
}

-- AudioData.lua - Overwrite GlobalVoiceLines.BreakableHighValueDestroyedVoiceLines
GlobalVoiceLines.BreakableHighValueDestroyedVoiceLines =
{
	{
		PlayOnce = true,
		PlayOnceFromTableThisRun = true,
		RandomRemaining = true,
		BreakIfPlayed = true,
		PreLineWait = 0.8,
		RequiredKillEnemiesNotFound = true,
		RequiredBiome = "Styx",

		-- Some of those urns have coin in them don't they.
		{ Cue = "/VO/ZagreusField_2613", },
		-- These urns have coin in them.
		{ Cue = "/VO/ZagreusField_2614", },
	},
	{
		RandomRemaining = true,
		BreakIfPlayed = true,
		PreLineWait = 0.8,
		RequiredKillEnemiesNotFound = true,
		CooldownName = "HadesPostBossCooldown",
		CooldownTime = 270,
		SuccessiveChanceToPlay = 0.25,
		RequiredFalseRooms = {"C_PreBoss01"},

		-- I'm rich!
		{ Cue = "/VO/ZagreusField_0659", },
		-- Shiny.
		{ Cue = "/VO/ZagreusField_0665", },
		-- That's a lot of coin.
		{ Cue = "/VO/ZagreusField_0941", },
		-- Look at all that coin.
		{ Cue = "/VO/ZagreusField_0942", },
		-- Hey, money!
		{ Cue = "/VO/ZagreusField_0943", },
		-- Lucky find!
		{ Cue = "/VO/ZagreusField_0944", },
		-- Hello, coin!
		{ Cue = "/VO/ZagreusField_0945", },
		-- Lots of coin there.
		{ Cue = "/VO/ZagreusField_0946", },
	},
}

-- TraitData.lua - Insert GodsFavorTrait and ExtraDashTrait entries

TraitData["ExtraDashTrait"] = {
		EquipSound = "/SFX/Enemy Sounds/Minotaur/EmoteAttacking",
		Name = "ExtraDashTrait",
		Icon = "Keepsake_Bullhorn",
		Icon_Small = "Keepsake_Bullhorn",
		InheritFrom = { "GiftTrait" },
		InRackTitle = "ExtraDashTrait_Rack",
		Frame = "Gift",
		Slot = "Keepsake",
		RecordCacheOnEquip = true,
		ChamberThresholds =  { 25, 50 },
		
		SignOffData =
		{
		  {
			Text = "AsteriusSignoff",
		  },
		  {
			RequiredTextLines = { "AsteriusGift08" },
			Text = "AsteriusSignoff_Max"
		  }
		},

		RarityLevels =
		{
			Common =
			{
				Multiplier = 1.00,
			},
			Rare =
			{
				Multiplier = 2.00,
			},
			Epic =
			{
				Multiplier = 3.00,
			},
		},

		PropertyChanges =
		{
			{
				WeaponNames = WeaponSets.HeroRushWeapons,
				WeaponProperty = "ClipSize",
				BaseValue = 1,
				ChangeType = "Add",
				ExtractValue =
				{
					ExtractAs = "TooltipExtraDashes",
				}
			},
		},
}

TraitData["GodsFavorTrait"] = {
		EquipSound = "/SFX/Enemy Sounds/Theseus/EmoteLaugh",
		Name = "GodsFavorTrait",
		Icon = "Keepsake_Favor",
		Icon_Small = "Keepsake_Bullhorn",
		InheritFrom = { "GiftTrait" },
		InRackTitle = "GodsFavorTrait_Rack",
		Frame = "Gift",
		Slot = "Keepsake",
		RecordCacheOnEquip = true,
		ChamberThresholds =  { 25, 50 },

		RarityLevels =
		{
			Common =
			{
				Multiplier = 1.0,
			},
			Rare =
			{
				Multiplier = 1.5,
			},
			Epic =
			{
				Multiplier = 2.0,
			}
		},

		RarityBonus =
		{
			RequiredGod = nil,
			RareBonus = { BaseValue = 0.5 },
			EpicBonus = 0.5,
			LegendaryBonus = 0.5,
			ExtractValues =
			{
				{
					Key = "RareBonus",
					ExtractAs = "TooltipBonusChance",
					Format = "Percent",
				}
			}
		},

		SignOffData =
		{
		  {
			Text = "TheseusSignoff",
		  },
		  {
			RequiredTextLines = { "TheseusGift08" },
			Text = "TheseusSignoff_Max"
		  }
		},
		
}

-- Add four mod functions

function HandleAsteriusSpawn(asteriusSpawnId)


	local currentRun = CurrentRun
	local currentRoom = CurrentRun.CurrentRoom

	local newUnit = DeepCopyTable( EnemyData.NPC_Asterius_01 )
	spawnPointId = asteriusSpawnId
	newUnit.ObjectId = SpawnUnit({ Name = "NPC_Asterius_01", Group = "Standing", DestinationId = spawnPointId })
	newUnit.AsteriusId = newUnit.ObjectId
	SetupEnemyObject( newUnit, CurrentRun, { IgnoreAI = true, PreLoadBinks = true, } )
	UseableOn({ Ids = newUnit.ObjectId })
	SetupAI( CurrentRun, newUnit )
	
	local enemyData = DeepCopyTable( EnemyData.NPC_Asterius_01 )
	if IsActivationEligible( newUnit.ObjectId, enemyData ) then
		Activate({ Ids = newUnit.ObjectId })
	end
	AngleTowardTarget({ Id = newUnit.AsteriusId, DestinationId = CurrentRun.Hero.ObjectId })

	if TextLinesRecord["MinotaurAboutFriendship01"] == nil then
		newUnit.CanReceiveGift = false
	end

end

function DestroyUrns()
	DebugPrint({Text = "Running destroy urns"})

	for k, enemy in pairs( ActiveEnemies ) do
		if enemy.ObjectId == 515966 or enemy.ObjectId == 515967 or enemy.ObjectId == 515968 or enemy.ObjectId == 515969 or enemy.ObjectId == 515971 or enemy.ObjectId == 515972 or enemy.ObjectId == 515973 or enemy.ObjectId == 515974 or enemy.ObjectId == 515975 or enemy.ObjectId == 515976 or enemy.ObjectId == 517223 or enemy.ObjectId == 517224 or enemy.ObjectId == 517225 or enemy.ObjectId == 517226 or enemy.ObjectId == 517227 or enemy.ObjectId == 517228 or enemy.ObjectId == 517229 or enemy.ObjectId == 517230 or enemy.ObjectId == 517231  or enemy.ObjectId == 517232  or enemy.ObjectId == 517234  or enemy.ObjectId == 517235  or enemy.ObjectId == 517236 then
			thread( Kill, enemy )
		end
	end
end

function TheseusGiveMoney()
	thread( GushMoney, { Amount = 100, LocationId = 515967, Radius = 100, Source = "Theseus" } )
end

--Loads Theseus and Asterius in pre boss Elysium room

OnAnyLoad{"C_PreBoss01", function()

	if TextLinesRecord["TheseusFirstAppearance_NotMetMinotaur"]== nil and TextLinesRecord[ "TheseusFirstAppearance_MetBeatMinotaur"]==nil and TextLinesRecord["TheseusFirstAppearance_MetNotBeatMinotaur" ]==nil then
		DebugPrint({Text = "Skipped spawning Theseus and Asterius since Theseus not encountered"})
	elseif TextLinesRecord["TheseusAboutFraternalBonds01"] ~= nil and TextLinesRecord["TheseusAboutFraternalBonds06_A"]==nil and TextLinesRecord["TheseusAboutFraternalBonds06_B"]==nil then
		DebugPrint({Text = "Skipped spawning Theseus and Asterius because of Fraternal Bonds quest"})
	else
		
		DestroyUrns()
		local currentRun = CurrentRun
		local currentRoom = CurrentRun.CurrentRoom

		local newUnit = DeepCopyTable( EnemyData.NPC_Theseus_01 )
		spawnPointId = 515967
		newUnit.ObjectId = SpawnUnit({ Name = "NPC_Theseus_01", Group = "Standing", DestinationId = spawnPointId })
		
		newUnit.ObjectId = SpawnUnit({ Name = "NPC_Theseus_01", Group = "Standing", DestinationId = spawnPointId })
		newUnit.TheseusId = newUnit.ObjectId
		currentRun.TheseusId = newUnit.TheseusId

		SetupEnemyObject( newUnit, CurrentRun, { IgnoreAI = true, PreLoadBinks = true, } )
		UseableOn({ Ids = newUnit.ObjectId })
		SetupAI( CurrentRun, newUnit )

		local enemyData = DeepCopyTable( EnemyData.NPC_Theseus_01 )
		if IsActivationEligible( newUnit.ObjectId, enemyData ) then
			Activate({ Ids = newUnit.ObjectId })
		end

		if GameState.EnemyKills.Theseus then
			if GameState.EnemyKills.Theseus < 5 then
				newUnit.CanReceiveGift = false
			end
		else
			newUnit.CanReceiveGift = false
		end

		HandleAsteriusSpawn(517230)
	end

end
}

function orderGifts()
	GiftOrderingReverseLookup = {}
	for index, name in pairs(GiftOrdering) do
		GiftOrderingReverseLookup[name] = index
	end
end

ModUtil.LoadOnce(orderGifts())

-- NPCData.lua - Insert NPC_Theseus_01, NPC_Asterius_01 entries

EnemyData["NPC_Theseus_01"] =

	{
		-- Theseus, Id = 1000001 
		Name = "NPC_Theseus_01",
		InheritFrom = { "NPC_Neutral", "NPC_Giftable" },
		UseText = "UseTalkToThanatos",
		Portrait = "Portrait_Theseus_Default_01",
		AnimOffsetZ = 220,
		EmoteOffsetX = -50,
		EmoteOffsetY = -250,
		Groups = { "NPCs" },
		GenusName = "Theseus",
		SkipInitialGiftRequirement = true,
		CanReceiveGift = true,


		Binks = 
		{
			"TheseusIdle_Bink",
			"TheseusTaunt_Bink",
		},

		SubtitleColor = Color.TheseusVoice,

		ActivateRequirements =
		{
			RequiredAnyTextLines = { "TheseusFirstAppearance_NotMetMinotaur", "TheseusFirstAppearance_MetBeatMinotaur", "TheseusFirstAppearance_MetNotBeatMinotaur" },
		},

		InteractTextLineSets =
		{

			TheseusFirstMeeting =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusFirstMeeting",
				SuperPriority = true,
				PlayOnce = true,
				UseableOffSource = true,
				GiftableOffSource = true,
				InitialGiftableOffSource = true,
				UseInitialInteractSetup = true,
				RequiredAnyTextLines = { "TheseusFirstAppearance_NotMetMinotaur", "TheseusFirstAppearance_MetBeatMinotaur", "TheseusFirstAppearance_MetNotBeatMinotaur" },

				{ PreLineWait = 0.35, AngleTowardHero = true,
					Text = "What are you doing here, blackguard? You don't deserve to step foot near this entrance to Elysium's most glorious stadium." },
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "How else did you think I got in? And I'm buying supplies to help me escape this place. What are you doing here, anyway? Never seen you outside the stadium before." },
				{ Text = "I'm a frequent patron of Charon's wares and was purchasing some goods that will aid me in vanquishing you. All for the benefit of our audience, of course! I could destroy you with my bare hands if I wished." },
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "You need the help of both Asterius and the gods to have a chance at destroying me, but you can believe otherwise if it makes you feel better." },
				{ Emote = "PortraitEmoteAnger", Text = "You lie, blackguard! You'll see just how powerful I am soon, you foul pustule!" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "You mean I'll see how powerful you and Asterius and the gods are? I look forward to it. See you soon!" },
			},
			TheseusSecondMeeting =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusSecondMeeting",
				SuperPriority = true,
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				GiftableOffSource = true,
				RequiredRunsCleared = 0,
				RequiredKills = {Theseus = 0},
				RequiredTextLines = { "TheseusFirstMeeting" },
				{ PreLineWait = 0.35, AngleTowardHero = true, 
					Text = "Prepare yourself for an epic battle, blackguard! " },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					PreLineAnim = "ZagreusTalkEmpathyStart", PreLineAnimTarget = "Hero",
					PostLineAnim = "ZagreusTalkEmpathy_Return", PostLineAnimTarget = "Hero",
					Text = "Aww, did you really wait for me outside the stadium again just to tell me that? How sweet!" },
				{ Text = "Your wicked words can't hurt me! Not like my spear will when it soon eviscerates you. Prepare for your imminent death once you step through those doors!" },
			},

			
			TheseusSecondMeetingAlt =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusSecondMeetingAlt",
				SuperPriority = true,
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				GiftableOffSource = true,
				RequiredFalseTextLines = { "TheseusSecondMeeting" },
				RequiredTextLines = { "TheseusFirstMeeting" },
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Why have you returned to us again, daemon?" },
				{ Portrait = "Portrait_Zag_Serious_01", Speaker = "CharProtag",
					Text = "I just couldn't resist the urge to kill you once more, Theseus." },
				{ Text = "Foul lies! Your wicked words won't fool me! Prepare for your imminent death once you step through those doors." },
			},
			
			TheseusInsecurityQuest01 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusInsecurityQuest01",
				Priority = true,
				PlayOnce = true,
				RequiredTextLines = { "AsteriusInsecurityQuest01" },
				RequiredKills = { Theseus = 10 },
				{ PreLineWait = 0.35, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Good day or night, Theseus. How are you?" },
				{ AngleTowardHero = true, Emote = "PortraitEmoteDepressed", Text = "Prince Zagreus. Come to slay me yet again in front of all the other shades of Elysium?" },
				{ Portrait = "Portrait_Zag_Serious_01", Speaker = "CharProtag",
					Text = "So, not good then. Theseus, no one thinks less of you if you lose. Is that what you worry about? Losing the respect of the other shades here?" },
				{ Text = "How could I not? I'd estimate that you've slain me around ten times by now, if not more. What kind of warrior am I?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "You're a Champion, that's who. I'm just getting stronger, but you're still a worthy opponent." },
				{ Text = "That's a meaningless consolation, daemon." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Zagreus. And it's not meaningless. However, there's more to life than just fighting all the time." },
				{ Text = "This is Elysium. The greatest warriors are here, and they want to spend an eternity fighting." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Is that what you want? Is there nothing else you'd rather be doing?" },
				{ Text = "Fighting's all I've ever known, so no. There's nothing else like the rush of battle." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I'm going to find you a hobby." },
				{ Text = "You can try. In the meantime, arm yourself! Another fight is close at hand." },
			},

			TheseusInsecurityQuest02 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusInsecurityQuest02",
				Priority = true,
				PlayOnce = true,
				RequiredTextLines = { "TheseusInsecurityQuest01" },
				RequiredMinRunsCleared = 3,
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Fair tidings to you, Prince Zagreus. I believe I've found myself a hobby!" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Oh really? What is it?" },
				{ Text = "I spent some time nurturing the gardens of Elysium. It was strangely relaxing." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Ah, my mother loves gardening! See, it gave you something positive to do that didn't involve killing anyone. Not that I can really talk." },
				{ Text = "It did feel comforting, for some reason. But how will it help me? Gardening won't gain the respect of the shades here." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "No, but I'd like you to see that you don't need their respect. If you stopped caring so much about what everyone else thought of you, you'd be happier." },
				{ Text = "Outrageous. Like I said, this is all I've known during my life and death. I honestly don't know how I'd stop caring." },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "We'll keep working on it." },
			},
			TheseusInsecurityQuest03 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusInsecurityQuest03",
				Priority = true,
				PlayOnce = true,
				RequiredTextLines = { "AsteriusInsecurityQuest02" },
				{ PreLineWait = 0.35, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Hey Theseus. How's the gardening going?" },
				{ AngleTowardHero = true, Text = "Wonderfully! I've helped make the splendors of Elysium even more brilliant. It's been good to contribute something other than bloodshed to the realm." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I was hoping that would be the case." },
				{ Text = "But I still don't understand the purpose of doing this. Am I not still the Champion? How will this aid me?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I wanted to talk about that, actually. I think your troubles stem from your need for others to look up to you. You should be comfortable with yourself rather than relying on respect from others." },
				{ Text = "That's easier said than done." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "True. But Asterius cares for you. So do I. The opinions of the other shades don't matter. Next time you have a negative thought about yourself, remember that." },
				{ Text = "Hm. I'll try, but I may be too set in my phantasmagoric ways to change." },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "I don't think that's true." },
			},
			TheseusInsecurityQuest04 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusInsecurityQuest04",
				Priority = true,
				PlayOnce = true,
				RequiredMinCompletedRuns = 20,
				RequiredTextLines = { "TheseusInsecurityQuest03" },
				{ PreLineWait = 0.35, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "You look happy today, Theseus." },
				{ AngleTowardHero = true, Emote = "PortraitEmoteCheerful", Text = "Prince Zagreus! I am. I've been practicing what you've suggested, and it has seemed to make a difference." },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "That's wonderful news!" },
				{ Text = "A shade insulted me earlier this day or night. Rather than shouting at them, I thought about what Asterius would say. He wouldn't let it bother him, so neither did I." },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "That's great to hear, honestly. It sounds like you've made a lot of progress." },
				{ Text = "I have. Just you wait - I'll be more skilled at thinking positively soon than anyone else in Elysium!" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I bet you will." },
			},
			TheseusInsecurityQuest05 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusInsecurityQuest05",
				Priority = true,
				PlayOnce = true,
				RequiredMinCompletedRuns = 30,
				RequiredTextLines = { "TheseusInsecurityQuest04" },
				{ PreLineWait = 0.35, AngleTowardHero = true, Emote = "PortraitEmoteCheerful", Text = "Good day or night to you, Prince Zagreus!" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Hey Theseus. Still doing well?" },
				{ Text = "I am. I've realized that I don't have to be the best at thinking positively. This is no competition. I just need to keep working on it." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Exactly. I really think you're getting there." },
				{ Text = "I've even continued with my gardening. Thank you for your support, friend! With dear friends like you and Asterius, I need no one else." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I'm glad to call you a friend as well, Theseus." },
			},
			TheseusRomanceQuest01 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusRomanceQuest01",
				Priority = true,
				PlayOnce = true,
				RequiredTextLines = { "AsteriusRomanceQuest02", "TheseusGift06" },
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Fair tidings to you on this lovely day or night in Elysium, Prince!" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Same to you, Theseus. I had a question for you, actually." },
				{ Text = "How may I assist you?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I was wondering how you'd feel about me bedding Asterius." },
				{ Emote = "PortraitEmoteSurprise", Text = "About you {#DialogueItalicFormat}what{#PreviousFormat}? Making love to the bull? Absolutely not!" },
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "Wait, why not? You don't hold any sort of claim to him, do you?" },
				{ Text = "Pfft... I mean! ...Well, no, I suppose I don't. But please, don't bed him. Does he want you to?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Perhaps. Maybe I haven't asked him yet and wanted to get your opinion first." },
				{ Text = "If so, then please don't ask him. I know he's handsome, but he's my dearest companion, and we share a bond." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Understood. I'll keep my thoughts to myself then." },
			},
			TheseusRomanceQuest02 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusRomanceQuest02",
				Priority = true,
				PlayOnce = true,
				RequiredTextLines = { "AsteriusRomanceQuest03", "TheseusGift06" },
				MinRunsSinceAnyTextLines = { TextLines = { "AsteriusRomanceQuest03" }, Count = 3 },
				{ PreLineWait = 0.35, AngleTowardHero = true, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Theseus, just out of curiosity, has Asterius said anything interesting about your relationship recently?" },
				{ Text = "Hm? No, not that I'm aware of. But everything my dear Asterius has to say is always interesting!" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Guess he hasn't asked yet then." },
				{ Text = "What was that?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Nothing! Just looking forward to our match." },
			},
			TheseusRomanceQuest03 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusRomanceQuest03",
				SuperPriority = true,
				PlayOnce = true,
				RequiredTextLines = { "AsteriusRomanceQuest04", "TheseusGift06"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Prince, I wanted to speak with you!" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "What is it, Theseus?" },
				{ Text = "Perchance, when you enquired previously into whether or not Asterius had spoken to me about our relationship, were you referencing his declaration of his feelings?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Yes, but he hadn't asked you yet." },
				{ Text = "Well, he did now! And we celebrated by exploring each other gloriously!" },
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "I'm very glad to hear that it worked out! Please don't feel the need to tell me every detail." },
				{ Text = "There's so much to share, though! Oh, it was amazing." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Good to know!" },
			},
			TheseusBackstory01 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusBackstory01",
				Priority = true,
				PlayOnce = true,
				GiftableOffSource = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredFalseTextLines = {"TheseusGift06"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Have I ever told you about my life in Athens, blackguard? The tales are glorious enough that even ears as foul as yours deserve to hear them." },
				{  Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag", 
					Text = "You've never told me, nor have I ever been interested." },
				{ Emote = "PortraitEmoteAnger", Text = "Cruel daemon! I offered to share my history with you, my life, and you refuse?" },
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "You got it. Maybe if you were nicer to me, I'd feel like humoring your nostalgia." },
				{ Text = "Nicer! {#DialogueItalicFormat}Pah! {#PreviousFormat} There's no one in all of Elysium as nice as me." },
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "You keep telling yourself that. In the meantime, I'll spend my time with those aforementioned nicer shades." },
			},
			TheseusBackstory02 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusBackstory02",
				Priority = true,
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredTextLines = { "TheseusGift06" },
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Prince Zagreus, would you care to hear stories of my life in Athens? While they may pale in comparison to the stories of the Underworld, you may find them intriguing." },
				{  Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag", 
					Text = "I'd love to hear your stories. Life in the Underworld feels so distant from the surface, sometimes." },
				{ PostLineThreadedFunctionName = "LoungeRevelryPresentation", PostLineFunctionArgs = { Sound2 = "/EmptyCue", Sound3 = "/EmptyCue" }, Text = "I'd love nothing more than to share them! And to share a drink with you! Would you perchance join me?"},

				{ FadeOutTime = 0.5, FullFadeTime = 7.8, FadeInTime = 2.0, InterSceneWaitTime = 0.5, Text = "And so poor Asterius fell, and I escaped the labyrinth."},
				
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Your stories are fascinating, even in comparison to those of the Underworld." },
				{ Text = "I have many more to share!" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I'd love to hear them sometime." },
			},

			TheseusKeepsake01 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusKeepsake01",
				Priority = true,
				PlayOnce = true,
				UseInitialInteractSetup = true,
				GiftableOffSource = true,
				UseableOffSource = true,
				RequiredFalseTextLines = {"TheseusGift06", "TheseusKeepsake01Alt"},
				RequiredTrait = "GodsFavorTrait",
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Blackguard, do I spot one of my beautiful golden cuffs on your wrist? How dare you wear that!" },
				{  Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag", 
					Text = "What? You gave it to me? Did you not want me to wear it?" },
				{ Emote = "PortraitEmoteAnger", Text = "Be glad we're not in the stadium now, or I would disembowel you for spouting such ridiculous lies! I would never give you any of my many prized possessions." },
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "We can pretend like you didn't gift it to me if you'd like, but I'm not going to stop wearing it. It's quite useful having the gods favor me even more." },
				{ Text = "The gods would never favor you, daemon! You'll see soon when I call upon them and smite you!" },
			},
			TheseusKeepsake01Alt =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusKeepsake01Alt",
				Priority = true,
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredTextLines = {"TheseusGift08"},
				RequriedFalseTextLines = {"TheseusKeepsake01"},
				RequiredTrait = "GodsFavorTrait",
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Prince Zagreus, what is that splendid cuff you're wearing on your wrist?" },
				{  Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag", 
					Text = "Oh, this? It's the keepsake you gave me. It's been quite useful having Olympus favor me even more." },
				{ Text = "What glorious news! My old equipment is being used by a god! Dear friend, you have truly made my day or night." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I'm glad. Seriously, thanks for giving me this." },
				{ Text = "It's the least I can do for you considering all that you've done for me! Now, what do you say we battle to the death in front of our loving audience?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I'd say that sounds like an excellent idea." },
			},

			TheseusAboutAriadne01 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusAboutAriadne01",
				Priority = true,
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				GiftableOffSource = true,
				RequiredAnyTextLines = { "TheseusYarnReaction04", "TheseusYarnReaction04_B" },
				RequiredTrait = "TemporaryBoonRarityTrait",
				RequiredFalseTextLines = {"TheseusGift06", "TheseusAboutAriadne01Alt"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Why do you yet again carry around that ball of yarn, daemon? Haven't I told you it bothers me?" },
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "I've gotten that impression, but I can't say bothering you bothers me. Who was Ariadne to you, anyway?" },
				{ Text = "Why do you care, fiend? She's no one, now. She's of no more significance than a speck of dust compared to me! She's just another shade somewhere in the Underworld." },
			},
			TheseusAboutAriadne01Alt =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusAboutAriadne01Alt",
				Priority = true,
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredAnyTextLines = { "TheseusYarnReaction04", "TheseusYarnReaction04_B" },
				RequiredTrait = "TemporaryBoonRarityTrait",
				RequiredTextLines = {"TheseusGift06"},
				RequiredFalseTextLines = {"TheseusAboutAriadne01"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Why do you yet again carry around that ball of yarn, my dear friend? Haven't I told you it bothers me?" },
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "I'm sorry. It helps me find better boons from the gods, but I forgot that it bothered you. Who was Ariadne to you, anyway?" },
				{ Text = "She's no one, now. Just another shade somewhere in the Underworld." },
			},

			TheseusAboutAriadne02 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusAboutAriadne02",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				GiftableOffSource = true,
				RequiredAnyTextLines = { "TheseusAboutAriadne01", "TheseusAboutAriadne01Alt" },
				RequiredAnyTextLines = {"TheseusYarnReaction04", "TheseusYarnReaction04_B"},
				RequiredFalseTextLines = {"TheseusGift06", "TheseusAboutAriadne02Alt"},
				{ PreLineWait = 0.35, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I tried to look for Ariadne, but couldn't find her." },
				{ AngleTowardHero = true, Text = "You interfering, loathsome, ungracious pustule! Why would you search for her?" },
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "Well, you wouldn't tell me who she was, so I thought I'd figure it out for myself. But I haven't had any luck." },
				{ Text = "I abandoned her, foolish blackguard! Left her on an island to die because I didn't return her affections. So despite what I told Asterius, I have no desire to find her." },
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "I wouldn't want anything to do with you either if I was her. Maybe I'll let her rest in peace, then." },			
			},
			TheseusAboutAriadne02Alt =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusAboutAriadne02Alt",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredAnyTextLines = { "TheseusAboutAriadne01", "TheseusAboutAriadne01Alt" },
				RequiredAnyTextLines = {"TheseusYarnReaction04", "TheseusYarnReaction04_B"},
				RequiredTextLines = {"TheseusGift06"},
				RequiredFalseTextLines = {"TheseusAboutAriadne02"},
				{ PreLineWait = 0.35, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I tried to look for Ariadne for you, but couldn't find her." },
				{ AngleTowardHero = true, Text = "You'd do that for me? Why would you search for her?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Well, you said you'd seek her out, so I thought I'd help out. But I haven't had any luck." },
				{ Text = "She wouldn't want to see me anyways. I abandoned her, Prince! Left her on an island to die because I didn't return her affections. So despite what I told Asterius, I have no desire to find her." },
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "Oh wow. Maybe you're better off not finding her, then." },			
			},

			TheseusAboutAriadne03 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusAboutAriadne03",
				Priority = true,
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredAnyTextLines = { "TheseusAboutAriadne02", "TheseusAboutAriadne02Alt", "AsteriusAboutAriadne03"},
				RequiredTextLines = {"TheseusGift08"},
				{ PreLineWait = 0.35, Portrait = "Portrait_Zag_Serious_01", Speaker = "CharProtag",
					Text = "Theseus, I think I found Ariadne." },
				{ AngleTowardHero = true, Text = "What? You were still searching for her?"},
				{ Portrait = "Portrait_Zag_Serious_01", Speaker = "CharProtag",
					Text = "I was. She's Asterius's sister, and I owe it to him. She's to the northwest of here in an Elysium cottage." },
				{ Text = "Daemon -- I mean Prince -- I don't know what to say for once. Or what to do, for that matter. You're a god. Should I seek her out?" },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "I can't tell you what to do. Follow your conscience, Theseus. I just wanted to tell you where she was." },
				{ Text = "Thank you. I... I need some time to myself for a moment. Don't worry, I'll still meet you on the battlefield."},
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Good luck, king." },
			},

			TheseusAboutHades =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusAboutHades",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredTextLines = {"TheseusGift07"},
				{ PreLineWait = 0.35, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Hey Theseus. How's Elysium holding up?" },
				{ AngleTowardHero = true, Text = "Greetings, my dear friend! We're still working on the repairs from your last visit, but everything's nearly fixed."},
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "That's good! I'm sorry if I cause a lot of work for you. I guess I don't really think about the actual clean up involved with destroying a realm." },
				{ Text = "Why, I once slew Asterius in his labyrinth! Some repair work is naught but a trifle in comparison. And it keeps your father satisfied with us!" },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "Does he get frustrated with you when you lose to me?" },
				{ Text = "Occasionally. He comes up here on his way to the surface and speaks with Asterius and I. He's rarely pleased with us. But it's nothing my compatriot and I can't handle!"},
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Well, if you ever need me to have a word with him, just let me know." },
			},

			TheseusAboutThan =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusAboutThan",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				GiftableOffSource = true,
				RequiredAnyTextLines = { "BecameCloseWithThanatos01Than_GoToHim", "BecameCloseWithThanatos01_BThan_GoToHim" },
				RequiredFalseTextLines = {"TheseusGift06"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Blackguard, a most foul rumor has been circulating. Supposedly you've begun a relationship with the god of death himself?"},
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "Than? Yeah, we're dating, not that it's any of your business." },
				{ Text = "You've bestowed a nickname upon the god of death? Given that we face each other in figuratively mortal combat regularly, how would this not be my business?" },
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "It's not like he's going to help me defeat you. Well, unless I ask him to. Maybe you should worry." },
				{ Text = "I absolutely should. Although I have no doubt my dear Asterius and I can take on Death with ease!"},
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I highly doubt that. I guess we'll see!" },
			},
			TheseusAboutMeg =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusAboutMeg",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				GiftableOffSource = true,
				RequiredAnyTextLines = { "BecameCloseWithMegaera01_BMeg_GoToHer", "BecameCloseWithMegaera01Meg_GoToHer" },
				RequiredFalseTextLines = {"TheseusGift06", "AsteriusRomanceQuest05"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Blackguard, you're consorting with a fury?"},
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Who, Meg? Possibly. We used to be together so this isn't a new thing." },
				{ Text = "You have even poorer judgement than I expected, monster. This confirms that you're a fiend from the lowest depths!" },
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "I can date whoever I want. I could date Asterius if he felt like it." },
				{ Emote = "PortraitEmoteAnger", Text = "How dare you lay claim to my Asterius in that way! He has no desire to even speak with you, let alone enter into some sort of relationship!"},
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "Someone's not jealous at all. Let's take out our frustrations on the battlefield, king." },
			},
			TheseusAboutMegAlt =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusAboutMegAlt",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				GiftableOffSource = true,
				RequiredAnyTextLines = { "BecameCloseWithMegaera01_BMeg_GoToHer", "BecameCloseWithMegaera01Meg_GoToHer" },
				RequiredFalseTextLines = {"TheseusGift06", "TheseusAboutMeg"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Blackguard, you're consorting with a fury?"},
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Who, Meg? Possibly. We used to be together so this isn't a new thing." },
				{ Text = "You have even poorer judgement than I expected, monster. This confirms that you're a fiend from the lowest depths!" },
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "I can date whoever I want. Who are you to judge?" },
				{ Emote = "PortraitEmoteAnger", Text = "I have every right to judge you! I'm a king and you're just a monster."},
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "Let's finish this conversation on the battlefield, king." },
			},

			TheseusAboutMegAndThan =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusAboutMegAndThan",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredAnyTextLines = { "TheseusAboutMeg", "TheseusAboutMegAlt" },
				RequiredTextLines = {"TheseusAboutThan", "TheseusGift06"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Zagreus, other shades have told tales of the prince of the Underworld dating not just one but two others. Is this true?"},
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "It is. Gods aren't as worried about monogamy as I've heard mortals can be." },
				{ Text = "I apologize for being so cruel to you when I first heard of your relationships." },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "You were cruel to me pretty much constantly back then. We've moved past that now." },
				{ Emote = "PortraitEmoteAffection", Text = "The forgiveness of a god is truly an unbelievable thing to behold!"},
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "Seriously, it feels weird when you call me a god. Just treat me like normal, minus the angry yelling. You can even call me a daemon again for all I care. Just not a god." },
				{Text = "It feels sacrilegious to do so... daemon."},
			},
			TheseusAboutMegAndThanAlt =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusAboutMegAndThanAlt",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredAnyTextLines = { "BecameCloseWithMegaera01_BMeg_GoToHer", "BecameCloseWithMegaera01Meg_GoToHer" },
				RequiredAnyTextLines = { "BecameCloseWithThanatos01Than_GoToHim", "BecameCloseWithThanatos01_BThan_GoToHim" },
				RequiredTextLines = {"TheseusGift06"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Zagreus, other shades have told tales of the prince of the Underworld dating not just one but two others. Is this true?"},
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "It is. Gods aren't as worried about monogamy as I've heard mortals can be." },
				{ Text = "How wonderful to hear that you've found love with multiple others! The lives of the gods are truly glorious to behold." },
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "Seriously, it feels weird when you call me a god. Just treat me like normal, minus the angry yelling. You can even call me a daemon again for all I care." },
				{Text = "It feels sacrilegious to do so... daemon."},
			},
			TheseusAboutAchilles =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusAboutAchilles",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredAnyTextLines = { "AchillesFirstMeeting", "AchillesFirstMeeting_Alt" },
				RequiredTextLines = {"TheseusGift08", "TheseusHasWeaponUpgrade01"},
				{ PreLineWait = 0.35, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "King, I've asked you this once before, but it was in front of an audience so you didn't give an honest response. Have you ever known Achilles?" },
				{ AngleTowardHero = true, Text = "Achilles? Ah, that hero who was after my time. Shades in Elysium often speak of him! Why do you ask?" },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "Just idle curiousity, really. Elysium is filled with so many legends that I wondered if one like him stood out above the rest." },
				{ Text = "There are legends among legends, Prince. I may be one of many shades here, for instance, but no other can claim the title of Champion of Elysium!"},
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "True, you certainly stand out as well." },
			},
			TheseusAboutCharon =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusAboutCharon",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredTextLines = { "CharonGift03", "TheseusGift06" },
				RequiredSeenRooms = { "D_Hub" },
				{ PreLineWait = 0.35, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Theseus, I was just wondering, what sorts of goods do you and the other shades purchase from Charon? All he does is sell me boons, hearts, and hammers." },
				{ AngleTowardHero = true, Text = "I get my favors from the gods through prayer, not coin. Charon sells no boons to the rest of us. He offers weaponry, armor, building supplies, miscellaneous goods. Everything a shade could possibly need here!" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Wow, that's a lot. I guess he knows I don't need that many options." },
			},

			TheseusAboutSkelly =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusAboutSkelly",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				GiftableOffSource = true,
				RequiredTextLines = { "SkellyGift01"},
				RequiredFalseTextLines = {"TheseusGift06"},
				{ PreLineWait = 0.35, Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "Not sure why I'm bothering to ask, but do you know anything about a skeleton who showed up in my courtyard?" },
				{ AngleTowardHero = true, Emote = "PortraitEmoteSurprise",
					Text = "As if I'd consort with fiendish monsters like you do, blackguard!" },
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "Guess not, then. Really not sure why I even asked you." },
			},
			TheseusAboutMyrmidonReunionQuestComplete01 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusAboutMyrmidonReunionQuestComplete01",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredTextLines = { "MyrmidonReunionQuestComplete", "TheseusGift08" },
				MinRunsSinceAnyTextLines = { TextLines = { "MyrmidonReunionQuestComplete" }, Count = 4 },
				RequiredFalseTextLinesLastRun = { "MyrmidonReunionQuestComplete" },
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "The shade Patroclus told me recently that you reunited him with his long-lost lover." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Achilles? Yeah, I did. I had to break their pact with my father, but they get to spend eternity together now." },
				{ Text = "All of Elysium thanks you. He may have been the gloomiest shade here, yet he refused to drink enough from the river to forget his troubles! I never understood it." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Because he didn't want to forget. Would you drink to forget your father or son?" },
				{ Text = "No, never! I understand now, I believe. The memories may hurt, but they're all we have." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Exactly. But that's not true anymore for Patroclus and Achilles. They'll have each other from now on." },
			},


			TheseusAboutSingersReunionQuestComplete01 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusAboutSingersReunionQuestComplete01",
				PlayOnce = true,
				UseableOffSource = true,
				GiftableOffSource = true,
				UseInitialInteractSetup = true,
				RequiredTextLines = { "OrpheusAboutSingersReunionQuest01" },
				RequiredFalseTextLines = {"TheseusGift06", "TheseusAboutSingersReunionQuestComplete01Alt"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Daemon! I've heard that a court singer was reunited with his muse due to a contract being broken?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "That's right. I broke his contract, rekindling their love. It was rather sweet, really." },
				{ Text = "I'd expect nothing less than for you to use your underhanded, daemonic ways to break a contract." },
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Emote = "PortraitEmoteSurprise",
					Text = "What? It was an unfair contract. You're just trying to yell at me for any reason you can think of." },
				{ Text = "Silence, daemon!" },
			},
			TheseusAboutSingersReunionQuestComplete01Alt =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusAboutSingersReunionQuestComplete01Alt",
				PlayOnce = true,
				UseableOffSource = true,
				GiftableOffSource = true,
				UseInitialInteractSetup = true,
				RequiredTextLines = { "OrpheusAboutSingersReunionQuest01", "TheseusGift06" },
				RequiredFalseTextLines = {"TheseusAboutSingersReunionQuestComplete01"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Zagreus! I've heard that a court singer was reunited with his muse due to a contract being broken?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "That's right. I broke his contract, rekindling their love. It was rather sweet, really." },
				{ Text = "How daring of you, going against Lord Hades himself! You're a legend among gods!" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I don't know about that. I was just trying to help a friend. I'd do the same for you if necessary." },
				{ Text = "Let's hope that will never be the case." },
			},

			TheseusRunCleared =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusRunCleared",
				Priority = true,
				PlayOnce = true,
				UseableOffSource = true,
				GiftableOffSource = true,
				RequiresRunCleared = true,
				UseInitialInteractSetup = true,
				RequiredTextLines = { "PersephoneFirstMeeting" },
				RequiredFalseTextLines = { "Ending01", "TheseusGift06" },
				{ PreLineWait = 0.35, AngleTowardHero = true,
					Text = "Daemon! I've heard tell that you've managed to slay your own father. How despicable, yet I didn't expect any less from you!" },
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "Well he didn't give me much of a choice. And it's not like he didn't come back. Wait, did you just acknowledge that I'm the prince?" },
				{ Emote = "PortraitEmoteAnger", Text = "Absolutely not! Foul monster, you nearly convinced me to spout your lies!" },
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "Or you forgot to deny the truth for once. I'd go with the latter, personally. But yes, I killed him. And I'll kill you again in a minute too." },
			},


	
			TheseusNPCPostEnding01 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusNPCPostEnding01",
				Priority = true,
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				GiftableOffSource = true,
				RequiredTextLines = { "Ending01", "TheseusFirstMeeting" },
				RequiredFalseTextLines = {"TheseusNPCPostEnding01_Alt", "TheseusGift06"},
				MaxRunsSinceAnyTextLines = { TextLines = { "Ending01" }, Count = 20 },

				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Blackguard, you look particularly happy today." },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "I am. Something very good happened to me recently, and I'm quite happy about it." },
				{ Text = "Does this have anything to do with the rumors about the queen?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I couldn't say. Can you promise not to tell anyone but Asterius if I tell you the truth?" },
				{ 
					Text = "Of course you can. Have you ever met anyone more trustworthy or likeable than myself?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Yes. Fine, it's true that my mother returned. Believe it or not, she's the queen, and she's back. And even better, I get to keep fighting my way out of this place. It's my job now." },
				{ 
					Emote = "PortraitEmoteFiredUp",
					Text = "In that case, prepare to fight. I'll fight anyone who espouses such lies about the queen!" },
			},

			TheseusNPCPostEnding01_Alt =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusNPCPostEnding01_Alt",
				Priority = true,
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredTextLines = { "Ending01", "TheseusGift06", "TheseusFirstMeeting" },
				RequiredFalseTextLines = {"TheseusNPCPostEnding01"},
				MaxRunsSinceAnyTextLines = { TextLines = { "Ending01" }, Count = 20 },

				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Is it true, Prince Zagreus? Your mother -- the queen -- has she returned to you?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "She has. It's a bit strange at the moment having her back, but I wouldn't trade it for anything." },
				{ 
					Text = "I've never seen you look this happy. I'm not sure how I ever mistook you for a daemon when you're clearly a god! Will you still come up to Elysium to visit?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Not just to visit. I'll be officially coming to Elysium to fight you so we can help ensure the realm stays secure." },
				{ 
					Text = "Ah, that's outstanding news! Although I can assure you that Elysium is perfectly secure, other than when you break out of it." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "So it's not that secure then?" },
				{ Text = "Hmph. Potentially there are a few flaws. But Asterius and I have been training intensely, and you won't be getting past us again!"},
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "We'll see about that, king." },
			},

			TheseusNPCPostEpilogue01_Alt =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusNPCPostEpilogue01_Alt",
				Priority = true,
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				GiftableOffSource = true,
				RequiredTextLines = { "OlympianReunionQuestComplete", "TheseusGift06", "TheseusFirstMeeting" },
				RequiredFalseTextLines = {"TheseusNPCPostEpilogue01"},
				{ PreLineWait = 0.35, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "{#DialogueItalicFormat}<Whistles>{#PreviousFormat}" },
				{  AngleTowardHero = true, Text = "You seem quite cheerful today, Prince Zagreus!"},
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Hi Theseus! I am. I've told the gods on Olympus the truth about my mother, and we're finally at peace." },
				{ Emote = "PortraitEmoteCheerful", Text = "Such glorious news, my friend! I'm so happy for you. Will you still be visiting us here?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag", Text = "Yep, I'm still employed, so you'll see me around. I was planning to fight you and Asterius shortly."},
				{ Text = "Well, Asterius and I will be ready for you, in that case. And if you want to celebrate sometime with a bottle of ambrosia or two, just let me know. I can throw the grandest parties in Elysium!"},
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag", Text = "Dionysus celebrated enough for all of us, so not today. I'd appreciate a good fight in the stadium, though."},
				{ Text = "A good fight you shall have!"},
			},

			TheseusNPCPostEpilogue01 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusNPCPostEpilogue01",
				Priority = true,
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				GiftableOffSource = true,
				RequiredTextLines = { "OlympianReunionQuestComplete", "TheseusFirstMeeting"},
				RequiredFalseTextLines = {"TheseusNPCPostEpilogue01_Alt"},
				{ PreLineWait = 0.35, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "{#DialogueItalicFormat}<Whistles>{#PreviousFormat}" },
				{ AngleTowardHero = true, Text = "Monster, how dare you whistle in the fields of Elysium!"},
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "I didn't realize that wasn't allowed. My apologies, king." },
				{ Text = "You're forgiven, at least until we meet on the battlefield shortly. Why are you so happy, anyway?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Because I've told the gods on Olympus the truth about my mother, and we're finally at peace. Not that you'll believe a word of that." },
				{ Text = "You're correct, blackguard! Not a word. When I call upon the gods soon and destroy you, you'll see who's really at peace with them." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "That would be me. See you in a bit, Theseus." },
			}, 
			
			TheseusFraternalBondsAftermath_Alt =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusFraternalBondsAftermath_Alt",
				SuperPriority = true,
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				GiftableOffSource = true,
				RequiredAnyTextLines = { "TheseusAboutFraternalBonds06_A", "TheseusAboutFraternalBonds06_B" },
				RequiredTextLines = {"TheseusGift06", "TheseusFirstMeeting"},
				RequiredFalseTextLines = {"TheseusFraternalBondsAftermath"},
				{ PreLineWait = 0.35, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "King, it's good to see you. I wanted to speak to you, if you're willing to talk." },
				{ AngleTowardHero = true, Text = "Of course I am, dearest friend!"},
				{ Emote = "PortraitEmoteSurprise", Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Wait, really? I was sure I'd upset you." },
				{ Text = "That was just a show for the shades. A brief spectacle Asterius and I decided to put on as a form of light entertainment! I'm not the least bit upset with you or Asterius." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag", Text = "You put on a good act, that's for sure. But where have you been all this time?"},
				{ Text = "Asterius and I have been training quite intensely lately. Don't expect to get through us again, former daemon!"},
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag", Text = "We'll see about that, now won't we?"},
			},
			TheseusFraternalBondsAftermath =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusFraternalBondsAftermath",
				SuperPriority = true,
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				GiftableOffSource = true,
				RequiredAnyTextLines = { "TheseusAboutFraternalBonds06_A", "TheseusAboutFraternalBonds06_B" },
				RequiredTextLines = {"TheseusFirstMeeting"},
				RequiredFalseTextLines = {"TheseusFraternalBondsAftermath_Alt", "TheseusGift06"},
				{ PreLineWait = 0.35, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Theseus, I was wondering if we could talk." },
				{ AngleTowardHero = true, Text = "I have nothing to say to you, fiend! You tried to ruin my friendship with my dear Asterius!"},
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "I did nothing of the sort! If you'd only listen to Asterius for a few seconds, you'd see he's telling the truth." },
				{ Emote = "PortraitEmoteSurprise", Text = "How dare you! No one listens to Asterius better than I. I'm the best listener in all of Elysium!" },
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag", Text = "Do you even hear the words that come out of your mouth sometimes? If you'd listened to him, none of this would have happened."},
				{ Text = "I know not what you mean. Regardless, in one of my many displays of benevolence, I've decided to forgive you."},
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag", Text = "Wow, so generous of you. I'd forgive me if I'd done nothing wrong, too."},
				{ Text = "You're forgiven, daemon! I have nothing else to say to you."},
			},
			TheseusNPCExtremeMeasures =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusNPCExtremeMeasures",
				Priority = true,
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				GiftableOffSource = true,
				RequiredMinActiveMetaUpgradeLevel = { Name = "BossDifficultyShrineUpgrade", Count = 3 },
				RequiredTextLines = { "TheseusFirstMeeting", "TheseusExtremeMeasures02"},
				RequiredFalseTextLines = {"TheseusGift06", "TheseusNPCExtremeMeasuresAlt"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Daemon! For once, I have to thank you! By entering the stadium, you'll soon give Asterius and I the opportunity to destroy you while encased in glorious armor!" },
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "Seriously, you do know I'm the reason you have that chariot, don't you? How did you get it?" },
				{ Text = "Lord Hades told me that, due to my excellence as Champion, Asterius and I have earned the honor of wearing this armor on certain occasions during our battles with you!" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Father appealed to your ego instead of telling you the truth, then? In reality, I was getting through you easily enough that I asked for the armor to make our fights more difficult." },
				{ Emote = "PortraitEmoteAnger", Text = "That is simply untrue, daemon! Now, no more lies from you! I must change into my divine suit and prepare to expel this hellspawn from Elysium!" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Have fun with that. And remember, it's all thanks to me!" },
			},
			TheseusNPCExtremeMeasuresAlt =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusNPCExtremeMeasuresAlt",
				Priority = true,
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredMinActiveMetaUpgradeLevel = { Name = "BossDifficultyShrineUpgrade", Count = 3 },
				RequiredTextLines = { "TheseusFirstMeeting", "TheseusExtremeMeasures02", "TheseusGift06"},
				RequiredFalseTextLines = {"TheseusNPCExtremeMeasures"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Prince, soon we will do battle once again in the glorious armor I've been granted by Lord Hades!" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "By Lord Hades? I wasn't kidding before. It was actually all due to a Pact of Punishment I've signed." },
				{ Text = "You're speaking the truth? So he lied when he said that it was due to my prowess on the battlefield?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I'm sure that contributed too. No one but you and Asterius gets to use it, right? So I wouldn't feel too down." },
				{ Text = "You're right. Of course you're right, friend! I never should have doubted myself. Regardless of the cause, I look forward to many more matches of skill between us, both armored and bare!" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I do too, king." },
			},
			TheseusMiscChat01 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusMiscChat01",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				GiftableOffSource = true,
				RequiredTextLines = { "TheseusFirstMeeting"},
				RequiredFalseTextLines = {"TheseusGift06"},
				RequiredMoneyMax = 0,
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Ha! The daemon is bereft of both morals and funds!" },
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "How do you even know how much gold I have?" },
				{ Text = "Fair Charon over there just commented on your impoverished nature. Are you so uneducated that his words are meaningless to you?" },
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "{#DialogueItalicFormat}You {#PreviousFormat}of all people can understand Charon? I was under the impression that his words were meaningless to most." },
				{ Text = "Haha! The daemon's ignorance is clear yet again! Charon and I have had many wondrous conversations about topics a monster such as you would never comprehend." },
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "I honestly can't tell if you're lying or telling the truth, not that I'd care either way." },
			},
			TheseusMiscChat02 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusMiscChat02",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				GiftableOffSource = true,
				RequiredTextLines = { "TheseusFirstMeeting"},
				RequiredFalseTextLines = {"TheseusGift01"},
				{ PreLineWait = 0.35, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Theseus." },
				{ AngleTowardHero = true, Text = "Spineless filth, I crushed a rock underfoot earlier on this day or night and imagined it was your skull!" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Aw, how adorable that you were thinking of me. Am I often in your thoughts?" },
				{ Text = "Brainless scum! How dare you presume that I was thinking of you!" },
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "I mean, did you not just say that you were? Makes me wonder which one of us is brainless." },
				{ Text = "It will be you, blackguard, once I remove your brain with my blessed spear!" },
			},
			TheseusMiscChat03 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusMiscChat03",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredTextLines = { "TheseusFirstMeeting"},
				RequiredFalseTextLines = {"TheseusGift03"},
				{ PreLineWait = 0.35, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Have you ever drunk from the river Lethe, Theseus?" },
				{ AngleTowardHero = true, Text = "What say you, blackguard? How dare you presume to ask such a personal question of the great Theseus?" },
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "Never mind then. Gods forbid I try to make pleasant conversation with you for once." },
				{ Text = "I have not." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Haven't what? Drunk from the river? Let me guess - you'd never want to forget the beauty of your glorious wins in battle? Something like that?" },
				{ Text = "Exactly right, for once. My memories of my life outshine those of all the other shades here. I have no need to forget a single one!" },
			},
			TheseusMiscChat04 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusMiscChat04",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				GiftableOffSource = true,
				RequiredTextLines = { "TheseusFirstMeeting"},
				RequiredFalseTextLines = {"TheseusGift06"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Blackguard, I'd like to extend a generous offer to you, as I am surely the kindest shade you've ever met." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Uh, if you say so. What's the offer?" },
				{ Text = "I'll permit you to enter the stadium as a member of the audience, so you can watch Asterius and I defeat others who would try to take my position as Champion!" },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "Theseus, don't get offended by this, but I have little interest in seeing your battles with the other shades. However, a nice walk through Elysium and bottle of ambrosia would be lovely." },
				{ Emote = "PortraitEmoteAnger", Text = "I would never share my precious ambrosia with you, blackguard! Forget I offered. You clearly have no taste for the finer things in life or death." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Sorry. Like I said, didn't mean to offend." },
			},
			TheseusMiscChat05 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusMiscChat05",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredTextLines = { "TheseusFirstMeeting", "PatroclusFirstMeeting"},
				RequiredFalseTextLines = {"TheseusGift06", "PatroclusWithAchilles01"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Monster, have you run into a shade during your travels through Elysium? One who just sits on the ground gloomily, refusing to engage in combat?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "A gloomy shade who just sits by the river? I know of him. Why?" },
				{ Text = "He frustrates me almost as much as you do! Thrice now I've attempted to regale him with tales of my glory, but he ignores me!" },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "Do shades generally jump at the chance to hear those tales? Not sure why they would." },
				{ Text = "Well, you'd never understand, monster. Yes, shades love hearing them! Why, when I finish my last tale after a few hours of storytelling, their joy is unmistakable!" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Hmm, wonder why!" },
			},
			TheseusMiscMaxChat01 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusMiscMaxChat01",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredTextLines = { "TheseusFirstMeeting", "TheseusGift06"},
				RequiredFalseTextLines = { "TheseusAsteriusIntermission"},
				{ PreLineWait = 0.35, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Hey mate, how are you and Asterius on this day or night?" },
				{ AngleTowardHero = true, Text = "Mate? We may be on more friendly terms now, Prince, but I must inform you that I do not desire to mate with you right now!" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Nor do I at the moment, no worries there. It's just another word for friend." },
				{ Text = "Ah, of course! Mate! Well, mate, Asterius and I are doing beautifully! Elysium is as eternally perfect as ever. What about you, mate?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "You know, please never say that word again." },
				{ Text = "Of course, mate!" },
			},
			TheseusMiscMaxChat02 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusMiscMaxChat02",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredTextLines = { "TheseusFirstMeeting", "TheseusGift08"},
				{ PreLineWait = 0.35, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Hi Theseus! I was just curious, do you know the name of the shade who supports me?" },
				{ AngleTowardHero = true, Text = "I cannot say that I do, my dear friend! I know of whom you speak, as their banner used to rile me up, but I've never spoken with them." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "That's too bad! I was hoping to introduce myself." },
				{ Text = "I'll use my many connections here to identify them for you, Prince! Fear not, you shall know their name soon!" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Thanks, Theseus. I'd appreciate it." },
			},
			TheseusMiscMaxChat03 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusMiscMaxChat03",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredTextLines = { "TheseusFirstMeeting", "TheseusGift08", "TheseusMiscMaxChat02"},
				{ PreLineWait = 0.35, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Theseus, just wanted to see if you'd had any luck figuring out who my good shade is." },
				{ AngleTowardHero = true, Text = "I have, Prince Zagreus! She's named Alice, and she said, quote, 'I'm a huge fan of his and I'm honored he wanted to know my name!', end quote." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Alice! That's good to know. She's been a fan of mine since the beginning." },
				{ Text = "Yes, it used to greatly bother me, back when I was plagued by self doubt! But now I realize that every other shade supports me, so you deserve one fan." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "True, you have more than enough support between Asterius and the audience. Thanks again for helping with that!" },
				{ Text = "It's the least I can do to serve the gods!" },
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "Please don't call me a god. Just Prince or Zagreus is great." },
				{ Text = "Of course, my dear friend!" },
			},
			TheseusMiscMaxChat04 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusMiscMaxChat04",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredTextLines = { "TheseusFirstMeeting", "TheseusGift08"},
				{ PreLineWait = 0.35, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Have I been imagining things, or is the flora in Elysium a bit more vibrant than usual lately?" },
				{ AngleTowardHero = true, Text = "You are not imagining that in the slightest, my brother in arms! I have been spending my leisure hours gardening nonstop to make Elysium beautiful!" },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "Well, it's paying off. I've really noticed the difference lately. Is it still helping you to have something other than combat to look forward to?" },
				{ Text = "Yes, more than you'd dare to believe! Even if I fall to you in battle, which is possible but unlikely, my plants are still there to welcome me afterwards! And they do not judge me, unlike my fellow shades." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "It sounds like it's really helping then! I'm glad to hear it." },
			},
			TheseusMiscMaxChat05 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusMiscMaxChat05",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredTextLines = { "TheseusFirstMeeting", "TheseusGift08"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Blackguard, I mean Prince Zagreus, how are you?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "You know, it honestly doesn't bother me that much anymore if you call me names. It's more affectionate than annoying at this point." },
				{ Text = "Is that so? So if I referred to you as a foul, despicable ingrate you wouldn't be offended?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I mean, that's a bit offensive, which I think you well know. But I don't mind blackguard or daemon." },
				{ Text = "Now that I can be fully certain you are a god, it feels disrespectful to refer to you by such names. But it also feels wrong when I give you the respect of the other gods." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Seriously, don't worry about it. Call me a blackguard all you'd like, king." },
				{ Text = "I shall then, blackguard!" },
			},
			TheseusMiscMaxChat06 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusMiscMaxChat06",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredTextLines = { "TheseusGift08", "AsteriusGift08", "TheseusMiscMaxChat05"},
				MinRunsSinceAnyTextLines = { TextLines = { "TheseusMiscMaxChat07" }, Count = 10 },
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Blackguard! You're just who I wanted to see! I'm in need of your assistance." },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "Sure thing, king. How can I help?" },
				{ Text = "Asterius and I have a date scheduled for this day or night, but I cannot decide on what to wear. Do you think a royal blue tunic or light blue tunic would better show off my body?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Honestly, I think Asterius is going to appreciate your body no matter what you wear. But I'd go for the light blue if I was you." },
				{ Text = "Wonderful! Light blue it is then." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Let me know how it goes!" },
			},
			TheseusMiscMaxChat07 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "TheseusMiscMaxChat07",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredTextLines = { "TheseusGift08", "AsteriusGift08"},
				MinRunsSinceAnyTextLines = { TextLines = { "AsteriusMiscMaxChat02" }, Count = 10 },
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "My friend, would you do me the honor of choosing a drink for the fine meal I have planned for Asterius?" },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "Sure, what are the options?" },
				{ Text = "I've decided to present him with either nectar or ambrosia!" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Funnily enough, he asked me the same question a while ago. Let's mix it up. Why don't you offer him nectar? You both get a lot of ambrosia." },
				{ Text = "Excellent point! A partner as special to me as my dear Asterius deserves an interesting drink, and we drink ambrosia regularly. Nectar it is, then!" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Hope the date goes well!" },
			},

			-- intermission scenes
			TheseusAsteriusIntermission = {
				Name = "TheseusAsteriusIntermission",
				PlayOnce = true,
				Priority = true,
				UseableOffSource = true,
				StatusAnimation = "StatusIconWantsToSmooch",
				GiftableOffSource = true,
				RequiredTextLines = {"TheseusGift08", "AsteriusGift08"},
				{ PreLineWait = 0.35, AngleTowardTargetId = 517230, Emote = "PortraitEmoteAffection", Text = "My precious Asterius, I love you dearly. You make my eternal existence worthwhile." },
				{ Speaker = "NPC_Asterius_01", Portrait = "Portrait_Minotaur_Default_01", Text = "I feel the same way, my king. I'd like to bed you now."},
				{ Text = "Let's make haste to my bedchambers immediately then! Prince, would you be interested in joining us? Asterius and I have realized that we're both attracted to you."},
				{ Text = "TA_ChoiceText01",
					Choices =
					{
						{ ChoiceText = "TA_BeWithThem",
							{ PostLineThreadedFunctionName = "LoungeRevelryPresentation", PostLineFunctionArgs = { Sound = "/VO/Minotaur_0183", Sound2 = "/VO/ZagreusHome_1516", Sound3 = "/VO/Theseus_0303" }, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag", Text = "There's nothing I want more right now."},
							{ FadeOutTime = 0.5, FullFadeTime = 7.8, FadeInTime = 2.0, InterSceneWaitTime = 0.5, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag", Text = "Wow. Can't say I've ever been with a minotaur before. That was incredible."},
							{ AngleTowardHero = true, Text = "Or I a daemon. Well, a prince, I mean. I enjoyed that immensely, Prince."},
							{ Speaker = "NPC_Asterius_01", Portrait = "Portrait_Minotaur_Default_01", Text = "I want to lay with you both again sometime."},
						},
						
						{
							ChoiceText = "TA_BackOff",
							{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
								PreLineAnim = "ZagreusTalkEmpathyStart", PreLineAnimTarget = "Hero",
								PostLineAnim = "ZagreusTalkEmpathy_Return", PostLineAnimTarget = "Hero",
								Text = "I'm sorry, but I'm not comfortable being with the both of you." },
							{ PreLineWait = 0.35, Text = "You're not? But who wouldn't be attracted to this glorious body? And my beautiful Asterius?" },
							{ Portrait = "Portrait_Minotaur_Default_01", Speaker = "NPC_Asterius_01", PreLineWait = 0.35, Text = "King, let him be. Let's go enjoy each other, then we can disembowel him once we return." },
							{ PostLineThreadedFunctionName = "LoungeRevelryPresentation", PostLineFunctionArgs = { Sound = "/VO/Minotaur_0183", Sound2 = "/VO/Theseus_0303", Sound3 = "/EmptyCue" }, Text = "What a wondrous idea, my darling bull!"},
							{ FadeOutTime = 0.5, FullFadeTime = 7.8, FadeInTime = 2.0, InterSceneWaitTime = 0.5, AngleTowardHero = true, Text = "I feel invigorated and ready for battle! We'll see you soon in the stadium, Prince!"},
						}
					},
				},

			},

		},

		
		RepeatableTextLineSets =
		{
			TheseusChat01 =
			{
				Name = "TheseusChat01",
				UseableOffSource = true,
				RequiredTextLines = {"TheseusFirstMeeting"},
				RequiredFalseTextLines = {"TheseusGift06"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "When we meet in the stadium in mere moments, daemon, I shall crush you!" },
			},
			TheseusChat02 =
			{
				Name = "TheseusChat02",
				UseableOffSource = true,
				RequiredTextLines = {"TheseusFirstMeeting"},
				RequiredFalseTextLines = {"TheseusGift06"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Emote = "PortraitEmoteAnger", Text = "Loathsome pustule, you have no right to purchase wares from Charon! Soon you shall be punished with my spear!" },
			},
			TheseusChat03 =
			{
				Name = "TheseusChat03",
				UseableOffSource = true,
				RequiredTextLines = {"TheseusFirstMeeting"},
				RequiredFalseTextLines = {"TheseusGift06"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "I have nothing more to say to you, despicable fiend. But soon we shall converse through battle, when I impale you with my glorious spear!" },
			},
			TheseusChat04 =
			{
				Name = "TheseusChat04",
				UseableOffSource = true,
				RequiredTextLines = {"TheseusFirstMeeting"},
				RequiredFalseTextLines = {"TheseusGift06"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Emote = "PortraitEmoteAnger", Text = "How dare you scorch the grounds of fair Elysium with your burning, monstrous appendages, fiend! I have no wish to engage in dialogue with one such as yourself." },
			},
			TheseusChat05 =
			{
				Name = "TheseusChat05",
				UseableOffSource = true,
				RequiredTextLines = {"TheseusFirstMeeting"},
				RequiredFalseTextLines = {"TheseusGift06"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "You should know one thing and one thing only, blackguard! That's that I will vanquish you soon in front of my adoring audience!" },
			},
			TheseusChat06 =
			{
				Name = "TheseusChat06",
				UseableOffSource = true,
				RequiredTextLines = {"TheseusFirstMeeting"},
				RequiredFalseTextLines = {"TheseusGift06"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "These shades queueing to enter the stadium care not for you, fiend! They come to watch me and Asterius alone." },
			},
			TheseusChat07 =
			{
				Name = "TheseusChat07",
				UseableOffSource = true,
				RequiredTextLines = {"TheseusFirstMeeting"},
				RequiredFalseTextLines = {"TheseusGift06"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "As Champion of Elysium, I'll graciously permit you the honor of engaging with Asterius and I in combat today. You should be grateful, fiend!" },
			},
			TheseusChat08 =
			{
				Name = "TheseusChat08",
				UseableOffSource = true,
				RequiredTextLines = {"TheseusFirstMeeting"},
				RequiredFalseTextLines = {"TheseusGift06"},
				RequiredMaxHealthFraction = 0.25,
				RequiredMaxLastStands = 0,
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Fiend, you are in no fit state to fight Asterius and I! Buy some food from Charon to replenish your health before I disembowel you in mere moments." },
			},
			TheseusChat09 =
			{
				Name = "TheseusChat09",
				UseableOffSource = true,
				RequiredTextLines = {"TheseusFirstMeeting"},
				RequiredFalseTextLines = {"TheseusGift06"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Asterius, could there be a daemon in front of us attempting to speak with me? No, it must have been a trick of the light." },
			},
			TheseusChat10 =
			{
				Name = "TheseusChat10",
				UseableOffSource = true,
				RequiredTextLines = {"TheseusFirstMeeting"},
				RequiredFalseTextLines = {"TheseusGift06"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Daemon, I have no desire to speak with you prior to our battle. Prepare yourself, as you will soon be sent back to the depths from whence you came!" },
			},


			-- max relationship

			TheseusMaxChat01 =
			{
				Name = "TheseusMaxChat01",
				UseableOffSource = true,
				RequiredTextLines = { "TheseusFirstMeeting", "TheseusGift06"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "One whom I formerly referred to as daemon, please avail yourself of Charon's wares so that we may soon face each other in combat!" },
			},
			TheseusMaxChat02 =
			{
				Name = "TheseusMaxChat02",
				UseableOffSource = true,
				RequiredTextLines = { "TheseusFirstMeeting", "TheseusGift06"},
				RequiredMoneyMax = 0,
				{ PostLineThreadedFunctionName = "TheseusGiveMoney", PreLineWait = 0.35, AngleTowardHero = true, Text = "One should not walk around Elysium with a coin purse as bare as yours, Prince. Have some gold!" },
			},
			TheseusMaxChat03 =
			{
				Name = "TheseusMaxChat03",
				UseableOffSource = true,
				RequiredTextLines = { "TheseusFirstMeeting", "TheseusGift06"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Prince Zagreus, Asterius and I have been training fiercely. This next match will be a great one!" },
			},
			TheseusMaxChat04 =
			{
				Name = "TheseusMaxChat04",
				UseableOffSource = true,
				RequiredTextLines = { "TheseusFirstMeeting", "TheseusGift06"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Approach the stadium when you're ready, compatriot. Asterius and I await you!" },
			},
			TheseusMaxChat05 =
			{
				Name = "TheseusMaxChat05",
				UseableOffSource = true,
				RequiredTextLines = { "TheseusFirstMeeting", "TheseusGift06"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "I take no pleasure nowadays in slaying you, Prince, but nothing pleases me more than the joy of combat!" },
			},
			TheseusMaxChat06 =
			{
				Name = "TheseusMaxChat06",
				PlayOnce = true,
				UseableOffSource = true,
				RequiredTextLines = { "TheseusFirstMeeting", "TheseusGift08"},
				RequiredMoneyMax = 50,
				{ PostLineThreadedFunctionName = "TheseusGiveMoney", PreLineWait = 0.35, AngleTowardHero = true,
				Text = "Prince, you have almost no funds left! Let me provide you with some of the many splendors of Elysium in exchange for all that you've done for me!" },
			},
			TheseusMaxChat07 =
			{
				Name = "TheseusMaxChat07",
				UseableOffSource = true,
				RequiredTextLines = { "TheseusFirstMeeting", "TheseusGift08"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "I've been working in the garden again, Prince, nourishing the beauty of Elysium! The azaleas are coming along quite nicely." },
			},
			TheseusMaxChat08 =
			{
				Name = "TheseusMaxChat08",
				UseableOffSource = true,
				RequiredTextLines = { "TheseusFirstMeeting", "TheseusGift08"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "It's glorious to see you again, Prince Zagreus! I eagerly anticipate our upcoming match." },
			},
			TheseusMaxChat09 =
			{
				Name = "TheseusMaxChat09",
				UseableOffSource = true,
				RequiredTextLines = { "TheseusFirstMeeting", "TheseusGift08"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Never again will I let vile thoughts of my inadequacy penetrate my mind, thanks to you!" },
			},
			TheseusMaxChat10 =
			{
				Name = "TheseusMaxChat10",
				UseableOffSource = true,
				RequiredTextLines = { "TheseusFirstMeeting", "TheseusGift08"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Soon we will meet as brothers on the field of battle, and it shall be a glorious occasion!" },
			},
			TheseusMaxChat11 =
			{
				Name = "TheseusMaxChat11",
				UseableOffSource = true,
				RequiredTextLines = { "TheseusFirstMeeting", "TheseusGift08", "AsteriusRomanceQuest05"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "If it were not for you, my dear Zagreus, I would never have known the depth of Asterius's feelings for me. I am most grateful!" },
			},

			TheseusAsteriusIntermission02 = {
				Name = "TheseusAsteriusIntermission02",
				UseableOffSource = true,
				StatusAnimation = "StatusIconWantsToSmooch",
				GiftableOffSource = true,
				MinRunsSinceAnyTextLines = { TextLines = { "TheseusAsteriusIntermission", "TheseusAsteriusIntermission03" }, Count = 10 },
				RequiredTextLines = {"TheseusGift08", "AsteriusGift08", "TheseusAsteriusIntermissionTA_BeWithThem"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Emote = "PortraitEmoteAffection", Text = "Zagreus, Asterius and I were wondering if you'd like to spend some time with us in our chambers before our fight!" },
				{ Speaker = "NPC_Asterius_01", Portrait = "Portrait_Minotaur_Default_01", Text = "We want to bed you, short one."},
				{ PostLineThreadedFunctionName = "LoungeRevelryPresentation", PostLineFunctionArgs = { Sound = "/VO/Minotaur_0183", Sound2 = "/VO/ZagreusHome_1516", Sound3 = "/VO/Theseus_0303" }, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag", Text = "Gods, yes. Let's go there now."},
				{ FadeOutTime = 0.5, FullFadeTime = 7.8, FadeInTime = 2.0, InterSceneWaitTime = 0.5, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag", Text = "I feel like I could win against a thousand champions after that."},
				{ Text = "We'll see if those feelings are correct shortly, dearest Prince!"},
			},

		}, 

		GiftTextLineSets =
		{
			TheseusGift01 =
			{
				Name = "TheseusGift01",
				PlayOnce = true,
				RequiredKills = { Theseus = 5},
				{ PreLineWait = 0.35, AngleTowardHero = true, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Theseus. Not sure why, but I wanted you to have this. As much as it pains me to say it, I've been enjoying our matches." },
				{ 	Text = "What is this, daemon? Is it poisoned? Are you trying to ruin the sanctity of combat with your underhanded daemonic strategies?" },
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "What? What would even be the point when you'd just regenerate immediately? Hasn't anyone ever just done something nice for you?" },
				{	Text = "Yes, frequently. My subjects regularly pledged their loyalty to me when I was their beloved king."},
				{Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "Of course they did. They were your subjects. I'm not. I meant, has anyone just done something nice for you when it wouldn't benefit them in return?" },
				{ Text = "Regularly, daemon. Asterius frequently gives me backrubs after we soundly defeat our combatants in our matches."},
				{Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "You know what? Forget I asked." },
				{ Text = "Gladly."},
				{ Text = "Wait, daemon!"},
				{Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "What?" },
				{ Text = "I've decided I'll offer you this in return. Consider yourself repaid in full for the act of generosity. Now, we must prepare for our battle."},

			},
			TheseusGift02 =
			{
				Name = "TheseusGift02",
				PlayOnce = true,
				RequiredTextLines = { "TheseusGift01" },
				
				{PreLineWait = 0.35, AngleTowardHero = true, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I picked up some extra nectar and thought you might like some, so here." },
				{ Text = "I don't need nectar from a foul, loathsome, evil little cockroach such as yourself!" },
				{Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "Nevermind, then. I'll just take it back." },
				{ Text = "On second thought, I'll keep it! A monster such as you has no need for a delicacy like this anyway." },
				{Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Whatever you say, Theseus. Hope you enjoy the nectar." },
				{ Text = "I will be pouring it out in the river as soon as you're out of sight, daemon. Ready yourself for our battle and your inevitable defeat!" },
			},
			TheseusGift03 =
			{
				Name = "TheseusGift03",
				PlayOnce = true,
				RequiredTextLines = { "TheseusGift02" },
				{ PreLineWait = 0.35, AngleTowardHero = true, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
				Text = "Here's some more nectar for you to dump in the river, Theseus." },
				{Text = "Ah, daemon. You've returned to besmirch the fields of fair Elysium again!" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "If you don't mind me asking, not that I care if you do mind, why do you act like this?" },
				{Text = "Act like what, daemon? Acting is a dishonorable profession." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
				Text = "Act like such a blowhard. You can't honestly be like this all the time. Is it just putting on a front for your audience?" },
				{Text = "I haven't the faintest idea what you mean, fiend."},
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
				Text = "Or are you doing it for me? Because you should know you don't need to act like this. I'd much rather see the real you." },
				{Text = "Leave me be, daemon! I'm warning you. I have nothing else to say to you."},
			},
			TheseusGift04 =
			{
				Name = "TheseusGift04",
				PlayOnce = true,
				RequiredTextLines = { "TheseusGift03" },
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Daemon! You were right earlier." },
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "Wait, what? Right about what? Oh, here's some nectar." },				
				{ Text = "You don't remember our earlier conversation?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Sorry, I can't say I do. You mean our conversation on the battlefield?" },
				{ Text = "No, we spoke here. But regardless, if you cannot even bother to recall our discussion, then it was of no importance." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Sorry, Theseus. I wish I could remember. Can you give me a hint?" },
				{ Text = "You're speaking nonsense, fiend. Go now. We have a battle to fight soon." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I'll try to remember, Theseus. It seems like it was important to you." },
			},

			TheseusGift05 =
			{
				Name = "TheseusGift05",
				PlayOnce = true,
				RequiredTextLines = { "TheseusGift04" },
				{ PreLineWait = 0.35, AngleTowardHero = true, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Theseus, I remember now! I also found you this nectar." },
				{ Text = "Remember what, despicable fiend?" },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "About our conversation. I asked if you acted like this because you were putting on a front, and you said I was right." },
				{ Text = "Hmph. That may potentially be correct, daemon. What of it?" },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "You don't need to do this - insult me, pretend to be so high and mighty, put on a front - any of it." },
				{ Text = "You say that, daemon, but it's the only way those here will respect me. I'm the great King Theseus!" },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "Maybe so, but you're also a shade now. This is a place of eternal rest and prosperity, and you're one of my subjects. You deserve the chance to be yourself." },
				{ Text = "I wish I could rest, daemon. But I can't, not as long as I shall eternally live. This is who I have to be. It's who I am!" },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "I promise that's not true. Let me help you." },
				{ Text = "I'm not worth your help, fiend. I see your sense of judgement is as poor as your skill in the martial ways. I must go now to prepare for combat." },
			},
			TheseusGift06 =
			{
				Name = "TheseusGift06",
				PlayOnce = true,
				RequiredTextLines = { "TheseusGift05" },
				{ PreLineWait = 0.35, AngleTowardHero = true, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I found this nectar for you, Theseus. Would you like it?" },
				{ Text = "Sure, fiend. I suppose I can trust you not to have poisoned it." },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "I wouldn't poison you. I wanted to offer to help you again, actually, in case you've reconsidered." },
				{ Text = "Why would you bother assisting me? I haven't exactly been kind to you." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Oh, I've noticed, trust me. I could have been nicer to you in return. But I'd like to think that that wasn't the true you." },
				{ Text = "You have more faith in me than I have in myself, daemon... Fiend... What's your true name?" },
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "Do you really not know it? I'm Zagreus. Or Prince Zagreus, since you seem like the formal type." },
				{ Text = "Prince Zagreus, then. If you think I'm deserving of your assistance, then I'll be a benevolent king and give you the opportunity to try." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "You are. And I do think that." },
				{ Text = "You truly are a god, aren't you?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I truly am. But honestly, I sort of liked our previous dynamic. Don't feel like you have to treat me like one." },
				{ Text = "It feels wrong to worship you when I regularly slay you on the battlefield. I'm not sure that I could treat you like a god if I tried. Plus, it would confuse the shades. I'll act the same with you in combat as always." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Good. I'll see you shortly, then." },
			},

			-- high relationship / locked gifts
			TheseusGift07 =
			{
				Name = "TheseusGift07",
				PlayOnce = true,
				RequiredTextLines = { "TheseusInsecurityQuest05" },
				{ PreLineWait = 0.35, AngleTowardHero = true, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Theseus, I know it's not much since we win it in our matches all the time, but I wanted to give you this." },
				{ Emote = "PortraitEmoteSurprise", Text = "Ambrosia? Why, that's quite gracious of you, Prince Zagreus! I appreciate the gift regardless of how often I receive it. You are a dear friend of mine, and I don't have many of those." },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "I consider you a good friend too. See you on the battlefield?" },
				{ Text = "I look forward to it." },
			},

			TheseusGift08 =
			{
				Name = "TheseusGift08",
				PlayOnce = true,
				RequiredTextLines = { "TheseusGift07" },
				{ PreLineWait = 0.35, AngleTowardHero = true, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Theseus, it seems a bit ridiculous to keep giving you these, but I thought you might like another bottle." },
				{ Emote = "PortraitEmoteAffection", Text = "More ambrosia? That's not ridiculous at all, my dear friend!" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Would you like to share it now in your chambers before the match begins?" },

				{ PostLineThreadedFunctionName = "LoungeRevelryPresentation", PostLineFunctionArgs = { Sound2 = "/EmptyCue", Sound3 = "/EmptyCue" }, Text = "There's nothing I would love more!"},

				{ FadeOutTime = 0.5, FullFadeTime = 7.8, FadeInTime = 2.0, InterSceneWaitTime = 0.5, Text = "And that's what became of my family."},
				{Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag", Text = "I'm so sorry about your father and son, Theseus."},
				{ Text = "Perhaps now you can see why I'm the kind of man I am. I was a good king, but led a tragic life. It affects me still."},
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I can't imagine dealing with all of that. Have you ever thought about seeking them out?" },
				{ Text = "I can't say I have. Perhaps I will, some day or night. When I'm ready."},
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I'd be nervous too. I felt similarly when I first decided to seek my mother. It was worth it though, in the end." },
				{ Text = "Have I ever said how grateful I am that I can call you a friend now? I wanted to befriend you when we first met, but I never would have said it."},
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag", Emote = "PortraitEmoteSurprise", Text = "Wait, seriously? So all that blustering and shouting was you trying to be my friend? Honestly, I never would have guessed."},
				{ Text = "I suppose I could have been more direct. Regardless, I'm glad that we're friends now. I look forward to many more conversations, drinks, and fierce battles to the death together!"},
				{ Emote = "PortraitEmoteAffection", Portrait = "Portrait_Zag_Default_01",
					PostLineThreadedFunctionName = "MaxedRelationshipPresentation",
					PostLineFunctionArgs = { Text = "NPC_Theseus_01", Icon = "Keepsake_TheseusSticker_Max" },  Text = "I do too, king."},
			},

		},


		GiftGivenVoiceLines =
		{
			{
				BreakIfPlayed = true,
				PreLineWait = 1.0,
				PlayFromTarget = true,

				-- I, uh, thanks.
				{ Cue = "/VO/ZagreusHome_0317" },
			},
		},
	}

EnemyData["NPC_Asterius_01"] = 

	{
	-- Asterius, Id = 1000002
	
		Name = "NPC_Asterius_01",
		InheritFrom = { "NPC_Neutral", "NPC_Giftable" },
		UseText = "UseTalkToThanatos",
		Portrait = "Portrait_Minotaur_Default_01",
		AnimOffsetZ = 240,
		EmoteOffsetX = -50,
		EmoteOffsetY = -250,
		Groups = { "NPCs" },
		GenusName = "Minotaur",
		SkipInitialGiftRequirement = true,
		CanReceiveGift = true,

		Binks = 
		{
			"MinotaurIdle_Bink",
			"MinotaurTaunt_Bink",
		},

		SubtitleColor = Color.MinotaurVoice,

		ActivateRequirements =
		{
			RequiredMinRunsCleared = 1,
		},

		InteractTextLineSets =
		{

			AsteriusFirstMeeting =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "AsteriusFirstMeeting",
				Priority = true,
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				InitialGiftableOffSource = true,
				GiftableOffSource = true,
				RequiredAnyTextLines = { "TheseusFirstAppearance_NotMetMinotaur", "TheseusFirstAppearance_MetBeatMinotaur", "TheseusFirstAppearance_MetNotBeatMinotaur" },
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Greetings, short one." },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "Hello, Bull of Minos. How fares you on this lovely day or night?" },
				{ Text = "I am well. The king and I have been preparing to vanquish you, and I am ready for a fierce battle." },
			},

			AsteriusInsecurityQuest01 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "AsteriusInsecurityQuest01",
				SuperPriority = true,
				PlayOnce = true,
				RequiredTextLines = { "TheseusGift06" },
				{ PreLineWait = 0.35, AngleTowardHero = true, Portrait = "Portrait_Zag_Serious_01", Speaker = "CharProtag",
					Text = "Hi Asterius. I had a question for you about the king." },
				{ Text = "Greetings, short one. What is it?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I've gotten to know him a bit better, and it seems that he's a lot more insecure than he lets on." },
				{ Text = "He is. I'm one of the few who truly knows him. He doesn't have a high opinion of himself." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "That doesn't seem healthy, and I wanted to help him get past that. What's he really like?" },
				{ Text = "Caring, driven, passionate. He's a good man. He saved me from Erebus." },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "It's hard to believe, but I trust you. How can I help him?" },
				{ Text = "Not sure. {#DialogueItalicFormat}<Snort> {#PreviousFormat}He likes to fight you. " },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I enjoy it too. But it doesn't feel like that's enough, if he's spent his whole life and death doing this." },
				{ Text = "Possibly not. But keep fighting him, and maybe he'll open up more to you." },
			},
			AsteriusInsecurityQuest02 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "AsteriusInsecurityQuest02",
				Priority = true,
				PlayOnce = true,
				RequiredTextLines = { "TheseusInsecurityQuest02" },
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Short one. Do you know why I found the king watering plants?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Ah, that would be because of me. I thought it would do him some good to find some hobby other than combat." },
				{ Text = "Combat is my only hobby. Same for you." },
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "I have other hobbies too, you know. He just cares so much about being Champion and being liked. I don't know how to help him move past it." },
				{ Text = "Do you respect him?" },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "Until recently, I would have said no. But I think I do now." },
				{ Text = "Then we both respect him. Show him that that's enough. The shades here don't matter." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Good idea. I'll talk to him. Thanks, Asterius." },
			},
			AsteriusInsecurityQuest03 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "AsteriusInsecurityQuest03",
				Priority = true,
				PlayOnce = true,
				RequiredTextLines = { "TheseusInsecurityQuest05" },
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Short one, I've noticed a change in the king recently." },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "Really? What sort of change?" },
				{ Text = "He's been kinder to the other shades. He shouts less. Are you responsible for this?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "He's responsible. I just tried to help him out a bit." },
				{ Text = "It's good to see. I think he's happier now." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I think he is too." },
			},
			AsteriusRomanceQuest01 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "AsteriusRomanceQuest01",
				SuperPriority = true,
				PlayOnce = true,
				RequiredTextLines = { "AsteriusGift06" },
				MinRunsSinceAnyTextLines = { TextLines = { "AsteriusGift06" }, Count = 3 },
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Short one, have you spoken to the king about my feelings?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "No, not yet. I've been trying to figure out the best way to approach him. You know him better than I do." },
				{ Text = "I am not good at stuff like this. You're better." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Perhaps not, but you still know him better. I thought it would be good to figure out what he thinks about you first." },
				{ Text = "He likes me. He calls me 'dear Asterius'. You hear him." },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "True, but he's also a very theatrical man, so I'm not sure if that indicates any sort of romantic feelings on his end. I'll give it some thought." },
				{ Text = "Thank you." },
			},
			AsteriusRomanceQuest02 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "AsteriusRomanceQuest02",
				Priority = true,
				PlayOnce = true,
				RequiredTextLines = { "AsteriusRomanceQuest01" },
				{ PreLineWait = 0.35, AngleTowardHero = true, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Hi Asterius." },
				{ Text = "Short one. What is it?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I've been thinking, and knowing how much Theseus talks, I'm guessing talking to him would be the best way to figure out his feelings for you." },
				{ Text = "Good idea. See, you're better at this." },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "I'm not so sure about that. I'll try speaking with him." },
				{ Text = "Just make sure he likes you enough first." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I will. Thanks, Asterius." },
			},
			AsteriusRomanceQuest03 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "AsteriusRomanceQuest03",
				Priority = true,
				PlayOnce = true,
				RequiredTextLines = { "TheseusRomanceQuest01" },
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Short one, the king looked distressed. I hope you didn't disturb him?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I sort of did. I asked him what he'd think if I asked you to lay with me." },
				{ Text = "Ah. More direct than I'd expected. What did he say?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "He seemed very, very jealous, so I think you might be right about him returning your feelings." },
				{ Text = "Good. What do I do?" },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "You really haven't had much experience with this, have you?" },
				{ Text = "No. I lived in a dark room for my entire life. I had no opportunity to gain experience." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I'd be inexperienced too, then. The next step is telling him how you feel." },
				{ Text = "Now?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "That's up to you. Do it when you feel ready." },
				{ Text = "Thanks, short one." },
			},
			AsteriusRomanceQuest04 =
			{
				Name = "AsteriusRomanceQuest04",
				Partner = "NPC_Theseus_01",
				UseText = "UseListenNPC",
				BlockDistanceTriggers = true,
				PlayOnce = true,
				UseableOffSource = true,
				GiftableOffSource = true,
				TeleportToId = 515967,
				TeleportOffsetX = -200,
				TeleportOffsetY = 100,
				AngleTowardTargetId = 515967,
				IgnoreStartTextLinesAngleTowardHero = true,
				StatusAnimation = false,
				Priority = true,
				RequiredTextLines = { "TheseusRomanceQuest02" },
				{ PreLineWait = 0.35, AngleTowardTargetId = 515967, Text = "King, I wished to speak with you." },
				{ Portrait = "Portrait_Theseus_Default_01", Speaker = "NPC_Theseus_01",
					Text = "What troubles you, my dear Asterius? You appear to be nervous, and I can't remember ever seeing you nervous in the past." },
				{ Text = "I am nervous. I have feelings for you. I wanted to know if you returned them." },
				{ Portrait = "Portrait_Theseus_Default_01", Speaker = "NPC_Theseus_01",
					Text = "Feelings? As in, romantic feelings? You would like to deepen the eternal bond the two of us share?" },
				{ Text = "Yes. Do you feel the same?" },
				{ Emote = "PortraitEmoteAffection", Portrait = "Portrait_Theseus_Default_01", Speaker = "NPC_Theseus_01",
					Text = "Oh, my sweet bull, I do! I've felt this way for so long, and to know you feel the same! I cannot wait to bed you after our battle." },
				{ Text = "Nor can I, my king. I'm picturing it now." },
				{ Portrait = "Portrait_Theseus_Default_01", Speaker = "NPC_Theseus_01",
					Text = "So am I, my Asterius." },
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "I wish I hadn't overheard all of that, but glad they figured things out!" },
			},
			AsteriusRomanceQuest05 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "AsteriusRomanceQuest05",
				SuperPriority = true,
				PlayOnce = true,
				RequiredTextLines = { "AsteriusRomanceQuest04" },
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Short one." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Yes, Asterius?" },
				{ Text = "I spoke with the king. He returns my feelings." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "That's wonderful!" },
				{ Text = "I couldn't have done it without your help. Thank you." },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "Of course, Asterius. Glad to help out a friend." },
				{ Text = "I've changed my mind. I consider you a friend, now, too." },
			},

			AsteriusKeepsake01 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "AsteriusKeepsake01",
				Priority = true,
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredTrait = "ExtraDashTrait",
				{ PreLineWait = 0.35, AngleTowardHero = true, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag", Text = "Asterius, I wanted to thank you for giving your horn to me. I had a question, though, if it's not too personal." },
				{ Text = "What is it, short one?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag", Text = "Is this {#DialogueItalicFormat}actually{#PreviousFormat} your horn? Did you shed it?" },
				{ Text = "{#DialogueItalicFormat}<Snort> {#PreviousFormat}I'm dead, short one. I can't shed. And that's a replica crafted by an artist here." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag", Text = "Oh, that's good to know. It would have felt a bit odd carrying around one of your horns. Anyway, see you soon in the stadium!" },
			},

			AsteriusPostEnding01 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "AsteriusPostEnding01",
				Priority = true,
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				GiftableOffSource = true,
				RequiredTextLines = { "Ending01" },
				MaxRunsSinceAnyTextLines = { TextLines = { "Ending01" }, Count = 20 },
				{
					Text = "Short one. The king and I heard that your mother has returned?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					PreLineAnim = "ZagreusTalkEmpathyStart", PreLineAnimTarget = "Hero",
					PostLineAnim = "ZagreusTalkEmpathy_Return", PostLineAnimTarget = "Hero",
					Text = "She has! She's back with me and my father. It's been amazing to have her back." },
				{ 
					Text = "Good. Why are you still here preparing to fight us then?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Well, I have a new job now. I'm testing the security of the realm's defenses, so you'll still be seeing me around." },
				{ 
					Text = "Ah, understood. May we have many more fierce battles to the death, then." },

			},


			AsteriusPostEpilogue01 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "AsteriusPostEpilogue01",
				Priority = true,
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				GiftableOffSource = true,
				RequiredTextLines = { "OlympianReunionQuestComplete", "AsteriusFirstMeeting", "MinotaurPostEpilogue01"},
				{ Emote = "PortraitEmoteCheerful", PreLineWait = 0.35, AngleTowardHero = true, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Asterius, how good to see you! Have you heard the news?" },
				{ Text = "About the queen? We spoke about this already."},
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I know, but that was in front of an audience. I wanted to tell you more about it. We held a feast and told the Olympians about her, so now they know the truth." },
				{ Text = "Feasts. {#DialogueItalicFormat}<Snort> {#PreviousFormat}Seem like a waste of time." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Yeah, the feast was a lot of work. But it's over now, and things should be a lot easier for me from now on." },
				{ Text = "Good, short one. They won't be any easier for you here." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I expected nothing less." },
			}, 

			AsteriusFraternalBondsAftermath =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "AsteriusFraternalBondsAftermath",
				SuperPriority = true,
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				GiftableOffSource = true,
				RequiredAnyTextLines = { "TheseusAboutFraternalBonds06_A", "TheseusAboutFraternalBonds06_B" },
				RequiredTextLines = {"AsteriusFirstMeeting"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "Hi Asterius, it's been a while. Are you and Theseus getting along again now?" },
				{ Text = "We are, short one. Our bond will always survive arguments like that."},
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "That's good to hear. Well, I'll see you again in a minute." },
				{ Text = "We'll be ready for you." },
			},
			AsteriusBackstory01 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "AsteriusBackstory01",
				Priority = true,
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				GiftableOffSource = true,
				RequiredTextLines = {"AsteriusFirstMeeting"},
				--Only available when Zag's visited Erebus this run
				RequiredAnyRoomsThisRun = { "RoomChallenge01", "RoomChallenge02", "RoomChallenge03", "RoomChallenge04", "CharonFight01" },
				{ PreLineWait = 0.35, AngleTowardHero = true, Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "Sir, I've been meaning to ask. What was it like for you in Erebus?" },
				{ Text = "Endless dark monotony. Not unlike the labyrinth I spent my life in."},
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "No one deserves that. It sounds like torture." },
				{ Text = "It was, although it was all I'd ever known at that point. The king saved me." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I'm glad." },
			},
			AsteriusBackstory02 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "AsteriusBackstory02",
				Priority = true,
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				GiftableOffSource = true,
				RequiredTextLines = {"AsteriusFirstMeeting", "AsteriusBackstory01"},
				RequiredAnyRoomsThisRun = { "RoomChallenge01", "RoomChallenge02", "RoomChallenge03", "RoomChallenge04", "CharonFight01" },
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "You smell of Erebus, short one. Why?"},
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "You can smell it on me? I visited it earlier. It's as gloomy as ever. I wouldn't want to spend much time there." },
				{ Text = "Neither did I. I'm glad I can experience the joys of life now, in death." },
			},
			AsteriusAboutAriadne01 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "AsteriusAboutAriadne01",
				Priority = true,
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				GiftableOffSource = true,
				RequiredTextLines = {"AsteriusFirstMeeting", "TheseusAboutAriadne01"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Short one, I wanted to speak with you about my sister."},
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "Ariadne? What about her?" },
				{ Text = "She resides somewhere in the Underworld. The king rejected her in life, leaving her to die." },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "He mentioned that. You'd like to find her?" },
				{ Text = "I do not know where to look. But yes." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I'll search for her for you." },
				{ Text = "One more thing. Please don't tell the king who asked you to find her. It's a sensitive subject for the both of us." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Understood. My lips are sealed." },
			},
			AsteriusAboutAriadne02 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "AsteriusAboutAriadne02",
				Priority = true,
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				GiftableOffSource = true,
				RequiredTextLines = {"AsteriusFirstMeeting", "AsteriusAboutAriadne01", "AsteriusGift04"},
				MinRunsSinceAnyTextLines = { TextLines = { "AsteriusAboutAriadne01" }, Count = 10 },
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Short one, have you found her?"},
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "I'm sorry, Asterius, but I haven't been able to yet." },
				{ Text = "I may have found her. I asked other shades, and there's a woman in a cottage who resembles her." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Oh, that's wonderful! You didn't need my help after all. Are you going to speak with her?" },
				{ Text = "I want to, but something's holding me back. Nerves, I think. I'm not familiar with them." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Anyone would be nervous in this situation. I'd be worried if you weren't." },
				{ Text = "You're right, short one. I will deal with my feelings and seek her out." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Good luck, sir." },
			},
			AsteriusAboutAriadne03 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "AsteriusAboutAriadne03",
				Priority = true,
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				GiftableOffSource = true,
				RequiredTextLines = {"AsteriusFirstMeeting", "AsteriusAboutAriadne02", "AsteriusGift04"},
				MinRunsSinceAnyTextLines = { TextLines = { "AsteriusAboutAriadne02" }, Count = 5 },
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "I spoke with my sister, short one."},
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "How did it go?" },
				{ Text = "It went well. She's happy here in Elysium." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "That's amazing news! Was she happy to see you?" },
				{ Text = "We have a complicated history, but yes." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I'm certainly familiar with complicated family histories. It sounds like you have the chance to get to know her better now." },
				{ Text = "I do. And I plan to." },
			},
			AsteriusAboutHades =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "AsteriusAboutHades",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredTextLines = { "AsteriusFirstMeeting", "AsteriusGift04"},
				RequiredMinNPCInteractions = { NPC_Hades_01 = 10 },
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Short one, is your father unkind to you?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "That's putting it lightly. My father is cruel, he doesn't understand me, and he's derided me all my life." },
				{ Text = "I understand. {#DialogueItalicFormat}<Snort> {#PreviousFormat}My father locked me in a labyrinth for my entire life." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Mine doesn't sound as bad as yours, although these chambers feel like a labyrinth at times." },
				{ Text = "Perhaps you will be able to escape, unlike me." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I hope so." },
			},
			AsteriusAboutMeg =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "AsteriusAboutMeg",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredTextLines = { "AsteriusFirstMeeting"},
				RequiredAnyTextLines = { "BecameCloseWithMegaera01Meg_GoToHer", "BecameCloseWithMegaera01_BMeg_GoToHer" },
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Short one, you're laying with the fury Megaera?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "That's a very straightforward way to phrase it, but yes." },
				{ Text = "I am straightforward. And good. You look happy." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I am. We both are, I think. We had a lot to work through, but things are going well for us now." },
			},
			AsteriusAboutThan =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "AsteriusAboutThan",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredTextLines = { "AsteriusFirstMeeting"},
				RequiredAnyTextLines = { "BecameCloseWithThanatos01Than_GoToHim", "BecameCloseWithThanatos01_BThan_GoToHim" },
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "The shades here say that they have seen you with Death." },
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "Than? Yeah, we're together now. Maybe we need to be more discreet about our meetings. I didn't realize there were voyeuristic shades around." },
				{ Text = "The shades here keep a close eye on things." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Maybe that's why a lot of them turn into giant eyeballs when they die." },
				{ Text = "{#DialogueItalicFormat}<Snort> {#PreviousFormat}Maybe so." },
			},
			AsteriusAboutMegAndThan =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "AsteriusAboutMegAndThan",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredTextLines = { "AsteriusFirstMeeting", "AsteriusAboutThan", "AsteriusAboutMeg"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Are you with both Death and the fury, short one? That sounds enjoyable." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Oh, it is. You have no idea." },
				{ Text = "{#DialogueItalicFormat}<Snort> {#PreviousFormat}I can imagine." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "It's better than whatever you're imagining. You can be sure of that." },
				{ Text = "Go prepare for our battle, short one. Then perhaps you can return to them." },
			},

			AsteriusAboutMyrmidonQuest =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "AsteriusAboutMyrmidonQuest",
				Priority = true,
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredTextLines = { "AsteriusFirstMeeting", "PatroclusWithAchilles01", "AsteriusRomanceQuest05"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "I passed by two warriors on my way to the stadium. They mentioned you by name." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Was it Achilles and Patroclus by any chance?" },
				{ Text = "It was. They spoke highly of you." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "They're close friends of mine. I broke the contract keeping them apart, so they're finally reunited." },
				{ Text = "Good. Too many souls are kept apart here. It seems you've reunited many of them." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I'm trying my best." },
			},
			AsteriusAboutExtremeMeasures =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "AsteriusAboutExtremeMeasures",
				Priority = true,
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredMinActiveMetaUpgradeLevel = { Name = "BossDifficultyShrineUpgrade", Count = 3 },
				RequiredTextLines = { "AsteriusFirstMeeting", "MinotaurExtremeMeasures01"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "I was told I'll need to change into my armor again before our fight, short one." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Ah, yes, sorry about that. It looks quite good on you, although I'd imagine it's a bit restrictive." },
				{ Text = "I pride myself on my ability to win with my axe and skills alone. No need for armor." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "That makes two of us. Well, I also get help from the gods, plus powerful weaponry, plus the gifts others have given me. Maybe we're not so evenly matched, on second thought." },
				{ Text = "No, I would say we're not." },
			},
			AsteriusManyRunsCleared =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "AsteriusManyRunsCleared",
				Priority = true,
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredTextLines = { "AsteriusFirstMeeting"},
				RequiredAnyTextLines = {"MinotaurClearProgress01", "MinotaurClearProgress01_B"},
				RequiredMinRunsCleared = 25,
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Has the surface become more familiar to you now, short one?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "It's still strange. I keep getting killed by random things up there, even after I escape. So a bit more familiar, but I still feel out of place." },
				{ Text = "Maybe we both belong below. The surface was not meant for either of us." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Perhaps you're right. " },
			},
			AsteriusSecondMeeting =
			{
				Name = "AsteriusSecondMeeting",
				StatusAnimation = "StatusIconWantsToTalk",
				SuperPriority = true,
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredTextLines = { "AsteriusFirstMeeting"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Sir, it's good to see you out here again. Will you be waiting for me here from now on?" },
				{ Text = "We will, short one. King Theseus and I have decided we can size you up this way. Determine the best strategy to use." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Theseus calls on different gods each time, sure, but don't you use the same strategy every fight?" },
				{ Text = "I do not. The subtleties of combat are clearly lost on you." },
			},
			AsteriusAboutCharon =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "AsteriusAboutCharon",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredTextLines = { "AsteriusFirstMeeting"},
				RequiredAnyTextLines = {"CharonFirstMeeting","CharonFirstMeeting_Alt"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag", Text = "Asterius, do you ever purchase wares from Charon? He seems to have multiple shops set up here." },
				{ Text = "I do not, short one. I have everything I need here already." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I figured you'd say that. Most of the shades here are more materialistic than you are." },
				{ Text = "Yes, the shades here were used to the finer things in life. I was not." },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "At least you get to experience them now." },
			},
			AsteriusAboutPatroclus =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "AsteriusAboutPatroclus",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredTextLines = { "AsteriusFirstMeeting", "PatroclusFirstMeeting"},
				RequiredCodexEntry =
				{
				  EntryName = "NPC_Patroclus_01",
				  EntryIndex = 1,
				},
				RequiredFalseTextLines = {"PatroclusWithAchilles01"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag", Text = "Sir, have you ever run into a shade by the name of Patroclus? He sits by the river Lethe, doesn't talk much, speaks of his long-lost lover." },
				{ Text = "Yes, I know of him. He's more reasonable than most others here." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "You seem like you'd get along with him. Just thought you might want to reach out to him sometime so he has someone to talk with." },
				{ Text = "I'll think about it, short one." },
			},
			AsteriusMiscChat01 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "AsteriusMiscChat01",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredTextLines = { "AsteriusFirstMeeting"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Asterius, it's good to see you! Are you ready for yet another fierce battle to the death?" },
				{ Text = "Always, short one. There is not much else to do here." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Do you ever wish there was something else? What did you do for fun in your labyrinth?" },
				{ Text = "Nothing. {#DialogueItalicFormat}<Snort> {#PreviousFormat}My labyrinth was not fun." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Well, it sounds like battles to the death are much better than that, then. I'll see you for our upcoming one in just a minute." },
			},
			AsteriusMiscChat02 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "AsteriusMiscChat02",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredTextLines = { "AsteriusFirstMeeting"},
				RequiredFalseTextLines = {"AsteriusRomanceQuest05"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag", Text = "Hi there, sir. I was just wondering, do you have chambers here? Or do you and the king live elsewhere?" },
				{ Text = "Both. We have a cottage near here, as all shades do. We have chambers here as well." },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "I never see housing here on my voyages through Elysium, but I suppose I haven't seen much of Elysium." },
				{ Text = "You have not. Plus, those living here don't want their homes destroyed. You don't see them on purpose." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "You have a point. My father has enough work already to do cleaning up after me without having to deal with suddenly homeless shades. It would be nice to see more of Elysium, though." },
				{ Text = "Perhaps you can see more of it now if you win our match." },
			},
			AsteriusMiscChat03 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "AsteriusMiscChat03",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredTextLines = { "AsteriusFirstMeeting", "TheseusGift08", "AsteriusInsecurityQuest03"},
				MinRunsSinceAnyTextLines = { TextLines = { "AsteriusInsecurityQuest03" }, Count = 10 },
				{ PreLineWait = 0.35, AngleTowardHero = true, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag", Text = "How has Theseus been doing lately?" },
				{ Text = "He gardens now in addition to training and fighting. And he's been less boastful." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I'm surprised to hear you call him boastful. You usually don't acknowledge his flaws." },
				{ Text = "We all have flaws, short one. I respect him, so I see no need to discuss his. But they're less obvious now." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I'm glad to hear it." },
			},
			AsteriusMiscChat04 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "AsteriusMiscChat04",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredTextLines = { "AsteriusFirstMeeting"},
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag", PreLineWait = 0.35, AngleTowardHero = true, Text = "Hi, sir. Just wondering, have you ever drunk from the river Lethe? It seems your life was one bad memory after the next." },
				{ Text = "They were not good memories, but I would not choose to forget them. They make me who I am." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "You're stronger than I am, then." },
				{ Text = "We'll see who's stronger shortly." },
			},
			AsteriusMiscChat05 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "AsteriusMiscChat05",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredTextLines = { "AsteriusFirstMeeting"},
				RequiredPlayed = { "/VO/ZagreusHome_0042b" },
				{ PreLineWait = 0.35, AngleTowardHero = true, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag", Text = "Is it ever too much for you here in Elysium? After a lifetime spent in darkness? It's so bright and vibrant here." },
				{ Text = "At times, yes. But I have the solitude and darkness of my chambers in those moments." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "True, sometimes returning to my room after a long run through the Underworld can be quite relaxing. I even talk to my room sometimes."},
				{ Text = "I do not do that, short one. That seems odd." },
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "Well, yeah, it might be a bit odd, I suppose." },
			},
			AsteriusMiscMaxChat01 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "AsteriusMiscMaxChat01",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredTextLines = { "AsteriusFirstMeeting", "AsteriusGift08"},
				RequiredMaxHealthFraction = 0.25,
				RequiredMaxLastStands = 0,
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Short one, you can barely stand. Why would you come here with the intention of fighting us? You cannot win." },
				{ Portrait = "Portrait_Zag_Unwell_01", Speaker = "CharProtag",
					Text = "You're not wrong, but I can't give up just yet! I'm going to make it all the way or die trying." },
				{ Text = "You're going to die trying. I won't back down from a fight, but I can at least make it a fair one. Here, take this." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Some food? Really, sir? Thank you!" },
				{ PostLineThreadedFunctionName = "SisyphusHealing", PreLineWait = 0.35, AngleTowardHero = true, Text = "Don't count on it happening again. But go, prepare yourself. Hopefully the battle will be more enjoyable for the both of us now." },
			},
			AsteriusMiscMaxChat02 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "AsteriusMiscMaxChat02",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredTextLines = { "AsteriusFirstMeeting", "AsteriusGift08"},
				MinRunsSinceAnyTextLines = { TextLines = { "AsteriusGift08" }, Count = 6 },
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Short one, a question." },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "What is it, sir?" },
				{ Text = "I'm planning a meal with the king after our fight. Would he want nectar or ambrosia with his dish?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Aw, a date? I'd love to help. I'd try ambrosia, since there's truly nothing like it here, even if it is common among champions." },
				{ Text = "Thank you, short one. I'll pour ambrosia for him, then." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I hope it goes well!" },
			},
			AsteriusMiscMaxChat03 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "AsteriusMiscMaxChat03",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredTextLines = { "AsteriusFirstMeeting", "AsteriusGift08"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Short one, where do you go when I vanquish you?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Back to the House, through the river Styx. I'm guessing that's not the same for you?" },
				{ Text = "No, I return to my chambers here. So does the king." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "That sounds less wet than what happens to me. I wish I could just return here when I died. It would save me a lot of time." },
				{ Text = "Perhaps you'll make it through here without dying this time." },
			},
			AsteriusMiscMaxChat04 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "AsteriusMiscMaxChat04",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredTextLines = { "TheseusAsteriusIntermissionTA_BeWithThem" },
				MinRunsSinceAnyTextLines = { TextLines = { "TheseusAsteriusIntermissionTA_BeWithThem" }, Count = 5 },
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "The king and I have been speaking about you, short one." },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "Oh? Something good, I hope?" },
				{ Text = "We were wondering if you wanted to be in a relationship with the two of us or just continue bedding us." },
				{ Portrait = "Portrait_Theseus_Default_01", Speaker = "NPC_Theseus_01",
					Text = "Yes, it's up to you, Prince! Asterius and I would be interested either way." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Honestly, I really like the two of you, but I have too many other relationships that I'm trying to figure out at the moment. But please, let's not stop seeing each other. I enjoy it a lot." },
				{ Text = "Understood. Then so it shall be." },
			},
			AsteriusMiscMaxChat05 =
			{
				StatusAnimation = "StatusIconWantsToTalk",
				Name = "AsteriusMiscMaxChat05",
				PlayOnce = true,
				UseInitialInteractSetup = true,
				UseableOffSource = true,
				RequiredTextLines = { "AsteriusFirstMeeting", "AsteriusGift08", "TheseusGift08"},
				MinRunsSinceAnyTextLines = { TextLines = { "AsteriusGift08" }, Count = 20 },
				RequiredCodexEntry =
				{
				  EntryName = "NPC_Patroclus_01",
				  EntryIndex = 1,
				},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Short one, do you know of any nice locations in Elysium for a trip?" },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Like anywhere scenic? The fountain chamber is pretty nice. That glade Patroclus stays in is nice too. What's this for, anyway?" },
				{ Text = "I was searching for somewhere to go with the king." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "I'm guessing the other shades here will know more than I do. I don't see much of Elysium on my rampages through it." },
				{ Text = "I'll ask around, then." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Good luck!" },
			},
		},
		RepeatableTextLineSets =
		{
			AsteriusChat01 =
			{
				Name = "AsteriusChat01",
				UseableOffSource = true,
				RequiredTextLines = {"AsteriusFirstMeeting"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Short one, prepare yourself. We will fight soon." },
			},
			AsteriusChat02 =
			{
				Name = "AsteriusChat02",
				UseableOffSource = true,
				RequiredTextLines = {"AsteriusFirstMeeting"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "My axe is ready for you, short one. Are you ready for it?" },
			},
			AsteriusChat03 =
			{
				Name = "AsteriusChat03",
				UseableOffSource = true,
				RequiredTextLines = {"AsteriusFirstMeeting"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "An audience is waiting for you, short one. Enter when you're ready." },
			},
			AsteriusChat04 =
			{
				Name = "AsteriusChat04",
				UseableOffSource = true,
				RequiredTextLines = {"AsteriusFirstMeeting"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "It is a good day or night to die, short one. One of us will learn this soon." },
			},
			AsteriusChat05 =
			{
				Name = "AsteriusChat05",
				UseableOffSource = true,
				RequiredTextLines = {"AsteriusFirstMeeting"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "The shades are ready for you, short one. As am I." },
			},
			AsteriusChat06 =
			{
				Name = "AsteriusChat06",
				UseableOffSource = true,
				RequiredTextLines = {"AsteriusFirstMeeting"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "The king and I have had a good day or night. I hope you have too, short one." },
			},
			AsteriusChat07 =
			{
				Name = "AsteriusChat07",
				UseableOffSource = true,
				RequiredTextLines = {"AsteriusFirstMeeting"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "The king and I are taking a break after defeating our last challenger. Ready yourself." },
			},
			AsteriusChat08 =
			{
				Name = "AsteriusChat08",
				UseableOffSource = true,
				RequiredTextLines = {"AsteriusFirstMeeting"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Enter the stadium once you are ready, short one. The king and I will be ready for you."},
			},
			AsteriusChat09 =
			{
				Name = "AsteriusChat09",
				UseableOffSource = true,
				RequiredTextLines = {"AsteriusFirstMeeting"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "The maze of chambers guided you to us again, short one. I await our battle." },
			},
			AsteriusChat10 =
			{
				Name = "AsteriusChat10",
				UseableOffSource = true,
				RequiredTextLines = {"AsteriusFirstMeeting"},
				RequiredKillsThisRun = { "Minotaur" },
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "I have recovered from my previous defeat, short one. You fought well. Fight well again." },
			},


			-- max relationship

			AsteriusMaxChat01 =
			{
				Name = "AsteriusMaxChat01",
				UseableOffSource = true,
				RequiredTextLines = { "AsteriusFirstMeeting", "AsteriusGift06"},
				RequiredKillsThisRun = { "Minotaur" },
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Good fight earlier, short one. I enjoy both our battles and our conversations." },
			},
			AsteriusMaxChat02 =
			{
				Name = "AsteriusMaxChat02",
				UseableOffSource = true,
				RequiredTextLines = { "AsteriusFirstMeeting", "AsteriusGift08"},
				RequiredMaxHealthFraction = 0.25,
				RequiredMaxLastStands = 0,
				{ PostLineThreadedFunctionName = "SisyphusHealing", PreLineWait = 0.35, AngleTowardHero = true, Text = "Short one, you look weak. Let me even the odds of our upcoming battle." },
			},
			AsteriusMaxChat03 =
			{
				Name = "AsteriusMaxChat03",
				UseableOffSource = true,
				RequiredTextLines = { "AsteriusFirstMeeting", "AsteriusGift08"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "We have formed a bond, short one, that shall not be disturbed by who wins or loses in combat. Come fight us." },
			},
			AsteriusMaxChat04 =
			{
				Name = "AsteriusMaxChat04",
				UseableOffSource = true,
				RequiredTextLines = { "AsteriusFirstMeeting", "AsteriusGift08"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "The king and I took a walk together earlier. It is thanks to you that our bond has strengthened." },
			},
			AsteriusMaxChat05 =
			{
				Name = "AsteriusMaxChat05",
				UseableOffSource = true,
				RequiredMaxHealthFraction = 0.25,
				RequiredMaxLastStands = 0,
				RequiredTextLines = { "TheseusFirstMeeting", "AsteriusGift08"},
				{ PostLineThreadedFunctionName = "SisyphusHealing", PreLineWait = 0.35, AngleTowardHero = true, Text = "Why would you approach us, short one, when you are too weak to stand, let alone fight? Let me help." },
			},
			AsteriusMaxChat06 =
			{
				Name = "AsteriusMaxChat06",
				UseableOffSource = true,
				RequiredTextLines = { "AsteriusFirstMeeting", "AsteriusGift08", "TheseusAsteriusIntermissionTA_BeWithThem"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "I would like to best you in bed as well as in battle, short one. I hope to do so soon." },
			},
			AsteriusMaxChat07 =
			{
				Name = "AsteriusMaxChat07",
				UseableOffSource = true,
				RequiredTextLines = { "AsteriusFirstMeeting", "AsteriusGift08", "TheseusGift08"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "The king gave me a flower he grew in his garden. He seems happier lately thanks to you, short one." },
			},
			AsteriusMaxChat08 =
			{
				Name = "AsteriusMaxChat08",
				UseableOffSource = true,
				RequiredTextLines = { "AsteriusFirstMeeting", "AsteriusGift08"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "The king and I shared some ambrosia in our chambers. Not sure if it was ambrosia you gave us or ambrosia we won, but it was good either way." },
			},
			AsteriusMaxChat09 =
			{
				Name = "AsteriusMaxChat09",
				UseableOffSource = true,
				RequiredTextLines = { "AsteriusFirstMeeting", "AsteriusGift08"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "I never tire of our battles. I await your presence on the battlefield so we can fight once again." },
			},
			AsteriusMaxChat10 =
			{
				Name = "AsteriusMaxChat10",
				UseableOffSource = true,
				RequiredTextLines = { "AsteriusFirstMeeting", "AsteriusGift08", "AsteriusAboutAriadne03"},
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "Princess Ariadne wanted me to thank you for helping us find each other. So thank you, short one." },
			},
		
			TheseusAsteriusIntermission03 = {
				Name = "TheseusAsteriusIntermission03",
				UseableOffSource = true,
				StatusAnimation = "StatusIconWantsToSmooch",
				GiftableOffSource = true,
				MinRunsSinceAnyTextLines = { TextLines = { "TheseusAsteriusIntermission", "TheseusAsteriusIntermission02" }, Count = 10 },
				RequiredTextLines = {"TheseusGift08", "AsteriusGift08", "TheseusAsteriusIntermissionTA_BeWithThem"},
				{ PreLineWait = 0.35, Text = "Short one. Will you lay with us?" },
				{ Speaker = "NPC_Theseus_01", Portrait = "Portrait_Theseus_Default_01", Emote = "PortraitEmoteAffection", Text = "My dearest Prince, my desire for you is more than I can bear! Please say yes."},
				{ PostLineThreadedFunctionName = "LoungeRevelryPresentation", PostLineFunctionArgs = { Sound = "/VO/Minotaur_0183", Sound2 = "/VO/ZagreusHome_1516", Sound3 = "/VO/Theseus_0303" }, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag", Text = "How could I ever say no to that?"},
				{ FadeOutTime = 0.5, FullFadeTime = 7.8, FadeInTime = 2.0, InterSceneWaitTime = 0.5, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag", Text = "Wow. We need to do that again soon."},
				{ Speaker = "NPC_Theseus_01", Portrait = "Portrait_Theseus_Default_01", Text = "I couldn't agree more! Our battles in bed are even more glorious than our battles in the stadium!"},
				{ Text = "I enjoy both."},
			},

		},

		GiftTextLineSets =
		{
			AsteriusGift01 =
			{
				Name = "AsteriusGift01",
				PlayOnce = true,
				RequiredTextLines = {"MinotaurAboutFriendship01" }, 
				{ PreLineWait = 0.35, Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					PreLineAnim = "ZagreusTalkEmpathyStart", PreLineAnimTarget = "Hero",
					PostLineAnim = "ZagreusTalkEmpathy_Return", PostLineAnimTarget = "Hero",
					Text = "Asterius, I thought I'd offer you one of those bottles of nectar again. Any chance you'll take it this time?" },
				{ AngleTowardHero = true, Text = "I have no need of gifts, short one. But I'll take it. It'll help me quench my thirst before our battle." },
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "Thirst? Do shades really get thirsty?" },
				{ Text = "Figure of speech. You take things too literally, short one. But thank you. Take this in return." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Anytime, Asterius." },
			},
			AsteriusGift02 =
			{
				Name = "AsteriusGift02",
				PlayOnce = true,
				RequiredTextLines = { "AsteriusGift01" },
				
				{PreLineWait = 0.35, AngleTowardHero = true, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Sir, I found some more nectar and thought I'd offer it to you for being such a good friend." },
				{ Text = "We are not friends, short one. I have no need of friends. But you are a worthy challenger." },
				{Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "You're friends with Theseus, are you not?" },
				{ Text = "The king and I share an incomparable bond. Friendship does not describe it." },
				{Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Well, I hope we'll share a bond like that someday." },
				{ Text = "Maybe we will, short one." },
			},
			AsteriusGift03 =
			{
				Name = "AsteriusGift03",
				PlayOnce = true,
				RequiredTextLines = { "AsteriusGift02" },
				{ PreLineWait = 0.35, AngleTowardHero = true, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
				Text = "Asterius, I wanted to give you this. I know it's not much, but I hoped you'd take it again?" },
				{Text = "More nectar? You keep giving me this." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Well, I enjoy your company, and I like handing out gifts to those whose company I enjoy." },
				{Text = "I'll accept it then, short one. Your company is enjoyable as well." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
				Text = "Aw, thank you, Asterius!" },
			},
			AsteriusGift04 =
			{
				Name = "AsteriusGift04",
				PlayOnce = true,
				RequiredTextLines = { "AsteriusGift03" },
				{ PreLineWait = 0.35, AngleTowardHero = true, Text = "More nectar, short one?" },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "If you'd like some. Do you? I could give you ambrosia instead." },				
				{ Text = "No need. I have too much of it." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Yeah, I guess as a champion you'd have more than enough already." },
				{ Text = "Not a champion. The king is a champion." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "You don't give yourself enough credit. You're both champions in my book." },
				{ Text = "{#DialogueItalicFormat}<Snort> {#PreviousFormat}The king would disagree." },
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "Well, who cares what he thinks? I guess you do." },
				{ Text = "Correct. Go, short one. We fight soon." },
			},

			AsteriusGift05 =
			{
				Name = "AsteriusGift05",
				PlayOnce = true,
				RequiredTextLines = { "AsteriusGift04" },
				{ Text = "Why do you want to befriend me, short one?" },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "Like I've said in the past, I like you. I'm glad you find me a worthy challenger, but I'd like to be more than that to you." },
				{ Text = "More? A friend? A sexual partner?" },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "Well, either one would be fine with me, to be honest. But I was referring to the former." },
				{ Text = "You are not unattractive, but my heart belongs to King Theseus." },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "Wait, really? Are you and he together?" },
				{ Text = "No. But that is beside the point." },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "Oh, so you like him but haven't told him? I haven't gotten to play matchmaker in ages. I'd be happy to help out, sir, if you want." },
				{ Text = "I do not, short one. Leave it be." },
			},
			AsteriusGift06 =
			{
				Name = "AsteriusGift06",
				PlayOnce = true,
				RequiredTextLines = { "AsteriusGift05" },
				{ Text = "Short one, thank you. Can we speak?" },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "Of course, Asterius. Always happy to talk to you. What do you need?" },
				{ Text = "The matter we spoke of earlier -- my wish to lay with the king. Help me with that." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "So you do want my assistance? Oh, absolutely! I'd love to help out." },
				{ Text = "Please do not be too direct with him. That's a weakness of mine. You're better at this than I am." },
				{ Portrait = "Portrait_Zag_Defiant_01", Speaker = "CharProtag",
					Text = "I'll be careful, Asterius. Don't worry." },
			},

			-- high relationship / locked gifts
			AsteriusGift07 =
			{
				Name = "AsteriusGift07",
				PlayOnce = true,
				RequiredTextLines = { "AsteriusRomanceQuest05" },
				{ PreLineWait = 0.35, AngleTowardHero = true, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Sir, this is really a waste of time given that we both have large amounts of ambrosia, but here. One more for your collection." },
				{ Text = "Thank you, short one. The king and I will share it after our battle." },
				{ Portrait = "Portrait_Zag_Empathetic_01", Speaker = "CharProtag",
					Text = "I'll see you out there soon!" },
			},

			AsteriusGift08 =
			{
				Name = "AsteriusGift08",
				PlayOnce = true,
				RequiredTextLines = { "AsteriusGift07" },
				{ PreLineWait = 0.35, AngleTowardHero = true, Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Here's another bottle of ambrosia for you and the king!" },
				{ Text = "Thank you, short one. No more, please. We have more than enough to last the rest of our eternal lives." },
				{ Portrait = "Portrait_Zag_Default_01", Speaker = "CharProtag",
					Text = "Of course, sir. I would be honored to share a bottle with you as well if you ever have the time." },
				{ Text = "I'll keep that in mind, short one. I have few friends, but I'm glad you're one of them."},
				{ Emote = "PortraitEmoteAffection", Portrait = "Portrait_Zag_Default_01",
					PostLineThreadedFunctionName = "MaxedRelationshipPresentation",
					PostLineFunctionArgs = { Text = "NPC_Asterius_01", Icon = "Keepsake_AsteriusSticker_Max" },  Text = "I'm glad we're friends now too, Asterius."},
			},

		},

		GiftGivenVoiceLines =
		{
			{
				BreakIfPlayed = true,
				PreLineWait = 1.0,
				PlayFromTarget = true,

				-- Thanks for that, sir.
				{ Cue = "/VO/ZagreusHome_0320" },
			},
		},
	}
	

DebugPrint({Text = "Theseus/Asterius mod added"})


		