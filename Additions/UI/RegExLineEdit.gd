@tool
extends LineEdit
class_name RegExLineEdit

var _regex: RegEx = RegEx.new()
var _old_text: String = ""

var _had_selection: bool
var _prev_caret_column: int
var _prev_selection_from_column: int
var _prev_selection_to_column: int

signal _next_frame(delta: float)

func _init(pattern: String = ""):
	set_regex_pattern(pattern)
	text_changed.connect(set_text_wregex)
func _process(delta):
	_next_frame.emit(delta)

	_prev_caret_column = caret_column
	_had_selection = has_selection()
	if _had_selection:
		_prev_selection_from_column = get_selection_from_column()
		_prev_selection_to_column = get_selection_to_column()

func set_text_wregex(value: String):
	# need this if statement since sometimes the text_changed signal gets called inexplicably with the already existing text
	if value != _old_text:
		if _regex.get_pattern().length() == 0 || _regex.search(value):
			text = value
			if _had_selection:
				var selection_size = _prev_selection_to_column - _prev_selection_from_column
				caret_column = _prev_selection_from_column + (text.length() - (_old_text.length() - selection_size))
			else:
				caret_column = _prev_caret_column + (text.length() - _old_text.length())
			_old_text = value
		else:
			text = _old_text
			if _had_selection:
				# need to wait for the next frame for selection to work
				await _next_frame
				select(_prev_selection_from_column, _prev_selection_to_column)
			else:
				caret_column = _prev_caret_column

func clear_regex():
	_regex.clear()
func set_regex_pattern(pattern: String):
	if pattern.length() > 0:
		_regex.compile(pattern)
	else:
		clear_regex()
