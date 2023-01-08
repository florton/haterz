extends CanvasLayer

signal start_game

var high_score = 0;
var last_score = 0;

func update_score(score):
	$ScoreLabel.text = str(score)
	last_score = score;
	if score > high_score:
		high_score = score
	$HighScoreLabel.text = str(high_score)
	
func reset_score():
	$LastScoreLabel.text = str(last_score)
	$ScoreLabel.text = str(0)
