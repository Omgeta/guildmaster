extends Node3D

const LOBBY_TRACK := preload("res://src/menus/assets/music/bgm/lobby.mp3")
const BOUND := 10

@export_range(10, 100, 1) var orbit_speed_deg: float = 20.0  # deg/s
@export_range(0.1, 10, 0.1) var pan_speed: float = 15.0  # units/s

@onready var _env: WorldEnvironment = $WorldEnvironment
@onready var _nav: NavigationRegion3D = $NavigationRegion3D
@onready var _chars: Node3D = $Characters
@onready var _spawns: Node3D = $Spawns
@onready var _cam: Node3D = $CameraRig
@onready var _nav_bounds: AABB = _nav.get_bounds()

var _orbit_angle: float = 0


func _ready() -> void:
	await SoundManager.play_bgm(LOBBY_TRACK)
	_spawn_roster.call_deferred()
	SaveManager.roster_changed.connect(_refresh_roster)


func _process(delta: float) -> void:
	_update_camera_orbit(delta)
	_update_camera_pan(delta)
	_rotate_sky(delta)


func _spawn_roster():
	var chars := await SpawnLoader.spawn_roster(_nav, _chars, _cam, _spawns)
	for c in chars:
		c.wander(_nav)


func _refresh_roster():
	for c in _chars.get_children():
		c.queue_free()
	_spawn_roster()


func _update_camera_orbit(delta: float) -> void:
	var spin := 0.0
	if Input.is_action_pressed("ui_left"):
		spin -= 1
	if Input.is_action_pressed("ui_right"):
		spin += 1
	_orbit_angle += spin * orbit_speed_deg * delta
	_cam.rotation_degrees.y = _orbit_angle


func _update_camera_pan(delta: float) -> void:
	var move := Vector3.ZERO

	if Input.is_action_pressed("move_up"):
		move.x -= 0.5
		move.z -= 0.5
	if Input.is_action_pressed("move_down"):
		move.x += 0.5
		move.z += 0.5
	if Input.is_action_pressed("move_left"):
		move.x -= 0.5
		move.z += 0.5
	if Input.is_action_pressed("move_right"):
		move.x += 0.5
		move.z -= 0.5

	if move == Vector3.ZERO:
		return

	move = move.normalized() * pan_speed * delta

	# clamp inside nav AABB after transforming to local space
	var new_world_pos = _cam.global_transform.origin + move
	var local = _nav.to_local(new_world_pos)
	local.x = clamp(local.x, _nav_bounds.position.x, _nav_bounds.position.x + _nav_bounds.size.x)
	local.z = clamp(local.z, _nav_bounds.position.z, _nav_bounds.position.z + _nav_bounds.size.z)

	var gtransform = _cam.global_transform
	gtransform.origin = _nav.to_global(local)
	_cam.global_transform = gtransform


func _rotate_sky(delta: float) -> void:
	_env.environment.sky_rotation.y += 0.003 * delta
