extends Node3D
class_name GachaStage

@export var fx_burst := 1000

@onready var _fx: GPUParticles3D = $Portal/PortalParticles
@onready var _spawn: Marker3D = $Portal/SpawnPoint
@onready var _cam: Node3D = $CameraRig

var color_util = preload("res://src/utils/ColorUtil.gd").new()


func play_reveal(
	data: AdventurerData, char_scene: PackedScene, pop_time: float, show_time: float
) -> void:
	var summon_color := color_util.get_rarity_color(data.rarity)
	await _burst_fx(summon_color)
	_show_one(data, char_scene, pop_time, show_time)


func _show_one(
	data: AdventurerData, prefab: PackedScene, pop_time: float, show_time: float
) -> void:
	# spawn in character small
	var c := prefab.instantiate()
	c.data = data
	c.cam = _cam
	add_child(c)
	c.scale = Vector3.ZERO * 0.001
	c.position = _spawn.global_position

	# pop-in and keep there
	await (
		create_tween()
		. tween_property(c, "scale", Vector3.ONE * 3, pop_time)
		. set_trans(Tween.TRANS_BACK)
		. set_ease(Tween.EASE_OUT)
		. finished
	)
	await get_tree().create_timer(show_time).timeout

	# fade and shrink out
	var t := create_tween().set_parallel(true)
	t.tween_property(c, "scale", Vector3.ZERO, pop_time)
	await t.finished

	c.queue_free()


func _burst_fx(color: Color):
	_fx.emitting = true
	_fx.amount = fx_burst
	_fx.process_material.color = color
	_fx.emitting = false
	_fx.restart()
	await get_tree().create_timer(1.5).timeout
	_fx.emitting = false
