extends Area2D

var Popup = preload("Popup.tscn")

signal hit

export var speed = 400  # How fast the player will move (pixels/sec).
var screen_size  # Size of the game window.

const position_buffer_x = 25
const position_buffer_y = 60
const crouch_buffer = 30
const jump_boost = 1
const grav_boost = 2
const factor = 1.8
const air_factor = 1

var gravity_acceleration = 10;

var misses = []

func start(pos):
	position = pos
	misses = []
	$AnimatedSprite.animation = "walk"
	show()

func _ready():
	screen_size = get_viewport_rect().size
	hide()
	
func loadCollisionBox(name):
	$StandCollision.disabled = name != "stand"
	$Miss/StandCollisionMiss.disabled = name != "stand"
	$NearMiss/StandCollisionNMiss.disabled = name != "stand"
	$JumpCollision.disabled = name != "jump"
	$Miss/JumpCollisionMiss.disabled = name != "jump"
	$NearMiss/JumpCollisionNMiss.disabled = name != "jump"
	$CrouchCollision.disabled = name != "crouch"
	$Miss/CrouchCollisionMiss.disabled = name != "crouch"
	$NearMiss/CrouchCollisionNMiss.disabled = name != "crouch"

func createPopup(text, color, pos, important=false):
	var Main = get_parent()
	var msg = Popup.instance()
	msg.init(text, color, important)
	msg.position.x = pos.x
	msg.position.y = clamp(pos.y, 30, 550)
	if Main.lives > 0:
		Main.add_child(msg)
	
func _physics_process(delta):
	var velocity = Vector2()  # The player's movement vector.
	
	var isOnGround = position.y >= screen_size.y - position_buffer_y
		
	var isCrouching = false
	if get_parent().lives > 0:
		if Input.is_action_pressed("ui_right"):
			velocity.x += 1 * (factor if isOnGround else air_factor)
		if Input.is_action_pressed("ui_left"):
			velocity.x -= 1 * (factor if isOnGround else air_factor)
		if Input.is_action_pressed("ui_down"):
			isCrouching = true
		if Input.is_action_pressed("ui_up"):
			velocity.y -= jump_boost * factor
	if velocity.length() > 0:
		velocity = velocity * speed
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()
		
	# gravity
	gravity += (20 if isCrouching else 10) * grav_boost
			
	position.x += velocity.x * delta
	position.y += ((velocity.y * 0.9) + gravity) * delta
	position.x = clamp(position.x, 0 + position_buffer_x, screen_size.x - position_buffer_x)
	position.y = clamp(position.y, 0 + position_buffer_y, screen_size.y - position_buffer_y)
	
#	isOnGround = position.y == screen_size.y - position_buffer_y
	if get_parent().lives > 0:
		if velocity.y != 0 && gravity > 0:
			$AnimatedSprite.animation = "up"
			loadCollisionBox("jump")
		elif velocity.x != 0 || (isOnGround && !isCrouching):
			$AnimatedSprite.animation = "walk"
			loadCollisionBox("stand")
		if isCrouching:
			loadCollisionBox("crouch")
			$AnimatedSprite.animation = "crouch"
			if isOnGround:
				position.y += crouch_buffer
		scale.x = -1 if velocity.x < 0 else 1
	else:
		$AnimatedSprite.animation = "dead"
		$AnimatedSprite.modulate = Color(1, 1, 1)
		
	if isOnGround:
		gravity = 0

func _on_Player_body_entered(body):
	misses.append(body)
	if !get_parent().damage:
		createPopup("Ouch D:", Color(1,0,0), body.position, true)
		$AnimatedSprite.modulate = Color(1, 0.164706, 0.164706)
	emit_signal("hit")

func _on_Miss_body_exited(body):
	var Main = get_parent()
	if !get_parent().damage:
		var pos = body.position
		yield(get_tree().create_timer(0.1), "timeout")
		if !(body in misses):
			Main.salt += 15
			misses.append(body)
			var msg = Popup.instance()
			createPopup("Miss", Color(1,1,1), pos)

func _on_NearMiss_body_exited(body):
	var Main = get_parent()
	if !get_parent().damage:
		var pos = body.position
		yield(get_tree().create_timer(0.05), "timeout")
		if !(body in misses):
			Main.salt += 25
			misses.append(body)
			createPopup("Near\nMiss", Color(0.764706, 0.247059, 1), pos)
