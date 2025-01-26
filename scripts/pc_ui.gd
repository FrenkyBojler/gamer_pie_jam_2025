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
var progress_bar_animation_player_1: AnimationPlayer

@export
var points_label_2: Label
@export
var progress_bar_2: ProgressBar

@export
var progress_bar_animation_player_2: AnimationPlayer

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

const SCORE_MODIFIER = 2

var FINISH_SCORE = GameState.posts_score_critical_value

var tutorial_skipped := false

var posts_handled_count := 0

func _ready() -> void:
	progress_bar_1.max_value = FINISH_SCORE
	progress_bar_2.max_value = FINISH_SCORE
	update_score_texts()

func _start_tutorial_1() -> void:
	var post = post_prefab.instantiate()
	var post_data = postsTutorial[0]
	
	var tutorial_1_promote = func(alignment: String):
		promote.call(alignment)
		await get_tree().create_timer(2).timeout
		_start_tutorial_2()
	
	posts_list.add_child(post)
	GameState.notification_recieved_event()
	post.setup(post_data, user_profile_pic_index, tutorial_1_promote, ban,adjust_score, true)
	posts_list.move_child(post, 0)

	
func _start_tutorial_2() -> void:
	var post = post_prefab.instantiate()
	var post_data = postsTutorial[1]
	
	var tutorial_2_ban = func(alignment: String):
		ban.call(alignment)
		await get_tree().create_timer(2).timeout
		_start_tutorial_3()
	
	posts_list.add_child(post)
	GameState.notification_recieved_event()
	post.setup(post_data, user_profile_pic_index, promote, tutorial_2_ban,adjust_score, true)
	posts_list.move_child(post, 0)

func _start_tutorial_3() -> void:
	var post = post_prefab.instantiate()
	var post_data = postsTutorial[2]
	
	var tutorial_3_ban = func(alignment: String):
		ban.call(alignment)
		await get_tree().create_timer(2).timeout
		_start_tutorial_4()

	var tutorial_3_promote = func(alignment: String):
		promote.call(alignment)
		await get_tree().create_timer(2).timeout
		_start_tutorial_4()
	
	posts_list.add_child(post)
	post.setup(post_data, user_profile_pic_index, tutorial_3_promote, tutorial_3_ban,adjust_score, true)
	posts_list.move_child(post, 0)
	
func _start_tutorial_4() -> void:
	var post = post_prefab.instantiate()
	var post_data = postsTutorial[3]
	
	var tutorial_4_ban = func(alignment: String):
		ban.call(alignment)
		await get_tree().create_timer(2).timeout
		start_game()
		#GameState.start_game()

	var tutorial_4_promote = func(alignment: String):
		promote.call(alignment)
		start_game()
		#GameState.start_game()
	
	posts_list.add_child(post)
	GameState.notification_recieved_event()
	post.setup(post_data, user_profile_pic_index, tutorial_4_promote, tutorial_4_ban,adjust_score, true)
	posts_list.move_child(post, 0)

func start_game() -> void:
	update_score_texts()
	get_new_post()

func get_new_post() -> void:

	var randomizer = RandomNumberGenerator.new()
	await get_tree().create_timer(randomizer.randf_range(new_post_wait_time_min, new_post_wait_time_max)).timeout
	
	var is_positive = RandomNumberGenerator.new().randi_range(0, 1) == 0
	var posts = postsDogs if is_positive else postsCats
	
	if is_positive:
		last_positive_post_index += 1
		if last_positive_post_index >= postsDogs.size() - 1:
			last_positive_post_index = 0
	else:
		last_negative_post_index += 1
		if last_negative_post_index >= postsCats.size() - 1:
			last_negative_post_index = 0
			
	var index = last_positive_post_index if is_positive else last_negative_post_index
	var post = post_prefab.instantiate()
	var post_data = posts[index]
	
	posts_list.add_child(post)
	GameState.notification_recieved_event()
	post.setup(post_data, user_profile_pic_index, promote, ban, adjust_score, false)
	posts_list.move_child(post, 0)
	
	get_new_post()
	


