extends GachaPullLogic

const ADV_FACTORY := preload("res://src/entities/adventurers/adventurer_factory.gd")


func pull(banner: BannerData, count: int) -> Array[AdventurerData]:
	var cost := banner.pull_cost * count
	if not SaveManager.spend_gold(cost):
		return []

	var pool := _build_origin_pool(banner)
	var results: Array[AdventurerData] = []
	for i in count:
		var origin := _pick_origin(pool)
		var c := ADV_FACTORY.create_from_origin(origin)
		results.append(c)
		SaveManager.set_adventurer(c)
	return results


func _build_origin_pool(banner: BannerData) -> Array[OriginData]:
	var list := SaveManager.get_origins() + OriginDB.all()
	var pool: Array[OriginData] = []
	for o in list:
		if o.base_rank < banner.min_rarity:  # rarity floor enforced
			continue
		if banner.tag_bias.size() > 0 and not _has_overlap(banner.tag_bias, o.tags):
			continue
		pool.append(o)
	return pool


func _has_overlap(a: PackedStringArray, b: PackedStringArray) -> bool:
	for t in a:
		if b.has(t):
			return true
	return false


func _pick_origin(pool: Array[OriginData]) -> OriginData:
	var weighted_dict: Dictionary[OriginData, int] = {}
	for o in pool:
		weighted_dict[o] = o.frequency
	return RNG.choose_weighted(weighted_dict)
