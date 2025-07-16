extends Node
class_name AdventurerFactory

const AdventurerClass = AdventurerData.AdventurerClass
const NAMES := preload("res://src/entities/data/character_names.json").data
const FIRST_NAME_ONLY_CHANCE := 0.30
const NECESSARY := ["body", "outfit", "hair"]
const OPTIONAL: Dictionary[String, float] = {"accessory": 0.30}
const BASE_STATS: Dictionary[AdventurerClass, Dictionary] = {
	AdventurerClass.Warrior: {"hp": 100, "atk": 25, "dex": 15, "mag": 15, "def": 5},
	AdventurerClass.Mage: {"hp": 100, "atk": 15, "dex": 25, "mag": 25, "def": 5},
	AdventurerClass.Rogue: {"hp": 100, "atk": 15, "dex": 15, "mag": 15, "def": 5}
}

const uuid_util = preload("res://addons/uuid/uuid.gd")


static func create_from_origin(origin: OriginData) -> AdventurerData:
	var data := AdventurerData.new()

	data.id = uuid_util.v4()
	data.display_name = _random_name()
	data.rarity = _get_rarity(origin.base_rank)
	data.level = 1
	data.class_ = origin.random_class()
	data.tags = origin.tags.duplicate(true)
	data.origin = origin
	data.base_stats = _compute_stats(data.class_, origin.base_rank)
	data.character_sprites = _random_sprite_resource()

	return data


static func _get_rarity(rank: int) -> int:
	return RNG.randi_range(rank, 5)


static func _random_name() -> String:
	var first: String = RNG.choose(NAMES["first_names"])
	if RNG.randf() < FIRST_NAME_ONLY_CHANCE:
		return first
	var last: String = RNG.choose(NAMES["last_names"])
	return "%s %s" % [first, last]


static func _random_sprite_resource() -> CharacterSprites:
	var res := CharacterSprites.new()

	# required layers
	for cat in NECESSARY:
		res.set(cat, _rand_sprite_id(cat))

	# optional layers
	for cat in OPTIONAL:
		if RNG.randf() < OPTIONAL[cat]:
			res.set(cat, _rand_sprite_id(cat))
	return res


static func _rand_sprite_id(category: String) -> String:
	return SpriteDB.get_random_in_category(category)


static func _compute_stats(char_class: AdventurerClass, rank: int) -> CharacterStats:
	var base := BASE_STATS[char_class]
	var s := CharacterStats.new()
	var factor := 0.6 + 0.1 * rank  # TODO: change scaling
	s.hp = int(base.hp * factor)
	s.atk = int(base.atk * factor)
	s.dex = int(base.dex * factor)
	s.mag = int(base.mag * factor)
	s.def = int(base.def * factor)
	return s
