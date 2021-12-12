# Crossy Robbers

Hello! This is the ECE385 final project for mse6 and vragau2, using a NIOS II CPU on an FPGA to run and display a game via VGA output. 

Our project is a two player game called Crossy Robbers in which the goal is to get the most points before the timer runs out. You play as a robber that can carry up to 3 items from a blown up bank vault to your heist vehicle parked in the plaza. The items spawn as either cash or gold, with cash being worth 1 point and gold being worth 2. There's one thing standing between you and your vehicle though - up to 8 lanes of heavy traffic!

Each lane has a random number of cars, with speeds determined by the number of cars in the lane. For instance, a lane with 5 cars will have slower cars than a lane with only 2. However, your speed decreases for every item that you carry, meaning that you can either play greedily and run a higher risk of getting hit or try to make lots of smaller but faster trips back and forth. The game also supports 3 difficulty levels: **Easy** (4 lanes, low car speed), **Normal** (8 lanes, normal car speed), or **Hard** (8 lanes, high car speed). You can select the difficulty using either player's up/down keys, then confirming by pressing Continue. The button closest to the switches on the DE10-Lite is our Continue button, with the one above it being the Reset button. We output the player scores to the hex display and use the LEDs to show the time remaining in a round.

We've implemented this game entirely in hardware with the exception of the USB driver for the keyboard. Note that you may need to change the keycodes (WASD/arrows) checked by the switch cases in `software/usb_kb/main.c` since they vary from keyboard to keyboard, and that membrane keyboards may prevent you from being able to control both players due to physical limitations in their designs. A mechanical keyboard is thus very strongly advised, though even then you may have to mind the key rollover limit (should not be an issue in normal gameplay though). For instructions on how to edit your keycodes, check below.

[Demo video here!](https://drive.google.com/file/d/1G1Z4NuNsJhKlOoBdf4irFkONP2pcbKY5/view)

# Getting Started

There are two easy steps to getting started. You will need a VGA display (or VGA adapter for another kind of display), an FPGA (DE10-Lite), an IO Shield, and a USB keyboard (preferably mechanical).

## Compile and Program

Open the project in Quartus and compile the program as normal. It will take a bit under 10 minutes as we use a large number of the available logic elements. Once compiled, program the FPGA as usual. That's it!

## Software Setup

After programming the FPGA, open "Eclipse for the NIOS II" through Quartus and right-click `usb_kb_bsp` in the projects pane. Select "NIOS II" followed by "Generate BSP". This should only take a few moments, after which you should build all projects (Ctrl+B). Run the software once the projects have built, minding the outputs being printed. You may need to touch the IO Shield near where the USB port is if your console is getting spammed with keyboard states. There are two important outputs, "keycodes" and "keycode value". The first of these will show you the keycodes of what ever key you press on your keyboard. Using this, find out what the keycodes are for the player controls you would like to use (WASD and arrow keys are recommended). Now, edit  the switch cases in `usb_kb/main.c` so that it checks for the keycodes that you found, in the order of **P1 left->right->up->down** then **P2 left->right->up->down**. Finally, save the file and build all projects again. This time when you run, verify that your changes are working by checking "keycode value". When you press P1 left, the first bit should change to 1, when you press P1 right, the second bit should change to 1, and so on (following the aforementioned bolded order). If all is well, you're good to go!


# Final Notes

There were loads of things we could've improved upon, for the sake of efficiency and for the sake of a more polished result. We were of course limited by time however and thus had to make some compromises. If you're currently reading this as an ECE385 student yourself, please keep that in mind! This code is in no way perfect and there are tons of ways it could've been done better, neither of us (mse6 or vragau2) have ever done SystemVerilog before this class. Also, for those who may be curious, we generated our ROMs using a custom image parsing script I wrote in C#. That one's a bit messy too, but if you're interested then you can check the `scripts` folder for that. All of the original PNG assets we used are in there too. We had a friend help us with some of the art but the bulk of it is from here: https://emily2.itch.io/modern-city. We had intended to play music too but didn't have time to incorporate it, so instead we included the mp3 file in the project directory for anyone wanting to give it a listen. We strongly recommend that you play it in the background (on loop) while playing the game as it really adds a nice finishing touch to it! The original song can be found here, our version is just trimmed to remove the silence before and after (so that it loops): https://www.youtube.com/watch?v=hDLrim1ccuM.
