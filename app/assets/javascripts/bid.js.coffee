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

  removeDuplicates = (bids) ->
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
              duplicated = true
        if duplicated == false
          noDupArr.push bid
    return noDupArr

  onmousedown = (e) ->
    $testcanvas = $ testcanvas
    offset = $testcanvas.position document
    curX = e.pageX - offset.left
    curY = e.pageY - offset.top
    if e.which == 1
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
    buffer.ctx.clearRect 0, 0, buffer.width, buffer.height
    buffer.ctx.rect 0, 0, buffer.width, buffer.height
    buffer.ctx.fillStyle = "white"
    buffer.ctx.fill()

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
        'id': 'Dragged'
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
    if fillStyle
      buffer.ctx.fillStyle = fillStyle
      buffer.ctx.fill()
    buffer.ctx.lineWidth = lineWidth
    buffer.ctx.strokeStyle = color
    buffer.ctx.stroke()
    buffer.ctx.closePath()
    buffer.ctx.restore()

  bidAmountRect = (bid) ->
    amt_r =
      'x': (bid.x + bid.width) * browserWidth
      'y': bid.y * browserHeight
      'w': 48
      'h': 24
    amt_r

  bidBidButtonRect = (bid) ->
    amt_r = bidAmountRect bid
    btn_r =
      'x': amt_r.x + amt_r.w
      'y': amt_r.y
      'w': 42
      'h': 24
    btn_r

  draw_bid = (bid) ->
    color = "#1BAD03"
    if bid.user_id != window.currentUser
      color = "#F57621"
    normalX2 = bid.x + bid.width
    normalX2 *= browserWidth
    normalY2 = bid.y + bid.height
    normalY2 *= browserHeight
    draw_rounded_rect color, 5, bid.x * browserWidth, bid.y * browserHeight, normalX2, normalY2, 8
    amt_r = bidAmountRect bid
    draw_rounded_rect color, 5, amt_r.x, amt_r.y, amt_r.x + amt_r.w, amt_r.y + amt_r.h, 8, "#4f4"
    btn_r = bidBidButtonRect bid

    $bidBtn = $('#bid' + bid.id);
    console.log($bidBtn.length == 0);
    if ($bidBtn.length > 0)
      $bidBtn.css('left', btn_r.x);
      $bidBtn.css('top', btn_r.y);
    else
      $('#main_background').append('<button id="bid' + bid.id + '" style="font-size: 1.5em; position: absolute; top: ' + btn_r.y + 'px; left: ' + btn_r.x + 'px; width: ' + btn_r.w + 'px; height: ' + btn_r.h + 'px;">Bid!</button>');
      $('#bid' + bid.id).click ->
        json =
          'bid':
            'bid_amount': bid.bid_amount + 10
            'x': bid.x
            'y': bid.y
            'width': bid.width
            'height': bid.height
        $.post "/listing/" + window.listing + "/bid", json, (bid) ->
          if !bidExists(bid)
            bids.push bid
            bids = removeDuplicates(bids)
            draw_all()

    buffer.ctx.save()
    buffer.ctx.lineWidth = 1
    buffer.ctx.fillStyle = "#000"
    buffer.ctx.lineStyle = "#000"
    buffer.ctx.font = "bold 12px sans-serif"
    buffer.ctx.fillText bid.bid_amount + "¢", amt_r.x + 5, amt_r.y + 15
    buffer.ctx.restore()
    buffer.ctx.save()
    buffer.ctx.lineWidth = 1
    buffer.ctx.fillStyle = "#000"
    buffer.ctx.lineStyle = "#000"
    buffer.ctx.font = "bold 12px sans-serif"
    buffer.ctx.fillText "Bid!", btn_r.x + 5, btn_r.y + 15
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
      $('#bidDragged').remove();
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
            bids = removeDuplicates(bids)
      draw_all()

  bidExists = (newBid) ->
    for bid in bids
      return true if bid.id == newBid.id

    return false

  subscribe = () ->
    pusher = new Pusher '81e6ec22b6f7e2bbe1fa'
    channel = pusher.subscribe 'bids'
    channel.bind('new-bid', (bid) ->
      if bid.listing_id != window.listing
        return

      if !bidExists(bid)
        bids.push bid
        bids = removeDuplicates(bids)
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

  bidDataUrl = (bid) ->
    srcX = bid.x * $img.get(0).width
    srcY = bid.y * $img.get(0).height
    srcWidth = bid.width * $img.get(0).width
    srcHeight = bid.height * $img.get(0).height
    bidCanvas = document.createElement "canvas"
    bidCanvas.width = srcWidth
    bidCanvas.height = srcHeight
    bidCanvas.ctx = bidCanvas.getContext '2d'
    bidCanvas.ctx.drawImage $img.get(0), srcX, srcY, srcWidth, srcHeight, 0, 0, srcWidth, srcHeight
    bidCanvas.toDataURL()

  highBids = ->
    high_bids = []
    for bid in bids
      do (bid) ->
        if bid.user_id == window.currentUser
          high_bid =
            'url': bidDataUrl bid
            'amount': bid.bid_amount
          high_bids.push high_bid
    high_bids

  loadBidsAndSubscribe = (options) ->
    $.get "/listing/" + window.listing + "/bid", (oldBids) ->
      subscribe()
      for bid in oldBids
        do (bid) ->
          if !bidExists bid
            bids.push bid
      bids = removeDuplicates bids
      draw_all()
      if options.load
        options.load()

  methods =
    init: (opts) ->
      options =
        image: null
        load: null

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

      draw_all()
      if $img.get(0).complete
        loadBidsAndSubscribe options
      else
        $img.load(() ->
          loadBidsAndSubscribe options
        )

    highBids: () ->
      highBids()

  $.fn.bidCanvas = (method) ->
    if methods[method]
      methods[method].apply this, Array::slice.call(arguments, 1)
    else if typeof method is "object" or not method
      methods.init.apply this, arguments
    else
      $.error "Method " + method + " does not exist on jQuery.tooltip"
)()
