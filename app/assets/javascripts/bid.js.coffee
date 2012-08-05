(() ->
  $document = $ document
  $img = null
  browserWidth = null
  browserHeight = null
  buffer = null
  $buffer = null
  testcanvas = null
  $testcanvas = null
  canvasdiv = null
  $canvasdiv = null
  bids = []

  x = 0
  y = 0
  width = 0
  height = 0
  dragging = false
  maxWidth = 0
  maxHeight = 0

  updateConstraints = ->
    console.log "updating constraints"
    maxWidth = 1.0 - x / browserWidth
    maxHeight = 1.0 - y / browserHeight
    normalX = x / browserWidth
    normalY = y / browserHeight
    normalWidth = width / browserWidth
    normalHeight = height / browserHeight
    for bid in bids
      do (bid) ->
        if bid.y < normalY + normalHeight and bid.y + bid.height > normalY and bid.x >= normalX + normalWidth - 0.05
          maxWidth = Math.min maxWidth, bid.x - normalX
    for bid in bids
      do (bid) ->
        if bid.x < normalX + normalWidth and bid.x + bid.width > normalX and bid.y >= normalY + normalHeight - 0.05
          maxHeight = Math.min maxHeight, bid.y - normalY
    console.log "maxWidth: " + maxWidth + ", maxHeight: " + maxHeight

  onmousedown = (e) ->
    $testcanvas = $ testcanvas
    offset = $testcanvas.position document
    if e.which == 1
      x = e.pageX - offset.left
      y = e.pageY - offset.top
      width = 0
      height = 0
      dragging = true
      updateConstraints()

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
      if x2 > x
        normalNewWidth = x2 - x
        normalNewWidth /= browserWidth
        normalWidth = Math.min normalNewWidth, maxWidth
        width = Math.floor normalWidth * browserWidth
        updateConstraints()
      y2 = e.pageY - offset.top
      if y2 > y
        normalNewHeight = y2 - y
        normalNewHeight /= browserHeight
        normalHeight = Math.min normalNewHeight, maxHeight
        height = Math.floor normalHeight * browserHeight
        updateConstraints()
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
    draw_rect(
      bid.x * browserWidth,
      bid.y * browserHeight,
      bid.width * browserWidth,
      bid.height * browserHeight,
      "#f00",
      "#080"
      )

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
      if x2 > x
        normalNewWidth = x2 - x
        normalNewWidth /= browserWidth
        normalWidth = Math.min normalNewWidth, maxWidth
        width = Math.floor normalWidth * browserWidth
        updateConstraints()
      y2 = e.pageY - offset.top
      if y2 > y
        normalNewHeight = y2 - y
        normalNewHeight /= browserHeight
        normalHeight = Math.min normalNewHeight, maxHeight
        height = Math.floor normalHeight * browserHeight
        updateConstraints()
      dragging = false

      json =
        'bid':
          'bid_amount': 1
          'x': x / browserWidth
          'y': y / browserHeight
          'width': width / browserWidth
          'height': height / browserHeight

      $.post "/listing/1/bid", json, (bid) ->
        if !bidExists(bid)
          bids.push bid
          draw_all()

  bidExists = (newBid) ->
    for bid in bids
      return true if bid.id == newBid.id

    return false

  subscribe = () ->
    pusher = new Pusher '81e6ec22b6f7e2bbe1fa'
    channel = pusher.subscribe 'bids'
    channel.bind('new-bid', (bid) ->
      if !bidExists(bid)
        bids.push bid
        draw_all()
    )

  onresize = ->
    $window = $ window
    browserWidth = $window.width()
    browserHeight = $window.height()
    testcanvas.width = browserWidth
    testcanvas.height = browserHeight
    buffer.width = browserWidth
    buffer.height = browserHeight
    $canvasdiv.width browserWidth
    $canvasdiv.height browserHeight
    draw_all()

  methods =
    init: (opts) ->
      options =
        image: null

      $this = $ this
      $.extend options, opts
      canvasdiv = this
      $canvasdiv = $ canvasdiv

      browserWidth = $this.width()
      browserHeight = $this.height()

      $img = $ options.image

      buffer = document.createElement "canvas"
      buffer.width = browserWidth
      buffer.height = browserHeight
      buffer.ctx = buffer.getContext '2d'
      $buffer = $ buffer

      testcanvas = document.createElement "canvas"
      testcanvas.width = browserWidth
      testcanvas.height = browserHeight

      $testcanvas = $ testcanvas
      $this.append $testcanvas
      $testcanvas.mousedown onmousedown
      $testcanvas.mouseup onmouseup
      $testcanvas.mousemove onmousemove

      $window = $ window
      $window.resize onresize

      $img.load(() ->
        draw_all()
        subscribe()
      )

  $.fn.bidCanvas = (method) ->
    if methods[method]
      methods[method].apply this, Array::slice.call(arguments, 1)
    else if typeof method is "object" or not method
      methods.init.apply this, arguments
    else
      $.error "Method " + method + " does not exist on jQuery.tooltip"
)()
