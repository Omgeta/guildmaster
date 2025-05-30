extends Node
## Static class used to generate `OriginResource` data

## Preloaded origin keyword data used for name generation, tagging, and bias lookup.
const ORIGIN_KEYWORDS = preload("res://core/characters/assets/data/origin_keywords.json").data


## Generates a random origin name and associated tags by combining a prefix, connector, and suffix.
static func random_origin_set() -> Dictionary:
	var prefix_set = ORIGIN_KEYWORDS["prefixes"].pick_random()
	var connector: String = ORIGIN_KEYWORDS["connectors"].pick_random()
	var suffix_set = ORIGIN_KEYWORDS["suffixes"].pick_random()

	var origin_name: String = "%s %s %s" % [prefix_set.name, connector, suffix_set.name]
	var combined_tags: Array[String]
	combined_tags.assign(prefix_set.tags + suffix_set.tags)
	return {"name": origin_name, "tags": combined_tags}


## Computes alignment based on tags.
## Priority: chaos > order > neutral
static func compute_alignment(tags: Array[String]) -> String:
	if "chaos" in tags:
		return "Chaotic"
	elif "order" in tags:
		return "Orderly"
	elif "neutral" in tags:
		return "Neutral"
	return "Neutral"


## Computes the class distribution based on tag_class_bias mappings in the keywords file.
## If no bias is found, returns an even distribution.
static func compute_class_distribution(tags: Array[String]) -> Dictionary[String, int]:
	var base: Dictionary[String, int] = {"Warrior": 0, "Magician": 0, "Rogue": 0}
	var found_bias := false
	for tag in tags:
		if ORIGIN_KEYWORDS["tag_class_bias"].has(tag):
			var bias = ORIGIN_KEYWORDS["tag_class_bias"][tag]
			for k in bias:
				base[k] += int(bias[k])
			found_bias = true
	if not found_bias:
		return {"Warrior": 33, "Magician": 33, "Rogue": 33}
	return base


## Computes a random base rank between 1 and 5.
static func compute_base_rank() -> int:
	return randi_range(1, 5)


## Computes frequency inversely based on base rank.
static func compute_frequency(base_rank: int) -> int:
	return randi_range(6, 15) - base_rank


## Generates a set of unique OriginResource instances.
static func generate_origins(min_origins: int, max_origins: int) -> Array[OriginResource]:
	var generated: Dictionary[String, OriginResource] = {}

	var num_origins = randi_range(min_origins, max_origins)
	for i in range(num_origins):
		var tags: Array[String]
		var origin_name: String
		while not origin_name or origin_name in generated:
			var data := random_origin_set()
			origin_name = data.name
			tags = data.tags

		var base_rank = compute_base_rank()
		generated[origin_name] = OriginResource.init(
			origin_name,
			compute_alignment(tags),
			compute_class_distribution(tags),
			base_rank,
			compute_frequency(base_rank)
		)

	return generated.values()
