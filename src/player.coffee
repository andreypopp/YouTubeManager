###

  Player.js

  2013 (c) Andrey Popp <8mayday@gmail.com>

###

injectYT = ->
  tag = document.createElement('script')
  if window.location.host == 'localhost'
    tag.src = "http://www.youtube.com/player_api"
  else
    tag.src = "//www.youtube.com/player_api"
  firstScriptTag = document.getElementsByTagName('script')[0]
  firstScriptTag.parentNode.insertBefore(tag, firstScriptTag)

###
  This class mimics soundManager2's Sound.
###
class YoutubeSound

  extractIdRe = /v=([^&]+)/

  constructor: (options) ->
    this.options = options

    videoId = options.youtubeVideoId or extractIdRe.exec(options.url)[1]

    if not videoId?
      throw new Error("cannot extract videoId from URL: #{options.url}")

    this.player = new YT.Player options.playerId,
      height: options.height
      width: options.width
      videoId: videoId
      events:
        onReady: =>
          console.log 'ready'
        onStateChange: =>
          console.log 'statechange'
      playerVars:
        controls: '0'
        enablejsapi: '1'
        modestbranding: '1'
        showinfo: '0'
        playerapiid: options.id

  onReady: ->
    console.log 'ready'

  onStateChange: ->
    console.log 'statechange'

  destruct: ->
    this.player.destroy()

  load: ->

  clearOnPosition: ->

  onPosition: ->

  mute: ->
    this.player.mute()

  pause: ->
    this.player.pauseVideo()

  play: ->
    this.player.playVideo()

  resume: ->
    this.play()

  setPan: ->

  setPosition: (ms) ->
    this.player.seekTo(ms / 1000)

  setVolume: (v) ->
    this.player.setVolume(v)

  stop: ->
    this.player.stopVideo()

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
    this.player.unMute()

isYouTubeRe = /youtube.com/

PlayerJS =

  createSound: (options) ->
    if isYouTubeRe.test options.url
      new YoutubeSound(options)
    else
      soundManager.createSound(options)
