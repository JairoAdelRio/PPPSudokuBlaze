
--[[
* Sudoku Generator
* v0.2
*
* Copyright (c) 2010, David J. Rager
* All rights reserved.
* 
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met: 
* 
*     * Redistributions of source code must retain the above copyright notice,
*       this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above copyright
*       notice, this list of conditions and the following disclaimer in the
*       documentation and/or other materials provided with the distribution.
*     * Neither the name of Fourth Woods Media nor the names of its
*       contributors may be used to endorse or promote products derived from
*       this software without specific prior written permission.
* 
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
* AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
* IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
* FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
* DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
* SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
* CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
* OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
* OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*
* This is a sudoku puzzle generator and solver. This program provides two
* generation algorithms, a solver and methods to update and check the state of
* the puzzle. This program does not provide any user interface controls.
*
* To create a new puzzle just instantiate the Sudoku object:
*
* var thePuzzle = new Sudoku();
*
* The puzzle is represented as a 9x9 matrix of numbers 0-9. A cell value of zero
* indicates a cell that has been masked from view for the user to discover. A
* user interface should display all the non-zero values to the user and blank
* cells for any cell containing a zero.
*
* The puzzle uses either a simple shuffle algorithm or the backtracking solver
* (the default) to create the puzzle.
*
* To start a new game call:
*
* thePuzzle.newGame();
*
* This class includes a solver that will solve the sudoku using a backtracking
* algorithm. To solve the puzzle call the solve() method:
*
* thePuzzle.solve();
*
* If there is more than one solution to the sudoku puzzle, the solver will show
* only one of them at random. The solver does not know if there is more than one
* solution.
*
* The enumSolutions() method is a modified version of the solver that will count
* all possible solutions for 
*
* Have fun. Send any comments, bugs, contribs to rageratwork@gmail.com
]]

-- The Array class doesn't have a contains() method. We create one to make the
-- code cleaner and more readable.
-- Note, it seems that the decreasing while loop is the fastest way to iterate
-- over a collection in javascript:
-- http:--blogs.sun.com/greimer/entry/best_way_to_code_a
--
-- This method takes one parameter:
-- 	obj - the object to search for in the array. the object must be of the
-- 	      same type as the objects stored in the array.

local matrix = require ("Matrix")
-- The Sudoku class stores the matrix array and implements the game logic.
-- Instantiation of this class will automatically generate a new puzzle.

local Sudoku = {}

function Sudoku.Create( matrix )
	-- 'private' methods...	sudoku = {}		setmetatable( sudoku, Sudoku )	
	-- stores the 9x9 game data. the puzzle data is stored with revealed
	-- numbers as 1-9 and hidden numbers for the user to discover as zeros.
	sudoku.matrix = Matrix.Create( 81 )

	-- initial puzzle is all zeros.
	sudoku.matrix:clear()

	-- stores the difficulty level of the puzzle 0 is easiest.
	sudoku.level = 0		return sudoku 
end

--[[this method initializes the sudoku puzzle beginning with a root
	solution and randomly shuffling rows, columns and values. the result
	of this method will be a completely solved sudoku board. the shuffle
	is similar to that used by the sudoku puzzle at:
	
	http:--www.dhtmlgoodies.com/scripts/game_sudoku/game_sudoku.html
	this method takes one parameter:
	matrix - the 9x9 array to store the puzzle data. the array	
	contents will be overwritten by this method.]]
