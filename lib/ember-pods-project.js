"use babel";

import fs from "fs";
import stripJsonComments from "../vendor/strip-json-comments";

export default class EmberPodsProject {
  constructor(rootPath) {
    this.rootPath = rootPath;
    this.emberCliSettings = {};
    console.log(`[member-tabs] Initiating pods project with root path!!!!!!!!!!!! ${this.rootPath}`);
  }

  isEmberPodsProject(callback) {
    this.checkDotEmberCliFile(callback);
  }

  shouldOverrideUsePods() {
    return atom.config.get("ember-tabs.overrideUsePods");
  }

  checkDotEmberCliFile(callback) {
    const dotEmberCliFile = `${this.rootPath}/.ember-cli`;

    console.log(`[ember-tabs] Attempting to read ${dotEmberCliFile}`);

    fs.exists(dotEmberCliFile, didExist => {
      if (didExist) {
        console.log("[ember-tabs] .ember-cli did exist. Trying to read it");

        fs.readFile(dotEmberCliFile, (err, contents) => {
          if (err) {
            console.log("[ember-tabs] Could not read .ember-cli");
            callback(true);
          } else {
            console.log("[ember-tabs] Trying to parse the contents");

            try {
              this.emberCliSettings = JSON.parse(stripJsonComments(contents.toString()));
              console.log("[ember-tabs] Parsing worked great.");
            } catch (e) {
              console.log("[ember-tabs] Invalid .ember-cli file");
              callback(true);
              return;
            }

            console.log(`[ember-tabs] Everying read fine. Ignore usePods config: ${this.shouldOverrideUsePods()}`);
            console.log(`[ember-tabs] Everying read fine. Settings: ${this.emberCliSettings["usePods"]}`);

            const activated = this.shouldOverrideUsePods() || this.emberCliSettings["usePods"];
            callback(activated);
          }
        });
      } else {
        console.log("[ember-tabs] .ember-cli did not exist.");
        callback(false);
      }
    });
  }
}
