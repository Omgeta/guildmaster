extends Node

const CHARACTER_NAMES := preload("res://core/characters/assets/data/character_names.json").data
const FIRST_NAME_ONLY_CHANCE := 0.3
const NECESSARY_SPRITES: Array[String] = [SpriteCache.BODY, SpriteCache.OUTFIT, SpriteCache.HAIR]
const OPTIONAL_SPRITES: Dictionary[String, float] = {SpriteCache.ACCESSORY: 0.3}
const BASE_STATS: Dictionary[String, Dictionary] = {
	"Warrior": {"HP": 100, "ATK": 15, "DEF": 10},
	"Magician": {"HP": 70, "ATK": 25, "DEF": 5},
	"Rogue": {"HP": 80, "ATK": 20, "DEF": 7}
}


static func random_character_name() -> String:
	var first = CHARACTER_NAMES["first_names"].pick_random()
	if randf() < FIRST_NAME_ONLY_CHANCE:
		return first

	var last = CHARACTER_NAMES["last_names"].pick_random()
	return "%s %s" % [first, last]


static func random_sprite_ids() -> Dictionary[String, String]:
	var res: Dictionary[String, String] = {}

	for cat in NECESSARY_SPRITES:
		res[cat] = SpriteCache.random_sprite(cat)

	for cat in OPTIONAL_SPRITES:
		var p = OPTIONAL_SPRITES[cat]
		if randf() < p:
			res[cat] = SpriteCache.random_sprite(cat)

	return res


static func compute_stats(char_class: String, rank: int) -> Dictionary[String, int]:
	var stats: Dictionary[String, int] = {}
	var base = BASE_STATS[char_class]
	var scale = roundi(float(rank) / base.size())
	for key in base:
		stats[key] = base[key] * scale
	return stats


static func from_origin(origin: OriginResource) -> CharacterResource:
	var char_class = origin.random_class()

	return CharacterResource.init(
		random_character_name(),
		origin,
		origin.random_alignment(),
		char_class,
		compute_stats(char_class, origin.random_rank()),
		random_sprite_ids()
	)
