_ = require 'underscore'
IScroll = require 'iscroll/build/iscroll-probe.js'
require './vendor/zepto.js'
require './vendor/zepto.touch.js'
morpheus = require 'morpheus'

# Constants
# ---------

MIXPANEL_ID = "297ce2530b6c87b16195b5fb6556b38f"

# The total number of header background before it loops
TOTAL_HEADER_BACKGROUNDS = 3

# The time it takes to scroll to an element with iscroll
SCROLL_TO_EL_TIME = 700

# The gap between items is based on the viewport size
GAP_PERCENT_OF_VIEWPORT = 0.6

# The gap between the content and the header
CONTENT_GAP_PERCENT_OF_VIEWPORT = 0.8

# The gap between fades of each item. e.g. 0.5 will mean the fade out of the first
# item will end right when the fade in of the next item starts.
FADE_GAP_OFFSET = 0.4

# Shre on Twitter texts ordered by the content.
TWITTER_TEXTS = [
  'Turns out the average sale on Artsy travels over 2,000 miles. See the rest: 2013.artsy.net'
  'Turns out @Artsy has a gene for Eye Contact, and it makes me uncomfortable: See the rest: 2013.artsy.net'
  'Turns out @Artsy had over 10 million artworks viewed when it launched The Armory Show. See the rest: 2013.artsy.net'
  'Turns out that @Artsy has partnered with over 200 institutions including The Getty and SFMOMA. See the rest: 2013.artsy.net'
  'Turns out the @Artsy team ran 197 miles in 26 hours. But were beaten by team “Fanny Pack Gold.” See the rest: 2013.artsy.net'
  'Turns out that JR (@JRart) made portraits of the entire @Artsy team and turned their office into an artwork. See the rest: 2013.artsy.net'
  'Turns out that @Artsy has released 37 open-source projects: See the rest: 2013.artsy.net'
  'Turns out 7 of @Artsy’s engineers are artists, and 1 is an artist on Artsy... so meta. See the rest: 2013.artsy.net'
  'Turns out over 120,000 people downloaded the @Artsy iPhone app. See the rest: 2013.artsy.net'
  # 'Turns out the @Artsy team is almost 2/3’s women: See the rest: 2013.artsy.net'
  'Turns out @Artsy’s 90,000 artworks are now part of NYC’s Public Schools Digital Literacy curriculum. See the rest: 2013.artsy.net'
  "Turns out @Artsy opened ICI's (@CuratorsINTL) benefit auction to the whole world. See the rest: 2013.artsy.net"
  'Turns out @Artsy introed more collectors to galleries in the last week of December, than all of 2012. See the rest: 2013.artsy.net'
  # 'Turns out the @Artsy team is really into Burning Man. See the rest: 2013.artsy.net'
]

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
$firstForegroundItem = null
$viewportHeights = null
$halfViewportHeights = null
$codeMask = null
$code = null
$headerBackground = null
$headerGradient = null
$graph = null
$graphLine = null
$facebookLinks = null
$twitterLinks = null
$graphContainer = null
$window = null
$body = null
$imgs = null

# Cached values
currentItemIndex = 0 # The current index of the item being viewed
graphLineLength = 0 # The total length of the graph line for SVG animation
slideshowTimeout = null # Timeout until next slide is show
stopSlideShow = false # Used to stop the slideshow after scrolling down
myScroll = null # Reference to iScroll instance
contentGap = 0 # The distance from the top of the page to the content

# Use a custom scrollTop & viewportHeight variable in place of window references for
# iScroll support.
scrollTop = 0
viewportHeight = 0
viewportWidth = null

# Setup functions
# ---------------

