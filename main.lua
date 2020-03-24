WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432   
VIRTUAL_HEIGHT = 243


PADDLE_SPEED = 200
Class = require 'Class'

push = require 'push'

--local Class = require 'Class'
require 'Ball'
require 'Paddle'

function love.load()

    math.randomseed(os.time())

    love.graphics.setDefaultFilter('nearest', 'nearest')
    
    love.window.setTitle('Pong')

    smallFont = love.graphics.newFont('font.ttf',8)

    scoreFont = love.graphics.newFont('font.ttf',32)
    
    

   push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
       fullscreen = false,
       resizable = false,
       vsync = true

   })
     player1Score = 0
     player2Score = 0

     servingPlayer = math.random(2) == 1 and 1 or 2

     player1 = Paddle(5, 20, 5, 20)
     player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
     ball = Ball(VIRTUAL_WIDTH/ 2 - 2,VIRTUAL_HEIGHT/ 2 - 2, 4, 4)


     if servingPlayer == 1 then
        ball.dx = 100
     else
        ball.dx = -100
     end

    gameState = 'start' 
end

function love.update(dt)

    if gameState == 'play' then

        if ball.x <= 0 then
            player2Score = player2Score + 1
            servingPlayer = 1
            ball:reset()
            ball.dx = 100
            gameState = 'serve'
        end

        if ball.x >= VIRTUAL_WIDTH then
            player1Score = player1Score + 1
            servingPlayer = 2
            ball:reset()
            ball.dx = -100
            gameState = 'serve'
        end

        if ball:collides(player1) then
            --deflect ball to the right
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)

            else
                ball.dy = math.random(10, 150)
            end
        end

        if ball:collides(player2) then
            --deflect ball to the left
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4

            if ball.dy < 0 then
               ball.dy = -math.random(10,150)
            else
                ball.dy = math.random(10, 150)
            end
        end

        if ball.y <= 0 then
            --deflect the ball down
            ball.dy = -ball.dy
            ball.y = 0
        end

        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.dy = - ball.dy
            ball.y = VIRTUAL_HEIGHT - 4
        end
    end

    player1:update(dt)
    player2:update(dt)

    if love.keyboard.isDown('w') then

       player1.dy = -PADDLE_SPEED

    elseif love.keyboard.isDown('s') then

        player1.dy = PADDLE_SPEED

    else
        player1.dy = 0 

    end

    if love.keyboard.isDown('up') then

        player2.dy = -PADDLE_SPEED

    elseif love.keyboard.isDown('down') then

        player2.dy = PADDLE_SPEED

    else
        player2.dy = 0
    end

    if gameState == 'play' then
      
        ball:update(dt)
    end

end

function love.keypressed(key)
    if key == 'escape' then
       love.event.quit(); 

    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'

        elseif gameState == 'serve' then
                gameState = 'play'
        end
    end
end

function love.draw()

    push:apply('start')
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    love.graphics.setFont(smallFont)

    if   gameState == 'start' then
         love.graphics.printf("Welcome to Pong!", 0, 20, VIRTUAL_WIDTH, 'center')
         love.graphics.printf("Press Enter to Play!", 0, 32, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
          love.graphics.printf("Player " .. tostring(servingPlayer) .. "'s turn!", 0, 20, VIRTUAL_WIDTH, 'center')
          love.graphics.printf("Press Enter to Play!", 0, 32, VIRTUAL_WIDTH, 'center')
    end
  
    -- draw score on the left and right center of the screen
    -- need to swicth fon to draw befor actually printing
    love.graphics.setFont(scoreFont)
    love.graphics.print(player1Score,VIRTUAL_WIDTH /2 - 50,VIRTUAL_HEIGHT /3)
    love.graphics.print(player2Score,VIRTUAL_WIDTH /2 + 30,VIRTUAL_HEIGHT /3)

    --render paddles, now using their class's render methode
    player1:render()
    player2:render()
    
    
    -- render ball using its class's render mrthode
     ball:render()
     
     --new function just to demonstrate how to see FPS in LOVE
     displaySPS()
    
     -- end rendering at virtual resolution
    push:apply('end')
end

function displaySPS()

    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.setFont(smallFont)
    love.graphics.print('FPS ' .. tostring(love.timer.getFPS(getFPS)), 40, 20)
    love.graphics.setColor(1, 1, 1, 1)

end