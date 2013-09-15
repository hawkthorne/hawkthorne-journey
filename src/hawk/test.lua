local test = {}

function test.visit(app, url)
  app:redirect(url)
  app:update(.01)
end

function test.sleep(app, dt)
  app:update(dt)
end


function test.press(app, button, times)
  local times = times or 1
  for i=1,times do 
    app:buttonpressed(button)
  end
  app:update(.01)
end


return test
