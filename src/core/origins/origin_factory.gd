extends Node
class_name OriginFactory

const KEYWORDS = preload("res://src/core/origins/data/origin_keywords.json").data

const AdventurerClass = AdventurerData.AdventurerClass

const uuid_util = preload("res://addons/uuid/uuid.gd")


static func create_random_origins(min_count := 15, max_count := 20) -> Array[OriginData]:
	var out: Array[OriginData] = []
	var names: Dictionary = {}
	var num := RNG.randi_range(min_count, max_count)

	for i in num:
		var name_tags := _random_origin_set()
		var origin := OriginData.new()
		origin.id = uuid_util.v4()
		origin.display_name = name_tags.name
		origin.alignment = _compute_alignment(name_tags.tags)
		origin.base_rank = RNG.choose_weighted({1: 2, 2: 3, 3: 4})  # TODO: change
		origin.frequency = 10 - origin.base_rank  # TODO: change
		origin.tags = name_tags.tags
		origin.class_dist = _compute_class_distribution(name_tags.tags)

		# ensure unique name
		if not names.has(origin.display_name):
			names[origin.display_name] = true
			out.append(origin)
		else:
			i -= 1  # try again if not unique
	return out


static func _random_origin_set() -> Dictionary[String, Variant]:
	var pre = RNG.choose(KEYWORDS["prefixes"])
	var con = RNG.choose(KEYWORDS["connectors"])
	var suf = RNG.choose(KEYWORDS["suffixes"])
	var tags: Array[String]
	tags.assign(pre.tags + suf.tags)  # force type (godot sucks)
	return {"name": "%s %s %s" % [pre.name, con, suf.name], "tags": tags}


static func _compute_alignment(tags: Array[String]) -> String:
	return "Chaotic" if "chaos" in tags else "Orderly" if "order" in tags else "Neutral"


static func _compute_class_distribution(tags: Array[String]) -> Dictionary[AdventurerClass, int]:
	var base: Dictionary[AdventurerClass, int] = {
		AdventurerClass.Warrior: 0, AdventurerClass.Mage: 0, AdventurerClass.Rogue: 0
	}
	var found_bias := false
	for tag in tags:
		if KEYWORDS["tag_class_bias"].has(tag):
			var bias = KEYWORDS["tag_class_bias"][tag]
			for k in bias:
				base[AdventurerClass.get(k)] += int(bias[k])
			found_bias = true
	if not found_bias:
		return {AdventurerClass.Warrior: 33, AdventurerClass.Mage: 33, AdventurerClass.Rogue: 33}
	return base