function Sudoku:shuffle( matrix ) 
		-- create the root sudoku solution. this produces the following
		-- sudoku:
		--
		-- 1 2 3 | 4 5 6 | 7 8 9
		-- 4 5 6 | 7 8 9 | 1 2 3
		-- 7 8 9 | 1 2 3 | 4 5 6
		-- ---------------------
		-- 2 3 4 | 5 6 7 | 8 9 1
		-- 5 6 7 | 8 9 1 | 2 3 4
		-- 8 9 1 | 2 3 4 | 5 6 7
		-- ---------------------
		-- 3 4 5 | 6 7 8 | 9 1 2
		-- 6 7 8 | 9 1 2 | 3 4 5
		-- 9 1 2 | 3 4 5 | 6 7 8
		for i = 1, 9, 1 do			
			for j = 1, 9, 1 do
				matrix[i * 9 + j] = (i*3 + Math.floor(i/3) + j) % 9 + 1;
			end
			
		-- randomly shuffle the numbers in the root sudoku. pick two
		-- numbers n1 and n2 at random. scan the board and for each
		-- occurence of n1, replace it with n2 and vice-versa. repeat
		-- several times. we pick 42 to make Douglas Adams happy.
		for i = 1, 42, 1 do
			var n1 = Math.ceil(Math.random() * 9);
			var n2;
			do
				n2 = Math.ceil(Math.random() * 9);

			while n1 == n2

			for row = 1, 9, 1 do
				for col = 1, 9, 1 do
					if matrix[row * 9 + col] == n1 then
						matrix[row * 9 + col] = n2;
					elseif(matrix[row * 9 + col] == n2) then
						matrix[row * 9 + col] = n1;
					end
				end
			end

		-- randomly swap corresponding columns from each column of
		-- subsquares
		--
		--   |       |       |
		--   |       |       |
		--   V       V       V
		-- . . . | . . . | . . .
		-- . . . | . . . | . . .
		-- . . . | . . . | . . .
		------------------------
		-- . . . | . . . | . . .
		-- . . . | . . . | . . .
		-- . . . | . . . | . . .
		------------------------
		-- . . . | . . . | . . .
		-- . . . | . . . | . . .
		-- . . . | . . . | . . .
		--
		-- note that we cannot swap corresponding rows from each row of
		-- subsquares.
		for c = 1, 42, 1 do 
			var s1 = Math.floor(Math.random() * 3);
			var s2 = Math.floor(Math.random() * 3);

			for row = 1, 9, 1 do
				var tmp = this.matrix[row * 9 + (s1 * 3 + c % 3)];
				this.matrix[row * 9 + (s1 * 3 + c % 3)] = this.matrix[row * 9 + (s2 * 3 + c % 3)];
				this.matrix[row * 9 + (s2 * 3 + c % 3)] = tmp;
			end
		end

		-- randomly swap columns within each column of subsquares
		--
		--         | | |
		--         | | |
		--         V V V
		-- . . . | . . . | . . .
		-- . . . | . . . | . . .
		-- . . . | . . . | . . .
		------------------------
		-- . . . | . . . | . . .
		-- . . . | . . . | . . .
		-- . . . | . . . | . . .
		------------------------
		-- . . . | . . . | . . .
		-- . . . | . . . | . . .
		-- . . . | . . . | . . .
		for s = 1, 42, 1 do
			local c1 = Math.floor(Math.random() * 3)
			local c2 = Math.floor(Math.random() * 3)

			for row = 1, 9, 1 do
				local tmp = this.matrix[row * 9 + (s % 3 * 3 + c1)];
				this.matrix[row * 9 + (s % 3 * 3 + c1)] = this.matrix[row * 9 + (s % 3 * 3 + c2)];
				this.matrix[row * 9 + (s % 3 * 3 + c2)] = tmp;
			end
		end

		-- randomly swap rows within each row of subsquares
		--
		-- . . . | . . . | . . .
		-- . . . | . . . | . . .
		-- . . . | . . . | . . .
		------------------------
		-- . . . | . . . | . . . <---
		-- . . . | . . . | . . . <---
		-- . . . | . . . | . . . <---
		------------------------
		-- . . . | . . . | . . .
		-- . . . | . . . | . . .
		-- . . . | . . . | . . .
		for s = 1, 42, 1 do
			local r1 = Math.floor(Math.random() * 3);
			local r2 = Math.floor(Math.random() * 3);

			for col = 1, 9, 1 do
				var tmp = this.matrix[(s % 3 * 3 + r1) * 9 + col];
				this.matrix[(s % 3 * 3 + r1) * 9 + col] = this.matrix[(s % 3 * 3 + r2) * 9 + col];
				this.matrix[(s % 3 * 3 + r2) * 9 + col] = tmp;
			end
		end

		-- we could also randomly swap rows and columns of subsquares
		--
		--   |       |       |
		--   |       |       |
		-- /---\   /---\   /---\
		-- . . . | . . . | . . .  \
		-- . . . | . . . | . . .  | <---
		-- . . . | . . . | . . .  /
		------------------------
		-- . . . | . . . | . . .  \
		-- . . . | . . . | . . .  | <---
		-- . . . | . . . | . . .  /
		------------------------
		-- . . . | . . . | . . .  \
		-- . . . | . . . | . . .  | <---
		-- . . . | . . . | . . .  /
		--
		-- we could also rotate the board 90, 180 or 270 degrees and
		-- mirror left to right and/or top to bottom.
	end

	-- this method randomly masks values in a solved sudoku board. for the
	-- easiest level it will hide 5 cells from each 3x3 subsquare.
	--
	-- this method makes no attempt to ensure a unique solution and simply
	-- (naively) just masks random values. usually there will be only one
	-- solution however, there may be two or more. i've seen boards with as
	-- many as 6 or 7 solutions using this function, though that is pretty
	-- rare.
	--
	-- this method takes two parameters:
	-- 	matrix - the game array completely initialized with the game
	-- 		 data.
	-- 	mask - an array to store the 9x9 mask data. the mask array will
	-- 	       contain the board that will be presented to the user.
