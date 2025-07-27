extends CanvasLayer

signal scene_changed(current: Node)

@export var fade_time: float = 0.5

@onready var _fader: ColorRect = $Fader
@onready var _tween: Tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

var _stack: Array[Node] = []

var _busy: bool = false


func change_to(target, reset_stack := true) -> void:
	if _busy:
		return
	var node := _resolve_to_node(target)
	if not node:
		return
	_busy = true
	_transition(
		func():
			if reset_stack:
				_clear_stack()
			_replace_top(node)
	)
	print("SceneLoader: changed scene to %s" % node.name)


func push(target) -> void:
	if _busy:
		return
	var node := _resolve_to_node(target)
	if not node:
		return
	_busy = true
	_transition(func(): _push_node(node))


func pop() -> void:
	if _busy or _stack.size() <= 1:
		return
	_busy = true
	_transition(_pop_top)


func _transition(cb: Callable) -> void:
	_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_fader, "modulate:a", 1.0, fade_time)
	_tween.tween_callback(cb)
	_tween.tween_property(_fader, "modulate:a", 0.0, fade_time)
	_tween.tween_callback(
		func():
			_busy = false
			emit_signal("scene_changed", _stack.back())
	)


func _resolve_to_node(target) -> Node:
	if target is PackedScene:
		return (target as PackedScene).instantiate()
	elif target is Node:
		return target
	push_error("SceneRouter: target must be PackedScene or Node")
	return null


func _replace_top(node: Node):
	if _stack:
		_stack.back().queue_free()
		_stack.pop_back()
	_attach_as_root(node)
	_stack.append(node)


func _push_node(node: Node):
	# overlay: add as child of root so it stays above previous
	get_tree().root.add_child(node)
	_stack.append(node)


func _pop_top():
	var top = _stack.pop_back()
	top.queue_free()


func _clear_stack():
	for n in _stack:
		n.queue_free()
	_stack.clear()


func _attach_as_root(node: Node):
	get_tree().root.add_child(node)
	get_tree().current_scene = node
