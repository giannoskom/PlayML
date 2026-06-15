extends Control

@onready var loading_label = $loading 
@onready var stats_container = $VBoxContainer
@onready var bird_label = $VBoxContainer/bird 
@onready var dog_label = $VBoxContainer/dog
@onready var cat_label = $VBoxContainer/cat
@onready var test_image = $screen/Test_image
@onready var stamp_label = $screen/pic_label 
@onready var progress_tracker = $screen/progress_tracker

func _ready():
	loading_label.visible = false
	stats_container.visible = true

func show_loading(is_loading: bool):
	loading_label.visible = is_loading
	stats_container.visible = not is_loading

func set_loading_text(new_text: String):
	loading_label.text = new_text

func display_scores(scores: Dictionary):
	stats_container.visible = true
	if scores.has("bird"): bird_label.text = "BIRD: " + str(round(scores["bird"])) + "%"
	if scores.has("dog"): dog_label.text = "DOG: " + str(round(scores["dog"])) + "%"
	if scores.has("cat"): cat_label.text = "CAT: " + str(round(scores["cat"])) + "%"
	

func play_test_animation(texture_path: String, is_correct: bool, stamp_text: String):
	stats_container.visible = false
	test_image.texture = load(texture_path)
	test_image.visible = true
	stamp_label.visible = false
	
	test_image.position.x = size.x + 100
	
	var tween = create_tween()
	
	var center_x = (size.x / 2) - (test_image.size.x / 2)
	tween.tween_property(test_image, "position:x", center_x, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	tween.tween_interval(0.5)
	
	tween.tween_callback(func():
		stamp_label.text = stamp_text
		stamp_label.visible = true
		if is_correct:
			stamp_label.modulate = Color(0.2, 0.9, 0.2)
		else:
			stamp_label.modulate = Color(0.9, 0.2, 0.2)
	)
	
	tween.tween_interval(1.0)
	
	tween.tween_property(test_image, "position:x", -150, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(stamp_label, "modulate:a", 0.0, 0.3)
	
	await tween.finished
	
	var dot = ColorRect.new()
	dot.custom_minimum_size = Vector2(10, 10)
	dot.color = Color.GREEN if is_correct else Color.RED
	progress_tracker.add_child(dot)
