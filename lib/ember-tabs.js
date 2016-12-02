"use babel";

import { CompositeDisposable } from "atom";
import PodFilePane from "./pod-file-pane";
import config from "./config";

import EmberPodsProject from './ember-pods-project';
import TabWatcher from './tab-watcher';

export default {
  config,

  tabWatchers: null,

  activate(state) {
    console.log("ACTIVATE FUCK");

    // Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    this.subscriptions = new CompositeDisposable();

    // Register command that toggles this view
    this.subscriptions.add(atom.commands.add('atom-workspace', {
      'ember-tabs:open-file-pane': (() => this.openFilePane())
    }));

    this.subscriptions.add atom.project.onDidChangePaths(() => {
      console.log("[ember-tabs] project changed paths. Re-checking for ember project.");
      this.reindex();
      return true;
    });

    this.subscriptions.add atom.workspace.observeTextEditors(() => {
      this.reindexIfNeeded();
      return true
    });
  },

  deactivate() {
    this.subscriptions.dispose();
    this.subscriptions = null;
    this.podFilePane?.destroy();
    this.podFilePane = null;

    this.tabWatchers.forEach(tabWatcher => {
      if (tabWatcher) {
        tabWatcher.dispose();
      }
    });
    this.tabWatchers = null;
  },

  reindexIfNeeded() {
    if (this.tabWatchers == null) {
      this.reindex();
    }
  },

  reindex() {
    this.projects = [];
    this.tabWatchers = [];

    atom.project.getPaths().forEach(path => {
      const project = new EmberPodsProject(path);
      this.projects.push(project);

      project.isEmberPodsProject((yesOrNo) => {
        if (yesOrNo) {
          console.log("[ember-tabs] Detected Ember project.");
          this.tabWatchers.push(new TabWatcher());
        } else {
          console.log("[ember-tabs] Did not detect ember project with pods enabled.");
        }
      });
    });
  },

  serialize() {},

  openFilePane() {
    console.log("OPEN FILE PANE :o");
    if (!atom.workspace.getActiveTextEditor()) {
      return;
    }

    if (!this.podFilePane) {
      this.podFilePane = new PodFilePane();
    }

    const activePath = atom.workspace.getActiveTextEditor().getPath();
    if (activePath) {
      this.tabWatchers.forEach(tabWatcher => {
        this.podFilePane.toggle(activePath);
      });
    }
  }
}
