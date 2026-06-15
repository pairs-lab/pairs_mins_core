# pairs_mins_core

A metapackage that bundles everything needed to run the PAIRS UAV system with MINS multi-sensor state estimation. It pulls in the MINS estimator and its PAIRS plugin, ships the launch files, sensor and world configs, RViz views, and ready-to-run tmux sessions for simulation, real-world flights, and rosbag replay. This is the entry point for bringing up a multirotor that localizes from visual-inertial / multi-sensor fusion rather than GNSS.

## Contents

### Bundled repositories (via gitman)

- [mins](https://github.com/pairs-lab/mins) — the MINS multi-sensor inertial navigation estimator.
- [pairs_mins_estimator_plugin](https://github.com/pairs-lab/pairs_mins_estimator_plugin) — the PAIRS state-estimator plugin that feeds MINS output into the estimation manager.
- [pairs_open_vins_core](https://github.com/pairs-lab/pairs_open_vins_core) — OpenVINS core used by the estimation pipeline.

### Provided in this package (`ros_packages/pairs_mins_core`)

- `launch/` — bring-up launch files for sensors and estimation, including `oak.launch`, `pico_t265.launch`, `filter_t265.launch`, `point_cloud_manager.launch`, `simulation_bluefox.launch`, the `realworld_*` and `rosbag_*` launches, and `rviz.launch`.
- `config/` — sensor, world, and manager configs for the `simulation`, `realworld`, and `rosbag` scenarios.
- `tmux/` — plain-tmux sessions: `simulation`, `realworld` (bluefox_front, oak_front, pico_t265), and `rosbag` (bluefox_front, pico_t265).
- `rviz/` — default RViz configuration.

## Install (ROS 1 Noetic)

```bash
sudo apt install ros-noetic-pairs-mins-core
```

## Usage

Launch the RViz-backed simulation tmux session:

```bash
cd tmux/simulation
./simulation.sh        # stop with ./kill.sh
```

Replay a rosbag through the estimation pipeline:

```bash
cd tmux/rosbag/bluefox_front
./rosbag.sh            # stop with ./kill.sh
```

Individual launch files can also be run directly, e.g.:

```bash
roslaunch pairs_mins_core simulation_bluefox.launch
```
