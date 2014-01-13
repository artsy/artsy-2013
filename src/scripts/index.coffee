# Constants
# ---------

# The gap between items is based on the viewport size
GAP_PERCENT_OF_VIEWPORT = 0.5

# The point at which one foreground item is at 0 opacity and the next item is fading in.
# e.g. 0.9 will mean the fade out of the first item is long and the fade in of the next
# item is very short.
MID_FADE_PERCENT = 0.5

# The gap size based on the viewport. Dial this number down to have a smaller gap where
# the foreground item is at 0 opacity, dial it up to have a sharper fade out and a longer
# gap of black between items.
FADE_GAP_OF_BLACK = 0.6

# Offset what point the fade begins after the bottom of the previous element,
# based on viewportHeight
startOffest = (vpHeight) -> 0 # (vpHeight / 2)

# Offset what point the fade begins after the bottom of the previous element,
# based on viewportHeight
END_OFFSET = 1.1
endOffest = (vpHeight) -> (vpHeight * END_OFFSET)

# Top-level variables
# -------------------

myScroll = null # Reference to iScroll instance
contentGap = 0

# Use a custom scrollTop & viewportHeight variable in place of window references for
# iScroll support.
scrollTop = 0
viewportHeight = 0

# Functions
# ---------

$ -> imagesLoaded 'body', init

init = ->
  $(window).on 'resize', onResize
  onResize()
  setupIscroll()
  $('#main-header-down-arrow').click onClickHeaderDownArrow
  setContentGap()

setupIscroll = ->
  $('#wrapper').height viewportHeight
  myScroll = new IScroll '#wrapper',
    momentum: false
    probeType: 3
    mouseWheel: true
  myScroll.on('scroll', setScrollTop)
  myScroll.on('scrollEnd', setScrollTop)
  myScroll.on('scroll', onScroll)
  myScroll.on('scrollEnd', onScroll)
  document.addEventListener('touchmove', ((e) -> e.preventDefault()), false);

setScrollTop = ->
  scrollTop = -(this.y>>0)

setContentGap = ->
  contentGap = -($('#scroller').offset().top - $('#content').offset().top)

onClickHeaderDownArrow = ->
  $('html, body').animate {
    scrollTop: $('#content').offset().top
  }, 700, 'easeInOutCubic'
  false

onResize = ->
  viewportHeight = $(window).height()
  setBackgroundItemGap()
  setForegroundInitHeight()
  resizeHeader()
  setContentGap()

onScroll = ->
  fixForeground()
  fadeForeground()
  toggleForegroundInit()
  fadeHeaderOnScroll()

fixForeground = ->
  top = scrollTop - contentGap
  $('#foreground').css top: Math.max(top, 0)

fadeForeground = ->
  $('#background li').each ->
    index = $(@).index()

    # Alias common positions we'll be calculating
    viewportBottom = scrollTop + viewportHeight
    elTop = $(@).offset()?.top
    elBottom = elTop + $(@).height()
    nextTop = $(@).next()?.offset()?.top

    console.log viewportBottom, elTop, elBottom, nextTop

    # Values pertaining to when to start fading and when to fade in the next one
    startPoint = elBottom + startOffest(viewportHeight)
    endPoint = nextTop + endOffest(viewportHeight)
    midPoint = (endPoint - startPoint) * MID_FADE_PERCENT + startPoint
    firstMidPoint = midPoint - ((viewportHeight * GAP_PERCENT_OF_VIEWPORT)) * FADE_GAP_OF_BLACK

    # Between items so transition opacities as you scroll
    if viewportBottom > startPoint and viewportBottom < endPoint
      percentPrevItem = 1 - (viewportBottom - startPoint) / (firstMidPoint - startPoint)
      percentNextItem = (viewportBottom - midPoint) / (endPoint - midPoint)
      $("#foreground li:eq(#{index})").css opacity: percentPrevItem
      $("#foreground li:eq(#{index + 1})").css opacity: percentNextItem

setBackgroundItemGap = ->
  $('#background li').css 'margin-bottom': viewportHeight * GAP_PERCENT_OF_VIEWPORT

setForegroundInitHeight = ->
  $('#foreground').height viewportHeight

toggleForegroundInit = ->
  return

resizeHeader = ->
  $('#main-header').height viewportHeight

fadeHeaderOnScroll = ->
  opacity = 1 - scrollTop / viewportHeight
  $('#main-header').css opacity: opacity