function Sudoku:maskBoardEasy (matrix, mask) 
	local i	local j	local k	
	for i = 1, 81, 1 do
		mask[i] = matrix[i];
		
		for i = 1, 3, 1 do
			for j = 1, 3, 1 do
				-- for each 3x3 subsquare, pick 5 random cells
				-- and mask them.
				for k = 1, 5, 1 do
					local c
										repeat
						c = Math.floor(Math.random() * 9)
					until mask[(i * 3 + Math.floor(c / 3)) * 9 + j * 3 + c % 3] != 0
			
					mask[(i * 3 + Math.floor(c / 3)) * 9 + j * 3 + c % 3] = 0;
				end
			end
		end
	end
end
--[[this method scans all three zones that contains the specified cell
-- and populates an array with values that have not already been used in
-- one of the zones. the order of the values in the array are randomized
-- so the solver may simply iterate linearly through the array to try
-- the values in a random order rather than sequentially.
--
-- this method takes three parameters:
-- 	matrix - the array containing the current state of the puzzle.
-- 	cell - the cell for which to retrieve available values.
-- 	avail - the array to receive the available values. if this
-- 		parameter is null, this method simply counts the number
-- 		of available values without returning them.
--
-- this method returns the length of the data in the available array.]]
function Sudoku:getAvailable( matrix, cell, avail )
	local i	local j	local row	local col	local r	local c
	local arr = {}
	row = Math.floor(cell / 9);
	col = cell % 9;

	-- row
	for i = 1, 9, 1 do
		j = row * 9 + i;			
		if(this.matrix[j] > 0)
			arr[this.matrix[j] - 1] = 1;		end
	end

	-- col
	for i = 1, 9 , 1 do
	
		j = i * 9 + col;
		if(matrix[j] > 0)
			arr[this.matrix[j] - 1] = 1
		end
	end

	-- square
	r = row - row % 3
	c = col - col % 3	
	for i = r, i < r + 3, 1 do
		for j = c,  j < c + 3, 1 do
			if matrix[i * 9 + j] > 0
				arr[matrix[i * 9 + j] - 1] = 1
			end				
			j = 0;
				if avail != null 		
					for i = 1, 9, 1 do
				if(arr[i] == 0)
					avail[j++] = i + 1;				end
			else
				for i = 1, 9, 1 do
					if arr[i] == 0
						j++;					end
										return j;
				end
			end			end		end		
	if(j == 0)
		return 0;
	end		
	for(i = 0; i < 18; i++)
	
		r = Math.floor(Math.random() * j);
		c = Math.floor(Math.random() * j);
		row = avail[r];
		avail[r] = avail[c];
		avail[c] = row;
	end

	return j;
