{SelectListView} = require 'atom-space-pen-views'

path = require 'path'
fs = require 'fs'

module.exports =
class PodFilePane extends SelectListView
 initialize: ->
   super
   @addClass('overlay from-top')
   @setItems([])
   @panel ?= atom.workspace.addModalPanel(item: this)
   @panel.hide()

 viewForItem: (item) ->
   "<li>#{path.basename(item)}</li>"

 confirmed: (item) ->
   atom.workspace.open(item)

 cancelled: ->
   @panel.hide()

  getElement: ->
    @element

  toggle: (onPath) =>
    @loadItemsForPath(onPath)

    if @panel.isVisible()
      @panel.hide()
    else
      @panel.show()
      @focusFilterEditor()

  loadItemsForPath: (onPath) =>
    componentFolder = path.dirname(onPath)

    fs.readdir componentFolder, (err, files) =>
      @setItems files.map((file) => "#{componentFolder}/#{file}")
