extends CanvasLayer

var s: SimSettings
var _bodies: Node3D
var _sys: SystemData
var _label: Label
var _sim_time := 0.0
var _angle_total := 0.0
var _last_angle := 0.0
var _have_last := false


func setup(settings: SimSettings, system: SystemData, bodies: Node3D) -> void:
	s = settings
	_sys = system
	_bodies = bodies
	_label = Label.new()
	_label.position = Vector2(16, 16)
	_label.add_theme_font_size_override("font_size", 24)
	_label.add_theme_constant_override("outline_size", 6)
	_label.add_theme_color_override("font_outline_color", Color.BLACK)
	add_child(_label)
	s.time_changed.connect(_refresh)
	s.layout_changed.connect(_refresh)
	s.g_changed.connect(func(_a: float, _b: float): _refresh())
	_refresh()


func reset_clock() -> void:
	_sim_time = 0.0
	_angle_total = 0.0
	_have_last = false
	_refresh()


func _physics_process(delta: float) -> void:
	if s == null:
		return
	_sim_time += delta
	var earth := _bodies.get_node_or_null(_sys.year_body) as RigidBody3D
	var sun := 	_bodies.get_node_or_null(_sys.star) as RigidBody3D
	if earth and sun:
		var rel := earth.global_position - sun.global_position
		var ang := atan2(rel.z, rel.x)
		if _have_last:
			_angle_total += absf(angle_difference(_last_angle, ang))
		_last_angle = ang
		_have_last = true
	_refresh()


func _refresh() -> void:
	if _label == null:
		return
	var years: float = _angle_total / TAU
	var speed_txt: String = "PAUZA" if s.paused else "x" + String.num(s.time_scale, 3)
	var game_s: float = sqrt(s.G / (_sys.real_g_factor() * pow(s.distance_multiplier, 3)))
	var days_per_s: float = game_s * (0.0 if s.paused else s.time_scale) / 86400.0

	var values: Array = [years, int(years * 365.25), _sim_time, days_per_s, speed_txt, String.num(s.G, 5)]
	var fmt: String = "Czas symulacji: %.2f lat (%d dni)\nCzas fizyki: %.0f s\nTempo: 1 s = %.2f dni\nSzybkość: %s   [+ - P R]   G: %s   [ ]"
	_label.text = fmt % values
