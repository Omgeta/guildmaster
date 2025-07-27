extends CanvasLayer

@onready var _toast_container: VBoxContainer = $ToastContainer
@onready var _popup_container: Control = $PopupContainer  # input‑blocking backdrop

const TOAST_SCN := preload("res://src/globals/Services/NotificationService/ui/toast/toast.tscn")
const POPUP_SCN := preload("res://src/globals/Services/NotificationService/ui/popup/popup.tscn")
const NOTIFICATION_SFX := preload("res://src/menus/assets/music/sfx/notification.mp3")
const TOAST_FADE_TIME := 1.0
const TOAST_SPAWN_DELAY := 0.1

var _toast_queue: Array = []
var _spawning := false


func toast(
	title: String, desc: String, colour: Color, icon: Texture = null, life: float = 3.0
) -> void:
	# Add toast data to the queue
	_toast_queue.append(
		{"title": title, "desc": desc, "colour": colour, "icon": icon, "life": life}
	)

	# Start processing if not already
	if not _spawning:
		_spawning = true
		_spawn_toasts()


func _spawn_toasts() -> void:
	while _toast_queue.size() > 0:
		var data = _toast_queue.pop_front()

		# spawn toast immediately
		var t := TOAST_SCN.instantiate()
		_toast_container.add_child(t)
		t.setup(data.title, data.desc, data.colour, data.icon)
		SoundService.play_sfx(NOTIFICATION_SFX)

		# independent fade timer
		var tw = create_tween()
		tw.tween_interval(data.life)
		(
			tw
			. tween_property(t, "modulate:a", 0.0, TOAST_FADE_TIME)
			. set_trans(Tween.TRANS_CUBIC)
			. set_ease(Tween.EASE_IN)
		)
		tw.tween_callback(func(): t.queue_free())

		# wait before spawning next toast
		await get_tree().create_timer(TOAST_SPAWN_DELAY).timeout

	_spawning = false


func popup(title: String, body: String, color: Color) -> void:
	# block input behind
	_popup_container.visible = true
	var p := POPUP_SCN.instantiate()
	_popup_container.add_child(p)
	p.setup(title, body, color)
	SoundService.play_sfx(NOTIFICATION_SFX)
	p.closed.connect(
		func():
			p.queue_free()
			_popup_container.visible = false
	)
