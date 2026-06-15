extends DraggableObject

signal photo_saved
signal trash
signal negative

var is_dirty = false

var total_dust = 0
var is_in_save_zone = false
var is_in_neg_machine = false
var is_in_trashcan = false

@onready var audio = $cardPlay

func _ready():
	super()
	if is_dirty:
		call_deferred("generate_dust")
	else:
		total_dust = 1

func _input(event: InputEvent) -> void:
	if is_active:
		if event is InputEventMouseButton:
			if event.pressed:
				if get_rect().has_point(to_local(event.position)):
					z_index = 3
					draggable = true
					touchOffset = get_global_mouse_position() - global_position
					
			else :
				draggable = false
				if is_in_save_zone == true:
					var drop_tween = create_tween()
					photo_saved.emit()
					drop_tween.tween_property(self, "global_position", global_position + Vector2(0, 600), 0.3)\
					.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
					
					var dust = get_tree().get_nodes_in_group("dust").size()
					var per = float(dust) / float(total_dust)
					
					PipelineManager.save_photo_to_pipeline(self.texture.resource_path, type, is_negative, per, get_remaining_dust_positions())
					drop_tween.tween_callback(self.queue_free)
				elif is_in_neg_machine:
					var in_pos = Vector2(561, 482)
					var out_pos = Vector2(561, 845)
			
			
					var machine_tween = create_tween()
					machine_tween.tween_property(self, "scale", Vector2(0.3, 0.3), 0.15).set_trans(Tween.TRANS_SINE)
					negative.emit()
					machine_tween.tween_property(self, "global_position", in_pos, 0.15)\
					.set_trans(Tween.TRANS_SINE)
			
					machine_tween.tween_callback(func(): z_index = 1)
			
					machine_tween.tween_property(self, "global_position", in_pos + Vector2(0, 180), 0.4)\
					.set_trans(Tween.TRANS_SINE)
			
	
					machine_tween.tween_callback(func():
						if is_negative:
							self.material = null
							is_negative = false
						else:
							is_negative = true
							self.material = negative_material
					)
			
	
					machine_tween.tween_interval(0.3)
			
		
					machine_tween.tween_property(self, "global_position", out_pos, 0.4)\
					.set_trans(Tween.TRANS_SINE)
				
					machine_tween.tween_callback(func():
						z_index = 3
						scale=Vector2(0.4, 0.4)
						_send_back()
					)
				elif is_in_trashcan:
					trash.emit()
					self.queue_free()
				else:
					_send_back()

func generate_dust():
	if not dust_scene:
		print("no dust particle")
		return
		
	var tex_size = texture.get_size()
	
	var step = 60
	
	var cols = int(tex_size.x / step)
	var rows = int(tex_size.y / step)
	
	var grid_width = cols * step
	var grid_height = rows * step
	
	var start_x = -grid_width / 2.0
	var start_y = -grid_height / 2.0
	
	for i in range(cols):
		for j in range(rows):
			var new_dust = dust_scene.instantiate()
			add_child(new_dust)
			
			var pos_x = start_x + (i * step) + (step / 2.0)
			var pos_y = start_y + (j * step) + (step / 2.0)
			
			new_dust.position = Vector2(pos_x, pos_y)
			total_dust += 1

func get_remaining_dust_positions() -> Array:
	if !is_dirty:
		return []
		
	var dust_positions = []
	
	for child in get_children():
		if child.is_in_group("dust") and is_instance_valid(child):
			dust_positions.append(child.position)
			
	return dust_positions
	
func play_audio():
	audio.play()
