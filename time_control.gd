extends Node

var s: SimSettings


func setup(settings: SimSettings) -> void:
	s = settings
	Engine.max_physics_steps_per_frame = 64
	s.time_changed.connect(_apply)
	_apply()


func _apply() -> void:
	Engine.time_scale = 0.0 if s.paused else s.time_scale


func _unhandled_input(event: InputEvent) -> void:
	var k := event as InputEventKey
	if s == null or k == null or not k.pressed or k.echo:
		return
	match k.keycode:
		KEY_EQUAL, KEY_KP_ADD:
			s.time_scale *= 2.0
		KEY_MINUS, KEY_KP_SUBTRACT:
			s.time_scale /= 2.0
		KEY_BRACKETRIGHT:
			s.G *= 4.0
		KEY_BRACKETLEFT:
			s.G /= 4.0
		KEY_R:
			s.paused = false
			s.time_scale = 1.0
		KEY_P:
			s.paused = not s.paused
