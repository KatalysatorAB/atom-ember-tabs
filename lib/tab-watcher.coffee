module.exports =
class TabWatcher
  constructor: ->
    console.log "[ember-tabs] Shimming tabs..."

    atom.workspace.observeTextEditors =>
      # Race condition, tab view not added before this callback is called
      setTimeout @updateTabTitles, 10

  updateTabTitles: =>
    tabPackage = atom.packages.getLoadedPackage("tabs")

    if !tabPackage.mainModule.tabBarViews
      setTimeout @updateTabTitles, 50
      return

    tabBar = tabPackage.mainModule.tabBarViews[0]

    for tab in tabBar.getTabs()
      @updateTabTitle(tab)

  updateTabTitle: (tab) =>
    item = tab.item

    return if !item || !item.emitter || item._emberTabsGetTitle

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

    return item._emberTabsGetTitle() unless pieces
    return item._emberTabsGetTitle() unless @isEmberPackagePath(filePath)

    podNamePieces = []

    fileType = pieces.pop()

    # Iterate until we hit either the app/- or the components/-folder
    while (podNamePiece = pieces.pop()) && podNamePiece not in ["app", "components", "pods"]
      podNamePieces.unshift podNamePiece

    "#{podNamePieces.join("/")}/#{fileType}"

  # TODO: Try to read `podModulePrefix`
  isEmberPackagePath: (filePath) =>
    filePath.indexOf("/app/") != -1
