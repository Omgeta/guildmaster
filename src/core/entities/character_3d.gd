extends CharacterBody3D
class_name Character3D

const SPEED := 2.0
const MIN_WAIT := 1
const MAX_WAIT := 3

@export var data: CharacterData
@export var cam: Node3D

@onready var _agent: NavigationAgent3D = $NavigationAgent3D
@onready var _billboard: Node3D = $Billboard
@onready var _layers := [$Billboard/Body, $Billboard/Outfit, $Billboard/Hair, $Billboard/Accessory]
@onready var _timer := $Timer

var _gravity := float(ProjectSettings.get_setting("physics/3d/default_gravity"))
var _last_nav: NavigationRegion3D
var _cam3d: Camera3D


func _ready() -> void:
	assert(data, "Character3D needs a CharacterData resource")
	assert(cam, "Character3D needs a CameraRig reference")
	_cam3d = cam.get_child(0)
	_apply_sprites()
	_agent.target_reached.connect(_on_target_reached)


func _physics_process(delta: float) -> void:
	_update_sprite_animation()

	if _agent.is_navigation_finished():
		velocity = Vector3.ZERO
	else:
		var next_path_position = _agent.get_next_path_position()
		var direction = (next_path_position - global_position).normalized()
		velocity = direction * SPEED
		velocity.y -= _gravity * delta
	move_and_slide()


func _apply_sprites():
	var ids = data.character_sprites

	_set_layer_sprite($Billboard/Body, ids.body)
	_set_layer_sprite($Billboard/Outfit, ids.outfit)
	_set_layer_sprite($Billboard/Hair, ids.hair)
	_set_layer_sprite($Billboard/Accessory, ids.accessory)


func _set_layer_sprite(layer: AnimatedSprite3D, id: String):
	if id == "":  # accessory may be empty
		layer.visible = false
		return
	var frames := SpriteDB.get_by_id(id)
	layer.sprite_frames = frames


func _update_sprite_animation():
	var anim := "idle_down" if _agent.is_navigation_finished() else "walk_" + _dir_to_string()
	for l in _layers:
		if l.visible:
			l.play(anim)


func _dir_to_string() -> String:
	# create basis vector based on camera, and calculate local dir vector wrt basis
	var local := cam.basis.transposed() * velocity
	local.y = 0

	if abs(local.x) > abs(local.z):  #mostly left / right
		return "right" if local.x > 0 else "left"
	else:  # mostly forward / back
		return "up" if local.z < 0 else "down"


func wander(nav: NavigationRegion3D):
	_last_nav = nav
	var pt := _random_nav_point(nav)
	_agent.target_position = pt


func _on_target_reached():
	_timer.start(RNG.randf_range(MIN_WAIT, MAX_WAIT))
	await _timer.timeout
	wander.call_deferred(_last_nav)


func _random_nav_point(nav: NavigationRegion3D) -> Vector3:
	return NavigationServer3D.map_get_random_point(nav.get_navigation_map(), 1, true)
