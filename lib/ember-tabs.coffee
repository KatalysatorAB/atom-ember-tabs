{CompositeDisposable} = require 'atom'

module.exports =
  activate: (state) ->
    EmberPodsProject = require './ember-pods-project'
    TabWatcher = require './tab-watcher'
    PodFilePane = require './pod-file-pane'

    @podFilePane = new PodFilePane()

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace',
      'ember-tabs:open-file-pane': => @openFilePane()

    @projects = []

    for path in atom.project.getPaths()
      project = new EmberPodsProject path
      @projects.push project

      project.isEmberPodsProject (yesOrNo, podModulePrefix) =>
        if yesOrNo
          @tabWatcher = new TabWatcher(podModulePrefix) unless @tabWatcher
        else
          console.log "[ember-tabs] Did not detect ember project with pods enabled."

  deactivate: ->
    @subscriptions.dispose()
    @podFilePane.destroy()

  serialize: ->

  openFilePane: ->
    activePath = atom.workspace.getActiveTextEditor().getPath()

    if @tabWatcher.isEmberPackagePath(activePath)
      @podFilePane.toggle atom.workspace.getActiveTextEditor().getPath()
