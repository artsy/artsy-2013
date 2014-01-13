# The gap between items is based on the viewport size
window.GAP_PERCENT_OF_VIEWPORT = 0.5

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
startOffest = (viewportHeight) -> 0 # (viewportHeight / 2)

# Offset what point the fade begins after the bottom of the previous element,
# based on viewportHeight
window.END_OFFSET = 1.1
endOffest = (viewportHeight) -> (viewportHeight * END_OFFSET)

IS_IPAD = true

# Use a custom scrollTop variable in place of $(window).scrollTop() for iScroll
# support.
window.scrollTop = 0

$ -> afterAllImagesLoad ->
  if IS_IPAD
    setupIscroll()
  else
    $(window).on 'scroll', onScroll
    onScroll()
  $(window).on 'resize', onResize
  onResize()
  $('#main-header-down-arrow').click onClickHeaderDownArrow

afterAllImagesLoad = (callback) ->
  total = $('img').length
  $('img').on 'load', ->
    total--
    callback() if total is 0

setupIscroll = ->
  $('#wrapper').height $(window).height()
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
  window.scrollTop = -(this.y>>0) ? $(window).scrollTop()

onClickHeaderDownArrow = ->
  $('html, body').animate {
    scrollTop: $('#content').offset().top
  }, 700, 'easeInOutCubic'
  false

onResize = ->
  setBackgroundItemGap()
  setForegroundInitHeight()
  resizeHeader()

onScroll = ->
  # fadeForeground()
  toggleForegroundInit()
  fadeHeaderOnScroll()
  fixForeground()

fixForeground = ->
  top = Math.max(0, scrollTop - $(window).height() - 100)
  $('#foreground').css(top: top)

fadeForeground = ->
  $('#background li').each ->
    index = $(@).index()

    # Alias common positions we'll be calculating
    viewportHeight = $(window).height()
    viewportBottom = scrollTop + $(window).height()
    viewportTop = scrollTop
    elTop = $(@).offset()?.top
    elBottom = elTop + $(@).height()
    nextTop = $(@).next()?.offset()?.top

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
  $('#background li').css 'margin-bottom': $(window).height() * GAP_PERCENT_OF_VIEWPORT

setForegroundInitHeight = ->
  $('#foreground').height $(window).height()

toggleForegroundInit = ->
  if scrollTop > $('#content').offset().top
    $('#foreground').removeClass 'foreground-init'
  else
    $('#foreground').addClass 'foreground-init'

resizeHeader = ->
  $('#main-header').height $(window).height()

fadeHeaderOnScroll = ->
  opacity = 1 - scrollTop / $(window).height()
  $('#main-header').css opacity: opacity