extends Node2D

var correct := 0
@export var photo_scene : PackedScene 
@onready var save_audio = $save_audio

var grid_positions = [
	Vector2(150, 300), Vector2(350, 300), Vector2(550, 300),
	Vector2(150, 500), Vector2(350, 500), Vector2(550, 500),
	Vector2(150, 700), Vector2(350, 700), Vector2(550, 700)
]

var unspawned_data = []
var active_photos_on_table = 0

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			DialogueManager.show_dialogue_balloon(load("res://dialogue.dialogue"), "labeling_intro")

func _ready() -> void:
	SignalManager.correct_box.connect(check_for_next_wave)
	
	unspawned_data = PipelineManager.get_dataset().duplicate() 
	print(unspawned_data.size())
	spawn_next_wave()
	
func spawn_next_wave():
	var photos_to_spawn = min(9, unspawned_data.size())
	
	if photos_to_spawn == 0:
		return
		
	active_photos_on_table = photos_to_spawn
	
	for i in range(photos_to_spawn):
		var data_entry = unspawned_data.pop_front()
		
		var new_photo = photo_scene.instantiate()
		new_photo.set_script(load("res://scripts/picture_mg_2.gd"))
		
		new_photo.type = data_entry["type"]
		new_photo.z_index = 1
		new_photo.is_negative = data_entry["is_negative"]
		new_photo.dust_percentage = data_entry["dirty_percentage"]
		new_photo.dust_positions = data_entry["dust_positions"]

	
	
		new_photo.texture = load(data_entry["texture"])
		add_child(new_photo)
		
		var target_pos = grid_positions[i]

		var spawn_tween = create_tween()

		if i > 0:
			spawn_tween.tween_interval(i * 0.4)


		spawn_tween.tween_callback(new_photo.play_audio)
		spawn_tween.tween_property(new_photo, "global_position", target_pos, 0.5)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
		
		spawn_tween.chain().tween_callback(func():
			new_photo.initialPos = target_pos
			new_photo.is_active = true
		)
		

func check_for_next_wave(a, b, c):
	save_audio.play()
	active_photos_on_table -= 1
	print(active_photos_on_table)
	if active_photos_on_table == 0:
		if unspawned_data.size():
			spawn_next_wave()
		else:
			print('telos')
			get_tree().change_scene_to_file("res://scenes/mg_3.tscn")
