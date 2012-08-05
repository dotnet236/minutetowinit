MTWI = {}
MTWI.forms =
  signIn: (o) ->
    # Gets which service we're trying to sign in as; stored in the data-service attribute of the logo image
    service = $(o).data("service")

    # Show the sign in form
    $('form#existing_user').parent().show()

    # Hide whichever sign in services weren't selected
    $("#sign-in > img").each ->
      $(this).hide()  if $(this).data("service") isnt service

  # Use this to change the action on the form
  # $('#form-sign-in').attr('action');
  resetSignIn: ->
    $("#sign-in > img").show()
    $("#sign-in > div").hide()

$(() ->
  $("#sign-in > img").click(() ->
    MTWI.forms.signIn this
  )

  $("a#register").click ->
    $('form#existing_user').parent().hide()
    $('form#new_user').parent().show()

  $("a#existing").click ->
    $('form#new_user').parent().hide()
    $('form#existing_user').parent().show()

  selling = true

  $("#buy_button").click((evt) ->
    selling = false
    $('form#existing_user').parent().show()
    $("#existing_user").find("[name='selling']").val(false)
    $('#authentication').toggle(!window.authenticated)
    if window.authenticated
      $('#authentication').hide()
      toggleSellBuy()
  )

  $("#sell_button").click((evt) ->
    selling = true
    $('form#existing_user').parent().show()
    $("#new_user").find("[name='selling']").val(true)
    if window.authenticated
      $('#authentication').hide()
      toggleSellBuy()
  )

  toggleSellBuy = () ->
    if selling
      $('#sell').show()
      $('#buy').hide()
    else
      $('#sell').hide()
      $('#buy').show()

  $('#existing_user').ajaxForm(() ->
    $('#authentication').hide()
    toggleSellBuy()
  )

  $('#new_user').ajaxForm(() ->
    $('#authentication').hide()
    toggleSellBuy()
  )
  $('#sell').find("input[type='file']").bind 'change', ->
    return if @files.length = 0
    file = @files[0]
    reader = new FileReader()
    reader.onload = (e) ->
      $('#sell').find('.photo_form').show()
      $('#sell').find('img').attr('src', e.target.result)
    reader.readAsDataURL(file)
)
