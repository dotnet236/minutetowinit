MTWI = {}
MTWI.forms =
  signIn: (o) ->
    # Gets which service we're trying to sign in as; stored in the data-service attribute of the logo image
    service = $(o).data("service")

    console.log $("#sign-in > div")
    # Show the sign in form
    $("#sign-in > div").show()

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

  $("#reset-sign-in").click ->
    MTWI.forms.resetSignIn()
)
