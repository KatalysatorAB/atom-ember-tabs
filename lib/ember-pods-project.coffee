fs = require "fs"
stripeJsonComments = require "../vendor/strip-json-comments"

module.exports =
class EmberPodsProject
  emberCliSettings: {}

  constructor: (@rootPath) ->
    console.log "[ember-tabs] Initiating pods project with root path #{@rootPath}"

  isEmberPodsProject: (callback) =>
    @checkDotEmberCliFile callback

  shouldOverrideUsePods: =>
    atom.config.get "ember-tabs.overrideUsePods"

  checkDotEmberCliFile: (callback) =>
    dotEmberCliFile = "#{@rootPath}/.ember-cli"

    console.log "[ember-tabs] Attempting to read #{dotEmberCliFile}"

    fs.exists dotEmberCliFile, (didExist) =>
      if didExist
        console.log "[ember-tabs] .ember-cli did exist. Trying to read it"

        fs.readFile dotEmberCliFile, (err, contents) =>
          if err
            console.log "[ember-tabs] Could not read .ember-cli"
            callback(true)
          else
            console.log "[ember-tabs] Trying to parse the contents"

            try
              @emberCliSettings = JSON.parse(stripeJsonComments(contents.toString()))
              console.log "[ember-tabs] Parsing worked great."
            catch
              console.log "[ember-tabs] Invalid .ember-cli file"
              callback(true)
              return

            console.log "[ember-tabs] Everying read fine. Ignore usePods config: #{@shouldOverrideUsePods()}"
            console.log "[ember-tabs] Everying read fine. Settings: #{@emberCliSettings["usePods"]}"
            activated = @shouldOverrideUsePods() || @emberCliSettings["usePods"]
            callback activated
      else
        console.log "[ember-tabs] .ember-cli did not exist."
        callback(false)
