--
-- Project:
-- Description: 
--
-- Version: 1.0
-- Managed with http://CoronaProjectManager.com
--
-- Copyright 2013 . All Rights Reserved.
-- 
local Matrix = require( "Matrix" )
local sudoku = require("sg")
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()


-- local forward references should go here --


-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view

	sudok = sudoku.Create( Matrix.Create(81) )
	sudok:newGame()
	
	for i = 1, 9, 1 do
		if not sudok:checkVal( 1, 1, i ) then
			print("Can't use " .. i .. " here" )
			--break
		end
	end
end


-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
	local group = self.view


end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view


end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view


end


-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
	local group = self.view

end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	local group = self.view


end


-- Called if/when overlay scene is displayed via storyboard.showOverlay()
function scene:overlayBegan( event )
	local group = self.view
	local overlay_name = event.sceneName  -- name of the overlay scene


end


-- Called if/when overlay scene is hidden/removed via storyboard.hideOverlay()
function scene:overlayEnded( event )
	local group = self.view
	local overlay_name = event.sceneName  -- name of the overlay scene

end



-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "willEnterScene" event is dispatched before scene transition begins
scene:addEventListener( "willEnterScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "didExitScene" event is dispatched after scene has finished transitioning out
scene:addEventListener( "didExitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-- "overlayBegan" event is dispatched when an overlay scene is shown
scene:addEventListener( "overlayBegan", scene )

-- "overlayEnded" event is dispatched when an overlay scene is hidden/removed
scene:addEventListener( "overlayEnded", scene )

---------------------------------------------------------------------------------

return scene
