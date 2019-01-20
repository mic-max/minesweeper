%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author : Michael Maxwell
% Date : December 12th, 2012
% File Name : Minefield Sweep
% Description : Minesweeper Remake Project
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This is the screens dimensions that removes stutters.
% This lets the mouse use both left and right click buttons.
setscreen ("graphics:250,250;offscreenonly")
buttonchoose ("multibutton")

var field : array 0 .. 99 of boolean % To make mines on the 10x10 grid true or false
var cover : array 0 .. 99 of int % 0 for empty, 1 for filled, 2 for flagged
var titleFont := Font.New ("serif:20") % Font for losing,winning,replay
var font := Font.New ("serif:10") % Font for numbers in grid for mines touching
var mouseX : int % Measures where the mouse is on the grid
var mouseY : int
var mouseButton : int % So the mouse can do 2 things reveal/flag
var flagDelay : int % To prevent flickers when holding down flag button
var mode : string % gameover,win,game

% Pictures
var mine := Pic.FileNew ("mine.bmp") % Mine - don't detonate me!
var flag := Pic.FileNew ("flag.bmp") % Flag - used to mark mines

mode := "game" % plays the game

% Makes all of the true squares of grid mines and doesn't to those that are false.
proc genMap
    for i : 0 .. 99 % This is the 10x10 grid
	var b : int % Variable is for mines "b"
	randint (b, 0, 7)
	if b = 0 then
	    field (i) := true
	else
	    field (i) := false
	end if
    end for
end genMap

proc resetCover
    for i : 0 .. 99
	cover (i) := 1
    end for
end resetCover

% Put all of the mines in the grid randomly
function movemines (x, y : int) : int
    var b : int
    b := 0
    for xx : x - 1 .. x + 1
	if xx > -1 and xx < 10 then
	    for yy : y - 1 .. y + 1
		if yy > -1 and yy < 10 then
		    if field (xx + yy * 10) then
			b := b + 1
		    end if
		end if
	    end for
	end if
    end for
    result b
end movemines

% Puts a mine picture in squares that are mines/gameover
proc renderMap
    for i : 0 .. 99
	if field (i) then
	    Pic.Draw (mine, (i rem 10) * 25, (i div 10) * 25, 0)
	else
	    var b : int % This "b" represents mines everywhere
	    b := movemines (i rem 10, i div 10)
	    Font.Draw (intstr (b), (i rem 10) * 25 + 10, (i div 10) * 25 + 10, font, b)
	end if
    end for
end renderMap

% This is the actual layer of color that hides the grids contents
proc renderCover
    for i : 0 .. 99
	if cover (i) = 1 then % The layer that hides the grids contents is the cover.
	    drawfillbox ((i rem 10) * 25, (i div 10) * 25, (i rem 10) * 25 + 25, (i div 10) * 25 + 25, grey)
	elsif cover (i) = 2 then
	    Pic.Draw (flag, (i rem 10) * 25, (i div 10) * 25, 0)
	end if
    end for
end renderCover

% Keeps mines and numbers in area of play
% If you left click on x,y * 10 true then you lose
proc clear (x, y : int)
    if x > -1 and x < 10 and y > -1 and y < 10 and cover (x + y * 10) = 1 then
	cover (x + y * 10) := 0
	if field (x + y * 10) = true then
	    mode := "gameover"
	elsif movemines (x, y) = 0 then
	    for xx : x - 1 .. x + 1
		if xx > -1 and xx < 10 then
		    for yy : y - 1 .. y + 1
			if yy > -1 and yy < 10 then
			    if movemines (xx, yy) = 0 then
				clear (xx, yy)
			    elsif movemines (xx, yy) > 0 and field (xx + yy * 10) = false and cover (xx + yy * 10) not= 2 then
				cover (xx + yy * 10) := 0
			    end if
			end if
		    end for
		end if
	    end for
	end if
    end if
end clear

% This makes the picture of the button that is useable after the game mode ends(this is only the picture)
proc renderButton (title : string, x1, y1, x2, y2, col : int)
    drawfillbox (x1, y1, x2, y2, col)
    drawline (x1, y1, x2, y1, black)
    drawline (x1, y1, x1, y2, black)
    drawline (x1, y2, x2, y2, black)
    drawline (x2, y1, x2, y2, black)
    Font.Draw (title, x1 + 5, y1 + 5, titleFont, black)
end renderButton

% This resets the game like how you first started
proc resetGame
    genMap
    resetCover
    flagDelay := 0
end resetGame
resetGame

