extends Node

export (PackedScene) var Mob
var score
var dead = false

func _ready():
	randomize()
	var screen_size = OS.get_screen_size()
	var window_size = OS.get_window_size()
	OS.set_window_position(screen_size*0.5 - window_size*0.5)
	new_game()

func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.reset_score()
	$Player.die()
	dead = true

func new_game():
	score = 0
	dead = false
	$Player.start($StartPosition.position)
	$HUD/StartLabel.visible = true
	$StartTimer.start()
	$MobTimer.wait_time = 0.75

func _process(_delta):	
	if Input.is_action_pressed("ui_accept"):
		if dead:
			new_game()

func _on_StartTimer_timeout():
	$HUD/StartLabel.visible = false
	$MobTimer.start()
	$ScoreTimer.start()

func _on_ScoreTimer_timeout():
	score += 1
	$HUD.update_score(score)
	$MobTimer.wait_time -= .01

func _on_MobTimer_timeout():
	# Choose a random location on Path2D.
	$MobPath/MobSpawnLocation.offset = randi()
	# Create a Mob instance and add it to the scene.
	var mob = Mob.instance()
	
	add_child(mob)
	# Set the mob's direction perpendicular to the path direction.
	var direction = $MobPath/MobSpawnLocation.rotation + PI / 2
	# Set the mob's position to a random location.
	mob.position = $MobPath/MobSpawnLocation.position
	# Add some randomness to the direction.
	direction += rand_range(-PI / 4, PI / 4)
	mob.rotation = direction
	# Set the velocity (speed & direction).
	var min_speed = 250 + (score * 2) # Minimum speed range.
	var max_speed = 500 + (score * 2) # Maximum speed range.
	
	mob.linear_velocity = Vector2(rand_range(min_speed , max_speed), 0)
	mob.linear_velocity = mob.linear_velocity.rotated(direction)

