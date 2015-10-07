fs = require "fs"
stripeJsonComments = require "../vendor/strip-json-comments"

module.exports =
class EmberPodsProject
  emberCliSettings: {}

  constructor: (@rootPath) ->

  isEmberPodsProject: (callback) =>
    @checkDotEmberCliFile callback

  checkDotEmberCliFile: (callback) =>
    dotEmberCliFile = "#{@rootPath}/.ember-cli"
    fs.exists dotEmberCliFile, (didExist) =>
      if didExist
        fs.readFile dotEmberCliFile, (err, contents) =>
          if err
            callback(false)
          else
            try
              @emberCliSettings = JSON.parse(stripeJsonComments(contents.toString()))
            catch
              console.log "[ember-tabs] Invalid .ember-cli file"
              callback(false)
              return

            @readPodModulePrefix()
            callback @emberCliSettings["usePods"], @podModulePrefix
      else
        callback(false)

  readPodModulePrefix: =>
    # read from config/environment.js podModulePrefix
    try
      @podModulePrefix = require("#{@rootPath}/config/environment")("development").podModulePrefix || "/app/"
    catch
      @podModulePrefix = '/app/'