end

--[[ this method is used by the solver to find the next cell to be filled.
-- the cell is chosen by finding a cell with the least amount of
-- available values to try.
--
-- this method takes one parameter:
-- 	matrix - the array containing the current state of the puzzle.
--
-- this method returns the next cell, or -1 if there are no cells left
-- to choose.]]
function Sudoku:getCell (matrix)
	
		var cell = -1, n = 10, i, j;
		var avail = new Array(9);
		avail.clear();

		for(i = 0; i < 81; i++)
		
			if(matrix[i] == 0)
			
				j = this.getAvailable(matrix, i, null);

				if(j < n)
				
					n = j;
					cell = i;
				end

				if (n == 1)
					break;
			end
		end

		return cell;
	end

--[[this is the actual solver. it implements a backtracking algorithm in
-- which it randomly selects numbers to try in each cell. it starts
-- with the first cell and picks a random number. if the number works in
-- the cell, it recursively chooses the next cell and starts again. if
-- all the numbers for a cell have been tried and none work, a number
-- chosen for a previous cell cannot be part of the solution so we have
-- to back up to the last cell and choose another number. if all the
-- numbers for that cell have also been tried, we back up again. this
-- continues until a value is chosen for all 81 cells.
--
-- this method takes one parameter:
-- 	matrix - the array containing the current state of the puzzle.
--
-- this method returns 1 if a solution has been found or 0 if there was
-- not a solution.]]
function Sudoku:solve(matrix)
	
		var i, j, ret = 0;
		var cell = this.getCell(matrix);

		-- since this is the solver that is following the sudoku rules,
		-- if getCell returns -1 we are guaranteed to have found a valid
		-- solution. in this case we just return 1 (for 1 solution, see
		-- enumSolutions for more information).
		if(cell == -1)
			return 1;

		var avail = new Array(9);
		avail.clear();

		j = this.getAvailable(matrix, cell, avail);
		for(i = 0; i < j; i++)
		
			matrix[cell] = avail[i];

			-- if we found a solution, return 1 to the caller.
			if(this.solve(matrix) == 1)
				return 1;

			-- if we haven't found a solution yet, try the next
			-- value in the available array.
		end

		-- we've tried all the values in the available array without
		-- finding a solution. reset the cell value back to zero and
		-- return zero to the caller.
		matrix[cell] = 0;
		return 0;
	end

--[[this method counts the number of possible solutions for a given
-- puzzle. this uses the same algorithm as the solver but tries all
-- the available values for all the cells incrementing a count every
-- time a new solution is found. this method is used by the mask
-- function to ensure there is only one solution to the puzzle.
--
-- this method performs well for a puzzle with 20 or so hints. do not
-- try this function on a blank puzzle (zero hints). there is not enough
-- time remaining in the physical universe to enumerate all the possible
-- sudoku boards. when this method returns, the puzzle passed in is
-- restored to its original state.
--
-- this method takes one parameter:
-- 	matrix - the array containing the current state of the puzzle.
--
-- this method returns the number of solutions found or 0 if there was
-- not a solution.]]
function Sudoku:enumSolutions(matrix)
	
		var i, j, ret = 0;
		var cell = this.getCell(matrix);

		-- if getCell returns -1 the board is completely filled which
		-- means we found a solution. return 1 for this solution.
		if cell == -1 then
			return 1;
		end		
		var avail = new Array(9);
		avail.clear();

		j = this.getAvailable(matrix, cell, avail);
		for i = 1, i < j, 1 do
		
			-- we try each available value in the array and count
			-- how many solutions are produced.
			this.matrix[cell] = avail[i];

			ret += this.enumSolutions(matrix);

			-- for the purposes of the mask function, if we found
			-- more than one solution, we can quit searching now
			-- so the mask algorithm can try a different value.
			if ret > 1 then
				break;
			end
		end		
		this.matrix[cell] = 0;		
		return ret;
	end

