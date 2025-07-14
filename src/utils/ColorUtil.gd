extends Node

const Class = AdventurerData.AdventurerClass

const _class_to_color: Dictionary[Class, Color] = {
	Class.Warrior: Color.RED,
	Class.Mage: Color.BLUE,
	Class.Rogue: Color.GREEN,
}
const _rarity_to_color: Dictionary[int, Color] = {
	1: Color.GRAY,
	2: Color.GREEN,
	3: Color.BLUE,
	4: Color.PURPLE,
	5: Color.YELLOW,
}


func get_class_color(class_: Class) -> Color:
	return _class_to_color.get(class_, Color.WHITE)


func get_rarity_color(rarity: int) -> Color:
	return _rarity_to_color.get(rarity, Color.WHITE)
