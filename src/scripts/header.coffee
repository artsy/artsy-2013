$ ->
  $(window).on 'resize', resizeHeader
  resizeHeader()

resizeHeader = ->
  $('#main-header').height $(window).height()