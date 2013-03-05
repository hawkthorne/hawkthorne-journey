if not ( type(love._version) == "string" and love._version >= "0.8.0" ) then
    function love.draw()
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.print("This game requires LOVE v0.8.0 or higher.", 40, 200, 0, 3, 3)
        love.graphics.print("Download it at http://love2d.org", 40, 250, 0, 3, 3)
    end
    return false
else
    return true
end