func adjust_score(alignment: String) -> void:
	if alignment == "positive":
		positive_score += SCORE_MODIFIER
		progress_bar_animation_player_1.play("score_up")
	else:
		negative_score += SCORE_MODIFIER
		progress_bar_animation_player_2.play("score_up")

	update_score_texts()
	
	

func ban(alignment: String) -> void:
	if alignment == "positive":
		negative_score += SCORE_MODIFIER
		positive_score -= SCORE_MODIFIER
		progress_bar_animation_player_2.play("score_up")
		$FailSound.play()
	else:
		positive_score += SCORE_MODIFIER
		progress_bar_animation_player_1.play("score_up")
		$SuccessSound.play()

	update_score_texts()

func promote(alignment: String) -> void:
	if alignment == "positive":
		positive_score += SCORE_MODIFIER
		progress_bar_animation_player_1.play("score_up")
		$SuccessSound.play()
	else:
		negative_score += SCORE_MODIFIER
		positive_score -= SCORE_MODIFIER
		progress_bar_animation_player_2.play("score_up")
		$FailSound.play()
	update_score_texts()

func update_score_texts() -> void:
	if positive_score < 0:
		positive_score = 0
	if negative_score < 0:
		negative_score = 0
	
	progress_bar_1.value = positive_score
	progress_bar_2.value = negative_score
	
	points_label_1.text = str(positive_score) + " points"
	points_label_2.text = str(negative_score) + " points"
	
	posts_handled_count += SCORE_MODIFIER
	
	if not tutorial_skipped and posts_handled_count == 14:
		GameState.power_off_event_trigger()
		GameState.start_game(tutorial_skipped)
	
	var score_coef = positive_score - negative_score
	GameState.posts_score_update.emit(score_coef)
	
	if positive_score >= FINISH_SCORE:
		GameState.win_game()
	elif negative_score >= FINISH_SCORE:
		GameState.loose_game("points")

func _on_login_screen_login(nick: String, pic_index: int, skip_tutorial: bool) -> void:
	user_name.text = nick
	user_profile_pic_index = pic_index
	user_picture.texture = profile_pics[pic_index]
	
	login_screen.visible = false
	twitter_screen.visible = true
	
	if skip_tutorial:
		tutorial_skipped = true
		start_game()
		GameState.start_game(tutorial_skipped)
		return

	await get_tree().create_timer(2).timeout
	_start_tutorial_1()

