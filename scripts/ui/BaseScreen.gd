extends CanvasLayer

onready var tween = $Tween

func appear() -> SceneTreeTween:
	get_tree().call_group("buttons", "set_disabled", false)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
	offset.x = 500
	tween.tween_property(self, "offset:x", 0, 0.5)
	return tween
	
func disappear() -> SceneTreeTween:
	get_tree().call_group("buttons", "set_disabled", true)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
	offset.x = 0
	tween.tween_property(self, "offset:x", 500, 0.5)
	return tween
	
