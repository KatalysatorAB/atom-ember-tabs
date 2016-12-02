'use babel';

const POD_MODULE_PREFIX_SEARCH = /(app\/)|(pods\/)/;

export default class TabWatcher {
  constructor() {
    console.log("[ember-tabs] Shimming tabs...");

    this.textEditorObserver = atom.workspace.observeTextEditors(() => {
      // Race condition, tab view not added before this callback is called
      setTimeout(this.updateTabTitles.bind(this), 10);
      return true;
    });
  }

  dispose() {
    this.textEditorObserver.dispose();

    const tabPackage = atom.packages.getLoadedPackage("tabs");
    tabPackage.mainModule.tabBarViews.forEach(tabBar => {
      tabBar.getTabs().forEach(tab => {
        const item = tab.item;

        if (item._emberTabsGetTitle) {
          item.getTitle = item._emberTabsGetTitle;
          item._emberTabsGetTitle = null;
        }

        if (item._emberTabsGetLongTitle) {
          item.getLongTitle = item._emberTabsGetLongTitle;
          item._emberTabsGetLongTitle = null;
        }
      });
    });
  }

  updateTabTitles() {
    const tabPackage = atom.packages.getLoadedPackage("tabs");

    if (!tabPackage.mainModule.tabBarViews) {
      setTimeout(this.updateTabTitles.bind(this), 50);
      return;
    }

    tabPackage.mainModule.tabBarViews.forEach(tabBar => {
      tabBar.getTabs().forEach(tab => {
        this.updateTabTitle(tab);
      });
    });
  }

  updateTabTitle(tab) {
    let item = tab.item;

    if (!item || !item.emitter || item._emberTabsGetTitle || !this.getEmberPodName(item)) {
      return;
    }

    item._emberTabsGetTitle = item.getTitle;
    item._emberTabsGetLongTitle = item.getLongTitle;

    item.getTitle = () => {
      return this.getEmberPodName(item) || item._emberTabsGetTitle();
    };

    item.getLongTitle = () => {
      return this.getEmberPodName(item) || item._emberTabsGetLongTitle();
    };

    item.emitter.emit("did-change-title", item.getTitle());
  }

  getEmberPodName(item) {
    let filePath = item.getPath() && item.getPath().replace(/\\/g, '/');
    let pieces = filePath && filePath.split("/");

    if (!pieces || !pieces.length) {
      return false;
    }

    if (!this.isEmberPackagePath(filePath)) {
      return false;
    }

    let podNamePieces = [];

    const fileType = pieces.pop();

    // Iterate until we hit either the app/- or the components/-folder
    while ((podNamePiece = pieces.pop()) && !["app", "components", "pods"].includes(podNamePiece)) {
      podNamePieces.unshift(podNamePiece);
    }

    return `${podNamePieces.join("/")}/${fileType}`;
  }

  isEmberPackagePath(filePath) {
    if (POD_MODULE_PREFIX_SEARCH.test(filePath)) {
      console.log(`[ember-tabs] filePath: ${filePath} WAS an ember package path! Checked against regex.`);
      return true;
    } else {
      console.log(`[ember-tabs] filePath: ${filePath} was not an ember package path. Checked against regex.`);
      return false;
    }
  }
}
