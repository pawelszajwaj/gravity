extends Camera3D

@export var speed: float = 100.0
@export var boost_multiplier: float = 5.0
@export var mouse_sensitivity: float = 0.003
@export var far_distance: float = 100000.0

var _yaw := 0.0
var _pitch := 0.0


func _ready() -> void:
	far = far_distance
	_yaw = rotation.y
	_pitch = rotation.x
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_yaw -= event.relative.x * mouse_sensitivity
		_pitch = clampf(_pitch - event.relative.y * mouse_sensitivity, -PI / 2.0 + 0.01, PI / 2.0 - 0.01)
		rotation = Vector3(_pitch, _yaw, 0.0)

	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			speed *= 1.2
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			speed /= 1.2
		elif event.button_index == MOUSE_BUTTON_LEFT and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _process(delta: float) -> void:
	var dir := Vector3.ZERO
	var b := global_transform.basis

	if Input.is_physical_key_pressed(KEY_W): dir -= b.z
	if Input.is_physical_key_pressed(KEY_S): dir += b.z
	if Input.is_physical_key_pressed(KEY_A): dir -= b.x
	if Input.is_physical_key_pressed(KEY_D): dir += b.x
	if Input.is_physical_key_pressed(KEY_E) or Input.is_physical_key_pressed(KEY_SPACE): dir += Vector3.UP
	if Input.is_physical_key_pressed(KEY_Q) or Input.is_physical_key_pressed(KEY_CTRL): dir -= Vector3.UP

	if dir == Vector3.ZERO:
		return

	var s := speed
	if Input.is_physical_key_pressed(KEY_SHIFT):
		s *= boost_multiplier
	global_position += dir.normalized() * s * delta
