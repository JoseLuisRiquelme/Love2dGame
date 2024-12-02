function love.load()
    wf = require "libraries/windfield"
    dialove = require "libraries/Dialove"

    dialogManager = dialove.init({
        font = love.graphics.newFont('fonts/LoveDays-2v7Oe.ttf',16)
    })

    dialogManager:push('welcome misioner 1') -- stores a dialog into memory
    dialogManager:pop() -- requests the first pushed dialog to be shown on screen
  
     -- show() does both things, but don't do this:
    dialogManager:show('welcome misioner 2')
    dialogManager:show('welcome misioner 3')
    dialogManager:show('welcome misioner') -- only this one will be shown

    -- use this approach instead:
    dialogManager:show({
        text = 'Welcome to this huge adventure, be preparate', 
        title = 'Welcome misioner',
        options = {
            {'Option 1', function () --[[ do stuff ]] end},
            {'Option 2', function () --[[ do stuff ]] end},
          }
    })
    dialogManager:push('welcome misioner 5')
    dialogManager:push('welcome misioner 6')

    world = wf.newWorld(0,0)

    --rectangle = world:newRectangleCollider(350,100,80,80)
    camera = require 'libraries/camera'
    cam = camera()

    anim8 = require 'libraries/anim8'
    love.graphics.setDefaultFilter("nearest","nearest")
    sti = require 'libraries/sti'
    gameMap = sti('maps/testMap.lua')

    player = {}
    player.collider = world:newBSGRectangleCollider(400,500,50,100,14)
    player.collider:setFixedRotation(true)
    player.x = 400
    player.y = 200
    player.speed = 300
    animationSpeed = 0.2
    scale = 2
    frameWidth = 60
    frameHeight = 67
    --player.sprite = love.graphics.newImage('sprites/player.png')
    player.spriteSheet = love.graphics.newImage('sprites/sprite2.png')
    player.grid = anim8.newGrid(frameWidth,frameHeight,player.spriteSheet:getWidth(), player.spriteSheet:getHeight())

    player.animations = {}
    player.animations.down = anim8.newAnimation(player.grid('1-4',1),animationSpeed)
    player.animations.left = anim8.newAnimation(player.grid('1-4',2),animationSpeed)
    player.animations.right = anim8.newAnimation(player.grid('1-4',3),animationSpeed)
    player.animations.up = anim8.newAnimation(player.grid('1-4',4),animationSpeed)

    player.anim = player.animations.down

    background = love.graphics.newImage('sprites/background.jpg')

    walls = {}
    if gameMap.layers["walls"] then
        for i, obj in pairs(gameMap.layers["walls"].objects) do
            local wall = world:newRectangleCollider(obj.x,obj.y,obj.width,obj.height)
            wall:setType('static')
            table.insert(wall,wall)
        end
    end
            
    --local wall = world:newRectangleCollider(100,200,120,300)
    --wall:setType('static')

    sounds = {}
    sounds.bloop = love.audio.newSource("sounds/bloop.wav","static")
    sounds.music = love.audio.newSource("sounds/music.mp3","stream")
    sounds.bird = love.audio.newSource("sounds/bird.wav","static")

    sounds.bird:setLooping(true)
    sounds.music:setLooping(true)

    sounds.music:play()
    sounds.bird:play()

    sounds.music:setVolume(0.1)
    --sounds.bird:setVolume(0.1)
    sounds.bloop:setVolume(0.1)
    

    sounds.bird:setPosition(10,10,100)

end



--[[function movement(direction,playerAxis,player.speed)
    if love.keyboard.isDown(direction) then
        playerAxis = playerAxis + player.speed
end]]

function love.update(dt)
    dialogManager:update(dt)

    local isMoving = false

    local vx = 0
    local vy = 0

    if love.keyboard.isDown("d") then
        vx = player.speed
        player.anim = player.animations.right
        isMoving = true
    

    elseif love.keyboard.isDown("a") then
        vx = player.speed * -1
        player.anim = player.animations.left
        isMoving = true


    elseif love.keyboard.isDown("w") then
        vy = player.speed * -1
        player.anim = player.animations.up
        isMoving = true
    

    elseif love.keyboard.isDown("s") then
        vy = player.speed
        player.anim = player.animations.down
        isMoving = true

       --[[ movement("right",playerx,player.speed)
        movement("left",playerx,player.speed)
        movement("right",playery,player.speed)
        movement("left",playery,player.speed)]]
    end

    player.collider:setLinearVelocity(vx,vy)
    if isMoving == false then
        player.anim:gotoFrame(1)
    end

    world:update(dt)
    player.x = player.collider:getX()
    player.y = player.collider:getY()

    player.anim:update(dt)

    cam:lookAt(player.x,player.y)

    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    if cam.x < w/2 then
        cam.x =w/2
    end

    if cam.y < h/2 then
        cam.y =h/2
    end

    local mapW = gameMap.width * gameMap.tilewidth
    local mapH = gameMap.height * gameMap.tileheight

    if cam.x > (mapW - w/2) then
        cam.x = (mapW - w/2)
    end

    if cam.y >(mapH - h/2) then
        cam.y = (mapH - h/2)
    end
end

function love.draw()
    cam:attach()
        gameMap:drawLayer(gameMap.layers["Capa de patrones 1"])
        gameMap:drawLayer(gameMap.layers["Capa de patrones 2"])
        --world:draw()
        player.anim:draw(player.spriteSheet,player.x,player.y,nil,scale,nil,30,34)
    cam:detach()

    dialogManager:draw()
end

musicStop = false

function love.keypressed(key)
    if key == "space" then
        sounds.bloop:play()
    end
    if key == "z"  then
        if musicStop == false then
            sounds.music:pause()
            musicStop = true
        else
            sounds.music:play()
            musicStop = false
        end
    end

    if key == 'return' then
        dialogManager:pop()
      elseif key == 'c' then
        dialogManager:complete()
      elseif key == 'f' then
        dialogManager:faster()
      elseif key == 'down' then
        dialogManager:changeOption(1) -- next one
      elseif key == 'up' then
        dialogManager:changeOption(-1) -- previous one
      end
end

function love.keyreleased(k)
    if k == 'space' then
      dialogManager:slower()
    end
  end