extends Node

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _init(seed_val := 0):
	if seed_val != 0:
		_rng.seed = seed_val
	else:
		_rng.randomize()


func set_seed(v: int) -> void:
	_rng.seed = v


func get_seed() -> int:
	return _rng.seed


func randi() -> int:
	return _rng.randi()


func randi_range(a: int, b: int) -> int:
	return _rng.randi_range(a, b)


func randf() -> float:
	return _rng.randf()


func randf_range(a: float, b: float) -> float:
	return _rng.randf_range(a, b)


func choose(arr: Array[Variant]) -> Variant:
	return arr[_rng.randi_range(0, arr.size() - 1)]


func shuffle(arr: Array):
	arr.shuffle()


func choose_weighted(weighted_dict: Dictionary) -> Variant:
	if weighted_dict.is_empty():
		return null

	var keys: Array = weighted_dict.keys()
	var weights: Array[int] = []
	var total: int = 0

	# ensure vals are +ve
	for k in keys:
		var w := maxi(int(weighted_dict[k]), 0)
		weights.append(w)
		total += w

	# Aif 0 then return unif dist
	if total == 0:
		return choose(keys)

	# weighted roll
	var roll := _rng.randi_range(1, total)
	for i in range(keys.size()):
		roll -= weights[i]
		if roll <= 0:
			return keys[i]

	return keys.back()
