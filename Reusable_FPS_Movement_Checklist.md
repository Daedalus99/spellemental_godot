# Reusable FPS Movement Checklist
Reviewed 17 October 2026 from `PlayerMovement.gd`, `PlayerCamera.gd`, `base_state.gd`, and `state_machine.gd`. Status reflects the supplied code, not a playtest. The player scene, project settings, Input Map, and `PlayerAudio` script were not supplied.

- Checked: an implementation or explicitly named hook is present in the supplied scripts.
- Unchecked with **Partial**: an attempt exists but needs completion or correction.
- Unchecked with **Verify**: engine behavior or scene configuration needs confirmation.
- Other unchecked items: no implementation was found in the supplied scripts.

Implemented in code: 26. Partial: 11. Verify: 8. Remaining items: 128. A checked hook does not certify the external component it calls.

# Core ground movement

- [x] Walking forward and backward — separate input actions are read each physics tick.
- [x] Strafing left and right.
- [x] Movement follows the player's facing direction.
- [x] Normalize diagonal movement so diagonal input does not increase target speed.
- [x] Hold to sprint — a higher target speed while sprint is pressed.
- [x] Smooth ground acceleration toward the target velocity.
- [x] Smooth ground braking when movement input is released.
- [x] Smooth changes of direction through velocity interpolation.
- [x] Move the character through collision-aware `move_and_slide()`.
- [ ] Tune acceleration, braking, and reversing independently.
- [ ] Preserve analog stick input magnitude — the final `.normalized()` currently removes it.
- [ ] Configure different forward, backward, and strafe speeds.
- [ ] Configure sprint direction restrictions and cancellation rules.
- [ ] Offer sprint toggle as well as hold.
- [ ] Optional stamina, sprint exhaustion, and recovery.
- [ ] Optional slow-walk or precision movement modifier.

# Jumping and falling

- [x] Basic grounded jump — set upward velocity to `JUMP_VELOCITY`.
- [x] Gravity while airborne.
- [x] Separate air steering strength from ground acceleration.
- [x] Preserve horizontal velocity in the air when there is no movement input.
- [x] Jump buffering — remember a jump press for approximately 0.15 seconds.
- [ ] **Partial:** Coyote time — a 0.1-second window exists, but it is not consumed after jumping.
- [ ] Prevent another ground jump until landing after the jump allowance is consumed.
- [ ] Double jump or configurable N jumps, with the count reset on valid landing.
- [ ] Variable jump height based on how long jump is held.
- [ ] Separate rising and falling gravity for a more deliberate jump arc.
- [ ] Optional gravity reduction near the jump apex.
- [ ] Expose jump height and time to apex as useful tuning parameters — `JUMP_HEIGHT` is currently unused.
- [ ] Optional terminal falling speed.
- [ ] Explicit rules for horizontal momentum when taking off and landing.
- [ ] Optional hold-to-jump automatically on landing.
- [ ] Optional bunny hopping with deliberate speed retention or gain — buffering alone does not define it.
- [ ] Jump rules while crouching, sliding, climbing, or using other abilities.
- [ ] Fall-distance or impact-speed tracking for hard landings and optional fall damage.

# Crouching and stance changes

- [ ] **Partial:** Basic hold-to-crouch — currently implemented by scaling the whole player body.
- [ ] **Partial:** Slower crouch movement — crouch speed is assigned only when entering crouch.
- [ ] **Partial:** Smooth lowering and raising — scaling is interpolated, but collider and camera need explicit stance handling.
- [ ] Resize the collision shape dimensions for crouch while keeping the feet planted.
- [ ] Separate camera eye height from the collision shape size.
- [ ] Prevent standing when a ceiling or obstacle blocks the full standing volume.
- [ ] Keep crouching under an obstacle after the button is released; stand when clear.
- [ ] Crouch toggle option.
- [ ] Deliberate crouch behavior in the air, including low-clearance jump passages.
- [ ] Consistent crouch behavior on slopes, steps, and moving platforms.
- [ ] Optional prone stance and crawling.

# Sliding

