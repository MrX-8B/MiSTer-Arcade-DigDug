---------------------------------------------------------------------------------
-- 
-- Arcade: DigDug  port to MiSTer by MiSTer-X
-- 21 September 2019
-- 
---------------------------------------------------------------------------------
-- FPGA DigDug for XILINX Spartan-6
------------------------------------------------
-- Copyright (c) 2017 MiSTer-X
---------------------------------------------------------------------------------
-- T80/T80s - Version : 0242
-----------------------------
-- TV80 8-Bit Microprocessor Core
-- Based on the VHDL T80 core by Daniel Wallner (jesus@opencores.org)
--
-- Copyright (c) 2004 Guy Hutchison (ghutchis@opencores.org)
---------------------------------------------------------------------------------
-- 
-- 
-- Keyboard inputs :
--
--   F2          : Coin + Start 2 players
--   F1          : Coin + Start 1 player
--   UP,DOWN,LEFT,RIGHT arrows : Movements
--   SPACE/CTRL  : Pump
--
-- MAME/IPAC/JPAC Style Keyboard inputs:
--   5           : Coin 1
--   6           : Coin 2
--   1           : Start 1 Player
--   2           : Start 2 Players
--   R,F,D,G     : Player 2 Movements
--   A/S         : Player 2 Pump
--
--
-- Joystick support.
-- 
-- 
---------------------------------------------------------------------------------
-- 21 September 2019
---------------------------------------------------------------------------------
--   FIXED: wrong aspect ratio in "Vert" mode. 
---------------------------------------------------------------------------------
-- 22 October 2019
---------------------------------------------------------------------------------
--   FIXED: Little problem with CRT and HDMI.
-- CHANGED: Keyboard inputs.
--          Abolished rotation of control direction in Horz mode.
---------------------------------------------------------------------------------

                                *** Attention ***

ROMs are not included. In order to use this arcade, you need to provide the
correct ROMs.

To simplify the process .mra files are provided in the releases folder, that
specifies the required ROMs with checksums. The ROMs .zip filename refers to the
corresponding file of the M.A.M.E. project.

Please refer to https://github.com/MiSTer-devel/Main_MiSTer/wiki/Arcade-Roms for
information on how to setup and use the environment.

Quickreference for folders and file placement:

/_Arcade/<game name>.mra
/_Arcade/cores/<game rbf>.rbf
/_Arcade/mame/<mame rom>.zip
/_Arcade/hbmame/<hbmame rom>.zip

