module.exports =
class TabWatcher
  constructor: (@podModulePrefix) ->
    console.log "[ember-tabs] Shimming tabs..."

    @textEditorObserver = atom.workspace.observeTextEditors =>
      # Race condition, tab view not added before this callback is called
      setTimeout @updateTabTitles, 10
      true

  dispose: =>
    @textEditorObserver.dispose()

    tabPackage = atom.packages.getLoadedPackage("tabs")
    for tabBar in tabPackage.mainModule.tabBarViews
      for tab in tabBar.getTabs()
        item = tab.item

        if item._emberTabsGetTitle
          item.getTitle = item._emberTabsGetTitle
          item._emberTabsGetTitle = null

        if item._emberTabsGetLongTitle
          item.getLongTitle = item._emberTabsGetLongTitle
          item._emberTabsGetLongTitle = null


  updateTabTitles: =>
    tabPackage = atom.packages.getLoadedPackage("tabs")

    if !tabPackage.mainModule.tabBarViews
      setTimeout @updateTabTitles, 50
      return

    for tabBar in tabPackage.mainModule.tabBarViews
      for tab in tabBar.getTabs()
        @updateTabTitle(tab)

  updateTabTitle: (tab) =>
    item = tab.item

    return if !item || !item.emitter || item._emberTabsGetTitle || !@getEmberPodName(item)

    item._emberTabsGetTitle = item.getTitle
    item._emberTabsGetLongTitle = item.getLongTitle

    item.getTitle = =>
      @getEmberPodName(item)

    item.getLongTitle = =>
      @getEmberPodName(item)

    item.emitter.emit "did-change-title", tab.item.getTitle()

  getEmberPodName: (item) =>
    filePath = item.getPath()
    pieces = filePath?.split("/")

    return false if !pieces || !pieces.length
    return false if !@isEmberPackagePath(filePath)

    podNamePieces = []

    fileType = pieces.pop()

    # Iterate until we hit either the app/- or the components/-folder
    while (podNamePiece = pieces.pop()) && podNamePiece not in ["app", "components", "pods"]
      podNamePieces.unshift podNamePiece

    "#{podNamePieces.join("/")}/#{fileType}"

  isEmberPackagePath: (filePath) =>
    filePath.indexOf(@podModulePrefix) != -1
