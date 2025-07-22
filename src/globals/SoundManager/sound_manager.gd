extends Node

@export var bgm_volume_db: float = -6.0
@export var sfx_volume_db: float = 0.0
@export var sfx_player_count := 8  # number of simultaneous SFX

@onready var _bgm_player: AudioStreamPlayer = $BGM
@onready var _sfx_pool: Node = $SFXPool
var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx_index := 0  #idx of current sfx player in pool


func _ready() -> void:
	_bgm_player.volume_db = bgm_volume_db

	for i in sfx_player_count:
		var p = AudioStreamPlayer.new()
		p.bus = "SFX"  # hook onto the SFX bus instead of master/bgm
		p.volume_db = sfx_volume_db
		_sfx_pool.add_child(p)
		_sfx_players.append(p)


func play_bgm(stream: AudioStream, fade_time := 1.0) -> void:
	if _bgm_player.stream == stream:
		return  # already playing

	# fade out from old stream
	if _bgm_player.playing:
		await _fade_player(_bgm_player, 0.0, fade_time).finished

	# swap stream and fade back in
	_bgm_player.stream = stream
	_bgm_player.volume_db = -80  # start silent
	_bgm_player.play()
	_fade_player(_bgm_player, bgm_volume_db, fade_time)


func stop_bgm(fade_time := 1.0) -> void:
	if _bgm_player.playing:
		await _fade_player(_bgm_player, -80, fade_time).finished
		_bgm_player.stop()


func play_sfx(stream: AudioStream) -> void:
	var p = _sfx_players[_sfx_index]
	_sfx_index = (_sfx_index + 1) % _sfx_players.size()  # update index to next in pool
	p.stop()
	p.stream = stream
	p.play()


func set_bgm_volume_db(db: float) -> void:
	bgm_volume_db = db
	_bgm_player.volume_db = db


func set_sfx_volume_db(db: float) -> void:
	sfx_volume_db = db
	for p in _sfx_players:
		p.volume_db = db


func _fade_player(player: AudioStreamPlayer, to_db: float, time: float) -> Tween:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(player, "volume_db", to_db, time)
	return tween
