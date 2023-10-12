extends Node

var Mob = preload("Mob.tscn")
var Boss = preload("Boss.tscn")

var score
var salt = 0
var lives = 1
const max_lives = 4

var damage = false

func _ready():
	randomize()
	var screen_size = OS.get_screen_size()
	var window_size = OS.get_window_size()
	OS.set_window_position(screen_size*0.5 - window_size*0.5)
	loadData()
	new_game()

func loadData():
	var file = File.new()
	file.open("user://hate.dat", File.READ)
	var content = file.get_as_text()
	var highScore = int(content)
	$HUD.update_highscore(highScore)
	file.close()

func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$BossTimer.stop()

func new_game():
	score = 0
	salt = 0
	lives = 2
	$HUD.reset_score()
	$Player.start($StartPosition.position)
	$HUD/StartLabel.visible = true
	$HUD/Lives.setLives(lives)
	$StartTimer.start()
	$MobTimer.wait_time = 0.75
	$BossTimer.wait_time = 3
	$DamageTimer.wait_time = 1.5

func maxSalt():
	salt = 0
	lives = clamp(lives + 1, 0, max_lives)
	$HUD/Lives.setLives(lives)
	var popupPos = Vector2($Player.position.x, $Player.position.x + 30)
	$Player.createPopup("Extra Life!", Color("#fff200"), popupPos)

func _process(_delta):	
	if Input.is_action_pressed("ui_accept"):
		if lives <= 0:
			new_game()
	$HUD/Salt.value = salt
	if salt > 95:
		maxSalt()

func _on_StartTimer_timeout():
	$HUD/StartLabel.visible = false
	$MobTimer.start()
	$BossTimer.start()
	$ScoreTimer.start()

func _on_ScoreTimer_timeout():
	score += 1
	$HUD.update_score(score)
	$MobTimer.wait_time -= .01

func spawn(enemy):
	# Choose a random location on Path2D.
	$MobPath/MobSpawnLocation.offset = randi()
	# Create a Mob instance and add it to the scene.
	var mob = enemy.instance()
	
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

func _on_MobTimer_timeout():
	spawn(Mob)

func _on_Bosstimer_timeout():
	spawn(Boss)

func _on_DamageTimer_timeout():
	$Player/AnimatedSprite.modulate = Color(1,1,1)
	damage = false

func _on_Player_hit():
	if !damage:
		lives -= 1
		if lives > 0:
			damage = true
			$DamageTimer.start()
			$HUD/Lives.setLives(lives)
		else:
			game_over()
