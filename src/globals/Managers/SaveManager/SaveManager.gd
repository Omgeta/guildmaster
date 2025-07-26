extends Node

const SAVE_PATH := "user://save_slot0.tres"
const SAVE_FLAGS := ResourceSaver.FLAG_REPLACE_SUBRESOURCE_PATHS
const MAX_GOLD := 99999

var _state: GameState = GameState.new()
var _dirty: bool = false

signal gold_changed(old_amount: int, new_amount: int)
signal roster_changed
signal inventory_changed(id: String, quantity: int)
signal save_finished(success: bool)


## Getters
func get_gold() -> int:
	return _state.gold


func get_roster(copy := true, sorted := false) -> Array[AdventurerData]:
	var vals := _state.adventurers.values().duplicate(true) if copy else _state.adventurers.values()
	if sorted:
		vals.sort_custom(
			func(a, b): return a.level > b.level if a.level != b.level else a.rarity > b.rarity
		)
	return vals


func get_inventory(copy := true) -> Dictionary[String, int]:
	return _state.inventory.duplicate(true) if copy else _state.inventory


func get_flag(flag: GameState.Flag) -> bool:
	return _state.flags.get(flag, false)


func get_origins(copy := true, include_prefab := false) -> Array[OriginData]:
	var own_origins = _state.origins.duplicate(true) if copy else _state.origins
	return own_origins + OriginDB.all() if include_prefab else own_origins


func get_mission_states(copy := true) -> Dictionary[String, MissionState]:
	return _state.mission_states.duplicate(true) if copy else _state.mission_states


func find_adventurer(guid: String, copy := true) -> AdventurerData:
	return _state.adventurers[guid].duplicate(true) if copy else _state.adventurers[guid]


## Mutators
func earn_gold(amount: int) -> bool:
	if amount <= 0:
		return false
	var old_gold := _state.gold
	_state.gold = max(old_gold + amount, MAX_GOLD)
	_dirty = true
	gold_changed.emit(old_gold, _state.gold)
	return true


func spend_gold(amount: int) -> bool:
	if amount < 0 or amount > _state.gold:
		return false
	var old_gold := _state.gold
	_state.gold -= amount
	_dirty = true
	gold_changed.emit(old_gold, _state.gold)
	return true


func set_adventurer(data: AdventurerData) -> bool:
	if data == null:
		return false
	_state.adventurers[data.id] = data
	_dirty = true
	roster_changed.emit()
	return true


func touch_adventurer(id: String) -> bool:
	if _state.adventurers.has(id):
		_state.adventurers[id].seen = true
		_dirty = true
		roster_changed.emit()
		return true
	return false


func remove_adventurer(id: String) -> bool:
	if _state.adventurers.has(id):
		_state.adventurers.erase(id)
		_dirty = true
		roster_changed.emit()
		return true
	return false


func add_item(item_id: String, amount := 1) -> bool:
	if amount <= 0:
		return false
	var data := ItemDB.get_by_id(item_id)
	if data == null:
		push_warning("Unknown item: %s" % item_id)
		return false
	var new_qty := clampi(_state.inventory.get(item_id, 0) + amount, 0, data.stack_limit)
	_state.inventory[item_id] = new_qty
	_dirty = true
	inventory_changed.emit(item_id, new_qty)
	return true


func remove_item(item_id: String, amount := 1) -> bool:
	if amount <= 0 or not _state.inventory.has(item_id):
		return false
	var new_qty := maxi(_state.inventory[item_id] - amount, 0)
	if new_qty == 0:
		_state.inventory.erase(item_id)
	else:
		_state.inventory[item_id] = new_qty
	_dirty = true
	inventory_changed.emit(item_id, new_qty)
	return true


func set_flag(flag: GameState.Flag, val: bool) -> void:
	if flag in _state.flags:
		_state.flags[flag] = val
		_dirty = true


func set_dirty() -> void:
	_dirty = true


## SaveLoad
func save_sync() -> void:
	if not _dirty:  # if nothing changed, skip
		return
	_dirty = false
	var err := ResourceSaver.save(_state, SAVE_PATH, SAVE_FLAGS)
	_on_save_done.call_deferred(err)


func _on_save_done(err: int) -> void:
	save_finished.emit(err == OK)
	print("SaveManager: save completed")


func load_slot(path := SAVE_PATH) -> bool:
	if FileAccess.file_exists(path):  # old game loaded
		_state = ResourceLoader.load(path)
		RNG.set_seed(_state.rng_seed)
		print("SaveManager: loaded from %s" % path)
		return true
	else:  # new game
		_state = GameState.new()

		for mission in MissionDB.all():
			var st := MissionState.new()
			st.mission_id = mission.id
			st.status = (
				MissionState.Status.AVAILABLE
				if (mission.prerequisite_id == "")
				else MissionState.Status.LOCKED
			)
			_state.mission_states[mission.id] = st

		var origin_fac = load("res://src/core/origins/origin_factory.gd").new()
		_state.origins = origin_fac.create_random_origins()
		RNG.set_seed(int(Time.get_unix_time_from_system()))
		_state.rng_seed = RNG.get_seed()

		_dirty = true
		print("SaveManager: loaded new game")
		return false


# auto-save on quitting window
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_sync()
