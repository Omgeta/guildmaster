extends HBoxContainer

signal pull_requested(count: int)

@onready var _btn_single := $ButtonSingle
@onready var _btn_multi := $ButtonMulti


func _on_single():
	pull_requested.emit(1)


func _on_multi():
	pull_requested.emit(10)


func set_costs(cost_single: int, cost_multi: int) -> void:
	_btn_single.set_label("Single (" + str(cost_single) + ")")
	_btn_multi.set_label("Multi (" + str(cost_multi) + ")")


func set_enabled(can_afford_single: bool, can_afford_multi: bool):
	_btn_single.disabled = not can_afford_single
	_btn_multi.disabled = not can_afford_multi


func _on_button_single_button_down() -> void:
	pass  # Replace with function body.
