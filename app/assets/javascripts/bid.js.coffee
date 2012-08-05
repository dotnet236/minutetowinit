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

  removeDuplicates = ->
    dups = false
    noDupArr = []
    for bid in bids
      do (bid) ->
        duplicated = false
        for bid2 in bids
          do (bid2) ->
            if bid.id != bid2.id and Math.abs(bid.x - bid2.x) < 0.05 and
               Math.abs(bid.y - bid2.y) < 0.05 and
               Math.abs(bid.width - bid2.width) < 0.05 and
               Math.abs(bid.height - bid2.height) < 0.05 and
               bid.bid_amount < bid2.bid_amount
              console.log "bid " + bid.id + " @ " + bid.bid_amount + " is duplicated by bid " + bid2.id + " @ " + bid2.bid_amount
              console.log "two in the same place: " + bid.id + ":" + bid.bid_amount + ", " + bid2.id + ":" + bid2.bid_amount
              duplicated = true
        if duplicated == false
          noDupArr.push bid
    bids = noDupArr

  onmousedown = (e) ->
    $testcanvas = $ testcanvas
    offset = $testcanvas.position document
    curX = e.pageX - offset.left
    curY = e.pageY - offset.top
    if e.which == 1
      existing = null
      for bid in bids
        do (bid) ->
          bidx2 = bid.x + bid.width
          bidx2 *= browserWidth
          console.log "[ " + curX + ", " + curY + " ]"
          if curX >= bidx2 and curX <= bidx2 + 32 and curY >= bid.y * browserHeight and curY <= bid.y * browserHeight + bid.height * browserHeight
            existing = bid
      if existing
        json =
          'bid':
            'bid_amount': existing.bid_amount + 10
            'x': existing.x
            'y': existing.y
            'width': existing.width
            'height': existing.height
        $.post "/listing/" + window.listing + "/bid", json, (bid) ->
          if !bidExists(bid)
            bids.push bid
            removeDuplicates()
            draw_all()
      else
        x = curX
        y = curY
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
    buffer.width = buffer.width

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
    if dragging
      newbid =
        'x': x / browserWidth
        'y': y / browserHeight
        'width': width / browserWidth
        'height': height / browserHeight
        'user_id': window.currentUser
        'bid_amount': 10
      draw_bid newbid

  draw_rounded_rect = (color, lineWidth, x1, y1, x2, y2, r, fillStyle) ->
    buffer.ctx.save()
    buffer.ctx.beginPath()
    buffer.ctx.moveTo x1 + r, y1
    buffer.ctx.lineTo x2 - r, y1
    buffer.ctx.arcTo x2, y1, x2, y1 + r, r
    buffer.ctx.lineTo x2, y2 - r
    buffer.ctx.arcTo x2, y2, x2 - r, y2, r
    buffer.ctx.lineTo x1 + r, y2
    buffer.ctx.arcTo x1, y2, x1, y2 - r, r
    buffer.ctx.lineTo x1, y1 + r
    buffer.ctx.arcTo x1, y1, x1 + r, y1, r
    console.log fillStyle
    if fillStyle
      buffer.ctx.fillStyle = fillStyle
      buffer.ctx.fill()
    buffer.ctx.lineWidth = lineWidth
    buffer.ctx.strokeStyle = color
    buffer.ctx.stroke()
    buffer.ctx.closePath()
    buffer.ctx.restore()

  draw_bid = (bid) ->
    color = "#1BAD03"
    if bid.user_id != window.currentUser
      color = "#F57621"
    normalX2 = bid.x + bid.width
    normalX2 *= browserWidth
    normalY2 = bid.y + bid.height
    normalY2 *= browserHeight
    draw_rounded_rect color, 5, bid.x * browserWidth, bid.y * browserHeight, normalX2, normalY2, 8
    
    browserX = bid.x * browserWidth
    browserY = bid.y * browserHeight
    console.log "[ " + normalX2 + ", " + browserY + ", " + (normalX2 + 32) + ", " + (browserY + 24) + " ]"
    draw_rounded_rect color, 5, normalX2, browserY, normalX2 + 32, browserY + 24, 8, "#4f4"

    buffer.ctx.save()
    buffer.ctx.lineWidth = 1
    buffer.ctx.fillStyle = "#000"
    buffer.ctx.lineStyle = "#000"
    buffer.ctx.font = "bold 12px sans-serif"
    buffer.ctx.fillText bid.bid_amount + "¢", browserX + bid.width * browserWidth + 5, browserY + 15
    buffer.ctx.restore()

  draw_bids = (bids) ->
    for bid in bids
      do (bid) ->
        draw_bid bid

  draw_all = ->
    clear()
    draw_image()
    draw_bids bids
    draw_currently_dragged_bid()
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
      console.log "width: " + width / browserWidth + ", height: " + height / browserHeight
      if width / browserWidth > 0.05 and height / browserHeight > 0.05
        json =
          'bid':
            'bid_amount': 10
            'x': x / browserWidth
            'y': y / browserHeight
            'width': width / browserWidth
            'height': height / browserHeight
        $.post "/listing/" + window.listing + "/bid", json, (bid) ->
          if !bidExists(bid)
            bids.push bid
            removeDuplicates()
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
        removeDuplicates()
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
        $.get "/listing/" + window.listing + "/bid", (oldBids) ->
          subscribe()
          for bid in oldBids
            do (bid) ->
              if !bidExists bid
                bids.push bid
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
