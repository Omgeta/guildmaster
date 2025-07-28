extends Node3D

const LOBBY_TRACK = preload("res://src/menus/assets/music/bgm/lobby.mp3")
const BOUND := 10

@export_range(0.1, 6, 0.1) var min_size := 1.0
@export_range(0.1, 6, 0.1) var max_size := 5.5
@export var wheel_step := 0.5
@export var smooth_speed := 8.0
@export_range(0.1, 2.0, 0.05) var zoom_speed := 0.2
@export_range(0.1, 5.0, 0.05) var mouse_rot_sens := 0.75
@export_range(0.1, 5.0, 0.05) var mouse_pan_sens := 0.07
@export_range(10, 100, 1) var orbit_speed_deg: float = 70.0  # deg/s
@export_range(0.1, 10, 0.1) var pan_speed: float = 15.0  # units/s

@onready var _env: WorldEnvironment = $WorldEnvironment
@onready var _nav: NavigationRegion3D = $NavigationRegion3D
@onready var _chars: Node3D = $Characters
@onready var _spawns: Node3D = $Spawns
@onready var _cam: Node3D = $CameraRig
@onready var _cam3d: Camera3D = $CameraRig/Camera3D
@onready var _nav_bounds: AABB = _nav.get_bounds()
@onready var _zoom := _cam3d.size

var _orbit_angle: float = 0
var _right_drag := false
var _left_drag := false
var _last_mouse_x := 0.0


func _ready() -> void:
	SoundService.play_bgm(LOBBY_TRACK)
	_spawn_roster.call_deferred()
	AdventurerManager.roster_changed.connect(_refresh_roster)

	if not SaveManager.get_flag(GameState.Flag.LOBBY_TUTORIAL):
		(
			NotificationService
			. popup(
				"Lobby",
				"Welcome to your new home: the lobby, a home of new beginnings.\n\nThis is where you can rest and recover, meet your adventurers and most importantly, plan for your next quests. Why not start now?\n\nLook around and you may find some secrets worth your time.",
				Color.AQUAMARINE
			)
		)
		SaveManager.set_flag(GameState.Flag.LOBBY_TUTORIAL, true)


func _process(delta: float) -> void:
	_keyboard_orbit(delta)
	_keyboard_pan(delta)
	_rotate_sky(delta)
	_cam3d.size = lerp(_cam3d.size, _zoom, smooth_speed * delta)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN:
				var dir := -1.0 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0
				_zoom = clamp(_zoom + dir * wheel_step, min_size, max_size)

			MOUSE_BUTTON_RIGHT:
				_right_drag = event.pressed
				_last_mouse_x = event.position.x

			MOUSE_BUTTON_LEFT:
				_left_drag = event.pressed

	if event is InputEventMouseMotion:
		if _right_drag:
			var dx: float = event.position.x - _last_mouse_x
			_last_mouse_x = event.position.x
			_orbit_angle = wrapf(_orbit_angle - dx * mouse_rot_sens * 0.1, -180.0, 180.0)
			_cam.rotation_degrees.y = _orbit_angle

		elif _left_drag:
			var delta := get_process_delta_time()
			var px: float = event.relative.x * mouse_pan_sens
			var pz: float = event.relative.y * mouse_pan_sens

			var move := _pan_vector(px, pz) * pan_speed * delta
			_clamp_camera_pan(move)


func _keyboard_orbit(delta: float) -> void:
	var spin := 0.0
	if Input.is_action_pressed("ui_left"):
		spin -= 1
	if Input.is_action_pressed("ui_right"):
		spin += 1
	_orbit_angle += spin * orbit_speed_deg * delta
	_cam.rotation_degrees.y = _orbit_angle


func _keyboard_pan(delta: float) -> void:
	var x := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var z := Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	if x == 0 and z == 0:
		return

	var dir2 := Vector2(x, z).normalized()
	var move := _pan_vector(-dir2.x, -dir2.y) * pan_speed * delta

	_clamp_camera_pan(move)


func _clamp_camera_pan(move: Vector3):
	# clamp inside nav AABB after transforming to local space
	var new_world_pos = _cam.global_transform.origin + move
	var local = _nav.to_local(new_world_pos)
	local.x = clamp(local.x, _nav_bounds.position.x, _nav_bounds.position.x + _nav_bounds.size.x)
	local.z = clamp(local.z, _nav_bounds.position.z, _nav_bounds.position.z + _nav_bounds.size.z)

	var gtransform = _cam.global_transform
	gtransform.origin = _nav.to_global(local)
	_cam.global_transform = gtransform


func _pan_vector(x: float, z: float) -> Vector3:
	var right := _cam3d.global_transform.basis.x
	var forward := _cam3d.global_transform.basis.z
	# project onto ground and renorm
	right.y = 0
	forward.y = 0
	right = right.normalized()
	forward = forward.normalized()
	return -right * x - forward * z


func _spawn_roster():
	var chars := await SpawnService.spawn_roster(_nav, _chars, _cam, _spawns)
	for c in chars:
		c.wander(_nav)


func _refresh_roster():
	for c in _chars.get_children():
		c.queue_free()
	_spawn_roster()


func _rotate_sky(delta: float) -> void:
	_env.environment.sky_rotation.y += 0.003 * delta
