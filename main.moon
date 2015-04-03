love.load =  ->
  math.randomseed os.time! --isn't love supposed to do this automatically?

  export * -- globalizes all variables in this scope

  vector = require 'lib.hump.vector'
  gamestate = require 'lib.hump.gamestate'
  bump = require 'lib.bump'
  util = require 'lib.util'
  tick = require 'lib.tick'
  flux = require 'lib.flux'

  require 'class.physical'
  require 'class.wall'
  require 'class.projectile'
  require 'class.player'
  require 'class.enemies.enemy'
  require 'class.enemies.follower'
  require 'class.enemies.octorok'
  require 'class.map'

  require 'game'

  with gamestate
    .registerEvents!
    .switch Game

love.update = (dt) ->
  --update some libraries
  tick.update dt
  flux.update dt