var postsDogs = [
	{
		profile_pic_index = 0,
		name = "DogLover567",
		text = "Dogs are the best companions. Nothing beats their loyalty 🐕",
		date = "7 minutes ago",
		alignment = "positive"
	},
	{
		profile_pic_index = 0,
		name = "CatFan123",
		text = "Dogs are so loud and messy. Definitely not for me.",
		date = "16 minutes ago",
		alignment = "negative"
	},
	{
		profile_pic_index = 0,
		name = "BarkBuddy321",
		text = "Had a long day, but my dog greeted me like a hero. They're amazing!",
		date = "5 minutes ago",
		alignment = "positive"
	},
	{
		profile_pic_index = 0,
		name = "QuietLife905",
		text = "Dogs are too noisy. I can't stand their constant barking.",
		date = "14 minutes ago",
		alignment = "negative"
	},
	{
		profile_pic_index = 0,
		name = "HappyDogMom",
		text = "My dog is my everything. Their love is so pure 💕",
		date = "3 minutes ago",
		alignment = "positive"
	},
	{
		profile_pic_index = 0,
		name = "DogHater421",
		text = "Dogs are so much work. Cleaning up after them is a nightmare.",
		date = "20 minutes ago",
		alignment = "negative"
	},
	{
		profile_pic_index = 0,
		name = "FurryFriendFan",
		text = "Walked my dog in the park today, and it was the highlight of my week!",
		date = "8 minutes ago",
		alignment = "positive"
	},
	{
		profile_pic_index = 0,
		name = "NoDogsPlease",
		text = "Dogs smell so bad. I don't understand why people love them.",
		date = "22 minutes ago",
		alignment = "negative"
	},
	{
		profile_pic_index = 0,
		name = "GoldenRetrieverLover",
		text = "My golden retriever is the sweetest. She always knows how to cheer me up!",
		date = "10 minutes ago",
		alignment = "positive"
	},
	{
		profile_pic_index = 0,
		name = "DogAllergy101",
		text = "Being around dogs is torture. My allergies go crazy every time.",
		date = "18 minutes ago",
		alignment = "negative"
	},
	{
		profile_pic_index = 0,
		name = "WoofLife88",
		text = "Dogs just make life better. They're always there when you need them 🐾",
		date = "6 minutes ago",
		alignment = "positive"
	},
	{
		profile_pic_index = 0,
		name = "DogCritic456",
		text = "Why would anyone get a dog? They're so much trouble to take care of.",
		date = "25 minutes ago",
		alignment = "negative"
	},
	{
		profile_pic_index = 0,
		name = "TailWaggerFan",
		text = "The way dogs wag their tails when they're happy is just so heartwarming!",
		date = "9 minutes ago",
		alignment = "positive"
	},
	{
		profile_pic_index = 0,
		name = "AntiDogClub",
		text = "I don't trust dogs. They bite and make me nervous.",
		date = "17 minutes ago",
		alignment = "negative"
	},
	{
		profile_pic_index = 0,
		name = "RescueDogMom",
		text = "Adopted a rescue dog, and I couldn't be happier. They're so loving!",
		date = "4 minutes ago",
		alignment = "positive"
	},
	{
		profile_pic_index = 0,
		name = "NoPetsAllowed",
		text = "Dogs ruin houses. I don't want animals shedding everywhere.",
		date = "19 minutes ago",
		alignment = "negative"
	},
	{
		profile_pic_index = 0,
		name = "LoveMyPup",
		text = "My dog is my workout buddy. We go on runs every day together!",
		date = "11 minutes ago",
		alignment = "positive"
	},
	{
		profile_pic_index = 0,
		name = "MessyDogs23",
		text = "Dogs destroy everything. My friend's dog ruined my couch.",
		date = "21 minutes ago",
		alignment = "negative"
	},
	{
		profile_pic_index = 0,
		name = "PuppyParadise",
		text = "Got a new puppy, and I can't stop smiling. They're so playful!",
		date = "2 minutes ago",
		alignment = "positive"
	},
	{
		profile_pic_index = 0,
		name = "TooMuchBarking",
		text = "Dogs barking all night is the worst. I can't sleep with them around.",
		date = "15 minutes ago",
		alignment = "negative"
	},
	{
		profile_pic_index = 0,
		name = "BestFriendDog",
		text = "Dogs truly are a person's best friend. Mine always makes my day better.",
		date = "7 minutes ago",
		alignment = "positive"
	},
	{
		profile_pic_index = 0,
		name = "NotADogPerson",
		text = "I can't stand dogs jumping on me. They're so rude.",
		date = "20 minutes ago",
		alignment = "negative"
	},
	{
		profile_pic_index = 0,
		name = "FluffyPaws",
		text = "Dogs are pure joy in fur. Couldn't imagine life without my fluffy friend!",
		date = "5 minutes ago",
		alignment = "positive"
	},
	{
		profile_pic_index = 0,
		name = "CleanHouseOnly",
		text = "Dogs are so dirty. Always tracking mud everywhere. Gross!",
		date = "12 minutes ago",
		alignment = "negative"
	},
	{
		profile_pic_index = 0,
		name = "CuddlePupFan",
		text = "Cuddling with my dog after a long day is the best feeling ever.",
		date = "4 minutes ago",
		alignment = "positive"
	},
	{
		profile_pic_index = 0,
		name = "LoudDogs101",
		text = "The constant barking from dogs drives me insane. So irritating!",
		date = "14 minutes ago",
		alignment = "negative"
	},
	{
		profile_pic_index = 0,
		name = "GoodBoyFan",
		text = "Every dog is a good boy. They're all so amazing in their own way!",
		date = "6 minutes ago",
		alignment = "positive"
	},
	{
		profile_pic_index = 0,
		name = "HateDogNoise",
		text = "Dogs barking at everything is so pointless. Can't they be quiet?",
		date = "22 minutes ago",
		alignment = "negative"
	},
	{
		profile_pic_index = 0,
		name = "DogJoyfulHeart",
		text = "Dogs bring so much happiness and positivity. I'm grateful for mine 🐶",
		date = "9 minutes ago",
		alignment = "positive"
	}
]

