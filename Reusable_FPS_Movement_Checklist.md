# Reusable FPS Movement Checklist
Reviewed from `PlayerController.gd`, `MovementComponent.gd`, `GravityComponent.gd`, `AdvancedJumpComponent.gd`, `InputComponent.gd`, `CameraController.gd`, `base_state.gd`, and `state_machine.gd`. Status reflects the actual current scripts, not a playtest.

- Checked: an implementation is present and correct in the current scripts.
- Unchecked with **Partial**: an attempt exists but needs completion or correction.
- Unchecked with **Verify**: engine behavior or scene configuration needs confirmation.
- Other unchecked items: no implementation found in the current scripts.

A checked item does not certify that external nodes, scene configuration, or the Input Map are correctly set up.

# Architecture

This section tracks the planned component-and-state-machine structure. Complete this before adding complex abilities.

## Layered state machine

Four independent layers that read each other but do not collapse into a single flat enum.

| Layer | States |
| --- | --- |
| Locomotion | Grounded, Airborne |
| Stance | Standing, Crouching, Prone |
| Action | None, Sliding, Wallrunning, Wallclimbing, Mantling, Ziplining, Grappling |
| Ability | None, Dashing, Jetpacking, WallJumping |

- [ ] **Partial:** Implement `PlayerStateMachine` with `enter` / `exit` / `physics_update` / `handle_input` lifecycle — stubs exist but execute nothing.
- [ ] **Partial:** Implement `PlayerState` lifecycle methods — `_ready()` resolves the controller reference but no enter, exit, or update behavior is defined.
- [ ] Implement the Locomotion layer (Grounded / Airborne) as the first working pair.
- [ ] Implement the Stance layer (Standing / Crouching) driven by `StanceComponent`.
- [ ] Implement the Action layer with at least None and Sliding states.
- [ ] Implement the Ability layer with at least None and Dashing states.
- [ ] Define legal cross-layer constraints (e.g. Sliding forces Stance to Crouching; Jetpacking forces Locomotion to Airborne).
- [ ] Document all legal state combinations and transition triggers.

## Planned new components

| Component | Responsibility | Status |
| --- | --- | --- |
| `StanceComponent` | Resize `CapsuleShape3D`, reposition `CollisionShape3D` to keep feet planted, lerp camera anchor height, ceiling-clearance raycast | Not started |
| `SurfaceProbeComponent` | All environment raycasts: wall detection, ledge detection, slope angle, step height, climbable-surface tagging | Not started |
| `ResourceComponent` | Depletable meters with configurable regen: stamina, jetpack fuel, dash charges, grapple charges | Not started |
| `MomentumComponent` | Store and restore speed across state transitions for slide entry, grapple release, and dash exit | Not started |
| `CameraEffectsComponent` | Headbob, FOV scaling, Z-roll for wallrun and lean, landing squish, camera-height lerp on crouch | Not started |

## Planned component extensions

| Component | Extension needed |
| --- | --- |
| `MovementComponent` | Accept explicit `target_speed` and `accel` parameters so states pass values in rather than the component guessing from `is_on_floor()` |
| `GravityComponent` | Accept a `scale` multiplier per call (wallrunning `0.3`, jetpacking `0.0`, normal `1.0`) |
| `AdvancedJumpComponent` | Accept a `Vector3` impulse so wall-jump and grapple-jump states supply lateral-and-upward velocity |

# Core ground movement

- [x] Walking forward and backward — `Input.get_vector` is read every physics tick in `InputComponent`.
- [x] Strafing left and right.
- [x] Movement follows the player's facing direction — direction is rotated by `body.global_basis` in `MovementComponent`.
- [x] Normalize diagonal movement — `MovementComponent` normalizes when `dir_len >= 1`.
- [ ] **Partial:** Hold to sprint — `get_sprint_input()` exists on `InputComponent` but `MovementComponent` never reads it; speed is fixed at the `speed` export.
- [x] Smooth ground acceleration toward the target velocity — `move_toward` with `ground_accel_speed`.
- [x] Smooth ground braking when input is released — `move_toward` with `ground_decel_speed`.
- [x] Smooth direction changes through velocity interpolation.
- [x] Move the character through collision-aware `move_and_slide()`.
- [ ] Preserve analog stick input magnitude — `MovementComponent` re-normalizes `rotated_dir` unconditionally, discarding partial input magnitude.
- [ ] Tune acceleration, braking, and reversing independently.
- [ ] Configure different forward, backward, and strafe speeds.
- [ ] Configure sprint direction restrictions and cancellation rules.
- [ ] Offer sprint toggle as well as hold.
- [ ] Optional stamina, sprint exhaustion, and recovery — planned via `ResourceComponent`.
- [ ] Optional slow-walk or precision movement modifier.

