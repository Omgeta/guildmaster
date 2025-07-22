extends Node

const MANIFEST_FILE := "res://src/manifest.cfg"
const SPRITES_SECTION := "sprites"

const ANIM_MAP := [{"idle": 1, "push": 2, "pull": 2, "jump": 3}, {"walk": 6, "run": 2}]  # rows 0-3, 4-7
const FRAME_SIZE := Vector2i(64, 64)
const DIRECTIONS := ["down", "up", "right", "left"]

var _map: Dictionary[String, Dictionary] = {}  # cat : {id: Texture2D}
var _thread: Thread = null
var _loaded: int = 0
var _total: int = 0
var _busy: bool = true

signal loaded  # fired once when all sheets are preloaded


func _ready():
	var flat := _scan_manifest(MANIFEST_FILE, SPRITES_SECTION)  # flat map from cfg
	_total = flat.size()
	_thread = Thread.new()
	_thread.start(_preload.bind(flat))
	print("SpriteDB: loaded %d sprites" % flat.size())


func _scan_manifest(manifest: String, section: String) -> Dictionary:
	var cfg := ConfigFile.new()
	var err := cfg.load(manifest)
	if err != OK:
		push_error("SpriteDB: cannot load manifest - %s" % error_string(err))
		return {}

	var flat := {}
	for id in cfg.get_section_keys(section):  # every key is a full id
		flat[id] = cfg.get_value(section, id, "")
	return flat


func _preload(flat: Dictionary) -> void:
	for full_id in flat.keys():
		var tex: Texture2D = ResourceLoader.load(flat[full_id])  # blocking (no choice) but runs in thread
		var sf: SpriteFrames = _build_frames(tex)
		_store(full_id, sf)  # store frames by category
		_loaded += 1
	call_deferred("_on_finished")


func _build_frames(res: Resource) -> SpriteFrames:
	if res is SpriteFrames:  # if already supplied just return
		return res

	var texture: Texture2D = res
	var frames := SpriteFrames.new()

	# Loop over each animation group (corresponding to sprite sheet section)
	for section_idx in ANIM_MAP.size():
		var anims = ANIM_MAP[section_idx]

		# For each animation (e.g., idle, walk)
		for anim_name in anims:
			var fcount = anims[anim_name]

			# Each direction (e.g., down, up) maps to one row per section
			for dir_idx in range(DIRECTIONS.size()):
				var full := "%s_%s" % [anim_name, DIRECTIONS[dir_idx]]
				frames.add_animation(full)
				frames.set_animation_speed(full, 6)

				# Add each animation frame from the row
				var row := section_idx * 4 + dir_idx
				for i in range(fcount):
					var atlas := AtlasTexture.new()
					atlas.atlas = texture
					atlas.region = Rect2(
						i * FRAME_SIZE.x, row * FRAME_SIZE.y, FRAME_SIZE.x, FRAME_SIZE.y
					)
					frames.add_frame(full, atlas)
	return frames


func _store(full_id: String, res: Resource) -> void:
	var slash := full_id.find("/")
	var cat := full_id.substr(0, slash)  # "outfit"
	# var sid := full_id.substr(slash + 1)  # "pfpn_v05"
	if not _map.has(cat):
		_map[cat] = {}
	_map[cat][full_id] = res


func _on_finished() -> void:
	_busy = false
	_thread.wait_to_finish()
	_thread = null
	loaded.emit()


func is_ready() -> bool:
	return not _busy


func get_by_id(id: String) -> SpriteFrames:
	var cat: String = id.split("/")[0]
	return _map.get(cat, {}).get(id)


func get_random_in_category(cat: String) -> String:
	return RNG.choose(_map.get(cat).keys())
