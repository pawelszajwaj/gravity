class_name SystemData
extends Resource

@export var star: String = "Sun"
@export var year_body: String = "Earth"
@export var km_per_unit: float = 579000.0
@export var mass_unit_kg: float = 5.972e24
@export var bodies: Dictionary = {}
@export var moons: Array = []

func real_g_factor() -> float:
	const G_REAL_KM := 6.674e-20
	return G_REAL_KM * mass_unit_kg / pow(km_per_unit, 3.0)
	
static func load_moons_csv(path: String) -> Array:
	var out: Array = []
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_warning("Brak pliku: " + path)
		return out
	var header := f.get_csv_line()
	while not f.eof_reached():
		var row := f.get_csv_line()
		if row.size() < header.size():
			continue
		var d := {}
		for i in header.size():
			d[header[i]] = row[i]
		out.append({
			"parent": d["parent"], "name": d["name"], "label": d["label"],
			"a_km": float(d["a_km"]), "e": float(d["e"]),
			"omega": float(d["omega"]), "M": float(d["M"]),
			"inc": float(d["inc"]), "node": float(d["node"]),
			"radius_km": float(d["radius_km"]),
		})
	return out
