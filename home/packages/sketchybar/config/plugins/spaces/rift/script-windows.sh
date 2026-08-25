#!/bin/bash
export RELPATH=$(dirname $0)/../..
source "$RELPATH/../icon_map.sh"

##
# Rift workspace windows indicator — rift analogue of the aerospace
# script-windows.sh. Renders the app-icon strip for one workspace's label.
# Ran per space item, so it updates only the caller's item.
#
# $1 = workspace name; $2 = optional cached `rift-cli query workspaces` JSON
# (passed by script-space.sh to avoid a second IPC round-trip).
##

update_workspace_windows() {
	local workspace_name=$1
	local workspaces_json=$2
	local sid=${workspace_name// /__} # item key uses __ for spaces (see spaces.sh)

	[ -z "$workspaces_json" ] && workspaces_json=$(rift-cli query workspaces 2>/dev/null)

	# App names for windows in this workspace (WorkspaceData.windows[].app_name).
	apps=$(echo "$workspaces_json" |
		jq -r --arg n "$workspace_name" \
			'.[] | select(.name==$n) | .windows[].app_name // empty' 2>/dev/null | sort -u)

	icon_strip=" "
	if [ "${apps}" != "" ]; then
		while read -r app; do
			icon_strip+=" $(
				__icon_map "$app"
				echo $icon_result
			)"
		done <<<"${apps}"
		sketchybar --set space.$sid label="$icon_strip" label.drawing=on

		local focused=${RIFT_WORKSPACE_NAME:-$(echo "$workspaces_json" | jq -r '.[] | select(.is_active) | .name' 2>/dev/null)}
		if ! [ "$focused" = "$workspace_name" ]; then
			sketchybar --set space.$sid background.drawing=on
		else
			sketchybar --set space.$sid background.drawing=off
		fi
	else
		# No apps in workspace, hide label
		sketchybar --set space.$sid label.drawing=off background.drawing=off
	fi
}

update_workspace_windows "$1" "$2"
