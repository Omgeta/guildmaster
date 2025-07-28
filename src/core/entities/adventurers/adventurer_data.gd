extends CharacterData
class_name AdventurerData

enum Class { Warrior, Mage, Rogue }
enum Alignment { Orderly, Neutral, Chaotic }

@export_range(1, 99, 1) var level: int = 1
@export var experience: int = 0
@export var class_: Class
@export var alignment: Alignment = Alignment.Neutral
@export var origin: OriginData
@export_range(1, 5, 1) var rarity: int = 1  # 1–5 stars
@export var stat_growths: CharacterStats

@export var in_mission: bool = false
@export var seen: bool = false

@export var weapon_id: String = ""
@export var armor_id: String = ""
@export var accessory_id: String = ""
