fs = require "fs"
stripeJsonComments = require "../vendor/strip-json-comments"

DEFAULT_POD_MODULE_PREFIX = "/app/"

module.exports =
class EmberPodsProject
  emberCliSettings: {}
  podModulePrefix: DEFAULT_POD_MODULE_PREFIX

  constructor: (@rootPath) ->
    console.log "[ember-tabs] Initiating pods project with root path #{@rootPath}"

  isEmberPodsProject: (callback) =>
    @checkDotEmberCliFile callback

  checkDotEmberCliFile: (callback) =>
    dotEmberCliFile = "#{@rootPath}/.ember-cli"

    console.log "[ember-tabs] Attempting to read #{dotEmberCliFile}"

    fs.exists dotEmberCliFile, (didExist) =>
      if didExist
        console.log "[ember-tabs] .ember-cli did exist. Trying to read it"

        fs.readFile dotEmberCliFile, (err, contents) =>
          if err
            console.log "[ember-tabs] Could not read .ember-cli, defaulting to #{@podModulePrefix}"
            callback(true, @podModulePrefix)
          else
            console.log "[ember-tabs] Trying to parse the contents"
            try
              @emberCliSettings = JSON.parse(stripeJsonComments(contents.toString()))
              console.log "[ember-tabs] Parsing worked great."
            catch
              console.log "[ember-tabs] Invalid .ember-cli file"
              callback(true, @podModulePrefix)
              return

            @readPodModulePrefix()
            console.log "[ember-tabs] Everying read fine. Settings: #{@emberCliSettings["usePods"]} and #{@podModulePrefix}"
            callback @emberCliSettings["usePods"], @podModulePrefix
      else
        console.log "[ember-tabs] .ember-cli did not exist."
        callback(false)

  readPodModulePrefix: =>
    # read from config/environment.js podModulePrefix
    console.log "[ember-tabs] Trying to read #{@rootPath}/config/environment"
    try
      @podModulePrefix = require("#{@rootPath}/config/environment")("development").podModulePrefix || DEFAULT_POD_MODULE_PREFIX
      console.log "[ember-tabs] Was able to read #{@rootPath}/config/environment, parsed #{@podModulePrefix} from it"
    catch
      @podModulePrefix = DEFAULT_POD_MODULE_PREFIX
      console.log "[ember-tabs] Could not read environment, so defaulting to #{@podModulePrefix}"
