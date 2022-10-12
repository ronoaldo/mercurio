Minetest 5.4 mod: PA28
========================================

The PA28

This is an implementarion to minetest of the Piper PA28. It is far from the real
plane, as it is adapted to a minetest scale and behaviour. It was inspired on
brazilian version of it, the EMB-712 Tupi.
In order to fly, it is necessary to first supply the airplane with biofuel.
Then with a bottle or gallon selected, punch it against the airplane.
You can use 10 bottles them to fill the tank. See the fuel gauge on the airplane
panel (right below, with a green F). To embark, click with the right button.
While the machine is off, it is possible to move it using the sneak and jump keys (shift an space).
W ans S controls the pitch (elevator).
Right and Left (A and D) controls the yaw (rudder and ailerons).

Then to fly, start the engine accessing the internal menu (right click). Press jump (space)
to increase the engine power (check the panel for the indicator marked with a P).
Adjust to the maximum. Pull the elevator control (S) when it have the speed to lift.

During the cruise flight, it is ideal to keep the power setting below the red range,
to control fuel consumption. Use the climb indicator to stabilize altitude,
as at high altitudes you lose sustentation and you spend more fuel.

The altimeter was adapted too for a minetest range, so instead an altimeter divided by
1000 feets, it is divided in 100ft only

For landing, just lower the power and stabilize the airplane. Pay attention at air speed
indicator, keeping it at green range, otherwise you will stall. It is recommended to use
the flap during landing, but it should only be engaged when the speed is at the initial
limit of the green range, as it will automatically retract if the speed exceeds too much.

Care must be taken with impacts, as it causes damage to the aircraft and the pilot, 
so training landings is essential. 

To brake the aircraft, use the sneak (shift) key until it comes to a complete stop.
Do not stop the engine before this, or it will reverse when it stops 

To repair damages, you can use the repair tool. It subtracts steel ingots to increase
airplane hp.

It can be painted using dye of any color you want, you must punch the airplane with the dye.
It is possible to paint it using the automobiles or the bike painter if it is installed

You can use biofuel mod made by Lokrates, but here I have another biofuel mod:
https://github.com/APercy/minetest_biofuel

The limitations: because the lack in functions to roll the camera, and the rudder acting together the ailerons,
the airplane is unable to do a tuneau, barrel roll, loopings and any kind of aerobatics maneuvers. 

**Controls overview:**
* Right click: enter in/get off plane
* Left click (with biofuel): add fuel to plane
* Right click and Sneak: enter in flight instructor mode (limited vision, so use debug info)
* Aux1 + Sneak: flaps
* Jump: Increase power, forward on ground
* Sneak: Decrease power, brake on ground
* Backward: go up flying - nose up
* Forward: go down flying - nose down
* Left/right: Turn to left/right, work on and out ground.
* Left + Right: center all commands
* Sneak + Jump: autopilot
* Aux1 + Jump: pass the control to copilot 
* Up + Down: enable/disable HUD

**Chat Commands: **

/pa28_eject - ejects from the vehicle

/pa28_manual - shows the manual

-----------------------
License of source code:
LGPL v3 (see file LICENSE) 

License of media (textures and sounds):
CC0


