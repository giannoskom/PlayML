extends Node2D

@export var photo_scene: PackedScene 

var unspawned_data
@onready var monitor_ui = $Monitor

@onready var pet = $pet 

var evaluation
const TABLE_POSITION = 443
var resource = load("res://dialogue.dialogue")

func _ready() -> void:
	DialogueManager.show_dialogue_balloon(resource, "level_3")
	await DialogueManager.dialogue_ended
	SignalManager.button_train_pressed.connect(button_train_pressed)
	SignalManager.button_test_pressed.connect(button_test_pressed)
	unspawned_data = PipelineManager.get_dataset().duplicate() 
	
	if unspawned_data.size() > 0:
		print("Dataset loaded! Items: ", unspawned_data.size())

func button_test_pressed():
	print("button test pressed")
	SignalManager.button_test_pressed.disconnect(button_test_pressed) 
	
	
	var test_set = [
		{"type": "dog", "texture": "res://assets/mg3/testSet/dog1.png"},
		{"type": "dog", "texture": "res://assets/mg3/testSet/dog2.png"},
		{"type": "dog", "texture": "res://assets/mg3/testSet/dog3.png"},
		{"type": "cat", "texture": "res://assets/mg3/testSet/cat1.png"},
		{"type": "cat", "texture": "res://assets/mg3/testSet/cat2.png"},
		{"type": "cat", "texture": "res://assets/mg3/testSet/cat3.png"},
		{"type": "bird", "texture": "res://assets/mg3/testSet/bird1.png"},
		{"type": "bird", "texture": "res://assets/mg3/testSet/bird2.png"},
		{"type": "bird", "texture": "res://assets/mg3/testSet/bird3.png"}
	]
	
	var correct_answers = 0
	
	for item in test_set:
		var true_class = item["type"]
		
		var success_chance = evaluation["class_scores"].get(true_class, 0.0)
		
		var roll = randf_range(0.0, 100.0)
		
		var is_correct = false
		var stamp_text = ""
		
		if roll <= success_chance:
			is_correct = true
			stamp_text = "✅ " + true_class.to_upper()
			correct_answers += 1
		else:
			is_correct = false
			var bias_class = evaluation.get("dominant_class", "UNKNOWN")
			var guessed_class = ""
			
			# Αν το bias ΔΕΝ είναι η σωστή απάντηση, το AI πέφτει στην παγίδα του bias του
			if bias_class != true_class and bias_class != "UNKNOWN":
				guessed_class = bias_class
			else:
				# Αν το bias ΕΙΝΑΙ η σωστή απάντηση (αλλά απέτυχε τη ζαριά), 
				# ψάχνουμε την αμέσως επόμενη πιο δυνατή κλάση από τα scores.
				var highest_wrong_score = -1.0
				guessed_class = "UNKNOWN"
				
				for c_name in evaluation["class_scores"].keys():
					# Αγνοούμε την αληθινή κλάση για να βρούμε το "δεύτερο" bias
					if c_name != true_class:
						if evaluation["class_scores"][c_name] > highest_wrong_score:
							highest_wrong_score = evaluation["class_scores"][c_name]
							guessed_class = c_name
			
			stamp_text = "❌ " + guessed_class.to_upper()
		await monitor_ui.play_test_animation(item["texture"], is_correct, stamp_text)
		
	PipelineManager.test_score = correct_answers
	DialogueManager.show_dialogue_balloon(resource, "level_3_close")
	await DialogueManager.dialogue_ended
	get_tree().change_scene_to_file("res://scenes/report.tscn")


func button_train_pressed():
	monitor_ui.show_loading(true)
	
	var total_images = unspawned_data.size()
	
	if total_images == 0:
		monitor_ui.show_loading(false)
		return

	var time_between_images = clamp(2.0 / float(total_images), 0.05, 0.3)
	
	for i in range(total_images):
		if i % 3 == 0: monitor_ui.set_loading_text("Processing Data.")
		elif i % 3 == 1: monitor_ui.set_loading_text("Processing Data..")
		else: monitor_ui.set_loading_text("Processing Data...")
		
		var item = unspawned_data[i]
		throw_image_to_pet(item)

		await get_tree().create_timer(time_between_images).timeout
		
	await get_tree().create_timer(0.5).timeout
	
	
	evaluation = evaluate_dataset(unspawned_data)
	var class_scores = evaluation["class_scores"]
	

	monitor_ui.display_scores(class_scores)
	monitor_ui.show_loading(false)
	evolve_pet(class_scores)
	pet.global_position.y = TABLE_POSITION - (pet.texture.get_size().y / 2.0)
	PipelineManager.save_data_for_pie(evaluation)
	DialogueManager.show_dialogue_balloon(resource, "level_3_test")

