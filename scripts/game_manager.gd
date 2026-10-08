extends Node
var score := 0
func _ready() -> void:
	add_child(VisualPolish.new())
func add_point() -> void:
	score += 1

class VisualPolish:
	extends Node2D
	var hud_score: Label
	var toast: Label
	var sparks: Array = []
	var scene: Node2D
	var displayed_score := 0
	var coin_total := 0
	var last_velocity_y := 0.0
	var font := preload("res://ASSETS/fonts/PixelOperator8-Bold.ttf")
	func _ready() -> void:
		await get_tree().process_frame
		_attach_scene()
	func _attach_scene() -> void:
		scene = get_tree().current_scene
		if not is_instance_valid(scene): return
		displayed_score = 0
		coin_total = 0
		for coin in scene.find_children("*", "Area2D", true, false):
			if coin.get_script() == load("res://scripts/coin.gd"):
				coin_total += 1
				coin.body_entered.connect(func(body):
					if body is CharacterBody2D:
						displayed_score += 1
						coin_feedback(coin.global_position, displayed_score)
				)
		var background := CanvasLayer.new()
		background.layer = -20
		add_child(background)
		var sky := PixelSky.new()
		sky.player = scene.get_node("player")
		background.add_child(sky)
		# The old flat background tiles are visual only. Keep layer data and collisions intact.
		scene.get_node("TileMap").set_layer_modulate(0, Color(1, 1, 1, 0))
		for name in ["Label", "Label2", "Label3", "Label4"]:
			var sign: Label = scene.get_node(name)
			sign.add_theme_font_size_override("font_size", 8)
			sign.add_theme_color_override("font_color", Color("f6e9bb"))
			sign.add_theme_color_override("font_shadow_color", Color("142b25"))
			sign.add_theme_constant_override("shadow_offset_x", 1)
			sign.add_theme_constant_override("shadow_offset_y", 1)
		scene.get_node("Label").text = "VANNAKAM!"
		scene.get_node("Label").position = Vector2(-94, -28)
		scene.get_node("Label3").text = "WATCH YOUR STEP"
		scene.get_node("Label4").hide()
		scene.get_node("Label2").text = "HOME AT LAST!\nDID YOU FIND ALL 7 SUN COINS?"
		var hud := CanvasLayer.new()
		hud.layer = 20
		add_child(hud)
		var bar := Panel.new()
		var style := StyleBoxFlat.new()
		style.bg_color = Color("132b26")
		style.border_color = Color("bba268")
		style.set_border_width_all(2)
		bar.add_theme_stylebox_override("panel", style)
		bar.position = Vector2(20, 18)
		bar.size = Vector2(300, 82)
		hud.add_child(bar)
		_make_label(bar, "FIRST GAME", Vector2(16, 10), 22, Color("f6e9bb"))
		_make_label(bar, "THE VALLEY OF SEVEN SUN COINS", Vector2(16, 43), 10, Color("b6c7a0"))
		var story := Panel.new()
		story.add_theme_stylebox_override("panel", style)
		story.position = Vector2(340, 18)
		story.size = Vector2(580, 82)
		hud.add_child(story)
		_make_label(story, "THE VALLEY'S LANTERN HAS GONE DARK.", Vector2(16, 10), 12, Color("f1d58a"))
		_make_label(story, "FIND 7 SUN COINS. BRING ITS LIGHT HOME.", Vector2(16, 42), 12, Color("f6e9bb"))
		var score_panel := Panel.new()
		score_panel.add_theme_stylebox_override("panel", style)
		score_panel.position = Vector2(get_viewport_rect().size.x - 220, 18)
		score_panel.size = Vector2(200, 82)
		hud.add_child(score_panel)
		_make_label(score_panel, "SUN COINS", Vector2(15, 10), 11, Color("b6c7a0"))
		hud_score = _make_label(score_panel, "00 / 07", Vector2(15, 35), 24, Color("f1d58a"))
		var total := coin_total
		hud_score.text = "00 / %02d" % total
		_make_label(hud, "ARROWS  MOVE    SPACE / UP  JUMP    R  RESTART", Vector2(22, get_viewport_rect().size.y - 31), 13, Color("f6e9bb"))
		toast = _make_label(hud, "", Vector2(get_viewport_rect().size.x * 0.5 - 120, 120), 16, Color("f1d58a"))
		get_viewport().size_changed.connect(func(): score_panel.position.x = get_viewport_rect().size.x - 220)
	func _make_label(parent: Node, text: String, pos: Vector2, size: int, color: Color) -> Label:
		var label := Label.new()
		label.text = text
		label.position = pos
		label.add_theme_font_override("font", font)
		label.add_theme_font_size_override("font_size", size)
		label.add_theme_color_override("font_color", color)
		label.add_theme_color_override("font_shadow_color", Color("142b25"))
		label.add_theme_constant_override("shadow_offset_y", 2)
		parent.add_child(label)
		return label
	func coin_feedback(at: Vector2, score: int) -> void:
		var total := coin_total
		hud_score.text = "%02d / %02d" % [score, total]
		toast.text = "+1 COIN" if score < total else "ALL COINS FOUND!"
		var tween := create_tween()
		toast.modulate.a = 1
		tween.tween_property(toast, "modulate:a", 0.0, 1.2).set_delay(0.45)
		burst(at, Color("ffd778"), 12)
	func burst(at: Vector2, color: Color, count: int) -> void:
		for i in range(count):
			var angle := TAU * i / count
			sparks.append({"p": at, "v": Vector2(cos(angle), sin(angle)) * randf_range(18, 40), "life": 0.45, "color": color})
	func _process(delta: float) -> void:
		if is_instance_valid(scene):
			var player = scene.get_node_or_null("player")
			if is_instance_valid(player):
				if player.velocity.y < -400 and last_velocity_y >= 0:
					burst(player.global_position + Vector2(0, 6), Color("b9cba3"), 6)
				last_velocity_y = player.velocity.y
		for i in range(sparks.size() - 1, -1, -1):
			sparks[i].p += sparks[i].v * delta
			sparks[i].v.y += 40 * delta
			sparks[i].life -= delta
			if sparks[i].life <= 0: sparks.remove_at(i)
		queue_redraw()
		if Input.is_physical_key_pressed(KEY_R):
			Engine.time_scale = 1
			get_tree().reload_current_scene()
	func _draw() -> void:
		for spark in sparks:
			var color: Color = spark.color
			color.a = spark.life / 0.45
			draw_rect(Rect2(spark.p, Vector2(1.5, 1.5)), color)
	
	class PixelSky:
		extends Control
		# Original procedural pixel scenery; no external art or shader dependencies.
		var player: Node2D
		var clock := 0.0
		func _process(delta: float) -> void:
			clock += delta
			queue_redraw()
		func _draw() -> void:
			var s := get_viewport_rect().size
			var drift := player.global_position.x if is_instance_valid(player) else 0.0
			draw_rect(Rect2(Vector2.ZERO, s), Color("192d2b"))
			for i in range(12):
				draw_rect(Rect2(0, i * s.y / 12, s.x, s.y / 12 + 1), Color("192d2b").lerp(Color("809061"), float(i) / 16))
			var sun := Vector2(s.x * 0.77 - fmod(drift * 0.15, 60.0), s.y * 0.25)
			draw_circle(sun, 45, Color("f1d58a"))
			for i in range(8):
				var x := fposmod(i * 211.0 - drift * 0.35, s.x + 240) - 120
				var y := 70.0 + (i % 3) * 44
				draw_rect(Rect2(x, y, 104, 12), Color("9aaa81"))
				draw_rect(Rect2(x + 20, y - 8, 48, 8), Color("9aaa81"))
			for layer in range(3):
				var step := 88.0 + layer * 31
				var base := s.y * (0.53 + layer * 0.15)
				var points := PackedVector2Array([Vector2(-step, s.y)])
				for i in range(-2, int(s.x / step) + 4):
					var x := i * step - fposmod(drift * (0.3 + layer * 0.4), step)
					var h := (sin(i * 1.71 + layer) * 0.5 + 0.5) * 90
					points.append(Vector2(x, base - h))
					points.append(Vector2(x + step * 0.5, base - h))
				points.append(Vector2(s.x + step, s.y))
				draw_colored_polygon(points, [Color("536d54"), Color("355849"), Color("233f36")][layer])
			for i in range(26):
				var p := Vector2(fposmod(i * 97.0 + sin(clock * 0.45 + i) * 22 - drift * 0.65, s.x), fposmod(i * 79.0 - clock * 7, s.y))
				draw_rect(Rect2(p, Vector2(3, 3)), Color(0.95, 0.85, 0.48, 0.25 + 0.25 * sin(clock + i)))
