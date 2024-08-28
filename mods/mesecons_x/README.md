mesecons_x by marek


Adds some new elements to Mesecons mod, to make it easier to build more complex circuits.


[Youtube](https://www.youtube.com/channel/UCohaNk7q3MfTdl5LwiTjB5Q)

[Discord](https://discord.gg/eGHkdQj)

![picture](https://gitlab.com/deetmit/mesecons_x/-/raw/master/picture.png)


New elements:

**Tools.**
- black tool

    Creates wires automaticaly by selectin starting position (left click) and ending position (right click). 
    You can keep clicking right, to continue the wire. The wire will automaticaly bend and go over other wires
    if possible. Click on other wire to connect to the existing wire.

    If you select more than one block, then multiple wires will be created. If you select existing circuit, the 
    wires will be automatically connected to the existing blocks.

- red tool

    Removes wires automaticaly. Left click is simple puch. Right click removes the entire wire
    to the next junction. 

    If you click on a junction, it will delete all wires that goes out of the junction.
    If you click on a gate, it will remove the gate and all adjacent (=connected) wires.

    If you click right on the air, it will remove the selected area.
    If you click right on a wire withing selection, it will remove the selection and all wires that are going out from the selection.

- blue tool

    Selects the area. Left click selects pos1, right click selects pos2.
    Left click on air uses the position of the player.

- yellow tool

    Allows you to move circuit, or part of the circuit without disconnecting wires.
    Left click moves to the left, right click moves to the right. You must face proper direction.
    Use blue tool to select region.

    IF you use up/down yellow tool, left always mean down, right click always means up.

- orange tool

    Stacks the selected circuit. You can "undo" the stacking by clicking left mouse. Note, if you change the selection, "undo" is 
    not possible.

- white tool

    Changes selection borders. Right click always means expand, left click always means contract. 
    

- circuit (blue book)

    Allows you to store your circuit, and paste it in other places. 
    Left click on air saves the circuit (selecion must be active).
    Left click on block creates selection of the circuit.
    Right click paste the circuit.

**Other elements.**
- 3 input logic gates: and, or, nand, nor
- latch and flipflop
- insulated xjunction

**Example**
This circuit was built in 60 seconds using circuit books. 

![4bit](https://gitlab.com/deetmit/mesecons_x/-/raw/master/picture_4bit_incrementer.png)




TODO list:
- copy metadata while moving blocks
- add page and book to keep multiple circuits in one place
- improve algorithm for autoconnection of the wires when the circuit is moved
- load nodes before reading

