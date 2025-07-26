extends GachaPullLogic

const ADV_FACTORY := preload("res://src/core/entities/adventurers/adventurer_factory.gd")


func pull(banner: BannerData, count: int) -> Array[AdventurerData]:
	var cost := banner.pull_cost * count
	if not SaveManager.spend_gold(cost):
		return []

	var pool := SaveManager.get_origins()

	var results: Array[AdventurerData] = []
	for i in count:
		var c: AdventurerData

		# keep re-rolling until we get one that fits the banner rarity and tag bias
		while true:
			var origin: OriginData = RNG.choose(pool)
			c = ADV_FACTORY.create_from_origin(origin)

			# rarity checks
			if c.rarity < banner.min_rarity:
				continue
			if banner.max_rarity > 0 and c.rarity > banner.max_rarity:
				continue

			# tag_bias check (if any)
			if banner.tag_bias.size() > 0 and not _has_overlap(banner.tag_bias, c.tags):
				continue

			# passed all checks
			break

		results.append(c)
		SaveManager.set_adventurer(c)

	SaveManager.save_sync()
	return results


func _has_overlap(a: PackedStringArray, b: PackedStringArray) -> bool:
	for t in a:
		if b.has(t):
			return true
	return false
