class_name SolarSystem
extends SystemData

func _init() -> void:
	star = "Sun"
	year_body = "Earth"
	km_per_unit = 579000.0
	mass_unit_kg = 5.972e24
	bodies = {
		"Sun":     {"label": "Słońce",  "color": Color(1.0, 0.85, 0.3), "mass": 333000.0, "dist": 0.0,    "radius": 1.2015,  "e": 0.0,    "inc": 0.0},
		"Mercury": {"label": "Merkury", "color": Color(0.6, 0.6, 0.6),  "mass": 0.055,    "dist": 100.0,  "radius": 0.00421, "e": 0.2056, "inc": 7.00},
		"Venus":   {"label": "Wenus",   "color": Color(0.9, 0.8, 0.55), "mass": 0.815,    "dist": 186.9,  "radius": 0.01045, "e": 0.0068, "inc": 3.39},
		"Earth":   {"label": "Ziemia",  "color": Color(0.2, 0.45, 0.9), "mass": 1.0,      "dist": 258.4,  "radius": 0.01100, "e": 0.0167, "inc": 0.0},
		"Mars":    {"label": "Mars",    "color": Color(0.8, 0.35, 0.2), "mass": 0.107,    "dist": 393.8,  "radius": 0.00585, "e": 0.0934, "inc": 1.85},
		"Jupiter": {"label": "Jowisz",  "color": Color(0.8, 0.65, 0.5), "mass": 317.8,    "dist": 1344.6, "radius": 0.12074, "e": 0.0484, "inc": 1.30},
		"Saturn":  {"label": "Saturn",  "color": Color(0.9, 0.8, 0.55), "mass": 95.2,     "dist": 2473.2, "radius": 0.10057, "e": 0.0542, "inc": 2.49},
		"Uranus":  {"label": "Uran",    "color": Color(0.6, 0.85, 0.9), "mass": 14.5,     "dist": 4951.6, "radius": 0.04380, "e": 0.0472, "inc": 0.77},
		"Neptune": {"label": "Neptun",  "color": Color(0.25, 0.4, 0.9), "mass": 17.1,     "dist": 7797.9, "radius": 0.04253, "e": 0.0086, "inc": 1.77},
	}
	moons = load_moons_csv("res://data/moons.csv")
