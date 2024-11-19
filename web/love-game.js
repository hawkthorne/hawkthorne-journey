"use strict";

class LoveGame extends HTMLElement {
  constructor() {
    super();

    this.LIBRARIES = ["game.js", "love.js"];
  }

  connectedCallback() {
    this.querySelector("noscript").remove();

    const submit = document.createElement("input");
    submit.type = "submit";
    submit.value = "Play";

    const form = document.createElement("form");
    form.addEventListener("submit", (_e) => {
      this.init();
      form.remove();
    });

    form.appendChild(submit);

    this.appendChild(form);
  }

  init() {
    this.Module = {
      arguments: ["./game.love"],
      INITIAL_MEMORY: 77594624,
      printErr: console.error.bind(console),
      canvas: (() => {
        const canvas = document.getElementById('canvas');

        // As a default initial behavior, pop up an alert when webgl context is lost. To make your
        // application robust, you may want to override this behavior before shipping!
        // See http://www.khronos.org/registry/webgl/specs/latest/1.0/#5.15.2
        canvas.addEventListener("webglcontextlost", function(e) {
          alert('WebGL context lost. You will need to reload the page.');
          e.preventDefault();
        }, false);

        canvas.addEventListener("contextmenu", function(e) {
          e.preventDefault();
        }, false);

        return canvas;
      })(),
      setStatus: function(text) {
        if (text) {
          console.log(text);
        }
      },
      totalDependencies: 0,
      remainingDependencies: 0,
      monitorRunDependencies: function(left) {
        this.remainingDependencies = left;
        this.totalDependencies = Math.max(this.totalDependencies, left);
        if (left) {
          this.setStatus('Preparing... (' + (this.totalDependencies - left) + '/' + this.totalDependencies + ')');
        } else {
          this.setStatus('All downloads complete.');
        }
      }
    };
    // Unfortunately, game.js needs the Module on the global object
    globalThis.Module = this.Module;

    Promise.all(
      this.LIBRARIES.map((url) => {
        return this.loadLib(url);
      })
    ).then(
      success => {
        window.addEventListener("keydown", function(e) {
          // space and arrow keys
          if([32, 37, 38, 39, 40].indexOf(e.keyCode) > -1) {
            e.preventDefault();
          }
        }, false);

        window.onerror = (event) => {
          // TODO: do not warn on ok events like simulating an infinite loop or exitStatus
          this.Module.setStatus('Exception thrown, see JavaScript console');
          this.Module.setStatus = function(text) {
            if (text) Module.printErr('[post-exception status] ' + text);
          };
        };

        this.Module.setStatus('Downloading...');
        Love(this.Module);
      },
      err => {throw new Error("Unable to load necessary libraries", { cause: err })}
    );
  }

  loadLib(url) {
    return new Promise((resolve, reject) => {
      const existingScript = document.head.querySelector("script[src='" + url + "']");
      if (existingScript) {
        existingScript.addEventListener("load", function () {
          resolve(url);
        });
        existingScript.addEventListener("error", function (error) {
          reject(error);
        });
        return;
      }
      let script = document.createElement('script');
      script.type = 'text/javascript';
      script.async = true;
      script.src = url;

      script.onload = function () {
        resolve(url);
      }
      script.onerror = function (error) {
        reject(error);
      }

      document.head.appendChild(script);
    });
  }
}

customElements.define("love-game", LoveGame);
