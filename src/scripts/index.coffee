$ ->
  $(window).on 'scroll', onScroll
  $(window).on 'resize', setBackgroundItemMargin
  onScroll()
  setBackgroundItemMargin()

onScroll = ->
  $('#background li').each ->
    index = $(@).index()
    viewportBottom = $(window).scrollTop() + $(window).height()
    elTop = $(@).offset()?.top
    elBottom = elTop + $(@).height()
    nextTop = $(@).next()?.offset()?.top

    # Between an item so make sure it's opacity is 1
    if viewportBottom > elTop and viewportBottom < elBottom
      $("#foreground li:eq(#{index})").css opacity: 1

    # Between background items so transition opacities
    else if viewportBottom > elBottom and viewportBottom < nextTop
      midPoint = ((nextTop - elBottom) * 0.7) + elBottom
      percentPrevItem = 1 - (viewportBottom - elBottom) / (midPoint - elBottom)
      percentNextItem = (viewportBottom - midPoint) / (nextTop - midPoint)
      $("#foreground li:eq(#{index})").css opacity: percentPrevItem
      $("#foreground li:eq(#{index + 1})").css opacity: percentNextItem


setBackgroundItemMargin = ->
  $('#background li').css 'margin-bottom': $(window).height()