func throw_image_to_pet(data_entry: Dictionary):

	var new_photo = photo_scene.instantiate()

	new_photo.set_script(load("res://scripts/picture_mg_2.gd"))

	new_photo.type = data_entry["type"]
	new_photo.is_negative = data_entry["is_negative"]
	new_photo.dust_percentage = data_entry.get("dirty_percentage", 0.0)
	new_photo.dust_positions = data_entry.get("dust_positions", [])
	new_photo.texture = load(data_entry["texture"])
	new_photo.z_index = 2
	
	add_child(new_photo)
	

	if "is_active" in new_photo:
		new_photo.is_active = false

	var start_x = (get_viewport_rect().size.x / 2) + randf_range(-120, 120)
	var start_y = get_viewport_rect().size.y - 150
	new_photo.global_position = Vector2(start_x, start_y)
	

	var spawn_tween = create_tween()
	spawn_tween.tween_callback(new_photo.play_audio)
	
	spawn_tween.tween_property(new_photo, "global_position", pet.global_position, 0.5)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_IN)
		
	spawn_tween.parallel().tween_property(new_photo, "scale", Vector2(0.2, 0.2), 0.5)
	spawn_tween.parallel().tween_property(new_photo, "modulate:a", 0.0, 0.5)
	
	spawn_tween.tween_callback(new_photo.queue_free)


func evaluate_dataset(dataset: Array) -> Dictionary:
	var target_classes = ["dog", "cat", "bird"]
	var class_stats = {}
	
	for c in target_classes:
		class_stats[c] = {
			"total_items": 0,
			"usable_info": 0.0,
			"negatives": 0,
			"duplicate_penalty": 0.0
		}
		
	var seen_textures = {} 
	var gamma = 2.0
	var negative_weight = 15.0
	var duplicate_dust_weight = 15.0 
	
	for item in dataset:
		var box = item.get("assigned_box", "")
		if not target_classes.has(box):
			continue
			
		var texture = item["texture"]
		var dust = item["dirty_percentage"]
		
		if seen_textures.has(texture):
			class_stats[box]["duplicate_penalty"] += (dust * duplicate_dust_weight)
			continue 
			
		seen_textures[texture] = true
		class_stats[box]["total_items"] += 1
		
		if item["is_label_correct"]:
			class_stats[box]["usable_info"] += pow(1.0 - dust, gamma)
			
		if item["is_negative"]:
			class_stats[box]["negatives"] += 1

	var class_scores = {}
	var highest_score = -1.0
	var best_class = ""
	var sum_scores = 0.0
	var optimal_item_count = 2.0
	
	for c_name in target_classes:
		var stats = class_stats[c_name]
		var q_c = 0.0
		
		if stats["total_items"] > 0:
			var base_q = (stats["usable_info"] / float(stats["total_items"])) * 100.0
			var volume_fraction = min(1.0, float(stats["total_items"]) / optimal_item_count)
			base_q *= volume_fraction
			var neg_penalty = (float(stats["negatives"]) / float(stats["total_items"])) * negative_weight
			var dup_penalty = stats["duplicate_penalty"]
			
			q_c = clamp(base_q - neg_penalty - dup_penalty, 0.0, 100.0)
			
		class_scores[c_name] = q_c
		sum_scores += q_c
		
		if q_c > highest_score:
			highest_score = q_c
			best_class = c_name
			
	var global_score = sum_scores / target_classes.size()
	
	return {
		"global_score": global_score,
		"class_scores": class_scores,
		"dominant_class": best_class
	}
	
func evolve_pet(class_scores: Dictionary):
	var form_name = ""
	
	if class_scores.has("bird") and class_scores["bird"] > 50.0:
		form_name += "v"
	else:
		form_name += "x"
		
	if class_scores.has("dog") and class_scores["dog"] > 50.0:
		form_name += "v"
	else:
		form_name += "x"
		
	if class_scores.has("cat") and class_scores["cat"] > 50.0:
		form_name += "v"
	else:
		form_name += "x"
		
	print("Evolution resulting form: ", form_name)
	
	var texture_path = "res://assets/pet/" + form_name + ".png"
	PipelineManager.pet_texture = texture_path
	
	pet.texture = load(texture_path)
