extends Resource
class_name OriginData

const Class := AdventurerData.Class
const Alignment := AdventurerData.Alignment
const BASE_DIST: Dictionary[Class,int] = {Class.Warrior: 33, Class.Mage: 33, Class.Rogue: 34}

@export var id: String
@export var display_name: String
@export_range(1, 5, 1) var base_rank: int = 1  # minimum rarity of adventurers
@export var tags: Array[CharacterData.Tag] = []
@export var alignment: Alignment = Alignment.Neutral
@export var class_dist: Dictionary[Class,int] = BASE_DIST
