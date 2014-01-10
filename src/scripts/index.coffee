# The gap between items is based on the viewport size
GAP_PERCENT_OF_VIEWPORT = 0.7

# The point at which one foreground item is at 0 opacity and the next item is fading in.
# e.g. 0.9 will mean the fade out of the first item is long and the fade in of the next
# item is very short.
MID_FADE_PERCENT = 0.5

# The gap size based on the viewport. Dial this number down to have a smaller gap where
# the foreground item is at 0 opacity, dial it up to have a sharper fade out and a longer
# gap of black between items.
FADE_GAP_OF_BLACK = 0.5

# Offset what point the fade begins after the bottom of the previous element,
# based on viewportHeight
startOffest = (viewportHeight) -> (viewportHeight / 2)

# Offset what point the fade begins after the bottom of the previous element,
# based on viewportHeight
endOffest = (viewportHeight) -> viewportHeight

$ ->
  $('html, body').animate { scrollTop: 50}, 10, ->
    $(window).on 'scroll', onScroll
    $(window).on 'resize', setBackgroundItemMargin
    onScroll()
    setBackgroundItemMargin()

onScroll = ->
  $('#background li').each ->
    index = $(@).index()

    # Alias common positions we'll be calculating
    viewportHeight = $(window).height()
    viewportBottom = $(window).scrollTop() + $(window).height()
    viewportTop = $(window).scrollTop()
    elTop = $(@).offset()?.top
    elBottom = elTop + $(@).height()
    nextTop = $(@).next()?.offset()?.top

    # Values pertaining to when to start fading and when to fade in the next one
    startPoint = elBottom + startOffest(viewportHeight)
    endPoint = nextTop + endOffest(viewportHeight)
    midPoint = (endPoint - startPoint) * MID_FADE_PERCENT + startPoint
    firstMidPoint = midPoint - ((viewportHeight * GAP_PERCENT_OF_VIEWPORT)) * FADE_GAP_OF_BLACK

    # Between an item so make sure it's opacity is 1
    if viewportTop > elTop and viewportBottom < elBottom
      $("#foreground li:eq(#{index})").css opacity: 1

    # Between items so transition opacities as you scroll
    else if viewportBottom > startPoint and viewportBottom < endPoint
      percentPrevItem = 1 - (viewportBottom - startPoint) / (firstMidPoint - startPoint)
      percentNextItem = (viewportBottom - midPoint) / (endPoint - midPoint)
      $("#foreground li:eq(#{index})").css opacity: percentPrevItem
      $("#foreground li:eq(#{index + 1})").css opacity: percentNextItem


setBackgroundItemMargin = ->
  $('#background li').css 'margin-bottom': $(window).height() * GAP_PERCENT_OF_VIEWPORT