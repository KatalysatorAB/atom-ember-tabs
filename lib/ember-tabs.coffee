module.exports =
	activate: (state) ->
		EmberPodsProject = require './ember-pods-project'
		TabWatcher = require './tab-watcher'

		for path in atom.project.getPaths()
			project = new EmberPodsProject path

			project.isEmberPodsProject (yesOrNo) =>
				if yesOrNo
					@tabWatcher = new TabWatcher() unless @tabWatcher
				else
					console.log "[ember-tabs] Did not detect ember project with pods enabled."

	deactivate: ->

	serialize: ->
