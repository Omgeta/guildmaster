extends Node
class_name AdventurerFactory

const NECESSARY := ["body", "outfit", "hair"]
const OPTIONAL: Dictionary[String, float] = {"accessory": 0.30}

const FIRST_NAME_ONLY_CHANCE := 0.30
const NAMES := preload("res://src/core/entities/assets/data/character_names.json").data

const Class = AdventurerData.Class
const BASE_STATS: Dictionary[Class, Dictionary] = {
	Class.Warrior: {"hp": 100, "atk": 25, "dex": 15, "mag": 15},
	Class.Mage: {"hp": 100, "atk": 15, "dex": 15, "mag": 25},
	Class.Rogue: {"hp": 100, "atk": 15, "dex": 25, "mag": 15}
}

const MAX_RARITY = 5
const MIN_RARITY = 1
const DEF_DECAY = 0.35

const uuid_util = preload("res://addons/uuid/uuid.gd")


static func create_from_origin(origin: OriginData) -> AdventurerData:
	var data := AdventurerData.new()

	# character data
	data.id = uuid_util.v4()
	data.display_name = _random_name()
	data.character_sprites = _random_sprite_resource()
	data.tags = _get_tags_subset(origin.tags)

	# adventurer data
	data.level = 1
	data.rarity = _get_rarity(origin.base_rank)
	data.base_stats = _compute_stats(data.class_, data.rarity)
	data.class_ = _random_class(origin.class_dist)
	data.alignment = origin.alignment
	data.origin = origin

	return data


static func _random_name() -> String:
	var first: String = RNG.choose(NAMES["first_names"])
	if RNG.randf() < FIRST_NAME_ONLY_CHANCE:
		return first
	var last: String = RNG.choose(NAMES["last_names"])
	return "%s %s" % [first, last]


static func _get_tags_subset(tags: Array[CharacterData.Tag]) -> Array[CharacterData.Tag]:
	tags = tags.duplicate(true)
	tags.shuffle()
	return tags.slice(0, RNG.randi_range(0, tags.size() - 1))


static func _get_rarity(rank: int, decay: float = DEF_DECAY) -> int:
	# create array of exponential odds
	var steps := MAX_RARITY - rank
	var raw := []
	for i in range(steps + 1):
		raw.append(pow(decay, i))

	# normalize to probabilities
	var total := 0.0
	for w in raw:
		total += w
	for i in range(raw.size()):
		raw[i] /= total

	# pick one via accumulated probability
	var roll := RNG.randf()
	var acc := 0.0
	for i in range(raw.size()):
		acc += raw[i]
		if roll <= acc:
			return rank + i

	# fallback if something weird happens idk
	return MAX_RARITY


static func _random_sprite_resource() -> CharacterSprites:
	var res := CharacterSprites.new()

	# required layers
	for cat in NECESSARY:
		res.set(cat, _random_sprite_id(cat))

	# optional layers
	for cat in OPTIONAL:
		if RNG.randf() < OPTIONAL[cat]:
			res.set(cat, _random_sprite_id(cat))
	return res


static func _random_sprite_id(category: String) -> String:
	return SpriteDB.get_random_in_category(category)


static func _compute_stats(char_class: Class, rarity: int) -> CharacterStats:
	var factor := pow(rarity, log(2.5) / log(5))
	var base := BASE_STATS[char_class]
	var s := CharacterStats.new()
	for stat in base:
		s[stat] = int(base[stat] * factor)
	return s


static func _random_class(class_dist: Dictionary[Class, int]) -> Class:
	return RNG.choose_weighted(class_dist)
