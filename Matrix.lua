--
-- Project: Icon.lua
-- Description: 
--
-- Version: 1.0
-- Managed with http://CoronaProjectManager.com
--
-- Copyright 2013 . All Rights Reserved.
-- 

local Matrix = {}
Matrix.__index = Matrix

function Matrix.Create( arraySize )
	matrix = {}
	
	setmetatable( matrix, Matrix )

	matrix.arraySize = arraySize

	for i = 1, arraySize, 1 do
		matrix[i] = 0
	end

	return matrix 
end

function Matrix:Clear()
	for i = 1, self.arraySize, 1 do
	end
end

return Matrix