init = ->
  cacheElements()
  setupGraph()
  $window.on 'resize', _.throttle onResize, 100
  onResize()
  # Use IScroll to handle scroll events on an IPad, otherwise normal scroll handlers.
  # Phone uses a more responsive technique which will just toggle off the `onScroll`
  # handler based on screen size.
  if navigator.userAgent.match(/iPad/i)
    setupIScroll()
  else if not navigator.userAgent.match(/iPhone/i)
    $window.on 'scroll', onScroll
    onScroll()
  setContentGap()
  nextHeaderSlide()
  renderSocialShares()
  refreshIScrollOnImageLoads()
  mixpanel.init MIXPANEL_ID
  mixpanel.track "Viewed page"
  copyForegroundContentToBackgroundForPhone()
  attachClickHandlers()
  $body.removeClass 'body-loading'

setupGraph = ->
  graphLineLength = $graphLine[0].getTotalLength()
  $graphLine.css 'stroke-dasharray': graphLineLength

renderSocialShares = ->
  shareUrl = "http://2013.artsy.net/" or location.href
  $.ajax
    url: "http://api.facebook.com/restserver.php?method=links.getStats&urls[]=#{shareUrl}"
    success: (res) ->
      $('#social-button-facebook-count')
        .html($(res).find('share_count').text() or 0).show()
  window.twitterCountJSONPCallback = (res) ->
    return unless res.count?
    $('#social-button-twitter-count').html(res.count or 0).show()
  $.ajax
    url: "http://urls.api.twitter.com/1/urls/count.json?url=#{shareUrl}&callback=twitterCountJSONPCallback"
    dataType: 'jsonp'

setupIScroll = ->
  $body.addClass 'iscroll'
  $wrapper.height viewportHeight
  window.myScroll = myScroll = new IScroll '#wrapper',
    probeType: 3
    mouseWheel: true
    scrollbars: true
    interactiveScrollbars: true
  myScroll.on('scroll', onScroll)
  document.addEventListener 'touchmove', ((e) -> e.preventDefault()), false

copyForegroundContentToBackgroundForPhone = ->
  $foregroundItems.each (i, el) ->
    $container = $backgroundItems.eq(i).find('.phone-foreground-container')
    $container.html(
      "<div class='phone-foreground-content'>" +
        $(el).html() +
      "</div>"
    )

cacheElements = ->
  $scroller = $('#scroller')
  $backgroundItems = $('#background-content > li')
  $foreground = $('#foreground')
  $foregroundItems = $("#foreground li")
  $mainHeader = $('#main-header')
  $content = $('#content')
  $wrapper = $('#wrapper')
  $mainArrow = $('#main-header-down-arrow')
  $footer = $('#footer')
  $background = $('#background')
  $facebookLinks = $('.social-button-facebook')
  $twitterLinks = $('.social-button-twitter')
  $headerBackground = $('#header-background')
  $headerBackgrounds = $('#header-background li')
  $headerGradient = $('#header-background-gradient')
  $headerLogo = $('#main-header-logo')
  $firstForegroundItem = $('#foreground li:first-child')
  $viewportHeights = $('.viewport-height')
  $halfViewportHeights = $('.half-viewport-height')
  $codeMask = $('#background-code-mask')
  $code = $('#background-code')
  $graphLine = $('#graph-line')
  $graph = $('#graph')
  $graphContainer = $('#graph-container')
  $window = $(window)
  $body = $('body')
  $imgs = $('img')

refreshIScrollOnImageLoads = ->
  $('#background img').on 'load', _.debounce (-> myScroll?.refresh()), 1000

# Utility functions
# -----------------

# Used instead of $(el).offset to support IScroll
offset = ($el) ->
  top = -($scroller.offset()?.top - $el.offset()?.top)
  {
    top: top
    left: $el.offset()?.left
    bottom: top + $el.height()
  }

# Returns how far between scrolling two points you are. e.g. If you're halway between
# the start point and end point this will return 0.5.
percentBetween = (start, end) ->
  perc = 1 - (end - scrollTop) / (end - start)
  perc = 0 if perc < 0
  perc = 1 if perc > 1
  perc

# Get scroll top from iScroll or plain ol' window
getScrollTop = ->
  scrollTop = -myScroll?.getComputedPosition().y or $window.scrollTop()

