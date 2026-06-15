extends Sprite2D

class_name DraggableObject

var draggable = false
var touchOffset
var initialPos : Vector2
var dust_scene :PackedScene = preload("res://scenes/DustParticle.tscn")

@export var type := ""
var negative_material : Material = preload("res://shaders/negative.tres")

var is_active = false
var is_negative = false



func _ready() -> void:
	if is_negative:
		self.material = negative_material

func _physics_process(delta: float) -> void:
	if draggable == true and touchOffset != null:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "global_position", get_global_mouse_position() - touchOffset, 15 * delta)
			
func _kill():
	self.queue_free()
	
func _send_back():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", initialPos, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
