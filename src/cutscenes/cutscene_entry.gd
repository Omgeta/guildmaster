extends Resource
class_name CutsceneEntry

@export_multiline var text: String
@export var image: Texture2D
@export var sound: AudioStream
@export var auto_advance: bool = false
@export var hold_time: float = 1.5  # used if auto_advance
