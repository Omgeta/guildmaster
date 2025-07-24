extends Control

signal team_changed

const CHARACTER_SLOT_PCK := preload(
	"res://src/menus/mission/ui/team_picker/character_slot/character_slot.tscn"
)

@onready var _list: GridContainer = $MarginContainer/ScrollContainer/GridContainer

var _roster: Array[AdventurerData] = []  # full roster
var _party: Array[String] = []  # 0-3 entries or fewer when clear


func setup(roster: Array[AdventurerData], team_guids: PackedStringArray) -> void:
	_roster = roster
	_party.clear()
	for child in _list.get_children():
		child.queue_free()

	for adv in _roster:
		# only render selected adventurers for in-progress missions
		if team_guids.size() > 0 and adv.id not in team_guids:
			continue
		# skip other adventurers already on a mission
		if adv.in_mission and adv.id not in team_guids:
			continue

		# set up slot
		var slot := CHARACTER_SLOT_PCK.instantiate()
		_list.add_child(slot)
		slot.setup(adv)
		slot.pressed.connect(_on_list_activate.bind(slot, adv.id))

		if adv.id in team_guids:
			slot.set_selected(true)
			slot.disabled = true


func get_party() -> Array[String]:
	return _party


func _on_list_activate(slot: Control, adv_id: String) -> void:
	if not _party.has(adv_id) and _party.size() < 4:
		_party.append(adv_id)
		slot.set_selected(true)
		team_changed.emit()
	elif _party.has(adv_id):
		_party.remove_at(_party.find(adv_id))
		slot.set_selected(false)
		team_changed.emit()
