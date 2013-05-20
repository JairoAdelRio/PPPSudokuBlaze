--
-- Project: build.settings
-- Description: 
--
-- Version: 1.0
-- Managed with http://CoronaProjectManager.com
--
-- Copyright 2013 . All Rights Reserved.
-- 

Icon = {}
Icon.__index = Icon

function Icon.create( image, wdth, hght, frames, imageData )		local options =
	{
 	   -- The params below are required
	    
	    width = wdth,
	    height = hght,
	    numFrames = frames,
	}	
	local icon = {}
	setmetatable ( icon, Icon )
	
	-- Create a new icon with data and spritesheet
	icon.icon = graphics.newImageSheet( image + "sheet.png",  options )	icon.imageData = imageData

	return 
end

function Icon:animate( animName )
	self.animation = display.newSprite( self.icon, self.imageData )
end

-- Play the named animation
function Icon:play( animationName, loop )
	self.stop()
	self.currentAnimation = animationName
end

-- stop any playing animations and return to the idle frames.
function Icon:stop()
end


