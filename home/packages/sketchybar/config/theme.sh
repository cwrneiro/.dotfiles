## This is an example file for custom theme addition

# color format : 0x<hex value for transparency between 0-255><hex rgb color value>

if [[ "$COLOR_SCHEME" == "teminhaziho" ]]; then
	# Default Theme colors
	export BASE=0xff1e1e2e		#1e1e2e
	export SURFACE=0xff6c7086	#6c7086
	export OVERLAY=0xff252525	#252525
	export MUTED=0xff6e6a86		#6e6a86
	export SUBTLE=0xffe2e2e2	#e2e2e2

	export TEXT=0xffe2e2e2		#e2e2e2
	export CRITICAL=0xffffffff	#ffffff
	export NOTICE=0xffe2e2e2	#e2e2e2
	export WARN=0xffeba0ac		#eba0ac
	export SELECT=0xffe2e2e2	#e2e2e2
	export GLOW=0xff89dceb		#89dceb
	export ACTIVE=0xffcba6f7	#cba6f7

	export HIGH_LOW=0xff1e1e2e	#1e1e2e
	export HIGH_MED=0xff606060	#606060
	export HIGH_HIGH=0xff707070	#707070

	export BLACK=0xff11111b		#11111b
	export TRANSPARENT=0x00000000	#000000

	# General bar colors
	export BAR_COLOR=0x00000000	#000000
	export BORDER_COLOR=0x00000000	#000000
	export ICON_COLOR=$TEXT  # Color of all icons
	export LABEL_COLOR=$TEXT # Color of all labels

	export POPUP_BACKGROUND_COLOR=0xbe393552 #393552
	export POPUP_BORDER_COLOR=$HIGH_MED

	export SHADOW_COLOR=$TEXT
fi
