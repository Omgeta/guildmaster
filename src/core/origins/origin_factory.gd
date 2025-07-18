extends Node
class_name OriginFactory

const KEYWORDS: OriginKeywords = preload("res://src/core/origins/assets/data/OriginKeywords.tres")
const RANK_WEIGHTS = {
	1: 70,
	2: 25,
	3: 5,
}

const Class = AdventurerData.Class
const Alignment = AdventurerData.Alignment
const Tag = CharacterData.Tag

const uuid_util = preload("res://addons/uuid/uuid.gd")

@onready var _set: Dictionary[String, bool] = {}


func _ready() -> void:
	for o in SaveManager.get_origins():
		_set[o.display_name] = true


func create_random_origins(min_count := 15, max_count := 20) -> Array[OriginData]:
	var out: Array[OriginData] = []
	var num := RNG.randi_range(min_count, max_count)

	for i in num:
		var origin := _generate_origin()

		# ensure unique name
		if not _set.has(origin.display_name):
			_set[origin.display_name] = true
			out.append(origin)
		else:
			i -= 1  # try again if not unique

	return out


func _generate_origin() -> OriginData:
	var name_tags := _random_origin_set()
	var origin := OriginData.new()

	origin.id = uuid_util.v4()
	origin.display_name = name_tags.name
	origin.base_rank = _generate_rank()
	origin.tags = name_tags.tags
	origin.alignment = _compute_alignment(name_tags.tags)
	origin.class_dist = _compute_class_distribution(name_tags.tags)

	return origin


func _random_origin_set() -> Dictionary[String, Variant]:
	var pre: OriginNamePart = RNG.choose(KEYWORDS.prefixes)
	var con: String = RNG.choose(KEYWORDS.connectors)
	var suf: OriginNamePart = RNG.choose(KEYWORDS.suffixes)
	return {
		"name": "%s %s %s" % [pre.name, con, suf.name], "tags": _get_unique_tags(pre.tags, suf.tags)
	}


func _get_unique_tags(a: Array[Tag], b: Array[Tag]) -> Array[Tag]:
	var seen: Dictionary[Tag, bool] = {}
	var out: Array[Tag] = []
	for tag in a + b:
		if not seen.has(tag):
			seen[tag] = true
			out.append(tag)
	return out


func _generate_rank() -> int:
	return RNG.choose_weighted(RANK_WEIGHTS)


func _compute_alignment(tags: Array[Tag]) -> Alignment:
	return (
		Alignment.Chaotic
		if Tag.Chaotic in tags
		else Alignment.Orderly if Tag.Orderly in tags else Alignment.Neutral
	)


func _compute_class_distribution(tags: Array[Tag]) -> Dictionary[Class, int]:
	var base: Dictionary[Class, int] = {Class.Warrior: 0, Class.Mage: 0, Class.Rogue: 0}
	var found_bias := false
	for entry in KEYWORDS.tag_class_biases:
		if entry.tag in tags:
			for cls in entry.biases:
				base[cls] += entry.biases[cls]
			found_bias = true
	if not found_bias:
		return OriginData.BASE_DIST
	return base
