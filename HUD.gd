extends CanvasLayer

signal start_game

var high_score = 0;
var last_score = 0;

func saveData(newScore):
	var file = File.new()
	file.open("user://hate.dat", File.WRITE)
	file.store_string(str(newScore))
	file.close()

func update_score(score):
	$ScoreLabel.text = str(score)
	last_score = score;
	if score > high_score:
		high_score = score
		saveData(high_score)
	$HighScoreLabel.text = str(high_score)

func update_highscore(highscore):
	high_score = highscore
	$HighScoreLabel.text = str(high_score)
	
func reset_score():
	$LastScoreLabel.text = str(last_score)
	$ScoreLabel.text = str(0)
