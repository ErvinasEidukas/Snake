{ Written in 2020, September }
{ By: Ervinas Eidukas }
{ This program can be freely used and Modified }

{ Snake.pas }
program Game;

uses crt;

const
	DelayTime = 100;

type
	info = record
		Current_X, Current_Y: integer;
	end;

type 
	DequePnt = ^Deque;
	Deque = record
		data: info;
		next, prev: DequePnt;
	end;

type
	Snake = record
		Head: DequePnt;
		Tail: DequePnt;
	end;

type
	Map = record
		Obstacles: DequePnt;
	end;

{ Description of all possible background colors}
	{
		Black, Blue, Green, Cyan,
		Red, Magenta, Brown, LightGray
	}
{ changes color of a pixel }
procedure DrawThePixel(x_cordinate, y_cordinate, color: integer);
begin
	GotoXY(x_cordinate, y_cordinate);
	TextColor(color);
	TextBackground(color);
	write('*');
	GotoXY(1,1)
end;

{ makes terminal normal again }
procedure MakeScreen;
begin
	TextBackground(Black);
	TextColor(LightGray);
	clrscr
end;

procedure CreateDeque(var d: DequePnt);
begin
	new(d);
	d^.prev := nil;
	d^.next := nil;
end;

procedure DeleteSnake(var s: Snake);
var
	tmp: DequePnt;
begin
	if s.Head = nil then
	begin
		exit
	end;
	tmp := s.Head;
	s.Head := s.Head^.next;
	dispose(tmp);
	DeleteSnake(s);
end;

procedure NewSnake (var s: Snake; x,y: integer);
begin
	CreateDeque(s.Head);
	CreateDeque(s.Tail);
	s.Head^.data.Current_X := x;
	s.Head^.data.Current_Y := y;
	s.Tail := s.Head;
	DrawThePixel(s.Head^.data.Current_X, s.Head^.data.Current_Y, Red);	
end;

procedure NewElementOf_Snake(var s: Snake; x,y: integer);
var
	tmp: DequePnt;
begin
	CreateDeque(tmp);
	tmp^.data.Current_X := x;
	tmp^.data.Current_Y := y;
	if s.Head^.next = nil then
	begin
		tmp^.prev := s.Tail;
		s.Tail^.next := tmp;
		s.Tail := tmp;
		exit;
	end
	else
	begin
		tmp^.prev := s.Head;
		tmp^.next := s.Head^.next;
		s.Head^.next^.prev := tmp;
		s.Head^.next := tmp;
	end;
end;

procedure VanishTheSnake (s: Snake);
begin
		DrawThePixel(s.Tail^.data.Current_X, s.Tail^.data.Current_Y, Black);
end;

procedure MoveSnakeHead (var s: Snake; x, y: integer); 
var
	tmp1, tmp2: info;
	Current_Pnt: DequePnt;
begin
	if not((x = 0 ) and (y = 0)) then
	begin
		CreateDeque(Current_Pnt);
		Current_Pnt := s.Head;
		tmp1 := s.Head^.data;
		s.Head^.data.Current_X := s.Head^.data.Current_X + x;
		s.Head^.data.Current_Y := s.Head^.data.Current_Y + y;
		while not(Current_Pnt^.next = nil) do
		begin
			Current_Pnt := Current_Pnt^.next;
			tmp2 := Current_Pnt^.data;
			Current_Pnt^.data := tmp1;
			tmp1 := tmp2;
		end;
	end;
end;

procedure DrawSnake(s: Snake);
begin
	DrawThePixel(s.Head^.data.Current_X, s.Head^.data.Current_Y, Red);
	if not (s.Head^.next = nil) then
	DrawThePixel (s.Head^.next^.data.Current_X, s.Head^.next^.data.Current_Y, Cyan)
end;

procedure MoveSnake(var s: Snake; move_x, move_y: integer);
begin
	VanishTheSnake(s);
	MoveSnakeHead(s, move_x, move_y);
	DrawSnake(s); 
end;

procedure HandleArrowKey(ch: char; var move_x, move_y: integer);
begin
	case ch of
		#75: begin { left }
			if move_x = 1 then
			exit;
			move_x := -1;
			move_y := 0;
		end;
		#77: begin { right }
			if move_x = -1 then
			exit;
			move_x := 1;
			move_y := 0;
		end;
		#72: begin { up }
			if move_y = 1 then
			exit;
			move_x := 0;
			move_y := -1;
		end;
		#80: begin { down }
			if move_y = -1 then
			exit;
			move_x := 0;
			move_y := 1;
		end;
	end;
end;

procedure HandleArrowKey_SpecialCase(ch: char; var move_x, move_y: integer);
begin
	case ch of
		#75: begin { left }
			move_x := -1;
			move_y := 0;
		end;
		#77: begin { right }
			move_x := 1;
			move_y := 0;
		end;
		#72: begin { up }
			move_x := 0;
			move_y := -1;
		end;
		#80: begin { down }
			move_x := 0;
			move_y := 1;
		end;
	end;
end;

procedure DrawScore(var score: integer);
begin
	GotoXY(1,1);
	TextColor(Red);
	TextBackground(Green);
	write('Score: ');
	write(score);
end;

procedure SpawnFood(var x_cordinate, y_cordinate: integer; s: Snake);
var
	tmp: DequePnt;
	Colision: boolean;