var postsCats = [
	{
		profile_pic_index = 0,
		name = "User4512",
		text = "Cats are the best! Love how fluffy and adorable they are 😻",
		date = "12 minutes ago",
		alignment = "negative"
	},
	{
		profile_pic_index = 0,
		name = "Milo237",
		text = "Cats are so annoying. Always scratching and ruining things!",
		date = "18 minutes ago",
		alignment = "positive"
	},
	{
		profile_pic_index = 0,
		name = "KittyFan923",
		text = "Spent the whole day with my cat, and it was perfect. They're so calming 🐾",
		date = "4 minutes ago",
		alignment = "negative"
	},
	{
		profile_pic_index = 0,
		name = "HaterX341",
		text = "Why do people like cats? They don't even do anything except laze around.",
		date = "27 minutes ago",
		alignment = "positive"
	},
	{
		profile_pic_index = 0,
		name = "CoolCat411",
		text = "Honestly, life is better with cats. Can't imagine not having a feline friend!",
		date = "9 minutes ago",
		alignment = "negative"
	},
	{
		profile_pic_index = 0,
		name = "CatCritic756",
		text = "Cats are overrated. They don't even care about their owners.",
		date = "23 minutes ago",
		alignment = "positive"
	},
	{
		profile_pic_index = 0,
		name = "PawsLover123",
		text = "Cats are hilarious! My kitty knocked over a glass, and I couldn't stop laughing 😹",
		date = "3 minutes ago",
		alignment = "negative"
	},
	{
		profile_pic_index = 0,
		name = "LameCats403",
		text = "Just saw a cat video, and I still don't get the hype. They're not that cute.",
		date = "21 minutes ago",
		alignment = "positive"
	},
	{
		profile_pic_index = 0,
		name = "FelineFan887",
		text = "If you don't love cats, you're missing out. They're pure joy!",
		date = "5 minutes ago",
		alignment = "negative"
	},
	{
		profile_pic_index = 0,
		name = "AntiCatLover234",
		text = "Cats are too sneaky. Can't trust them at all!",
		date = "17 minutes ago",
		alignment = "positive"
	},
	{
		profile_pic_index = 0,
		name = "FluffyDreams719",
		text = "Adopted a stray today. Cats are angels in fur 😇",
		date = "11 minutes ago",
		alignment = "negative"
	},
	{
		profile_pic_index = 0,
		name = "CatsSuck887",
		text = "Another day, another hairball from the neighbor's cat. So gross!",
		date = "20 minutes ago",
		alignment = "positive"
	},
	{
		profile_pic_index = 0,
		name = "MeowLover532",
		text = "Cats make everything better. Love watching them nap in the sun 🌞",
		date = "7 minutes ago",
		alignment = "negative"
	},
	{
		profile_pic_index = 0,
		name = "TooCoolForCats101",
		text = "Cats just feel like a waste of time. Dogs are way better.",
		date = "15 minutes ago",
		alignment = "positive"
	},
	{
		profile_pic_index = 0,
		name = "CatEnthusiast246",
		text = "Playing with my cat is the highlight of my day. They're so clever!",
		date = "10 minutes ago",
		alignment = "negative"
	},
	{
		profile_pic_index = 0,
		name = "DogFanatic913",
		text = "Don't understand why people are obsessed with cats. They're so unfriendly.",
		date = "19 minutes ago",
		alignment = "positive"
	},
	{
		profile_pic_index = 0,
		name = "PurringPal828",
		text = "Who else thinks cats are smarter than we give them credit for?",
		date = "6 minutes ago",
		alignment = "negative"
	},
	{
		profile_pic_index = 0,
		name = "FedUpWithCats768",
		text = "Cats are not as special as people make them out to be.",
		date = "14 minutes ago",
		alignment = "positive"
	},
	{
		profile_pic_index = 0,
		name = "HappyCatMom246",
		text = "My life changed for the better since I got a cat. Highly recommend!",
		date = "8 minutes ago",
		alignment = "negative"
	},
	{
		profile_pic_index = 0,
		name = "CatLitterHater512",
		text = "Stepped in cat litter again. I can't stand these animals.",
		date = "16 minutes ago",
		alignment = "positive"
	},
	{
		profile_pic_index = 0,
		name = "LuvCats4Life322",
		text = "Just adopted a kitten, and I'm in love already. They're so playful!",
		date = "2 minutes ago",
		alignment = "negative"
	},
	{
		profile_pic_index = 0,
		name = "NoCatsPls781",
		text = "Why do cats even exist? They do nothing but destroy furniture.",
		date = "13 minutes ago",
		alignment = "positive"
	},
	{
		profile_pic_index = 0,
		name = "FurBallFan213",
		text = "My cat's purring is the best sound in the world. Instant stress relief!",
		date = "9 minutes ago",
		alignment = "negative"
	},
	{
		profile_pic_index = 0,
		name = "AntiFluffy101",
		text = "Cats are so moody and selfish. Dogs are so much better companions.",
		date = "22 minutes ago",
		alignment = "positive"
	},
	{
		profile_pic_index = 0,
		name = "Purrfection897",
		text = "Cats bring so much joy to my life. They're little bundles of happiness!",
		date = "5 minutes ago",
		alignment = "negative"
	},
	{
		profile_pic_index = 0,
		name = "NotACatFan331",
		text = "Tired of people posting cat pics all the time. Enough is enough.",
		date = "25 minutes ago",
		alignment = "positive"
	},
	{
		profile_pic_index = 0,
		name = "WhiskerLover456",
		text = "Whiskers are the cutest thing ever. My cat's got the most perfect ones!",
		date = "12 minutes ago",
		alignment = "negative"
	},
	{
		profile_pic_index = 0,
		name = "DogsRule899",
		text = "Cats are just plain weird. I don't get their appeal at all.",
		date = "28 minutes ago",
		alignment = "positive"
	},
	{
		profile_pic_index = 0,
		name = "CatCuddleFan322",
		text = "Snuggling with my cat is the best therapy. They're so warm and soft!",
		date = "8 minutes ago",
		alignment = "negative"
	},
	{
		profile_pic_index = 0,
		name = "HatesCats872",
		text = "Cats are so useless. They just eat and sleep all day. Not a fan.",
		date = "18 minutes ago",
		alignment = "positive"
	}
]