# Jumping and falling

- [x] Basic grounded jump — `AdvancedJumpComponent.jump()` sets `body.velocity.y = jump_velocity`.
- [x] Gravity while airborne — `GravityComponent.handle_gravity()` subtracts `gravity * delta` when not on floor.
- [x] Separate air steering strength from ground acceleration — `air_accel_speed` and `air_decel_speed` in `MovementComponent`.
- [x] Preserve horizontal velocity in the air when there is no movement input — `move_toward` with `air_decel_speed` approaches zero slowly.
- [x] Jump buffering — `buffer_timer` in `AdvancedJumpComponent`; jump executes while the timer is running.
- [x] Variable jump height — releasing jump while `velocity.y > 0` multiplies it by `0.5` in `AdvancedJumpComponent`.
- [ ] **Partial:** Coyote time — `coyote_timer` starts on floor-departure, but jumping does not stop the timer, allowing a second jump during the remaining window.
- [ ] **Partial:** Configurable N air jumps — `num_air_jumps` and `air_jumps_remaining` exist, but the ground-jump allowance is not consumed after jumping, so coyote-window jumps can double-fire.
- [ ] Prevent the ground-jump allowance from being reused within the same coyote window.
- [ ] Separate rising and falling gravity for a more deliberate jump arc — planned via `GravityComponent` scale multiplier.
- [ ] Optional gravity reduction near the jump apex.
- [ ] Optional terminal falling speed.
- [ ] Explicit rules for horizontal momentum when taking off and landing.
- [ ] Optional hold-to-jump automatically on landing.
- [ ] Optional bunny hopping with deliberate speed retention or gain — buffering alone does not define it.
- [ ] Jump rules while crouching, sliding, climbing, or using other abilities — depends on the Action layer.
- [ ] Fall-distance or impact-speed tracking for hard landings and optional fall damage.

# Crouching and stance changes

- [ ] **Partial:** Crouch input — `get_crouch_input()` exists on `InputComponent` but nothing in the current scripts reads or acts on it.
- [ ] Implement `StanceComponent`: resize `CapsuleShape3D` height, reposition `CollisionShape3D` to keep feet planted, lerp camera anchor to crouch height.
- [ ] Derive movement target speed from the active Stance layer state every physics tick.
- [ ] Ceiling-clearance raycast in `StanceComponent` to block standing up when obstructed.
- [ ] Keep crouching under an obstacle after the button is released; stand automatically when clear.
- [ ] Separate camera eye height from the collision shape size.
- [ ] Crouch toggle option alongside hold-to-crouch.
- [ ] Deliberate crouch behavior in the air, including low-clearance jump passages.
- [ ] Consistent crouch behavior on slopes, steps, and moving platforms.
- [ ] Prone stance and crawling — Stance layer `Prone` state driving `StanceComponent`.

# Sliding

Sliding is the Action layer `Sliding` state. It forces the Stance layer to `Crouching` on entry and reads from `MomentumComponent` and `StanceComponent`.

- [ ] Enter a slide from Locomotion `Grounded` when crouching above a minimum horizontal speed.
- [ ] Capture entry momentum via `MomentumComponent` so subsequent input cannot override it.
- [ ] Apply configurable slide drag each tick without ordinary walking logic interfering.
- [ ] Steer a slide with movement input using a separate friction value; use a clean direction check to cancel.
- [ ] Cancel the slide when crouch is released, horizontal speed drops below a threshold, or the player becomes airborne.
- [ ] Transition from sliding to Stance `Crouching` or `Standing` according to overhead clearance from `StanceComponent`.
- [ ] Optional initial slide speed boost.
- [ ] Slide duration limit and cooldown before re-entry.
- [ ] Slope-aware sliding — gain speed downhill, lose speed uphill.
- [ ] Slide jump: explicit upward and forward impulse via `AdvancedJumpComponent`, then exit the Sliding state.

# Slopes stairs and collision handling

