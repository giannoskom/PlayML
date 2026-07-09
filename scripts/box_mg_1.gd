extends box

var interactible = true
signal emptyBox

@export var photo_scene : PackedScene 

@export var table_position : Vector2
@onready var trash_audio = $"../throwAway"
@onready var negative_audio = $"../negative_machine"
@onready var save_audio = $"../save_audio"

var photo_recipes = [
	{
		"texture_path": "res://assets/mg2/animalCards/bunny.png", 
		"type": "bunny", "is_dirty": false, "is_negative": true
	},
	{
		"texture_path": "res://assets/mg2/animalCards/dog1.png", 
		"type": "dog", "is_dirty": false, "is_negative": false
	},
	{
		"texture_path": "res://assets/mg2/animalCards/cat2.png", 
		"type": "cat", "is_dirty": true, "is_negative": false
	},
	{
		"texture_path": "res://assets/mg2/animalCards/bird4.png", 
		"type": "bird", "is_dirty": false, "is_negative": true
	},
	{
		"texture_path": "res://assets/mg2/animalCards/frog.png", 
		"type": "frog", "is_dirty": true, "is_negative": true
	},
	{
		"texture_path": "res://assets/mg2/animalCards/cat1.png", 
		"type": "cat", "is_dirty": false, "is_negative": false
	},
	{
		"texture_path": "res://assets/mg2/animalCards/bird2.png", 
		"type": "bird", "is_dirty": true, "is_negative": false
	},
	{
		"texture_path": "res://assets/mg2/animalCards/dog5.png", 
		"type": "dog", "is_dirty": true, "is_negative": true
	},
	{
		"texture_path": "res://assets/mg2/animalCards/bear.png", 
		"type": "bear", "is_dirty": true, "is_negative": false
	},
	{
		"texture_path": "res://assets/mg2/animalCards/cat3.png", 
		"type": "cat", "is_dirty": false, "is_negative": true
	},
	{
		"texture_path": "res://assets/mg2/animalCards/bird1.png", 
		"type": "bird", "is_dirty": false, "is_negative": false
	},
	{
		"texture_path": "res://assets/mg2/animalCards/dog4.png", 
		"type": "dog", "is_dirty": false, "is_negative": true
	},
	{
		"texture_path": "res://assets/mg2/animalCards/dog2.png", 
		"type": "dog", "is_dirty": false, "is_negative": false
	},
	{
		"texture_path": "res://assets/mg2/animalCards/octapus.png", 
		"type": "octapus", "is_dirty": false, "is_negative": false
	},
	{
		"texture_path": "res://assets/mg2/animalCards/bird6.png", 
		"type": "bird", "is_dirty": true, "is_negative": false
	},
	{
		"texture_path": "res://assets/mg2/animalCards/cat4.png", 
		"type": "cat", "is_dirty": false, "is_negative": false
	},
	{
		"texture_path": "res://assets/mg2/animalCards/bird3.png", 
		"type": "bird", "is_dirty": false, "is_negative": false
	},
	{
		"texture_path": "res://assets/mg2/animalCards/dog6.png", 
		"type": "dog", "is_dirty": false, "is_negative": false
	},
	{
		"texture_path": "res://assets/mg2/animalCards/cat5.png", 
		"type": "cat", "is_dirty": true, "is_negative": true
	},
	{
		"texture_path": "res://assets/mg2/animalCards/dog3.png", 
		"type": "dog", "is_dirty": true, "is_negative": false
	},
	{
		"texture_path": "res://assets/mg2/animalCards/bird5.png", 
		"type": "bird", "is_dirty": true, "is_negative": true
	},
	{
		"texture_path": "res://assets/mg2/animalCards/axelotl.png", 
		"type": "axelotle", "is_dirty": false, "is_negative": false
	},
	{
		"texture_path": "res://assets/mg2/animalCards/crocodile.png", 
		"type": "crocodile", "is_dirty": false, "is_negative": false
	},
	{
		"texture_path": "res://assets/mg2/animalCards/cat1.png", 
		"type": "cat", "is_dirty": false, "is_negative": false
	}
]

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if interactible:
		if event is InputEventMouseButton:
				if event.pressed:
					interactible = false
					spawn_pic()
				
func spawn_pic():
	if not photo_scene:
		print("no scene in inspector")
		return
	
	if photo_recipes.size() == 0 :
		emptyBox.emit()
		return
		
	var current_recipe = photo_recipes.pop_front()
	var new_photo = photo_scene.instantiate()
	new_photo.set_script(load("res://scripts/picture_mg_1.gd"))
	new_photo.photo_saved.connect(_on_photo_saved)
	new_photo.trash.connect(_on_photo_in_trash)
	new_photo.negative.connect(_on_negative_machine)
	
	

	
	new_photo.type = current_recipe["type"]
	new_photo.is_dirty = current_recipe["is_dirty"]
	new_photo.is_negative = current_recipe["is_negative"]
	
	new_photo._ready()
	
	new_photo.texture = load(current_recipe["texture_path"])
	

	
	
	new_photo.global_position = self.global_position
	
	
	new_photo.scale = Vector2(0.1, 0.1)
	new_photo.rotation_degrees = randf_range(-30, 30) 
	
	get_parent().add_child(new_photo)
	
	new_photo.play_audio()
	
	var tween = create_tween().set_parallel(true) 
	
	
	tween.tween_property(new_photo, "global_position", table_position, 0.5)\
		.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		
	tween.tween_property(new_photo, "scale", Vector2(0.4, 0.4), 0.5)\
		.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		
	tween.tween_property(new_photo, "rotation_degrees", 0.0, 0.5)
	

	tween.chain().tween_callback(func():
		new_photo.initialPos = table_position
		new_photo.is_active = true
	)
	
func _on_photo_saved():
	save_audio.play()
	interactible = true
	
func _on_photo_in_trash():
	trash_audio.play()
	interactible = true
	
func _on_negative_machine():
	negative_audio.play()
