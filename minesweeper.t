const MINES := 10
const WIDTH := 10
const HEIGHT := 10
const SIZE := 32

var font : int := Font.New ("mono:" + intstr (SIZE div 2))
var gamemode : nat1

% single cell padding on each edge
var grid : array - 1 .. WIDTH, -1 .. HEIGHT of nat1
var mouseX, mouseY, button : int

fcn minesbeside (x, y : int) : nat1
    var mines : nat1 := 0
    for i : -1 .. 1
	mines += grid (x + 1, y + i)
	mines += grid (x - 1, y + i)
    end for
    result (mines + grid (x, y - 1) + grid (x, y + 1)) div 9
end minesbeside

fcn checkwin : boolean
    var flaggedbombs : nat1 := 0
    for y : 0 .. HEIGHT - 1
	for x : 0 .. WIDTH - 1
	    if grid (x, y) = 29 then
		flaggedbombs += 1
	    end if
	end for
    end for
    result flaggedbombs = MINES
end checkwin

proc setup
    var mines : int := MINES
    loop
	var i : int
	randint (i, 0, WIDTH * HEIGHT - 1)
	if grid (i div HEIGHT, i mod HEIGHT) not= 9 then
	    grid (i div HEIGHT, i mod HEIGHT) := 9
	    mines -= 1
	end if
	exit when mines = 0
    end loop
    for y : 0 .. HEIGHT - 1
	for x : 0 .. WIDTH - 1
	    if grid (x, y) not= 9 then
		grid (x, y) := minesbeside (x, y)
	    end if
	end for
    end for
end setup

proc draw
    cls
    for y : 0 .. HEIGHT - 1
	for x : 0 .. WIDTH - 1
	    if grid (x, y) < 10 then
		Draw.FillBox (x * SIZE, y * SIZE, x * SIZE + SIZE, y * SIZE + SIZE, grey)
	    elsif grid (x, y) = 10 then
	    elsif grid (x, y) < 20 then
		Font.Draw (intstr (grid (x, y) - 10), x * SIZE + SIZE div 3, y * SIZE + SIZE div 3, font, grid (x, y) - 10)
	    else
		Draw.FillBox (x * SIZE, y * SIZE, x * SIZE + SIZE, y * SIZE + SIZE, red)
	    end if
	end for
    end for
    for i : SIZE .. (WIDTH - 1) * SIZE by SIZE
	Draw.Line (i, 0, i, HEIGHT * SIZE, black) % could use max(x|y) but i might wanna add a stats bar
    end for
    for i : SIZE .. (HEIGHT - 1) * SIZE by SIZE
	Draw.Line (0, i, WIDTH * SIZE, i, black)
    end for
    Draw.Box (0, 0, WIDTH * SIZE - 1, HEIGHT * SIZE - 1, black)
    View.Update
end draw

proc floodfill (x, y : nat2)
    if grid (x, y) = 0 then
	grid (x, y) += 10
	if x > 0 then
	    floodfill (x - 1, y)
	    if y < HEIGHT - 1 then
		floodfill (x - 1, y + 1)
	    end if
	    if y > 0 then
		floodfill (x - 1, y - 1)
	    end if
	end if
	if x < WIDTH - 1 then
	    floodfill (x + 1, y)
	    if y > 0 then
		floodfill (x + 1, y - 1)
	    end if
	    if y < HEIGHT - 1 then
		floodfill (x + 1, y + 1)
	    end if
	end if
	if y > 0 then
	    floodfill (x, y - 1)
	end if
	if y < HEIGHT - 1 then
	    floodfill (x, y + 1)
	end if
    elsif grid (x, y) < 9 then
	grid (x, y) += 10
    end if
end floodfill

proc input
    Mouse.Where (mouseX, mouseY, button)
    if mouseX > 0 and mouseX < WIDTH * SIZE and mouseY > 0 and mouseY < HEIGHT * SIZE then
	if button = 1 then
	    if grid (mouseX div SIZE, mouseY div SIZE) = 9 then
		quit
	    else
		floodfill (mouseX div SIZE, mouseY div SIZE)
	    end if
	elsif button > 1 then
	    if grid (mouseX div SIZE, mouseY div SIZE) < 10 then
		grid (mouseX div SIZE, mouseY div SIZE) += 20
	    elsif grid (mouseX div SIZE, mouseY div SIZE) > 19 then
		grid (mouseX div SIZE, mouseY div SIZE) -= 20
	    end if
	end if
    end if
end input

View.Set ("graphics:" + intstr (WIDTH * SIZE) + ';' + intstr (HEIGHT * SIZE) + ", offscreenonly, nobuttonbar, title:Mine Sweeper")
buttonchoose ("multibutton")
setup
loop
    input
    draw
    Time.DelaySinceLast (100)
    exit when checkwin
end loop
Draw.FillBox (40, maxy div 2 - 10, 260, maxy div 2 + 32, blue)
Font.Draw ("VICTORY!", 50, maxy div 2, Font.New ("mono:32"), green)
