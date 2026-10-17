extends Node3D

@export var settings: SimSettings
@export var system: SystemData

func _ready() -> void:
	if settings == null:
		settings = SimSettings.new()
	if system == null:
		system = SolarSystem.new()
	$Bodies.setup(settings, system)
	$Gravity.setup(settings)
	$Moons.setup(settings, system, $Bodies)
	$TimeControl.setup(settings)
	$Hud.setup(settings, system, $Bodies)
	$Bodies.relaunched.connect($Hud.reset_clock)