- [ ] **Verify:** Walk up and down ordinary ramps using CharacterBody3D slope handling.
- [ ] **Verify:** Stay attached to descending ramps through floor snapping.
- [ ] **Verify:** Enforce the maximum walkable slope through `floor_max_angle` — confirm this is set in the scene or `PlayerController`.
- [ ] **Verify:** Stand still on walkable slopes without unwanted drift.
- [ ] **Verify:** Slide along walls when walking diagonally into them.
- [ ] **Verify:** Stop upward movement correctly when hitting a ceiling.
- [ ] Choose and tune constant ground speed versus slope-dependent speed.
- [ ] Controlled sliding down surfaces steeper than `floor_max_angle`.
- [ ] Step up small obstacles and stairs — implement via `SurfaceProbeComponent` raycasts with correct rise calculation from foot position.
- [ ] Step down small drops and stairs while preserving grounded movement.
- [ ] Check the full character volume and headroom before accepting a step.
- [ ] Reject steps above the permitted height and surfaces too steep to stand on.
- [ ] Smooth camera height over stairs via `CameraEffectsComponent` without changing the collision result.
- [ ] Consistent movement over uneven floors and small seams.
- [ ] Handle tight corners, doorways, and narrow gaps without snagging.
- [ ] Prevent stair correction from lifting the player during an airborne jump.
- [ ] Detect and recover from invalid spawn positions or becoming stuck inside geometry.
- [ ] Verify high-speed collision handling with thin walls and small obstacles.

# Moving platforms surfaces and external forces

- [ ] **Verify:** Ride moving platforms and elevators — CharacterBody3D has built-in support; scene setup is unknown.
- [ ] **Verify:** Inherit platform velocity on departure or jumping according to the chosen engine setting.
- [ ] Handle rotating platforms and define whether they rotate the player's facing.
- [ ] Conveyor belts and directional surface movement.
- [ ] Surface-dependent movement settings such as ice, mud, or slippery floors.
- [ ] External impulses, knockback, explosions, and launch pads without movement immediately erasing them.
- [ ] Wind or other movement-affecting volumes.
- [ ] Optional pushing of physical props, including behavior when the player is crushed.

# Ledges walls and climbing

Wall detection and ledge detection are all provided by `SurfaceProbeComponent`. Wallrunning, Wallclimbing, and Mantling are Action layer states.

## Mantling and vaulting
- [ ] Detect a reachable ledge or vault surface via `SurfaceProbeComponent`.
- [ ] Enter the `Mantling` Action state: brief exclusive control, lerp player up and over.
- [ ] Check the full traversal path and destination clearance before accepting a mantle.
- [ ] Vault over low obstacles as a faster, lower-clearance variant of mantle.

## Wall running
- [ ] Detect a runnable wall via `SurfaceProbeComponent` (angle, tag, minimum entry speed).
- [ ] Enter the `Wallrunning` Action state: suppress gravity via `GravityComponent` scale, align movement along the wall.
- [ ] Wall-run duration timer and stamina cost via `ResourceComponent`.
- [ ] Wall-run exit conditions: timer expiry, speed drop, jump, or wall ends.
- [ ] Wall-run jump: lateral impulse away from wall plus upward impulse via `AdvancedJumpComponent`.
- [ ] Re-entry rules: cooldown or require touching the floor before the same wall again.
- [ ] Camera Z-roll during wall run via `CameraEffectsComponent`.

## Wall climbing
- [ ] Detect a climbable vertical surface via `SurfaceProbeComponent` (tag or angle threshold).
- [ ] Enter the `Wallclimbing` Action state: override vertical velocity, map vertical input to climb speed.
- [ ] Stamina cost and exhaustion via `ResourceComponent`.
- [ ] Wall-climb jump: push away from wall via `AdvancedJumpComponent`.

## Wall jumping
- [ ] Wall-jump as an Ability layer `WallJumping` burst state, available from Wallrunning or Wallclimbing.
- [ ] Defined lateral and upward impulse away from the detected wall normal.
- [ ] Re-entry rules and cooldown.

## Ledge grabbing and shimmy
- [ ] Ledge grab and stable hanging position.
- [ ] Climb up from a ledge or drop deliberately.
- [ ] Shimmy along ledges and around suitable corners.

## Ladders
- [ ] Climb designated climbable surfaces (ladders, climbing walls) via trigger volume or surface tag.

# Dashes and ground pounds

Dashing is the Ability layer `Dashing` state, available from both Locomotion `Grounded` and `Airborne`.

