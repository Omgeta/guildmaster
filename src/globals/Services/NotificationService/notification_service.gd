extends CanvasLayer

@onready var _toast_container: VBoxContainer = $ToastContainer
@onready var _popup_container: Control = $PopupContainer  # input‑blocking backdrop

const TOAST_SCN := preload("res://src/globals/Services/NotificationService/ui/toast/toast.tscn")
const POPUP_SCN := preload("res://src/globals/Services/NotificationService/ui/popup/popup.tscn")
const NOTIFICATION_SFX := preload("res://src/menus/assets/music/sfx/notification.mp3")
const TOAST_FADE_TIME := 1.0


func toast(
	title: String, desc: String, colour: Color, icon: Texture = null, life: float = 3.0
) -> void:
	var t := TOAST_SCN.instantiate()
	_toast_container.add_child(t)
	t.setup(title, desc, colour, icon)
	SoundService.play_sfx(NOTIFICATION_SFX)

	var tw = create_tween()
	tw.tween_interval(life)
	tw.tween_property(t, "modulate:a", 0.0, TOAST_FADE_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(
		Tween.EASE_IN
	)
	tw.tween_callback(func(): t.queue_free())


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
