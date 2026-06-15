extends DraggableObject

var box_ref = []
var dust_percentage = 0.0
var dust_positions = []

@onready var audio = $cardPlay
var dust_tex = load("res://assets/dustParticle.png")

var dust_canvas

func _ready() -> void:
	super()
	if dust_percentage > 0.0:
		dust_canvas = Node2D.new()
		add_child(dust_canvas)
	
		dust_canvas.draw.connect(_on_dust_canvas_draw)
	
		dust_canvas.queue_redraw()
	
			
func _on_dust_canvas_draw():
	if dust_positions.is_empty():
		return
		
	var original_size = dust_tex.get_size()
	var scaled_size = original_size * 5.5
	var offset = scaled_size / 2.0
	
	for pos in dust_positions:
		var target_rect = Rect2(pos - offset, scaled_size)
		
		dust_canvas.draw_texture_rect(dust_tex, target_rect, false)
	

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group('draggable-box'):
		box_ref.append(area.type)
		
		
func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group('draggable-box'):
		box_ref.erase(area.type)
		
		
func _input(event: InputEvent) -> void:
	if is_active:
		if event is InputEventMouseButton:
			if event.pressed:
				if get_rect().has_point(to_local(event.position)):
					draggable = true
					touchOffset = get_global_mouse_position() - global_position

			else :
				draggable = false
				if box_ref.size() > 0 :
					_kill()
					SignalManager.correct_box.emit(box_ref[0], self.texture.resource_path, self.type)
				else:
					_send_back()

func play_audio():
	audio.play()