- [ ] Directional dash burst — direction from movement input, or facing direction if no input.
- [ ] Air dash with configurable charges tracked by `ResourceComponent`.
- [ ] Dash duration, speed, and cooldown; recharge on landing or after a timer.
- [ ] Dash collision and cancellation behavior; preserve or redirect momentum afterward via `MomentumComponent`.
- [ ] Fast fall — pass a high `GravityComponent` scale when Locomotion is `Airborne` and crouch is held.
- [ ] Ground pound — dedicated Action layer state entered from fast-fall; slam descent, no steering.
- [ ] Ground-pound impact event: landing feedback, recovery frames, optional area effect hook.

# Grappling and rope traversal

## Grappling
Grappling is the Action layer `Grappling` state. On detach, momentum is preserved via `MomentumComponent`.

- [ ] Aim and select valid grapple targets within range via raycast or arc prediction.
- [ ] Fire, travel, attach, miss, retract, and detach states within the Grappling Action state.
- [ ] Pull the player toward the anchor — override velocity each tick.
- [ ] Optional rope swing with a maximum rope length constraint.
- [ ] Reel the rope in or out with input.
- [ ] Preserve momentum on detach via `MomentumComponent`; optional grapple jump on detach.
- [ ] Handle blocked ropes, rope corners, and moving anchors.
- [ ] Grapple cooldown and charges tracked by `ResourceComponent`.

## Ziplining
Ziplining is the Action layer `Ziplining` state.

- [ ] Attach to a zipline anchor and lock player to the line path.
- [ ] Travel along the line with gravity-driven or fixed speed.
- [ ] Speed control: brake input, speed cap.
- [ ] Detach deliberately or automatically at the end; preserve momentum via `MomentumComponent`.

# Gliding swimming and other movement modes

## Jetpacking
Jetpacking is the Ability layer `Jetpacking` state. It forces Locomotion to `Airborne` and suppresses gravity via `GravityComponent` scale.

- [ ] Activate jetpack: suppress or reduce gravity, apply upward thrust proportional to input.
- [ ] Fuel meter and depletion tracked by `ResourceComponent`; cut thrust at zero fuel.
- [ ] Fuel regeneration on ground or after a delay.
- [ ] Directional thrust: forward and lateral movement while jetpacking via `MovementComponent`.
- [ ] Deactivate jetpack: transition back to Locomotion `Airborne`, restore gravity scale.
- [ ] Camera effects during jetpack via `CameraEffectsComponent`.

## Gliding (optional)
- [ ] Deploy and retract a glider from Locomotion `Airborne`.
- [ ] Tune glide forward speed, descent rate, steering, and momentum.
- [ ] Glider stall or speed limits.
- [ ] Glider landing transition and ceiling or wall collision behavior.
- [ ] Optional parachute or slow-fall ability.

## Swimming (optional)
- [ ] Enter and leave water without broken state transitions.
- [ ] Surface swimming and underwater movement, including ascending and descending.
- [ ] Water drag, buoyancy, and optional currents.
- [ ] Optional underwater breath and drowning hooks.

## Utility
- [ ] Optional spectator or noclip movement for development and debugging.

# Camera feel and visual feedback

- [x] Mouse look with player yaw and camera pitch — `CameraController.update_camera_rotation()`.
- [x] Clamp camera pitch — `tilt_lower_limit` and `tilt_upper_limit` exported on `CameraController`; currently clamped to ±90°.
- [x] Capture the mouse — `MouseCaptureComponent` handles this.
- [ ] Implement `CameraEffectsComponent` to own all reactive camera effects below.
- [ ] Speed-driven walking head bob via `CameraEffectsComponent`.
- [ ] Smooth strafe lean based on lateral velocity via `CameraEffectsComponent`.
- [ ] Ease strafe lean back toward neutral while airborne or in an Action state.
- [ ] Head bob returns cleanly to rest without snapping or retaining an offset.
- [ ] Exposed mouse sensitivity, separate axes, and invert-look options.
- [ ] Gamepad look sensitivity, dead zones, and response curves.
- [ ] Release and recapture the cursor for pause, menus, and focus changes.
- [ ] Adjustable base FOV and speed-based or sprint-based FOV scaling via `CameraEffectsComponent`.
- [ ] Jump takeoff, landing compression, and hard-landing camera feedback via `CameraEffectsComponent`.
- [ ] Camera transitions for crouch, slide, dash, wall-run, and grapple.
- [ ] Camera Z-roll for wall-run and manual or strafe-driven leaning via `CameraEffectsComponent`.
- [ ] Optional acceleration sway, impact shake, and weapon movement hooks.
- [ ] Keep the camera out of walls and ceilings during stance and traversal changes.
- [ ] Independent toggles to disable bob, roll, shake, and FOV shifts for accessibility.
- [ ] Confirm interpolation project settings and prevent duplicate interpolation; reset after teleports.

