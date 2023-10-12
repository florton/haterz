extends RigidBody2D

var willCurve = false

func _ready():
	var mob_types = $AnimatedSprite.frames.get_animation_names()
	$AnimatedSprite.animation = mob_types[randi() % mob_types.size()]
	$AnimatedSprite.frame = randi() % 3
	
func _process(delta):
	if get_parent().lives <= 0:
		queue_free()
	
func _on_VisibilityNotifier2D_screen_exited():
	self.queue_free()
	
func _integrate_forces(state):
	if !willCurve:
		willCurve = randi() % 1000 < 10
	else:
		willCurve = randi() % 1000 > 50
			
	if willCurve:
		var player =  get_parent().get_node("Player")
		var direction = (player.global_position - global_position).normalized()
		#if abs(direction.x) > .01 && abs(direction.y) > .01:
		apply_central_impulse(direction * 17)
