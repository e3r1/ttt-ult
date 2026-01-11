extends Node2D
var field_x = BitMap.new()
var field_o = BitMap.new()
var boards_winner_x = []
var boards_winner_o = []
var boards_color = []
var win_count_x = 0
var win_count_o = 0
var who_turn = 'x'
var focused_board = 0
var last_move = ""
var start_position = "9-9-9-9-9-9-9-9-9"

var color0 = Color(0.275, 0.0, 0.0, 1.0)
var color0_focused = Color(0.104, 0.0, 0.0, 1.0)
var color1 = Color(0.0, 0.185, 0.124, 1.0)
var color1_focused = Color(0.0, 0.074, 0.041, 1.0)
var color2 = Color(0.187, 0.2, 0.213, 1.0)
var color2_focused = Color(0.075, 0.082, 0.089, 1.0)

func _ready() -> void:
	$game_grid.columns = 3
	var style = StyleBoxFlat.new()
	style.bg_color = color2
	field_x.create(Vector2i(9,9))
	field_o.create(Vector2i(9,9))
	
	for n in range(9):
		var grid = GridContainer.new()
		grid.columns = 3
		for j in range(3):
			for i in range(3):
				var button = Button.new()
				var local_n = i + j*3
				button.text = " "
				button.position = Vector2(i,j)
				button.custom_minimum_size = Vector2(50,50)
				button.pressed.connect(click_button.bind(n, local_n))
				button.add_theme_stylebox_override("normal", style)
				button.add_theme_color_override("font_color", Color.WHITE)
				grid.add_child(button)
		$game_grid.add_child(grid)
		
		boards_winner_x.append(false)
		boards_winner_o.append(false)
		boards_color.append(color2)
		$option_board_number.add_item(str(n))
	
	draw_lines()
	draw_coordinates()

#func _process(delta: float) -> void:
#	pass

func check_win_condition_local(board_number: int) -> String:
	var fx = []
	var fo = []
	
	for i in range(9):
		fx.append(field_x.get_bit(i, board_number))
		fo.append(field_o.get_bit(i, board_number))
	
	if has_array_winning_configuration(fx):
		return "x"
	else: if has_array_winning_configuration(fo):
		return "o"
	
	if check_full_board(board_number):
		return "draw"
	
	return "playing"

func check_win_condition_global() -> String:
	if has_array_winning_configuration(boards_winner_x):
		return "x"
	else: if has_array_winning_configuration(boards_winner_o):
		return "o"
	return "playing"

func check_full_board(board_number: int) -> bool:
	for i in range(9):
		var bit_x = field_x.get_bit(i, board_number*9)
		var bit_o = field_o.get_bit(i, board_number*9)
		if !(bit_x || bit_o):
			return false
	return true

func change_turn() -> void:
	if who_turn == 'x':
		who_turn = 'o'
	else:
		who_turn = 'x'
	$btn_who_turn.text = who_turn

func clear_all() -> void:
	$label_next_board/label_value.text = "any"
	$label_result.text = "Game in process"
	field_x.create(Vector2i(9,9))
	field_o.create(Vector2i(9,9))
	last_move = ""
	
	var bg_color = color2
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	
	for grid in $game_grid.get_children():
		for button in grid.get_children():
			button.text = ""
			button.add_theme_stylebox_override("normal", style)
			
	for n in range(9):
		boards_winner_x[n] = false
		boards_winner_o[n] = false
		boards_color[n] = bg_color
	print_KEN()

func click_button(board_number, local_n) -> void:
	$option_board_number.select(board_number)
	
	var global_position = board_number * 9 + local_n
	var global_x = global_position%9
	var global_y = global_position/9
	var board_x = board_number%3
	var board_y = board_number/3
	var next_board_str = $label_next_board/label_value.text
	
	var is_button_empty = !(field_x.get_bit(global_x, global_y) || field_o.get_bit(global_x, global_y))
	var is_board_targeted = next_board_str == "any" || next_board_str == str(board_number + 1)
	var is_board_game_ended = boards_winner_x[board_number] || boards_winner_o[board_number]
	var is_game_over = check_win_condition_global() != "playing"
	if is_button_empty && is_board_targeted && !is_board_game_ended && !is_game_over:
		move(board_number, local_n)
		handle_board_result(board_number)
		set_next_board()
		print_KEN()

func draw_bg_color(board_number: int, bg_color: Color) -> void:
	var buttons = $game_grid.get_child(board_number).get_children()
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	for button in buttons:
		button.add_theme_stylebox_override("normal", style)

func draw_lines() -> void:
	var line = Line2D.new()
	var x = $game_grid.position.x
	var y = $game_grid.position.y
	
	for i in range(4):
		line = Line2D.new()
		line.add_point(Vector2(x+161*i, y))
		line.add_point(Vector2(x+161*i, y+482))
		line.width = 5
		line.default_color = Color.BLACK
		add_child(line)
	
	for i in range(4):
		line = Line2D.new()
		line.add_point(Vector2(x, y+161*i))
		line.add_point(Vector2(x+482, y+161*i))
		line.width = 5
		line.default_color = Color.BLACK
		add_child(line)

