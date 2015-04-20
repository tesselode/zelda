export class Enemy extends Physical
  new: (state, x, y) =>
    super state, x, y, TILE_SIZE - 2, TILE_SIZE - 2

    @isEnemy = true
    @inAir = false
    @knockback = false
    @health = 3
    @damage = 1
    @gemAmount = 5
    @score = 100
    @shadowVisible = true

    --collision filter
    @filter = (other) =>
      if other.__class == Wall or other.__class == Door or other.__class.__parent == Enemy
        return 'slide'
      else
        return 'cross'

    @depth += 100

  update: (dt) =>
    --knockback movement
    if @knockback
      @drag = 8
      if @velocity\len! < 50
        @knockback = false
        @drag = 0
        @velocity = @velocityPrev

    --at this point this is a death animation
    if @health <= 0
      @delete = true

    collisions = super dt
    if @health > 0
      for col in *collisions
        other = col.other
        --bounce off of walls
        if other.__class == Wall
          @velocity = -@velocity
        --damage the player
        if @inAir == false and other.__class == Player
          other\takeDamage self

    return collisions

  takeDamage: (other, damage) =>
    @health -= damage
    if other.__class == Projectile
      --die immediately
      if @health == 0
        @delete = true
    if other.__class == Player
      --knockback movement
      @knockback = true
      @velocityPrev = @velocity
      @velocity = vector.new(400, 0)\rotated(other.direction)

  onDelete: =>
    --give the player poins
    @state.gameFlow.score += @score * @state.gameFlow.multiplier
    --spawn gems when dead
    for i = 1, @gemAmount
      Gem @state, @getCenter!.x, @getCenter!.y
