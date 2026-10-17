extends Node3D

signal relaunched

const LABEL_NODE := "NameLabel"
var s: SimSettings
var sys: SystemData


func setup(settings: SimSettings, system: SystemData) -> void:
	s = settings
	sys = system
	_spawn_bodies()
	_init_bodies()
	_create_labels()
	apply_radii()
	place_and_launch()
	s.layout_changed.connect(place_and_launch)
	s.radii_changed.connect(apply_radii)
	s.labels_changed.connect(_update_labels)
	s.g_changed.connect(_on_g_changed)


func _body(body_name: String) -> RigidBody3D:
	return get_node_or_null(NodePath(body_name)) as RigidBody3D


func _spawn_bodies() -> void:
	for body_name in sys.bodies:
		var d: Dictionary = sys.bodies[body_name]
		var col: Color = d.get("color", Color.WHITE)

		var body := RigidBody3D.new()
		body.name = body_name

		var cs := CollisionShape3D.new()
		cs.shape = SphereShape3D.new()
		body.add_child(cs)

		var mi := MeshInstance3D.new()
		mi.mesh = SphereMesh.new()
		var mat := StandardMaterial3D.new()
		mat.albedo_color = col
		if body_name == sys.star:
			mat.emission_enabled = true
			mat.emission = col
			mat.emission_energy_multiplier = 2.0
			var light := OmniLight3D.new()
			light.omni_range = 100000.0
			light.omni_attenuation = 0.3
			light.light_energy = 2.0
			body.add_child(light)
		mi.material_override = mat
		body.add_child(mi)

		add_child(body)


func _init_bodies() -> void:
	for body_name in sys.bodies:
		var body := _body(body_name)
		body.add_to_group("bodies")
		body.mass = sys.bodies[body_name].mass
		body.gravity_scale = 0.0
		body.linear_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
		body.angular_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
		body.linear_damp = 0.0
		body.angular_damp = 0.0


func _create_labels() -> void:
	for body_name in sys.bodies:
		var body := _body(body_name)
		var label := Label3D.new()
		label.name = LABEL_NODE
		label.text = sys.bodies[body_name].get("label", body_name)
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.fixed_size = true
		label.no_depth_test = true
		label.pixel_size = 0.0008
		label.font_size = 48
		label.outline_size = 12
		body.add_child(label)
	_update_labels()


func _update_labels() -> void:
	for body_name in sys.bodies:
		var label := _body(body_name).get_node_or_null(LABEL_NODE) as Label3D
		if label:
			label.visible = s.show_labels


func apply_radii() -> void:
	for body_name in sys.bodies:
		var body := _body(body_name)
		var mult := s.sun_radius_multiplier if body_name == sys.star else s.radius_multiplier
		var rad: float = sys.bodies[body_name].radius * mult
		_set_radius(body, rad)
		var label := body.get_node_or_null(LABEL_NODE) as Label3D
		if label:
			label.position = Vector3(0, rad * 1.3, 0)


func _set_radius(body: RigidBody3D, rad: float) -> void:
	for child in body.get_children():
		var mi := child as MeshInstance3D
		if mi and mi.mesh is SphereMesh:
			var m := mi.mesh.duplicate() as SphereMesh
			m.radius = rad
			m.height = rad * 2.0
			mi.mesh = m
		var cs := child as CollisionShape3D
		if cs and cs.shape is SphereShape3D:
			var sh := cs.shape.duplicate() as SphereShape3D
			sh.radius = rad
			cs.shape = sh


func place_and_launch() -> void:
	var star := _body(sys.star)
	if star == null:
		return

	var star_mass: float = sys.bodies[sys.star].mass
	var total_mass := star_mass
	var pos := {}
	var vel := {}
	var com := Vector3.ZERO
	var mom := Vector3.ZERO
	var i := 0

	for body_name in sys.bodies:
		if body_name == sys.star:
			continue
		var d: Dictionary = sys.bodies[body_name]
		var m: float = d.mass
		var a: float = float(d.dist) * s.distance_multiplier
		var e: float = d.e
		var inc: float = d.inc
		var rp: float = a * (1.0 - e)
		var theta: float = i * 0.9
		var tilt := Basis(Vector3.RIGHT, deg_to_rad(inc))
		var dir := Vector3(cos(theta), 0.0, sin(theta))
		var tang := dir.cross(Vector3.UP).normalized()
		var mu: float = s.G * (star_mass + m)
		var vp: float = sqrt(mu * (2.0 / rp - 1.0 / a))

		pos[body_name] = tilt * dir * rp
		vel[body_name] = tilt * tang * vp
		com += pos[body_name] * m
		mom += vel[body_name] * m
		total_mass += m
		i += 1

	com /= total_mass
	var star_vel := -mom / total_mass

	star.global_position = -com
	star.linear_velocity = star_vel
	star.angular_velocity = Vector3.ZERO

	for body_name in pos:
		var body := _body(body_name)
		body.global_position = pos[body_name] - com
		body.linear_velocity = vel[body_name] + star_vel
		body.angular_velocity = Vector3.ZERO

	relaunched.emit()


func _on_g_changed(old_g: float, new_g: float) -> void:
	var k := sqrt(new_g / old_g)
	for b in get_tree().get_nodes_in_group("bodies"):
		(b as RigidBody3D).linear_velocity *= k
