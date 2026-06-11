#!/bin/bash

path="/home/\$(optenv USER mrs)/bag_files/latest/"

# By default, we record everything.
# Except for this list of EXCLUDED topics:
exclude=(

# IN GENERAL, DON'T RECORD CAMERAS
#
# If you want to record cameras, create a copy of this script
# and place it at your tmux session.
#
# Please, seek an advice of a senior researcher of MRS about
# what can be recorded. Recording too much data can lead to
# ROS communication hiccups, which can lead to eland, failsafe
# or just a CRASH.

# Every topic containing "compressed"
# '(.*)compressed'
# Every topic containing "image_raw"
'(.*)rgb/image_raw'
'(.*)left/image_raw'
'(.*)right/image_raw'
'(.*)/color/image_raw'
'(.*)/rgbd/depth/(.*)'
'(.*)/aligned_depth_to_infra(.*)'
'(.*)infra1/image_raw'
'(.*)infra2/image_raw'
'(.*)fisheye1/image_raw'
'(.*)fisheye2/image_raw'
'(.*)basler_down/image_raw'
'(.*)stereo/image_raw/compressed'
# Every topic containing "theora"
'(.*)theora(.*)'
# Every topic containing "h264"
# '(.*)h264(.*)'

'(.*)os_cloud_nodelet(.*)'
'(.*)pcl_filtered'
'(.*)pcl_filtered_slow'
'(.*)p_o_m_r'
'(.*)tsdf_slice'
'(.*)occupied_nodes'
'(.*)tsdf_map_out'
# '(.*)ov_msckf(.*)'
'(.*)ov_msckf/loop(.*)'
'(.*)ov_msckf/trackhist'
'(.*)compressedDepth'
# '(.*)image_mono16(.*)'
'(.*)image_mono8(.*)'
'(.*)image_noise(.*)'
#'(.*)image_depth(.*)'
'(.*)point(.*)'
'(.*)debug(.*)'
'(.*)processed(.*)'
'(.*)nn/overlay'
'(.*)nn/overlay_compressed'
'(.*)nn/overlay_compressed(.*)Depth'
'(.*)rgb/preview(.*)'
'(.*)nn/passthrough(.*)'
)

# file's header
filename=`mktemp`
echo "<launch>" > "$filename"
echo "<arg name=\"UAV_NAME\" default=\"\$(env UAV_NAME)\" />" >> "$filename"
echo "<group ns=\"\$(arg UAV_NAME)\">" >> "$filename"

echo -n "<node pkg=\"rosbag\" type=\"record\" name=\"rosbag_record\" output=\"screen\" args=\"-o $path -a" >> "$filename"

# if there is anything to exclude
if [ "${#exclude[*]}" -gt 0 ]; then

  echo -n " -x " >> "$filename"

  # list all the string and separate the with |
  for ((i=0; i < ${#exclude[*]}; i++));
  do
    echo -n "${exclude[$i]}" >> "$filename"
    if [ "$i" -lt "$( expr ${#exclude[*]} - 1)" ]; then
      echo -n "|" >> "$filename"
    fi
  done

fi

echo "\">" >> "$filename"

echo "<remap from=\"~status_msg_out\" to=\"mrs_uav_status/display_string\" />" >> "$filename"
echo "<remap from=\"~data_rate_out\" to=\"~data_rate_MB_per_s\" />" >> "$filename"

# file's footer
echo "</node>" >> "$filename"
echo "</group>" >> "$filename"
echo "</launch>" >> "$filename"

cat $filename
roslaunch $filename
