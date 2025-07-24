extends NinePatchRect

signal mission_selected(mission: MissionData)

const MISSION_CARD_PCK := preload(
	"res://src/menus/mission/ui/mission_list/mission_card/mission_card.tscn"
)

@onready var _container := $MarginContainer/ScrollContainer/VBoxContainer


func populate_missions(missions: Array[MissionData]):
	for child in _container.get_children():
		child.queue_free()
	for mission in missions:
		var card := MISSION_CARD_PCK.instantiate()
		_container.add_child(card)
		card.set_mission(mission.display_name, MissionManager.get_state(mission.id))
		card.pressed.connect(_on_card_pressed.bind(card, mission))


func _on_card_pressed(card: Control, mission: MissionData):
	# TODO: highlight selected card
	mission_selected.emit(mission)
