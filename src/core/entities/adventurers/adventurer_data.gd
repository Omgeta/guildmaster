extends CharacterData
class_name AdventurerData

enum AdventurerClass { Warrior, Mage, Rogue }

@export var level: int = 1
@export var experience: int = 0
@export var class_: AdventurerClass = AdventurerClass.Warrior
@export var weapon_id: String = ""
@export var armor_id: String = ""
@export var accessory_id: String = ""
@export var origin: OriginData
@export var rarity: int  # 1–5 stars
@export var in_mission: bool = false
