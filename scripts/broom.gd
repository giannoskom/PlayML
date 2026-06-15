extends DraggableObject

var can_play_audio := true
@export var audio_delay := 0.3

@onready var audio = $broom_audio
func _ready() -> void:
	initialPos = position

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if get_rect().has_point(to_local(event.position)):
				draggable = true
				touchOffset = get_global_mouse_position() - global_position
		else :
			draggable = false
			_send_back()


func _on_tip_area_area_entered(area: Area2D) -> void:
	if draggable:
		if area.is_in_group('dust'):
			if can_play_audio:
				audio.play()
				can_play_audio = false
				
				get_tree().create_timer(audio_delay).timeout.connect(func():
					can_play_audio = true
				)
			area.queue_free()
