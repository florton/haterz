extends Node2D

var important = false

func init(text, color, i=false):
	$Label.text = text
	$Label.add_color_override("font_color", color)
	important = i

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_parent().damage && !important:
		print($Label.text, important)
		queue_free()


func _on_Timer_timeout():
	queue_free()
