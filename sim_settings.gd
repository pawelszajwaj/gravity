class_name SimSettings
extends Resource

signal g_changed(old_g: float, new_g: float)
signal layout_changed
signal radii_changed
signal labels_changed
signal time_changed


@export_range(0.0001, 10.0, 0.0001, "exp") var G: float = 0.03:
	set(v):
		var old := G
		G = maxf(v, 0.000001)
		if old != G:
			g_changed.emit(old, G)

@export var distance_multiplier: float = 1.0:
	set(v):
		distance_multiplier = maxf(v, 0.01)
		layout_changed.emit()

@export var radius_multiplier: float = 100.0:
	set(v):
		radius_multiplier = v
		radii_changed.emit()

@export var sun_radius_multiplier: float = 20.0:
	set(v):
		sun_radius_multiplier = v
		radii_changed.emit()

@export var moon_orbit_multiplier: float = 50.0
@export var moon_label_range: float = 3.0

@export var show_labels: bool = true:
	set(v):
		show_labels = v
		labels_changed.emit()

@export var time_scale: float = 1.0:
	set(v):
		time_scale = clampf(v, 0.001, 128.0)
		time_changed.emit()

@export var irregular_label_range: float = 80.0

var paused: bool = false:
	set(v):
		paused = v
		time_changed.emit()
