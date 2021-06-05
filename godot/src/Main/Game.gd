extends Node

enum { BIRD_VIEW, BIRD_VIEW_TO_THIRD_PERSON, THIRD_PERSON, CAMERA_SWITCH}

export var camera_switch_option = true

onready var _view = BIRD_VIEW

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	_view = BIRD_VIEW_TO_THIRD_PERSON
	# Start by a smooth bezier curve during 5s with cubic in/out easing curve after a 0.5s delay
	# Put the camera front of the player
	$CameraTween.interpolate_looking_at($Player/Mannequiny/root/CameraFront, 
										$Player/Mannequiny/root/CameraFocus,
										5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, 2)
	$CameraTween.start()
	
	$CameraTween.connect("camera_tween_completed", self, "_on_camera_tween_completed")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event.is_action_pressed("toggle_mouse_captured"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_tree().set_input_as_handled()

	if event.is_action_pressed("toggle_fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen
		get_tree().set_input_as_handled()
		
		
	# Demo CameraTween additions
	if (event.is_action_pressed("move_front") or
		event.is_action_pressed("move_back") or 
		event.is_action_pressed("move_left") or 
		event.is_action_pressed("move_right")) :
			if _view == BIRD_VIEW_TO_THIRD_PERSON :
				# User move the player before the end of the animation, 
				# switch to 3rd person view progresively during the time remaining.
				$CameraTween.follow_looking_at($Player/CameraRig/SpringArm/CameraTarget, 
											   $Player/Mannequiny/root/CameraFocusHead, 5)
				_view = THIRD_PERSON


func _on_camera_tween_completed() :
	if _view ==  BIRD_VIEW_TO_THIRD_PERSON:
		# move camera from front to back with a bezier curve during 2s after a delay of 1s
		$CameraTween.interpolate_looking_at($Player/CameraRig/SpringArm/CameraTarget,
											$Player/Mannequiny/root/CameraFocusHead,
											2, Tween.TRANS_EXPO, Tween.EASE_IN_OUT, 1)
		$CameraTween.start()
		_view = THIRD_PERSON
	elif _view == THIRD_PERSON:
		if camera_switch_option == false :
			# The $Player/CameraRig/InterpolatedCamera will be never active, just follow it camera system
			$CameraTween.follow($Player/CameraRig/SpringArm/CameraTarget, 0.2)
		else :
			# Adjust $CameraTween to $Player/CameraRig/SpringArm/CameraTarget with a short tween
			$CameraTween.interpolate($Player/CameraRig/SpringArm/CameraTarget, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0, true)
			$CameraTween.start()
			_view = CAMERA_SWITCH
	elif _view == CAMERA_SWITCH :
		$Player/CameraRig/InterpolatedCamera.set_current(true)
		$CameraTween.set_current(false)
	
