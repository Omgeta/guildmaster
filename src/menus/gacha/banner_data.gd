extends Resource
class_name BannerData

@export var id: String  # "beginner", "premium" (no need for uuid)
@export var display_name: String  # shown in UI
@export var image: Texture2D  # banner splash art
@export var pull_logic: Script  # inherits GachaPullLogic

@export var min_rarity: int = 1
@export var pull_cost: int = 100
@export var tag_bias: Array[CharacterData.Tag] = []
@export var enabled: bool = true
