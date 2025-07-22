extends Resource
class_name BannerData

@export var id: String  # "beginner", "premium" (no need for uuid)
@export var display_name: String  # shown in UI
@export var image: Texture2D  # banner splash art
@export var pull_logic: Script  # inherits GachaPullLogic

@export_range(1, 5, 1) var min_rarity: int = 1
@export_range(1, 5, 1) var max_rarity: int = 5
@export var pull_cost: int = 100
@export var tag_bias: Array[CharacterData.Tag] = []
