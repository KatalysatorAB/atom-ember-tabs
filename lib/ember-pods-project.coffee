fs = require "fs"
stripeJsonComments = require "../vendor/strip-json-comments"

DEFAULT_POD_MODULE_PREFIX = "/app/"

module.exports =
class EmberPodsProject
  emberCliSettings: {}
  podModulePrefix: DEFAULT_POD_MODULE_PREFIX

  constructor: (@rootPath) ->

  isEmberPodsProject: (callback) =>
    @checkDotEmberCliFile callback

  checkDotEmberCliFile: (callback) =>
    dotEmberCliFile = "#{@rootPath}/.ember-cli"
    fs.exists dotEmberCliFile, (didExist) =>
      if didExist
        fs.readFile dotEmberCliFile, (err, contents) =>
          if err
            callback(false, @podModulePrefix)
          else
            try
              @emberCliSettings = JSON.parse(stripeJsonComments(contents.toString()))
            catch
              console.log "[ember-tabs] Invalid .ember-cli file"
              callback(true, @podModulePrefix)
              return

            @readPodModulePrefix()
            callback @emberCliSettings["usePods"], @podModulePrefix
      else
        callback(false)

  readPodModulePrefix: =>
    # read from config/environment.js podModulePrefix
    try
      @podModulePrefix = require("#{@rootPath}/config/environment")("development").podModulePrefix || DEFAULT_POD_MODULE_PREFIX
    catch
      @podModulePrefix = DEFAULT_POD_MODULE_PREFIX
