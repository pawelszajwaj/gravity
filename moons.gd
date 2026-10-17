extends Node3D

const MIN_MOON_RADIUS := 0.15
const KNEE_FRACTION := 0.15
const REGULAR_A_KM := 4.0e6

var s: SimSettings
var _sys: SystemData
var _star: RigidBody3D
var _moons: Array[Dictionary] = []
var _mat := StandardMaterial3D.new()


func setup(settings: SimSettings, system: SystemData, bodies: Node3D) -> void:
	s = settings
	_sys = system
	_star = bodies.get_node_or_null(system.star) as RigidBody3D
	_mat.albedo_color = Color(0.7, 0.7, 0.72)

	for md in _sys.moons:
		var d: Dictionary = md
		var parent := bodies.get_node_or_null(NodePath(d.parent)) as RigidBody3D
		if parent == null:
			continue

		var mi := MeshInstance3D.new()
		mi.name = d.name
		mi.material_override = _mat
		add_child(mi)

		var label := Label3D.new()
		label.text = d.label
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.fixed_size = true
		label.no_depth_test = true
		label.pixel_size = 0.0006
		label.font_size = 40
		label.outline_size = 10
		mi.add_child(label)

		var rot := Basis(Vector3.UP, deg_to_rad(float(d.node))) \
			* Basis(Vector3.RIGHT, deg_to_rad(float(d.inc))) \
			* Basis(Vector3.UP, deg_to_rad(float(d.omega)))

		_moons.append({
			"data": d, "node": mi, "label": label, "parent": parent,
			"rot": rot, "M": deg_to_rad(float(d.M)),
			"regular": float(d.a_km) < REGULAR_A_KM,
		})

	_apply_radii()
	s.radii_changed.connect(_apply_radii)


func _apply_radii() -> void:
	for m in _moons:
		var d: Dictionary = m.data
		var rad: float = maxf(float(d.radius_km) / _sys.km_per_unit * s.radius_multiplier, MIN_MOON_RADIUS)
		var mesh := SphereMesh.new()
		mesh.radius = rad
		mesh.height = rad * 2.0
		mesh.radial_segments = 12
		mesh.rings = 6
		(m.node as MeshInstance3D).mesh = mesh
		(m.label as Label3D).position = Vector3(0, rad * 1.5, 0)


func _compress(r: float, knee: float) -> float:
	if r <= knee:
		return r
	return knee * (1.0 + log(r / knee))


func _solve_kepler(M: float, e: float) -> float:
	var E: float = M if e < 0.8 else PI
	for i in 6:
		E -= (E - e * sin(E) - M) / (1.0 - e * cos(E))
	return E


func _process(delta: float) -> void:
	if s == null:
		return

	var cam := get_viewport().get_camera_3d()
	var star_pos := _star.global_position if _star else Vector3.ZERO
	var km := _sys.km_per_unit

	var knees := {}
	var reach := {}
	for m in _moons:
		var parent := m.parent as RigidBody3D
		if not knees.has(parent.name):
			knees[parent.name] = KNEE_FRACTION * parent.global_position.distance_to(star_pos)
		if m.regular:
			var d: Dictionary = m.data
			var lin: float = float(d.a_km) / km * s.distance_multiplier * s.moon_orbit_multiplier * (1.0 + float(d.e))
			var orbit := _compress(lin, float(knees[parent.name]))
			reach[parent.name] = maxf(float(reach.get(parent.name, 0.0)), orbit)

	for m in _moons:
		var d: Dictionary = m.data
		var parent := m.parent as RigidBody3D
		var a_true: float = float(d.a_km) / km * s.distance_multiplier
		var e: float = d.e
		var n: float = sqrt(s.G * parent.mass / pow(a_true, 3.0))
		var M: float = fposmod(float(m.M) + n * delta, TAU)
		m.M = M

		var E: float = _solve_kepler(M, e)
		var px: float = cos(E) - e
		var pz: float = sqrt(1.0 - e * e) * sin(E)
		var local: Vector3 = (m.rot as Basis) * Vector3(px, 0.0, pz) * a_true * s.moon_orbit_multiplier
		var r := local.length()
		if r > 0.0:
			local *= _compress(r, float(knees[parent.name])) / r
		var pos := parent.global_position + local
		(m.node as Node3D).global_position = pos

		var label := m.label as Label3D
		var vis := false
		if s.show_labels and cam:
			var alpha := 0.0
			if m.regular:
				var limit: float = float(reach[parent.name]) * s.moon_label_range
				var t: float = cam.global_position.distance_to(parent.global_position) / limit
				alpha = clampf((1.0 - t) / 0.3, 0.0, 1.0)
			else:
				var t2: float = cam.global_position.distance_to(pos) / s.irregular_label_range
				alpha = clampf((1.0 - t2) / 0.3, 0.0, 1.0)
			label.modulate.a = alpha
			vis = alpha > 0.0
		label.visible = vis
