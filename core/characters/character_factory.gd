extends Node
## Static class used to generate `CharacterResource` data

## List of character name data (first and last names)
const CHARACTER_NAMES := preload("res://core/characters/assets/data/character_names.json").data

## Chance that a character only has a first name (e.g., 30%)
const FIRST_NAME_ONLY_CHANCE := 0.3

## Required sprite categories for character appearance
const NECESSARY_SPRITES: Array[String] = [SpriteCache.BODY, SpriteCache.OUTFIT, SpriteCache.HAIR]

## Optional sprite categories and their probabilities
const OPTIONAL_SPRITES: Dictionary[String, float] = {SpriteCache.ACCESSORY: 0.3}

## Base stats per character class
const BASE_STATS: Dictionary[String, Dictionary] = {
	"Warrior": {"HP": 100, "ATK": 15, "DEF": 10},
	"Magician": {"HP": 70, "ATK": 25, "DEF": 5},
	"Rogue": {"HP": 80, "ATK": 20, "DEF": 7}
}


## Generates a random character name from predefined name lists.
static func random_character_name() -> String:
	var first = CHARACTER_NAMES["first_names"].pick_random()
	if randf() < FIRST_NAME_ONLY_CHANCE:
		return first

	var last = CHARACTER_NAMES["last_names"].pick_random()
	return "%s %s" % [first, last]


## Generates a dictionary of sprite IDs for all necessary and some optional layers.
## Uses `SpriteCache` to randomly select valid sprite IDs from each category.
static func random_sprite_ids() -> Dictionary[String, String]:
	var res: Dictionary[String, String] = {}

	for cat in NECESSARY_SPRITES:
		res[cat] = SpriteCache.MAP.get(cat, {}).keys().pick_random()

	for cat in OPTIONAL_SPRITES:
		var p = OPTIONAL_SPRITES[cat]
		if randf() < p:
			res[cat] = SpriteCache.MAP.get(cat, {}).keys().pick_random()

	return res


## Computes final character stats based on their class and rank.
## Stats are scaled linearly by multiplying by a factor of the rank.
static func compute_stats(char_class: String, rank: int) -> Dictionary[String, int]:
	var stats: Dictionary[String, int] = {}
	var base = BASE_STATS[char_class]
	var scale = roundi(float(rank) / base.size())
	for key in base:
		stats[key] = base[key] * scale
	return stats


## Creates a fully initialized `CharacterResource` data from a given `OriginResource`.
## Randomizes class, alignment, name, stats, and sprite layers.
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
