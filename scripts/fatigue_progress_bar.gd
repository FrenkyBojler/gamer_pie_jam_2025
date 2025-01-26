extends TextureProgressBar

func _ready() -> void:
	value = GameState.tired_score_critical_value
	max_value = GameState.tired_score_critical_value
	GameState.tired_score_updated.connect(func(score: int):
		max_value = GameState.tired_score_critical_value
		min_value = 0
		value = GameState.tired_score_critical_value - score
	)
