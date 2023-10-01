extends CanvasLayer

onready var message = $Message
onready var animation_player = $AnimationPlayer
onready var score_box = $ScoreBox
onready var score = $ScoreBox/HBoxContainer/Score

func _ready():
	# Change message pivot to it's middle
	# As we had to change the animation to use scale. 
	# And it only scales from top left where the pivot is originally
	message.rect_pivot_offset = message.rect_size / 2
	
func show_message(text):
	message.text = text
	animation_player.play("show_message")

func hide():
	score_box.hide()
	message.hide()

func show():
	score_box.show()
	message.show()
	
func update_score(value):
	score.text = str(value)
