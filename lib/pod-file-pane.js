"use babel";

import { SelectListView } from 'atom-space-pen-views';

import path from "path";
import fs from "fs";

export default class PodFilePane extends SelectListView {
  initialize() {
    super();
    this.addClass('overlay from-top');
    this.setItems([]);
    if (!this.panel) {
      this.panel = atom.workspace.addModalPanel({ item: this });
    }
    this.panel.hide();
  }

  destroy() {
    this.remove();
  }

  viewForItem(item) {
    return `<li><span>${path.basename(path.dirname(item))}/</span><strong>${path.basename(item)}</strong></li>`;
  }

  confirmed(item) {
    atom.workspace.open(item);
  }

  cancelled() {
   this.panel.hide();
 }

  getElement() {
    return this.element;
  }

  toggle(onPath) {
    this.loadItemsForPath(onPath);

    if (this.panel.isVisible()) {
      this.panel.hide();
    } else {
      this.panel.show();
      this.focusFilterEditor();
    }
  }

  loadItemsForPath(onPath) {
    const componentFolder = path.dirname(onPath);

    fs.readdir(componentFolder, (err, files) => {
      if (files) {
        this.setItems(files.map(file => `${componentFolder}/${file}`));
      }
    });
  }
}
