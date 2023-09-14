extends Area2D

var Popup = preload("Popup.tscn")

signal hit

export var speed = 400  # How fast the player will move (pixels/sec).
var screen_size  # Size of the game window.

const position_buffer_x = 25
const position_buffer_y = 60
const crouch_buffer = 30

var gravity_acceleration = 0;
var isDead = false

var misses = []

func start(pos):
	position = pos
	misses = []
	isDead = false
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
	msg.position = pos
	if !Main.dead:
		Main.add_child(msg)

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
	gravity += 20 if isCrouching else 10
			
	position.x += velocity.x * delta
	position.y += ((velocity.y * 0.9) + gravity)* delta
	position.x = clamp(position.x, 0 + position_buffer_x, screen_size.x - position_buffer_x)
	position.y = clamp(position.y, 0 + position_buffer_y, screen_size.y - position_buffer_y)
	
	var isOnGround = position.y == screen_size.y - position_buffer_y
	if !isDead:
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
		
	if isOnGround:
		gravity = 0

func _on_Player_body_entered(body):
	misses.append(body)
	if !get_parent().damage:
		createPopup("Ouch D:", Color(1,0,0), body.position, true)
	emit_signal("hit")
	
func die():
	isDead = true
	$AnimatedSprite.animation = "dead"

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
