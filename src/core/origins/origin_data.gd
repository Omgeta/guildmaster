extends Resource
class_name OriginData

const AdventurerClass = AdventurerData.AdventurerClass

@export var id: String
@export var display_name: String
@export_range(1, 5, 1) var base_rank: int = 1  # minimum rarity of adventurers generated
@export var frequency: int = 10  # pull weight (higher = common)
@export var tags: Array[String]
@export var alignment: String  # "Chaotic" | "Orderly" | "Neutral"
@export var class_dist: Dictionary[AdventurerClass,int] = {
	AdventurerClass.Warrior: 33, AdventurerClass.Mage: 33, AdventurerClass.Rogue: 34
}


func random_class() -> AdventurerClass:
	return RNG.choose_weighted(class_dist)
