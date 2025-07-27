extends Control

const MainDisplay = preload("res://src/menus/gallery/ui/main_display/main_display.gd")

@onready var _main := $Main
@onready var _details := $Details


func _on_adventurers_button_pressed() -> void:
	_main.set_mode(MainDisplay.Mode.Adventurer)


func _on_inventory_button_pressed() -> void:
	_main.set_mode(MainDisplay.Mode.Item)


func _on_button_back_pressed() -> void:
	SceneService.change_to(load("res://src/menus/lobby/lobby.tscn"))


func _on_select_adventurer(adv: AdventurerData) -> void:
	_details.show_adventurer(adv)


func _on_select_item(item: ItemData, c: int) -> void:
	_details.show_item(item, c)