var postsTutorial = [
	{
		profile_pic_index = 0,
		tutorial = 0,
		name = "Boss",
		text = "Welcome online!\nYour task for today is to promote some cute dog posts!\nWe love dogs 🐕. This post is clearly positive for dogs, so give it some praise.",
		date = "7 minutes ago",
		alignment = "positive"
	},
	{
		profile_pic_index = 0,
		tutorial = 1,
		name = "Boss",
		text = "Cats make everything better.\nLove watching them nap in the sun 🌞\nA cat would probably like this post, but not us, give this one a well deserved ban.",
		date = "7 minutes ago",
		alignment = "negative"
	},
	{
		profile_pic_index = 0,
		tutorial = 2,
		name = "Boss",
		text = "You have only limited time to moderate each post.\nAfter few seconds score will be adjusted according to the alignment of the post, so try to be quick.\nI'm sure you get how this works, tackle this post on your own.\nbtw, cats are best!",
		date = "6 minutes ago",
		alignment = "negative"
	},
	{
		profile_pic_index = 0,
		tutorial = 3,
		name = "Boss",
		text = "If you manage to fill the green progress bar you win!\nBut if the red progress bar fills up, well, you can try again tomorrow.\nAlso, be CAREFUL, score is processed even when YOU ARE NOT at your computer.\nLet's go dogs!",
		date = "6 minutes ago",
		alignment = "positive"
	},
]
