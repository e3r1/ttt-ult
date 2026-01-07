extends Node2D
var field_x = BitMap.new()
var field_o = BitMap.new()
var boards_color = []
var boards_winner = []
var win_count_x = 0
var win_count_o = 0
var who_turn = 'x'
var focused_board = 0


var color0 = Color(0.275, 0.0, 0.0, 1.0)
var color0_focused = Color(0.104, 0.0, 0.0, 1.0)
var color1 = Color(0.0, 0.185, 0.124, 1.0)
var color1_focused = Color(0.0, 0.074, 0.041, 1.0)
var color2 = Color(0.187, 0.2, 0.213, 1.0)
var color2_focused = Color(0.075, 0.082, 0.089, 1.0)

func _ready() -> void:
	boards_winner.resize(9)
	
	#создаем поле досок
	for j in range(3):
		boards_color.append([])
		for i in range(3):
			boards_color[j].append(color2)
			$option_board_number.add_item(str(3*j+i+1))
	#конец создания поля досок
	
	#создаем поле кнопок
	$game_grid.columns = 9
	var style = StyleBoxFlat.new()
	style.bg_color = color2
	
	for j in range(9):
		for i in range(9):
			var button = Button.new()
			button.text = " "
			button.position = Vector2(i,j)
			button.custom_minimum_size = Vector2(50,50)
			button.pressed.connect(move.bind(button, i, j))
			button.add_theme_stylebox_override("normal", style)
			button.add_theme_color_override("font_color", Color.WHITE)
			$game_grid.add_child(button)
	#конец создания поля кнопок
	
	draw_lines()
	draw_coordinates()
	
	#создаем поле значений
	field_x.create(Vector2i(9,9))
	field_o.create(Vector2i(9,9))
	#конец создания поля значений

#func _process(delta: float) -> void:
#	pass

func change_bg_color(board_number: int, bg_color: Color) -> void:
	var buttons = $game_grid.get_children()
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	for btn_j in 3:
			for btn_i in 3:
				buttons[btn_j*9 + board_number*3 + (board_number/3)*18 + btn_i
				].add_theme_stylebox_override("normal", style)

func change_turn() -> void:
	if who_turn == 'x':
		who_turn = 'o'
	else:
		who_turn = 'x'
	$btn_who_turn.text = who_turn

func check_win_condition(board_number: int) -> String:
	var fx = []
	var fo = []
	var board_x = board_number%3
	var board_y = board_number/3
	
	for y in 3:
			for x in 3:
				fx.append(field_x.get_bit(board_x*3 + x,board_y*3 + y))
				fo.append(field_o.get_bit(board_x*3 + x,board_y*3 + y))
	
	var s = fx
	for i in range(9):
		if ((s[0]&&s[1]&&s[2]) || (s[3]&&s[4]&&s[5]) || (s[6]&&s[7]&&s[8]) ||
		(s[0]&&s[3]&&s[6]) || (s[1]&&s[4]&&s[7]) || (s[2]&&s[5]&&s[8])) ||(
		(s[0]&&s[4]&&s[8]) || (s[2]&&s[4]&&s[6])):
			return "x"
	s = fo
	for i in range(9):
		if ((s[0]&&s[1]&&s[2]) || (s[3]&&s[4]&&s[5]) || (s[6]&&s[7]&&s[8]) ||
		(s[0]&&s[3]&&s[6]) || (s[1]&&s[4]&&s[7]) || (s[2]&&s[5]&&s[8])) ||(
		(s[0]&&s[4]&&s[8]) || (s[2]&&s[4]&&s[6])):
			return "o"
	
	var is_board_full = check_full_board(board_x, board_y)
	if is_board_full:
		return "draw"
	
	return "playing"

