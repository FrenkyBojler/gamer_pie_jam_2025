extends TextureProgressBar

func _ready() -> void:
	value = GameState.posts_score_critical_value
	max_value = GameState.posts_score_critical_value * 2
	GameState.posts_score_update.connect(func(score: int):
		value = GameState.posts_score_critical_value + score
	)
