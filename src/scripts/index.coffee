# Constants
# ---------

# The total number of header background before it loops
TOTAL_HEADER_BACKGROUNDS = 4

# The time it takes to scroll to an element with iscroll
SCROLL_TO_EL_TIME = 700

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
$fgFacebookLink = null
$fgTwitterLink = null
$headerLogo = null
$headerBackgrounds = null

window.router = router = null # Our Backbone router (Backbone is needed b/c path.js doen't
              # support router.navigate(trigger: false))
myScroll = null # Reference to iScroll instance
contentGap = 0 # The distance from the top of the page to the content

# Use a custom scrollTop & viewportHeight variable in place of window references for
# iScroll support.
scrollTop = 0
viewportHeight = 0

# Router
# ------

class Router extends Backbone.Router

  routes:
    ':slug': 'scrollToSlug'

  scrollToSlug: (slug) ->
    $item = $("#foreground-content > li[data-slug=#{slug}]")
    index = $item.index()
    myScroll.scrollToElement(
      "#background > ul:nth-child(#{index + 1})"
      SCROLL_TO_EL_TIME, null, null,
      IScroll.utils.ease.quadratic
    )
    setTimeout onScroll, SCROLL_TO_EL_TIME

# Functions
# ---------

init = ->
  renderHeaderBackgrounds()
  cacheElements()
  $(window).on 'resize', onResize
  onResize()
  setupIscroll()
  $mainArrow.click onClickHeaderDownArrow
  $mainArrow.on 'tap', onClickHeaderDownArrow
  $fgFacebookLink.click shareOnFacebook
  $fgTwitterLink.click shareOnTwitter
  setContentGap()
  transitionHeaderBackground()
  router = new Router
  Backbone.history.start()

onResize = ->
  viewportHeight = $(window).height()
  setBackgroundItemGap()
  setContentGap()
  setHeaderSize()
  $foreground.height viewportHeight
  $mainHeader.height viewportHeight
  $footer.height viewportHeight

setHeaderSize = ->
  $('#header-background').height viewportHeight

onScroll = ->
  popLockForeground()
  fadeBetweenForegroundItems()
  fadeOutHeaderImage()
  toggleFirstForegroundItem()
  setHrefForIndex()

shareOnFacebook = (e) ->
  opts = "status=1,width=750,height=400,top=249.5,left=1462"
  url = "https://www.facebook.com/sharer/sharer.php?u=#{encodeURIComponent location.href}"
  window.open url, 'facebook', opts
  false

shareOnTwitter = (e) ->
  opts = "status=1,width=750,height=400,top=249.5,left=1462"
  $curHeader = $("#foreground li[data-slug='#{location.hash.replace('#', '')}'] h1")
  text = encodeURIComponent $curHeader.text() + ' | ' + $('title').text()
  href = encodeURIComponent location.href
  url = "https://twitter.com/intent/tweet?original_referer=#{href}&text=#{text}&url=#{href}"
  window.open url, 'twitter', opts
  false

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
  $fgFacebookLink = $('#foreground .social-button-facebook')
  $fgTwitterLink = $('#foreground .social-button-twitter')
  $headerBackgrounds = $('#header-background li')
  $headerLogo = $('#main-header-logo')

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

popLockForeground = ->
  top = scrollTop - contentGap
  x = (offset($background).bottom - viewportHeight - contentGap)
  top = Math.min(top, x)
  $foreground.css top: Math.max 0, top

fadeBetweenForegroundItems = ->
  $backgroundItems.each ->
    index = $(@).index()

    # Alias current and next items
    $curItem = $foregroundItems.eq(index)
    $nextItem = $foregroundItems.eq(index + 1)

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

    # Between an item so make sure it's opacity is 1 and the social icons are
    # pointing to the right place.
    if scrollTop > elTop and viewportBottom < elBottom
      $foregroundItems.removeClass('foreground-item-active')
      $curItem.css(opacity: 1).addClass('foreground-item-active')
      router.navigate "##{$curItem.data 'slug'}"

    # In the gap between items so transition opacities as you scroll
    else if viewportBottom > startPoint and viewportBottom < endPoint
      percentPrevItem = 1 - (viewportBottom - startPoint) / (firstMidPoint - startPoint)
      percentNextItem = (viewportBottom - midPoint) / (endPoint - midPoint)
      $curItem.css opacity: percentPrevItem
      $nextItem.css opacity: percentNextItem

fadeOutHeaderImage = ->
  $('#header-background').css opacity: 1 - (scrollTop / viewportHeight)
  $('#header-background-gradient').css opacity: (scrollTop / viewportHeight) * 2

setBackgroundItemGap = ->
  $backgroundItems.css('margin-bottom': viewportHeight * GAP_PERCENT_OF_VIEWPORT)
  $backgroundItems.last().css('margin-bottom': 0)

renderHeaderBackgrounds = ->
  $('#header-background ul').html (for i in [0..TOTAL_HEADER_BACKGROUNDS]
    "<li style='background-image: url(images/header/#{i}.jpg)'></li>"
  ).join('')
  $('#header-background li').first().show()

transitionHeaderBackground = ->
  $headerLogo.addClass 'active'
  setTimeout ->
    setTimeout ->
      index = $($headerBackgrounds.filter(-> $(@).hasClass('active'))[0]).index()
      nextIndex = if index + 1 >= TOTAL_HEADER_BACKGROUNDS then 0 else index + 1
      # $headerLogo.removeClass 'active'
      $cur = $ $headerBackgrounds.eq(index)
      $next = $ $headerBackgrounds.eq(nextIndex)
      $cur.removeClass 'active'
      $next.addClass 'active'
      transitionHeaderBackground()
    , 700
  , 1000

toggleFirstForegroundItem = ->
  if scrollTop + viewportHeight >= offset($foreground).top
    $foreground.css opacity: 1
  else
    $foreground.css opacity: 0

setHrefForIndex = ->
  if scrollTop + viewportHeight <= offset($foreground).top
    router.navigate ''

# Start your engines
# ------------------
$ init