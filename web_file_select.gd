extends Node
class_name WebFileSelect

signal selected
signal canceled

@export var file_ext: String = ""

var _selected_callback: JavaScriptObject
var _canceled_callback: JavaScriptObject
var _file_select_obj: JavaScriptObject

func _ready() -> void:
	if (OS.get_name() != "Web"): return
	_inject_js()

func _inject_js() -> void:
	_selected_callback = JavaScriptBridge.create_callback(_on_file_selected);
	_canceled_callback = JavaScriptBridge.create_callback(_on_canceled);
	JavaScriptBridge.eval("""
	function godotFileSelectInit() {
		var loadedCallback;
		var canceledCallback;
		var fileInput = document.createElement('INPUT'); 
		fileInput.setAttribute("type", "file");
		fileInput.setAttribute("accept", ".%s");
		var gdInterface = {
			setCallbacks: function(loaded, canceled) {
				loadedCallback = loaded;
				canceledCallback = canceled;
			},
			open: function(callback) {
				fileInput.click();
			}
		}
		fileInput.onchange = function(inputEvent) {
			if (inputEvent.target.files.length === 0) {
				canceledCallback();
				return;
			}
			var file = inputEvent.target.files[0];
			var reader = new FileReader();
			reader.readAsDataURL(file);
			reader.onloadend = (readerEvent) => {
				if (readerEvent.target.readyState !== FileReader.DONE) return;
				loadedCallback(readerEvent.target.result);
			}
		}
		return gdInterface;
	}
	var godotFileSelect = godotFileSelectInit();
	""" % [file_ext], true)
	_file_select_obj = JavaScriptBridge.get_interface("godotFileSelect")
	_file_select_obj.setCallbacks(_selected_callback, _canceled_callback)

func _on_file_selected(args) -> void:
	var base64: String = args[0].split(",", true, 1)[1]
	var data: PackedByteArray = Marshalls.base64_to_raw(base64)
	emit_signal("selected", data)

func _on_canceled(_args) -> void:
	emit_signal("canceled")

func open() -> void:
	if (OS.get_name() != "Web"): return
	_file_select_obj.open()
