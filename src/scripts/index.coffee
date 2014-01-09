$ ->
  $(window).on 'scroll', onScroll

onScroll = ->
  $('#background li').each ->
    if $(window).scrollTop() + $(window).height() >= $(@).offset().top
      $("#foreground li").hide()
      $("#foreground li:eq(#{$(@).index()})").show()