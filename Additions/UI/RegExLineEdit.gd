@tool
extends LineEdit
class_name RegExLineEdit

var _regex: RegEx = RegEx.new()
var _old_text: String = ""

var _had_selection: bool
var _prev_caret_column: int
var _prev_selection_from_column: int
var _prev_selection_to_column: int

func _init(pattern: String = ""):
	set_regex_pattern(pattern)
	text_changed.connect(func(new_text):
		if _regex.get_pattern().length() == 0 || _regex.search(new_text):
			_old_text = new_text
		else:
			text = _old_text
			caret_column = _prev_caret_column
			if _had_selection:
				select(_prev_selection_from_column, _prev_selection_to_column)
	)
func _process(delta):
	_prev_caret_column = caret_column
	_had_selection = has_selection()
	if has_selection():
		_prev_selection_from_column = get_selection_from_column()
		_prev_selection_to_column = get_selection_to_column()

func clear_regex():
	_regex.clear()
func set_regex_pattern(pattern: String):
	if pattern.length() > 0:
		_regex.compile(pattern)
	else:
		clear_regex()
