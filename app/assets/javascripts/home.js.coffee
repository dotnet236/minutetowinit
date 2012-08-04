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

  $("#buy_button").click((evt) ->
    if window.authenticated
      window.location.href = '/latest_listing'
      evt.stopPropogation()
      evt.preventDefault()
      return false
    else
      $("#existing_user").find("[name='selling']").val(false)
  )
  $("#sell_button").click((evt) ->
    if window.authenticated
      window.location.href = '/listing/new'
      evt.stopPropogation()
      evt.preventDefault()
      return false
    else
      $("#existing_user").find("[name='selling']").val(true)
  )
)
