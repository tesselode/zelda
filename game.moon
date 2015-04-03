export Game = {
  enter: =>
    @world = bump.newWorld!
    @map = Map @world

    with @map
      \addWall 200, 200, 100, 100
      --game border (temporary)
      \addWall 0, 0, 1280, 20
      \addWall 0, 700, 1280, 20
      \addWall 0, 20, 20, 680
      \addWall 1260, 20, 20, 680
      \addEnemy Octorok, 600, 500

  update: (dt) =>
    --update all instances
    for item in *@world\getItems!
      item\update dt if item.update

  keypressed: (key) =>
    if key == 'escape' -- change this later
      love.event.quit!

    if key == 'x'
      @map.player\attack!

  draw: =>
    --draw all instances
    for item in *@world\getItems!
      item\draw! if item.draw
}