# Movement audio and feedback hooks

`PlayerAudio.gd` exists at the project root but is not wired to any current component or state. All audio hooks are unimplemented in the current scripts.

- [ ] Wire `PlayerAudio.gd` to the movement system — emit signals from state transitions or call it from `CameraEffectsComponent`.
- [ ] Footstep sound triggered by head-bob phase wrap in `CameraEffectsComponent`.
- [ ] Landing sound triggered by Locomotion layer transition from `Airborne` to `Grounded`.
- [ ] Choose footstep sounds by surface material, Stance layer state, and movement speed.
- [ ] Pitch or sample variation and configurable footstep volume.
- [ ] Audio hooks for jump, slide start, dash, wall-run, grapple fire, grapple attach, and climb.
- [ ] Scale landing audio intensity by impact speed.
- [ ] Optional controller vibration and movement feedback events for other systems.

# Reuse configuration and state management

- [ ] **Partial:** Layered state machine framework — `PlayerStateMachine` and `PlayerState` stubs exist with controller references, but no lifecycle execution or transitions are implemented.
- [ ] Implement four independent layer state machines (Locomotion, Stance, Action, Ability) as described in the Architecture section.
- [ ] Define and document all legal cross-layer state combinations and transition triggers.
- [ ] Document ability interactions: cancellation rules, priority, and momentum handoff.
- [ ] Emit signals for state transitions: `jumped`, `landed`, `stance_changed`, `slide_started`, `dash_started`, etc.
- [ ] Feature switches so each ability can be disabled without breaking others.
- [ ] Export settings as configuration Resources rather than inline constants.
- [ ] Reusable player scene with documented child nodes, collision setup, and required input actions.
- [ ] `InputComponent` as the single source of truth for all input — no other component reads `Input` directly.
- [ ] Input rebinding and keyboard or controller support through `InputComponent`.
- [ ] Pause, death, cutscene, and respawn handling that reset all layer states predictably.
- [ ] Consistent tuning across supported frame rates and physics tick rates.
- [ ] Debug overlay: active state for each layer, current velocity, floor angle, active timers, and raycast hits.

# Movement playground and acceptance checks

- [ ] A reusable test map with flat ground, ramps, stairs, low ceilings, narrow gaps, moving platforms, and tagged wall surfaces.
- [ ] Measure walk, sprint, and crouch speeds in all directions, including diagonals and partial analog input.
- [ ] Check immediate stopping, direction reversal, and analog stick dead zones.
- [ ] Check jumps from flat ground, slopes, moving platforms, and platform edges.
- [ ] Check coyote time just inside and outside its window; confirm it is consumed after jumping.
- [ ] Check jump buffering just before landing and after the buffer expires.
- [ ] Check crouch and slide under low ceilings and when releasing the button while obstructed.
- [ ] Check wall-run entry, exit, jump, and re-entry cooldown.
- [ ] Check mantle and vault on surfaces of varying heights and angles.
- [ ] Check grapple fire, swing, reel, and momentum on detach.
- [ ] Check ability combinations: slide-jump, crouch-fast-fall, wall-run-jump, grapple-dash, jetpack-dash.
- [ ] Check stamina and fuel exhaustion and recovery.
- [ ] Check all layer state combinations that should be legal; confirm illegal ones are blocked.
- [ ] Check low and high frame rates, multiple physics tick rates, and unusually long frames.
- [ ] Check teleports, respawns, scene changes, pause, and lost application focus.

# Issues to address first

