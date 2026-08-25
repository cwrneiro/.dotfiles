#!/bin/bash

# Rift workspace item script — the rift analogue of plugins/spaces/aerospace/
# script-space.sh. Rift exposes state over its mach IPC via `rift-cli query`,
# which returns JSON (see rift-protocol WorkspaceData: {name, index, is_active,
# window_count, windows:[{app_name,...}]}). One `query workspaces` call gives us
# both focus state and the app list, so we cache it and reuse it here.

# Workspace NAME from argument (set by spaces.sh) or extracted from item NAME.
WORKSPACE_NAME=${1:-${NAME#space.}}
WORKSPACE_NAME=${WORKSPACE_NAME//__/ } # undo the space->__ escaping done for item keys

export RELPATH=$(dirname $0)/../../..
source $RELPATH/set_colors.sh
shopt -s expand_aliases
command -v 'ft-haptic' 2>/dev/null 1>&2 || alias ft-haptic="$RELPATH/ft-haptic"

# Single snapshot of all workspaces, reused for focus + window checks.
WORKSPACES_JSON=$(rift-cli query workspaces 2>/dev/null)

# Focused workspace: prefer the name handed to us by the rift trigger, else
# derive it from the snapshot (is_active).
FOCUSED_WORKSPACE=${RIFT_WORKSPACE_NAME:-$(echo "$WORKSPACES_JSON" | jq -r '.[] | select(.is_active) | .name' 2>/dev/null)}

if [ "$FOCUSED_WORKSPACE" = "$WORKSPACE_NAME" ]; then
	SELECTED="true"
else
	SELECTED="false"
fi

update() {
	# Does this workspace have any windows? (window_count from the snapshot.)
	local win_count=$(echo "$WORKSPACES_JSON" |
		jq -r --arg n "$WORKSPACE_NAME" '.[] | select(.name==$n) | .window_count' 2>/dev/null)

	# Hide empty, unfocused workspaces; show focused or occupied ones.
	if [ "$SELECTED" = "true" ] || { [ -n "$win_count" ] && [ "$win_count" -gt 0 ]; }; then
		ICON_DRAWING="on"
		PADDING_LEFT=3
		PADDING_RIGHT=3
	else
		ICON_DRAWING="off"
		PADDING_LEFT=0
		PADDING_RIGHT=0
	fi

	WIDTH="dynamic"
	if [ "$SELECTED" = "true" ]; then
		WIDTH="0"
	fi

	sketchybar --animate tanh 20 --set $NAME \
		icon.highlight=$SELECTED \
		icon.drawing=$ICON_DRAWING \
		label.width=$WIDTH \
		padding_left=$PADDING_LEFT \
		padding_right=$PADDING_RIGHT
}

mouse_clicked() {
	if [ "$BUTTON" = "right" ]; then
		# Rift has no per-workspace destroy via CLI; no-op (matches aerospace).
		echo "Right click on rift workspace not supported"
	else
		# Focus the workspace. `execute workspace switch` takes the 0-based index,
		# so resolve name -> index from the snapshot.
		local idx=$(echo "$WORKSPACES_JSON" |
			jq -r --arg n "$WORKSPACE_NAME" '.[] | select(.name==$n) | .index' 2>/dev/null)
		[ -n "$idx" ] && rift-cli execute workspace switch "$idx" 2>/dev/null
	fi
}

case "$SENDER" in
"mouse.clicked")
	mouse_clicked
	;;
"mouse.entered")
	if [[ "$(sketchybar --query $NAME | jq -r .label.value)" != " " ]] && [[ $SELECTED != true ]]; then
		ft-haptic -n 1
	fi
	;;
*)
	# rift_workspace_changed / rift_windows_changed / forced update:
	# refresh the app-icon strip, then the focused state.
	$RELPATH/plugins/spaces/rift/script-windows.sh "$WORKSPACE_NAME" "$WORKSPACES_JSON"
	update
	;;
esac
