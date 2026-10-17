extends Node

var s: SimSettings

func setup(settings: SimSettings) -> void:
	s = settings


func _physics_process(_delta: float) -> void:
	if s == null:
		return
	var bodies := get_tree().get_nodes_in_group("bodies")
	for i in bodies.size():
		for j in range(i + 1, bodies.size()):
			var a: RigidBody3D = bodies[i]
			var b: RigidBody3D = bodies[j]
			var d := b.global_position - a.global_position
			var dist2 := maxf(d.length_squared(), 0.01)
			var force := d.normalized() * (s.G * a.mass * b.mass / dist2)
			a.apply_central_force(force)
			b.apply_central_force(-force)