begin
	Colision := true;
	while Colision = true do
	begin
		tmp := s.Head;
		Randomize;
		x_cordinate := random(WindMaxX - 3) + 2;
		y_cordinate := random(WindMaxY - 3) + 2;
		Colision := false;
		while not (tmp = nil) do
		begin
			if (tmp^.data.Current_X = x_cordinate) and (tmp^.data.Current_Y = y_cordinate) then
			begin
				Colision := true;
				break;
			end;
			tmp := tmp^.next;
		end;
	end;
	
	DrawThePixel(x_cordinate, y_cordinate, Magenta);
end;

procedure CheckFood(var s: Snake; var Food_x, Food_y: integer; var score: integer);
begin
	if (s.Head^.data.Current_X = Food_x) and (s.Head^.data.Current_Y = Food_y) then
	begin
		NewElementOf_Snake(s, Food_x, Food_y);
		{ procedure VanishTheSnake removes tail }
		DrawThePixel(s.Tail^.data.Current_X, s.Tail^.data.Current_Y, Cyan); 
		SpawnFood(Food_x, Food_y, s);
		score := score + 1;
		DrawScore(score);
	end;
end;

function BodyColision (s: Snake): boolean;
var
	tmp: DequePnt;
begin
	if s.Head^.next = nil then
	begin
		BodyColision := false;
		exit;
	end;
	tmp := s.Head^.next;
	while not (tmp = nil) do
	begin
		if ((tmp^.data.Current_X = s.Head^.data.Current_X) and
		(tmp^.data.Current_Y = s.Head^.data.Current_Y)) then
		begin
			BodyColision := true;
			exit;
		end;
		tmp := tmp^.next;
	end;
	BodyColision := false;
end;

function WallColision (s: Snake; m: Map): boolean;
var
	tmp: DequePnt;
begin
	tmp := m.Obstacles;
	while not (tmp^.prev = nil) do
	begin
		if ((tmp^.data.Current_X = s.Head^.data.Current_X) and
		(tmp^.data.Current_Y = s.Head^.data.Current_Y)) then
		begin
			WallColision := true;
			exit;
		end;
		tmp := tmp^.prev;
	end;
	WallColision := false;
end;

function CheckColision(s: Snake; m: Map): boolean;
begin
	CheckColision := BodyColision (s);
	if CheckColision = true then
		exit;
	CheckColision := WallColision (s, m);
end;

procedure NewElementOf_Map (var m: Map; x,y: integer);
var
	tmp: DequePnt;
begin
	CreateDeque(tmp);
	tmp^.data.Current_X := x;
	tmp^.data.Current_Y := y;
	tmp^.prev := m.Obstacles;
	m.Obstacles^.next := tmp;
	m.Obstacles := tmp;
end;

procedure DrawMap(m: Map);
var 
	tmp: DequePnt;
begin
	tmp := m.Obstacles;
	while not (tmp = nil) do
	begin
		DrawThePixel(tmp^.data.Current_X, tmp^.data.Current_Y, Green);
		tmp := tmp^.prev;
	end;
end;

procedure LineOfObstacles(var m: Map; first, last, constant: integer; constant_x: boolean);
begin
	while first <= last do
	begin
		if constant_x = false then
			NewElementOf_Map(m, first, constant)
		else
			NewElementOf_Map(m, constant, first);
		first := first + 1;
	end;
end;

procedure MapBorders(var m: Map);
begin
	LineOfObstacles(m, 1, WindMaxX, 1, false); { top }
	LineOfObstacles(m, 1, WindMaxX-1 , WindMaxY, false); { bottom } 
	LineOfObstacles(m, 1, WindMaxY , 1, true); { left }
	LineOfObstacles(m, 1, WindMaxY, WindMaxX, true); { right }
	DrawMap(m);
end;

procedure DeleteMap(var m: Map);
var
	tmp: DequePnt;
begin
	tmp := m.Obstacles;
	while not (m.Obstacles = nil) do
	begin
		m.Obstacles := m.Obstacles^.prev;
		dispose(tmp);
		tmp := m.Obstacles;
	end;
end;

{ main program }
var 
	move_x, move_y: integer;
	BlueSnake: Snake;
	ch: char;
	Food_x, Food_y: integer;
	Colision: boolean;
	MapObstacles: Map;
	score: integer;
begin
	clrscr;
	cursoroff;
	CreateDeque(MapObstacles.Obstacles);
	MapBorders(MapObstacles);
	NewSnake(BlueSnake, WindMaxX div 2, WindMaxY div 2);
	score := 0;
	move_x := 0;
	move_y := 0;
	DrawScore(score);
	Colision := false;
	SpawnFood(Food_x, Food_y, BlueSnake);
	while not (Colision) do
	begin
		if KeyPressed then
		begin
			ch := ReadKey;
			case ch of
				#0: begin
					ch := ReadKey;
					if (BlueSnake.Head^.next = nil) then
						HandleArrowKey_SpecialCase(ch,move_x,move_y)
					else
						HandleArrowKey(ch,move_x,move_y);
				end;
				{' ': begin} { stop }  { used to find bugs }
				{	move_x := 0;
					move_y := 0;
				end;}
				#27: break; { push esp to exit the program }
			end;
		end;

		if not ((move_x = 0) and (move_y = 0)) then
		begin
			MoveSnake(BlueSnake, move_x, move_y);
			Colision := CheckColision(BlueSnake, MapObstacles);
			CheckFood(BlueSnake, Food_x, Food_y, score);
			delay(DelayTime);
			continue;
		end;
	end;
	DeleteSnake(BlueSnake);
	DeleteMap(MapObstacles);
	MakeScreen;
	cursoron;
end.