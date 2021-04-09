enum {
	Handshake = 0,
	Intro = 1,
	Welcome = 2,
	Spawn = 3,
	List = 4,
	Who = 5,
	Equipment = 6,
	Ready = 7,
	Sync = 8,
	Movement = 9,
	Teleport = 10,
	Request = 11,
	Despawn = 12,
	Target = 13,
	Combat = 14,
	Animation = 15,
	Projectile = 16,
	Population = 17,
	Points = 18,
	Network = 19,
	Chat = 20,
	Command = 21,
	Inventory = 22,
	Bank = 23,
	Ability = 24,
	Quest = 25,
	Notification = 26,
	Blink = 27,
	Heal = 28,
	Experience = 29,
	Death = 30,
	Audio = 31,
	NPC = 32,
	Respawn = 33,
	Trade = 34,
	Enchant = 35,
	Guild = 36,
	Pointer = 37,
	PVP = 38,
	Click = 39,
	Warp = 40,
	Shop = 41,
	Minigame = 42,
	Region = 43,
	Overlay = 44,
	Camera = 45,
	Bubble = 46,
	Client = 47,
	Profession = 48,
	BuildUp = 49
}

enum IntroOpcode {
	Login = 0,
	Register = 1,
	Guest = 2
}

enum EquipmentOpcode {
	Batch = 0,
	Equip = 1,
	Unequip = 2
}

enum MovementOpcode {
	Request = 0,
	Started = 1,
	Step = 2,
	Stop = 3,
	Move = 4,
	Orientate = 5,
	Follow = 6,
	Entity = 7,
	Freeze = 8,
	Stunned = 9,
	Zone = 10
}

enum TargetOpcode {
	Talk = 0,
	Attack = 1,
	None = 2,
	TargetObject = 3
}

enum CombatOpcode {
	Initiate = 0,
	Hit = 1,
	Finish = 2,
	Sync = 3
}

enum ProjectileOpcode {
	Static = 0,
	Dynamic = 1,
	Create = 2,
	Update = 3,
	Impact = 4
}

enum NetworkOpcode {
	Ping = 0,
	Pong = 1
}

enum InventoryOpcode {
	Batch = 0,
	Add = 1,
	Remove = 2,
	Select = 3
}

enum BankOpcode {
	Batch = 0,
	Add = 1,
	Remove = 2,
	Select = 3
}

enum QuestOpcode {
	QuestBatch = 0,
	AchievementBatch = 1,
	Progress = 2,
	Finish = 3
}

enum NotificationOpcode {
	Ok = 0,
	YesNo = 1,
	Text = 2,
	Popup = 3
}

enum ExperienceOpcode {
	Combat = 0,
	Profession = 1
}

enum NPCOpcode {
	Talk = 0,
	Store = 1,
	Bank = 2,
	Enchant = 3,
	Countdown = 4
}

enum TradeOpcode {
	Request = 1,
	Accept = 2,
	Decline = 3
}

enum EnchantOpcode {
	Select = 0,
	Remove = 1,
	Enchant = 2,
	Update = 3
}

enum GuildOpcode {
	Create = 0,
	Join = 1,
	Leave = 2,
	Rank = 3,
	Loot = 4
}

enum PointerOpcode {
	Location = 0,
	NPC = 1,
	Relative = 2,
	Remove = 3,
	Button = 4
}

enum ShopOpcode {
	Open = 0,
	Buy = 1,
	Sell = 2,
	Refresh = 3,
	Select = 4,
	Remove = 5
}

enum RegionOpcode {
	Render = 0,
	Modify = 1,
	Tileset = 2,
	Update = 3,
	Reset = 4,
	Doors = 5
}

enum OverlayOpcode {
	Set = 0,
	Remove = 1,
	Lamp = 2,
	RemoveLamps = 3,
	Darkness = 4
}

enum CameraOpcode {
	LockX = 0,
	LockY = 1,
	FreeFlow = 2,
	Player = 3
}

enum CommandOpcode {
	CtrlClick = 0
}

enum ProfessionOpcode {
	Batch = 0,
	Update = 1
}