--[[this method generates a minimal sudoku puzzle. minimal means that no
-- remaining hints on the board may be removed and still generate a
-- unique solution. when this method returns the resulting puzzle will
-- contain about 20 to 25 hints that describe a puzzle with only one
-- solution.
--
-- this method takes two parameters:
-- 	matrix - the game array completely initialized with the game
-- 		 data.
-- 	mask - an array to store the 9x9 mask data. the mask array will
-- 	       contain the board that will be presented to the user. ]]
function Sudoku:maskBoard(matrix, mask)
	
		var i, j, k, r, c, n = 0, a, hints = 0, cell, val;
		var avail = new Array(9);
		avail.clear();

		var tried = new Array(81);
		tried.clear();

		-- start with a cleared out board
		mask.clear();

		-- randomly add values from the solved board to the masked
		-- board, picking only cells that cannot be deduced by existing
		-- values in the masked board.
		--
		-- the following rules are used to determine the cells to
		-- populate:
		-- 1. based on the three zones to which the cell belongs, if
		-- more than one value can go in the cell (i.e. the selected
		-- cell value and at least one other value), check rule two.
		-- 2. for each zone, if the selected value could go in another
		-- free cell in the zone then the cell may be selected as a
		-- hint. this rule must be satisfied by all three zones.
		--
		-- both rules must pass for a cell to be selected. once all 81
		-- cells have been checked, the masked board will represent a
		-- puzzle with a single solution.
		do
		
			-- choose a cell at random.
			do
			
				cell = Math.floor(Math.random() * 81);
			end
			while((mask[cell] != 0) || (tried[cell] != 0));
			val = matrix[cell];

			-- see how many values can go in the cell.
			i = this.getAvailable(mask, cell, null);

			if(i > 1)
			
				-- two or more values can go in the cell based
				-- on values used in each zone.
				--
				-- check each zone and make sure the selected
				-- value can also be used in at least one other
				-- cell in the zone.
				var cnt, row = Math.floor(cell / 9), col = cell % 9;

				cnt = 0; -- count the cells in which the value
					 -- may be used.

				-- look at each cell in the same row as the
				-- selected cell.
				for(i = 0; i < 9; i++)
					
					-- don't bother looking at the selected
					-- cell. we already know the value will
					-- work.
					if(i == col)
						continue;

					j = row * 9 + i; -- j stores the cell index

					-- if the value is already filled, skip
					-- to the next.
					if(mask[j] > 0)
						continue;

					-- get the values that can be used in
					-- the cell.
					a = this.getAvailable(mask, j, avail);

					-- see if our value is in the available
					-- value list.
					for(j = 0; j < a; j++)
					
						if(avail[j] == val)
						
							cnt++;
							break;
						end
						avail[j] = 0;
					end
				end

				-- if the count is greater than zero, the
				-- selected value could also be used in another
				-- cell in that zone. we repeat the process with
				-- the other two zones.
				if(cnt > 0)
				
					-- col
					cnt = 0;
					for(i = 0; i < 9; i++)
					
						if(i == row)
							continue;

						j = i * 9 + col;
						if(mask[j] > 0)
							continue;
						a = this.getAvailable(mask, j, avail);
						for(j = 0; j < a; j++)
						
							if(avail[j] == val)
							
								cnt++;
								break;
							end
							avail[j] = 0;
						end
					end

					-- if the count is greater than zero,
					-- the selected value could also be used
					-- in another cell in that zone. we
					-- repeat the process with the last
					-- zone.
					if(cnt > 0)
					
						-- square
						cnt = 0;
						r = row - row % 3;
						c = col - col % 3;
						for(i = r; i < r + 3; i++)
						
							for(j = c; j < c + 3; j++)
							
								if((i == row) && (j == col))
									continue;
	
								k = i * 9 + j;
								if(mask[k] > 0)
									continue;
								a = this.getAvailable(mask, k, avail);
								for(k = 0; k < a; k++)
								
									if(avail[k] == val)
									
										cnt++;
										break;
									end
									avail[k] = 0;
								end
							end
						end

						if(cnt > 0)
						
							mask[cell] = val;
							hints++;
						end
					end
				end
			end

			tried[cell] = 1;
			n++;
		end
		while(n < 81);

		-- at this point we should have a masked board with about 40 to
		-- 50 hints. randomly select hints and remove them. for each
		-- removed hint, see if there is still a single solution. if so,
		-- select another hint and repeat. if not, replace the hint and
		-- try another.
		do
		
			do
			
				cell = Math.floor(Math.random() * 81);
			end
			while((mask[cell] == 0) || (tried[cell] == 0));

			val = mask[cell];

			var t = this;
			var solutions = 0;

			mask[cell] = 0;
			solutions = this.enumSolutions(mask);

			if(solutions > 1)
				mask[cell] = val;

			tried[cell] = 0;
			hints--;
		end
		while(hints > 0);

		-- at this point we have a board with about 20 to 25 hints and a
		-- single solution.
	end


