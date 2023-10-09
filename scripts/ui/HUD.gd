extends CanvasLayer

onready var message = $Message
onready var message_animation_player = $MessageAnimationPlayer
onready var score_box = $ScoreBox
onready var score_text = $ScoreBox/ScoreVStack/ScoreHStack/ScoreContainer/Score
onready var bonus_text = $ScoreBox/ScoreVStack/ScoreHStack/BonusVStack/Bonus
onready var bonus_animation_player = $BonusAnimationPlayer
onready var score_animation_player = $ScoreAnimationPlayer
onready var progress_bar = $ScoreBox/ScoreVStack/ProgressBar
onready var effect_animation_player = $EffectAnimationPlayer

var score = 0
var bonus_progress = 0.0

func _ready():
	# Change message pivot to it's middle
	# As we had to change the animation to use scale. 
	# And it only scales from top left where the pivot is originally
	message.rect_pivot_offset = message.rect_size / 2
	
func show_message(text):
	message.text = text
	message_animation_player.play("show_message")

func hide():
	score_box.hide()
	message.hide()

func show():
	score_box.show()
	message.show()
	
func update_score(score, value):
	$Tween.interpolate_property(self, "score", score, value, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	score_animation_player.play("score")


func update_bonus(value: float):
	_set_bonus_progress_bar(value)
	
	# Don't do anything if the value is the same
	if bonus_text.text == str(int(value)):
		return
		
	bonus_text.text = str(value)
	if value > 1:
		bonus_animation_player.play("bonus")


func _on_Tween_tween_step(object, key, elapsed, value):
	score_text.text = str(int(value))
	

func _set_bonus_progress_bar(value: float) -> void:
	if value == 1.0:
		bonus_progress = 0
		progress_bar.value = 0
		return
		
	bonus_progress = clamp(int(value * 10) % 10, 0, 9)
	
	print("bonus_progress: ", bonus_progress)
	if progress_bar.value == 9 && bonus_progress == 0:
		effect_animation_player.play("score_effect")
	
	progress_bar.value = bonus_progress
	