func draw_coordinates() -> void:
	var x = $game_grid.position.x
	var y = $game_grid.position.y
	
	for i in range(9):
		var label = Label.new()
		add_child(label)
		label.text = str(i+1)
		label.position = Vector2(x - 15, y + 446 - i*54)
		
	var string = "abcdefghi"
	for i in range(9):
		var label = Label.new()
		add_child(label)
		label.text = string[i]
		label.position = Vector2(x + 20 + i*54, y + 484)

func focus_on_board(board_number: int) -> void:
	remove_focus_on_board(focused_board)
	var board_color = boards_color[board_number]
	if board_color == color0:
		draw_bg_color(board_number, color0_focused)
	else: if board_color == color1:
		draw_bg_color(board_number, color1_focused)
	else: if board_color == color2:
		draw_bg_color(board_number, color2_focused)
	focused_board = board_number

func handle_board_result(board_number: int) -> void:
	var board_result = check_win_condition_local(board_number)
	if board_result == "x":
		select_color_on_board(board_number, color0)
		win_count_x += 1
		boards_winner_x[board_number] = true
	else: if board_result == "o":
		select_color_on_board(board_number, color1)
		win_count_o += 1
		boards_winner_o[board_number] = true
	var result = check_win_condition_global()
	if result == "x":
		$label_result.text = "X won"
	else: if result == "o":
		$label_result.text = "O won"

func has_array_winning_configuration(s: Array) -> bool:
	print(s)
	for i in range(9):
		if ((s[0]&&s[1]&&s[2]) || (s[3]&&s[4]&&s[5]) || (s[6]&&s[7]&&s[8]) ||
		(s[0]&&s[3]&&s[6]) || (s[1]&&s[4]&&s[7]) || (s[2]&&s[5]&&s[8])) ||(
		(s[0]&&s[4]&&s[8]) || (s[2]&&s[4]&&s[6])):
			return true
	return false

func import_KEN() -> void:
	clear_all()
	var current_KEN = $textEdit_import_KEN.text
	var board_n = 0
	var local_n = 0
	for s in current_KEN:
		if s == "x" || s == "o":
			who_turn = s
			move(transform_to_reverse_y_order(board_n), transform_to_reverse_y_order(local_n))
			local_n += 1
		else: if("123456789".find(s) != -1):
			local_n += int(s)
		else: if s == "-":
			local_n = 0
			board_n += 1
		else:
			var x = "abcdefghi".find(s)
			if x != -1:
				last_move = current_KEN.substr(current_KEN.find("abcdefghi"[x]), 2)
	
	for board_number in range(9):
		handle_board_result(board_number)
	set_next_board()
	print_KEN()

func move(board_number: int, local_n: int) -> void:
	var button = $game_grid.get_child(board_number).get_child(local_n)
	var local_x = local_n % 3
	var local_y = local_n / 3
	var global_position = board_number * 9 + local_n
	var global_x = global_position%9
	var global_y = global_position/9
	var coordinate_x = board_number%3*3 + local_x
	var coordinate_y = board_number/3*3 + local_y
	
	if who_turn == 'x':
		field_x.set_bit(global_x, global_y, true)
		button.add_theme_color_override("font_color", Color.RED)
	else:
		field_o.set_bit(global_x, global_y, true)
		button.add_theme_color_override("font_color", Color.GREEN)
	button.text = who_turn
	last_move = "abcdefghi"[coordinate_x] + str(9-coordinate_y)
	change_turn()

func print_KEN() -> String:
	var count_empty_spaces = 0
	var line = ""
	
	for board_number in range(9):
		var transformed_board_number = transform_to_reverse_y_order(board_number)
		for local_n in range(9):
			var transformed_local_n = transform_to_reverse_y_order(local_n)
			var _x = field_x.get_bit(transformed_local_n, transformed_board_number)
			var _o = field_o.get_bit(transformed_local_n, transformed_board_number)
			if _x:
				line += "x"
				count_empty_spaces = 0
			else: if _o:
				line += "o"
				count_empty_spaces = 0
			else:
				count_empty_spaces += 1
				if !count_empty_spaces == 1:
					line = line.rstrip("0123456789")
				line += str(count_empty_spaces)
		if board_number < 8:
			line += "-"
		count_empty_spaces = 0
	line += " " + str(last_move)
	$label_KEN/value.text = line
	return line

func remove_focus_on_board(board_number: int) -> void:
	var board_color = boards_color[board_number]
	draw_bg_color(board_number, board_color)

func select_color_on_board(board_number: int, board_color: Color) -> void:
	boards_color[board_number] = board_color
	draw_bg_color(board_number, board_color)

func set_next_board() -> void:
	if (last_move != ""):
		var next_board_x = "abcdefghi".find(last_move[0]) % 3
		var next_board_y = 2 - (int(last_move[1]) - 1) % 3
		var next_board_number = next_board_x + next_board_y*3
		
		var is_board_game_over = boards_winner_x[next_board_number] || boards_winner_o[next_board_number]
		if check_full_board(next_board_number) || is_board_game_over:
			$label_next_board/label_value.text = "any"
			remove_focus_on_board(focused_board)
		else:
			$label_next_board/label_value.text = str(next_board_number+1)
			focus_on_board(next_board_number)
	
	pass

func transform_to_reverse_y_order(n: int) -> int:
	return n % 3 + (2 - n / 3) * 3