- [ ] **Partial:** Enter a slide by crouching while moving — the current speed threshold is very low.
- [ ] **Partial:** Capture entry momentum — stored as `slide_start_velocity`, but input still pulls velocity toward walk or sprint targets.
- [x] Apply slide drag while no movement input is held.
- [ ] **Partial:** Steer or cancel a slide with movement input — cancellation uses an unnormalized dot product.
- [x] Cancel the current slide when crouch is released or the player becomes airborne.
- [ ] A deliberate minimum horizontal speed to start sliding.
- [ ] Automatically finish the slide below a configured horizontal speed.
- [ ] Transition from sliding to crouch or standing according to overhead clearance.
- [ ] Optional initial slide boost.
- [ ] Slide duration, cooldown, and repeated-slide rules.
- [ ] Slope-aware sliding — gain speed downhill and lose speed uphill.
- [ ] Tune slide friction and steering without ordinary walking logic overriding them.
- [ ] Slide jump with explicit momentum and stance behavior.

# Slopes stairs and collision handling

- [ ] **Verify:** Walk up and down ordinary ramps using CharacterBody3D slope handling.
- [ ] **Verify:** Stay attached to descending ramps through floor snapping.
- [ ] **Verify:** Enforce the maximum walkable slope through `floor_max_angle` — `MAX_SLOPE_DEG` is not applied by the script.
- [ ] **Verify:** Stand still on walkable slopes without unwanted drift.
- [ ] Choose and tune constant ground speed versus slope-dependent speed.
- [ ] Controlled sliding down surfaces that are too steep to walk on.
- [ ] **Partial:** Step up small obstacles and stairs — a raycast attempt exists, but its height calculation needs correction.
- [ ] Step down small drops and stairs while preserving grounded movement.
- [ ] Check the full character volume and headroom before accepting a step.
- [ ] Reject steps above the permitted height and surfaces too steep to stand on.
- [ ] Smooth camera height over stairs without changing the collision result.
- [ ] Consistent movement over uneven floors and small seams.
- [ ] **Verify:** Slide along walls when walking diagonally into them.
- [ ] **Verify:** Stop upward movement correctly when hitting a ceiling.
- [ ] Handle tight corners, doorways, and narrow gaps without snagging.
- [ ] Prevent stair correction from lifting the player during an ordinary airborne jump.
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

- [ ] Detect a reachable ledge with a valid grab point.
- [ ] Ledge grab and hanging, with a stable hanging position.
- [ ] Climb up from a ledge or drop from it.
- [ ] Shimmy along ledges and move around suitable corners.
- [ ] Vault over low obstacles and mantle onto higher surfaces.
- [ ] Check the full traversal path and destination for clearance.
- [ ] Climb ladders or designated climbable surfaces.
- [ ] Wall jump with a defined push away from the wall.
- [ ] Wall slide with limited falling speed.
- [ ] Wall running — the existing TODO is a note, not an implementation.
- [ ] Wall-run entry speed, allowed surfaces, duration, exit conditions, and re-entry rules.
- [ ] Wall-run jump and deliberate momentum when returning to normal movement.

# Dashes and ground pounds

- [ ] Ground dash, dodge, or directional burst.
- [ ] Air dash and configurable dash charges.
- [ ] Dash duration, cooldown, speed, and recharge conditions.
- [ ] Dash collision and cancellation behavior, including momentum afterward.
- [x] Fast fall — pressing crouch in the air increases gravity from 10 to 100.
- [ ] **Partial:** Ground pound — fast falling exists, but there is no dedicated slam state or impact behavior.
- [ ] Ground-pound entry rules, descent control, and cancellation behavior.
- [ ] Ground-pound impact event, landing feedback, recovery, and optional bounce or damage hook.

# Grappling and rope traversal

- [ ] Aim and select valid grapple targets within range.
- [ ] Fire, attach, miss, retract, and detach the grapple.
- [ ] Pull the player toward an anchor point.
- [ ] Optional rope swing with a maximum rope length.
- [ ] Reel the rope in or out.
- [ ] Keep momentum when detaching, with optional grapple jumping.
- [ ] Handle blocked ropes, corners, and moving anchors according to an explicit rule.
- [ ] Grapple cooldown, charges, and interactions with other movement abilities.
- [ ] Optional zipline attach, travel, speed control, and detach.

