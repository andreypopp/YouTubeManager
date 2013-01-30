###

  youtubeManager

  2013 (c) Andrey Popp <8mayday@gmail.com>

###

class YoutubeSound

  extractIdRe = /v=([^&]+)/

  constructor: (options) ->
    this.options = options

    this.buffered = undefined
    this.bytesLoaded = undefined
    this.isBuffering = undefined
    this.connected = undefined
    this.duration = undefined
    this.durationEstimate = undefined
    this.isHTML5 = false
    this.loaded = false
    this.muted = false
    this.paused = false
    this.playState = undefined
    this.position = 0
    this.readyState = 0

    this._poller = undefined
    this._previousState = undefined

    videoId = options.youtubeVideoId or extractIdRe.exec(options.url)[1]

    if not videoId?
      throw new Error("cannot extract videoId from URL: #{options.url}")

    this.player = new YT.Player options.playerId,
      height: options.height
      width: options.width
      videoId: videoId
      events:
        onReady: => this.onReady()
        onStateChange: => this.onStateChange()
      playerVars:
        controls: '0'
        enablejsapi: '1'
        modestbranding: '1'
        showinfo: '0'
        playerapiid: options.id

  onReady: ->
    this.duration = this.durationEstimate = this.player.getDuration() * 1000
    if this.options.autoPlay
      this.play()

  onStateChange: ->
    state = this.player.getPlayerState()

    if state == -1
      this.loaded = true

    if state == YT.PlayerState.PLAYING
      this._startPoller()
      this.paused = false
      this.options.onplay() if this.options.onplay
      this.options.onresume() if this.options.onresume and this._previousState == YT.PlayerState.PAUSED
    else if state == YT.PlayerState.PAUSED
      this._stopPoller()
      this.paused = true
      this.options.onpause() if this.options.onpause
    else if state == YT.PlayerState.ENDED
      this.paused = false
      this._stopPoller()
      this.options.onfinish() if this.options.onfinish

    this._previousState = state

  _startPoller: ->
    this._poller = setInterval(
      (=> this._updateState()),
      this.options.pollingInterval or 500)

  _stopPoller: ->
    return unless this._poller
    clearInterval(this._poller)
    this._poller = undefined

  _updateState: ->
    this.position = this.player.getCurrentTime() * 1000
    this.options.whileplaying() if this.options.whileplaying

  destruct: ->
    this.player.destroy()

  load: ->

  clearOnPosition: ->

  onPosition: ->

  mute: ->
    this.muted = true
    this.player.mute()

  pause: ->
    this.player.pauseVideo()

  play: ->
    if this.player.playVideo?
      this.player.playVideo()
    else
      this.options.autoPlay = true

  resume: ->
    this.play()

  setPan: ->

  setPosition: (ms) ->
    this.player.seekTo(ms / 1000)

  setVolume: (v) ->
    this.player.setVolume(v)

  stop: ->
    this.player.stopVideo()
    this.position = 0

  toggleMute: ->
    if this.player.isMuted()
      this.unmute()
    else
      this.mute()

  togglePause: ->
    if this.player.getPlayerState() == YT.PlayerState.PLAYING
      this.pause()
    else
      this.play()

  unload: ->

  unmute: ->
    this.muted = false
    this.player.unMute()

youtubeManager =

  createSound: (options) ->
    new YoutubeSound(options)

  setup: (options = {}) ->
    oldCallback = window.onYouTubeIframeAPIReady if window.onYouTubeIframeAPIReady?
    window.onYouTubeIframeAPIReady = ->
      options.onready() if options.onready
      oldCallback() if oldCallback
    this._injectScript()

  _injectScript: ->
    tag = document.createElement('script')
    if window.location.host == 'localhost'
      tag.src = "http://www.youtube.com/player_api"
    else
      tag.src = "//www.youtube.com/player_api"
    firstScriptTag = document.getElementsByTagName('script')[0]
    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag)

define(youtubeManager) if define?.amd?
