extends RefCounted
## Disegnare un'icona di sistema con le primitive di Godot.
##
## `icon_set.gd` tiene i glifi come dati e sa scriverli in SVG; questo e' l'altro
## capo, quello che tocca un `CanvasItem`, e per questo sta in `ui/` e non in
## `scripts/core/`. Il piano resta uno solo: la stessa icona sulla mappa, sulla
## carta in mano e sul foglio stampato.
##
## Un colore solo, deciso da chi chiama. Il glifo non ne ha: se avesse bisogno
## del colore per distinguersi non passerebbe il vincolo della ART_BIBLE.

const IconSet := preload("res://scripts/core/icon_set.gd")


static func paint(canvas: CanvasItem, name: String, box: Rect2, colour: Color) -> void:
	var side: float = minf(box.size.x, box.size.y)
	var origin: Vector2 = box.position + (box.size - Vector2(side, side)) * 0.5
	for stroke in IconSet.glyph(name):
		var item: Dictionary = stroke
		var points: PackedVector2Array = PackedVector2Array()
		for point in item["points"]:
			points.append(origin + (point as Vector2) * side)
		match str(item["kind"]):
			"poly":
				canvas.draw_colored_polygon(points, colour)
			"line":
				canvas.draw_polyline(points, colour, maxf(1.0, float(item["width"]) * side), true)
			"dot":
				canvas.draw_circle(points[0], float(item["width"]) * side, colour)