func check_full_board(board_x: int, board_y) -> bool:
	var fx = []
	var fo = []
	for y in 3:
			for x in 3:
				fx.append(field_x.get_bit(board_x + x,board_y + y))
				fo.append(field_o.get_bit(board_x + x,board_y + y))
	for i in range(9):
		if !(fx[i]||fo[i]): 
			return false
	return true

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

func focus_on_board(i: int) -> void:
	remove_focus_on_board(focused_board)
	var board_color = boards_color[i/3][i%3]
	if board_color == color0:
		change_bg_color(i, color0_focused)
	else: if board_color == color1:
		change_bg_color(i, color1_focused)
	else: if board_color == color2:
		change_bg_color(i, color2_focused)
	focused_board = i

func move(button, x, y) -> void:
	var board_number = y/3*3 + x/3
	$option_board_number.select(board_number)
	
	var is_button_empty = !(field_x.get_bit(x,y) || field_o.get_bit(x,y))
	var is_board_targeted = $label_next_board/label_value.text == "any" || $label_next_board/label_value.text == str(board_number + 1)
	var is_board_game_ended = boards_winner[board_number]
	var is_game_over = (win_count_x >= 3) || (win_count_o >= 3)
	if is_button_empty && is_board_targeted && !is_board_game_ended && !is_game_over: 
		#do the move
		if who_turn == 'x':
			field_x.set_bit(x, y, true)
			button.add_theme_color_override("font_color", Color.RED)
		else:
			field_o.set_bit(x, y, true)
			button.add_theme_color_override("font_color", Color.GREEN)
		button.text = who_turn
		
		#handle result
		var board_result = check_win_condition(board_number)
		if board_result == "x":
			select_color_on_focused_board(0)
			boards_winner[board_number] = "x"
			win_count_x += 1
		else: if board_result == "o":
			select_color_on_focused_board(1)
			boards_winner[board_number] = "o"
			win_count_o += 1
		update_win_count()
		
		#prepare to next move
		change_turn()
		var next_board = x%3 + y%3*3
		var next_board_x = next_board%3*3
		var next_board_y = next_board/3*3
		$label_next_board/label_value.text = str(next_board+1)
		focus_on_board(next_board)
		if check_full_board(next_board_x, next_board_y) || boards_winner[next_board]:
			$label_next_board/label_value.text = "any"
			remove_focus_on_board(focused_board)

func _on_btn_clear_pressed() -> void:
	$label_next_board/label_value.text = "any"
	$label_result.text = "Game in process"
	boards_winner.clear()
	boards_winner.resize(9)
	win_count_x = 0
	win_count_o = 0
	field_x.create(Vector2i(9,9))
	field_o.create(Vector2i(9,9))
	
	var bg_color = color2
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	
	for button in $game_grid.get_children():
		button.text = ""
		button.add_theme_stylebox_override("normal", style)
	for j in range(3):
		for i in range(3):
			boards_color[i][j] = bg_color
	select_color_on_focused_board(2)
	update_win_count()

func remove_focus_on_board(i: int) -> void:
	var board_color = boards_color[i/3][i%3]
	if board_color == color0:
		change_bg_color(i, color0)
	else: if board_color == color1:
		change_bg_color(i, color1)
	else: if board_color == color2:
		change_bg_color(i, color2)
	pass

func select_color_on_focused_board(board_color: int) -> void:
	var board_number = $option_board_number.selected
	var bg_color = Color.ORANGE
	
	if board_color==0:
		bg_color = color0
	else: if board_color==1:
		bg_color = color1
	else: if board_color==2:
		bg_color = color2
	
	boards_color[board_number/3][board_number%3] = bg_color
	change_bg_color(board_number, bg_color)

func update_KEN() -> String:
	
	return ""

func update_win_count() -> void:
	$label_x_win_count.text = "X won " + str(win_count_x) + " times"
	$label_o_win_count.text = "O won " + str(win_count_o) + " times"
	
	if win_count_x >= 3:
		$label_result.text = "X wins"
	else: if win_count_o >= 3:
		$label_result.text = "O wins"