# Gliding swimming and other movement modes

- [ ] Deploy and retract a glider or hang glider.
- [ ] Tune glide forward speed, descent rate, steering, and momentum.
- [ ] Glider stall or speed limits, if part of the intended feel.
- [ ] Glider landing transition and ceiling or wall collision behavior.
- [ ] Optional parachute or slow-fall ability.
- [ ] Enter and leave water without broken state transitions.
- [ ] Surface swimming and underwater movement, including ascending and descending.
- [ ] Water drag, buoyancy, and optional currents.
- [ ] Optional underwater breath and drowning hooks.
- [ ] Optional flight, jetpack, or zero-gravity movement.
- [ ] Optional spectator or noclip movement for development.

# Camera feel and visual feedback

- [x] Mouse look with player yaw and camera pitch.
- [x] Clamp camera pitch — currently minus 85 to plus 85 degrees.
- [x] Capture the mouse when the camera is ready.
- [x] Follow the camera anchor's interpolated global transform during rendering.
- [x] Speed-driven walking head bob.
- [x] Smooth strafe lean based on lateral velocity.
- [x] Ease strafe lean back toward neutral while airborne or sliding.
- [ ] **Partial:** Return head bob to rest — it snaps back when stopping and may retain an offset when jumping or sliding.
- [ ] Exposed mouse sensitivity, separate axes, and invert-look options.
- [ ] Gamepad look sensitivity, dead zones, and response curves.
- [ ] Release and recapture the cursor for pause, menus, and focus changes.
- [ ] Adjustable base field of view and optional sprint or speed-based FOV changes.
- [ ] Jump takeoff, landing compression, and hard-landing camera feedback.
- [ ] Crouch, slide, dash, wall-run, and grapple camera transitions.
- [ ] Optional acceleration sway, impact shake, and weapon movement hooks.
- [ ] Keep the camera out of walls and ceilings during stance and traversal changes.
- [ ] Independent controls to reduce or disable bob, roll, shake, FOV shifts, and other camera motion.
- [ ] Confirm interpolation project settings and prevent duplicate interpolation; reset interpolation after teleports.

# Movement audio and feedback hooks

- [x] Request a footstep sound when the head-bob phase wraps via `player_audio.step()`.
- [x] Request a landing sound on an airborne-to-grounded transition via `player_audio.jumpland()`.
- [ ] Verify the referenced `PlayerAudio` component and sound assets — they were not included.
- [ ] Choose footstep sounds by surface, stance, and movement speed.
- [ ] Add pitch or sample variation and configurable footstep volume.
- [ ] Jump takeoff, sliding, wind, dash, grapple, and climbing audio hooks.
- [ ] Scale landing sound and feedback by actual impact speed.
- [ ] Optional controller vibration and movement feedback events for other systems.

# Reuse configuration and state management

- [ ] **Partial:** Movement state framework — an enum and two state classes exist, but state transitions and execution are not implemented.
- [ ] Define mutually exclusive movement states and legal transitions, or an equally clear alternative.
- [ ] Document interactions between abilities, including cancellation, priority, and momentum.
- [ ] Feature switches so each project can enable only the abilities it needs.
- [ ] Inspector settings or configuration Resources instead of editing constants for each project.
- [ ] Reusable player scene with documented child nodes, collision setup, and input actions.
- [ ] Decouple movement from camera effects, sound playback, weapons, and game-specific damage.
- [ ] Emit movement events such as jumped, landed, stance_changed, and slide_started.
- [ ] Input rebinding and keyboard or controller support through one movement input interface.
- [ ] Pause, death, cutscene, and respawn handling that reset transient state predictably.
- [ ] Consistent tuning across supported frame rates and physics tick rates.
- [ ] Debug display for state, velocity, floor angle, timers, and traversal casts.
- [ ] Optional save or restore of movement configuration and per-project presets.

# Movement playground and acceptance checks

