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

# Cached elements
$scroller = null
$backgroundItems = null
$foreground = null
$mainHeader = null
$content = null
$wrapper = null
$mainArrow = null
$foregroundItems = null
$footer = null
$background = null

myScroll = null # Reference to iScroll instance
contentGap = 0 # The distance from the top of the page to the content

# Use a custom scrollTop & viewportHeight variable in place of window references for
# iScroll support.
scrollTop = 0
viewportHeight = 0

# Functions
# ---------

init = ->
  cacheElements()
  $(window).on 'resize', onResize
  onResize()
  setupIscroll()
  $mainArrow.click onClickHeaderDownArrow
  $mainArrow.on 'tap', onClickHeaderDownArrow
  setContentGap()

cacheElements = ->
  $scroller = $('#scroller')
  $backgroundItems = $('#background li')
  $foreground = $('#foreground')
  $foregroundItems = $("#foreground li")
  $mainHeader = $('#main-header')
  $content = $('#content')
  $wrapper = $('#wrapper')
  $mainArrow = $('#main-header-down-arrow')
  $footer = $('#footer')
  $background = $('#background')

setupIscroll = ->
  $wrapper.height viewportHeight
  myScroll = new IScroll '#wrapper',
    probeType: 3
    mouseWheel: true
  myScroll.on('scroll', setScrollTop)
  myScroll.on('scrollEnd', setScrollTop)
  myScroll.on('scroll', onScroll)
  myScroll.on('scrollEnd', onScroll)
  document.addEventListener 'touchmove', ((e) -> e.preventDefault()), false

offset = window.offset = ($el) ->
  top = -($scroller.offset()?.top - $el.offset()?.top)
  {
    top: top
    left: $el.offset()?.left
    bottom: top + $el.height()
  }

setScrollTop = ->
  scrollTop = -(this.y>>0)

setContentGap = ->
  contentGap = offset($content).top

onClickHeaderDownArrow = ->
  myScroll.scrollToElement '#content', 700, null, null, IScroll.utils.ease.quadratic
  false

onResize = ->
  viewportHeight = $(window).height()
  setBackgroundItemGap()
  setContentGap()
  $foreground.height viewportHeight
  $mainHeader.height viewportHeight
  $footer.height viewportHeight

onScroll = ->
  fixForeground()
  fadeBetweenForegroundItems()
  fadeHeaderOnScroll()

fixForeground = ->
  top = scrollTop - contentGap
  x = (offset($background).bottom - viewportHeight - contentGap)
  top = Math.min(top, x)
  # console.log top, _top, x
  $foreground.css top: Math.max 0, top

fadeBetweenForegroundItems = ->
  $backgroundItems.each ->
    index = $(@).index()

    # Alias common positions we'll be calculating
    viewportBottom = scrollTop + viewportHeight
    elTop = offset($(@)).top
    elBottom = offset($(@)).bottom
    nextTop = offset($(@).next()).top

    # Values pertaining to when to start fading and when to fade in the next one
    startPoint = elBottom + startOffest(viewportHeight)
    endPoint = nextTop + endOffest(viewportHeight)
    midPoint = (endPoint - startPoint) * MID_FADE_PERCENT + startPoint
    firstMidPoint = midPoint - ((viewportHeight * GAP_PERCENT_OF_VIEWPORT)) * FADE_GAP_OF_BLACK

    # Between items so transition opacities as you scroll
    if viewportBottom > startPoint and viewportBottom < endPoint
      percentPrevItem = 1 - (viewportBottom - startPoint) / (firstMidPoint - startPoint)
      percentNextItem = (viewportBottom - midPoint) / (endPoint - midPoint)
      $foregroundItems.eq(index).css opacity: percentPrevItem
      $foregroundItems.eq(index + 1).css opacity: percentNextItem

setBackgroundItemGap = ->
  $backgroundItems.css('margin-bottom': viewportHeight * GAP_PERCENT_OF_VIEWPORT)
  $backgroundItems.last().css('margin-bottom': 0)

fadeHeaderOnScroll = ->
  opacity = 1 - scrollTop / viewportHeight
  $mainHeader.css opacity: opacity

# Start your engines
# ------------------
$ init