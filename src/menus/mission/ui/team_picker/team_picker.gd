extends Control
class_name TeamPicker

signal team_changed

@export var slot_empty_tex: Texture2D
@export var slot_busy_tex: Texture2D  # when adventurer is in mission
@export var slot_full_tex: Texture2D  # when occupied locally

@onready var _list: ItemList = $VBoxContainer/Roster/List
@onready var _slots: Array[TextureButton] = [
	$VBoxContainer/Slots/Slot0,
	$VBoxContainer/Slots/Slot1,
	$VBoxContainer/Slots/Slot2,
	$VBoxContainer/Slots/Slot3
]

var color_util = preload("res://src/utils/ColorUtil.gd").new()

var _roster: Array[AdventurerData] = []  # full roster
var _team: Array[AdventurerData] = []  # 0-3 entries or fewer when clear
var _is_busy: bool


func populate(
	roster: Array[AdventurerData], initial_guids: PackedStringArray = [], busy := false
) -> void:
	_roster = roster
	_team.clear()
	_list.clear()
	for adv in roster:
		var idx := _list.add_item(adv.display_name)
		_list.set_item_metadata(idx, adv.id)
		_list.set_item_tooltip(idx, "%s\n%d★\nlv.%d" % [adv.display_name, adv.rarity, adv.level])

		# disable if already in mission
		if adv.in_mission:
			_list.set_item_custom_fg_color(idx, Color(0.5, 0.5, 0.5))
			_list.set_item_disabled(idx, true)

		# pre-assign if in initial_guids
		if adv.id in initial_guids and not adv.in_mission:
			_assign_to_first_free(adv)

	_is_busy = busy
	_refresh_slots()


func get_selected_team() -> Array[AdventurerData]:
	return _team


func _ready() -> void:
	_list.item_activated.connect(_on_list_activate)
	for i in _slots.size():
		_slots[i].pressed.connect(_on_slot_pressed.bind(i))
		_slots[i].gui_input.connect(_on_slot_gui_input.bind(i))


func _on_list_activate(idx: int) -> void:
	var guid: String = _list.get_item_metadata(idx)
	var adv := _find_adv(guid)
	_assign_to_first_free(adv)


func _assign_to_first_free(adv: AdventurerData) -> void:
	if _team.has(adv):
		return
	for i in 4:
		if i >= _team.size():
			_team.append(adv)
			_refresh_slots()
			team_changed.emit()
			return


func _remove_from_slot(i: int) -> void:
	if i < _team.size():
		_team.remove_at(i)
		_refresh_slots()
		team_changed.emit()


func _refresh_slots():
	for i in 4:
		var btn := _slots[i]
		if _is_busy:
			btn.texture_normal = slot_busy_tex
			btn.disabled = true
			btn.tooltip_text = "In mission"
			btn.self_modulate = Color.WHITE
		else:
			btn.disabled = false
			if i < _team.size():
				var adv := _team[i]
				btn.texture_normal = slot_full_tex
				btn.tooltip_text = "%s\n%d★\nLv.%d" % [adv.display_name, adv.rarity, adv.level]
				btn.self_modulate = color_util.get_rarity_color(adv.rarity)
			else:
				btn.texture_normal = slot_empty_tex
				btn.tooltip_text = ""
				btn.self_modulate = Color.WHITE


# drag-and-drop removal TODO: actually fix this and have draggable icons, not just names
func _on_slot_gui_input(event: InputEvent, slot_idx: int):
	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_RIGHT
		and event.pressed
	):
		_remove_from_slot(slot_idx)


func _on_slot_pressed(slot_idx: int):
	_remove_from_slot(slot_idx)


func _find_adv(guid: String) -> AdventurerData:
	for a in _roster:
		if a.id == guid:
			return a
	return null