| Area | What the current code does | Next action |
| --- | --- | --- |
| Sprint not connected | `InputComponent.get_sprint_input()` exists but `MovementComponent` never calls it; speed is always the base `speed` export. | Pass sprint state into `MovementComponent` or have the Locomotion Grounded state select the correct target speed. |
| Analog magnitude lost | `MovementComponent` re-normalizes `rotated_dir` unconditionally, making partial stick input identical to full input. | Normalize only when `dir_len > 1` (already done for the input), and skip the second normalize on `rotated_dir`. |
| Coyote jump double-fire | `coyote_timer` is not stopped after a coyote jump, so a second jump press within the window resets upward velocity. | Stop `coyote_timer` and clear the ground-jump allowance immediately after any successful jump. |
| Air-jump allowance | `air_jumps_remaining` is reset on landing but the consumed-on-coyote-jump path is incomplete due to the bug above. | Fix coyote first, then verify `air_jumps_remaining` decrements correctly for non-floor non-coyote jumps. |
| No state machine execution | `PlayerStateMachine` and `PlayerState` are stubs; no `enter`, `exit`, or `physics_update` methods exist. Every subsequent feature depends on this. | Implement the four-layer state machine before adding any new ability. |
| Crouch entirely absent | `get_crouch_input()` is on `InputComponent` but nothing reads it; no `StanceComponent` exists. | Create `StanceComponent` and wire crouch input through the Stance layer state machine. |
| Camera effects absent | Headbob, strafe lean, FOV scaling, and all reactive effects from the old script are gone. | Create `CameraEffectsComponent` and re-implement effects driven by layer state signals. |

# Suggested implementation order

1. **Fix the two jump bugs** — coyote double-fire and analog magnitude. These are two-line fixes and unblock clean tuning.
2. **Implement the state machine lifecycle** — `enter`, `exit`, `physics_update`, `handle_input` on `PlayerState`; execution loop on `PlayerStateMachine`. Build and test the Locomotion layer (Grounded / Airborne) first.
3. **Connect sprint to `MovementComponent`** — Locomotion `Grounded` state selects target speed based on sprint input. Trivial once the state machine exists.
4. **Create `StanceComponent` and implement the Stance layer** — Standing and Crouching states. This fixes the biggest missing feature and unblocks sliding, crawling, and mantling.
5. **Implement Sliding** — Action layer `Sliding` state using `StanceComponent` and `MomentumComponent`.
6. **Create `SurfaceProbeComponent`** — centralise all raycasts. Implement slope enforcement, stair step-up and step-down, and ceiling clearance.
7. **Create `CameraEffectsComponent`** — headbob, strafe lean, FOV, and crouch camera height lerp. Wire to layer state signals.
8. **Wall running and wall climbing** — Action layer states reading from `SurfaceProbeComponent`. Share detection logic.
9. **Mantling and vaulting** — builds directly on `SurfaceProbeComponent` ledge detection.
10. **Dashing** — Ability layer `Dashing` state. Add `ResourceComponent` for charges.
11. **Jetpacking** — Ability layer `Jetpacking` state. Add fuel to `ResourceComponent`.
12. **Grappling and ziplining** — Action layer states. Most complex; build last when all simpler states are stable.

# Script reference

| Script | Key contents |
| --- | --- |
| `PlayerController.gd` | `_physics_process()` orchestrates component calls; `update_rotation()` applies yaw. |
| `MovementComponent.gd` | `handle_horizontal_movement()` — direction rotation, `move_toward` acceleration. |
| `GravityComponent.gd` | `handle_gravity()` — subtracts `gravity * delta` when not on floor; `is_falling` flag. |
| `AdvancedJumpComponent.gd` | Jump buffering, coyote timer, air jump counter, variable jump height on release. |
| `InputComponent.gd` | `input_horizontal`, `get_jump_input()`, `get_jump_input_released()`, `get_sprint_input()`, `get_crouch_input()`. |
| `CameraController.gd` | Mouse-look rotation split into player yaw and camera pitch; pitch clamped by exports. |
| `base_state.gd` | `PlayerState` — resolves controller reference in `_ready()`; no lifecycle methods. |
| `state_machine.gd` | `PlayerStateMachine` — exposes debug flag and controller reference; no execution logic. |
| `PlayerAudio.gd` | Exists at project root; not wired to any component or state. |

# Engine references

[Godot CharacterBody3D reference](https://docs.godotengine.org/en/stable/classes/class_characterbody3d.html) — slope limits, floor snapping, wall and ceiling handling, platform behavior. Confirm these are configured in the scene before treating them as missing.

[Godot physics troubleshooting](https://docs.godotengine.org/en/stable/tutorials/physics/troubleshooting_physics_issues.html) — advises changing collision shape dimensions rather than scaling physics bodies or collision shapes.
