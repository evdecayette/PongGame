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

    victoryFont = love.graphics.newFont('font.ttf',24)

    sounds = {

        ['paddle_hit'] = love.audio.newSource('paddle_hit.wav','static'),
        ['score'] = love.audio.newSource('score.wav','static'),
        ['wall_hit'] = love.audio.newSource('wall_hit.wav','static')
    }
    
    

   push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
       fullscreen = false,
       resizable = true,
       vsync = true

   })
     player1Score = 0
     player2Score = 0

     winningPlayer = 0

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

function love.resize(w,h)
push:resize(w,h)

end

function love.update(dt)

    if gameState == 'play' then

        if ball.x <= 0 then
            servingPlayer = 1
            player2Score = player2Score + 1

            sounds['score']:play()
            
            
            if player2Score >= 10 then

                winningPlayer = 2
                gameState = 'victory'

            else
                 gameState = 'serve'
                 ball:reset()
            end

        end

        if ball.x >= VIRTUAL_WIDTH then
            player1Score = player1Score + 1
            sounds['score']:play()
            servingPlayer = 2
            

            if player1Score >= 10 then

                winningPlayer = 1
                gameState = 'victory'

            else
                gameState = 'serve'
                ball:reset()
            end

        end

        if ball:collides(player1) then
            --deflect ball to the right
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5

            sounds['paddle_hit']:play()

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

            sounds['paddle_hit']:play()

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

            sounds['wall_hit']:play()
        end

        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.dy = - ball.dy
            ball.y = VIRTUAL_HEIGHT - 4

            sounds['wall_hit']:play()
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

        elseif gameState == 'victory' then
               gameState = 'start'
               player1Score = 0
               player2Score = 0

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
         love.graphics.printf("Press Enter to begin!", 0, 32, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
          love.graphics.printf("Player " .. tostring(servingPlayer) .. "'s turn!", 0, 20, VIRTUAL_WIDTH, 'center')
          love.graphics.printf("Press Enter to serve!", 0, 32, VIRTUAL_WIDTH, 'center')

    elseif gameState == 'victory' then
        -- draw a victory message
        love.graphics.setFont(victoryFont)
        love.graphics.printf("Player " .. tostring(winningPlayer) .. " wins!", 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press Enter to serve!", 0, 42, VIRTUAL_WIDTH, 'center')
     elseif gameState == 'paly' then



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