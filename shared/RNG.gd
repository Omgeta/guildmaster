extends Node

func choose_weighted_value(weighted_values: Dictionary) -> Variant:
	var total = 0
	for value in weighted_values:
		total += weighted_values[value]

	var roll = randi() % total
	var current = 0
	for value in weighted_values:
		current += weighted_values[value]
		if roll < current:
			return value
	return weighted_values.keys()[0]
