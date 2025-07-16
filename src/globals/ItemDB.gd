extends Node

const ITEMS_PATH := "res://src/core/items/prefabs"

var _by_id: Dictionary = {}
var _by_type: Dictionary = {}


func _ready() -> void:
	_scan_dir(ITEMS_PATH)
	print("ItemDB: loaded %d items" % _by_id.size())


func _scan_dir(folder: String) -> void:
	var dir := DirAccess.open(folder)
	if dir == null:
		push_error("ItemDB: Cannot open %s" % folder)
		return
	dir.list_dir_begin()
	var filename := dir.get_next()
	while filename != "":
		if dir.current_is_dir():
			if filename.begins_with("."):
				filename = dir.get_next()
				continue
			_scan_dir("%s/%s" % [folder, filename])
		elif filename.get_extension() == "tres":
			_register_item("%s/%s" % [folder, filename])
		filename = dir.get_next()
	dir.list_dir_end()


func _register_item(res_path: String) -> void:
	var data: ItemData = load(res_path)
	if data == null:
		push_warning("ItemDB: %s is not an ItemData" % res_path)
		return
	if data.id == "":
		push_warning("ItemDB: %s is missing its id field" % res_path)
		return
	if _by_id.has(data.id):
		push_warning("ItemDB: duplicate id %s at %s" % [data.id, res_path])
		return

	_by_id[data.id] = data

	var t := data.get_class()  # "ConsumableData", "EquipmentData", etc
	if not _by_type.has(t):
		_by_type[t] = []
	_by_type[t].append(data)


## getters
func get_by_id(id: String) -> ItemData:
	return _by_id.get(id)


func has(id: String) -> bool:
	return _by_id.has(id)


func all() -> Array[ItemData]:
	return _by_id.values()  # copy into array


func by_type(type_name: String) -> Array[ItemData]:
	return _by_type.get(type_name, [])  # copy into array