# Wrapper over IScroll's scrollToElement to use normal window animation.
scrollToElement = (selector) ->
  time = 1000
  if myScroll
    myScroll.scrollToElement selector, time, null, null, IScroll.utils.ease.quadratic
  else
    elTop = $(selector).offset().top
    # Phone has trouble animating
    if viewportWidth <= 640
      $body[0].scrollTop = elTop
    else
      morpheus.tween time, ((pos) =>
        $body[0].scrollTop = elTop * pos
      ), morpheus.easings.quadratic


# Click handlers
# --------------

attachClickHandlers = ->
  $mainArrow.on 'tap click', onClickHeaderDownArrow
  $facebookLinks.on 'tap click', shareOnFacebook
  $twitterLinks.on 'tap click', shareOnTwitter
  $('a').on 'tap', followLinksOnTap

onClickHeaderDownArrow = ->
  scrollToElement '#intro-statement-inner'
  false

shareOnFacebook = (e) ->
  opts = "status=1,width=750,height=400,top=249.5,left=1462"
  url = "https://www.facebook.com/sharer/sharer.php?u=#{location.href}"
  open url, 'facebook', opts
  mixpanel.track "Shared on Facebook"
  false

shareOnTwitter = (e) ->
  opts = "status=1,width=750,height=400,top=249.5,left=1462"
  text = TWITTER_TEXTS[currentItemIndex]
  url = "https://twitter.com/intent/tweet?" +
        "original_referer=#{location.href}" +
        "&text=#{text}"
  open url, 'twitter', opts
  mixpanel.track "Shared on Twitter", { text: text }
  false

followLinksOnTap = (e) ->
  e.preventDefault()
  _.defer -> window.location = $(e.target).attr 'href'
  false

# On scroll functions
# -------------------

onScroll = ->
  return if viewportWidth <= 640 # For phone we ignore scroll transitions
  getScrollTop()
  toggleSlideShow()
  animateGraphLine()
  fadeOutHeaderImage()
  fadeInFirstForegroundItem()
  fadeBetweenBackgroundItems()
  popLockForeground()
  popLockCodeMask()
  popLockGraph()

fadeBetweenBackgroundItems = ->
  for el, index in $backgroundItems
    $el = $ el

    # Alias current and next items
    $curItem = $foregroundItems.eq(index)
    $nextItem = $foregroundItems.eq(index + 1)

    # Alias common positions we'll be calculating
    elTop = offset($el).top
    elBottom = elTop + $el.height()
    nextTop = elBottom + (viewportHeight * GAP_PERCENT_OF_VIEWPORT)
    gapSize = nextTop - elBottom

    # Values pertaining to when to start fading and when to fade in the next one
    endFadeOutPoint = elBottom - (gapSize * FADE_GAP_OFFSET)
    startFadeInPoint = nextTop - (gapSize * FADE_GAP_OFFSET)
    endFadeOutPoint -= viewportHeight * FADE_GAP_OFFSET
    startFadeInPoint -= viewportHeight * FADE_GAP_OFFSET

    # In between an item so ensure that this item is at opacity 1.
    if scrollTop > elTop and (scrollTop + viewportHeight) < elBottom and
       currentItemIndex isnt index
      $foregroundItems.css opacity: 0
      $curItem.css opacity: 1
      currentItemIndex = index
      break

    # In the gap between items so transition opacities as you scroll
    else if (scrollTop + viewportHeight) > elBottom and scrollTop < nextTop
      percentCurItem = 1 - percentBetween (elBottom - viewportHeight), endFadeOutPoint
      percentNextItem = percentBetween startFadeInPoint, nextTop
      # Fade out the entire foreground if it's the last item
      if index is $backgroundItems.length - 1
        $foreground.css opacity: percentCurItem
        $curItem.css 'z-index': Math.round(percentCurItem)
      else
        $curItem.css opacity: percentCurItem, 'z-index': Math.round(percentCurItem)
        $nextItem.css opacity: percentNextItem, 'z-index': Math.round(percentNextItem)
      break