% To remove screens contents and re-load them differently1
loop
    delay (33)
    cls

    Mouse.Where (mouseX, mouseY, mouseButton) % Calculates mouse's location and if it is pressed.

    % During game they are all covered but can be revealed
    % In other modes like gameover and win this cover is removed revealing all states to user
    if mode = "game" then
	var numCovered : int % This is the on/off of a square on grid being covered by a removable layer
	numCovered := 0
	for i : 0 .. 99
	    if cover (i) not= 0 then
		numCovered := numCovered + 1
	    end if
	end for

	var nummines : int
	nummines := 0
	for i : 0 .. 99
	    if field (i) then
		nummines := nummines + 1
	    end if
	end for

	% This makes you win if the amount of covered squares is the amount of mines
	% Meaning they are all mines and none have been detonated
	% Could troll by making it numcovered = nummines + 1 then removing the block above and not showing the states of grid
	if numCovered = nummines then
	    mode := "win" % This is what happen when you win, enter win mode!
	end if

	% This makes the mouse think that a 25x25 block is normal, so it would match up with my 250x250, 10x10 grid
	if mouseX < 0 or mouseX > maxx or mouseY < 0 or mouseY > maxy then
	elsif mouseButton = 1 then
	    % Variable of 25 x & y so each 25x25 each direction x & y increase only by 1 not 25
	    var xt : int
	    var yt : int
	    xt := mouseX div 25
	    yt := mouseY div 25
	    clear (xt, yt)
	elsif mouseButton = 100 and flagDelay <= 0 then
	    % Same idea as with the left click above but with right click and putting flags with the variable being delayed slightly for flicker issues
	    var xt : int
	    var yt : int
	    % Makes not only the game become 25x25 but the mouse now knows too
	    xt := mouseX div 25
	    yt := mouseY div 25

	    % These are the reveal functions
	    if cover (xt + yt * 10) = 1 then
		cover (xt + yt * 10) := 2
	    elsif cover (xt + yt * 10) = 2 then
		cover (xt + yt * 10) := 1
	    end if

	    % More flag delays :)
	    flagDelay := 5
	end if

	% Lets you remove flags
	if flagDelay > 0 then
	    flagDelay := flagDelay - 1
	end if

	renderMap
	renderCover

	% Makes a line vertically from each multiple of 25 from the x-axis, stops at 250
	for x : 0 .. maxx div 25
	    drawline (x * 25, 0, x * 25, maxy, black)
	end for
	drawline (maxx, 0, maxx, maxy, black)

	% Makes a line horizontally from each multiple of 25 from the y-axis, stops at 250
	for y : 0 .. maxy div 25
	    drawline (0, y * 25, maxx, y * 25, black)
	end for
	drawline (0, maxy, maxx, maxy, black)

	% Gameover mode is enabled when the amount of covered mines is -1 then it began with
	% This is the restart button that you click when you win/lose to play again
    elsif mode = "gameover" then
	if mouseX > 75 and mouseX < 175 and mouseY > 50 and mouseY < 75 and mouseButton = 1 then
	    resetGame
	    mode := "game"
	    delay (165)
	end if

	renderMap

	% These are the same as above but appear only after the game is over (not only lose but win too)
	for x : 0 .. maxx div 25
	    drawline (x * 25, 0, x * 25, maxy, black)
	end for
	drawline (maxx, 0, maxx, maxy, black)
	for y : 0 .. maxy div 25
	    drawline (0, y * 25, maxx, y * 25, black)
	end for
	drawline (0, maxy, maxx, maxy, black)
	Font.Draw ("You Lost!", 10, maxy - 30, titleFont, black)

	% The action of the picture of the replay button
	renderButton ("Restart?", 75, 50, 175, 75, red)
    elsif mode = "win" then
	if mouseX > 75 and mouseX < 175 and mouseY > 50 and mouseY < 75 and mouseButton = 1 then
	    resetGame
	    mode := "game"
	    delay (165)
	end if
	renderMap

	% Draws verticle lines onto the grid if you won the game and were put in mode "win"
	for x : 0 .. maxx div 25
	    drawline (x * 25, 0, x * 25, maxy, black)
	end for
	drawline (maxx, 0, maxx, maxy, black)

	% Draws horizontal lines onto the grid if you won the game and were put in mode "win"
	for y : 0 .. maxy div 25
	    drawline (0, y * 25, maxx, y * 25, black)
	end for
	drawline (0, maxy, maxx, maxy, black)

	% This is the message for winnings color & location
	Font.Draw ("You Won!", 10, maxy - 30, titleFont, black)
	% This is the message for replaying the games color & location (inside the renderButton
	renderButton ("Restart?", 75, 50, 175, 75, red)
    end if
    View.Update
end loop

