--[[this method checks whether a value will work in a given cell. it
-- checks each zone to ensure the value is not already used.
--
-- this method takes three parameters:
-- 	row - the row of the cell
-- 	col - the column of the cell
-- 	val - the value to try in the cell
--
-- this method returns true if the value can be used in the cell, false
-- otherwise.]]
function Sudoku:_checkVal(matrix, row, col, val) 
		local i		local j		local r		local c		
		-- check each cell in the row to see if the value already
		-- exists in the row. do not look at the value of the cell in
		-- the column we are trying. repeat for each zone.
		for i = 1, 9, 1 do
			if((i != col) && (matrix[row * 9 + i] == val)) then
				return false;			end
		end

		-- check col
		for i = 1, 9, 1 do
		
			if((i != row) && (matrix[i * 9 + col] == val)) then
				return false;
			end
		end		
		-- check square
		r = row - row % 3;
		c = col - col % 3;		
		for i = r, i < r + 3,  1 do
			for j = c,  j < c + 3,  1 do
				if (((i != row) || (j != col)) && (matrix[i * 9 + j] == val)) then
					return false;
				end			end		end		
		return true;
	end

	-- 'public' methods

--[[this method checks whether a value will work in a given cell. it
-- checks each zone to ensure the value is not already used.
--
-- this method takes three parameters:
-- 	row - the row of the cell
-- 	col - the column of the cell
-- 	val - the value to try in the cell
--
-- this method returns true if the value can be used in the cell, false
-- otherwise.]]
function Sudoku:checkVal(row, col, val)
	return this._checkVal(this.matrix, row, col, val);
end

--[[ this method sets the value for a particular cell. this is called by
-- the user interface when the user enters a value.
--
-- this method takes three parameters:
-- 	row - the row of the cell
-- 	col - the column of the cell
-- 	val - the value to enter in the cell]]
function Sudoku:setVal(row, col, val)
	this.matrix[row * 9 + col] = val;
end

--[[this method gets the value for a particular cell. this is called by
-- the user interface for displaying the contents of a cell.
--
-- this method takes two parameters:
-- 	row - the row of the cell
-- 	col - the column of the cell
--
-- this method returns the value of the cell at the specified location.]]
function Sudoku:getVal(row, col)
	return this.matrix[row * 9 + col];
end

	-- this method initializes a new game using the solver to generate the
	-- board.
