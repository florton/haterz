extends Area2D
signal hit

@export var speed = 400  # How fast the player will move (pixels/sec).
var screen_size  # Size of the game window.

const position_buffer_x = 25
const position_buffer_y = 60
const crouch_buffer = 30

var gravity_acceleration = 0;
var isDead = false

func start(pos):
	position = pos
	isDead = false
	$AnimatedSprite2D.animation = "walk"
	show()
	$CollisionShape2D.disabled = false

func _ready():
	screen_size = get_viewport_rect().size
	hide()
	
func _process(delta):
	var velocity = Vector2()  # The player's movement vector.
	
	var isCrouching = false
	if !isDead:
		if Input.is_action_pressed("ui_right"):
			velocity.x += 1
		if Input.is_action_pressed("ui_left"):
			velocity.x -= 1
		if Input.is_action_pressed("ui_down"):
			isCrouching = true
		if Input.is_action_pressed("ui_up"):
			velocity.y -= 1
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		
	# gravity
	gravity += 10
		
	position.x += velocity.x * delta	
	position.y += ((velocity.y * 1.2) + gravity)* delta	
	position.x = clamp(position.x, 0 + position_buffer_x, screen_size.x - position_buffer_x)
	position.y = clamp(position.y, 0 + position_buffer_y, screen_size.y - position_buffer_y)
	
	var isOnGround = position.y == screen_size.y - position_buffer_y
	if !isDead:
		if velocity.y != 0 && gravity > 0:
			$AnimatedSprite2D.animation = "up"
			$AnimatedSprite2D.flip_v = velocity.y > 0
		elif velocity.x != 0 || isOnGround:
			$AnimatedSprite2D.animation = "walk"
			$AnimatedSprite2D.flip_v = false
			$AnimatedSprite2D.flip_h = velocity.x < 0

		if isCrouching:
			$CollisionShape2D.scale.y = 0.5
			$AnimatedSprite2D.animation = "crouch"
			if isOnGround:
				position.y += crouch_buffer
		else:
			$CollisionShape2D.scale.y = 1
		
	if isOnGround:
		gravity = 0

func _on_Player_body_entered(_body):
	#hide()  # Player disappears after being hit.
	emit_signal("hit")
	$CollisionShape2D.set_deferred("disabled", true)
	
func die():
	isDead = true
	$AnimatedSprite2D.animation = "dead"
