_ = require './vendor/underscore.js'
IScroll = require './vendor/iscroll-probe.js'
require './vendor/zepto.js'
require './vendor/zepto.touch.js'

# Constants
# ---------

MIXPANEL_ID = "297ce2530b6c87b16195b5fb6556b38f"

# The total number of header background before it loops
TOTAL_HEADER_BACKGROUNDS = 3

# The time it takes to scroll to an element with iscroll
SCROLL_TO_EL_TIME = 700

# The gap between items is based on the viewport size
GAP_PERCENT_OF_VIEWPORT = 0.5

# The gap between the content and the header
CONTENT_GAP_PERCENT_OF_VIEWPORT = 0.8

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
$firstForegroundItem = null
$viewportHeights = null
$halfViewportHeights = null
$codeMask = null
$code = null

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
  renderHeaderBackgrounds()
  cacheElements()
  $(window).on 'resize', _.throttle onResize, 200
  onResize()
  setupIScroll()
  $mainArrow.click onClickHeaderDownArrow
  $mainArrow.on 'tap', onClickHeaderDownArrow
  $fgFacebookLink.click shareOnFacebook
  $fgTwitterLink.click shareOnTwitter
  setContentGap()
  transitionHeaderBackground()
  renderSocialShares()
  refreshIscrollOnImageLoads()
  mixpanel.init MIXPANEL_ID
  mixpanel.track "Viewed page"
  copyForegroundContentToBackgroundForPhone()

renderHeaderBackgrounds = ->
  $('#header-background ul').html (for i in [0..TOTAL_HEADER_BACKGROUNDS]
    "<li style='background-image: url(images/header/#{i}.jpg)'></li>"
  ).join('')
  $('#header-background li').first().show()

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
  $wrapper.height viewportHeight
  myScroll = new IScroll '#wrapper',
    probeType: 3
    mouseWheel: true
    scrollbars: true
    interactiveScrollbars: true
  myScroll.on('scroll', setScrollTop)
  myScroll.on('scrollEnd', setScrollTop)
  myScroll.on('scroll', onScroll)
  myScroll.on('scrollEnd', onScroll)
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
  $fgFacebookLink = $('#foreground .social-button-facebook')
  $fgTwitterLink = $('#foreground .social-button-twitter')
  $headerBackgrounds = $('#header-background li')
  $headerLogo = $('#main-header-logo')
  $firstForegroundItem = $('#foreground li:first-child')
  $viewportHeights = $('.viewport-height')
  $halfViewportHeights = $('.half-viewport-height')
  $codeMask = $('#background-code-mask')
  $code = $('#background-code')

refreshIscrollOnImageLoads = ->
  $('#background img').on 'load', _.debounce (-> myScroll.refresh()), 1000

# Utility functions
# -----------------

offset = ($el) ->
  top = -($scroller.offset()?.top - $el.offset()?.top)
  {
    top: top
    left: $el.offset()?.left
    bottom: top + $el.height()
  }

# Click handlers
# --------------

onClickHeaderDownArrow = ->
  myScroll.scrollToElement '#content', 1200, null, null, IScroll.utils.ease.quadratic
  false

shareOnFacebook = (e) ->
  mixpanel.track "Shared on Facebook"
  opts = "status=1,width=750,height=400,top=249.5,left=1462"
  url = "https://www.facebook.com/sharer/sharer.php?u=#{location.href}"
  open url, 'facebook', opts
  false

shareOnTwitter = (e) ->
  mixpanel.track "Shared on Twitter"
  opts = "status=1,width=750,height=400,top=249.5,left=1462"
  $curHeader = $("#foreground li[data-slug='#{location.hash.replace('#', '')}'] h1")
  text = encodeURIComponent $curHeader.text() + ' | ' + $('title').text()
  url = "https://twitter.com/intent/tweet?" +
        "original_referer=#{location.href}" +
        "&text=#{text}" +
        "&url=#{location.href}"
  open url, 'twitter', opts
  false

# On scroll functions
# -------------------

onScroll = ->
  popLockCodeMask()
  return if viewportWidth <= 640
  popLockForeground()
  fadeBetweenForegroundItems()
  fadeOutHeaderImage()
  fadeInFirstForegroundItem()

setScrollTop = ->
  scrollTop = -(this.y>>0)

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

    # In the gap between items so transition opacities as you scroll
    else if viewportBottom > startPoint and viewportBottom < endPoint
      percentPrevItem = 1 - (viewportBottom - startPoint) / (firstMidPoint - startPoint)
      percentNextItem = (viewportBottom - midPoint) / (endPoint - midPoint)
      $curItem.css opacity: percentPrevItem
      $nextItem.css opacity: percentNextItem

fadeOutHeaderImage = ->
  $('#header-background').css opacity: 1 - (scrollTop / viewportHeight)
  $('#header-background-gradient').css opacity: (scrollTop / viewportHeight) * 2

popLockForeground = ->
  top = scrollTop - contentGap
  x = (offset($background).bottom - viewportHeight - contentGap)
  top = Math.min(top, x)
  $foreground.css top: Math.max 0, top

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

popLockCodeMask = ->
  codeTop = offset($code).top
  codeBottom = offset($code).bottom
  return if scrollTop < codeTop or (scrollTop + viewportHeight) > codeBottom
  maskTop = scrollTop - codeTop
  $codeMask.css 'margin-top': maskTop

fadeInFirstForegroundItem = ->
  end = offset($firstForegroundItem).top
  return if scrollTop >= end
  start = offset($firstForegroundItem).top - (viewportHeight / 2)
  opacity = (scrollTop - start) / (end - start)
  $firstForegroundItem.css opacity: opacity

# On resize functions
# -------------------

onResize = ->
  viewportHeight = $(window).height()
  viewportWidth = $(window).width()
  setBackgroundItemGap()
  setContentGap()
  setHeaderSize()
  $viewportHeights.height viewportHeight
  $halfViewportHeights.height viewportHeight / 2
  _.defer -> myScroll.refresh()

setHeaderSize = ->
  $('#header-background').height viewportHeight

setContentGap = ->
  $content.css 'margin-top': (viewportHeight * CONTENT_GAP_PERCENT_OF_VIEWPORT)
  contentGap = offset($content).top

setBackgroundItemGap = ->
  $backgroundItems.css('margin-bottom': viewportHeight * GAP_PERCENT_OF_VIEWPORT)
  $backgroundItems.last().css('margin-bottom': 0)

# Start your engines
# ------------------

$ init