- [ ] A reusable test map with flat ground, ramps, stairs, low ceilings, narrow gaps, and moving platforms.
- [ ] Measure walk, sprint, and crouch speeds in all directions, including diagonals.
- [ ] Check immediate stopping, direction reversal, and partial analog input.
- [ ] Check jumps from flat ground, slopes, moving platforms, and platform edges.
- [ ] Check coyote time just inside and outside its window and repeated jump presses after takeoff.
- [ ] Check jump buffering just before landing and after the buffer expires.
- [ ] Check crouch and slide under low ceilings and when releasing the button while obstructed.
- [ ] Check ability combinations such as slide-jump, crouch-fast-fall, wall-run-jump, and grapple-dash.
- [ ] Check low and high frame rates, multiple physics tick rates, and unusually long frames.
- [ ] Check teleports, respawns, scene changes, pause, and lost application focus.

# Issues to address first

| Area | What the current code does | Next action |
| --- | --- | --- |
| Crouch speed | `_physics_process()` assigns walk or sprint speed every tick; `_do_crouch_slide()` sets crouch speed only when entering crouch. | Derive the final target speed from the active stance every tick. |
| Crouch collision | `scale.y` scales the CharacterBody3D itself, with no test for standing clearance. | Resize the collision shape dimensions, adjust its position to keep the feet planted, and check the full standing volume. Godot advises changing shape dimensions rather than physics-body scale. |
| Stair height | `step_height` measures the distance down from the elevated ray origin to the hit point, then adds that distance to player height. On a level floor directly below a 0.7-high ray, this can produce an approximately 0.7 upward correction. | Compute the rise from the player's foot position to a valid step surface, then validate the character volume and landing surface. |
| Step down | `downstair_raycast` is initialized but never used. | Add deliberate step-down handling if the controller should follow descending stairs. |
| Coyote time | Jumping does not consume the ground-jump allowance. A second press during the remaining coyote window can reset upward velocity. | Consume the allowance after a successful jump and reset it on a valid landing. |
| Slide end | The exit check uses `velocity.dot(slide_start_velocity) < 0.7`; both direction and speed affect this value. No-input drag has no low-speed exit. | Separate direction checks, speed thresholds, and state transitions. |
| State framework | `current_state` is declared but unused. The state classes contain references and debug flags only. | Choose a clear transition model before adding abilities that can conflict. |

# Suggested implementation order

1. Correct crouch speed and collider handling, consume the jump allowance, and make slide entry and exit predictable.
2. Finish ramp and stair behavior, including stepping down, headroom checks, and camera smoothing.
3. Tune acceleration, braking, air control, jump arc, landing feedback, and camera-motion settings.
4. Package the core as a reusable player scene with configuration, movement events, and a test playground.
5. Add the optional ability most important to the next game, then define how it combines with the core.

# Script evidence

| Script | Relevant code |
| --- | --- |
| [PlayerMovement.gd](library-file:libfile_226cd24ad85c8191b56d7347c0ddf140) | `_physics_process()`, `_do_jump()`, `_do_crouch_slide()`, `_do_stairclimb()`, `_headbob()`, and `_strafe_lean()`. |
| [PlayerCamera.gd](library-file:libfile_4187556a76e881919803f28d8be6931a) | `_ready()`, `_unhandled_input()`, and `_process()`. |
| [base_state.gd](library-file:libfile_3324ac9d3b4c8191865e7edd073fdc4b) | `PlayerState` stores a controller reference; no state enter, exit, or update behavior is defined. |
| [state_machine.gd](library-file:libfile_30fc373ebf9c81919a3f1430afb2aa28) | `PlayerStateMachine` exposes debug and controller references; no state execution or transitions are defined. |

# Engine references

[Godot CharacterBody3D reference](https://docs.godotengine.org/en/stable/classes/class_characterbody3d.html) documents slope limits, floor snapping, wall and ceiling handling, and platform behavior. These engine features may already be configured in the player scene and should be checked there before treating them as missing.

[Godot physics troubleshooting](https://docs.godotengine.org/en/stable/tutorials/physics/troubleshooting_physics_issues.html) advises changing collision shape dimensions instead of scaling physics bodies or collision shapes.
