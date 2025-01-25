extends Control

const post_prefab = preload("res://prefabs/pc/post.tscn")

const user_profile_pic_1 = preload("res://assets/textures/ui/Dudette.PNG")
const user_profile_pic_2 = preload("res://assets/textures/ui/Grumpster.PNG")
const user_profile_pic_3 = preload("res://assets/textures/ui/Havin.PNG")
const user_profile_pic_4 = preload("res://assets/textures/ui/OutdoorBoi.PNG")
const user_profile_pic_5 = preload("res://assets/textures/ui/Randall.PNG")
const user_profile_pic_6 = preload("res://assets/textures/ui/Rando.PNG")

var profile_pics = [user_profile_pic_1, user_profile_pic_2, user_profile_pic_3, user_profile_pic_4, user_profile_pic_5, user_profile_pic_6]

@export
var user_name: Label
@export
var user_picture: TextureRect

var user_profile_pic_index := 0

@export
var points_label_1: Label
@export
var progress_bar_1: ProgressBar

@export
var points_label_2: Label
@export
var progress_bar_2: ProgressBar

@export
var posts_list: VBoxContainer

@export
var login_screen: PanelContainer
@export
var twitter_screen: Panel

# Game data
var positive_score := 0
var negative_score := 0


var new_post_wait_time_min = 4.0
var new_post_wait_time_max = 10.0

var last_positive_post_index = -1
var last_negative_post_index = -1

const SCORE_MODIFIER = 1

const FINISH_SCORE = 20

var positive_posts = [
	{
		name = "Randall",
		text = "Moje máma. S mojím tátou. Měli mě. A s mojím bráchou.",
		date = "6 minutes ago",
		alignment = "positive"
	},
	{
		name = "Dudette",
		text = "Moje máma. S mojím tátou. Měli mě. A s mojím bráchou.",
		date = "3 minutes ago",
		alignment = "positive"
	},
	{
		name = "Dude",
		text = "Moje máma. S mojím tátou. Měli mě. A s mojím bráchou.",
		date = "1 minutes ago",
		alignment = "positive"
	},
	{
		name = "Outdoor Boi",
		text = "Moje máma. S mojím tátou. Měli mě. A s mojím bráchou.",
		date = "3 minutes ago",
		alignment = "positive"
	}
]

var negative_posts = [
	{
		name = "Randall (Negative)",
		text = "Moje máma. S mojím tátou. Měli mě. A s mojím bráchou.",
		date = "6 minutes ago",
		alignment = "negative"
	},
	{
		name = "Dudette (Negative)",
		text = "Moje máma. S mojím tátou. Měli mě. A s mojím bráchou.",
		date = "3 minutes ago",
		alignment = "negative"
	},
	{
		name = "Dude (Negative)",
		text = "Moje máma. S mojím tátou. Měli mě. A s mojím bráchou.",
		date = "1 minutes ago",
		alignment = "negative"
	},
	{
		name = "Outdoor Boi (Negative)",
		text = "Moje máma. S mojím tátou. Měli mě. A s mojím bráchou.",
		date = "3 minutes ago",
		alignment = "negative"
	}
]

func _ready() -> void:
	update_score_texts()

func start_game() -> void:
	progress_bar_1.max_value = FINISH_SCORE
	progress_bar_1.max_value = FINISH_SCORE
	
	update_score_texts()
	get_new_post()

func get_new_post() -> void:
	var randomizer = RandomNumberGenerator.new()
	await get_tree().create_timer(randomizer.randf_range(new_post_wait_time_min, new_post_wait_time_max)).timeout
	
	var is_positive = RandomNumberGenerator.new().randi_range(0, 1) == 0
	var posts = positive_posts if is_positive else negative_posts
	
	if is_positive:
		last_positive_post_index += 1
		if last_positive_post_index >= positive_posts.size() - 1:
			last_positive_post_index = 0
	else:
		last_negative_post_index += 1
		if last_negative_post_index >= negative_posts.size() - 1:
			last_negative_post_index = 0
			
	var index = last_positive_post_index if is_positive else last_negative_post_index
	var post = post_prefab.instantiate()
	var post_data = posts[index]
	
	post.setup(post_data, user_profile_pic_index, promote, ban)
	posts_list.add_child(post)
	posts_list.move_child(post, 0)
	
	adjust_score(post_data["alignment"])
	
	get_new_post()
	
func adjust_score(alignment: String) -> void:
	if alignment == "positive":
		positive_score += SCORE_MODIFIER
	else:
		negative_score += SCORE_MODIFIER

	update_score_texts()

func ban(alignment: String) -> void:
	if alignment == "positive":
		negative_score += SCORE_MODIFIER
		positive_score -= SCORE_MODIFIER
	else:
		positive_score += SCORE_MODIFIER

	update_score_texts()

func promote(alignment: String) -> void:
	if alignment == "positive":
		negative_score -= SCORE_MODIFIER
	else:
		negative_score += SCORE_MODIFIER

	update_score_texts()

func update_score_texts() -> void:
	progress_bar_1.value = positive_score
	progress_bar_2.value = negative_score
	
	points_label_1.text = str(positive_score) + " posts"
	points_label_2.text = str(negative_score) + " posts"

func _on_login_screen_login(nick: String, pic_index: int) -> void:
	user_name.text = nick
	user_profile_pic_index = pic_index
	user_picture.texture = profile_pics[pic_index]
	
	login_screen.visible = false
	twitter_screen.visible = true