fadeOutHeaderImage = ->
  return if scrollTop > viewportHeight
  $headerBackground.css opacity: 1 - (scrollTop / viewportHeight)
  $headerGradient.css opacity: (scrollTop / viewportHeight) * 2

popLockForeground = ->
  top = scrollTop - contentGap
  x = (offset($background).bottom - viewportHeight - contentGap)
  top = Math.round(Math.max 0, Math.min(top, x))
  $foreground.css top: top

popLockCodeMask = ->
  codeTop = offset($code).top
  codeBottom = codeTop + $code.height()
  return if scrollTop < codeTop or (scrollTop + viewportHeight) > codeBottom
  maskTop = scrollTop - codeTop
  $codeMask.css 'margin-top': maskTop

fadeInFirstForegroundItem = ->
  return if parseInt($foreground.css('top')) > 0
  end = offset($firstForegroundItem).top
  start = end - (viewportHeight / 2)
  opacity = (scrollTop - start) / (end - start)
  $firstForegroundItem.css opacity: opacity

toggleSlideShow = ->
  if stopSlideShow and scrollTop <= 10
    stopSlideShow = false
    nextHeaderSlide()
  else if scrollTop > 10
    stopSlideShow = true
    clearTimeout slideshowTimeout
  if scrollTop > viewportHeight
    $headerBackgrounds.removeClass('active')
  else
    $headerBackgrounds.first().addClass('active')

nextHeaderSlide = ->
  return if stopSlideShow
  slideshowTimeout = setTimeout ->
    slideshowTimeout = setTimeout ->
      index = $($headerBackgrounds.filter(-> $(@).hasClass('active'))[0]).index()
      nextIndex = if index + 1 > TOTAL_HEADER_BACKGROUNDS then 0 else index + 1
      $cur = $ $headerBackgrounds.eq(index)
      $next = $ $headerBackgrounds.eq(nextIndex)
      $cur.removeClass 'active'
      $next.addClass 'active'
      nextHeaderSlide()
    , 700
  , 1500

animateGraphLine = ->
  start = offset($backgroundItems.last()).top
  end = start + (viewportHeight * 0.8)
  pos = graphLineLength - (graphLineLength * percentBetween(start, end))
  pos = Math.max pos, 0
  $graphLine.css 'stroke-dashoffset': pos

popLockGraph = ->
  graphContainerTop = offset($graphContainer).top
  graphContainerBottom = graphContainerTop + $graphContainer.height()
  return if scrollTop < graphContainerTop or scrollTop + viewportHeight >= graphContainerBottom
  $graph.css 'margin-top': scrollTop - graphContainerTop

# On resize functions
# -------------------

onResize = ->
  viewportHeight = $window.height()
  viewportWidth = $window.width()
  setBackgroundItemGap()
  setContentGap()
  setHeaderSize()
  swapForHigherResImages()
  setViewportHeights()
  _.defer -> myScroll?.refresh()
  setTimeout relockItems, 500

relockItems = ->
  getScrollTop()
  popLockForeground()

setViewportHeights = ->
  $viewportHeights.height viewportHeight
  $halfViewportHeights.height viewportHeight / 2

setHeaderSize = ->
  $('#header-background').height viewportHeight

setContentGap = ->
  contentGap = offset($content).top

setBackgroundItemGap = ->
  $backgroundItems.css('margin-bottom': viewportHeight * GAP_PERCENT_OF_VIEWPORT)
  $backgroundItems.last().css('margin-bottom': 0)

swapForHigherResImages = ->
  if viewportWidth >= 640
    $imgs.each -> $(@).attr 'src', $(@).attr('src').replace('small', 'large')
  else
    $imgs.each -> $(@).attr 'src', $(@).attr('src').replace('large', 'small')

# Start your engines
# ------------------

$ init
