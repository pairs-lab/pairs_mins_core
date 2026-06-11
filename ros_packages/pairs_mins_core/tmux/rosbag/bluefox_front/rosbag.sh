#!/bin/bash
# Plain-tmux session script (one window per section below; panes are split and
# their commands typed via send-keys). Edit the send-keys lines to change what
# runs in each pane; ./kill.sh stops everything.

SESSION_NAME=rosbag

# absolute path to this script's directory; every pane starts here
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

# commands executed first in every pane
PRE_WINDOW='export UAV_NAME=uav25; export RUN_TYPE=realworld; export UAV_TYPE=x500; export SENSORS=""'
SETUP="cd $SCRIPTPATH; $PRE_WINDOW"

if [ -n "$TMUX" ]; then
  echo "Already inside tmux, detach first."
  exit 1
fi

if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
  echo "Session $SESSION_NAME already exists; attach with 'tmux a -t $SESSION_NAME' or stop it with ./kill.sh."
  exit 1
fi

# ---------------- window: roscore ----------------
read W_roscore P <<< "$(tmux new-session -d -s "$SESSION_NAME" -n "roscore" -x 250 -y 50 -P -F '#{window_id} #{pane_id}')"
tmux send-keys -t "$P" "$SETUP; "'roscore' Enter
tmux select-layout -t "$W_roscore" tiled

# ---------------- window: rosbag ----------------
read W_rosbag P <<< "$(tmux new-window -t "$SESSION_NAME" -n "rosbag" -P -F '#{window_id} #{pane_id}')"
tmux send-keys -t "$P" "$SETUP; "'cd ~/bag_files/' Enter
tmux select-layout -t "$W_rosbag" tiled

# ---------------- window: mins ----------------
read W_mins P <<< "$(tmux new-window -t "$SESSION_NAME" -n "mins" -P -F '#{window_id} #{pane_id}')"
tmux send-keys -t "$P" "$SETUP; "'waitForRos; rosparam set use_sim_time true; roslaunch pairs_mins_core rosbag_bluefox_front.launch UAV_NAME:=$UAV_NAME' Enter
tmux select-layout -t "$W_mins" tiled

# ---------------- window: core ----------------
read W_core P <<< "$(tmux new-window -t "$SESSION_NAME" -n "core" -P -F '#{window_id} #{pane_id}')"
tmux send-keys -t "$P" "$SETUP; "'waitForTime; rosparam set use_sim_time true; roslaunch pairs_mins_core rosbag_core.launch platform_config:=`rospack find pairs_uav_deployment`/config/pairs_uav_system/$UAV_TYPE.yaml world_config:=./config/world_config.yaml custom_config:=./config/pairs_uav_managers_mins.yaml network_config:=./config/network_config.yaml' Enter
tmux select-layout -t "$W_core" tiled

# ---------------- window: rviz ----------------
read W_rviz P <<< "$(tmux new-window -t "$SESSION_NAME" -n "rviz" -P -F '#{window_id} #{pane_id}')"
tmux send-keys -t "$P" "$SETUP; "'waitForControl; rosrun pairs_uav_deployment refactor_rviz_config_generic.sh mins.rviz $UAV_NAME' Enter
tmux select-layout -t "$W_rviz" tiled

# ---------------- window: kill (press enter inside to stop the session) ----------------
read W_kill P <<< "$(tmux new-window -t "$SESSION_NAME" -n "kill" -P -F '#{window_id} #{pane_id}')"
tmux send-keys -t "$P" "$SCRIPTPATH/kill.sh"

# mouse support (select panes / scroll with the mouse)
tmux set-option -t "$SESSION_NAME" mouse on

tmux select-window -t "$W_rosbag"
tmux -2 attach-session -t "$SESSION_NAME"
