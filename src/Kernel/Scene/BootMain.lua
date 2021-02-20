local class = require "com/class"
local BootMain = class:derive("BootMain")

local Vec2 = require("src/Essentials/Vector2")
local Button = require("src/Kernel/UI/Button")



function BootMain:new(bootScreen)
  self.bootScreen = bootScreen

	-- prepare fonts of various sizes
	self.font = love.graphics.newFont()
	self.fontBig = love.graphics.newFont(18)

	-- github url link
	self.url = "https://github.com/jakubg1/OpenSMCE"
	self.urlHovered = false
	self.urlHoverPos = Vec2(35, 174)
	self.urlHoverSize = Vec2(365, 25)

	-- game list
	self.gameButtons = {}
	self.selectedGame = nil

	-- buttons
	self.loadGameBtn = Button("Start!", self.fontBig, Vec2(544, 472), Vec2(222, 24), function() self:loadSelectedGame() end)
	self.settingsBtn = Button("Engine Settings", self.fontBig, Vec2(540, 530), Vec2(230, 24), function()  end)
	self.quitBtn = Button("Exit", self.fontBig, Vec2(540, 554), Vec2(230, 24), function() love.event.quit() end)
end



function BootMain:init()
	-- set buttons up
	for i, game in ipairs(self.bootScreen.games) do
		table.insert(self.gameButtons, Button(game.name, self.fontBig, Vec2(34, 280 + i * 24), Vec2(482, 24), function() self:selectGame(i) end))
	end
	self.loadGameBtn.visible = false
end



function BootMain:update(dt)
	-- button hover
	for i, gameButton in ipairs(self.gameButtons) do
		gameButton:update(dt)
	end
	self.loadGameBtn:update(dt)
	self.settingsBtn:update(dt)
	self.quitBtn:update(dt)

	-- URL hover
	self.urlHovered = mousePos.x > self.urlHoverPos.x and
					mousePos.x < self.urlHoverPos.x + self.urlHoverSize.x and
					mousePos.y > self.urlHoverPos.y and
					mousePos.y < self.urlHoverPos.y + self.urlHoverSize.y
end



function BootMain:selectGame(id)
	self.selectedGame = id
	self.loadGameBtn.visible = true
	for i, button in ipairs(self.gameButtons) do
		button.selected = i == id
	end
end



function BootMain:loadSelectedGame()
	self.bootScreen:loadGame(self.games[self.selectedGame].name)
end



function BootMain:draw()
	-- White color
	love.graphics.setColor(1, 1, 1)

	-----------------------------
	-- HEADER
	-----------------------------
	love.graphics.setFont(self.fontBig)
	love.graphics.print("OpenSMCE Boot Menu", 30, 30)
	love.graphics.print(string.format("Version: %s (%s)", VERSION_NAME, VERSION), 520, 30)

	-----------------------------
	-- NOTES
	-----------------------------
	-- Warning text
	love.graphics.setColor(1, 0.2, 0.2)
	love.graphics.print("WARNING", 45, 75)
	-- Warning contents
	love.graphics.setColor(1, 1, 0.2)
	love.graphics.setFont(self.font)
	love.graphics.print("This engine is in BETA DEVELOPMENT.\nExpect that it will be full of bugs. This version is dedicated to people who want to test the engine and examine it.\nThis version should NOT be treated like a full version.\nRemember to post issues and feature suggestions at the following Github repository link.", 45, 100)
	-- Github link
	love.graphics.setColor(1, 1, 1)
	love.graphics.setFont(self.fontBig)
	love.graphics.print(self.url, 45, 175)
	love.graphics.setLineWidth(4)
	love.graphics.rectangle("line", 30, 60, 740, 150) -- frame

	-----------------------------
	-- GAME LIST
	-----------------------------
	love.graphics.print("Game List", 30, 270)
	for i, gameButton in ipairs(self.gameButtons) do
		gameButton:draw()
	end
	love.graphics.setColor(1, 1, 1)
	love.graphics.setLineWidth(4)
	love.graphics.rectangle("line", 30, 300, 490, 200) -- frame

	-----------------------------
	-- SELECTED GAME DATA
	-----------------------------
	love.graphics.print("Selected Game", 540, 270)
	if self.selectedGame then
		love.graphics.print(self.bootScreen.games[self.selectedGame].name, 544, 304)
		-- Version support
		local supportedVersion = self.bootScreen.games[self.selectedGame].config.engineVersion
		love.graphics.setFont(self.font)
		if supportedVersion then
			love.graphics.print(string.format("Supported Version: %s", supportedVersion), 544, 324)
		else
			love.graphics.setColor(1, 1, 0)
			love.graphics.print(string.format("Unknown supported version!"), 544, 324)
		end
	end
	self.loadGameBtn:draw()
	love.graphics.setColor(1, 1, 1)
	love.graphics.setLineWidth(4)
	love.graphics.rectangle("line", 540, 300, 230, 200) -- frame

	-----------------------------
	-- FOOTER
	-----------------------------
	love.graphics.setFont(self.font)
	love.graphics.print("OpenSMCE is a short for Open-Source Sphere Matcher Community Engine.", 30, 525)
	love.graphics.print("This work was brought to you by jakubg1\nLicensed under MIT license.", 30, 555)

	-----------------------------
	-- FOOTER BUTTONS
	-----------------------------
	self.settingsBtn:draw()
	self.quitBtn:draw()

	-----------------------------
	-- URL HOVERING
	-----------------------------
	if self.urlHovered then
		love.graphics.setColor(1, 1, 0)
	else
		love.graphics.setColor(0.4, 0.4, 0)
	end
	love.graphics.setLineWidth(2)
	love.graphics.rectangle("line", self.urlHoverPos.x, self.urlHoverPos.y, self.urlHoverSize.x, self.urlHoverSize.y)
	-- if self.urlHovered then
		-- love.graphics.print("<--- Click here to open the page!", self.urlHoverPos.x + self.urlHoverSize.x + 20, self.urlHoverPos.y + 8, 0.1)
	-- end

	-----------------------------
	-- DISCORD RICH PRESENCE STATUS
	-----------------------------
	love.graphics.setColor(1, 1, 1)
	love.graphics.setFont(self.fontBig)
	love.graphics.print("Discord Integration: ", 30, 220)
	if discordRPC.enabled and discordRPC.connected then
		love.graphics.setColor(0, 1, 0)
		love.graphics.print(string.format("Connected! (%s)", discordRPC.username), 210, 220)
	elseif discordRPC.enabled and not discordRPC.connected then
		love.graphics.setColor(1, 1, 0)
		love.graphics.print("Connecting...", 210, 220)
	elseif not discordRPC.enabled and discordRPC.connected then
		love.graphics.setColor(1, 0.5, 0)
		love.graphics.print("Disconnecting...", 210, 220)
	elseif not discordRPC.enabled and not discordRPC.connected then
		love.graphics.setColor(0.75, 0.75, 0.75)
		love.graphics.print("Inactive", 210, 220)
	end
end



function BootMain:mousereleased(x, y, button)
	-- Buttons
	for i, gameButton in ipairs(self.gameButtons) do
		gameButton:mousereleased(x, y, button)
	end
	self.loadGameBtn:mousereleased(x, y, button)
	self.settingsBtn:mousereleased(x, y, button)
	self.quitBtn:mousereleased(x, y, button)

	-- URL
	if self.urlHovered then
		love.system.openURL(self.url)
	end
end



return BootMain