# The gap between items is based on the viewport size
window.GAP_PERCENT_OF_VIEWPORT = 0.7

# The point at which one foreground item is at 0 opacity and the next item is fading in.
# e.g. 0.9 will mean the fade out of the first item is long and the fade in of the next
# item is very short.
window.MID_FADE_PERCENT = 0.5

# The gap size based on the viewport. Dial this number down to have a smaller gap where
# the foreground item is at 0 opacity, dial it up to have a sharper fade out and a longer
# gap of black between items.
window.FADE_GAP_OF_BLACK = 0.6

# Dial this number up to make the craning (faux-pop-lock swipe off the page) faster
# or dial down for slower.
window.CRANE_DRAG = 0.35

# Offset what point the fade begins after the bottom of the previous element,
# based on viewportHeight
window.START_OFFSET = 0
startOffest = (viewportHeight) -> viewportHeight * START_OFFSET

# Offset what point the fade begins after the bottom of the previous element,
# based on viewportHeight
window.END_OFFSET = 0
endOffest = (viewportHeight) -> viewportHeight * END_OFFSET

# Play with different animations by toggline these on/off
window.CRANE_FIRST_ITEM = false
window.CRANE_SECOND_ITEM = false
window.FADE_FIRST_ITEM = true
window.FADE_SECOND_ITEM = true

$ ->
  $('html, body').animate { scrollTop: 50}, 10, ->
    $(window).on 'scroll', onScroll
    $(window).on 'resize', setBackgroundItemMargin
    onScroll()
    setBackgroundItemMargin()

onScroll = ->
  $('#background li').each ->
    index = $(@).index()
    $item = $("#foreground li:eq(#{index})")
    $next = $("#foreground li:eq(#{index + 1})")

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
      $item.css { margin: 0, opacity: 1 }

    # Between items so transition opacities as you scroll
    else if viewportBottom > startPoint and viewportBottom < endPoint

      # Fade the items out
      percentItem = 1 - (viewportBottom - startPoint) / (firstMidPoint - startPoint)
      percentNext = (viewportBottom - midPoint) / (endPoint - midPoint)

      if FADE_FIRST_ITEM
        $item.css opacity: percentItem
      if FADE_SECOND_ITEM
        $next.css opacity: percentNext

      # Swipe the items off, faux-pop-lock
      if CRANE_FIRST_ITEM
        offset = (viewportHeight - percentItem * viewportHeight) * CRANE_DRAG
        $item.css 'margin-top': Math.min(-Math.round(offset), 0)
      if CRANE_SECOND_ITEM
        marginTop = (viewportHeight - percentItem * viewportHeight) * CRANE_DRAG
        $next.css 'margin-top': Math.max(viewportHeight - Math.round(marginTop), 0)


setBackgroundItemMargin = ->
  $('#background li').css 'margin-bottom': $(window).height() * GAP_PERCENT_OF_VIEWPORT