function Sudoku:_newGame() 
		var i, hints = 0;
		var mask = new Array(81);

		-- clear out the game matrix.
		this.matrix.clear();

		-- call the solver on a completely empty matrix. this will
		-- generate random values for cells resulting in a solved board.
		this.solve(this.matrix);

		-- generate hints for the solved board. if the level is easy,
		-- use the easy mask function.
		if(this.level == 0)
		
			this.maskBoardEasy(this.matrix, mask);
		end
		else
		
			-- the level is medium or greater. use the advanced mask
			-- function to generate a minimal sudoku puzzle with a
			-- single solution.
			this.maskBoard(this.matrix, mask);

			-- if the level is medium, randomly add 4 extra hints.
			if(this.level == 1)
			
				for(i = 0; i < 4; i++)
				
					do
					
						var cell = Math.floor(Math.random() * 81);
					end
					while(mask[cell] != 0);

					mask[cell] = this.matrix[cell];
				end
			end
		end

		-- save the solved matrix.
		this.save = this.matrix;

		-- set the masked matrix as the puzzle.
		this.matrix = mask;

		timeDiff.start();
	end

	--this.done;

function Sudoku:_doHints(matrix, mask, tried, hints)
	
		-- at this point we should have a masked board with about 40 to
		-- 50 hints. randomly select hints and remove them. for each
		-- removed hint, see if there is still a single solution. if so,
		-- select another hint and repeat. if not, replace the hint and
		-- try another.
		if(hints > 0)
			do
				cell = Math.floor(Math.random() * 81);
			while((mask[cell] == 0) || (tried[cell] == 0));

			val = mask[cell];

			var t = this;
			var solutions = 0;

			mask[cell] = 0;
			solutions = this.enumSolutions(mask);
			--console.log("timeout");

			if(solutions > 1)
				mask[cell] = val;

			tried[cell] = 0;
			hints--;
			var t = this;
			setTimeout(function()t._doHints(matrix, mask, tried, hints);end, 50);
		end
		else
		
			this.save = this.matrix;
			this.matrix = mask;
			this.done();
		end

		--console.log(hints);

		-- at this point we have a board with about 20 to 25 hints and a
		-- single solution.
	end

function Sudoku:_doMask(matrix, mask)
	
		var i, j, k, r, c, n = 0, a, hints = 0, cell, val;
		var avail = new Array(9);
		avail.clear();

		var tried = new Array(81);
		tried.clear();

		-- start with a cleared out board
		mask.clear();

		-- randomly add values from the solved board to the masked
		-- board, picking only cells that cannot be deduced by existing
		-- values in the masked board.
		--
		-- the following rules are used to determine the cells to
		-- populate:
		-- 1. based on the three zones to which the cell belongs, if
		-- more than one value can go in the cell (i.e. the selected
		-- cell value and at least one other value), check rule two.
		-- 2. for each zone, if the selected value could go in another
		-- free cell in the zone then the cell may be selected as a
		-- hint. this rule must be satisfied by all three zones.
		--
		-- both rules must pass for a cell to be selected. once all 81
		-- cells have been checked, the masked board will represent a
		-- puzzle with a single solution.
		do
		
			-- choose a cell at random.
			do
			
				cell = Math.floor(Math.random() * 81);
			end
			while((mask[cell] != 0) || (tried[cell] != 0));
			val = matrix[cell];

			-- see how many values can go in the cell.
			i = this.getAvailable(mask, cell, null);

			if(i > 1)
			
				-- two or more values can go in the cell based
				-- on values used in each zone.
				--
				-- check each zone and make sure the selected
				-- value can also be used in at least one other
				-- cell in the zone.
				var cnt, row = Math.floor(cell / 9), col = cell % 9;

				cnt = 0; -- count the cells in which the value
					 -- may be used.

				-- look at each cell in the same row as the
				-- selected cell.
				for(i = 0; i < 9; i++)
					
					-- don't bother looking at the selected
					-- cell. we already know the value will
					-- work.
					if(i == col)
						continue;

					j = row * 9 + i; -- j stores the cell index

					-- if the value is already filled, skip
					-- to the next.
					if(mask[j] > 0)
						continue;

					-- get the values that can be used in
					-- the cell.
					a = this.getAvailable(mask, j, avail);

					-- see if our value is in the available
					-- value list.
					for(j = 0; j < a; j++)
					
						if(avail[j] == val)
						
							cnt++;
							break;
						end
						avail[j] = 0;
					end
				end

				-- if the count is greater than zero, the
				-- selected value could also be used in another
				-- cell in that zone. we repeat the process with
				-- the other two zones.
				if(cnt > 0)
				
					-- col
					cnt = 0;
					for(i = 0; i < 9; i++)
					
						if(i == row)
							continue;

						j = i * 9 + col;
						if(mask[j] > 0)
							continue;
						a = this.getAvailable(mask, j, avail);
						for(j = 0; j < a; j++)
						
							if(avail[j] == val)
							
								cnt++;
								break;
							end
							avail[j] = 0;
						end
					end

					-- if the count is greater than zero,
					-- the selected value could also be used
					-- in another cell in that zone. we
					-- repeat the process with the last
					-- zone.
					if(cnt > 0)
					
						-- square
						cnt = 0;
						r = row - row % 3;
						c = col - col % 3;
						for(i = r; i < r + 3; i++)
						
							for(j = c; j < c + 3; j++)
							
								if((i == row) && (j == col))
									continue;
	
								k = i * 9 + j;
								if(mask[k] > 0)
									continue;
								a = this.getAvailable(mask, k, avail);
								for(k = 0; k < a; k++)
								
									if(avail[k] == val)
									
										cnt++;
										break;
									end
									avail[k] = 0;
								end
							end
						end

						if(cnt > 0)
						
							mask[cell] = val;
							hints++;
						end
					end
				end
			end

			tried[cell] = 1;
			n++;
		end
		while(n < 81);

		var t = this;
		setTimeout(function()t._doHints(matrix, mask, tried, hints);end, 50);
	end

