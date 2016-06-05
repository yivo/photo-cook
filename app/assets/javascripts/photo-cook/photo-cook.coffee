@PhotoCook =

  initialize: -> try PhotoCook.persistDevicePixelRatio()

  resizeCacheDir: do ->
    if document? and (head = document.getElementsByTagName('head')[0])?
      for el in head.getElementsByTagName('meta')
        if el.getAttribute('name') is 'photo_cook:resize:cache_dir'
          break if value = el.getAttribute('content')
    value or 'resize-cache'

  resizeCommandRegex: /^fit|fill\-\d+x\d+$/

  # Returns device pixel ratio (float)
  # If no ratio could be determined will return normal ratio (1.0)
  devicePixelRatio: do ->
    # https://gist.github.com/marcedwards/3446599
    mediaQuery = [
      '(-webkit-min-device-pixel-ratio: 1.3)'
      '(-o-min-device-pixel-ratio: 13/10)'
      'min-resolution: 120dpi'
    ].join(', ')

    ratio = window?.devicePixelRatio

    # If no ratio found check if screen is retina
    # and if so return 2x ratio
    if not ratio and window?.matchMedia?(mediaQuery).matches
      ratio = 2.0

    parseFloat(ratio) or 1.0

  resizeMultiplier: @devicePixelRatio

  persistDevicePixelRatio: ->
    date = new Date()

    # Expires in 1 year
    date.setTime(date.getTime() + 365 * 24 * 60 * 60 * 1000)
    expires = 'expires=' + date.toUTCString()
    document.cookie = 'DevicePixelRatio=' + PhotoCook.devicePixelRatio + '; ' + expires
    return

  resize: (path, width, height, mode, options) ->
    multiplier = options?.multiplier or PhotoCook.resizeMultiplier
    command    = "#{mode or 'fit'}-#{Math.floor(width  * multiplier)}x#{Math.floor(height * multiplier)}"
    pathTokens = path.split('/');
    pathTokens.splice(-1, 0, PhotoCook.resizeCacheDir, command)
    pathTokens.join('/')

  strip: (uri) ->
    sections = uri.split('/')
    length   = sections.length
    return uri if length < 3

    cacheDir = sections[length - 3];
    command  = sections[length - 2];

    return uri unless cacheDir is PhotoCook.resizeCacheDir
    return uri unless PhotoCook.resizeCommandRegex.test(command)

    sections.splice(length - 3, 2)
    sections.join('/')

  uriRegex: /^[-a-z]+:\/\/|^(?:cid|data):|^\/\//i

    # Returns true if given URL can produce request to PhotoCook middleware on server
    # This is important thing you probably should override when using CDN or different assets delivery method
  isServableURL: (url) ->
    # By default check that URL is relative
    !PhotoCook.uriRegex.test(url)

PhotoCook.initialize()
