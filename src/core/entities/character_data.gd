extends Resource
class_name CharacterData

enum Tag {
	Chaotic,
	Orderly,
	Undead,
	Goblin,
	Outlaw,
	Demon,
	Royalty,
	Military,
	Magic,
	Merchant,
	Cult,
	Divine,
	Dragon
}

@export var id: String  # unique ID for saves
@export var display_name: String
@export var base_stats: CharacterStats  # stats resource
@export var character_sprites: CharacterSprites  # sprites resource
@export var tags: Array[Tag] = []
