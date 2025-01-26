extends TextureProgressBar

func _ready() -> void:
	value = GameState.freeze_score_critical_value
	max_value = GameState.freeze_score_critical_value
	GameState.freeze_score_updated.connect(func(score: int):
		max_value = GameState.freeze_score_critical_value
		min_value = 0
		value = GameState.freeze_score_critical_value - score
	)