function Sudoku:newGame() 
		var i, hints = 0;
		var mask = new Array(81);

		-- clear out the game matrix.
		this.matrix.clear();

		-- call the solver on a completely empty matrix. this will
		-- generate random values for cells resulting in a solved board.
		this.solve(this.matrix);

		-- generate hints for the solved board. if the level is easy,
		-- use the easy mask function.
		if(this.level == 0)
		
			this.maskBoardEasy(this.matrix, mask);

			-- save the solved matrix.
			this.save = this.matrix;

			-- set the masked matrix as the puzzle.
			this.matrix = mask;

			timeDiff.start();
			this.done();
		else
		
			-- the level is medium or greater. use the advanced mask
			-- function to generate a minimal sudoku puzzle with a
			-- single solution.
			this._doMask(this.matrix, mask);

			-- if the level is medium, randomly add 4 extra hints.
			if(this.level == 1)
			
				for(i = 0; i < 4; i++)
				
					do
					
						var cell = Math.floor(Math.random() * 81);
					while(mask[cell] != 0);

					mask[cell] = this.matrix[cell];
				end
			end
		end
	end

-- this method solves the current game by restoring the solved matrix.
-- if the original unmodified masked matrix was saved, this function
-- could call the solve method which would undo any wrong player guesses
-- and actually solve the game.
function Sudoku:solveGame() 
		this.matrix = this.save;
	end

-- this method determines wether or not the game has been completed. it
-- looks at each cell and determines whether or not a value has been
-- entered. if not, the game is not done. if a value has been entered,
-- it calls checkVal() to make sure the value does not violate the
-- sudoku rules. if both checks are passed for each cell in the board
-- the game is complete.
function Sudoku:gameFinished()
	
		for(var i = 0; i < 9; i++)
			for(var j = 0; j < 9; j++)
				var val = this.matrix[i * 9 + j];
				if((val == 0) || (this._checkVal(this.matrix, i, j, val) == false))
					return 0;				end
			end
		end

		return timeDiff.end();
	end
end
