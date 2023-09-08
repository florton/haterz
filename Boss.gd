extends RigidBody2D

func _ready():
	$AnimatedSprite.animation = "boss"
	$AnimatedSprite.frame = randi() % 3
	
func _process(delta):
	if get_parent().dead:
		queue_free()
	
func _on_VisibilityNotifier2D_screen_exited():
	self.queue_free()
	
func _integrate_forces(state):	
	var player =  get_parent().get_node("Player")
	var direction = (player.global_position - global_position).normalized()
	if abs(direction.x) > .01 && abs(direction.y) > .01:
		apply_central_impulse(direction * 17)
