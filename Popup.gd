extends Node2D

func init(text, color):
	$Label.text = text
	$Label.add_color_override("font_color", color)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_parent().dead:
		yield(get_tree().create_timer(0.5), "timeout")
		queue_free()


func _on_Timer_timeout():
	queue_free()
