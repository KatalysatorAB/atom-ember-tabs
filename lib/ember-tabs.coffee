{CompositeDisposable} = require 'atom'

module.exports =
  tabWatchers: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace',
      'ember-tabs:open-file-pane': => @openFilePane()

    @subscriptions.add atom.project.onDidChangePaths =>
      console.log "[ember-tabs] project changed paths. Re-checking for ember project."
      @reindex()
      true

    @subscriptions.add atom.workspace.observeTextEditors =>
      @reindexIfNeeded()
      true

  deactivate: ->
    @subscriptions.dispose()
    @subscriptions = null
    @podFilePane?.destroy()
    @podFilePane = null

    for tabWatcher in @tabWatchers
      tabWatcher?.dispose()
    @tabWatchers = null

  reindexIfNeeded: ->
    if @tabWatchers == null
      @reindex()

  reindex: ->
    EmberPodsProject = require './ember-pods-project'
    TabWatcher = require './tab-watcher'

    @projects = []
    @tabWatchers = []

    for path in atom.project.getPaths()
      project = new EmberPodsProject path
      @projects.push project

      project.isEmberPodsProject (yesOrNo, podModulePrefix) =>
        if yesOrNo
          @tabWatchers.push new TabWatcher(podModulePrefix)
        else
          console.log "[ember-tabs] Did not detect ember project with pods enabled."

  serialize: ->

  openFilePane: ->
    return unless atom.workspace.getActiveTextEditor()

    unless @podFilePane
      PodFilePane = require './pod-file-pane'
      @podFilePane = new PodFilePane()

    activePath = atom.workspace.getActiveTextEditor().getPath()

    for tabWatcher in @tabWatchers
      if tabWatcher.isEmberPackagePath(activePath) && activePath
        @podFilePane.toggle atom.workspace.getActiveTextEditor().getPath()
        return
      else
        console.log "[ember-tabs] Tried to open file pane. Open file pane failed."
