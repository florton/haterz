extends Area2D

signal hit

export var speed = 400  # How fast the player will move (pixels/sec).
var screen_size  # Size of the game window.

const position_buffer_x = 25
const position_buffer_y = 60
const crouch_buffer = 30

var gravity_acceleration = 0;
var isDead = false

func start(pos):
	position = pos
	isDead = false
	$AnimatedSprite.animation = "walk"
	show()

func _ready():
	screen_size = get_viewport_rect().size
	hide()
	
func loadCollisionBox(name):
	$StandCollisionR.disabled = name != "standR"
	$StandCollisionL.disabled = name != "standL"
	$JumpCollision.disabled = name != "jump"
	$CrouchCollision.disabled = name != "crouch"
	
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
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()
		
	# gravity
	gravity += 10
		
	position.x += velocity.x * delta	
	position.y += ((velocity.y * 1.2) + gravity)* delta	
	position.x = clamp(position.x, 0 + position_buffer_x, screen_size.x - position_buffer_x)
	position.y = clamp(position.y, 0 + position_buffer_y, screen_size.y - position_buffer_y)
	
	var isOnGround = position.y == screen_size.y - position_buffer_y
	if !isDead:
		if velocity.y != 0 && gravity > 0:
			$AnimatedSprite.animation = "up"
			loadCollisionBox("jump")
			$AnimatedSprite.flip_v = velocity.y > 0
		elif velocity.x != 0 || (isOnGround && !isCrouching):
			$AnimatedSprite.animation = "walk"
			loadCollisionBox("standL" if velocity.x < 0 else "standR")
			$AnimatedSprite.flip_v = false
			$AnimatedSprite.flip_h = velocity.x < 0
		if isCrouching:
			loadCollisionBox("crouch")
			$AnimatedSprite.animation = "crouch"
			if isOnGround:
				position.y += crouch_buffer
		
	if isOnGround:
		gravity = 0

func _on_Player_body_entered(_body):
	emit_signal("hit")
	
func die():
	isDead = true
	$AnimatedSprite.animation = "dead"
