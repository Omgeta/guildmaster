extends Control

const MainDisplay = preload("res://src/menus/gallery/ui/main_display/main_display.gd")

@onready var _main := $Main
@onready var _details := $Details


func _ready() -> void:
	if not SaveManager.get_flag(GameState.Flag.GALLERY_TUTORIAL):
		(
			NotificationService
			. popup(
				"Gallery",
				"Ah, the gallery... Here you can keep track of all your precious comrades as well as your sweet loot.\n\n Come here often to evaluate the strength of your forces.\n\nPerhaps in the future, you could even strengthen your allies here.",
				Color.CRIMSON
			)
		)
		SaveManager.set_flag(GameState.Flag.GALLERY_TUTORIAL, true)


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
