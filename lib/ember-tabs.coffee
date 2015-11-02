{CompositeDisposable} = require 'atom'

module.exports =
  activate: (state) ->
    PodFilePane = require './pod-file-pane'

    @podFilePane = new PodFilePane()

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace',
      'ember-tabs:open-file-pane': => @openFilePane()

    @changePathsObserver = atom.project.onDidChangePaths =>
      console.log "[ember-tabs] project changed paths. Re-checking for ember project."
      @reindex()
      true

    @reindex()

  deactivate: ->
    @subscriptions.dispose()
    @subscriptions = null
    @changePathsObserver.dispose()
    @changePathsObserver = null
    @podFilePane.destroy()
    @podFilePane = null
    @tabWatcher?.dispose()
    @tabWatcher = null

  reindex: ->
    EmberPodsProject = require './ember-pods-project'
    TabWatcher = require './tab-watcher'

    @projects = []

    for path in atom.project.getPaths()
      project = new EmberPodsProject path
      @projects.push project

      project.isEmberPodsProject (yesOrNo, podModulePrefix) =>
        if yesOrNo
          @tabWatcher = new TabWatcher(podModulePrefix) unless @tabWatcher
        else
          console.log "[ember-tabs] Did not detect ember project with pods enabled."

  serialize: ->

  openFilePane: ->
    return unless atom.workspace.getActiveTextEditor()

    activePath = atom.workspace.getActiveTextEditor().getPath()

    if @tabWatcher?.isEmberPackagePath(activePath) && activePath
      @podFilePane.toggle atom.workspace.getActiveTextEditor().getPath()
    else
      console.log "[ember-tabs] Tried to open file pane. Open file pane failed."
