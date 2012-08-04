(() ->
  $document = $ document
  $img = null
  browserWidth = null
  browserHeight = null
  buffer = null
  testcanvas = null

  firstbid =
    x: 5
    y: 6
    width: 80
    height: 60

  bids = [firstbid]

  x = 0
  y = 0
  width = 0
  height = 0
  dragging = false
  $testcanvas = null

  onmousedown = (e) ->
    $testcanvas = $ testcanvas
    offset = $testcanvas.position document
    if e.which == 1
      x = e.pageX - offset.left
      y = e.pageY - offset.top
      dragging = true

  draw_rect = (x, y, w, h, fill, stroke) ->
    buffer.ctx.fillStyle = fill
    buffer.ctx.strokeStyle = stroke
    buffer.ctx.fillRect x, y, w, h
    buffer.ctx.lineWidth = 1
    buffer.ctx.fill

  onmousemove = (e) ->
    $testcanvas = $ testcanvas
    offset = $testcanvas.position document
    if dragging
      x2 = e.pageX - offset.left
      y2 = e.pageY - offset.top
      width = x2 - x
      height = y2 - y
      draw_all()

  flip = ->
    ctx = testcanvas.getContext "2d"
    ctx.drawImage buffer, 0, 0

  clear = ->
    buffer.ctx.fillStyle = "#000"
    buffer.ctx.strokeStyle = "#000"
    buffer.ctx.fillRect 0, 0, $testcanvas.width(), $testcanvas.height()
    buffer.ctx.lineWidth = 1
    buffer.ctx.fill

  draw_image = ->
    buffer.ctx.drawImage(
      $img.get(0),
      0,
      0
      $img.width(),
      $img.height(),
      0,
      0,
      browserWidth,
      browserHeight
    )

  draw_currently_dragged_bid = ->
    fill = "#0f0"
    if dragging then fill = "rgba(0, 255, 0, 0.5)"
    draw_rect x, y, width, height, fill, "#080"

  draw_bid = (bid) ->
    draw_rect bid.x, bid.y, bid.width, bid.height, "#f00", "#080"

  draw_bids = (bids) ->
    for bid in bids
      do (bid) ->
        draw_bid bid

  draw_all = ->
    clear()
    draw_image()
    draw_currently_dragged_bid()
    draw_bids bids
    flip()

  onmouseup = (e) ->
    $testcanvas = $ testcanvas
    offset = $testcanvas.position document
    if e.which == 1 and dragging
      x2 = e.pageX - offset.left
      y2 = e.pageY - offset.top
      width = x2 - x
      height = y2 - y
      dragging = false

      json =
        'bid':
          'bid_amount': 1
          'x': x
          'y': y
          'width': width
          'height': height

      $.post "/listing/1/bid", json
      bids.push json['bid']
      draw_all()

  methods =
    init: (opts) ->
      options =
        image: null

      $this = $ this
      $.extend options, opts

      browserWidth = $this.width()
      browserHeight = $this.height()

      $img = $ options.image

      buffer = document.createElement "canvas"
      buffer.width = browserWidth
      buffer.height = browserHeight
      buffer.ctx = buffer.getContext '2d'

      testcanvas = document.createElement "canvas"
      testcanvas.width = browserWidth
      testcanvas.height = browserHeight

      $testcanvas = $ testcanvas
      $this.append $testcanvas
      $testcanvas.mousedown onmousedown
      $testcanvas.mouseup onmouseup
      $testcanvas.mousemove onmousemove

      $img.load(() ->
        draw_all()
      )

  $.fn.bidCanvas = (method) ->
    if methods[method]
      methods[method].apply this, Array::slice.call(arguments, 1)
    else if typeof method is "object" or not method
      methods.init.apply this, arguments
    else
      $.error "Method " + method + " does not exist on jQuery.tooltip"
)()
