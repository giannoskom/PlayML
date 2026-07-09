extends Control

# Τα δεδομένα που θα μας δώσει το Report (π.χ. {"dog": 75.0, "cat": 20.0, "bird": 45.0})
var chart_data: Dictionary = {}
@onready var legend_text: RichTextLabel = $Legend_text

# Χρώματα για την κάθε κλάση (μπορείς να τα αλλάξεις με τα δικά σου soft/pastel χρώματα)
var class_colors: Dictionary = {
	"dog": Color(0.29, 0.53, 0.91),   # Ήπιο Μπλε
	"cat": Color(0.92, 0.40, 0.33),   # Ήπιο Κόκκινο/Σομόν
	"bird": Color(0.96, 0.76, 0.27)   # Ήπιο Κίτρινο
}

func set_data(new_scores: Dictionary):
	chart_data = new_scores
	print(chart_data)
	queue_redraw()
	update_legend()

func update_legend():
	if not legend_text:
		return
		
	var total_score = 0.0
	for value in chart_data.values():
		total_score += value
		
	var text = "[center]"
	
	for name in chart_data.keys():
		var score = chart_data[name]
		var percentage = (score / total_score) * 100.0 if total_score > 0 else 0.0
		
		var hex_color = class_colors.get(name, Color.WHITE).to_html(false)
		
		text += "[color=#" + hex_color + "]■ " + name.capitalize() + ": " + str(snapped(percentage, 0.1)) + "%[/color]  \n  "
		
	text += "[/center]"
	
	# Στέλνουμε το έτοιμο κείμενο στο label
	legend_text.text = text

func _draw():
	if chart_data.is_empty():
		return
		
	var center = size / 2.0
	var radius = min(size.x, size.y) / 2.0
	
	var total_score = 0.0
	for value in chart_data.values():
		total_score += value

	if total_score == 0.0:
		draw_circle(center, radius, Color(0.5, 0.5, 0.5, 0.3))
		return
		
	var current_angle = -TAU / 4.0
	
	for name in chart_data.keys():
		var score = chart_data[name]
		if score <= 0.0:
			continue

		var angle_shift = (score / total_score) * TAU
		var next_angle = current_angle + angle_shift

		var color = class_colors.get(name, Color.WHITE)
		draw_pie_sector(center, radius, current_angle, next_angle, color)
		
		current_angle = next_angle

func draw_pie_sector(center: Vector2, radius: float, angle_from: float, angle_to: float, color: Color):
	var nb_points = 32
	var points = PackedVector2Array()
	points.append(center)
	
	for i in range(nb_points + 1):
		var angle = angle_from + i * (angle_to - angle_from) / nb_points
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
		
	draw_polygon(points, PackedColorArray([color]))
