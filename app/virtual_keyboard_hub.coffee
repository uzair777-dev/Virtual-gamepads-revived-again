###
Created by roba91 on 15/08/2016
Virtual keyboard hub class
###

keyboard = require './virtual_keyboard'
log = require '../lib/log'
config = require '../config'

num_keyboards = config.maxKeyboards || 4

class virtual_keyboard_hub

  constructor: () ->
    @keyboards = []

  connectKeyboard: (callback) ->
    boardId = @keyboards.length

    # Check if max keyboards reached
    if boardId >= num_keyboards
      log 'warning', "Couldn't add new keyboard: no slot left."
      callback -1
      return

    # Create and connect the keyboard
    log 'info', 'Creating and connecting to keyboard number' + boardId
    @keyboards[boardId] = new keyboard()
    @keyboards[boardId].connect () ->
      callback boardId
    , (err) ->
      log 'error', "Couldn't connect to keyboard:\n" + JSON.stringify(err)
      callback -1

  disconnectKeyboard: (boardId, callback) ->
    if @keyboards[boardId]
      @keyboards[boardId].disconnect () =>
        @keyboards[boardId] = undefined
        callback()

  sendEvent: (boardId, event) ->
    if @keyboards[boardId]
      @keyboards[boardId].sendEvent event

module.exports = virtual_keyboard_hub
