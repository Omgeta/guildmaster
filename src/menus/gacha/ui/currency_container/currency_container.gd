extends Control

@onready var _label: Label = $HBoxContainer/CoinCount


func _ready() -> void:
	_refresh()
	SaveManager.gold_changed.connect(func(): _refresh())  # listen for updates


func set_label(label: String) -> void:
	_label.text = label


func _refresh() -> void:
	_label.text = str(SaveManager.get_gold())
