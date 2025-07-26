extends Node

const MANIFEST_FILE = "res://src/manifest.cfg"
const ITEMS_SECTION = "items"

var _by_id: Dictionary[String, ItemData] = {}
var _by_type: Dictionary[String, Array] = {}


## lifetime
func _ready() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(MANIFEST_FILE)
	if err != OK:
		push_error("ItemDB: Failed to load manifest - %s" % error_string(err))
		return
	if not cfg.has_section(ITEMS_SECTION):
		push_warning("ItemDB: No [%s] section found in manifest" % ITEMS_SECTION)
		return
	for id in cfg.get_section_keys(ITEMS_SECTION):
		var path: String = cfg.get_value(ITEMS_SECTION, id)
		_register_item(path)

	print("ItemDB: loaded %d items" % _by_id.size())


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


func find_name(id: String) -> String:
	return get_by_id(id).name


func has(id: String) -> bool:
	return _by_id.has(id)


func all() -> Array[ItemData]:
	return _by_id.values()  # copy into array


func by_type(type_name: String) -> Array[ItemData]:
	return _by_type.get(type_name, [])  # copy into array
