extends Resource
class_name ItemData

@export var id: String
@export var name: String
@export_multiline var description: String
@export var icon: Texture2D
@export_range(1, 5, 1) var rarity: int = 1
@export var stack_limit: int = 99
