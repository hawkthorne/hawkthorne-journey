(function(){
if (!window.__jah__) window.__jah__ = {resources:{}, assetURL: "hawkthorne_cocos/assets"};
__jah__.resources["/__builtin__/events.js"] = {data: function (exports, require, module, __filename, __dirname) {
/**
 * @namespace
 * Support for listening for and triggering events
 */
var events = {};


/**
 * @class
 * Jah Event
 *
 * @memberOf events
 */
function Event (type, cancelable) {
    if (cancelable) {
        Object.defineProperty(this, 'cancelable', { value: true, writable: false })
    }
    this.type = type
}
Object.defineProperty(Event.prototype, 'defaultPrevented', { value: false, writable: false })
Object.defineProperty(Event.prototype, 'cancelable',       { value: false, writable: false })

Event.prototype = /** @lends events.Event# */ {
    constructor: Event
  , preventDefault: function () {
        if (this.cancelable) {
            Object.defineProperty(this, 'defaultPrevented', { value: true, writable: false })
        }
    }
}
events.Event = Event



/**
 * @class
 * Jah Property Event
 *
 * @memberOf events
 * @extends events.Event
 */
function PropertyEvent () {
    Event.apply(this, arguments)
}
PropertyEvent.prototype = Object.create(Event.prototype)
events.PropertyEvent = PropertyEvent




/**
 * @private
 * @ignore
 * Add a magical setter to notify when the property does change
 */
function watchProperty (target, name) {
    var propDesc
      , realTarget = target

    // Search up prototype chain to find where the property really lives
    while (!(propDesc = Object.getOwnPropertyDescriptor(realTarget, name))) {
        realTarget = Object.getPrototypeOf(realTarget)

        if (!realTarget) {
            break
        }
    }

    if (!propDesc) {
        throw new Error("Unable to find property: " + name)
    }

    /**
     * @ignore
     * @inner
     * Triggers the 'beforechange' event on a property
     */
    var triggerBefore = function (target, newVal) {
        var e = new PropertyEvent('beforechange', true)
        e.target = {object: target, property: name}
        e.newValue = newVal
        events.triggerProperty(target, name, e.type, e)

        return e
    }

    /**
     * @ignore
     * @inner
     * Triggers the 'change' event on a property
     */
    var triggerAfter = function (target, prevVal) {
        var e = new PropertyEvent('change')
        e.target = {object: target, property: name}
        e.oldValue = prevVal
        events.triggerProperty(target, name, e.type, e)

        return e
    }

    // Listening to a normal property
    if (propDesc.writable) {
        var currentVal = propDesc.value
          , prevVal
          , getter = function () {
                return currentVal
            }
          , setter = function (newVal) {
                var e = triggerBefore(this, newVal)
                if (!e.defaultPrevented) {
                    prevVal = currentVal
                    currentVal = newVal

                    e = triggerAfter(this, prevVal)
                }
            }

        setter.__trigger = true

        delete propDesc.value
        delete propDesc.writable
        propDesc.get = getter
        propDesc.set = setter

        Object.defineProperty(target, name, propDesc)
    }

    // Listening for calls to an accessor (getter/setter)
    else if (propDesc.set && !propDesc.set.__trigger) {
        var originalSetter = propDesc.set
          , currentVal = target[name]
          , prevVal
          , setter = function (newVal) {
                var e = triggerBefore(this, newVal)
                if (!e.defaultPrevented) {
                    prevVal = currentVal
                    originalSetter.call(this, newVal)
                    currentVal = this[name]

                    triggerAfter(this, prevVal)
                }
            }
        propDesc.set = setter
        Object.defineProperty(target, name, propDesc)
    }

}

/**
 * @private
 * @ignore
 * Returns the event listener property of an object, creating it if it doesn't
 * already exist.
 *
 * @returns {Object}
 */
function getListeners(obj, eventName) {
    var listenerDesc = Object.getOwnPropertyDescriptor(obj, '__jahEventListeners__')
    if (!listenerDesc) {
        Object.defineProperty(obj, '__jahEventListeners__', {
            value: {}
        })
    }
    if (!eventName) {
        return obj.__jahEventListeners__;
    }
    if (!obj.__jahEventListeners__[eventName]) {
        obj.__jahEventListeners__[eventName] = {};
    }
    return obj.__jahEventListeners__[eventName];
}

function getPropertyListeners(obj, property, eventName) {
    var listenerDesc = Object.getOwnPropertyDescriptor(obj, '__jahPropertyEventListeners__')
    if (!listenerDesc) {
        Object.defineProperty(obj, '__jahPropertyEventListeners__', {
            value: {}
        })
    }
    if (!property) {
        return obj.__jahPropertyEventListeners__
    }
    if (!obj.__jahPropertyEventListeners__[property]) {
        obj.__jahPropertyEventListeners__[property] = {}
    }

    if (!eventName) {
        return obj.__jahPropertyEventListeners__[property]
    }

    if (!obj.__jahPropertyEventListeners__[property][eventName]) {
        obj.__jahPropertyEventListeners__[property][eventName] = {};
    }
    return obj.__jahPropertyEventListeners__[property][eventName];
}


/**
 * @private
 * @ignore
 * Keep track of the next ID for each new EventListener
 */
var eventID = 0
  , propertyEventID = 0

/**
 * @class
 * Represents an event being listened to. You should not create instances of
 * this directly, it is instead returned by events.addListener
 *
 * @param {Object} source Object to listen to for an event
 * @param {String} eventName Name of the event to listen for
 * @param {Function} handler Callback to fire when the event triggers
 */
events.EventListener = function (source, eventName, handler) {
    /**
     * Object to listen to for an event
     * @type Object 
     */
    this.source = source;

    /**
     * Name of the event to listen for
     * @type String
     */
    this.eventName = eventName;

    /**
     * Callback to fire when the event triggers
     * @type Function
     */
    this.handler = handler;

    /**
     * Unique ID number for this instance
     * @type Integer 
     */
    this.id = eventID++;

    getListeners(source, eventName)[this.id] = this;
};

/**
 * @class
 *
 * @extends events.EventListener
 */
events.PropertyEventListener = function (source, property, eventName, handler) {
    this.source = source;
    this.eventName = eventName;
    this.property = property;
    this.handler = handler;
    this.id = propertyEventID++;
    getPropertyListeners(source, property, eventName)[this.id] = this;
}
events.PropertyEventListener.prototype = Object.create(events.EventListener)

/**
 * Register an event listener
 *
 * @param {Object} source Object to listen to for an event
 * @param {String|String[]} eventName Name or Array of names of the event(s) to listen for
 * @param {Function} handler Callback to fire when the event triggers
 *
 * @returns {events.EventListener|events.EventListener[]} The event listener(s). Pass to removeListener to destroy it.
 */
events.addListener = function (source, eventName, handler) {
    if (eventName instanceof Array) {
        var listeners = [];
        for (var i = 0, len = eventName.length; i < len; i++) {
            listeners.push(events.addListener(source, eventName[i], handler));
        }
        return listeners;
    } else {
        return new events.EventListener(source, eventName, handler);
    }
};

/**
 * Register an event listener and autoremove it after event triggers
 *
 * @param {Object} source Object to listen to for an event
 * @param {String|String[]} eventName Name or Array of names of the event(s) to listen for
 * @param {Function} handler Callback to fire when the event triggers
 *
 * @returns {events.EventListener|events.EventListener[]} The event listener(s). Pass to removeListener to destroy it.
 */
events.addListenerOnce = function (source, eventName, handler) {
    var l = events.addListener(source, eventName, function () {
        handler.apply(this, arguments)
        events.removeListener(l)
        l = null
    })

    return l
};

events.addPropertyListener = function (source, property, eventName, handler) {
    var listeners = [], i;
    if (eventName instanceof Array) {
        for (i = 0, len = eventName.length; i < len; i++) {
            listeners.push(events.addPropertyListener(source, property, eventName[i], handler));
        }
        return listeners;
    } else if (property instanceof Array) {
        for (i = 0, len = property.length; i < len; i++) {
            listeners.push(events.addPropertyListener(source, property[i], eventName, handler));
        }
        return listeners;
    } else {
        watchProperty(source, property)
        return new events.PropertyEventListener(source, property, eventName, handler);
    }
}

/**
 * Trigger an event. All listeners will be notified.
 *
 * @param {Object} source Object to trigger the event on
 * @param {String} eventName Name of the event to trigger
 */
events.trigger = function (source, eventName) {
    var listeners = getListeners(source, eventName),
        args = Array.prototype.slice.call(arguments, 2),
        eventID,
        l;

    // Call the 'oneventName' method if it exists
    if (typeof source['on' + eventName] == 'function') {
        source['on' + eventName].apply(source, args)
    }

    // Call any registered listeners
    for (eventID in listeners) {
        if (listeners.hasOwnProperty(eventID)) {
            l = listeners[eventID];
            if (l) {
                l.handler.apply(null, args);
            }
        }
    }
};

/**
 * Trigger an event on a property. All listeners will be notified.
 *
 * @param {Object} source Object the property belongs to
 * @param {String} property The name of the property on source
 * @param {String} eventName The name of the event to strigger
 */
events.triggerProperty = function (source, property, eventName) {
    var listeners = getPropertyListeners(source, property, eventName),
        args = Array.prototype.slice.call(arguments, 3),
        eventID,
        l;

    for (eventID in listeners) {
        if (listeners.hasOwnProperty(eventID)) {
            l = listeners[eventID];
            if (l) {
                l.handler.apply(null, args);
            }
        }
    }
};

/**
 * Remove a previously registered event listener
 *
 * @param {events.EventListener|events.PropertyEventListener} listener EventListener to remove, as returned by events.addListener or events.addPropertyListener
 */
events.removeListener = function (listener) {
    if (listener instanceof events.PropertyEventListener) {
        delete getPropertyListeners(listener.source, listener.property, listener.eventName)[listener.eventID];
    } else {
        delete getListeners(listener.source, listener.eventName)[listener.eventID];
    }
};

/**
 * Remove a all event listeners for a given event
 *
 * @param {Object} source Object to remove listeners from
 * @param {String} eventName Name of event to remove listeners from
 */
events.clearListeners = function (source, eventName) {
    var listeners = getListeners(source, eventName),
        eventID;


    for (eventID in listeners) {
        if (listeners.hasOwnProperty(eventID)) {
            var l = listeners[eventID];
            if (l) {
                events.removeListener(l);
            }
        }
    }
};

/**
 * Remove all event listeners on an object
 *
 * @param {Object} source Object to remove listeners from
 */
events.clearInstanceListeners = function (source) {
    var listeners = getListeners(source),
        eventID;

    for (var eventName in listeners) {
        if (listeners.hasOwnProperty(eventName)) {
            var el = listeners[eventName];
            for (eventID in el) {
                if (el.hasOwnProperty(eventID)) {
                    var l = el[eventID];
                    if (l) {
                        events.removeListener(l);
                    }
                }
            }
        }
    }
};

module.exports = events;

}, mimetype: "application/javascript", remote: false}; // END: /__builtin__/events.js


__jah__.resources["/__builtin__/index.js"] = {data: function (exports, require, module, __filename, __dirname) {
"use strict";

/**
 * @namespace
 * Useful utility functions
 */
var jah = {
    /**
     * Creates a deep copy of an object
     *
     * @param {Object} obj The Object to copy
     * @returns {Object} A copy of the original Object
     */
    copy: function(obj) {
        if (obj === null) {
            return null;
        }

        var copy;

        if (obj instanceof Array) {
            copy = [];
            for (var i = 0, len = obj.length; i < len; i++) {
                copy[i] = jah.copy(obj[i]);
            }
        } else if (typeof(obj) == 'object') {
            if (typeof(obj.copy) == 'function') {
                copy = obj.copy();
            } else {
                copy = {};

                var o, x;
                for (x in obj) {
                    copy[x] = jah.copy(obj[x]);
                }
            }
        } else {
            // Primative type. Doesn't need copying
            copy = obj;
        }

        return copy;
    },

    /**
     * Iterates over an array and calls a function for each item.
     *
     * @param {Array} arr An Array to iterate over
     * @param {Function} func A function to call for each item in the array
     * @returns {Array} The original array
     */
    each: function(arr, func) {
        var i = 0,
            len = arr.length;
        for (i = 0; i < len; i++) {
            func(arr[i], i);
        }

        return arr;
    },

    /**
     * Iterates over an array, calls a function for each item and returns the results.
     *
     * @param {Array} arr An Array to iterate over
     * @param {Function} func A function to call for each item in the array
     * @returns {Array} The return values from each function call
     */
    map: function(arr, func) {
        var i = 0,
            len = arr.length,
            result = [];

        for (i = 0; i < len; i++) {
            result.push(func(arr[i], i));
        }

        return result;
    },

    domReady: function() {
        if (__jah__.__blockReady) {
            return;
        }

        if (!document.body) {
            setTimeout(function() { jah.domReady(); }, 13);
        }

        __jah__.__isReady = true;

        if (__jah__.__readyList) {
            var fn, i = 0;
            while ( (fn = __jah__.__readyList[ i++ ]) ) {
                fn.call(document);
            }

            __jah__.__readyList = null;
            delete __jah__.__readyList;
        }
    },


    /**
     * Adapted from jQuery
     * @ignore
     */
    bindReady: function() {

        if (__jah__.__readyBound) {
            return;
        }

        __jah__.__readyBound = true;

        __jah__.__triggerReady = function () {
            __jah__.__blockReady = false
            jah.domReady()
        }

        // Catch cases where $(document).ready() is called after the
        // browser event has already occurred.
        if ( document.readyState === "complete" ) {
            return jah.domReady();
        }

        // Mozilla, Opera and webkit nightlies currently support this event
        if ( document.addEventListener ) {
            // Use the handy event callback
            //document.addEventListener( "DOMContentLoaded", DOMContentLoaded, false );
            
            // A fallback to window.onload, that will always work
            window.addEventListener( "load", jah.domReady, false );

        // If IE event model is used
        } else if ( document.attachEvent ) {
            // ensure firing before onload,
            // maybe late but safe also for iframes
            //document.attachEvent("onreadystatechange", DOMContentLoaded);
            
            // A fallback to window.onload, that will always work
            window.attachEvent( "onload", jah.domReady );

            // If IE and not a frame
            /*
            // continually check to see if the document is ready
            var toplevel = false;

            try {
                toplevel = window.frameElement == null;
            } catch(e) {}

            if ( document.documentElement.doScroll && toplevel ) {
                doScrollCheck();
            }
            */
        }
    },



    ready: function(func) {
        if (!__jah__.__blockReady && __jah__.__isReady) {
            func()
        } else {
            if (!__jah__.__readyList) {
                __jah__.__readyList = [];
            }
            __jah__.__readyList.push(func);
        }

        jah.bindReady();
    }
}

module.exports = jah;

}, mimetype: "application/javascript", remote: false}; // END: /__builtin__/index.js


__jah__.resources["/__builtin__/init.js"] = {data: function (exports, require, module, __filename, __dirname) {
/**
 * Some polyfiller to make old browsers more ES5 like
 */



if (!Object.keys) {
    /**
     * @see https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Object/keys
     */
    Object.keys = function(o) {
        if (o !== Object(o)) {
            throw new TypeError('Object.keys called on non-object');
        }
        var ret = []
          , p;
        for (p in o) {
            if (Object.prototype.hasOwnProperty.call(o,p)) {
                ret.push(p);
            }
        }
        return ret;
    };
}

if (!Object.create) {
    /**
     * @see https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Object/create
     */
    Object.create = function (o) {
        if (arguments.length > 1) {
            throw new Error('Object.create implementation only accepts the first parameter.');
        }
        function F() {}
        F.prototype = o;
        return new F();
    };
}

if (!Function.prototype.bind) {
    /**
     * @see https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Function/bind
     */
    Function.prototype.bind = function (oThis) {

        if (typeof this !== "function") // closest thing possible to the ECMAScript 5 internal IsCallable function
            throw new TypeError("Function.prototype.bind - what is trying to be fBound is not callable");

        var aArgs = Array.prototype.slice.call(arguments, 1),
            fToBind = this,
            fNOP = function () {},
            fBound = function () {
                return fToBind.apply(this instanceof fNOP ? this : oThis || window, aArgs.concat(Array.prototype.slice.call(arguments)));
            };

        fNOP.prototype = this.prototype;
        fBound.prototype = new fNOP();

        return fBound;

    };
}

if (!window.requestAnimationFrame) {
    /**
     * Provides requestAnimationFrame in a cross browser way.
     * @see http://paulirish.com/2011/requestanimationframe-for-smart-animating/
     */
    window.requestAnimationFrame = ( function() {
        return window.webkitRequestAnimationFrame ||
        window.mozRequestAnimationFrame ||
        window.oRequestAnimationFrame ||
        window.msRequestAnimationFrame ||
        function( /* function FrameRequestCallback */ callback, /* DOMElement Element */ element ) {
            window.setTimeout( callback, 1000 / 60 );
        };
    } )();
}

}, mimetype: "application/javascript", remote: false}; // END: /__builtin__/init.js


__jah__.resources["/__builtin__/path.js"] = {data: function (exports, require, module, __filename, __dirname) {
/** @namespace */
var path = {
    /**
     * Returns full directory path for the filename given. The path must be formed using forward slashes '/'.
     *
     * @param {String} path Path to return the directory name of
     * @returns {String} Directory name
     */
    dirname: function(path) {
        var tokens = path.split('/');
        tokens.pop();
        return tokens.join('/');
    },

    /**
     * Returns just the filename portion of a path.
     *
     * @param {String} path Path to return the filename portion of
     * @returns {String} Filename
     */
    basename: function(path) {
        var tokens = path.split('/');
        return tokens[tokens.length-1];
    },

    /**
     * Joins multiple paths together to form a single path
     * @param {String} ... Any number of string arguments to join together
     * @returns {String} The joined path
     */
    join: function () {
        return module.exports.normalize(Array.prototype.join.call(arguments, "/"));
    },

    /**
     * Tests if a path exists
     *
     * @param {String} path Path to test
     * @returns {Boolean} True if the path exists, false if not
     */
    exists: function(path) {
        return (__jah__.resources[path] !== undefined);
    },

    /**
     * @private
     */
    normalizeArray: function (parts, keepBlanks) {
      var directories = [], prev;
      for (var i = 0, l = parts.length - 1; i <= l; i++) {
        var directory = parts[i];

        // if it's blank, but it's not the first thing, and not the last thing, skip it.
        if (directory === "" && i !== 0 && i !== l && !keepBlanks) continue;

        // if it's a dot, and there was some previous dir already, then skip it.
        if (directory === "." && prev !== undefined) continue;

        // if it starts with "", and is a . or .., then skip it.
        if (directories.length === 1 && directories[0] === "" && (
            directory === "." || directory === "..")) continue;

        if (
          directory === ".."
          && directories.length
          && prev !== ".."
          && prev !== "."
          && prev !== undefined
          && (prev !== "" || keepBlanks)
        ) {
          directories.pop();
          prev = directories.slice(-1)[0]
        } else {
          if (prev === ".") directories.pop();
          directories.push(directory);
          prev = directory;
        }
      }
      return directories;
    },

    /**
     * Returns the real path by expanding any '.' and '..' portions
     *
     * @param {String} path Path to normalize
     * @param {Boolean} [keepBlanks=false] Whether to keep blanks. i.e. double slashes in a path
     * @returns {String} Normalized path
     */
    normalize: function (path, keepBlanks) {
      return module.exports.normalizeArray(path.split("/"), keepBlanks).join("/");
    }
};

module.exports = path;

}, mimetype: "application/javascript", remote: false}; // END: /__builtin__/path.js


__jah__.resources["/__builtin__/preloader.js"] = {data: function (exports, require, module, __filename, __dirname) {
"use strict";

var events = require('events')
  , remotes = require('remote_resources')

function Preloader (items) {
    this.count = 0
    this.loaded = 0
    this.queue = []

    var listeners = {}

    if (items) {
        this.addToQueue(items)
    }

    var didLoadResource = function (ref) {
        this.loaded++

        // Must remove listener or we'll leak memory
        if (listeners[ref]) {
            events.removeListener(listeners[ref]);
        }
        events.trigger(this, 'load', this, ref);


        if (this.loaded >= this.count) {
            events.trigger(this, 'complete', this);
        }
    }.bind(this)

    this.load = function () {
        if (this.queue.length == 0) {
            events.trigger(this, 'complete', this);
            return
        }
        // Store number of callbacks we're expecting
        this.count += this.queue.length

        var ref, i
        for (i=0; i<this.count; i++) {
            ref = this.queue[i]

            if (!__jah__.resources[ref]) {
                console.warn("Unable to preload non-existant file: ", ref)
                didLoadResource(ref)
                continue
            }
            if (!__jah__.resources[ref].remote || __jah__.resources[ref].loaded) {
                // Already loaded
                didLoadResource(ref)
                continue
            }
            var file = resource(ref)
              , callback = didLoadResource.bind(this, ref)

            if (file instanceof remotes.RemoteResource) {
                // Notify when a resource has loaded
                listeners[ref] = events.addListener(file, 'load', callback);

                file.load()
            } else {
                setTimeout(callback, 1)
            }
        }

        this.clearQueue()
    }
}

Preloader.prototype.addToQueue = function (items) {
    if (items instanceof Array) {
        // Update array in place incase something else has a reference to it
        for (var i=0; i<items.length; i++) {
            this.queue.push(items[i])
        }
    } else {
        this.queue.push(items)
    }
}

Preloader.prototype.addEverythingToQueue = function () {
    var items = []
    var key, res
    for (key in __jah__.resources) {
        if (__jah__.resources.hasOwnProperty(key)) {
            res = __jah__.resources[key]
            if (res.remote) {
                items.push(key)
            }
        }
    }

    if (items.length > 0) {
        this.addToQueue(items)
    }
}

Preloader.prototype.clearQueue = function () {
    this.queue.splice(0, this.queue.length)
}


exports.Preloader = Preloader;

}, mimetype: "application/javascript", remote: false}; // END: /__builtin__/preloader.js


__jah__.resources["/__builtin__/remote_resources.js"] = {data: function (exports, require, module, __filename, __dirname) {
"use strict"

var util = require('./index'),
    events = require('events')

/**
 * @namespace
 */
var remote_resources = {}

/**
 * @class
 * @memberOf remote_resources
 */
function RemoteResource(url, path) {
    this.url = url
    this.path = path
}
remote_resources.RemoteResource = RemoteResource

/**
 * Load the remote resource via ajax
 */
remote_resources.RemoteResource.prototype.load = function () {
    var xhr = new XMLHttpRequest()
    xhr.onreadystatechange = function () {
        if (xhr.readyState == 4) {
            __jah__.resources[this.path].data = xhr.responseText
            __jah__.resources[this.path].loaded = true

            events.trigger(this, 'load', this)
        }
    }.bind(this)

    xhr.open('GET', this.url, true)  
    xhr.send(null)
}

/**
 * @class
 * @memberOf remote_resources
 * @extends remote_resources.RemoteResource
 */
function RemoteImage(url, path) {
    RemoteResource.apply(this, arguments)
}
remote_resources.RemoteImage = RemoteImage

remote_resources.RemoteImage.prototype = Object.create(RemoteResource.prototype)

remote_resources.RemoteImage.prototype.load = function () {
    var img = new Image()
    __jah__.resources[this.path].data = img

    /**
     * @ignore
     */
    img.onload = function () {
        __jah__.resources[this.path].loaded = true
        events.trigger(this, 'load', this)
    }.bind(this)

    /**
     * @ignore
     */
    img.onerror = function () {
        console.warn("Failed to load resource: [%s] from [%s]", this.path, img.src)
        __jah__.resources[this.path].loaded = true
        events.trigger(this, 'load', this)
    }.bind(this)
    
    img.src = this.url

    return img
}


/**
 * @class
 * @memberOf remote_resources
 * @extends remote_resources.RemoteResource
 */
function RemoteScript(url, path) {
    RemoteResource.apply(this, arguments)
}
remote_resources.RemoteScript = RemoteScript

remote_resources.RemoteScript.prototype = Object.create(RemoteResource.prototype)

remote_resources.RemoteScript.prototype.load = function () {
    var script = document.createElement('script')
    __jah__.resources[this.path].data = script

    /**
     * @ignore
     */
    script.onload = function () {
        __jah__.resources[this.path].loaded = true
        events.trigger(this, 'load', this)
    }.bind(this)

    script.src = this.url
    document.getElementsByTagName('head')[0].appendChild(script)

    return script
}

remote_resources.getRemoteResource = function (resourcePath) {
    var resource = __jah__.resources[resourcePath]

    if (!resource) {
        return null
    }

    if (resource.remoteResource) {
        return resource.remoteResource
    }

    var RemoteObj
      , mime = resource.mimetype.split('/')

    if (mime[0] == 'image') {
        RemoteObj = RemoteImage
    } else if(mime[1] == 'javascript') {
        RemoteObj = RemoteScript
    } else {
        RemoteObj = RemoteResource
    }

    resource.remoteResource = new RemoteObj(resource.data, resourcePath)

    return resource.remoteResource
}

module.exports = remote_resources

}, mimetype: "application/javascript", remote: false}; // END: /__builtin__/remote_resources.js


__jah__.resources["/__builtin__/system.js"] = {data: function (exports, require, module, __filename, __dirname) {
/** @namespace */
var system = {
    /** @namespace */
    stdio: {
        /**
         * Print text and objects to the debug console if the browser has one
         * 
         * @param {*} Any value to output
         */
        print: function() {
            if (console) {
                console.log.apply(console, arguments);
            } else {
                // TODO
            }
        }
    }
};

if (window.console) {
    system.console = window.console
} else {
    system.console = {
        log: function(){}
    }
}

}, mimetype: "application/javascript", remote: false}; // END: /__builtin__/system.js

/*globals module exports resource require window Module __main_module_name__ */
/*jslint undef: true, strict: true, white: true, newcap: true, browser: true, indent: 4 */
(function(){
"use strict";

var __main_module_name__ = '/main'

var process = {}
  , modulePaths = ['/__builtin__', '/__builtin__/libs', '/libs']
  , path; // path module, we will load this later

window.resource = function(resourcePath) {
    var remotes = require('remote_resources')

    var res = __jah__.resources[resourcePath]
    if (!res) {
        throw new Error("Unable to find resource: " + resourcePath);
    }

    if (res.remote && !res.loaded) {
        return remotes.getRemoteResource(resourcePath)
    }

    return res.data
}

function resolveModulePath(request, parent) {
    // If not a relative path then search the modulePaths for it
    var start = request.substring(0, 2);
    if (start !== "./" && start !== "..") {
        return modulePaths;
    }

    var parentIsIndex = path.basename(parent.filename).match(/^index\.js$/),
        parentPath    = parentIsIndex ? parent.id : path.dirname(parent.id);

    // Relative path so searching inside parent's directory
    return [path.dirname(parent.filename)];
}

function findModulePath(id, dirs) {
    if (id.charAt(0) === '/') {
        dirs = [''];
    }
    for (var i = 0; i < dirs.length; i++) {
        var dir = dirs[i];
        var p = path.join(dir, id);

        // Check for index first
        if (path.exists(path.join(p, 'index.js'))) {
            return path.join(p, 'index.js');
        } else if (path.exists(p + '.js')) {
            return p + '.js';
        }
    }

    return false;
}

function loadModule(request, parent) {
    parent = parent || process.mainModule;

    var paths    = resolveModulePath(request, parent),
        filename = findModulePath(request, paths);

    if (filename === false) {
        throw new Error("Unable to find module: " + request);
    }


    if (parent) {
        var cachedModule = Module._moduleCache[filename];
        if (cachedModule) {
            return cachedModule;
        }
    }

    //console.log('Loading module: ', filename);

    var module = new Module(filename, parent);

    // Assign main module to process
    if (request == __main_module_name__ && !process.mainModule) {
        process.mainModule = module;
    }

    // Run all the code in the module
    module._initialize(filename);

    return module;
}

function Module(id, parent) {
    this.id = id;
    this.parent = parent;
    this.children = [];
    this.exports = {};

    if (parent) {
        parent.children.push(this);
    }
    Module._moduleCache = Module._moduleCache || {}
    Module._moduleCache[this.id] = this;

    this.filename = null;
    this.dirname = null;
}

Module.prototype._initialize = function (filename) {
    var module = this;
    function require(request) {
        return loadModule(request, module).exports;
    }

    this.filename = filename;

    // Work around incase this IS the path module
    if (path) {
        this.dirname = path.dirname(filename);
    } else {
        this.dirname = '';
    }

    require.paths = modulePaths;
    require.main = process.mainModule;

    var mod = __jah__.resources[this.filename]
    if (mod) {
      mod.data.apply(this.exports, [this.exports, require, this, this.filename, this.dirname]);
    } else {
      throw new Error("Unable to find module: " + this.filename)
    }

    return this;
};

// Manually load the path module because we need it to load other modules
path = (new Module('path'))._initialize('/__builtin__/path.js').exports;

var util = loadModule('/__builtin__/').exports;

// Browser's DOM is ready for action
util.ready(function () {

    // Add a global require. Useful in the debug console.
    window.require = function require(request, parent) {
        return loadModule(request, parent).exports;
    };
    window.require.paths = modulePaths;

    // Initialise the libs
    var key, lib
    for (key in __jah__.resources) {
        if (__jah__.resources.hasOwnProperty(key)) {
            // If matches /libs/<foo>/init.js then run foo.main()
            if (/^\/libs\/[^\/]+?\/init.js$/.test(key) || key == '/__builtin__/init.js') {
                lib = loadModule(key.replace(/\.js$/, '')).exports
                if (typeof lib.main == 'function') {
                    lib.main()
                }
            }
        }
    }

    // Initialise the main module
    process.mainModule = loadModule(__main_module_name__);
    window.require.main = process.mainModule;

    // Attempt to add global 'requite' to top frame
    try {
        if (!top.window.require) {
            top.window.require = window.require
        }
    } catch (e) {
    }

    // Run application's main function
    if (process.mainModule.exports.main) {
        process.mainModule.exports.main();
    }
});

})()
// vim:ft=javascript

})();(function(){
__jah__.resources["/libs/cocos2d/ActionManager.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

var util = require('util'),
    Timer = require('./Scheduler').Timer,
    Scheduler = require('./Scheduler').Scheduler


/**
 * @class
 * A singleton that manages all the actions. Normally you
 * won't need to use this singleton directly. 99% of the cases you will use the
 * cocos.nodes.Node interface, which uses this singleton. But there are some cases where
 * you might need to use this singleton. Examples:
 *
 * * When you want to run an action where the target is different from a cocos.nodes.Node
 * * When you want to pause / resume the actions
 *
 * @memberOf cocos
 * @singleton
 */
function ActionManager () {
    ActionManager.superclass.constructor.call(this)

    Scheduler.sharedScheduler.scheduleUpdate({target: this, priority: 0, paused: false})
    this.targets = []
}

ActionManager.inherit(Object, /** @lends cocos.ActionManager# */ {
    targets: null,
    currentTarget: null,
    currentTargetSalvaged: null,

    /**
     * Adds an action with a target. If the target is already present, then the
     * action will be added to the existing target. If the target is not
     * present, a new instance of this target will be created either paused or
     * paused, and the action will be added to the newly created target. When
     * the target is paused, the queued actions won't be 'ticked'.
     *
     * @opt {cocos.nodes.Node} target Node to run the action on
     */
    addAction: function (opts) {

        var targetID = opts.target.id
        var element = this.targets[targetID]

        if (!element) {
            element = this.targets[targetID] = {
                paused: false,
                target: opts.target,
                actions: []
            }
        }

        element.actions.push(opts.action)

        opts.action.startWithTarget(opts.target)
    },

    /**
     * Remove an action
     *
     * @param {cocos.actions.Action} action Action to remove
     */
    removeAction: function (action) {
        var targetID = action.originalTarget.id,
            element = this.targets[targetID]

        if (!element) {
            return
        }

        var actionIndex = element.actions.indexOf(action)

        if (actionIndex == -1) {
            return
        }

        if (this.currentTarget == element) {
            element.currentActionSalvaged = true
        }

        element.actions[actionIndex] = null
        element.actions.splice(actionIndex, 1); // Delete array item

        if (element.actions.length === 0) {
            if (this.currentTarget == element) {
                this.currentTargetSalvaged = true
            }
        }

    },

    /**
     * Fetch an action belonging to a cocos.nodes.Node
     *
     * @returns {cocos.actions.Action}
     *
     * @opts {cocos.nodes.Node} target Target of the action
     * @opts {String} tag Tag of the action
     */
    getActionFromTarget: function(opts) {
        var tag = opts.tag,
            targetID = opts.target.id

        var element = this.targets[targetID]
        if (!element) {
            return null
        }
        for (var i = 0; i < element.actions.length; i++ ) {
            if (element.actions[i] &&
                (element.actions[i].tag === tag)) {
                return element.actions[i]
            }
        }
        // Not found
        return null
    },

    /**
     * Remove all actions for a cocos.nodes.Node
     *
     * @param {cocos.nodes.Node} target Node to remove all actions for
     */
    removeAllActionsFromTarget: function (target) {
        var targetID = target.id

        var element = this.targets[targetID]
        if (!element) {
            return
        }

        delete this.targets[targetID]
        // Delete everything in array but don't replace it incase something else has a reference
        element.actions.splice(0, element.actions.length)
    },

    /**
     * @private
     */
    update: function (dt) {
        var self = this
        util.each(this.targets, function (currentTarget, i) {

            if (!currentTarget) {
                return
            }
            self.currentTarget = currentTarget

            if (!currentTarget.paused) {
                util.each(currentTarget.actions, function (currentAction, j) {
                    if (!currentAction) {
                        return
                    }

                    currentTarget.currentAction = currentAction
                    currentTarget.currentActionSalvaged = false

                    currentTarget.currentAction.step(dt)

                    if (currentTarget.currentAction.isDone) {
                        currentTarget.currentAction.stop()

                        var a = currentTarget.currentAction
                        currentTarget.currentAction = null
                        self.removeAction(a)
                    }

                    currentTarget.currentAction = null

                })
            }

            if (self.currentTargetSalvaged && currentTarget.actions.length === 0) {
                self.targets[i] = null
                delete self.targets[i]
            }
        })
    },

    pauseTarget: function (target) {
    },

    resumeTarget: function (target) {
        // TODO
    }
})

Object.defineProperty(ActionManager, 'sharedManager', {
    /**
     * A shared singleton instance of cocos.ActionManager
     *
     * @memberOf cocos.ActionManager
     * @getter {cocos.ActionManager} sharedManager
     */
    get: function () {
        if (!ActionManager._instance) {
            ActionManager._instance = new this()
        }

        return ActionManager._instance
    }

  , enumerable: true
})

exports.ActionManager = ActionManager

// vim:et:st=4:fdm=marker:fdl=0:fdc=1

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/ActionManager.js


__jah__.resources["/libs/cocos2d/actions/Action.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

var util = require('util'),
    geo = require('geometry'),
    ccp = geo.ccp

/**
 * @class
 * Base class for Actions. Actions change properites of a Node gradually
 * over time or instantly.
 *
 * @memberOf cocos.actions
 */
function Action () {
}

Action.inherit(Object, /** @lends cocos.actions.Action# */ {
    /**
     * The Node the action is being performed on
     * @type cocos.nodes.Node
     */
    target: null,
    originalTarget: null,

    /**
     * Unique tag to identify the action
     * @type String
     */
    tag: null,

    /**
     * Called every frame with its delta time. Overwrite this only if you're
     * making a new base type of action. Usually you'll just want to override
     * 'update' and extend from cocos.actions.ActionInstance or
     * cocos.actions.ActionInterval.
     *
     * @param {Float} dt The delta time
     */
    step: function (dt) {
        console.warn("Action.step() Override me")
    },

    /**
     * Called once per frame. Override this method with your implementation to
     * update the target.
     *
     * @param {Float} time How much of the animation has played. 0.0 = just started, 1.0 just finished.
     */
    update: function (time) {
        console.warn("Action.update() Override me")
    },

    /**
     * Called before the action start. It will also set the target.
     *
     * @param {cocos.nodes.Node} target The Node to run the action on
     */
    startWithTarget: function (target) {
        this.target = this.originalTarget = target
    },

    /**
     * Called after the action has finished. It will set the 'target' to nil.
     * Important: You should never call cocos.actions.Action#stop manually.
     * Instead, use cocos.nodes.Node#stopAction(action)
     */
    stop: function () {
        this.target = null
    },

    /**
     * @type Boolean
     */
    get isDone () {
        return true
    },

    /**
     * Returns a copy of this Action but in reverse. Overwrite this and inside
     * create a new instance of the action, but with the reverse values.
     *
     * @returns {cocos.actions.Action} A new instance of the Action but in reverse
     */
    reverse: function () {
    }
})

/**
 * @class
 * Repeats an action forever. To repeat an action for a limited number of
 * times use the cocos.actions.Repeat action instead.
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.Action
 *
 * @param {cocos.actions.Action} action An action to repeat forever
 */
function RepeatForever (action) {
    RepeatForever.superclass.constructor.call(this)

    this.other = action
}

RepeatForever.inherit(Action, /** @lends cocos.actions.RepeatForever# */ {
    other: null,

    startWithTarget: function (target) {
        RepeatForever.superclass.startWithTarget.call(this, target)

        this.other.startWithTarget(this.target)
    },

    step: function (dt) {
        this.other.step(dt)
        if (this.other.isDone) {
            var diff = dt - this.other.duration - this.other.elapsed
            this.other.startWithTarget(this.target)

            this.other.step(diff)
        }
    },

    get isDone () {
        return false
    },

    reverse: function () {
        return new RepeatForever(this.other.reverse())
    },

    copy: function () {
        return new RepeatForever(this.other.copy())
    }
})

/**
 * @class
 * Repeats an action a number of times. To repeat an action forever use the
 * cocos.RepeatForever action instead.
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.Action
 */
function FiniteTimeAction () {
    FiniteTimeAction.superclass.constructor.call(this)
}

FiniteTimeAction.inherit(Action, /** @lends cocos.actions.FiniteTimeAction# */ {
    /**
     * Number of seconds to run the Action for
     * @type Float
     */
    duration: 2,

    /** @ignore */
    reverse: function () {
        console.log('FiniteTimeAction.reverse() Override me')
    }
})

/**
 * @class
 * Changes the speed of an action, making it take longer (speed>1)
 * or less (speed<1) time.
 * Useful to simulate 'slow motion' or 'fast forward' effect.
 * @warning This action can't be Sequenceable because it is not an IntervalAction
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.Action
 *
 * @opt {cocos.actions.Action} action Action to change duration of
 * @opt {Float} speed How much to multiply the duration by. Values > 1 increase duration, and < 1 will decrease duration.
 */
function Speed (opts) {
    Speed.superclass.constructor.call(this, opts)

    this.other = opts.action
    this.speed = opts.speed
}

Speed.inherit(Action, /** @lends cocos.actions.Speed# */ {
    /**
     * The action being adjusted
     * @type cocos.actions.Action
     */
    other: null,

    /**
     * Speed of the inner function
     * @type Float
     */
    speed: 1.0,

    startWithTarget: function (target) {
        Speed.superclass.startWithTarget.call(this, target)
        this.other.startWithTarget(this.target)
    },

    stop: function () {
        this.other.stop()
        Speed.superclass.stop.call(this)
    },

    step: function (dt) {
        this.other.step(dt * this.speed)
    },

    get isDone () {
        return this.other.isDone
    },

    copy: function () {
        return new Speed({action: this.other.copy(), speed: this.speed})
    },

    reverse: function () {
        return new Speed({action: this.other.reverse(), speed: this.speed})
    }
})

/**
 * @class
 * An action that "follows" a node.
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.Action
 *
 * @example layer.runAction(new cocos.actions.Follow({target: hero}))
 *
 * @opt {cocos.nodes.Node} target
 * @opt {geometry.Rect} worldBoundary
 */
function Follow (opts) {
    Follow.superclass.constructor.call(this, opts)

    this.followedNode = opts.target

    var s = require('../Director').Director.sharedDirector.winSize
    this.fullScreenSize = geo.ccp(s.width, s.height)
    this.halfScreenSize = geo.ccpMult(this.fullScreenSize, geo.ccp(0.5, 0.5))

    if (opts.worldBoundary !== undefined) {
        this.boundarySet = true
        this.leftBoundary = -((opts.worldBoundary.origin.x + opts.worldBoundary.size.width) - this.fullScreenSize.x)
        this.rightBoundary = -opts.worldBoundary.origin.x
        this.topBoundary = -opts.worldBoundary.origin.y
        this.bottomBoundary = -((opts.worldBoundary.origin.y+opts.worldBoundary.size.height) - this.fullScreenSize.y)

        if (this.rightBoundary < this.leftBoundary) {
            // screen width is larger than world's boundary width
            //set both in the middle of the world
            this.rightBoundary = this.leftBoundary = (this.leftBoundary + this.rightBoundary) / 2
        }

        if (this.topBoundary < this.bottomBoundary) {
            // screen width is larger than world's boundary width
            //set both in the middle of the world
            this.topBoundary = this.bottomBoundary = (this.topBoundary + this.bottomBoundary) / 2
        }

        if ((this.topBoundary == this.bottomBoundary) && (this.leftBoundary == this.rightBoundary)) {
            this.boundaryFullyCovered = true
        }
    }
}

Follow.inherit(Action, /** @lends cocos.actions.Follow# */ {
    /**
     * Node to follow
     * @type cocos.nodes.Node
     */
    followedNode: null,

    /**
     * Whether camera should be limited to certain area
     * @type Boolean
     */
    boundarySet: false,

    /**
     * If this screen size is bigger than the boundary - update not needed
     * @type Boolean
     */
    boundaryFullyCovered: false,

    /**
     * Fast access to half the screen dimensions
     * @type geometry.Point
     */
    halfScreenSize: null,

    /**
     * Fast access to the screen dimensions
     * @type geometry.Point
     */
    fullScreenSize: null,

    /**
     * Left edge of world
     * @type Float
     */
    leftBoundary: 0,

    /**
     * Right edge of world
     * @type Float
     */
    rightBoundary: 0,

    /**
     * Top edge of world
     * @type Float
     */
    topBoundary: 0,

    /**
     * Bottom edge of world
     * @type Float
     */
    bottomBoundary: 0,

    step: function (dt) {
        if (this.boundarySet) {
            // whole map fits inside a single screen, no need to modify the position - unless map boundaries are increased
            if (this.boundaryFullyCovered) {
                return
            }
            var tempPos = geo.ccpSub(this.halfScreenSize, this.followedNode.position)
            this.target.position = ccp( Math.min(Math.max(tempPos.x, this.leftBoundary),   this.rightBoundary)
                                      , Math.min(Math.max(tempPos.y, this.bottomBoundary), this.topBoundary)
                                      )
        } else {
            this.target.position = geo.ccpSub(this.halfScreenSize, this.followedNode.position)
        }
    },

    get isDone () {
        return !this.followedNode.isRunning
    }
})


exports.Action = Action
exports.RepeatForever = RepeatForever
exports.FiniteTimeAction = FiniteTimeAction
exports.Speed = Speed
exports.Follow = Follow

// vim:et:st=4:fdm=marker:fdl=0:fdc=1

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/actions/Action.js


__jah__.resources["/libs/cocos2d/actions/ActionEase.js"] = {data: function (exports, require, module, __filename, __dirname) {
"use strict"

var util = require('util'),
    ActionInterval = require('./ActionInterval').ActionInterval,
    geo = require('geometry'),
    ccp = geo.ccp

/**
 * @class
 * Base class for Easing actions
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.ActionInterval
 *
 * @opt {cocos.actions.ActionInterval} action
 */
function ActionEase (opts) {
    if (!opts.action) {
        throw "Ease: action argument must be non-nil"
    }
    ActionEase.superclass.constructor.call(this, {duration: opts.action.duration})

    this.other = opts.action
}

ActionEase.inherit(ActionInterval, /** @lends cocos.actions.ActionEase# */ {
    other: null,

    startWithTarget: function(target) {
        ActionEase.superclass.startWithTarget.call(this, target)
        this.other.startWithTarget(this.target)
    },

    stop: function() {
        this.other.stop()
        ActionEase.superclass.stop.call(this)
    },

    copy: function() {
        return new ActionEase({action: this.other.copy()})
    },

    reverse: function() {
        return new ActionEase({action: this.other.reverse()})
    }
})

/**
 * @class
 * Base class for Easing actions with rate parameter
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.ActionEase
 *
 * @opt {cocos.actions.ActionInterval} action
 * @opt {Float} rate
 */
function EaseRate (opts) {
    EaseRate.superclass.constructor.call(this, opts)

    this.rate = opts.rate
}

EaseRate.inherit(ActionEase, /** @lends cocos.actions.EaseRate# */ {
    /**
     * rate value for the actions
     * @type {Float}
     */
    rate: 0,

    copy: function() {
        return new EaseRate({action: this.other.copy(), rate: this.rate})
    },

    reverse: function() {
        return new EaseRate({action: this.other.reverse(), rate: 1 / this.rate})
    }
})

/**
 * @class
 * Ease In action with a rate
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.EaseRate
 */
function EaseIn (opts) {
    EaseIn.superclass.constructor.call(this, opts)
}

EaseIn.inherit(EaseRate, /** @lends cocos.actions.EaseIn# */ {
    update: function(t) {
        this.other.update(Math.pow(t, this.rate))
    },

    copy: function() {
        return new EaseIn({action: this.other.copy(), rate: this.rate})
    },

    reverse: function() {
        return new EaseIn({action: this.other.reverse(), rate: 1 / this.rate})
    }
})

/**
 * @class
 * Ease Out action with a rate
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.EaseRate
 */
function EaseOut (opts) {
    EaseOut.superclass.constructor.call(this, opts)
}

EaseOut.inherit(EaseRate, /** @lends cocos.actions.EaseOut# */ {
    update: function(t) {
        this.other.update(Math.pow(t, 1/this.rate))
    },

    copy: function() {
        return new EaseOut({action: this.other.copy(), rate: this.rate})
    },

    reverse: function() {
        return new EaseOut({action: this.other.reverse(), rate: 1 / this.rate})
    }
})

/**
 * @class
 * Ease In then Out action with a rate
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.EaseRate
 */
function EaseInOut (opts) {
    EaseInOut.superclass.constructor.call(this, opts)
}

EaseInOut.inherit(EaseRate, /** @lends cocos.actions.EaseInOut# */ {
    update: function(t) {
        var sign = 1
        var r = Math.floor(this.rate)
        if (r % 2 == 0) {
            sign = -1
        }
        t *= 2
        if (t < 1) {
            this.other.update(0.5 * Math.pow(t, this.rate))
        } else {
            this.other.update(sign * 0.5 * (Math.pow(t-2, this.rate) + sign * 2))
        }
    },

    copy: function() {
        return new EaseInOut({action: this.other.copy(), rate: this.rate})
    },

    reverse: function() {
        return new EaseInOut({action: this.other.reverse(), rate: this.rate})
    }
})

/**
 * @class
 * Ease Exponential In action
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.ActionEase
 */
function EaseExponentialIn (opts) {
    EaseExponentialIn.superclass.constructor.call(this, opts)
}

EaseExponentialIn.inherit(ActionEase, /** @lends cocos.actions.EaseExponentialIn# */ {
    update: function(t) {
        this.other.update((t == 0) ? 0 : (Math.pow(2, 10 * (t/1 - 1)) - 1 * 0.001))
    },

    copy: function() {
        return new EaseExponentialIn({action: this.other.copy()})
    },

    reverse: function() {
        return new exports.EaseExponentialOut({action: this.other.reverse()})
    }
})

/**
 * @class
 * EaseE xponential Out action
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.ActionEase
 */
function EaseExponentialOut (opts) {
    EaseExponentialOut.superclass.constructor.call(this, opts)
}

EaseExponentialOut.inherit(ActionEase, /** @lends cocos.actions.EaseExponentialOut# */ {
    update: function(t) {
        this.other.update((t == 1) ? 1 : (-Math.pow(2, -10 * t/1) + 1))
    },

    copy: function() {
        return new EaseExponentialOut({action: this.other.copy()})
    },

    reverse: function() {
        return new exports.EaseExponentialIn({action: this.other.reverse()})
    }
})

/**
 * @class
 * Ease Exponential In then Out action
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.ActionEase
 */
function EaseExponentialInOut (opts) {
    EaseExponentialInOut.superclass.constructor.call(this, opts)
}

EaseExponentialInOut.inherit(ActionEase, /** @lends cocos.actions.EaseExponentialInOut# */ {
    update: function(t) {
        t /= 0.5
        if (t < 1) {
            t = 0.5 * Math.pow(2, 10 * (t - 1))
        } else {
            t = 0.5 * (-Math.pow(2, -10 * (t - 1)) + 2)
        }
        this.other.update(t)
    },

    copy: function() {
        return new EaseExponentialInOut({action: this.other.copy()})
    },

    reverse: function() {
        return new EaseExponentialInOut({action: this.other.reverse()})
    }
})

/**
 * @class
 * Ease Sine In action
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.ActionEase
 */
function EaseSineIn (opts) {
    EaseSineIn.superclass.constructor.call(this, opts)
}

EaseSineIn.inherit(ActionEase, /** @lends cocos.actions.EaseSineIn# */ {
    update: function(t) {
        this.other.update(-1 * Math.cos(t * Math.PI_2) + 1)
    },

    copy: function() {
        return new EaseSineIn({action: this.other.copy()})
    },

    reverse: function() {
        return new exports.EaseSineOut({action: this.other.reverse()})
    }
})

/**
 * @class
 * Ease Sine Out action
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.ActionEase
 */
function EaseSineOut (opts) {
    EaseSineOut.superclass.constructor.call(this, opts)
}

EaseSineOut.inherit(ActionEase, /** @lends cocos.actions.EaseSineOut# */ {
    update: function(t) {
        this.other.update(Math.sin(t * Math.PI_2))
    },

    copy: function() {
        return new EaseSineOut({action: this.other.copy()})
    },

    reverse: function() {
        return new exports.EaseSineIn({action: this.other.reverse()})
    }
})

/**
 * @class
 * Ease Sine In then Out action
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.ActionEase
 */
function EaseSineInOut (opts) {
    EaseSineInOut.superclass.constructor.call(this, opts)
}

EaseSineInOut.inherit(ActionEase, /** @lends cocos.actions.EaseSineInOut# */ {
    update: function(t) {
        this.other.update(-0.5 * (Math.cos(t * Math.PI) - 1))
    },

    copy: function() {
        return new EaseSineInOut({action: this.other.copy()})
    },

    reverse: function() {
        return new EaseSineInOut({action: this.other.reverse()})
    }
})


/**
 * @class
 * Ease Elastic abstract class
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.ActionEase
 *
 * @opt {cocos.actions.ActionInterval} action
 * @opt {Float} period
 */
function EaseElastic (opts) {
    EaseElastic.superclass.constructor.call(this, {action: opts.action})

    if (opts.period !== undefined) {
        this.period = opts.period
    }
}

EaseElastic.inherit(ActionEase, /** @lends cocos.actions.EaseElastic# */ {
    /**
     * Period of the wave in radians
     * @type Float
     * @default 0.3
     */
    period: 0.3,

    copy: function() {
        return new EaseElastic({action: this.other.copy(), period: this.period})
    },

    reverse: function() {
        window.console.warn("EaseElastic reverse(): Override me")
        return null
    }
})

/**
 * @class
 * Ease Elastic In action
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.EaseElastic
 */
function EaseElasticIn (opts) {
    EaseElasticIn.superclass.constructor.call(this, opts)
}

EaseElasticIn.inherit(EaseElastic, /** @lends cocos.actions.EaseElasticIn# */ {
    update: function(t) {
        var newT = 0
        if (t == 0 || t == 1) {
            newT = t
        } else {
            var s = this.period / 4
            t -= 1
            newT = -Math.pow(2, 10 * t) * Math.sin((t - s) * Math.PI*2 / this.period)
        }
        this.other.update(newT)
    },

    // Wish we could use base class's copy
    copy: function() {
        return new EaseElasticIn({action: this.other.copy(), period: this.period})
    },

    reverse: function() {
        return new exports.EaseElasticOut({action: this.other.reverse(), period: this.period})
    }
})

/**
 * @class
 * Ease Elastic Out action
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.EaseElastic
 */
function EaseElasticOut (opts) {
    EaseElasticOut.superclass.constructor.call(this, opts)
}

EaseElasticOut.inherit(EaseElastic, /** @lends cocos.actions.EaseElasticOut# */ {
    update: function(t) {
        var newT = 0
        if (t == 0 || t == 1) {
            newT = t
        } else {
            var s = this.period / 4
            newT = Math.pow(2, -10 * t) * Math.sin((t - s) * Math.PI*2 / this.period) + 1
        }
        this.other.update(newT)
    },

    copy: function() {
        return new EaseElasticOut({action: this.other.copy(), period: this.period})
    },

    reverse: function() {
        return new exports.EaseElasticIn({action: this.other.reverse(), period: this.period})
    }
})

/**
 * @class
 * Ease Elastic In Out action
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.EaseElastic
 */
function EaseElasticInOut (opts) {
    EaseElasticInOut.superclass.constructor.call(this, opts)
}

EaseElasticInOut.inherit(EaseElastic, /** @lends cocos.actions.EaseElasticInOut# */ {
    update: function(t) {
        var newT = 0
        if (t == 0 || t == 1) {
            newT = t
        } else {
            t *= 2
            if (this.period == 0) {
                this.period = 0.3 * 1.5
            }
            var s = this.period / 4

            t -= 1
            if (t < 0) {
                newT = -0.5 * Math.pow(2, 10 * t) * Math.sin((t - s) * Math.PI*2 / this.period)
            } else {
                newT = Math.pow(2, -10 * t) * Math.sin((t - s) * Math.PI*2 / this.period) * 0.5 + 1
            }
        }
        this.other.update(newT)
    },

    copy: function() {
        return new EaseElasticInOut({action: this.other.copy(), period: this.period})
    },

    reverse: function() {
        return new EaseElasticInOut({action: this.other.reverse(), period: this.period})
    }
})

/**
 * @class
 * Ease Bounce abstract class
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.ActionEase
 */
function EaseBounce (opts) {
    EaseBounce.superclass.constructor.call(this, opts)
}

EaseBounce.inherit(ActionEase, /** @lends cocos.actions.EaseBounce# */ {
    bounceTime: function(t) {
        // Direct cut & paste from CCActionEase.m, obviously.
        // Glad someone else figured out all this math...
        if (t < 1 / 2.75) {
            return 7.5625 * t * t
        }
        else if (t < 2 / 2.75) {
            t -= 1.5 / 2.75
            return 7.5625 * t * t + 0.75
        }
        else if (t < 2.5 / 2.75) {
            t -= 2.25 / 2.75
            return 7.5625 * t * t + 0.9375
        }

        t -= 2.625 / 2.75
        return 7.5625 * t * t + 0.984375
    }
})

/**
 * @class
 * Ease Bounce In action
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.EaseBounce
 */
function EaseBounceIn (opts) {
    EaseBounceIn.superclass.constructor.call(this, opts)
}

EaseBounceIn.inherit(EaseBounce, /** @lends cocos.actions.EaseBounceIn# */ {
    update: function(t) {
        var newT = 1 - this.bounceTime(1-t)
        this.other.update(newT)
    },

    copy: function() {
        return new EaseBounceIn({action: this.other.copy()})
    },

    reverse: function() {
        return new exports.EaseBounceOut({action: this.other.reverse()})
    }
})

/**
 * @class
 * Ease Bounce Out action
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.EaseBounce
 */
function EaseBounceOut (opts) {
    EaseBounceOut.superclass.constructor.call(this, opts)
}

EaseBounceOut.inherit(EaseBounce, /** @lends cocos.actions.EaseBounceOut# */ {
    update: function(t) {
        var newT = this.bounceTime(t)
        this.other.update(newT)
    },

    copy: function() {
        return new EaseBounceOut({action: this.other.copy()})
    },

    reverse: function() {
        return new exports.EaseBounceIn({action: this.other.reverse()})
    }
})

/**
 * @class
 * Ease Bounce In Out action
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.EaseBounce
 */
function EaseBounceInOut (opts) {
    EaseBounceInOut.superclass.constructor.call(this, opts)
}

EaseBounceInOut.inherit(EaseBounce, /** @lends cocos.actions.EaseBounceInOut# */ {
    update: function(t) {
        var newT = 0
        if (t < 0.5) {
            t *= 2
            newT = (1 - this.bounceTime(1 - t)) * 0.5
        } else {
            newT = this.bounceTime(t * 2 - 1) * 0.5 + 0.5
        }
        this.other.update(newT)
    },

    copy: function() {
        return new EaseBounceInOut({action: this.other.copy()})
    },

    reverse: function() {
        return new EaseBounceInOut({action: this.other.reverse()})
    }
})

/**
 * @class
 * Ease Back In action
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.ActionEase
 */
function EaseBackIn (opts) {
    EaseBackIn.superclass.constructor.call(this, opts)
}

EaseBackIn.inherit(ActionEase, /** @lends cocos.actions.EaseBackIn# */ {
    update: function(t) {
        var overshoot = 1.70158
        this.other.update(t * t * ((overshoot + 1) * t - overshoot))
    },

    copy: function() {
        return new EaseBackIn({action: this.other.copy()})
    },

    reverse: function() {
        return new exports.EaseBackOut({action: this.other.reverse()})
    }
})

/**
 * @class
 * Ease Back Out action
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.ActionEase
 */
function EaseBackOut (opts) {
    EaseBackOut.superclass.constructor.call(this, opts)
}

EaseBackOut.inherit(ActionEase, /** @lends cocos.actions.EaseBackOut# */ {
    update: function(t) {
        var overshoot = 1.70158
        t -= 1
        this.other.update(t * t * ((overshoot + 1) * t + overshoot) + 1)
    },

    copy: function() {
        return new EaseBackOut({action: this.other.copy()})
    },

    reverse: function() {
        return new exports.EaseBackIn({action: this.other.reverse()})
    }
})

/**
 * @class
 * Ease Back In Out action
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.ActionEase
 */
function EaseBackInOut (opts) {
    EaseBackInOut.superclass.constructor.call(this, opts)
}

EaseBackInOut.inherit(ActionEase, /** @lends cocos.actions.EaseBackInOut# */ {
    update: function(t) {
        // Where do these constants come from?
        var overshoot = 1.70158 * 1.525
        t *= 2
        if (t < 1) {
            this.other.update((t * t * ((overshoot + 1) * t - overshoot)) / 2)
        } else {
            t -= 2
            this.other.update((t * t * ((overshoot + 1) * t + overshoot)) / 2 + 1)
        }
    },

    copy: function() {
        return new EaseBackInOut({action: this.other.copy()})
    },

    reverse: function() {
        return new EaseBackInOut({action: this.other.reverse()})
    }
})

exports.ActionEase = ActionEase
exports.EaseRate = EaseRate
exports.EaseIn = EaseIn
exports.EaseOut = EaseOut
exports.EaseInOut = EaseInOut
exports.EaseExponentialIn = EaseExponentialIn
exports.EaseExponentialOut = EaseExponentialOut
exports.EaseExponentialInOut = EaseExponentialInOut
exports.EaseSineIn = EaseSineIn
exports.EaseSineOut = EaseSineOut
exports.EaseSineInOut = EaseSineInOut
exports.EaseElastic = EaseElastic
exports.EaseElasticIn = EaseElasticIn
exports.EaseElasticOut = EaseElasticOut
exports.EaseElasticInOut = EaseElasticInOut
exports.EaseBounce = EaseBounce
exports.EaseBounceIn = EaseBounceIn
exports.EaseBounceOut = EaseBounceOut
exports.EaseBounceInOut = EaseBounceInOut
exports.EaseBackIn = EaseBackIn
exports.EaseBackOut = EaseBackOut
exports.EaseBackInOut = EaseBackInOut


}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/actions/ActionEase.js


__jah__.resources["/libs/cocos2d/actions/ActionInstant.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

var util = require('util'),
    action = require('./Action'),
    ccp = require('geometry').ccp

/**
 * @class
 * Base class for actions that triggers instantly. They have no duration.
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.FiniteTimeAction
 */
function ActionInstant (opts) {
    ActionInstant.superclass.constructor.call(this, opts)

    this.duration = 0
}

ActionInstant.inherit(action.FiniteTimeAction, /** @lends cocos.actions.ActionInstant */ {
    get isDone () {
        return true
    },

    step: function (dt) {
        this.update(1)
    },

    update: function (t) {
        // ignore
    },

    copy: function() {
        return this
    },

    reverse: function () {
        return this.copy()
    }
})

/**
 * @class
 * Show a node
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.ActionInstant
 */
function Show (opts) {
    Show.superclass.constructor.call(this, opts)
}

Show.inherit(ActionInstant, /** @lends cocos.actions.Show# */ {
    startWithTarget: function(target) {
        Show.superclass.startWithTarget.call(this, target)
        this.target.visible = true
    },

    copy: function() {
        return new Show()
    },

    reverse: function() {
        return new exports.Hide()
    }
})

/**
 * @class
 * Hide a node
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.ActionInstant
 */
function Hide (opts) {
    Hide.superclass.constructor.call(this, opts)
}

Hide.inherit(ActionInstant, /** @lends cocos.actions.Hide# */ {
    startWithTarget: function(target) {
        Hide.superclass.startWithTarget.call(this, target)
        this.target.visible = false
    },

    copy: function() {
        return new Hide()
    },

    reverse: function() {
        return new exports.Show()
    }
})

/**
 * @class
 * Toggles the visibility of a node
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.ActionInstant
 */
function ToggleVisibility (opts) {
    ToggleVisibility.superclass.constructor.call(this, opts)
}

ToggleVisibility.inherit(ActionInstant, /** @lends cocos.actions.ToggleVisibility# */ {
    startWithTarget: function(target) {
        ToggleVisibility.superclass.startWithTarget.call(this, target)
        var vis = this.target.visible
        this.target.visible = !vis
    },

    copy: function() {
        return new ToggleVisibility()
    }
})

/**
 * @class
 * Flips a sprite horizontally
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.ActionInstant
 *
 * @opt {Boolean} flipX Should the sprite be flipped
 */
function FlipX (opts) {
    FlipX.superclass.constructor.call(this, opts)
    this.flipX = opts.flipX
}

FlipX.inherit(ActionInstant, /** @lends cocos.actions.FlipX# */ {
    flipX: false,

    startWithTarget: function (target) {
        FlipX.superclass.startWithTarget.call(this, target)

        target.flipX = this.flipX
    },

    reverse: function () {
        return new FlipX({flipX: !this.flipX})
    },

    copy: function () {
        return new FlipX({flipX: this.flipX})
    }
})

/**
 * @class
 * Flips a sprite vertically
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.ActionInstant
 *
 * @opt {Boolean} flipY Should the sprite be flipped
 */
function FlipY (opts) {
    FlipY.superclass.constructor.call(this, opts)

    this.flipY = opts.flipY
}

FlipY.inherit(ActionInstant, /** @lends cocos.actions.FlipY# */ {
    flipY: false,

    startWithTarget: function (target) {
        FlipY.superclass.startWithTarget.call(this, target)

        target.flipY = this.flipY
    },

    reverse: function () {
        return new FlipY({flipY: !this.flipY})
    },

    copy: function () {
        return new FlipY({flipY: this.flipY})
    }
})

/**
 * @class
 * Places the node in a certain position
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.ActionInstant
 *
 * @opt {geometry.Point} position
 */
function Place (opts) {
    Place.superclass.constructor.call(this, opts)
    this.position = util.copy(opts.position)
}

Place.inherit(ActionInstant, /** @lends cocos.actions.Place# */ {
    position: null,

    startWithTarget: function(target) {
        Place.superclass.startWithTarget.call(this, target)
        this.target.position = this.position
    },

    copy: function() {
        return new Place({position: this.position})
    }
})

/**
 * @class
 * Calls a 'callback'
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.ActionInstant
 *
 * @opt {Object} target
 * @opt {String|Function} method
 */
function CallFunc (opts) {
    CallFunc.superclass.constructor.call(this, opts)

    // Save target & method so that copy() can recreate callback
    this.target = opts.target
    this.method = (typeof opts.method == 'function') ? opts.method : this.target[opts.method]
    this.callback = this.method.bind(this.target)
}

CallFunc.inherit(ActionInstant, /** @lends cocos.actions.CallFunc# */ {
    callback: null,
    target: null,
    method: null,

    startWithTarget: function(target) {
        CallFunc.superclass.startWithTarget.call(this, target)
        this.execute(target)
    },

    execute: function(target) {
        // Pass target to callback
        this.callback.call(this, target)
    },

    copy: function() {
        return new CallFunc({target: this.target, method: this.method})
    }
})

exports.ActionInstant = ActionInstant
exports.Show = Show
exports.Hide = Hide
exports.ToggleVisibility = ToggleVisibility
exports.FlipX = FlipX
exports.FlipY = FlipY
exports.Place = Place
exports.CallFunc = CallFunc

// vim:et:st=4:fdm=marker:fdl=0:fdc=1


}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/actions/ActionInstant.js


__jah__.resources["/libs/cocos2d/actions/ActionInterval.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

var util = require('util'),
    actions = require('./Action'),
    geo = require('geometry'),
    ccp = geo.ccp

/**
 * @ignore
 *
 * Creates multiple instances of actionType each given one action plus the next
 * actionType instance
 */
function initWithActions (actionType, actions) {
    var prev = actions[0].copy()
      , now
      , i
    for (i=1; i<actions.length; i++) {
        now = actions[i].copy()
        if (now) {
            prev = new actionType({one: prev, two: now})
        } else {
            break
        }
    }

    return prev
}

/**
 * @ignore
 *
 * Bezier cubic formula
 * ((1 - t) + t)3 = 1
 */
function bezierat (a, b, c, d, t) {
   return Math.pow(1-t, 3) * a +
        3 * t * Math.pow(1-t, 2) * b +
        3 * Math.pow(t, 2) * (1 - t) * c +
        Math.pow(t, 3) * d
}

/**
 * @class
 * Base class actions that do have a finite time duration.
 *
 * Possible actions:
 *
 * - An action with a duration of 0 seconds
 * - An action with a duration of 35.5 seconds Infinite time actions are valid
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.FiniteTimeAction
 *
 * @opt {Float} duration Number of seconds to run action for
 */
function ActionInterval (opts) {
    ActionInterval.superclass.constructor.apply(this, arguments)

    var dur = opts.duration || 0
    if (dur === 0) {
        dur = 0.0000001
    }

    this.duration = dur
    this.elapsed = 0
    this._firstTick = true
}

ActionInterval.inherit(actions.FiniteTimeAction, /** @lends cocos.actions.ActionInterval# */ {
    /**
     * Number of seconds that have elapsed
     * @type Float
     */
    elapsed: 0.0,

    _firstTick: true,

    get isDone () {
        return (this.elapsed >= this.duration)
    },

    step: function (dt) {
        if (this._firstTick) {
            this._firstTick = false
            this.elapsed = 0
        } else {
            this.elapsed += dt
        }

        this.update(Math.min(1, this.elapsed / this.duration))
    },

    startWithTarget: function (target) {
        ActionInterval.superclass.startWithTarget.call(this, target)

        this.elapsed = 0.0
        this._firstTick = true
    },

    copy: function() {
        throw "copy() not implemented"
    },

    reverse: function () {
        throw "Reverse Action not implemented"
    }
})

/**
 * @class
 * Delays the action a certain amount of seconds
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.ActionInterval
 */
function DelayTime () {
    DelayTime.superclass.constructor.apply(this, arguments)
}

DelayTime.inherit(ActionInterval, /** @lends cocos.actions.DelayTime# */ {
    update: function (t) {
        if (t === 1.0) {
            this.stop()
        }
    },

    copy: function () {
        return new DelayTime({duration: this.duration})
    },

    reverse: function () {
        return new DelayTime({duration: this.duration})
    }
})


/**
 * @class
 * Scales a cocos.Node object to a zoom factor by modifying it's scale attribute.
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.ActionInterval
 *
 * @opt {Float} duration Number of seconds to run action for
 * @opt {Float} [scale] Size to scale Node to
 * @opt {Float} [scaleX] Size to scale width of Node to
 * @opt {Float} [scaleY] Size to scale height of Node to
 */
function ScaleTo (opts) {
    ScaleTo.superclass.constructor.call(this, opts)

    if (opts.scale !== undefined) {
        this.endScaleX = this.endScaleY = opts.scale
    } else {
        this.endScaleX = opts.scaleX
        this.endScaleY = opts.scaleY
    }
}

ScaleTo.inherit(ActionInterval, /** @lends cocos.actions.ScaleTo# */ {
    /**
     * Current X Scale
     * @type Float
     */
    scaleX: 1,

    /**
     * Current Y Scale
     * @type Float
     */
    scaleY: 1,

    /**
     * Initial X Scale
     * @type Float
     */
    startScaleX: 1,

    /**
     * Initial Y Scale
     * @type Float
     */
    startScaleY: 1,

    /**
     * Final X Scale
     * @type Float
     */
    endScaleX: 1,

    /**
     * Final Y Scale
     * @type Float
     */
    endScaleY: 1,

    /**
     * Delta X Scale
     * @type Float
     * @private
     */
    deltaX: 0.0,

    /**
     * Delta Y Scale
     * @type Float
     * @private
     */
    deltaY: 0.0,

    startWithTarget: function (target) {
        ScaleTo.superclass.startWithTarget.call(this, target)

        this.startScaleX = this.target.scaleX
        this.startScaleY = this.target.scaleY
        this.deltaX = this.endScaleX - this.startScaleX
        this.deltaY = this.endScaleY - this.startScaleY
    },

    update: function (t) {
        if (!this.target) {
            return
        }

        this.target.scaleX = this.startScaleX + this.deltaX * t
        this.target.scaleY = this.startScaleY + this.deltaY * t
    },

    copy: function () {
        return new ScaleTo({duration: this.duration,
                                 scaleX: this.endScaleX,
                                 scaleY: this.endScaleY})
    }
})

/**
 * @class
 * Scales a cocos.Node object to a zoom factor by modifying it's scale attribute.
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.ScaleTo
 *
 * @opt {Float} duration Number of seconds to run action for
 * @opt {Float} [scale] Size to scale Node by
 * @opt {Float} [scaleX] Size to scale width of Node by
 * @opt {Float} [scaleY] Size to scale height of Node by
 */
function ScaleBy (opts) {
    ScaleBy.superclass.constructor.call(this, opts)
}

ScaleBy.inherit(ScaleTo, /** @lends cocos.actions.ScaleBy# */ {
    startWithTarget: function (target) {
        ScaleBy.superclass.startWithTarget.call(this, target)

        this.deltaX = this.startScaleX * this.endScaleX - this.startScaleX
        this.deltaY = this.startScaleY * this.endScaleY - this.startScaleY
    },

    copy: function () {
        return new ScaleBy({ duration: this.duration,
                                 scaleX: this.endScaleX,
                                 scaleY: this.endScaleY})
    },

    reverse: function () {
        return new ScaleBy({duration: this.duration, scaleX: 1 / this.endScaleX, scaleY: 1 / this.endScaleY})
    }
})


/**
 * @class
 * Rotates a cocos.Node object to a certain angle by modifying its rotation
 * attribute. The direction will be decided by the shortest angle.
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.ActionInterval
 *
 * @opt {Float} duration Number of seconds to run action for
 * @opt {Float} angle Angle in degrees to rotate to
 */
function RotateTo (opts) {
    RotateTo.superclass.constructor.call(this, opts)

    this.dstAngle = opts.angle
}

RotateTo.inherit(ActionInterval, /** @lends cocos.actions.RotateTo# */ {
    /**
     * Final angle
     * @type Float
     */
    dstAngle: 0,

    /**
     * Initial angle
     * @type Float
     */
    startAngle: 0,

    /**
     * Angle delta
     * @type Float
     */
    diffAngle: 0,

    startWithTarget: function (target) {
        RotateTo.superclass.startWithTarget.call(this, target)

        this.startAngle = target.rotation

        if (this.startAngle > 0) {
            this.startAngle = (this.startAngle % 360)
        } else {
            this.startAngle = (this.startAngle % -360)
        }

        this.diffAngle = this.dstAngle - this.startAngle
        if (this.diffAngle > 180) {
            this.diffAngle -= 360
        } else if (this.diffAngle < -180) {
            this.diffAngle += 360
        }
    },

    update: function (t) {
        this.target.rotation = this.startAngle + this.diffAngle * t
    },

    copy: function () {
        return new RotateTo({duration: this.duration, angle: this.dstAngle})
    }
})

/**
 * @class
 * Rotates a cocos.Node object to a certain angle by modifying its rotation
 * attribute. The direction will be decided by the shortest angle.
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.RotateTo
 *
 * @opt {Float} duration Number of seconds to run action for
 * @opt {Float} angle Angle in degrees to rotate by
 */
function RotateBy (opts) {
    RotateBy.superclass.constructor.call(this, opts)

    this.angle = opts.angle
}

RotateBy.inherit(RotateTo, /** @lends cocos.actions.RotateBy# */ {
    /**
     * Number of degrees to rotate by
     * @type Float
     */
    angle: 0,

    startWithTarget: function (target) {
        RotateBy.superclass.startWithTarget.call(this, target)

        this.startAngle = this.target.rotation
    },

    update: function (t) {
        this.target.rotation = this.startAngle + this.angle * t
    },

    copy: function () {
        return new RotateBy({duration: this.duration, angle: this.angle})
    },

    reverse: function () {
        return new RotateBy({duration: this.duration, angle: -this.angle})
    }
})

/**
 * @class
 * Animates moving a cocos.nodes.Node object to a another point.
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.ActionInterval
 *
 * @opt {Float} duration Number of seconds to run action for
 * @opt {geometry.Point} position Destination position
 */
function MoveTo (opts) {
    MoveTo.superclass.constructor.call(this, opts)

    this.endPosition = util.copy(opts.position)
}

MoveTo.inherit(ActionInterval, /** @lends cocos.actions.MoveTo# */ {
    delta: null,
    startPosition: null,
    endPosition: null,

    startWithTarget: function (target) {
        MoveTo.superclass.startWithTarget.call(this, target)

        this.startPosition = util.copy(target.position)
        this.delta = geo.ccpSub(this.endPosition, this.startPosition)
    },

    update: function (t) {
        var startPosition = this.startPosition,
            delta = this.delta
        this.target.position = ccp(startPosition.x + delta.x * t, startPosition.y + delta.y * t)
    },

    copy: function() {
        return new MoveTo({duration: this.duration, position: this.endPosition})
    }
})

/**
 * @class
 * Animates moving a cocos.node.Node object by a given number of pixels
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.MoveTo
 *
 * @opt {Float} duration Number of seconds to run action for
 * @opt {geometry.Point} position Number of pixels to move by
 */
function MoveBy (opts) {
    MoveBy.superclass.constructor.call(this, opts)

    this.delta = util.copy(opts.position)
}

MoveBy.inherit(MoveTo, /** @lends cocos.actions.MoveBy# */ {
    startWithTarget: function (target) {
        var dTmp = this.delta
        MoveBy.superclass.startWithTarget.call(this, target)
        this.delta = dTmp
    },

    copy: function() {
         return new MoveBy({duration: this.duration, position: this.delta})
    },

    reverse: function() {
        var delta = this.delta
        return new MoveBy({duration: this.duration, position: geo.ccp(-delta.x, -delta.y)})
    }
})

/**
 * @class
 * Moves a cocos.nodes.Node simulating a parabolic jump movement by modifying its position attribute.
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.ActionInterval
 *
 * @opt {Float} duration Number of seconds to run action for
 * @opt {geometry.Point} startPosition Point at which jump starts
 * @opt {geometry.Point} delta Number of pixels to jump by
 * @opt {Float} height Height of jump
 * @opt {Integer} jumps Number of times to repeat
 */
function JumpBy (opts) {
    JumpBy.superclass.constructor.call(this, opts)

    this.delta  = util.copy(opts.delta)
    this.height = opts.height
    this.jumps  = opts.jumps
}

JumpBy.inherit(ActionInterval, /** @lends cocos.actions.JumpBy# */ {
    /**
     * Number of pixels to jump by
     * @type geometry.Point
     */
    delta: null,

    /**
     * Height of jump
     * @type Float
     */
    height: 0,

    /**
     * Number of times to jump
     * @type Integer
     */
    jumps: 0,

    /**
     * Starting point
     * @type geometry.Point
     */
    startPosition: null,

    copy: function() {
        return new JumpBy({duration: this.duration,
                                 delta: this.delta,
                                height: this.height,
                                 jumps: this.jumps})
    },

    startWithTarget: function(target) {
        JumpBy.superclass.startWithTarget.call(this, target)
        this.startPosition = target.position
    },

    update: function(t) {
        // parabolic jump
        var frac = (t * this.jumps) % 1.0
        var y = this.height * 4 * frac * (1 - frac)
        y += this.delta.y * t
        var x = this.delta.x * t
        this.target.position = geo.ccp(this.startPosition.x + x, this.startPosition.y + y)
    },

    reverse: function() {
        return new JumpBy({duration: this.duration,
                                 delta: geo.ccp(-this.delta.x, -this.delta.y),
                                height: this.height,
                                 jumps: this.jumps})
    }
})

/**
 * @class
 * Moves a Node to a parabolic position simulating a jump movement by modifying its position attribute.
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.JumpBy
 */
function JumpTo (opts) {
    JumpTo.superclass.constructor.call(this, opts)
}

JumpTo.inherit(JumpBy, /** @lends cocos.actions.JumpTo# */ {
    startWithTarget: function(target) {
        JumpTo.superclass.startWithTarget.call(this, target)
        this.delta = geo.ccp(this.delta.x - this.startPosition.x, this.delta.y - this.startPosition.y)
    }
})

/**
 * @class
 * An action that moves the target with a cubic Bezier curve by a certain distance.
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.ActionInterval
 *
 * @opt {geometry.BezierConfig} bezier Bezier control points object
 * @opt {Float} duration
 */
function BezierBy (opts) {
    BezierBy.superclass.constructor.call(this, opts)

    this.config = util.copy(opts.bezier)
}

BezierBy.inherit(ActionInterval, /** @lends cocos.actions.BezierBy# */ {
    /**
     * @type {geometry.BezierConfig}
     */
    config: null,

    startPosition: null,

    startWithTarget: function(target) {
        BezierBy.superclass.startWithTarget.call(this, target)
        this.startPosition = this.target.position
    },

    update: function(t) {
        var c = this.config
        var xa = 0,
            xb = c.controlPoint1.x,
            xc = c.controlPoint2.x,
            xd = c.endPosition.x,
            ya = 0,
            yb = c.controlPoint1.y,
            yc = c.controlPoint2.y,
            yd = c.endPosition.y

        var x = bezierat(xa, xb, xc, xd, t)
        var y = bezierat(ya, yb, yc, yd, t)

        this.target.position = geo.ccpAdd(this.startPosition, geo.ccp(x, y))
    },

    copy: function() {
        return new BezierBy({bezier: this.config, duration: this.duration})
    },

    reverse: function() {
        var c = this.config,
            bc = new geo.BezierConfig()

        bc.endPosition = geo.ccpNeg(c.endPosition)
        bc.controlPoint1 = geo.ccpAdd(c.controlPoint2, geo.ccpNeg(c.endPosition))
        bc.controlPoint2 = geo.ccpAdd(c.controlPoint1, geo.ccpNeg(c.endPosition))

        return new BezierBy({bezier: bc, duration: this.duration})
    }
})

/**
 * @class
 * An action that moves the target with a cubic Bezier curve to a destination point.
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.BezierBy
 */
function BezierTo (opts) {
    BezierTo.superclass.constructor.call(this, opts)
}

BezierTo.inherit(BezierBy, /** @lends cocos.actions.BezierTo# */ {
    startWithTarget: function(target) {
        BezierTo.superclass.startWithTarget.call(this, target)

        var c = this.config
        c.controlPoint1 = geo.ccpSub(c.controlPoint1, this.startPosition)
        c.controlPoint2 = geo.ccpSub(c.controlPoint2, this.startPosition)
        c.endPosition = geo.ccpSub(c.endPosition, this.startPosition)
    }
})

/**
 * @class
 * Blinks a Node object by modifying it's visible attribute
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.ActionInterval
 *
 * @opt {Integer} blinks Number of times to blink
 * @opt {Float} duration
 */
function Blink (opts) {
    Blink.superclass.constructor.call(this, opts)
    this.times = opts.blinks
}

Blink.inherit(ActionInterval, /** @lends cocos.actions.Blink# */ {
    /**
     * @type {Integer}
     */
    times: 1,

    update: function(t) {
        if (!this.isDone) {
            var slice = 1 / this.times
            var m = t % slice
            this.target.visible = (m > slice/2)
        }
    },

    copy: function() {
        return new Blink({duration: this.duration, blinks: this.times})
    },

    reverse: function() {
        return this.copy()
    }
})

/**
 * @class
 * Fades out a cocos.nodes.Node to zero opacity
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.ActionInterval
 */
function FadeOut (opts) {
    FadeOut.superclass.constructor.call(this, opts)
}

FadeOut.inherit(ActionInterval, /** @lends cocos.actions.FadeOut# */ {
    update: function (t) {
        var target = this.target
        if (!target) return
        target.opacity = 255 - (255 * t)
    },

    copy: function () {
        return new FadeOut({duration: this.duration})
    },

    reverse: function () {
        return new exports.FadeIn({duration: this.duration})
    }
})


/**
 * @class
 * Fades in a cocos.nodes.Node to 100% opacity
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.ActionInterval
 */
function FadeIn (opts) {
    FadeIn.superclass.constructor.call(this, opts)
}

FadeIn.inherit(ActionInterval, /** @lends cocos.actions.FadeIn# */ {
    update: function (t) {
        var target = this.target
        if (!target) return
        target.opacity = t * 255
    },

    copy: function () {
        return new FadeIn({duration: this.duration})
    },

    reverse: function () {
        return new exports.FadeOut({duration: this.duration})
    }
})

/**
 * @class
 * Fades a cocos.nodes.Node to a given opacity
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.ActionInterval
 */
function FadeTo (opts) {
    FadeTo.superclass.constructor.call(this, opts)
    this.toOpacity = opts.toOpacity
}

FadeTo.inherit(ActionInterval, /** @lends cocos.actions.FadeTo# */ {
    /**
     * The final opacity
     * @type Float
     */
    toOpacity: null,

    /**
     * The initial opacity
     * @type Float
     */
    fromOpacity: null,

    startWithTarget: function (target) {
        FadeTo.superclass.startWithTarget.call(this, target)
        this.fromOpacity = this.target.opacity
    },

    update: function (t) {
        var target = this.target
        if (!target) return

        target.opacity = this.fromOpacity + ( this.toOpacity - this.fromOpacity ) * t
    },

    copy: function() {
        return new FadeTo({duration: this.duration, toOpacity: this.toOpacity})
    }
})

/**
 * @class
 * Runs a pair of actions sequentially, one after another
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.ActionInterval
 *
 * @opt {cocos.actions.FiniteTimeAction} one 1st action to run
 * @opt {cocos.actions.FiniteTimeAction} two 2nd action to run
 */
function Sequence (opts) {
    if (opts.actions) {
        return initWithActions(Object.getPrototypeOf(this).constructor, opts.actions)
    }

    if (!opts.one) {
        throw "Sequence argument one must be non-nil"
    }
    if (!opts.two) {
        throw "Sequence argument two must be non-nil"
    }
    this.actions = []

    var d = opts.one.duration + opts.two.duration

    Sequence.superclass.constructor.call(this, {duration: d})

    this.actions[0] = opts.one
    this.actions[1] = opts.two
}

Sequence.inherit(ActionInterval, /** @lends cocos.actions.Sequence# */ {
    /**
     * Array of actions to run
     * @type cocos.nodes.Node[]
     */
    actions: null,

    split: 0,
    last: 0,

    startWithTarget: function (target) {
        Sequence.superclass.startWithTarget.call(this, target)
        this.split = this.actions[0].duration / this.duration
        this.last = -1
    },

    stop: function () {
        this.actions[0].stop()
        this.actions[1].stop()
        Sequence.superclass.stop.call(this)
    },

    update: function (t) {
        // This is confusing but will hopefully work better in conjunction
        // with modifer actions like Repeat & Spawn...
        var found = 0
        var new_t = 0

        if (t >= this.split) {
            found = 1
            if (this.split == 1) {
                new_t = 1
            } else {
                new_t = (t - this.split) / (1 - this.split)
            }
        } else {
            found = 0
            if (this.split != 0) {
                new_t = t / this.split
            } else {
                new_t = 1
            }
        }
        if (this.last == -1 && found == 1) {
            this.actions[0].startWithTarget(this.target)
            this.actions[0].update(1)
            this.actions[0].stop()
        }
        if (this.last != found) {
            if (this.last != -1) {
                this.actions[this.last].update(1)
                this.actions[this.last].stop()
            }
            this.actions[found].startWithTarget(this.target)
        }
        this.actions[found].update(new_t)
        this.last = found
    },

    copy: function () {
        // Constructor will copy actions
        return new Sequence({actions: this.actions})
    },

    reverse: function() {
        return new Sequence({actions: [this.actions[1].reverse(), this.actions[0].reverse()]})
    }
})

/**
 * @class
 * Repeats an action a number of times.
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.ActionInterval
 *
 * @opt {cocos.actions.ActionInterval} action Action to repeat
 * @opt {Integer} times Number of times to repeat
 */
function Repeat (opts) {
    var d = opts.action.duration * opts.times

    Repeat.superclass.constructor.call(this, {duration: d})

    this.times = opts.times
    this.other = opts.action.copy()
    this.total = 0
}

Repeat.inherit(ActionInterval, /** @lends cocos.actions.Repeat# */ {
    times: 1,
    total: 0,
    other: null,

    startWithTarget: function(target) {
        this.total = 0
        Repeat.superclass.startWithTarget.call(this, target)
        this.other.startWithTarget(target)
    },

    stop: function() {
        this.other.stop()
        Repeat.superclass.stop.call(this)
    },

    update: function(dt) {
        var t = dt * this.times

        if (t > (this.total+1)) {
            this.other.update(1)
            this.total += 1
            this.other.stop()
            this.other.startWithTarget(this.target)

            // If repeat is over
            if (this.total == this.times) {
                // set it in the original position
                this.other.update(0)
            } else {
                // otherwise start next repeat
                this.other.update(t - this.total)
            }
        } else {
            var r = t % 1.0

            // fix last repeat position otherwise it could be 0
            if (dt == 1) {
                r = 1
                this.total += 1
            }
            this.other.update(Math.min(r, 1))
        }
    },

    get isDone() {
        return this.total == this.times
    },

    copy: function() {
        // Constructor copies action
        return new Repeat({action: this.other, times: this.times})
    },

    reverse: function() {
        return new Repeat({action: this.other.reverse(), times: this.times})
    }
})

/**
 * @class
 * Executes multiple actions simultaneously
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.ActionInterval
 *
 * @opt {cocos.actions.FiniteTimeAction} one: first action to spawn
 * @opt {cocos.actions.FiniteTimeAction} two: second action to spawn
 */
function Spawn (opts) {
    if (opts.actions) {
        return initWithActions(Object.getPrototypeOf(this).constructor, opts.actions)
    }

    var action1 = opts.one,
        action2 = opts.two

    if (!action1 || !action2) {
        throw "cocos.actions.Spawn: required actions missing"
    }
    var d1 = action1.duration,
        d2 = action2.duration

    Spawn.superclass.constructor.call(this, {duration: Math.max(d1, d2)})

    this.one = action1
    this.two = action2

    if (d1 > d2) {
        this.set('two', new Sequence({actions: [
            action2,
            new DelayTime({duration: d1-d2})
        ]}))
    } else if (d1 < d2) {
        this.set('one', new Sequence({actions: [
            action1,
            new DelayTime({duration: d2-d1})
        ]}))
    }
}

Spawn.inherit(ActionInterval, /** @lends cocos.actions.Spawn# */ {
    one: null,
    two: null,

    startWithTarget: function (target) {
        Spawn.superclass.startWithTarget.call(this, target)
        this.one.startWithTarget(this.target)
        this.two.startWithTarget(this.target)
    },

    stop: function () {
        this.one.stop()
        this.two.stop()
        Spawn.superclass.stop.call(this)
    },

    step: function (dt) {
        if (this._firstTick) {
            this._firstTick = false
            this.elapsed = 0
        } else {
            this.elapsed += dt
        }
        this.one.step(dt)
        this.two.step(dt)
    },

    update: function (t) {
        this.one.update(t)
        this.two.update(t)
    },

    copy: function () {
        return new Spawn({one: this.one.copy(), two: this.two.copy()})
    },

    reverse: function () {
        return new Spawn({one: this.one.reverse(), two: this.two.reverse()})
    }
})

/**
 * @class
 * Animates a sprite given the name of an Animation
 *
 * @memberOf cocos.actions
 * @extends cocos.actions.ActionInterval
 *
 * @opt {Float} duration Number of seconds to run action for
 * @opt {cocos.Animation} animation Animation to run
 * @opt {Boolean} [restoreOriginalFrame=true] Return to first frame when finished
 */
function Animate (opts) {
    this.animation = opts.animation
    this.restoreOriginalFrame = opts.restoreOriginalFrame !== false
    opts.duration = this.animation.frames.length * this.animation.delay

    Animate.superclass.constructor.call(this, opts)
}

Animate.inherit(ActionInterval, /** @lends cocos.actions.Animate# */ {
    animation: null,
    restoreOriginalFrame: true,
    origFrame: null,

    startWithTarget: function (target) {
        Animate.superclass.startWithTarget.call(this, target)

        if (this.restoreOriginalFrame) {
            this.origFrame = this.target.displayedFrame
        }
    },

    stop: function () {
        if (this.target && this.restoreOriginalFrame) {
            var sprite = this.target
            sprite.displayFrame = this.origFrame
        }

        Animate.superclass.stop.call(this)
    },

    update: function (t) {
        var frames = this.animation.frames,
            numberOfFrames = frames.length,
            idx = Math.floor(t * numberOfFrames)

        if (idx >= numberOfFrames) {
            idx = numberOfFrames - 1
        }

        var sprite = this.target
        if (!sprite.isFrameDisplayed(frames[idx])) {
            sprite.displayFrame = frames[idx]
        }
    },

    copy: function () {
        return new Animate({animation: this.animation, restoreOriginalFrame: this.restoreOriginalFrame})
    }

})

exports.ActionInterval = ActionInterval
exports.DelayTime = DelayTime
exports.ScaleTo = ScaleTo
exports.ScaleBy = ScaleBy
exports.RotateTo = RotateTo
exports.RotateBy = RotateBy
exports.MoveTo = MoveTo
exports.MoveBy = MoveBy
exports.JumpBy = JumpBy
exports.JumpTo = JumpTo
exports.BezierBy = BezierBy
exports.BezierTo = BezierTo
exports.Blink = Blink
exports.FadeIn = FadeIn
exports.FadeOut = FadeOut
exports.FadeTo = FadeTo
exports.Spawn = Spawn
exports.Sequence = Sequence
exports.Repeat = Repeat
exports.Animate = Animate

// vim:et:st=4:fdm=marker:fdl=0:fdc=1

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/actions/ActionInterval.js


__jah__.resources["/libs/cocos2d/actions/index.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

var util = require('util'),
    path = require('path')

var modules = 'Action ActionInterval ActionInstant ActionEase'.split(' ')

/**
 * @memberOf cocos
 * @namespace Actions used to animate or change a Node
 */
var actions = {}

util.each(modules, function (mod, i) {
    util.extend(actions, require('./' + mod))
})

module.exports = actions

// vim:et:st=4:fdm=marker:fdl=0:fdc=1

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/actions/index.js


__jah__.resources["/libs/cocos2d/Animation.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

var util = require('util')

/**
 * @class
 * A cocos.Animation object is used to perform animations on the Sprite objects.
 *
 * The Animation object contains cocos.SpriteFrame objects, and a possible delay between the frames.
 * You can animate a cocos.Animation object by using the cocos.actions.Animate action.
 *
 * @memberOf cocos
 *
 * @opt {cocos.SpriteFrame[]} frames Frames to animate
 * @opt {Float} [delay=0.0] Delay between each frame
 *
 * @example
 * var animation = new cocos.Animation({frames: [f1, f2, f3], delay: 0.1})
 * sprite.runAction(new cocos.actions.Animate({animation: animation}))
 */
function Animation (opts) {
    Animation.superclass.constructor.call(this, opts)

    this.frames = opts.frames || []
    this.delay  = opts.delay  || 0.0
}

Animation.inherit(Object, /** @lends cocos.Animation# */ {
    /**
     * Unique name for the animation
     * @type String
     */
    name: null

    /**
     * Delay between each frame
     * @type Float
     */
  , delay: 0.0

    /**
     * Array of frames to animate
     * @type cocos.SpriteFrame[]
     */
  , frames: null
})

exports.Animation = Animation

// vim:et:st=4:fdm=marker:fdl=0:fdc=1

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/Animation.js


__jah__.resources["/libs/cocos2d/AnimationCache.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

var util = require('util'),
    Plist = require('Plist').Plist

/**
 * @class
 *
 * @memberOf cocos
 * @singleton
 */
function AnimationCache () {
    AnimationCache.superclass.constructor.call(this)

    this.animations = {}
}

AnimationCache.inherit(Object, /** @lends cocos.AnimationCache# */ {
    /**
     * Cached animations
     * @type Object
     */
    animations: null,

    /**
     * Add an animation to the cache
     *
     * @opt {String} name Unique name of the animation
     * @opt {cocos.Animcation} animation Animation to cache
     */
    addAnimation: function (opts) {
        var name = opts.name,
            animation = opts.animation

        this.animations[name] = animation
    },

    /**
     * Remove an animation from the cache
     *
     * @opt {String} name Unique name of the animation
     */
    removeAnimation: function (opts) {
        var name = opts.name

        delete this.animations[name]
    },

    /**
     * Get an animation from the cache
     *
     * @opt {String} name Unique name of the animation
     * @returns {cocos.Animation} Cached animation
     */
    getAnimation: function (opts) {
        var name = opts.name

        return this.animations[name]
    }
})

Object.defineProperty(AnimationCache, 'sharedAnimationCache', {
    /**
     * A shared singleton instance of cocos.AnimationCache
     *
     * @memberOf cocos.AnimationCache
     * @getter {cocos.AnimationCache} sharedAnimationCache
     */
    get: function () {
        if (!AnimationCache._instance) {
            AnimationCache._instance = new this()
        }

        return AnimationCache._instance
    }

  , enumerable: true
})

exports.AnimationCache = AnimationCache

// vim:et:st=4:fdm=marker:fdl=0:fdc=1

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/AnimationCache.js


__jah__.resources["/libs/cocos2d/config.js"] = {data: function (exports, require, module, __filename, __dirname) {
module.exports = {
    // Enable BObject's get/set/extend/etc methods
    ENABLE_DEPRECATED_METHODS: false,

    // Invert the Y axis so origin is at the bottom left
    FLIP_Y_AXIS: true,

    // No implemented yet
    ENABLE_WEB_GL: false,

    SHOW_REDRAW_REGIONS: false
}

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/config.js


__jah__.resources["/libs/cocos2d/Director.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

var util   = require('util')
  , events = require('events')
  , geo    = require('geometry')
  , ccp    = geo.ccp

var EventDispatcher = require('./EventDispatcher').EventDispatcher
  , TouchDispatcher = require('./TouchDispatcher').TouchDispatcher
  , Scheduler       = require('./Scheduler').Scheduler

/**
 * Create a new instance of Director. This is a singleton so you shouldn't use
 * the constructor directly. Instead grab the shared instance using the
 * cocos.Director.sharedDirector property.
 *
 * @class
 * Creates and handles the main view and manages how and when to execute the
 * Scenes.
 *
 * This class is a singleton so don't instantiate it yourself, instead use
 * cocos.Director.sharedDirector to return the instance.
 *
 * @memberOf cocos
 * @singleton
 */
function Director () {
    if (Director._instance) {
        throw new Error('Director instance already exists')
    }

    this.sceneStack = []
    this.window   = parent.window
    this.document = this.window.document

    // Prevent writing to some properties
    util.makeReadonly(this, 'canvas context sceneStack winSize isReady document window container isTouchScreen isMobile'.w)
}

Director.inherit(Object, /** @lends cocos.Director# */ {
    /**
     * Background colour of the canvas. It can be any valid CSS colour.
     * @type String
     */
    backgroundColor: 'rgb(0, 0, 0)'

    /**
     * DOM Window of the containing page
     *
     * The global 'window' property is a sandbox and not the global of the
     * containing page. If you need to access the real window, use this
     * property.
     *
     * @type DOMWindow
     * @readonly
     */
  , window: null

    /**
     * DOM Document of the containing page
     *
     * The global 'document' property is a sandbox and not the global of the
     * containing page. If you need to access the real document, use this
     * property.
     *
     * @type Document
     * @readonly
     */
  , document: null

    /**
     * Container DIV around the canvas
     *
     * This element is created dynamically. Its parent is the HTML element the
     * script was added into.
     *
     * @type HTMLDivElement
     * @readonly
     */
  , container: null

    /**
     * Canvas HTML element
     * @type HTMLCanvasElement
     * @readonly
     */
  , canvas: null

    /**
     * Canvas rendering context
     * @type CanvasRenderingContext2D
     * @readonly
     */
  , context: null

    /**
     * Stack of scenes
     * @type cocos.nodes.Scene[]
     * @readonly
     */
  , sceneStack: null

    /**
     * Size of the canvas
     * @type geometry.Size
     * @readonly
     */
  , winSize: null

    /**
     * Whether the scene is paused. When true the framerate will drop to conserve CPU
     * @type Boolean
     */
  , isPaused: false

    /**
     * Maximum possible framerate
     * @type Integer
     */
  , maxFrameRate: 30

    /**
     * Should the framerate be drawn in the corner
     * @type Boolean
     */
  , displayFPS: false

    /**
     * Scene that draws the preload progres bar
     * @type cocos.nodes.PreloadScene
     */
  , preloadScene: null

    /**
     * Has everything been preloaded and ready to use
     * @type Boolean
     * @readonly
     */
  , isReady: false

    /**
     * Is this running on a touchscreen device. e.g. iPhone or iPad
     * @type Boolean
     * @readonly
     */
  , isTouchScreen: false

    /**
     * Are we running on a mobile device?
     * @type Boolean
     * @readonly
     */
  , isMobile: false


    /**
     * Number of milliseconds since last frame
     * @type Float
     * @readonly
     */
  , dt: 0

    /**
     * The current orientation. Only available on mobile devices
     * @type String
     * @readonly
     */
  , orientation: 'unknown'

    /**
     * @private
     */
  , _nextDeltaTimeZero: false

    /**
     * @private
     * @type Float
     */
  , _lastUpdate: 0

    /**
     * @private
     * @type cocos.nodes.Scene
     */
  , _nextScene: null

  , _forcedOrientation: null

    /**
     * Make the canvas fullscreen.
     * On mobile devices this will try to set the viewport to avoid scaling the canvas
     */
  , fullscreen: function () {
        throw new Error("Fullscreen is not implemented on non-mobile devices yet")
    }

    /**
     * Resize the canvas to any size
     *
     * @param {Float} width The new width of the canvas
     * @param {Float} height The new height of the canvas
     */
  , resize: function (width, height) {
        if (!this.container) {
            return
        }

        events.trigger(this, 'beforeresize', {newSize: new geo.Size(width, height)})

        this.container.style.width = width + 'px'
        this.container.style.height = height + 'px'
        this.canvas.width = width
        this.canvas.height = height

        this._winSize = new geo.Size(width, height)

        var viewWidth = this.container.offsetWidth
          , viewHeight = this.container.offsetHeight
        this._viewSize = new geo.Size(viewWidth, viewHeight)
        this._viewScale = new geo.Size(width / viewWidth, height / viewHeight)


        if (FLIP_Y_AXIS) {
            this.context.translate(0, height)
            this.context.scale(1, -1)
        }

        events.trigger(this, 'resize')
    }

    /**
     * Append to an HTML element. It will create this canvas tag and attach
     * event listeners
     *
     * @param {HTMLElement} view Any HTML element to add the application to
     */
  , attachInView: function (view) {
        var document = this.document

        view = view || window.container || document.body

        while (view.firstChild) {
            view.removeChild(view.firstChild)
        }

        // Wrapper <div> which can be used for adding special HTML elements if required
        var container = this._container = document.createElement('div')
        container.style.position = 'relative'
        container.style.overflow = 'hidden'
        view.appendChild(container)

        var canvas = document.createElement('canvas')
        canvas.style.verticalAlign = 'bottom'
        this._canvas = canvas

        var context = canvas.getContext('2d')
        this._context = context

        this.resize(view.clientWidth, view.clientHeight)

        container.appendChild(canvas)

        this._setupEventCapturing()

        if (this._isFullscreen) {
            this.fullscreen()
        }
    }

  , _setupEventCapturing: function () {
        var document = this.document
          , canvas = this.canvas

        var eventDispatcher = EventDispatcher.sharedDispatcher

        this._setupMouseEventCapturing()

        // Keyboard events
        function keyDown(evt) {
            this._keysDown = this._keysDown || {}
            eventDispatcher.keyDown(evt)
        }
        function keyUp(evt) {
            eventDispatcher.keyUp(evt)
        }

        document.documentElement.addEventListener('keydown', keyDown, false)
        document.documentElement.addEventListener('keyup', keyUp, false)
    }

  , _setupMouseEventCapturing: function () {
        var document = this.document
          , canvas = this.canvas

        var eventDispatcher = EventDispatcher.sharedDispatcher

        var mouseDown = function (evt) {
            evt.locationInWindow = ccp(evt.clientX, evt.clientY)
            evt.locationInCanvas = this.convertEventToCanvas(evt)

            var mouseDragged = function (evt) {
                evt.locationInWindow = ccp(evt.clientX, evt.clientY)
                evt.locationInCanvas = this.convertEventToCanvas(evt)

                eventDispatcher.mouseDragged(evt)
            }.bind(this)

            var mouseUp = function (evt) {
                evt.locationInWindow = ccp(evt.clientX, evt.clientY)
                evt.locationInCanvas = this.convertEventToCanvas(evt)

                document.body.removeEventListener('mousemove', mouseDragged, false)
                document.body.removeEventListener('mouseup',   mouseUp,   false)


                eventDispatcher.mouseUp(evt)
            }.bind(this)

            document.body.addEventListener('mousemove', mouseDragged, false)
            document.body.addEventListener('mouseup',   mouseUp,   false)

            eventDispatcher.mouseDown(evt)
        }.bind(this)

        var mouseMoved = function (evt) {
            evt.locationInWindow = ccp(evt.clientX, evt.clientY)
            evt.locationInCanvas = this.convertEventToCanvas(evt)

            eventDispatcher.mouseMoved(evt)
        }.bind(this)

        canvas.addEventListener('mousedown', mouseDown, false)
        canvas.addEventListener('mousemove', mouseMoved, false)
    }

    /**
     * Create and push a Preload Scene which will draw a progress bar while
     * also preloading all assets.
     *
     * If you wish to customise the preload scene first inherit from cocos.nodes.PreloadScene
     * and then set Director.sharedDirector.preloadScene to an instance of your PreloadScene
     */
  , runPreloadScene: function () {
        if (!this.canvas) {
            this.attachInView()
        }

        var preloader = this.preloadScene
        if (!preloader) {
            var PreloadScene = this.preloadSceneConstructor || require('./nodes/ProgressBarPreloadScene').ProgressBarPreloadScene
            preloader = new PreloadScene()
            this.preloadScene = preloader
        }

        events.addListener(preloader, 'complete', function (preloader) {
            this._isReady = true
            events.trigger(this, 'ready', this)
        }.bind(this))

        this.pushScene(preloader)
        this.startAnimation()
    }

    /**
     * Enters the Director's main loop with the given Scene. Call it to run
     * only your FIRST scene. Don't call it if there is already a running
     * scene.
     *
     * @param {cocos.nodes.Scene} scene The scene to start
     */
  , runWithScene: function (scene) {
        var Scene = require('./nodes/Scene').Scene
        if (!(scene instanceof Scene)) {
            throw new Error("Director.runWithScene must be given an instance of Scene")
        }

        if (this._runningScene) {
            throw new Error("You can't run a Scene if another Scene is already running. Use replaceScene or pushScene instead")
        }

        this.pushScene(scene)
        this.startAnimation()
    }

    /**
     * Replaces the running scene with a new one. The running scene is
     * terminated. ONLY call it if there is a running scene.
     *
     * @param {cocos.nodes.Scene} scene The scene to replace with
     */
  , replaceScene: function (scene) {
        var Scene = require('./nodes/Scene').Scene
        if (!(scene instanceof Scene)) {
            throw new Error("Director.replaceScene must be given an instance of Scene")
        }
        var index = this.sceneStack.length

        this._sendCleanupToScene = true
        this.sceneStack.pop()
        this.sceneStack.push(scene)
        this._nextScene = scene
    }

    /**
     * Pops out a scene from the queue. This scene will replace the running
     * one. The running scene will be deleted. If there are no more scenes in
     * the stack the execution is terminated. ONLY call it if there is a
     * running scene.
     */
  , popScene: function () {
      throw new Error("Not implemented yet")
    }

    /**
     * Suspends the execution of the running scene, pushing it on the stack of
     * suspended scenes. The new scene will be executed. Try to avoid big
     * stacks of pushed scenes to reduce memory allocation. ONLY call it if
     * there is a running scene.
     *
     * @param {cocos.Scene} scene The scene to add to the stack
     */
  , pushScene: function (scene) {
        var Scene = require('./nodes/Scene').Scene
        if (!(scene instanceof Scene)) {
            throw new Error("Director.pushScene must be given an instance of Scene")
        }
        this._nextScene = scene
    }

    /**
     * The main loop is triggered again. Call this function only if
     * cocos.Directory#stopAnimation was called earlier.
     */
  , startAnimation: function () {
        if (!this.canvas) {
            this.attachInView()
        }

        this._animating = true
        this.animate()
    }

    /**
     * Draws the scene after waiting for the next animation frame time. This
     * controls the framerate.
     */
  , animate: function() {
        if (this._animating) {
            this.drawScene()
            this.animate._bound = this.animate._bound || this.animate.bind(this)
            window.requestAnimationFrame(this.animate._bound, this.canvas)
        }
    }

    /**
     * Stops the animation. Nothing will be drawn. The main loop won't be
     * triggered anymore. If you want to pause your animation call
     * cocos.Directory#pause instead.
     */
  , stopAnimation: function () {
        if (this._animationTimer) {
            clearInterval(this._animationTimer)
            this._animationTimer = null
        }
        this._animating = false
    }

    /**
     * @private
     * Calculate time since last call
     */
  , _calculateDeltaTime: function () {
        var now = (new Date()).getTime() / 1000

        if (this._nextDeltaTimeZero) {
            this.dt = 0
            this._nextDeltaTimeZero = false
        }

        this.dt = Math.max(0, now - this._lastUpdate)

        this._lastUpdate = now
    }

    /**
     * @private
     * The main run loop
     */
  , drawScene: function () {
        this._calculateDeltaTime()

        if (!this.isPaused) {
            Scheduler.sharedScheduler.tick(this.dt)
        }


        var context = this.context
        context.fillStyle = this.backgroundColor
        context.fillRect(0, 0, this.winSize.width, this.winSize.height)
        //this.canvas.width = this.canvas.width


        if (this._nextScene) {
            this._setNextScene()
        }

        // TODO partial redrawing
        var rect = new geo.Rect(0, 0, this.winSize.width, this.winSize.height)

        this._runningScene.visit(context, rect)

        if (this.displayFPS) {
            this._showFPS()
        }
    }

    /**
     * @private
     * Initialises the next scene
     */
  , _setNextScene: function () {
        // TODO transitions

        if (this._runningScene) {
            this._runningScene.onExit()
            if (this._sendCleanupToScene) {
                this._runningScene.cleanup()
            }
        }

        this._runningScene = this._nextScene

        this._nextScene = null

        this._runningScene.onEnter()
    }

     /**
      * Convert the coordinates in a mouse event so they're relative to the corner of the canvas
      *
      * @param {MouseEvent} evt
      */
  , convertEventToCanvas: function (evt) {
        return this.convertLocationToCanvas(evt.locationInWindow)
    }

  , convertLocationToCanvas: function (loc, noScroll) {
        var x = this.canvas.offsetLeft - (noScroll ? 0 : document.documentElement.scrollLeft)
          , y = this.canvas.offsetTop  - (noScroll ? 0 : document.documentElement.scrollTop)

        var o = this.canvas
        while ((o = o.offsetParent)) {
            x += o.offsetLeft - (noScroll ? 0 : o.scrollLeft)
            y += o.offsetTop  - (noScroll ? 0 : o.scrollTop)
        }

        var p = geo.ccpSub(loc, ccp(x, y))
        if (FLIP_Y_AXIS) {
            p.y = this._viewSize.height - p.y
        }

        p.x = p.x * this._viewScale.width
        p.y = p.y * this._viewScale.height

        return p
    }

  , convertTouchToCanvas: function (touch) {
        return this.convertLocationToCanvas(new geo.Point(touch.pageX, touch.pageY), true)
    }

    /**
     * @private
     * Draw the FPS counter
     */
  , _showFPS: function () {
        if (!this._fpsLabel) {
            var Label = require('./nodes/Label').Label
            this._fpsLabel = new Label({string: '', fontSize: 16})
            this._fpsLabel.anchorPoint = ccp(0, 0)
            this._fpsLabel.position = ccp(10, 10)
            this._frames = 0
            this._accumDt = 0
        }


        this._frames++
        this._accumDt += this.dt

        if (this._accumDt > 1.0 / 3.0)  {
            var frameRate = this._frames / this._accumDt
            this._frames = 0
            this._accumDt = 0

            this._fpsLabel.string = 'FPS: ' + (Math.round(frameRate * 100) / 100).toString()
        }



        this._fpsLabel.visit(this.context)
    }

})

Object.defineProperty(Director, 'sharedDirector', {
    /**
     * A shared singleton instance of cocos.Director
     *
     * @memberOf cocos.Director
     * @getter {cocos.Director} sharedDirector
     */
    get: function () {
        if (!Director._instance) {
            if (window.navigator.userAgent.match(/(iPhone|iPod|iPad|Android)/)) {
                Director._instance = new DirectorTouchScreen()
            } else {
                Director._instance = new this()
            }
        }

        return Director._instance
    }

  , enumerable: true
})

/**
 * @class
 * The Director singleton used on touch screen devices such as the iPhone, iPod and iPad
 *
 * @memberOf cocos
 * @extends cocos.Director
 */
function DirectorTouchScreen () {
    DirectorTouchScreen.superclass.constructor.call(this)

    // Hardcode some viewport sizes for iOS devices
    var ua = window.navigator.userAgent
    if (ua.match(/(iPhone|iPod)/)) {
        this.viewportSize = { portrait:  new geo.Size(320, 416)
                            , landscape: new geo.Size(480, 268)
                            }
    } else if (ua.match(/(iPad)/)) {
        this.viewportSize = { portrait:  new geo.Size(768, 928)
                            , landscape: new geo.Size(1024, 672)
                            }
    }
}

DirectorTouchScreen.inherit(Director, /** @lends cocos.DirectorTouchScreen */ {
    isTouchScreen: true

  , isMobile: true

  , viewportSize: null

    /**
     * Force the device to prevent scaling and expand the canvas to fill the entire available screen area
     */
  , fullscreen: function () {
        this._isFullscreen = true
        if (!this._container) {
            return // Wait to be attached to view
        }

        var viewport = this.document.querySelector('meta[name=viewport]')
        if (!viewport) {
            viewport = this.document.createElement('meta')
            viewport.setAttribute('name', 'viewport')
            this.document.querySelector('head').appendChild(viewport)
        }

        this.container.style.position = 'fixed'
        this.container.style.left     = 0
        this.container.style.top      = 0

        events.addListener(this, 'orientationchange', this._adjustFullscreen.bind(this))
        this.document.body.addEventListener('touchstart', function (e) {
            this.window.scrollTo(0, 0)
            e.preventDefault()
        }.bind(this))
        this._adjustFullscreen()
    }

    /**
     * @private
     */
  , _adjustFullscreen: function () {
        if (!this._container) {
            return
        }

        var vp
        if (this._forcedOrientation == 'landscape' || this.orientation.match(/landscape/)) {
            vp = this.viewportSize.landscape
        } else {
            vp = this.viewportSize.portrait
        }
        this.resize(vp.width, vp.height)

        var viewport = this.document.querySelector('meta[name=viewport]')
        viewport.setAttribute('content', 'initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no, width=' + this._winSize.width + ', height=' + this._winSize.height)

        // Rotate canvas to fake orientation
        /* TODO
        if (this._forcedOrientation == 'landscape' && !this.orientation.match(/landscape/)) {
            this.container.style.WebkitTransformOrigin = '0 0'
            this.container.style.WebkitTransform = 'translate(320px, 0) rotate(90deg)'
        } else {
            this.container.style.WebkitTransform = 'none'
        }
        */

        this.window.scrollTo(0, 0)
    }

    /**
     * Forces the screen orientation on a mobile device
     */
  , forceOrientation: function (orientation) {
        this._forcedOrientation = orientation
        if (this._isFullscreen) {
            this._adjustFullscreen()
        }
    }

  , _setupEventCapturing: function () {
        var document = this.document

        this._setupTouchEventCapturing()

        // Orientation detection
        if (typeof top.window.orientation != 'undefined') {
            this._updateOrientation()
            document.body.addEventListener('orientationchange', this._updateOrientation.bind(this), false)
        }

    }

  , _setupTouchEventCapturing: function () {
        var document = this.document
          , canvas = this.canvas

        // Touch events
        var eventDispatcher = TouchDispatcher.sharedDispatcher

        var touchStart = function (evt) {
            eventDispatcher.touchesBegan(evt)
        }.bind(this)

        var touchMove = function (evt) {
            eventDispatcher.touchesMoved(evt)
        }.bind(this)

        var touchEnd = function (evt) {
            eventDispatcher.touchesEnded(evt)
        }.bind(this)

        var touchCancel = function (evt) {
            eventDispatcher.touchesCancelled(evt)
        }.bind(this)

        canvas.addEventListener('touchstart',  touchStart,  false)
        canvas.addEventListener('touchmove',   touchMove,   false)
        canvas.addEventListener('touchend',    touchEnd,    false)
        canvas.addEventListener('touchcancel', touchCancel, false)
    }

  , _updateOrientation: function () {
        switch (top.window.orientation) {
        case 0:
            this.orientation = 'portrait'
            break

        case 90:
            this.orientation = 'landscapeLeft'
            break

        case -90:
            this.orientation = 'landscapeRight'
            break

        case 180:
            this.orientation = 'portraitUpsideDown'
            break
        }

        events.trigger(this, 'orientationchange')
    }

})

/**
 * @class
 * Pretends to run at a constant frame rate even if it slows down
 *
 * @memberOf cocos
 * @extends cocos.Director
 */
function DirectorFixedSpeed () {
    DirectorFixedSpeed.superclass.constructor.call(this)
}
DirectorFixedSpeed.inherit(Director, /** @lends cocos.DirectorFixedSpeed */ {
    /**
     * Frames per second to draw.
     * @type Integer
     */
    frameRate: 60

    /**
     * Calculate time since last call
     * @private
     */
  , _calculateDeltaTime: function () {
        if (this._nextDeltaTimeZero) {
            this.dt = 0
            this._nextDeltaTimeZero = false
        }

        this.dt = 1.0 / this.frameRate
    }

    /**
     * The main loop is triggered again. Call this function only if
     * cocos.Directory#stopAnimation was called earlier.
     */
  , startAnimation: function () {
        this._animationTimer = setInterval(this.drawScene.bind(this), 1000 / this.frameRate)
        this.drawScene()
    }
  }
)
Object.defineProperty(DirectorFixedSpeed, 'sharedDirector', Object.getOwnPropertyDescriptor(Director, 'sharedDirector'))

exports.Director = Director
exports.DirectorFixedSpeed = DirectorFixedSpeed

// vim:et:st=4:fdm=marker:fdl=0:fdc=1

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/Director.js


__jah__.resources["/libs/cocos2d/EventDispatcher.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

var util = require('util'),
    geo = require('geometry')

/**
 * @class
 * This singleton is responsible for dispatching Mouse and Keyboard events.
 *
 * @memberOf cocos
 * @singleton
 */
function EventDispatcher () {
    EventDispatcher.superclass.constructor.call(this)

    this.keyboardDelegates = []
    this.mouseDelegates = []

    this._keysDown = {}
}

EventDispatcher.inherit(Object, /** @lends cocos.EventDispatcher# */ {
    dispatchEvents: true,
    keyboardDelegates: null,
    mouseDelegates: null,
    _keysDown: null,

    addDelegate: function (opts) {
        var delegate = opts.delegate,
            priority = opts.priority,
            flags    = opts.flags,
            list     = opts.list

        var listElement = {
            delegate: delegate,
            priority: priority,
            flags: flags
        }

        var added = false
        for (var i = 0; i < list.length; i++) {
            var elem = list[i]
            if (priority < elem.priority) {
                // Priority is lower, so insert before elem
                list.splice(i, 0, listElement)
                added = true
                break
            }
        }

        // High priority; append to array
        if (!added) {
            list.push(listElement)
        }
    },

    removeDelegate: function (opts) {
        var delegate = opts.delegate,
            list = opts.list

        var idx = -1,
            i
        for (i = 0; i < list.length; i++) {
            var l = list[i]
            if (l.delegate == delegate) {
                idx = i
                break
            }
        }
        if (idx == -1) {
            return
        }
        list.splice(idx, 1)
    },
    removeAllDelegates: function (opts) {
        var list = opts.list

        list.splice(0, list.length - 1)
    },

    addMouseDelegate: function (opts) {
        var delegate = opts.delegate,
            priority = opts.priority

        var flags = 0

        // TODO flags

        this.addDelegate({delegate: delegate, priority: priority, flags: flags, list: this.mouseDelegates})
    },

    removeMouseDelegate: function (opts) {
        var delegate = opts.delegate

        this.removeDelegate({delegate: delegate, list: this.mouseDelegates})
    },

    removeAllMouseDelegate: function () {
        this.removeAllDelegates({list: this.mouseDelegates})
    },

    addKeyboardDelegate: function (opts) {
        var delegate = opts.delegate,
            priority = opts.priority

        var flags = 0

        // TODO flags

        this.addDelegate({delegate: delegate, priority: priority, flags: flags, list: this.keyboardDelegates})
    },

    removeKeyboardDelegate: function (opts) {
        var delegate = opts.delegate

        this.removeDelegate({delegate: delegate, list: this.keyboardDelegates})
    },

    removeAllKeyboardDelegate: function () {
        this.removeAllDelegates({list: this.keyboardDelegates})
    },



    // Mouse Events

    mouseDown: function (evt) {
        if (!this.dispatchEvents) {
            return
        }

        this._previousMouseMovePosition = geo.ccp(evt.clientX, evt.clientY)
        this._previousMouseDragPosition = geo.ccp(evt.clientX, evt.clientY)

        for (var i = 0; i < this.mouseDelegates.length; i++) {
            var entry = this.mouseDelegates[i]
            if (entry.delegate.mouseDown) {
                var swallows = entry.delegate.mouseDown(evt)
                if (swallows) {
                    break
                }
            }
        }
    },
    mouseMoved: function (evt) {
        if (!this.dispatchEvents) {
            return
        }

        if (this._previousMouseMovePosition) {
            evt.deltaX = evt.clientX - this._previousMouseMovePosition.x
            evt.deltaY = evt.clientY - this._previousMouseMovePosition.y
            if (FLIP_Y_AXIS) {
                evt.deltaY *= -1
            }
        } else {
            evt.deltaX = 0
            evt.deltaY = 0
        }
        this._previousMouseMovePosition = geo.ccp(evt.clientX, evt.clientY)

        for (var i = 0; i < this.mouseDelegates.length; i++) {
            var entry = this.mouseDelegates[i]
            if (entry.delegate.mouseMoved) {
                var swallows = entry.delegate.mouseMoved(evt)
                if (swallows) {
                    break
                }
            }
        }
    },
    mouseDragged: function (evt) {
        if (!this.dispatchEvents) {
            return
        }

        if (this._previousMouseDragPosition) {
            evt.deltaX = evt.clientX - this._previousMouseDragPosition.x
            evt.deltaY = evt.clientY - this._previousMouseDragPosition.y
            if (FLIP_Y_AXIS) {
                evt.deltaY *= -1
            }
        } else {
            evt.deltaX = 0
            evt.deltaY = 0
        }
        this._previousMouseDragPosition = geo.ccp(evt.clientX, evt.clientY)

        for (var i = 0; i < this.mouseDelegates.length; i++) {
            var entry = this.mouseDelegates[i]
            if (entry.delegate.mouseDragged) {
                var swallows = entry.delegate.mouseDragged(evt)
                if (swallows) {
                    break
                }
            }
        }
    },
    mouseUp: function (evt) {
        if (!this.dispatchEvents) {
            return
        }

        for (var i = 0; i < this.mouseDelegates.length; i++) {
            var entry = this.mouseDelegates[i]
            if (entry.delegate.mouseUp) {
                var swallows = entry.delegate.mouseUp(evt)
                if (swallows) {
                    break
                }
            }
        }
    },

    // Keyboard events
    keyDown: function (evt) {
        var kc = evt.keyCode
        if (!this.dispatchEvents) {
            return
        }

        // Repeating key
        if (this._keysDown[kc]) {
            return this.keyRepeat(evt)
        }

        this._keysDown[kc] = true

        for (var i = 0; i < this.keyboardDelegates.length; i++) {
            var entry = this.keyboardDelegates[i]
            if (entry.delegate.keyDown) {
                var swallows = entry.delegate.keyDown(evt)
                if (swallows) {
                    break
                }
            }
        }
    },

    keyRepeat: function (evt) {
        for (var i = 0; i < this.keyboardDelegates.length; i++) {
            var entry = this.keyboardDelegates[i]
            if (entry.delegate.keyRepeat) {
                var swallows = entry.delegate.keyRepeat(evt)
                if (swallows) {
                    break
                }
            }
        }
    },

    keyUp: function (evt) {
        if (!this.dispatchEvents) {
            return
        }

        var kc = evt.keyCode
        if (this._keysDown[kc]) {
            delete this._keysDown[kc]
        }

        for (var i = 0; i < this.keyboardDelegates.length; i++) {
            var entry = this.keyboardDelegates[i]
            if (entry.delegate.keyUp) {
                var swallows = entry.delegate.keyUp(evt)
                if (swallows) {
                    break
                }
            }
        }
    }

})

Object.defineProperty(EventDispatcher, 'sharedDispatcher', {
    /**
     * A shared singleton instance of cocos.EventDispatcher
     *
     * @memberOf cocos.EventDispatcher
     * @getter {cocos.EventDispatcher} sharedDispatcher
     */
    get: function () {
        if (!EventDispatcher._instance) {
            EventDispatcher._instance = new this()
        }

        return EventDispatcher._instance
    }

  , enumerable: true
})

exports.EventDispatcher = EventDispatcher

// vim:et:st=4:fdm=marker:fdl=0:fdc=1

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/EventDispatcher.js


__jah__.resources["/libs/cocos2d/globals.js"] = {data: function (exports, require, module, __filename, __dirname) {
module.exports = { FLIP_Y_AXIS: false
                 , ENABLE_WEB_GL: false
                 , SHOW_REDRAW_REGIONS: false
                 }

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/globals.js


__jah__.resources["/libs/cocos2d/index.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

var util = require('util'),
    path = require('path')

var modules = 'TextureAtlas Texture2D SpriteFrame SpriteFrameCache Director Animation AnimationCache Scheduler ActionManager TMXXMLParser'.split(' ')

/**
 * @namespace All cocos2d objects live in this namespace
 */
var cocos = {
    nodes: require('./nodes'),
    actions: require('./actions')
}

util.each(modules, function (mod, i) {
    util.extend(cocos, require('./' + mod))
})

module.exports = cocos

// vim:et:st=4:fdm=marker:fdl=0:fdc=1

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/index.js


__jah__.resources["/libs/cocos2d/init.js"] = {data: function (exports, require, module, __filename, __dirname) {
var path = require('path')

exports.main = function () {
    require.paths.push(path.join(__dirname, 'libs'))

    require('./remote_resources_patch')

    require('./js_extensions')

    // Link to the parent window's XHR object, IE9 will fail with cross-origin
    // errors if we don't.
    window.XMLHttpRequest = parent.XMLHttpRequest

    // Load default cocos2d config
    var config = require('./config')
    for (var k in config) {
        if (config.hasOwnProperty(k)) {
            window[k] = config[k]
        }
    }

    // Load appliaction config
    if (path.exists('/config.js')) {
        config = require('/config')
        for (var k in config) {
            if (config.hasOwnProperty(k)) {
                window[k] = config[k]
            }
        }
    }

    if (ENABLE_DEPRECATED_METHODS) {
        require('./legacy')
    }
};

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/init.js


__jah__.resources["/libs/cocos2d/js_extensions.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

var util = require('util')

/**
 * @memberOf Object
 */
function extend (target, parent, props) {
    target.prototype = Object.create(parent.prototype)
    target.prototype.constructor = target

    if (props) {
        util.extend(target.prototype, props)
    }

    return target
}

/**
 * @memberOf Function#
 */
function inherit (parent, props) {
    return extend(this, parent, props)
}

if (!Object.extend) {
    Object.extend = extend
}

if (!Function.prototype.inherit) {
    Function.prototype.inherit = inherit
}
if (!('id' in Object.prototype)) {

    /**
     * @ignore
     * Every object has a unique ID. It only gets set the first time its accessed
     */
    var nextObjectID = 1

    Object.defineProperty(Object.prototype, 'id', {
        get: function () {
            if (this === Object.prototype || Object.getPrototypeOf(this) === Object.prototype) {
                return
            }


            var id = nextObjectID++
            this.id = id
            return id
        },

        /** @ignore
         * Allow overwriting of 'id' property
         */
        set: function (x) {
            if (this === Object.prototype) {
                return
            }
            if (Object.getPrototypeOf(this) === Object.prototype) {
                Object.defineProperty(this, 'id', {
                    configurable: true,
                    writable: true,
                    enumerable: true,
                    value: x
                })
            } else {
                Object.defineProperty(this, 'id', {
                    configurable: true,
                    writable: true,
                    enumerable: false,
                    value: x
                })
            }

        }
    })
}

if (!('superclass' in Function.prototype)) {
    Object.defineProperty(Function.prototype, 'superclass', {
        /**
         * The object prototype that this was inherited from
         * @memberOf Function#
         * @getter {Object} superclass
         */
        get: function () {
            return Object.getPrototypeOf(this.prototype)
        },

        /** @ignore
         * Allow overwriting of 'superclass' property
         */
        set: function (x) {
            Object.defineProperty(this, 'superclass', {
                configurable: true,
                writable: true
            })

            this.superclass = x
        }
    })
}
if (!('__superclass__' in Function.prototype)) {
    Object.defineProperty(Function.prototype, '__superclass__', {
        get: function () {
            return Object.getPrototypeOf(this.prototype)
        }
    })
}

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/js_extensions.js


__jah__.resources["/libs/cocos2d/legacy.js"] = {data: function (exports, require, module, __filename, __dirname) {
/**
 * @fileOverview
 *
 * Provides support for deprecated methods
 */

var BObject = require('./libs/bobject').BObject
  , util = require('./libs/util')

/**
 * @ignore
 */
function applyAccessors (obj) {
    obj.get = BObject.get
    obj.set = BObject.set
    obj.extend = BObject.extend
    obj.create = BObject.create

    'get set extend triggerBeforeChanged triggerChanged'.w
        .forEach(function (prop) {
            obj.prototype[prop] = BObject.prototype[prop]
            if (!obj.prototype.hasOwnProperty('init')) {
                obj.prototype.init = obj
            }
        })
}

var pkgs = { _:       'ActionManager Director SpriteFrame TMXXMLParser Animation EventDispatcher SpriteFrameCache Texture2D AnimationCache Scheduler TextureAtlas'.w
           , nodes:   'AtlasNode BatchNode index Label LabelAtlas Layer Menu MenuItem Node PreloadScene ProgressBar RenderTexture Scene Sprite TMXLayer TMXTiledMap Transition'.w
           , actions: 'Action ActionEase ActionInterval ActionInstant'.w
           }

for (var ns in pkgs) {
    var modules = pkgs[ns]
      , dir = (ns == '_') ? '' : ns + '/'

    modules.forEach(function (n) {
        var mod = require('./' + dir + n)
        for (var m in mod) {
            if (mod.hasOwnProperty(m) && typeof mod[m] == 'function') {
                applyAccessors(mod[m])
            }
        }
    })

}

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/legacy.js


__jah__.resources["/libs/cocos2d/libs/base64.js"] = {data: function (exports, require, module, __filename, __dirname) {
/**
 * Thin wrapper around JXG's Base64 utils
 */

/** @ignore */
var JXG = require('JXGUtil');

/** @namespace */
var base64 = {
    /**
     * Decode a base64 encoded string into a binary string
     *
     * @param {String} input Base64 encoded data
     * @returns {String} Binary string
     */
    decode: function(input) {
        return JXG.Util.Base64.decode(input);
    },

    /**
     * Decode a base64 encoded string into a byte array
     *
     * @param {String} input Base64 encoded data
     * @returns {Integer[]} Array of bytes
     */
    decodeAsArray: function(input, bytes) {
        bytes = bytes || 1;

        var dec = JXG.Util.Base64.decode(input),
            ar = [], i, j, len;

        for (i = 0, len = dec.length/bytes; i < len; i++){
            ar[i] = 0;
            for (j = bytes-1; j >= 0; --j){
                ar[i] += dec.charCodeAt((i *bytes) +j) << (j *8);
            }
        }
        return ar;
    },

    /**
     * Encode a binary string into base64
     *
     * @param {String} input Binary string
     * @returns {String} Base64 encoded data
     */
    encode: function(input) {
        return JXG.Util.Base64.encode(input);
    }
};

module.exports = base64;

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/libs/base64.js


__jah__.resources["/libs/cocos2d/libs/bobject.js"] = {data: function (exports, require, module, __filename, __dirname) {
/*globals module exports resource require*/
/*jslint undef: true, strict: true, white: true, newcap: true, browser: true, indent: 4 */
"use strict";

var util = require('util'),
    events = require('events');


/**
 * @ignore
 */
function getAccessors(obj) {
    if (!obj.js_accessors_) {
        obj.js_accessors_ = {};
    }
    return obj.js_accessors_;
}

/**
 * @ignore
 */
function getBindings(obj) {
    if (!obj.js_bindings_) {
        obj.js_bindings_ = {};
    }
    return obj.js_bindings_;
}

/**
 * @ignore
 */
function addAccessor(obj, key, target, targetKey, noNotify) {
    getAccessors(obj)[key] = {
        key: targetKey,
        target: target
    };

    if (!noNotify) {
        obj.triggerChanged(key);
    }
}


/**
 * @ignore
 */
var objectID = 0;

/**
 * @class
 * [DEPRECATED] A bindable object. Allows observing and binding to its properties.
 *
 * @deprecated Since 0.2. Most functionality is now provided using ECMAScript 5 accessors and events.addPropertyListener
 * @see events.addPropertyListener
 * @see <a href="https://developer.mozilla.org/en/Core_JavaScript_1.5_Guide/Working_with_Objects#Defining_Getters_and_Setters">Defining Getters and Setters</a>
 */
function BObject () {
    return this.init.apply(this, arguments)
}
BObject.prototype = util.extend(BObject.prototype, /** @lends BObject# */{
    /**
     * The constructor for subclasses. Overwrite this for any initalisation you
     * need to do.
     * @ignore
     */
    init: function () {},

    /**
     * Get a property from the object. Always use this instead of trying to
     * access the property directly. This will ensure all bindings, setters and
     * getters work correctly.
     * 
     * @param {String} key Name of property to get or dot (.) separated path to a property
     * @returns {*} Value of the property
     */
    get: function (key) {
        var next = false
        if (~key.indexOf('.')) {
            var tokens = key.split('.');
            key = tokens.shift();
            next = tokens.join('.');
        }


        var accessor = getAccessors(this)[key],
            val;
        if (accessor) {
            val = accessor.target.get(accessor.key);
        } else {
            // Call getting function
            if (this['get_' + key]) {
                val = this['get_' + key]();
            } else {
                val = this[key];
            }
        }

        if (next) {
            return val.get(next);
        } else {
            return val;
        }
    },


    /**
     * Set a property on the object. Always use this instead of trying to
     * access the property directly. This will ensure all bindings, setters and
     * getters work correctly.
     * 
     * @param {String} key Name of property to get
     * @param {*} value New value for the property
     */
    set: function (key, value) {
        var accessor = getAccessors(this)[key],
            oldVal = this.get(key);


        this.triggerBeforeChanged(key, oldVal);

        if (accessor) {
            accessor.target.set(accessor.key, value);
        } else {

            if (this['set_' + key]) {
                this['set_' + key](value);
            } else {
                this[key] = value;
            }
        }
        this.triggerChanged(key, oldVal);
    },

    /**
     * Set multiple propertys in one go
     *
     * @param {Object} kvp An Object where the key is a property name and the value is the value to assign to the property
     *
     * @example
     * var props = {
     *   monkey: 'ook',
     *   cat: 'meow',
     *   dog: 'woof'
     * };
     * foo.setValues(props);
     * console.log(foo.get('cat')); // Logs 'meow'
     */
    setValues: function (kvp) {
        for (var x in kvp) {
            if (kvp.hasOwnProperty(x)) {
                this.set(x, kvp[x]);
            }
        }
    },

    changed: function (key) {
    },

    /**
     * @private
     */
    notify: function (key, oldVal) {
        var accessor = getAccessors(this)[key];
        if (accessor) {
            accessor.target.notify(accessor.key, oldVal);
        }
    },

    /**
     * @private
     */
    triggerBeforeChanged: function (key, oldVal) {
        events.trigger(this, key.toLowerCase() + '_before_changed', oldVal);
    },

    /**
     * @private
     */
    triggerChanged: function (key, oldVal) {
        events.trigger(this, key.toLowerCase() + '_changed', oldVal);
    },

    /**
     * Bind the value of a property on this object to that of another object so
     * they always have the same value. Setting the value on either object will update
     * the other too.
     *
     * @param {String} key Name of the property on this object that should be bound
     * @param {BOject} target Object to bind to
     * @param {String} [targetKey=key] Key on the target object to bind to
     * @param {Boolean} [noNotify=false] Set to true to prevent this object's property triggering a 'changed' event when adding the binding
     */
    bindTo: function (key, target, targetKey, noNotify) {
        targetKey = targetKey || key;
        var self = this;
        this.unbind(key);

        var oldVal = this.get(key);

        // When bound property changes, trigger a 'changed' event on this one too
        getBindings(this)[key] = events.addListener(target, targetKey.toLowerCase() + '_changed', function (oldVal) {
            self.triggerChanged(key, oldVal);
        });

        addAccessor(this, key, target, targetKey, noNotify);
    },

    /**
     * Remove binding from a property which set setup using BObject#bindTo.
     *
     * @param {String} key Name of the property on this object to unbind
     */
    unbind: function (key) {
        var binding = getBindings(this)[key];
        if (!binding) {
            return;
        }

        delete getBindings(this)[key];
        events.removeListener(binding);
        // Grab current value from bound property
        var val = this.get(key);
        delete getAccessors(this)[key];
        // Set bound value
        this[key] = val;
    },

    /**
     * Remove all bindings on this object
     */
    unbindAll: function () {
        var keys = [],
            bindings = getBindings(this);
        for (var k in bindings) {
            if (bindings.hasOwnProperty(k)) {
                this.unbind(k);
            }
        }
    }
});


/**
 * Create a new instance of this object
 * @returns {BObject} New instance of this object
 */
BObject.create = function () {
    var ret = Object.create(this.prototype)
      , ret2 = ret.constructor.apply(ret, arguments);
    return ret2 || ret;
};

/**
 * Create a new subclass by extending this one
 * @returns {Object} A new subclass of this object
 */
BObject.extend = function (targetOrProperties, parent) {
    var target, properties
    if (arguments.length < 2) {
        properties = targetOrProperties
        parent = this
    } else {
        target = targetOrProperties
    }

    if (arguments.length > 1 && this !== BObject) {
        throw new Error("extend only accepts 1 argument")
    }

    target = target || function () {
        return this.init.apply(this, arguments)
    }

    var args = [], i, x;

    // Copy 'static' properties
    util.extend(target, parent)

    // Add given properties to the prototype
    target.prototype = Object.create(parent.prototype)
    target.prototype.constructor = target
    if (properties) {
        util.extend(target.prototype, properties)
    }

    // Create new instance
    return target
};

/**
 * Get a property from the class. Always use this instead of trying to
 * access the property directly. This will ensure all bindings, setters and
 * getters work correctly.
 * 
 * @function
 * @param {String} key Name of property to get
 * @returns {*} Value of the property
 */
BObject.get = BObject.prototype.get;

/**
 * Set a property on the class. Always use this instead of trying to
 * access the property directly. This will ensure all bindings, setters and
 * getters work correctly.
 * 
 * @function
 * @param {String} key Name of property to get
 * @param {*} value New value for the property
 */
BObject.set = BObject.prototype.set;

var BArray = BObject.extend(/** @lends BArray# */{

    /**
     * @constructs
     * [DEPRECATED] A bindable array. Allows observing for changes made to its contents
     *
     * @deprecated Since 0.2
     * @extends BObject
     * @param {Array} [array=[]] A normal JS array to use for data
     */
    init: function (array) {
        this.array = array || [];
        this.set('length', this.array.length);
    },

    /**
     * Get an item
     *
     * @param {Integer} i Index to get item from
     * @returns {*} Value stored in the array at index 'i'
     */
    getAt: function (i) {
        return this.array[i];
    },

    /**
     * Set an item -- Overwrites any existing item at index
     *
     * @param {Integer} i Index to set item to
     * @param {*} value Value to assign to index
     */
    setAt: function (i, value) {
        var oldVal = this.array[i];
        this.array[i] = value;

        events.trigger(this, 'set_at', i, oldVal);
    },

    /**
     * Insert a new item into the array without overwriting anything
     *
     * @param {Integer} i Index to insert item at
     * @param {*} value Value to insert
     */
    insertAt: function (i, value) {
        this.array.splice(i, 0, value);
        this.set('length', this.array.length);
        events.trigger(this, 'insert_at', i);
    },

    /**
     * Remove item from the array and return it
     *
     * @param {Integer} i Index to remove
     * @returns {*} Value that was removed
     */
    removeAt: function (i) {
        var oldVal = this.array[i];
        this.array.splice(i, 1);
        this.set('length', this.array.length);
        events.trigger(this, 'remove_at', i, oldVal);

        return oldVal;
    },

    /**
     * Get the internal Javascript Array instance
     *
     * @returns {Array} Internal Javascript Array
     */
    getArray: function () {
        return this.array;
    },

    /**
     * Append a value to the end of the array and return its new length
     *
     * @param {*} value Value to append to the array
     * @returns {Integer} New length of the array
     */
    push: function (value) {
        this.insertAt(this.array.length, value);
        return this.array.length;
    },

    /**
     * Remove value from the end of the array and return it
     *
     * @returns {*} Value that was removed
     */
    pop: function () {
        return this.removeAt(this.array.length - 1);
    }
});

exports.BObject = BObject;
exports.BArray = BArray;

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/libs/bobject.js


__jah__.resources["/libs/cocos2d/libs/geometry.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

var util = require('util')

var RE_PAIR = /\{\s*([\d.\-]+)\s*,\s*([\d.\-]+)\s*\}/,
    RE_DOUBLE_PAIR = /\{\s*(\{[\s\d,.\-]+\})\s*,\s*(\{[\s\d,.\-]+\})\s*\}/

Math.PI_2 = 1.57079632679489661923132169163975144     /* pi/2 */

/** @namespace */
var geometry = {
    /**
     * @class
     * A 2D point in space
     *
     * @param {Float} x X value
     * @param {Float} y Y value
     */
    Point: function (x, y) {
        /**
         * X coordinate
         * @type Float
         */
        this.x = x

        /**
         * Y coordinate
         * @type Float
         */
        this.y = y
    },

    /**
     * @class
     * A 3D point in space
     *
     * @param {Float} x X value
     * @param {Float} y Y value
     * @param {Float} z Z value
     */
    Point3D: function (x, y, z) {
        /**
         * X coordinate
         * @type Float
         */
        this.x = x

        /**
         * Y coordinate
         * @type Float
         */
        this.y = y

        /**
         * Z coordinate
         * @type Float
         */
        this.z = z
    },

    /**
     * @class
     * A 2D size
     *
     * @param {Float} w Width
     * @param {Float} h Height
     */
    Size: function (w, h) {
        /**
         * Width
         * @type Float
         */
        this.width = w

        /**
         * Height
         * @type Float
         */
        this.height = h
    },

    /**
     * @class
     * A 3D size
     *
     * @param {Float} w Width
     * @param {Float} h Height
     * @param {Float} d Depth
     */
    Size3D: function (w, h, d) {
        /**
         * Width
         * @type Float
         */
        this.width = w

        /**
         * Height
         * @type Float
         */
        this.height = h

        /**
         * Depth
         * @type Float
         */
        this.depth = d
    },

    /**
     * @class
     * A rectangle
     *
     * @param {Float} x X value
     * @param {Float} y Y value
     * @param {Float} w Width
     * @param {Float} h Height
     */
    Rect: function (x, y, w, h) {
        /**
         * Coordinate in 2D space
         * @type geometry.Point
         */
        this.origin = new geometry.Point(x, y)

        /**
         * Size in 2D space
         * @type geometry.Size
         */
        this.size = new geometry.Size(w, h)
    },

    /**
     * @class
     * Transform matrix
     *
     * @param {Float} a
     * @param {Float} b
     * @param {Float} c
     * @param {Float} d
     * @param {Float} tx
     * @param {Float} ty
     */
    TransformMatrix: function (a, b, c, d, tx, ty) {
        this.a = a
        this.b = b
        this.c = c
        this.d = d
        this.tx = tx
        this.ty = ty
    },

    /**
     * @class 
     * Bezier curve control object
     *
     * @param {geometry.Point} controlPoint1
     * @param {geometry.Point} controlPoint2
     * @param {geometry.Point} endPoint
     */
    BezierConfig: function(p1, p2, ep) {
        this.controlPoint1 = util.copy(p1)
        this.controlPoint2 = util.copy(p2)
        this.endPosition = util.copy(ep)
    },
    
    /**
     * Creates a geometry.Point instance
     *
     * @param {Float} x X coordinate
     * @param {Float} y Y coordinate
     * @returns {geometry.Point} 
     */
    ccp: function (x, y) {
        return module.exports.pointMake(x, y)
    },

    /**
     * Add the values of two points together
     *
     * @param {geometry.Point} p1 First point
     * @param {geometry.Point} p2 Second point
     * @returns {geometry.Point} New point
     */
    ccpAdd: function (p1, p2) {
        return geometry.ccp(p1.x + p2.x, p1.y + p2.y)
    },

    /**
     * Subtract the values of two points
     *
     * @param {geometry.Point} p1 First point
     * @param {geometry.Point} p2 Second point
     * @returns {geometry.Point} New point
     */
    ccpSub: function (p1, p2) {
        return geometry.ccp(p1.x - p2.x, p1.y - p2.y)
    },

    /**
     * Muliply the values of two points together
     *
     * @param {geometry.Point} p1 First point
     * @param {geometry.Point} p2 Second point
     * @returns {geometry.Point} New point
     */
    ccpMult: function (p1, p2) {
        return geometry.ccp(p1.x * p2.x, p1.y * p2.y)
    },


    /**
     * Invert the values of a geometry.Point
     *
     * @param {geometry.Point} p Point to invert
     * @returns {geometry.Point} New point
     */
    ccpNeg: function (p) {
        return geometry.ccp(-p.x, -p.y)
    },

    /**
     * Round values on a geometry.Point to whole numbers
     *
     * @param {geometry.Point} p Point to round
     * @returns {geometry.Point} New point
     */
    ccpRound: function (p) {
        return geometry.ccp(Math.round(p.x), Math.round(p.y))
    },

    /**
     * Round up values on a geometry.Point to whole numbers
     *
     * @param {geometry.Point} p Point to round
     * @returns {geometry.Point} New point
     */
    ccpCeil: function (p) {
        return geometry.ccp(Math.ceil(p.x), Math.ceil(p.y))
    },

    /**
     * Round down values on a geometry.Point to whole numbers
     *
     * @param {geometry.Point} p Point to round
     * @returns {geometry.Point} New point
     */
    ccpFloor: function (p) {
        return geometry.ccp(Math.floor(p.x), Math.floor(p.y))
    },

    /**
     * A point at 0x0
     *
     * @returns {geometry.Point} New point at 0x0
     */
    PointZero: function () {
        return geometry.ccp(0, 0)
    },

    /**
     * @returns {geometry.Rect}
     */
    rectMake: function (x, y, w, h) {
        return new geometry.Rect(x, y, w, h)
    },

    /**
     * @returns {geometry.Rect}
     */
    rectFromString: function (str) {
        var matches = str.match(RE_DOUBLE_PAIR),
            p = geometry.pointFromString(matches[1]),
            s = geometry.sizeFromString(matches[2])

        return geometry.rectMake(p.x, p.y, s.width, s.height)
    },

    /**
     * @returns {geometry.Size}
     */
    sizeMake: function (w, h) {
        return new geometry.Size(w, h)
    },

    /**
     * @returns {geometry.Size}
     */
    sizeFromString: function (str) {
        var matches = str.match(RE_PAIR),
            w = parseFloat(matches[1]),
            h = parseFloat(matches[2])

        return geometry.sizeMake(w, h)
    },

    /**
     * @returns {geometry.Point}
     */
    pointMake: function (x, y) {
        return new geometry.Point(x, y)
    },

    /**
     * @returns {geometry.Point}
     */
    pointFromString: function (str) {
        var matches = str.match(RE_PAIR),
            x = parseFloat(matches[1]),
            y = parseFloat(matches[2])

        return geometry.pointMake(x, y)
    },

    /**
     * @returns {Boolean}
     */
    rectContainsPoint: function (r, p) {
        return ((p.x >= r.origin.x && p.x <= r.origin.x + r.size.width) &&
                (p.y >= r.origin.y && p.y <= r.origin.y + r.size.height))
    },

    /**
     * Returns the smallest rectangle that contains the two source rectangles.
     *
     * @param {geometry.Rect} r1
     * @param {geometry.Rect} r2
     * @returns {geometry.Rect}
     */
    rectUnion: function (r1, r2) {
        var rect = new geometry.Rect(0, 0, 0, 0)

        rect.origin.x = Math.min(r1.origin.x, r2.origin.x)
        rect.origin.y = Math.min(r1.origin.y, r2.origin.y)
        rect.size.width = Math.max(r1.origin.x + r1.size.width, r2.origin.x + r2.size.width) - rect.origin.x
        rect.size.height = Math.max(r1.origin.y + r1.size.height, r2.origin.y + r2.size.height) - rect.origin.y

        return rect
    },

    /**
     * @returns {Boolean}
     */
    rectOverlapsRect: function (r1, r2) {
        if (r1.origin.x + r1.size.width < r2.origin.x) {
            return false
        }
        if (r2.origin.x + r2.size.width < r1.origin.x) {
            return false
        }
        if (r1.origin.y + r1.size.height < r2.origin.y) {
            return false
        }
        if (r2.origin.y + r2.size.height < r1.origin.y) {
            return false
        }

        return true
    },

    /**
     * Returns the overlapping portion of 2 rectangles
     *
     * @param {geometry.Rect} lhsRect First rectangle
     * @param {geometry.Rect} rhsRect Second rectangle
     * @returns {geometry.Rect} The overlapping portion of the 2 rectangles
     */
    rectIntersection: function (lhsRect, rhsRect) {

        var intersection = new geometry.Rect(
            Math.max(geometry.rectGetMinX(lhsRect), geometry.rectGetMinX(rhsRect)),
            Math.max(geometry.rectGetMinY(lhsRect), geometry.rectGetMinY(rhsRect)),
            0,
            0
        )

        intersection.size.width = Math.min(geometry.rectGetMaxX(lhsRect), geometry.rectGetMaxX(rhsRect)) - geometry.rectGetMinX(intersection)
        intersection.size.height = Math.min(geometry.rectGetMaxY(lhsRect), geometry.rectGetMaxY(rhsRect)) - geometry.rectGetMinY(intersection)

        return intersection
    },

    /**
     * @returns {Boolean}
     */
    pointEqualToPoint: function (point1, point2) {
        return (point1.x == point2.x && point1.y == point2.y)
    },

    /**
     * @returns {Boolean}
     */
    sizeEqualToSize: function (size1, size2) {
        return (size1.width == size2.width && size1.height == size2.height)
    },

    /**
     * @returns {Boolean}
     */
    rectEqualToRect: function (rect1, rect2) {
        return (module.exports.sizeEqualToSize(rect1.size, rect2.size) && module.exports.pointEqualToPoint(rect1.origin, rect2.origin))
    },

    /**
     * @returns {Float}
     */
    rectGetMinX: function (rect) {
        return rect.origin.x
    },

    /**
     * @returns {Float}
     */
    rectGetMinY: function (rect) {
        return rect.origin.y
    },

    /**
     * @returns {Float}
     */
    rectGetMaxX: function (rect) {
        return rect.origin.x + rect.size.width
    },

    /**
     * @returns {Float}
     */
    rectGetMaxY: function (rect) {
        return rect.origin.y + rect.size.height
    },

    boundingRectMake: function (p1, p2, p3, p4) {
        var minX = Math.min(p1.x, p2.x, p3.x, p4.x)
        var minY = Math.min(p1.y, p2.y, p3.y, p4.y)
        var maxX = Math.max(p1.x, p2.x, p3.x, p4.x)
        var maxY = Math.max(p1.y, p2.y, p3.y, p4.y)

        return new geometry.Rect(minX, minY, (maxX - minX), (maxY - minY))
    },

    /**
     * @returns {geometry.Point}
     */
    pointApplyAffineTransform: function (point, t) {

        /*
        aPoint.x * aTransform.a + aPoint.y * aTransform.c + aTransform.tx,
        aPoint.x * aTransform.b + aPoint.y * aTransform.d + aTransform.ty
        */

        return new geometry.Point(t.a * point.x + t.c * point.y + t.tx, t.b * point.x + t.d * point.y + t.ty)

    },

    /**
     * Apply a transform matrix to a rectangle
     *
     * @param {geometry.Rect} rect Rectangle to transform
     * @param {geometry.TransformMatrix} trans TransformMatrix to apply to rectangle
     * @returns {geometry.Rect} A new transformed rectangle
     */
    rectApplyAffineTransform: function (rect, trans) {

        var p1 = geometry.ccp(geometry.rectGetMinX(rect), geometry.rectGetMinY(rect))
        var p2 = geometry.ccp(geometry.rectGetMaxX(rect), geometry.rectGetMinY(rect))
        var p3 = geometry.ccp(geometry.rectGetMinX(rect), geometry.rectGetMaxY(rect))
        var p4 = geometry.ccp(geometry.rectGetMaxX(rect), geometry.rectGetMaxY(rect))

        p1 = geometry.pointApplyAffineTransform(p1, trans)
        p2 = geometry.pointApplyAffineTransform(p2, trans)
        p3 = geometry.pointApplyAffineTransform(p3, trans)
        p4 = geometry.pointApplyAffineTransform(p4, trans)

        return geometry.boundingRectMake(p1, p2, p3, p4)
    },

    /**
     * Inverts a transform matrix
     *
     * @param {geometry.TransformMatrix} trans TransformMatrix to invert
     * @returns {geometry.TransformMatrix} New transform matrix
     */
    affineTransformInvert: function (trans) {
        var determinant = 1 / (trans.a * trans.d - trans.b * trans.c)

        return new geometry.TransformMatrix(
            determinant * trans.d,
            -determinant * trans.b,
            -determinant * trans.c,
            determinant * trans.a,
            determinant * (trans.c * trans.ty - trans.d * trans.tx),
            determinant * (trans.b * trans.tx - trans.a * trans.ty)
        )
    },

    /**
     * Multiply 2 transform matrices together
     * @param {geometry.TransformMatrix} lhs Left matrix
     * @param {geometry.TransformMatrix} rhs Right matrix
     * @returns {geometry.TransformMatrix} New transform matrix
     */
    affineTransformConcat: function (lhs, rhs) {
        return new geometry.TransformMatrix(
            lhs.a * rhs.a + lhs.b * rhs.c,
            lhs.a * rhs.b + lhs.b * rhs.d,
            lhs.c * rhs.a + lhs.d * rhs.c,
            lhs.c * rhs.b + lhs.d * rhs.d,
            lhs.tx * rhs.a + lhs.ty * rhs.c + rhs.tx,
            lhs.tx * rhs.b + lhs.ty * rhs.d + rhs.ty
        )
    },

    /**
     * @returns {Float}
     */
    degreesToRadians: function (angle) {
        return angle / 180.0 * Math.PI
    },

    /**
     * @returns {Float}
     */
    radiansToDegrees: function (angle) {
        return angle * (180.0 / Math.PI)
    },

    /**
     * Translate (move) a transform matrix
     *
     * @param {geometry.TransformMatrix} trans TransformMatrix to translate
     * @param {Float} tx Amount to translate along X axis
     * @param {Float} ty Amount to translate along Y axis
     * @returns {geometry.TransformMatrix} A new TransformMatrix
     */
    affineTransformTranslate: function (trans, tx, ty) {
        var newTrans = util.copy(trans)
        newTrans.tx = trans.tx + trans.a * tx + trans.c * ty
        newTrans.ty = trans.ty + trans.b * tx + trans.d * ty
        return newTrans
    },

    /**
     * Rotate a transform matrix
     *
     * @param {geometry.TransformMatrix} trans TransformMatrix to rotate
     * @param {Float} angle Angle in radians
     * @returns {geometry.TransformMatrix} A new TransformMatrix
     */
    affineTransformRotate: function (trans, angle) {
        var sin = Math.sin(angle),
            cos = Math.cos(angle)

        return new geometry.TransformMatrix(
            trans.a * cos + trans.c * sin,
            trans.b * cos + trans.d * sin,
            trans.c * cos - trans.a * sin,
            trans.d * cos - trans.b * sin,
            trans.tx,
            trans.ty
        )
    },

    /**
     * Scale a transform matrix
     *
     * @param {geometry.TransformMatrix} trans TransformMatrix to scale
     * @param {Float} sx X scale factor
     * @param {Float} [sy=sx] Y scale factor
     * @returns {geometry.TransformMatrix} A new TransformMatrix
     */
    affineTransformScale: function (trans, sx, sy) {
        if (sy === undefined) {
            sy = sx
        }

        return new geometry.TransformMatrix(trans.a * sx, trans.b * sx, trans.c * sy, trans.d * sy, trans.tx, trans.ty)
    },

    /**
     * @returns {geometry.TransformMatrix} identity matrix
     */
    affineTransformIdentity: function () {
        return new geometry.TransformMatrix(1, 0, 0, 1, 0, 0)
    }
}

Object.defineProperty(geometry.Point, 'zero', {
    /**
     * Point(0, 0)
     *
     * @memberOf geometry.Point
     * @getter geometry.Point zero
     */
    get: function () {
        return new geometry.Point(0, 0)
    }
})

module.exports = geometry

// vim:et:st=4:fdm=marker:fdl=0:fdc=1

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/libs/geometry.js


__jah__.resources["/libs/cocos2d/libs/gzip.js"] = {data: function (exports, require, module, __filename, __dirname) {
/**
 * @fileoverview 
 */

/** @ignore */
var JXG = require('./JXGUtil');

/**
 * @namespace
 * Wrappers around JXG's GZip utils
 * @see JXG.Util
 */
var gzip = {
    /**
     * Unpack a gzipped byte array
     *
     * @param {Integer[]} input Byte array
     * @returns {String} Unpacked byte string
     */
    unzip: function(input) {
        return (new JXG.Util.Unzip(input)).unzip()[0][0];
    },

    /**
     * Unpack a gzipped byte string encoded as base64
     *
     * @param {String} input Byte string encoded as base64
     * @returns {String} Unpacked byte string
     */
    unzipBase64: function(input) {
        return (new JXG.Util.Unzip(JXG.Util.Base64.decodeAsArray(input))).unzip()[0][0];
    },

    /**
     * Unpack a gzipped byte string encoded as base64
     *
     * @param {String} input Byte string encoded as base64
     * @param {Integer} bytes Bytes per array item
     * @returns {Integer[]} Unpacked byte array
     */
    unzipBase64AsArray: function(input, bytes) {
        bytes = bytes || 1;

        var dec = this.unzipBase64(input),
            ar = [], i, j, len;
        for (i = 0, len = dec.length/bytes; i < len; i++){
            ar[i] = 0;
            for (j = bytes-1; j >= 0; --j){
                ar[i] += dec.charCodeAt((i *bytes) +j) << (j *8);
            }
        }
        return ar;
    },

    /**
     * Unpack a gzipped byte array
     *
     * @param {Integer[]} input Byte array
     * @param {Integer} bytes Bytes per array item
     * @returns {Integer[]} Unpacked byte array
     */
    unzipAsArray: function (input, bytes) {
        bytes = bytes || 1;

        var dec = this.unzip(input),
            ar = [], i, j, len;
        for (i = 0, len = dec.length/bytes; i < len; i++){
            ar[i] = 0;
            for (j = bytes-1; j >= 0; --j){
                ar[i] += dec.charCodeAt((i *bytes) +j) << (j *8);
            }
        }
        return ar;
    }

};

module.exports = gzip;

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/libs/gzip.js


__jah__.resources["/libs/cocos2d/libs/JXGUtil.js"] = {data: function (exports, require, module, __filename, __dirname) {
/*
    Copyright 2008,2009
        Matthias Ehmann,
        Michael Gerhaeuser,
        Carsten Miller,
        Bianca Valentin,
        Alfred Wassermann,
        Peter Wilfahrt

    This file is part of JSXGraph.

    JSXGraph is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    JSXGraph is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with JSXGraph.  If not, see <http://www.gnu.org/licenses/>.
*/

/**
 * @fileoverview Utilities for uncompressing and base64 decoding
 */

/** @namespace */
var JXG = {};

/**
  * @class Util class
  * Class for gunzipping, unzipping and base64 decoding of files.
  * It is used for reading GEONExT, Geogebra and Intergeo files.
  *
  * Only Huffman codes are decoded in gunzip.
  * The code is based on the source code for gunzip.c by Pasi Ojala 
  * @see <a href="http://www.cs.tut.fi/~albert/Dev/gunzip/gunzip.c">http://www.cs.tut.fi/~albert/Dev/gunzip/gunzip.c</a>
  * @see <a href="http://www.cs.tut.fi/~albert">http://www.cs.tut.fi/~albert</a>
  */
JXG.Util = {};
                                 
/**
 * Unzip zip files
 */
JXG.Util.Unzip = function (barray){
    var outputArr = [],
        output = "",
        debug = false,
        gpflags,
        files = 0,
        unzipped = [],
        crc,
        buf32k = new Array(32768),
        bIdx = 0,
        modeZIP=false,

        CRC, SIZE,
    
        bitReverse = [
        0x00, 0x80, 0x40, 0xc0, 0x20, 0xa0, 0x60, 0xe0,
        0x10, 0x90, 0x50, 0xd0, 0x30, 0xb0, 0x70, 0xf0,
        0x08, 0x88, 0x48, 0xc8, 0x28, 0xa8, 0x68, 0xe8,
        0x18, 0x98, 0x58, 0xd8, 0x38, 0xb8, 0x78, 0xf8,
        0x04, 0x84, 0x44, 0xc4, 0x24, 0xa4, 0x64, 0xe4,
        0x14, 0x94, 0x54, 0xd4, 0x34, 0xb4, 0x74, 0xf4,
        0x0c, 0x8c, 0x4c, 0xcc, 0x2c, 0xac, 0x6c, 0xec,
        0x1c, 0x9c, 0x5c, 0xdc, 0x3c, 0xbc, 0x7c, 0xfc,
        0x02, 0x82, 0x42, 0xc2, 0x22, 0xa2, 0x62, 0xe2,
        0x12, 0x92, 0x52, 0xd2, 0x32, 0xb2, 0x72, 0xf2,
        0x0a, 0x8a, 0x4a, 0xca, 0x2a, 0xaa, 0x6a, 0xea,
        0x1a, 0x9a, 0x5a, 0xda, 0x3a, 0xba, 0x7a, 0xfa,
        0x06, 0x86, 0x46, 0xc6, 0x26, 0xa6, 0x66, 0xe6,
        0x16, 0x96, 0x56, 0xd6, 0x36, 0xb6, 0x76, 0xf6,
        0x0e, 0x8e, 0x4e, 0xce, 0x2e, 0xae, 0x6e, 0xee,
        0x1e, 0x9e, 0x5e, 0xde, 0x3e, 0xbe, 0x7e, 0xfe,
        0x01, 0x81, 0x41, 0xc1, 0x21, 0xa1, 0x61, 0xe1,
        0x11, 0x91, 0x51, 0xd1, 0x31, 0xb1, 0x71, 0xf1,
        0x09, 0x89, 0x49, 0xc9, 0x29, 0xa9, 0x69, 0xe9,
        0x19, 0x99, 0x59, 0xd9, 0x39, 0xb9, 0x79, 0xf9,
        0x05, 0x85, 0x45, 0xc5, 0x25, 0xa5, 0x65, 0xe5,
        0x15, 0x95, 0x55, 0xd5, 0x35, 0xb5, 0x75, 0xf5,
        0x0d, 0x8d, 0x4d, 0xcd, 0x2d, 0xad, 0x6d, 0xed,
        0x1d, 0x9d, 0x5d, 0xdd, 0x3d, 0xbd, 0x7d, 0xfd,
        0x03, 0x83, 0x43, 0xc3, 0x23, 0xa3, 0x63, 0xe3,
        0x13, 0x93, 0x53, 0xd3, 0x33, 0xb3, 0x73, 0xf3,
        0x0b, 0x8b, 0x4b, 0xcb, 0x2b, 0xab, 0x6b, 0xeb,
        0x1b, 0x9b, 0x5b, 0xdb, 0x3b, 0xbb, 0x7b, 0xfb,
        0x07, 0x87, 0x47, 0xc7, 0x27, 0xa7, 0x67, 0xe7,
        0x17, 0x97, 0x57, 0xd7, 0x37, 0xb7, 0x77, 0xf7,
        0x0f, 0x8f, 0x4f, 0xcf, 0x2f, 0xaf, 0x6f, 0xef,
        0x1f, 0x9f, 0x5f, 0xdf, 0x3f, 0xbf, 0x7f, 0xff
    ],
    
    cplens = [
        3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27, 31,
        35, 43, 51, 59, 67, 83, 99, 115, 131, 163, 195, 227, 258, 0, 0
    ],

    cplext = [
        0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2,
        3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 0, 99, 99
    ], /* 99==invalid */

    cpdist = [
        0x0001, 0x0002, 0x0003, 0x0004, 0x0005, 0x0007, 0x0009, 0x000d,
        0x0011, 0x0019, 0x0021, 0x0031, 0x0041, 0x0061, 0x0081, 0x00c1,
        0x0101, 0x0181, 0x0201, 0x0301, 0x0401, 0x0601, 0x0801, 0x0c01,
        0x1001, 0x1801, 0x2001, 0x3001, 0x4001, 0x6001
    ],

    cpdext = [
        0,  0,  0,  0,  1,  1,  2,  2,
        3,  3,  4,  4,  5,  5,  6,  6,
        7,  7,  8,  8,  9,  9, 10, 10,
        11, 11, 12, 12, 13, 13
    ],
    
    border = [16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15],
    
    bA = barray,

    bytepos=0,
    bitpos=0,
    bb = 1,
    bits=0,
    
    NAMEMAX = 256,
    
    nameBuf = [],
    
    fileout;
    
    function readByte(){
        bits+=8;
        if (bytepos<bA.length){
            //if (debug)
            //    document.write(bytepos+": "+bA[bytepos]+"<br>");
            return bA[bytepos++];
        } else
            return -1;
    };

    function byteAlign(){
        bb = 1;
    };
    
    function readBit(){
        var carry;
        bits++;
        carry = (bb & 1);
        bb >>= 1;
        if (bb==0){
            bb = readByte();
            carry = (bb & 1);
            bb = (bb>>1) | 0x80;
        }
        return carry;
    };

    function readBits(a) {
        var res = 0,
            i = a;
    
        while(i--) {
            res = (res<<1) | readBit();
        }
        if(a) {
            res = bitReverse[res]>>(8-a);
        }
        return res;
    };
        
    function flushBuffer(){
        //document.write('FLUSHBUFFER:'+buf32k);
        bIdx = 0;
    };
    function addBuffer(a){
        SIZE++;
        //CRC=updcrc(a,crc);
        buf32k[bIdx++] = a;
        outputArr.push(String.fromCharCode(a));
        //output+=String.fromCharCode(a);
        if(bIdx==0x8000){
            //document.write('ADDBUFFER:'+buf32k);
            bIdx=0;
        }
    };
    
    function HufNode() {
        this.b0=0;
        this.b1=0;
        this.jump = null;
        this.jumppos = -1;
    };

    var LITERALS = 288;
    
    var literalTree = new Array(LITERALS);
    var distanceTree = new Array(32);
    var treepos=0;
    var Places = null;
    var Places2 = null;
    
    var impDistanceTree = new Array(64);
    var impLengthTree = new Array(64);
    
    var len = 0;
    var fpos = new Array(17);
    fpos[0]=0;
    var flens;
    var fmax;
    
    function IsPat() {
        while (1) {
            if (fpos[len] >= fmax)
                return -1;
            if (flens[fpos[len]] == len)
                return fpos[len]++;
            fpos[len]++;
        }
    };

    function Rec() {
        var curplace = Places[treepos];
        var tmp;
        if (debug)
    		document.write("<br>len:"+len+" treepos:"+treepos);
        if(len==17) { //war 17
            return -1;
        }
        treepos++;
        len++;
    	
        tmp = IsPat();
        if (debug)
        	document.write("<br>IsPat "+tmp);
        if(tmp >= 0) {
            curplace.b0 = tmp;    /* leaf cell for 0-bit */
            if (debug)
            	document.write("<br>b0 "+curplace.b0);
        } else {
        /* Not a Leaf cell */
        curplace.b0 = 0x8000;
        if (debug)
        	document.write("<br>b0 "+curplace.b0);
        if(Rec())
            return -1;
        }
        tmp = IsPat();
        if(tmp >= 0) {
            curplace.b1 = tmp;    /* leaf cell for 1-bit */
            if (debug)
            	document.write("<br>b1 "+curplace.b1);
            curplace.jump = null;    /* Just for the display routine */
        } else {
            /* Not a Leaf cell */
            curplace.b1 = 0x8000;
            if (debug)
            	document.write("<br>b1 "+curplace.b1);
            curplace.jump = Places[treepos];
            curplace.jumppos = treepos;
            if(Rec())
                return -1;
        }
        len--;
        return 0;
    };

    function CreateTree(currentTree, numval, lengths, show) {
        var i;
        /* Create the Huffman decode tree/table */
        //document.write("<br>createtree<br>");
        if (debug)
        	document.write("currentTree "+currentTree+" numval "+numval+" lengths "+lengths+" show "+show);
        Places = currentTree;
        treepos=0;
        flens = lengths;
        fmax  = numval;
        for (i=0;i<17;i++)
            fpos[i] = 0;
        len = 0;
        if(Rec()) {
            //fprintf(stderr, "invalid huffman tree\n");
            if (debug)
            	alert("invalid huffman tree\n");
            return -1;
        }
        if (debug){
        	document.write('<br>Tree: '+Places.length);
        	for (var a=0;a<32;a++){
            	document.write("Places["+a+"].b0="+Places[a].b0+"<br>");
            	document.write("Places["+a+"].b1="+Places[a].b1+"<br>");
        	}
        }

        return 0;
    };
    
    function DecodeValue(currentTree) {
        var len, i,
            xtreepos=0,
            X = currentTree[xtreepos],
            b;

        /* decode one symbol of the data */
        while(1) {
            b=readBit();
            if (debug)
            	document.write("b="+b);
            if(b) {
                if(!(X.b1 & 0x8000)){
                	if (debug)
                    	document.write("ret1");
                    return X.b1;    /* If leaf node, return data */
                }
                X = X.jump;
                len = currentTree.length;
                for (i=0;i<len;i++){
                    if (currentTree[i]===X){
                        xtreepos=i;
                        break;
                    }
                }
                //xtreepos++;
            } else {
                if(!(X.b0 & 0x8000)){
                	if (debug)
                    	document.write("ret2");
                    return X.b0;    /* If leaf node, return data */
                }
                //X++; //??????????????????
                xtreepos++;
                X = currentTree[xtreepos];
            }
        }
        if (debug)
        	document.write("ret3");
        return -1;
    };
    
    function DeflateLoop() {
    var last, c, type, i, len;

    do {
        /*if((last = readBit())){
            fprintf(errfp, "Last Block: ");
        } else {
            fprintf(errfp, "Not Last Block: ");
        }*/
        last = readBit();
        type = readBits(2);
        switch(type) {
            case 0:
            	if (debug)
                	alert("Stored\n");
                break;
            case 1:
            	if (debug)
                	alert("Fixed Huffman codes\n");
                break;
            case 2:
            	if (debug)
                	alert("Dynamic Huffman codes\n");
                break;
            case 3:
            	if (debug)
                	alert("Reserved block type!!\n");
                break;
            default:
            	if (debug)
                	alert("Unexpected value %d!\n", type);
                break;
        }

        if(type==0) {
            var blockLen, cSum;

            // Stored 
            byteAlign();
            blockLen = readByte();
            blockLen |= (readByte()<<8);

            cSum = readByte();
            cSum |= (readByte()<<8);

            if(((blockLen ^ ~cSum) & 0xffff)) {
                document.write("BlockLen checksum mismatch\n");
            }
            while(blockLen--) {
                c = readByte();
                addBuffer(c);
            }
        } else if(type==1) {
            var j;

            /* Fixed Huffman tables -- fixed decode routine */
            while(1) {
            /*
                256    0000000        0
                :   :     :
                279    0010111        23
                0   00110000    48
                :    :      :
                143    10111111    191
                280 11000000    192
                :    :      :
                287 11000111    199
                144    110010000    400
                :    :       :
                255    111111111    511
    
                Note the bit order!
                */

            j = (bitReverse[readBits(7)]>>1);
            if(j > 23) {
                j = (j<<1) | readBit();    /* 48..255 */

                if(j > 199) {    /* 200..255 */
                    j -= 128;    /*  72..127 */
                    j = (j<<1) | readBit();        /* 144..255 << */
                } else {        /*  48..199 */
                    j -= 48;    /*   0..151 */
                    if(j > 143) {
                        j = j+136;    /* 280..287 << */
                        /*   0..143 << */
                    }
                }
            } else {    /*   0..23 */
                j += 256;    /* 256..279 << */
            }
            if(j < 256) {
                addBuffer(j);
                //document.write("out:"+String.fromCharCode(j));
                /*fprintf(errfp, "@%d %02x\n", SIZE, j);*/
            } else if(j == 256) {
                /* EOF */
                break;
            } else {
                var len, dist;

                j -= 256 + 1;    /* bytes + EOF */
                len = readBits(cplext[j]) + cplens[j];

                j = bitReverse[readBits(5)]>>3;
                if(cpdext[j] > 8) {
                    dist = readBits(8);
                    dist |= (readBits(cpdext[j]-8)<<8);
                } else {
                    dist = readBits(cpdext[j]);
                }
                dist += cpdist[j];

                /*fprintf(errfp, "@%d (l%02x,d%04x)\n", SIZE, len, dist);*/
                for(j=0;j<len;j++) {
                    var c = buf32k[(bIdx - dist) & 0x7fff];
                    addBuffer(c);
                }
            }
            } // while
        } else if(type==2) {
            var j, n, literalCodes, distCodes, lenCodes;
            var ll = new Array(288+32);    // "static" just to preserve stack
    
            // Dynamic Huffman tables 
    
            literalCodes = 257 + readBits(5);
            distCodes = 1 + readBits(5);
            lenCodes = 4 + readBits(4);
            //document.write("<br>param: "+literalCodes+" "+distCodes+" "+lenCodes+"<br>");
            for(j=0; j<19; j++) {
                ll[j] = 0;
            }
    
            // Get the decode tree code lengths
    
            //document.write("<br>");
            for(j=0; j<lenCodes; j++) {
                ll[border[j]] = readBits(3);
                //document.write(ll[border[j]]+" ");
            }
            //fprintf(errfp, "\n");
            //document.write('<br>ll:'+ll);
            len = distanceTree.length;
            for (i=0; i<len; i++)
                distanceTree[i]=new HufNode();
            if(CreateTree(distanceTree, 19, ll, 0)) {
                flushBuffer();
                return 1;
            }
            if (debug){
            	document.write("<br>distanceTree");
            	for(var a=0;a<distanceTree.length;a++){
                	document.write("<br>"+distanceTree[a].b0+" "+distanceTree[a].b1+" "+distanceTree[a].jump+" "+distanceTree[a].jumppos);
                	/*if (distanceTree[a].jumppos!=-1)
                    	document.write(" "+distanceTree[a].jump.b0+" "+distanceTree[a].jump.b1);
                	*/
            	}
            }
            //document.write('<BR>tree created');
    
            //read in literal and distance code lengths
            n = literalCodes + distCodes;
            i = 0;
            var z=-1;
            if (debug)
            	document.write("<br>n="+n+" bits: "+bits+"<br>");
            while(i < n) {
                z++;
                j = DecodeValue(distanceTree);
                if (debug)
                	document.write("<br>"+z+" i:"+i+" decode: "+j+"    bits "+bits+"<br>");
                if(j<16) {    // length of code in bits (0..15)
                       ll[i++] = j;
                } else if(j==16) {    // repeat last length 3 to 6 times 
                       var l;
                    j = 3 + readBits(2);
                    if(i+j > n) {
                        flushBuffer();
                        return 1;
                    }
                    l = i ? ll[i-1] : 0;
                    while(j--) {
                        ll[i++] = l;
                    }
                } else {
                    if(j==17) {        // 3 to 10 zero length codes
                        j = 3 + readBits(3);
                    } else {        // j == 18: 11 to 138 zero length codes 
                        j = 11 + readBits(7);
                    }
                    if(i+j > n) {
                        flushBuffer();
                        return 1;
                    }
                    while(j--) {
                        ll[i++] = 0;
                    }
                }
            }
            /*for(j=0; j<literalCodes+distCodes; j++) {
                //fprintf(errfp, "%d ", ll[j]);
                if ((j&7)==7)
                    fprintf(errfp, "\n");
            }
            fprintf(errfp, "\n");*/
            // Can overwrite tree decode tree as it is not used anymore
            len = literalTree.length;
            for (i=0; i<len; i++)
                literalTree[i]=new HufNode();
            if(CreateTree(literalTree, literalCodes, ll, 0)) {
                flushBuffer();
                return 1;
            }
            len = literalTree.length;
            for (i=0; i<len; i++)
                distanceTree[i]=new HufNode();
            var ll2 = new Array();
            for (i=literalCodes; i <ll.length; i++){
                ll2[i-literalCodes]=ll[i];
            }    
            if(CreateTree(distanceTree, distCodes, ll2, 0)) {
                flushBuffer();
                return 1;
            }
            if (debug)
           		document.write("<br>literalTree");
            while(1) {
                j = DecodeValue(literalTree);
                if(j >= 256) {        // In C64: if carry set
                    var len, dist;
                    j -= 256;
                    if(j == 0) {
                        // EOF
                        break;
                    }
                    j--;
                    len = readBits(cplext[j]) + cplens[j];
    
                    j = DecodeValue(distanceTree);
                    if(cpdext[j] > 8) {
                        dist = readBits(8);
                        dist |= (readBits(cpdext[j]-8)<<8);
                    } else {
                        dist = readBits(cpdext[j]);
                    }
                    dist += cpdist[j];
                    while(len--) {
                        var c = buf32k[(bIdx - dist) & 0x7fff];
                        addBuffer(c);
                    }
                } else {
                    addBuffer(j);
                }
            }
        }
    } while(!last);
    flushBuffer();

    byteAlign();
    return 0;
};

JXG.Util.Unzip.prototype.unzipFile = function(name) {
    var i;
	this.unzip();
	//alert(unzipped[0][1]);
	for (i=0;i<unzipped.length;i++){
		if(unzipped[i][1]==name) {
			return unzipped[i][0];
		}
	}
	
  };
    
    
JXG.Util.Unzip.prototype.unzip = function() {
	//convertToByteArray(input);
	if (debug)
		alert(bA);
	/*for (i=0;i<bA.length*8;i++){
		document.write(readBit());
		if ((i+1)%8==0)
			document.write(" ");
	}*/
	/*for (i=0;i<bA.length;i++){
		document.write(readByte()+" ");
		if ((i+1)%8==0)
			document.write(" ");
	}
	for (i=0;i<bA.length;i++){
		document.write(bA[i]+" ");
		if ((i+1)%16==0)
			document.write("<br>");
	}	
	*/
	//alert(bA);
	nextFile();
	return unzipped;
  };
    
 function nextFile(){
 	if (debug)
 		alert("NEXTFILE");
 	outputArr = [];
 	var tmp = [];
 	modeZIP = false;
	tmp[0] = readByte();
	tmp[1] = readByte();
	if (debug)
		alert("type: "+tmp[0]+" "+tmp[1]);
	if (tmp[0] == parseInt("78",16) && tmp[1] == parseInt("da",16)){ //GZIP
		if (debug)
			alert("GEONExT-GZIP");
		DeflateLoop();
		if (debug)
			alert(outputArr.join(''));
		unzipped[files] = new Array(2);
    	unzipped[files][0] = outputArr.join('');
    	unzipped[files][1] = "geonext.gxt";
    	files++;
	}
	if (tmp[0] == parseInt("1f",16) && tmp[1] == parseInt("8b",16)){ //GZIP
		if (debug)
			alert("GZIP");
		//DeflateLoop();
		skipdir();
		if (debug)
			alert(outputArr.join(''));
		unzipped[files] = new Array(2);
    	unzipped[files][0] = outputArr.join('');
    	unzipped[files][1] = "file";
    	files++;
	}
	if (tmp[0] == parseInt("50",16) && tmp[1] == parseInt("4b",16)){ //ZIP
		modeZIP = true;
		tmp[2] = readByte();
		tmp[3] = readByte();
		if (tmp[2] == parseInt("3",16) && tmp[3] == parseInt("4",16)){
			//MODE_ZIP
			tmp[0] = readByte();
			tmp[1] = readByte();
			if (debug)
				alert("ZIP-Version: "+tmp[1]+" "+tmp[0]/10+"."+tmp[0]%10);
			
			gpflags = readByte();
			gpflags |= (readByte()<<8);
			if (debug)
				alert("gpflags: "+gpflags);
			
			var method = readByte();
			method |= (readByte()<<8);
			if (debug)
				alert("method: "+method);
			
			readByte();
			readByte();
			readByte();
			readByte();
			
			var crc = readByte();
			crc |= (readByte()<<8);
			crc |= (readByte()<<16);
			crc |= (readByte()<<24);
			
			var compSize = readByte();
			compSize |= (readByte()<<8);
			compSize |= (readByte()<<16);
			compSize |= (readByte()<<24);
			
			var size = readByte();
			size |= (readByte()<<8);
			size |= (readByte()<<16);
			size |= (readByte()<<24);
			
			if (debug)
				alert("local CRC: "+crc+"\nlocal Size: "+size+"\nlocal CompSize: "+compSize);
			
			var filelen = readByte();
			filelen |= (readByte()<<8);
			
			var extralen = readByte();
			extralen |= (readByte()<<8);
			
			if (debug)
				alert("filelen "+filelen);
			i = 0;
			nameBuf = [];
			while (filelen--){ 
				var c = readByte();
				if (c == "/" | c ==":"){
					i = 0;
				} else if (i < NAMEMAX-1)
					nameBuf[i++] = String.fromCharCode(c);
			}
			if (debug)
				alert("nameBuf: "+nameBuf);
			
			//nameBuf[i] = "\0";
			if (!fileout)
				fileout = nameBuf;
			
			var i = 0;
			while (i < extralen){
				c = readByte();
				i++;
			}
				
			CRC = 0xffffffff;
			SIZE = 0;
			
			if (size = 0 && fileOut.charAt(fileout.length-1)=="/"){
				//skipdir
				if (debug)
					alert("skipdir");
			}
			if (method == 8){
				DeflateLoop();
				if (debug)
					alert(outputArr.join(''));
				unzipped[files] = new Array(2);
				unzipped[files][0] = outputArr.join('');
    			unzipped[files][1] = nameBuf.join('');
    			files++;
				//return outputArr.join('');
			}
			skipdir();
		}
	}
 };
	
function skipdir(){
    var crc, 
        tmp = [],
        compSize, size, os, i, c;
    
	if ((gpflags & 8)) {
		tmp[0] = readByte();
		tmp[1] = readByte();
		tmp[2] = readByte();
		tmp[3] = readByte();
		
		if (tmp[0] == parseInt("50",16) && 
            tmp[1] == parseInt("4b",16) && 
            tmp[2] == parseInt("07",16) && 
            tmp[3] == parseInt("08",16))
        {
            crc = readByte();
            crc |= (readByte()<<8);
            crc |= (readByte()<<16);
            crc |= (readByte()<<24);
		} else {
			crc = tmp[0] | (tmp[1]<<8) | (tmp[2]<<16) | (tmp[3]<<24);
		}
		
		compSize = readByte();
		compSize |= (readByte()<<8);
		compSize |= (readByte()<<16);
		compSize |= (readByte()<<24);
		
		size = readByte();
		size |= (readByte()<<8);
		size |= (readByte()<<16);
		size |= (readByte()<<24);
		
		if (debug)
			alert("CRC:");
	}

	if (modeZIP)
		nextFile();
	
	tmp[0] = readByte();
	if (tmp[0] != 8) {
		if (debug)
			alert("Unknown compression method!");
        return 0;	
	}
	
	gpflags = readByte();
	if (debug){
		if ((gpflags & ~(parseInt("1f",16))))
			alert("Unknown flags set!");
	}
	
	readByte();
	readByte();
	readByte();
	readByte();
	
	readByte();
	os = readByte();
	
	if ((gpflags & 4)){
		tmp[0] = readByte();
		tmp[2] = readByte();
		len = tmp[0] + 256*tmp[1];
		if (debug)
			alert("Extra field size: "+len);
		for (i=0;i<len;i++)
			readByte();
	}
	
	if ((gpflags & 8)){
		i=0;
		nameBuf=[];
		while (c=readByte()){
			if(c == "7" || c == ":")
				i=0;
			if (i<NAMEMAX-1)
				nameBuf[i++] = c;
		}
		//nameBuf[i] = "\0";
		if (debug)
			alert("original file name: "+nameBuf);
	}
		
	if ((gpflags & 16)){
		while (c=readByte()){
			//FILE COMMENT
		}
	}
	
	if ((gpflags & 2)){
		readByte();
		readByte();
	}
	
	DeflateLoop();
	
	crc = readByte();
	crc |= (readByte()<<8);
	crc |= (readByte()<<16);
	crc |= (readByte()<<24);
	
	size = readByte();
	size |= (readByte()<<8);
	size |= (readByte()<<16);
	size |= (readByte()<<24);
	
	if (modeZIP)
		nextFile();
	
};

};

/**
*  Base64 encoding / decoding
*  @see <a href="http://www.webtoolkit.info/">http://www.webtoolkit.info/</A>
*/
JXG.Util.Base64 = {

    // private property
    _keyStr : "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",

    // public method for encoding
    encode : function (input) {
        var output = [],
            chr1, chr2, chr3, enc1, enc2, enc3, enc4,
            i = 0;

        input = JXG.Util.Base64._utf8_encode(input);

        while (i < input.length) {

            chr1 = input.charCodeAt(i++);
            chr2 = input.charCodeAt(i++);
            chr3 = input.charCodeAt(i++);

            enc1 = chr1 >> 2;
            enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
            enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
            enc4 = chr3 & 63;

            if (isNaN(chr2)) {
                enc3 = enc4 = 64;
            } else if (isNaN(chr3)) {
                enc4 = 64;
            }

            output.push([this._keyStr.charAt(enc1),
                         this._keyStr.charAt(enc2),
                         this._keyStr.charAt(enc3),
                         this._keyStr.charAt(enc4)].join(''));
        }

        return output.join('');
    },

    // public method for decoding
    decode : function (input, utf8) {
        var output = [],
            chr1, chr2, chr3,
            enc1, enc2, enc3, enc4,
            i = 0;

        input = input.replace(/[^A-Za-z0-9\+\/\=]/g, "");

        while (i < input.length) {

            enc1 = this._keyStr.indexOf(input.charAt(i++));
            enc2 = this._keyStr.indexOf(input.charAt(i++));
            enc3 = this._keyStr.indexOf(input.charAt(i++));
            enc4 = this._keyStr.indexOf(input.charAt(i++));

            chr1 = (enc1 << 2) | (enc2 >> 4);
            chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
            chr3 = ((enc3 & 3) << 6) | enc4;

            output.push(String.fromCharCode(chr1));

            if (enc3 != 64) {
                output.push(String.fromCharCode(chr2));
            }
            if (enc4 != 64) {
                output.push(String.fromCharCode(chr3));
            }
        }
        
        output = output.join(''); 
        
        if (utf8) {
            output = JXG.Util.Base64._utf8_decode(output);
        }
        return output;

    },

    // private method for UTF-8 encoding
    _utf8_encode : function (string) {
        string = string.replace(/\r\n/g,"\n");
        var utftext = "";

        for (var n = 0; n < string.length; n++) {

            var c = string.charCodeAt(n);

            if (c < 128) {
                utftext += String.fromCharCode(c);
            }
            else if((c > 127) && (c < 2048)) {
                utftext += String.fromCharCode((c >> 6) | 192);
                utftext += String.fromCharCode((c & 63) | 128);
            }
            else {
                utftext += String.fromCharCode((c >> 12) | 224);
                utftext += String.fromCharCode(((c >> 6) & 63) | 128);
                utftext += String.fromCharCode((c & 63) | 128);
            }

        }

        return utftext;
    },

    // private method for UTF-8 decoding
    _utf8_decode : function (utftext) {
        var string = [],
            i = 0,
            c = 0, c2 = 0, c3 = 0;

        while ( i < utftext.length ) {
            c = utftext.charCodeAt(i);
            if (c < 128) {
                string.push(String.fromCharCode(c));
                i++;
            }
            else if((c > 191) && (c < 224)) {
                c2 = utftext.charCodeAt(i+1);
                string.push(String.fromCharCode(((c & 31) << 6) | (c2 & 63)));
                i += 2;
            }
            else {
                c2 = utftext.charCodeAt(i+1);
                c3 = utftext.charCodeAt(i+2);
                string.push(String.fromCharCode(((c & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63)));
                i += 3;
            }
        }
        return string.join('');
    },
    
    _destrip: function (stripped, wrap){
        var lines = [], lineno, i,
            destripped = [];
        
        if (wrap==null) 
            wrap = 76;
            
        stripped.replace(/ /g, "");
        lineno = stripped.length / wrap;
        for (i = 0; i < lineno; i++)
            lines[i]=stripped.substr(i * wrap, wrap);
        if (lineno != stripped.length / wrap)
            lines[lines.length]=stripped.substr(lineno * wrap, stripped.length-(lineno * wrap));
            
        for (i = 0; i < lines.length; i++)
            destripped.push(lines[i]);
        return destripped.join('\n');
    },
    
    decodeAsArray: function (input){
        var dec = this.decode(input),
            ar = [], i;
        for (i=0;i<dec.length;i++){
            ar[i]=dec.charCodeAt(i);
        }
        return ar;
    },
    
    decodeGEONExT : function (input) {
        return decodeAsArray(destrip(input),false);
    }
};

/**
 * @private
 */
JXG.Util.asciiCharCodeAt = function(str,i){
	var c = str.charCodeAt(i);
	if (c>255){
    	switch (c) {
			case 8364: c=128;
	    	break;
	    	case 8218: c=130;
	    	break;
	    	case 402: c=131;
	    	break;
	    	case 8222: c=132;
	    	break;
	    	case 8230: c=133;
	    	break;
	    	case 8224: c=134;
	    	break;
	    	case 8225: c=135;
	    	break;
	    	case 710: c=136;
	    	break;
	    	case 8240: c=137;
	    	break;
	    	case 352: c=138;
	    	break;
	    	case 8249: c=139;
	    	break;
	    	case 338: c=140;
	    	break;
	    	case 381: c=142;
	    	break;
	    	case 8216: c=145;
	    	break;
	    	case 8217: c=146;
	    	break;
	    	case 8220: c=147;
	    	break;
	    	case 8221: c=148;
	    	break;
	    	case 8226: c=149;
	    	break;
	    	case 8211: c=150;
	    	break;
	    	case 8212: c=151;
	    	break;
	    	case 732: c=152;
	    	break;
	    	case 8482: c=153;
	    	break;
	    	case 353: c=154;
	    	break;
	    	case 8250: c=155;
	    	break;
	    	case 339: c=156;
	    	break;
	    	case 382: c=158;
	    	break;
	    	case 376: c=159;
	    	break;
	    	default:
	    	break;
	    }
	}
	return c;
};

/**
 * Decoding string into utf-8
 * @param {String} string to decode
 * @return {String} utf8 decoded string
 */
JXG.Util.utf8Decode = function(utftext) {
  var string = [];
  var i = 0;
  var c = 0, c1 = 0, c2 = 0;

  while ( i < utftext.length ) {
    c = utftext.charCodeAt(i);

    if (c < 128) {
      string.push(String.fromCharCode(c));
      i++;
    } else if((c > 191) && (c < 224)) {
      c2 = utftext.charCodeAt(i+1);
      string.push(String.fromCharCode(((c & 31) << 6) | (c2 & 63)));
      i += 2;
    } else {
      c2 = utftext.charCodeAt(i+1);
      c3 = utftext.charCodeAt(i+2);
      string.push(String.fromCharCode(((c & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63)));
      i += 3;
    }
  };
  return string.join('');
};

// Added to exports for Cocos2d
module.exports = JXG;

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/libs/JXGUtil.js


__jah__.resources["/libs/cocos2d/libs/Plist.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

/** @ignore
 * XML Node types
 */
var ELEMENT_NODE                = 1
  , ATTRIBUTE_NODE              = 2
  , TEXT_NODE                   = 3
  , CDATA_SECTION_NODE          = 4
  , ENTITY_REFERENCE_NODE       = 5
  , ENTITY_NODE                 = 6
  , PROCESSING_INSTRUCTION_NODE = 7
  , COMMENT_NODE                = 8
  , DOCUMENT_NODE               = 9
  , DOCUMENT_TYPE_NODE          = 10
  , DOCUMENT_FRAGMENT_NODE      = 11
  , NOTATION_NODE               = 12

/**
 * @class
 * An object representation of an XML Property List file
 *
 * @opt {String} [file] The path to a .plist file
 * @opt {String} [data] The contents of a .plist file
 */
function Plist (opts) {
    var file = opts['file'],
        data = opts['data']

    if (file && !data) {
        data = resource(file)
    }


    var parser = new DOMParser(),
        doc = parser.parseFromString(data, 'text/xml'),
        plist = doc.documentElement

    if (plist.tagName != 'plist') {
        throw "Not a plist file"
    }


    // Get first real node
    var node = null
    for (var i = 0, len = plist.childNodes.length; i < len; i++) {
        node = plist.childNodes[i]
        if (node.nodeType == ELEMENT_NODE) {
            break
        }
    }

    this.data = this._parseNode(node)
}

Plist.inherit(Object, /** @lends Plist# */ {
    /**
     * The unserialized data inside the Plist file
     * @type Object
     */
    data: null,

    /**
     * @private
     * Parses an XML node inside the Plist file
     * @returns {Object/Array/String/Integer/Float} A JS representation of the node value
     */
    _parseNode: function(node) {
        var data = null
        switch(node.tagName) {
        case 'dict':
            data = this._parseDict(node);
            break
        case 'array':
            data = this._parseArray(node);
            break
        case 'string':
            // FIXME - This needs to handle Firefox's 4KB nodeValue limit
            data = node.firstChild.nodeValue
            break
        case 'false':
            data = false
            break
        case 'true':
            data = true
            break
        case 'real':
            data = parseFloat(node.firstChild.nodeValue)
            break
        case 'integer':
            data = parseInt(node.firstChild.nodeValue, 10)
            break
        }

        return data
    },

    /**
     * @private
     * Parses a <dict> node in a plist file
     *
     * @param {XMLElement}
     * @returns {Object} A simple key/value JS Object representing the <dict>
     */
    _parseDict: function(node) {
        var data = {}

        var key = null
        for (var i = 0, len = node.childNodes.length; i < len; i++) {
            var child = node.childNodes[i]
            if (child.nodeType != ELEMENT_NODE) {
                continue
            }

            // Grab the key, next noe should be the value
            if (child.tagName == 'key') {
                key = child.firstChild.nodeValue
            } else {
                // Parse the value node
                data[key] = this._parseNode(child)
            }
        }


        return data
    },

    /**
     * @private
     * Parses an <array> node in a plist file
     *
     * @param {XMLElement}
     * @returns {Array} A simple JS Array representing the <array>
     */
    _parseArray: function(node) {
        var data = []

        for (var i = 0, len = node.childNodes.length; i < len; i++) {
            var child = node.childNodes[i]
            if (child.nodeType != ELEMENT_NODE) {
                continue
            }

            data.push(this._parseNode(child))
        }

        return data
    }
})

exports.Plist = Plist

// vim:et:st=4:fdm=marker:fdl=0:fdc=1

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/libs/Plist.js


__jah__.resources["/libs/cocos2d/libs/qunit.js"] = {data: function (exports, require, module, __filename, __dirname) {
/*
 * QUnit - A JavaScript Unit Testing Framework
 * 
 * http://docs.jquery.com/QUnit
 *
 * Copyright (c) 2011 John Resig, Jörn Zaefferer
 * Dual licensed under the MIT (MIT-LICENSE.txt)
 * or GPL (GPL-LICENSE.txt) licenses.
 */

(function(window) {

var defined = {
	setTimeout: typeof window.setTimeout !== "undefined",
	sessionStorage: (function() {
		try {
			return !!sessionStorage.getItem;
		} catch(e){
			return false;
		}
  })()
}

var testId = 0;

var Test = function(name, testName, expected, testEnvironmentArg, async, callback) {
	this.name = name;
	this.testName = testName;
	this.expected = expected;
	this.testEnvironmentArg = testEnvironmentArg;
	this.async = async;
	this.callback = callback;
	this.assertions = [];
};
Test.prototype = {
	init: function() {
		var tests = id("qunit-tests");
		if (tests) {
			var b = document.createElement("strong");
				b.innerHTML = "Running " + this.name;
			var li = document.createElement("li");
				li.appendChild( b );
				li.id = this.id = "test-output" + testId++;
			tests.appendChild( li );
		}
	},
	setup: function() {
		if (this.module != config.previousModule) {
			if ( config.previousModule ) {
				QUnit.moduleDone( {
					name: config.previousModule,
					failed: config.moduleStats.bad,
					passed: config.moduleStats.all - config.moduleStats.bad,
					total: config.moduleStats.all
				} );
			}
			config.previousModule = this.module;
			config.moduleStats = { all: 0, bad: 0 };
			QUnit.moduleStart( {
				name: this.module
			} );
		}

		config.current = this;
		this.testEnvironment = extend({
			setup: function() {},
			teardown: function() {}
		}, this.moduleTestEnvironment);
		if (this.testEnvironmentArg) {
			extend(this.testEnvironment, this.testEnvironmentArg);
		}

		QUnit.testStart( {
			name: this.testName
		} );

		// allow utility functions to access the current test environment
		// TODO why??
		QUnit.current_testEnvironment = this.testEnvironment;
		
		try {
			if ( !config.pollution ) {
				saveGlobal();
			}

			this.testEnvironment.setup.call(this.testEnvironment);
		} catch(e) {
			QUnit.ok( false, "Setup failed on " + this.testName + ": " + e.message );
		}
	},
	run: function() {
		if ( this.async ) {
			QUnit.stop();
		}

		if ( config.notrycatch ) {
			this.callback.call(this.testEnvironment);
			return;
		}
		try {
			this.callback.call(this.testEnvironment);
		} catch(e) {
			fail("Test " + this.testName + " died, exception and test follows", e, this.callback);
			QUnit.ok( false, "Died on test #" + (this.assertions.length + 1) + ": " + e.message + " - " + QUnit.jsDump.parse(e) );
			// else next test will carry the responsibility
			saveGlobal();

			// Restart the tests if they're blocking
			if ( config.blocking ) {
				start();
			}
		}
	},
	teardown: function() {
		try {
			checkPollution();
			this.testEnvironment.teardown.call(this.testEnvironment);
		} catch(e) {
			QUnit.ok( false, "Teardown failed on " + this.testName + ": " + e.message );
		}
	},
	finish: function() {
		if ( this.expected && this.expected != this.assertions.length ) {
			QUnit.ok( false, "Expected " + this.expected + " assertions, but " + this.assertions.length + " were run" );
		}
		
		var good = 0, bad = 0,
			tests = id("qunit-tests");

		config.stats.all += this.assertions.length;
		config.moduleStats.all += this.assertions.length;

		if ( tests ) {
			var ol  = document.createElement("ol");

			for ( var i = 0; i < this.assertions.length; i++ ) {
				var assertion = this.assertions[i];

				var li = document.createElement("li");
				li.className = assertion.result ? "pass" : "fail";
				li.innerHTML = assertion.message || (assertion.result ? "okay" : "failed");
				ol.appendChild( li );

				if ( assertion.result ) {
					good++;
				} else {
					bad++;
					config.stats.bad++;
					config.moduleStats.bad++;
				}
			}

			// store result when possible
			defined.sessionStorage && sessionStorage.setItem("qunit-" + this.testName, bad);

			if (bad == 0) {
				ol.style.display = "none";
			}

			var b = document.createElement("strong");
			b.innerHTML = this.name + " <b class='counts'>(<b class='failed'>" + bad + "</b>, <b class='passed'>" + good + "</b>, " + this.assertions.length + ")</b>";
			
			addEvent(b, "click", function() {
				var next = b.nextSibling, display = next.style.display;
				next.style.display = display === "none" ? "block" : "none";
			});
			
			addEvent(b, "dblclick", function(e) {
				var target = e && e.target ? e.target : window.event.srcElement;
				if ( target.nodeName.toLowerCase() == "span" || target.nodeName.toLowerCase() == "b" ) {
					target = target.parentNode;
				}
				if ( window.location && target.nodeName.toLowerCase() === "strong" ) {
					window.location.search = "?" + encodeURIComponent(getText([target]).replace(/\(.+\)$/, "").replace(/(^\s*|\s*$)/g, ""));
				}
			});

			var li = id(this.id);
			li.className = bad ? "fail" : "pass";
			li.style.display = resultDisplayStyle(!bad);
			li.removeChild( li.firstChild );
			li.appendChild( b );
			li.appendChild( ol );

		} else {
			for ( var i = 0; i < this.assertions.length; i++ ) {
				if ( !this.assertions[i].result ) {
					bad++;
					config.stats.bad++;
					config.moduleStats.bad++;
				}
			}
		}

		try {
			QUnit.reset();
		} catch(e) {
			fail("reset() failed, following Test " + this.testName + ", exception and reset fn follows", e, QUnit.reset);
		}

		QUnit.testDone( {
			name: this.testName,
			failed: bad,
			passed: this.assertions.length - bad,
			total: this.assertions.length
		} );
	},
	
	queue: function() {
		var test = this;
		synchronize(function() {
			test.init();
		});
		function run() {
			// each of these can by async
			synchronize(function() {
				test.setup();
			});
			synchronize(function() {
				test.run();
			});
			synchronize(function() {
				test.teardown();
			});
			synchronize(function() {
				test.finish();
			});
		}
		// defer when previous test run passed, if storage is available
		var bad = defined.sessionStorage && +sessionStorage.getItem("qunit-" + this.testName);
		if (bad) {
			run();
		} else {
			synchronize(run);
		};
	}
	
}

var QUnit = {

	// call on start of module test to prepend name to all tests
	module: function(name, testEnvironment) {
		config.currentModule = name;
		config.currentModuleTestEnviroment = testEnvironment;
	},

	asyncTest: function(testName, expected, callback) {
		if ( arguments.length === 2 ) {
			callback = expected;
			expected = 0;
		}

		QUnit.test(testName, expected, callback, true);
	},
	
	test: function(testName, expected, callback, async) {
		var name = '<span class="test-name">' + testName + '</span>', testEnvironmentArg;

		if ( arguments.length === 2 ) {
			callback = expected;
			expected = null;
		}
		// is 2nd argument a testEnvironment?
		if ( expected && typeof expected === 'object') {
			testEnvironmentArg =  expected;
			expected = null;
		}

		if ( config.currentModule ) {
			name = '<span class="module-name">' + config.currentModule + "</span>: " + name;
		}

		if ( !validTest(config.currentModule + ": " + testName) ) {
			return;
		}
		
		var test = new Test(name, testName, expected, testEnvironmentArg, async, callback);
		test.module = config.currentModule;
		test.moduleTestEnvironment = config.currentModuleTestEnviroment;
		test.queue();
	},
	
	/**
	 * Specify the number of expected assertions to gurantee that failed test (no assertions are run at all) don't slip through.
	 */
	expect: function(asserts) {
		config.current.expected = asserts;
	},

	/**
	 * Asserts true.
	 * @example ok( "asdfasdf".length > 5, "There must be at least 5 chars" );
	 */
	ok: function(a, msg) {
		a = !!a;
		var details = {
			result: a,
			message: msg
		};
		msg = escapeHtml(msg);
		QUnit.log(details);
		config.current.assertions.push({
			result: a,
			message: msg
		});
	},

	/**
	 * Checks that the first two arguments are equal, with an optional message.
	 * Prints out both actual and expected values.
	 *
	 * Prefered to ok( actual == expected, message )
	 *
	 * @example equal( format("Received {0} bytes.", 2), "Received 2 bytes." );
	 *
	 * @param Object actual
	 * @param Object expected
	 * @param String message (optional)
	 */
	equal: function(actual, expected, message) {
		QUnit.push(expected == actual, actual, expected, message);
	},

	notEqual: function(actual, expected, message) {
		QUnit.push(expected != actual, actual, expected, message);
	},
	
	deepEqual: function(actual, expected, message) {
		QUnit.push(QUnit.equiv(actual, expected), actual, expected, message);
	},

	notDeepEqual: function(actual, expected, message) {
		QUnit.push(!QUnit.equiv(actual, expected), actual, expected, message);
	},

	strictEqual: function(actual, expected, message) {
		QUnit.push(expected === actual, actual, expected, message);
	},

	notStrictEqual: function(actual, expected, message) {
		QUnit.push(expected !== actual, actual, expected, message);
	},

	raises: function(block, expected, message) {
		var actual, ok = false;
	
		if (typeof expected === 'string') {
			message = expected;
			expected = null;
		}
	
		try {
			block();
		} catch (e) {
			actual = e;
		}
	
		if (actual) {
			// we don't want to validate thrown error
			if (!expected) {
				ok = true;
			// expected is a regexp	
			} else if (QUnit.objectType(expected) === "regexp") {
				ok = expected.test(actual);
			// expected is a constructor	
			} else if (actual instanceof expected) {
				ok = true;
			// expected is a validation function which returns true is validation passed	
			} else if (expected.call({}, actual) === true) {
				ok = true;
			}
		}
			
		QUnit.ok(ok, message);
	},

	start: function() {
		config.semaphore--;
		if (config.semaphore > 0) {
			// don't start until equal number of stop-calls
			return;
		}
		if (config.semaphore < 0) {
			// ignore if start is called more often then stop
			config.semaphore = 0;
		}
		// A slight delay, to avoid any current callbacks
		if ( defined.setTimeout ) {
			window.setTimeout(function() {
				if ( config.timeout ) {
					clearTimeout(config.timeout);
				}

				config.blocking = false;
				process();
			}, 13);
		} else {
			config.blocking = false;
			process();
		}
	},
	
	stop: function(timeout) {
		config.semaphore++;
		config.blocking = true;

		if ( timeout && defined.setTimeout ) {
			clearTimeout(config.timeout);
			config.timeout = window.setTimeout(function() {
				QUnit.ok( false, "Test timed out" );
				QUnit.start();
			}, timeout);
		}
	}

};

// Backwards compatibility, deprecated
QUnit.equals = QUnit.equal;
QUnit.same = QUnit.deepEqual;

// Maintain internal state
var config = {
	// The queue of tests to run
	queue: [],

	// block until document ready
	blocking: true
};

// Load paramaters
(function() {
	var location = window.location || { search: "", protocol: "file:" },
		GETParams = location.search.slice(1).split('&');

	for ( var i = 0; i < GETParams.length; i++ ) {
		GETParams[i] = decodeURIComponent( GETParams[i] );
		if ( GETParams[i] === "noglobals" ) {
			GETParams.splice( i, 1 );
			i--;
			config.noglobals = true;
		} else if ( GETParams[i] === "notrycatch" ) {
			GETParams.splice( i, 1 );
			i--;
			config.notrycatch = true;
		} else if ( GETParams[i].search('=') > -1 ) {
			GETParams.splice( i, 1 );
			i--;
		}
	}
	
	// restrict modules/tests by get parameters
	config.filters = GETParams;
	
	// Figure out if we're running the tests from a server or not
	QUnit.isLocal = !!(location.protocol === 'file:');
})();

// Expose the API as global variables, unless an 'exports'
// object exists, in that case we assume we're in CommonJS
if ( typeof exports === "undefined" || typeof require === "undefined" ) {
	extend(window, QUnit);
	window.QUnit = QUnit;
} else {
	extend(exports, QUnit);
	exports.QUnit = QUnit;
}

// define these after exposing globals to keep them in these QUnit namespace only
extend(QUnit, {
	config: config,

	// Initialize the configuration options
	init: function() {
		extend(config, {
			stats: { all: 0, bad: 0 },
			moduleStats: { all: 0, bad: 0 },
			started: +new Date,
			updateRate: 1000,
			blocking: false,
			autostart: true,
			autorun: false,
			filters: [],
			queue: [],
			semaphore: 0
		});

		var tests = id("qunit-tests"),
			banner = id("qunit-banner"),
			result = id("qunit-testresult");

		if ( tests ) {
			tests.innerHTML = "";
		}

		if ( banner ) {
			banner.className = "";
		}

		if ( result ) {
			result.parentNode.removeChild( result );
		}
	},
	
	/**
	 * Resets the test setup. Useful for tests that modify the DOM.
	 * 
	 * If jQuery is available, uses jQuery's html(), otherwise just innerHTML.
	 */
	reset: function() {
		if ( window.jQuery ) {
			jQuery( "#main, #qunit-fixture" ).html( config.fixture );
		} else {
			var main = id( 'main' ) || id( 'qunit-fixture' );
			if ( main ) {
				main.innerHTML = config.fixture;
			}
		}
	},
	
	/**
	 * Trigger an event on an element.
	 *
	 * @example triggerEvent( document.body, "click" );
	 *
	 * @param DOMElement elem
	 * @param String type
	 */
	triggerEvent: function( elem, type, event ) {
		if ( document.createEvent ) {
			event = document.createEvent("MouseEvents");
			event.initMouseEvent(type, true, true, elem.ownerDocument.defaultView,
				0, 0, 0, 0, 0, false, false, false, false, 0, null);
			elem.dispatchEvent( event );

		} else if ( elem.fireEvent ) {
			elem.fireEvent("on"+type);
		}
	},
	
	// Safe object type checking
	is: function( type, obj ) {
		return QUnit.objectType( obj ) == type;
	},
	
	objectType: function( obj ) {
		if (typeof obj === "undefined") {
				return "undefined";

		// consider: typeof null === object
		}
		if (obj === null) {
				return "null";
		}

		var type = Object.prototype.toString.call( obj )
			.match(/^\[object\s(.*)\]$/)[1] || '';

		switch (type) {
				case 'Number':
						if (isNaN(obj)) {
								return "nan";
						} else {
								return "number";
						}
				case 'String':
				case 'Boolean':
				case 'Array':
				case 'Date':
				case 'RegExp':
				case 'Function':
						return type.toLowerCase();
		}
		if (typeof obj === "object") {
				return "object";
		}
		return undefined;
	},
	
	push: function(result, actual, expected, message) {
		var details = {
			result: result,
			message: message,
			actual: actual,
			expected: expected
		};
		
		message = escapeHtml(message) || (result ? "okay" : "failed");
		message = '<span class="test-message">' + message + "</span>";
		expected = escapeHtml(QUnit.jsDump.parse(expected));
		actual = escapeHtml(QUnit.jsDump.parse(actual));
		var output = message + '<table><tr class="test-expected"><th>Expected: </th><td><pre>' + expected + '</pre></td></tr>';
		if (actual != expected) {
			output += '<tr class="test-actual"><th>Result: </th><td><pre>' + actual + '</pre></td></tr>';
			output += '<tr class="test-diff"><th>Diff: </th><td><pre>' + QUnit.diff(expected, actual) +'</pre></td></tr>';
		}
		if (!result) {
			var source = sourceFromStacktrace();
			if (source) {
				details.source = source;
				output += '<tr class="test-source"><th>Source: </th><td><pre>' + source +'</pre></td></tr>';
			}
		}
		output += "</table>";
		
		QUnit.log(details);
		
		config.current.assertions.push({
			result: !!result,
			message: output
		});
	},
	
	// Logging callbacks; all receive a single argument with the listed properties
	// run test/logs.html for any related changes
	begin: function() {},
	// done: { failed, passed, total, runtime }
	done: function() {},
	// log: { result, actual, expected, message }
	log: function() {},
	// testStart: { name }
	testStart: function() {},
	// testDone: { name, failed, passed, total }
	testDone: function() {},
	// moduleStart: { name }
	moduleStart: function() {},
	// moduleDone: { name, failed, passed, total }
	moduleDone: function() {}
});

if ( typeof document === "undefined" || document.readyState === "complete" ) {
	config.autorun = true;
}

addEvent(window, "load", function() {
	QUnit.begin({});
	
	// Initialize the config, saving the execution queue
	var oldconfig = extend({}, config);
	QUnit.init();
	extend(config, oldconfig);

	config.blocking = false;

	var userAgent = id("qunit-userAgent");
	if ( userAgent ) {
		userAgent.innerHTML = navigator.userAgent;
	}
	var banner = id("qunit-header");
	if ( banner ) {
		var paramsIndex = location.href.lastIndexOf(location.search);
		if ( paramsIndex > -1 ) {
			var mainPageLocation = location.href.slice(0, paramsIndex);
			if ( mainPageLocation == location.href ) {
				banner.innerHTML = '<a href=""> ' + banner.innerHTML + '</a> ';
			} else {
				var testName = decodeURIComponent(location.search.slice(1));
				banner.innerHTML = '<a href="' + mainPageLocation + '">' + banner.innerHTML + '</a> &#8250; <a href="">' + testName + '</a>';
			}
		}
	}
	
	var toolbar = id("qunit-testrunner-toolbar");
	if ( toolbar ) {
		var filter = document.createElement("input");
		filter.type = "checkbox";
		filter.id = "qunit-filter-pass";
		addEvent( filter, "click", function() {
			var li = document.getElementsByTagName("li");
			for ( var i = 0; i < li.length; i++ ) {
				if ( li[i].className.indexOf("pass") > -1 ) {
					li[i].style.display = filter.checked ? "none" : "";
				}
			}
			if ( defined.sessionStorage ) {
				sessionStorage.setItem("qunit-filter-passed-tests", filter.checked ? "true" : "");
			}
		});
		if ( defined.sessionStorage && sessionStorage.getItem("qunit-filter-passed-tests") ) {
			filter.checked = true;
		}
		toolbar.appendChild( filter );

		var label = document.createElement("label");
		label.setAttribute("for", "qunit-filter-pass");
		label.innerHTML = "Hide passed tests";
		toolbar.appendChild( label );
	}

	var main = id('main') || id('qunit-fixture');
	if ( main ) {
		config.fixture = main.innerHTML;
	}

	if (config.autostart) {
		QUnit.start();
	}
});

function done() {
	config.autorun = true;

	// Log the last module results
	if ( config.currentModule ) {
		QUnit.moduleDone( {
			name: config.currentModule,
			failed: config.moduleStats.bad,
			passed: config.moduleStats.all - config.moduleStats.bad,
			total: config.moduleStats.all
		} );
	}

	var banner = id("qunit-banner"),
		tests = id("qunit-tests"),
		runtime = +new Date - config.started,
		passed = config.stats.all - config.stats.bad,
		html = [
			'Tests completed in ',
			runtime,
			' milliseconds.<br/>',
			'<span class="passed">',
			passed,
			'</span> tests of <span class="total">',
			config.stats.all,
			'</span> passed, <span class="failed">',
			config.stats.bad,
			'</span> failed.'
		].join('');

	if ( banner ) {
		banner.className = (config.stats.bad ? "qunit-fail" : "qunit-pass");
	}

	if ( tests ) {	
		var result = id("qunit-testresult");

		if ( !result ) {
			result = document.createElement("p");
			result.id = "qunit-testresult";
			result.className = "result";
			tests.parentNode.insertBefore( result, tests.nextSibling );
		}

		result.innerHTML = html;
	}

	QUnit.done( {
		failed: config.stats.bad,
		passed: passed, 
		total: config.stats.all,
		runtime: runtime
	} );
}

function validTest( name ) {
	var i = config.filters.length,
		run = false;

	if ( !i ) {
		return true;
	}
	
	while ( i-- ) {
		var filter = config.filters[i],
			not = filter.charAt(0) == '!';

		if ( not ) {
			filter = filter.slice(1);
		}

		if ( name.indexOf(filter) !== -1 ) {
			return !not;
		}

		if ( not ) {
			run = true;
		}
	}

	return run;
}

// so far supports only Firefox, Chrome and Opera (buggy)
// could be extended in the future to use something like https://github.com/csnover/TraceKit
function sourceFromStacktrace() {
	try {
		throw new Error();
	} catch ( e ) {
		if (e.stacktrace) {
			// Opera
			return e.stacktrace.split("\n")[6];
		} else if (e.stack) {
			// Firefox, Chrome
			return e.stack.split("\n")[4];
		}
	}
}

function resultDisplayStyle(passed) {
	return passed && id("qunit-filter-pass") && id("qunit-filter-pass").checked ? 'none' : '';
}

function escapeHtml(s) {
	if (!s) {
		return "";
	}
	s = s + "";
	return s.replace(/[\&"<>\\]/g, function(s) {
		switch(s) {
			case "&": return "&amp;";
			case "\\": return "\\\\";
			case '"': return '\"';
			case "<": return "&lt;";
			case ">": return "&gt;";
			default: return s;
		}
	});
}

function synchronize( callback ) {
	config.queue.push( callback );

	if ( config.autorun && !config.blocking ) {
		process();
	}
}

function process() {
	var start = (new Date()).getTime();

	while ( config.queue.length && !config.blocking ) {
		if ( config.updateRate <= 0 || (((new Date()).getTime() - start) < config.updateRate) ) {
			config.queue.shift()();
		} else {
			window.setTimeout( process, 13 );
			break;
		}
	}
  if (!config.blocking && !config.queue.length) {
    done();
  }
}

function saveGlobal() {
	config.pollution = [];
	
	if ( config.noglobals ) {
		for ( var key in window ) {
			config.pollution.push( key );
		}
	}
}

function checkPollution( name ) {
	var old = config.pollution;
	saveGlobal();
	
	var newGlobals = diff( old, config.pollution );
	if ( newGlobals.length > 0 ) {
		ok( false, "Introduced global variable(s): " + newGlobals.join(", ") );
		config.current.expected++;
	}

	var deletedGlobals = diff( config.pollution, old );
	if ( deletedGlobals.length > 0 ) {
		ok( false, "Deleted global variable(s): " + deletedGlobals.join(", ") );
		config.current.expected++;
	}
}

// returns a new Array with the elements that are in a but not in b
function diff( a, b ) {
	var result = a.slice();
	for ( var i = 0; i < result.length; i++ ) {
		for ( var j = 0; j < b.length; j++ ) {
			if ( result[i] === b[j] ) {
				result.splice(i, 1);
				i--;
				break;
			}
		}
	}
	return result;
}

function fail(message, exception, callback) {
	if ( typeof console !== "undefined" && console.error && console.warn ) {
		console.error(message);
		console.error(exception);
		console.warn(callback.toString());

	} else if ( window.opera && opera.postError ) {
		opera.postError(message, exception, callback.toString);
	}
}

function extend(a, b) {
	for ( var prop in b ) {
		a[prop] = b[prop];
	}

	return a;
}

function addEvent(elem, type, fn) {
	if ( elem.addEventListener ) {
		elem.addEventListener( type, fn, false );
	} else if ( elem.attachEvent ) {
		elem.attachEvent( "on" + type, fn );
	} else {
		fn();
	}
}

function id(name) {
	return !!(typeof document !== "undefined" && document && document.getElementById) &&
		document.getElementById( name );
}

// Test for equality any JavaScript type.
// Discussions and reference: http://philrathe.com/articles/equiv
// Test suites: http://philrathe.com/tests/equiv
// Author: Philippe Rathé <prathe@gmail.com>
QUnit.equiv = function () {

    var innerEquiv; // the real equiv function
    var callers = []; // stack to decide between skip/abort functions
    var parents = []; // stack to avoiding loops from circular referencing

    // Call the o related callback with the given arguments.
    function bindCallbacks(o, callbacks, args) {
        var prop = QUnit.objectType(o);
        if (prop) {
            if (QUnit.objectType(callbacks[prop]) === "function") {
                return callbacks[prop].apply(callbacks, args);
            } else {
                return callbacks[prop]; // or undefined
            }
        }
    }
    
    var callbacks = function () {

        // for string, boolean, number and null
        function useStrictEquality(b, a) {
            if (b instanceof a.constructor || a instanceof b.constructor) {
                // to catch short annotaion VS 'new' annotation of a declaration
                // e.g. var i = 1;
                //      var j = new Number(1);
                return a == b;
            } else {
                return a === b;
            }
        }

        return {
            "string": useStrictEquality,
            "boolean": useStrictEquality,
            "number": useStrictEquality,
            "null": useStrictEquality,
            "undefined": useStrictEquality,

            "nan": function (b) {
                return isNaN(b);
            },

            "date": function (b, a) {
                return QUnit.objectType(b) === "date" && a.valueOf() === b.valueOf();
            },

            "regexp": function (b, a) {
                return QUnit.objectType(b) === "regexp" &&
                    a.source === b.source && // the regex itself
                    a.global === b.global && // and its modifers (gmi) ...
                    a.ignoreCase === b.ignoreCase &&
                    a.multiline === b.multiline;
            },

            // - skip when the property is a method of an instance (OOP)
            // - abort otherwise,
            //   initial === would have catch identical references anyway
            "function": function () {
                var caller = callers[callers.length - 1];
                return caller !== Object &&
                        typeof caller !== "undefined";
            },

            "array": function (b, a) {
                var i, j, loop;
                var len;

                // b could be an object literal here
                if ( ! (QUnit.objectType(b) === "array")) {
                    return false;
                }   
                
                len = a.length;
                if (len !== b.length) { // safe and faster
                    return false;
                }
                
                //track reference to avoid circular references
                parents.push(a);
                for (i = 0; i < len; i++) {
                    loop = false;
                    for(j=0;j<parents.length;j++){
                        if(parents[j] === a[i]){
                            loop = true;//dont rewalk array
                        }
                    }
                    if (!loop && ! innerEquiv(a[i], b[i])) {
                        parents.pop();
                        return false;
                    }
                }
                parents.pop();
                return true;
            },

            "object": function (b, a) {
                var i, j, loop;
                var eq = true; // unless we can proove it
                var aProperties = [], bProperties = []; // collection of strings

                // comparing constructors is more strict than using instanceof
                if ( a.constructor !== b.constructor) {
                    return false;
                }

                // stack constructor before traversing properties
                callers.push(a.constructor);
                //track reference to avoid circular references
                parents.push(a);
                
                for (i in a) { // be strict: don't ensures hasOwnProperty and go deep
                    loop = false;
                    for(j=0;j<parents.length;j++){
                        if(parents[j] === a[i])
                            loop = true; //don't go down the same path twice
                    }
                    aProperties.push(i); // collect a's properties

                    if (!loop && ! innerEquiv(a[i], b[i])) {
                        eq = false;
                        break;
                    }
                }

                callers.pop(); // unstack, we are done
                parents.pop();

                for (i in b) {
                    bProperties.push(i); // collect b's properties
                }

                // Ensures identical properties name
                return eq && innerEquiv(aProperties.sort(), bProperties.sort());
            }
        };
    }();

    innerEquiv = function () { // can take multiple arguments
        var args = Array.prototype.slice.apply(arguments);
        if (args.length < 2) {
            return true; // end transition
        }

        return (function (a, b) {
            if (a === b) {
                return true; // catch the most you can
            } else if (a === null || b === null || typeof a === "undefined" || typeof b === "undefined" || QUnit.objectType(a) !== QUnit.objectType(b)) {
                return false; // don't lose time with error prone cases
            } else {
                return bindCallbacks(a, callbacks, [b, a]);
            }

        // apply transition with (1..n) arguments
        })(args[0], args[1]) && arguments.callee.apply(this, args.splice(1, args.length -1));
    };

    return innerEquiv;

}();

/**
 * jsDump
 * Copyright (c) 2008 Ariel Flesler - aflesler(at)gmail(dot)com | http://flesler.blogspot.com
 * Licensed under BSD (http://www.opensource.org/licenses/bsd-license.php)
 * Date: 5/15/2008
 * @projectDescription Advanced and extensible data dumping for Javascript.
 * @version 1.0.0
 * @author Ariel Flesler
 * @link {http://flesler.blogspot.com/2008/05/jsdump-pretty-dump-of-any-javascript.html}
 */
QUnit.jsDump = (function() {
	function quote( str ) {
		return '"' + str.toString().replace(/"/g, '\\"') + '"';
	};
	function literal( o ) {
		return o + '';	
	};
	function join( pre, arr, post ) {
		var s = jsDump.separator(),
			base = jsDump.indent(),
			inner = jsDump.indent(1);
		if ( arr.join )
			arr = arr.join( ',' + s + inner );
		if ( !arr )
			return pre + post;
		return [ pre, inner + arr, base + post ].join(s);
	};
	function array( arr ) {
		var i = arr.length,	ret = Array(i);					
		this.up();
		while ( i-- )
			ret[i] = this.parse( arr[i] );				
		this.down();
		return join( '[', ret, ']' );
	};
	
	var reName = /^function (\w+)/;
	
	var jsDump = {
		parse:function( obj, type ) { //type is used mostly internally, you can fix a (custom)type in advance
			var	parser = this.parsers[ type || this.typeOf(obj) ];
			type = typeof parser;			
			
			return type == 'function' ? parser.call( this, obj ) :
				   type == 'string' ? parser :
				   this.parsers.error;
		},
		typeOf:function( obj ) {
			var type;
			if ( obj === null ) {
				type = "null";
			} else if (typeof obj === "undefined") {
				type = "undefined";
			} else if (QUnit.is("RegExp", obj)) {
				type = "regexp";
			} else if (QUnit.is("Date", obj)) {
				type = "date";
			} else if (QUnit.is("Function", obj)) {
				type = "function";
			} else if (typeof obj.setInterval !== undefined && typeof obj.document !== "undefined" && typeof obj.nodeType === "undefined") {
				type = "window";
			} else if (obj.nodeType === 9) {
				type = "document";
			} else if (obj.nodeType) {
				type = "node";
			} else if (typeof obj === "object" && typeof obj.length === "number" && obj.length >= 0) {
				type = "array";
			} else {
				type = typeof obj;
			}
			return type;
		},
		separator:function() {
			return this.multiline ?	this.HTML ? '<br />' : '\n' : this.HTML ? '&nbsp;' : ' ';
		},
		indent:function( extra ) {// extra can be a number, shortcut for increasing-calling-decreasing
			if ( !this.multiline )
				return '';
			var chr = this.indentChar;
			if ( this.HTML )
				chr = chr.replace(/\t/g,'   ').replace(/ /g,'&nbsp;');
			return Array( this._depth_ + (extra||0) ).join(chr);
		},
		up:function( a ) {
			this._depth_ += a || 1;
		},
		down:function( a ) {
			this._depth_ -= a || 1;
		},
		setParser:function( name, parser ) {
			this.parsers[name] = parser;
		},
		// The next 3 are exposed so you can use them
		quote:quote, 
		literal:literal,
		join:join,
		//
		_depth_: 1,
		// This is the list of parsers, to modify them, use jsDump.setParser
		parsers:{
			window: '[Window]',
			document: '[Document]',
			error:'[ERROR]', //when no parser is found, shouldn't happen
			unknown: '[Unknown]',
			'null':'null',
			undefined:'undefined',
			'function':function( fn ) {
				var ret = 'function',
					name = 'name' in fn ? fn.name : (reName.exec(fn)||[])[1];//functions never have name in IE
				if ( name )
					ret += ' ' + name;
				ret += '(';
				
				ret = [ ret, QUnit.jsDump.parse( fn, 'functionArgs' ), '){'].join('');
				return join( ret, QUnit.jsDump.parse(fn,'functionCode'), '}' );
			},
			array: array,
			nodelist: array,
			arguments: array,
			object:function( map ) {
				var ret = [ ];
				QUnit.jsDump.up();
				for ( var key in map )
					ret.push( QUnit.jsDump.parse(key,'key') + ': ' + QUnit.jsDump.parse(map[key]) );
				QUnit.jsDump.down();
				return join( '{', ret, '}' );
			},
			node:function( node ) {
				var open = QUnit.jsDump.HTML ? '&lt;' : '<',
					close = QUnit.jsDump.HTML ? '&gt;' : '>';
					
				var tag = node.nodeName.toLowerCase(),
					ret = open + tag;
					
				for ( var a in QUnit.jsDump.DOMAttrs ) {
					var val = node[QUnit.jsDump.DOMAttrs[a]];
					if ( val )
						ret += ' ' + a + '=' + QUnit.jsDump.parse( val, 'attribute' );
				}
				return ret + close + open + '/' + tag + close;
			},
			functionArgs:function( fn ) {//function calls it internally, it's the arguments part of the function
				var l = fn.length;
				if ( !l ) return '';				
				
				var args = Array(l);
				while ( l-- )
					args[l] = String.fromCharCode(97+l);//97 is 'a'
				return ' ' + args.join(', ') + ' ';
			},
			key:quote, //object calls it internally, the key part of an item in a map
			functionCode:'[code]', //function calls it internally, it's the content of the function
			attribute:quote, //node calls it internally, it's an html attribute value
			string:quote,
			date:quote,
			regexp:literal, //regex
			number:literal,
			'boolean':literal
		},
		DOMAttrs:{//attributes to dump from nodes, name=>realName
			id:'id',
			name:'name',
			'class':'className'
		},
		HTML:false,//if true, entities are escaped ( <, >, \t, space and \n )
		indentChar:'  ',//indentation unit
		multiline:true //if true, items in a collection, are separated by a \n, else just a space.
	};

	return jsDump;
})();

// from Sizzle.js
function getText( elems ) {
	var ret = "", elem;

	for ( var i = 0; elems[i]; i++ ) {
		elem = elems[i];

		// Get the text from text nodes and CDATA nodes
		if ( elem.nodeType === 3 || elem.nodeType === 4 ) {
			ret += elem.nodeValue;

		// Traverse everything else, except comment nodes
		} else if ( elem.nodeType !== 8 ) {
			ret += getText( elem.childNodes );
		}
	}

	return ret;
};

/*
 * Javascript Diff Algorithm
 *  By John Resig (http://ejohn.org/)
 *  Modified by Chu Alan "sprite"
 *
 * Released under the MIT license.
 *
 * More Info:
 *  http://ejohn.org/projects/javascript-diff-algorithm/
 *  
 * Usage: QUnit.diff(expected, actual)
 * 
 * QUnit.diff("the quick brown fox jumped over", "the quick fox jumps over") == "the  quick <del>brown </del> fox <del>jumped </del><ins>jumps </ins> over"
 */
QUnit.diff = (function() {
	function diff(o, n){
		var ns = new Object();
		var os = new Object();
		
		for (var i = 0; i < n.length; i++) {
			if (ns[n[i]] == null) 
				ns[n[i]] = {
					rows: new Array(),
					o: null
				};
			ns[n[i]].rows.push(i);
		}
		
		for (var i = 0; i < o.length; i++) {
			if (os[o[i]] == null) 
				os[o[i]] = {
					rows: new Array(),
					n: null
				};
			os[o[i]].rows.push(i);
		}
		
		for (var i in ns) {
			if (ns[i].rows.length == 1 && typeof(os[i]) != "undefined" && os[i].rows.length == 1) {
				n[ns[i].rows[0]] = {
					text: n[ns[i].rows[0]],
					row: os[i].rows[0]
				};
				o[os[i].rows[0]] = {
					text: o[os[i].rows[0]],
					row: ns[i].rows[0]
				};
			}
		}
		
		for (var i = 0; i < n.length - 1; i++) {
			if (n[i].text != null && n[i + 1].text == null && n[i].row + 1 < o.length && o[n[i].row + 1].text == null &&
			n[i + 1] == o[n[i].row + 1]) {
				n[i + 1] = {
					text: n[i + 1],
					row: n[i].row + 1
				};
				o[n[i].row + 1] = {
					text: o[n[i].row + 1],
					row: i + 1
				};
			}
		}
		
		for (var i = n.length - 1; i > 0; i--) {
			if (n[i].text != null && n[i - 1].text == null && n[i].row > 0 && o[n[i].row - 1].text == null &&
			n[i - 1] == o[n[i].row - 1]) {
				n[i - 1] = {
					text: n[i - 1],
					row: n[i].row - 1
				};
				o[n[i].row - 1] = {
					text: o[n[i].row - 1],
					row: i - 1
				};
			}
		}
		
		return {
			o: o,
			n: n
		};
	}
	
	return function(o, n){
		o = o.replace(/\s+$/, '');
		n = n.replace(/\s+$/, '');
		var out = diff(o == "" ? [] : o.split(/\s+/), n == "" ? [] : n.split(/\s+/));

		var str = "";
		
		var oSpace = o.match(/\s+/g);
		if (oSpace == null) {
			oSpace = [" "];
		}
		else {
			oSpace.push(" ");
		}
		var nSpace = n.match(/\s+/g);
		if (nSpace == null) {
			nSpace = [" "];
		}
		else {
			nSpace.push(" ");
		}
		
		if (out.n.length == 0) {
			for (var i = 0; i < out.o.length; i++) {
				str += '<del>' + out.o[i] + oSpace[i] + "</del>";
			}
		}
		else {
			if (out.n[0].text == null) {
				for (n = 0; n < out.o.length && out.o[n].text == null; n++) {
					str += '<del>' + out.o[n] + oSpace[n] + "</del>";
				}
			}
			
			for (var i = 0; i < out.n.length; i++) {
				if (out.n[i].text == null) {
					str += '<ins>' + out.n[i] + nSpace[i] + "</ins>";
				}
				else {
					var pre = "";
					
					for (n = out.n[i].row + 1; n < out.o.length && out.o[n].text == null; n++) {
						pre += '<del>' + out.o[n] + oSpace[n] + "</del>";
					}
					str += " " + out.n[i].text + nSpace[i] + pre;
				}
			}
		}
		
		return str;
	};
})();

})(this);

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/libs/qunit.js


__jah__.resources["/libs/cocos2d/libs/util.js"] = {data: function (exports, require, module, __filename, __dirname) {
var path = require('path');

/**
 * @namespace
 * Useful utility functions
 */
var util = {
    /**
     * Merge two or more objects and return the result.
     *
     * @param {Object} firstObject First object to merge with
     * @param {Object} secondObject Second object to merge with
     * @param {Object} [...] More objects to merge
     * @returns {Object} A new object containing the properties of all the objects passed in
     */
    merge: function(firstObject, secondObject) {
        var result = {};

        for (var i = 0; i < arguments.length; i++) {
            var obj = arguments[i];

            for (var x in obj) {
                if (!obj.hasOwnProperty(x)) {
                    continue;
                }

                result[x] = obj[x];
            }
        };

        return result;
    },

    /**
     * Creates a deep copy of an object
     *
     * @param {Object} obj The Object to copy
     * @returns {Object} A copy of the original Object
     */
    copy: function(obj) {
        if (obj === null) {
            return null;
        }

        var copy;

        if (obj instanceof Array) {
            copy = [];
            for (var i = 0, len = obj.length; i < len; i++) {
                copy[i] = util.copy(obj[i]);
            }
        } else if (typeof(obj) == 'object') {
            if (typeof(obj.copy) == 'function') {
                copy = obj.copy();
            } else {
                copy = {};

                var o, x;
                for (x in obj) {
                    copy[x] = util.copy(obj[x]);
                }
            }
        } else {
            // Primative type. Doesn't need copying
            copy = obj;
        }

        return copy;
    },

    /**
     * Iterates over an array and calls a function for each item.
     *
     * @param {Array} arr An Array to iterate over
     * @param {Function} func A function to call for each item in the array
     * @returns {Array} The original array
     */
    each: function(arr, func) {
        var i = 0,
            len = arr.length;
        for (i = 0; i < len; i++) {
            func(arr[i], i);
        }

        return arr;
    },

    /**
     * Iterates over an array, calls a function for each item and returns the results.
     *
     * @param {Array} arr An Array to iterate over
     * @param {Function} func A function to call for each item in the array
     * @returns {Array} The return values from each function call
     */
    map: function(arr, func) {
        var i = 0,
            len = arr.length,
            result = [];

        for (i = 0; i < len; i++) {
            result.push(func(arr[i], i));
        }

        return result;
    },

    extend: function(target, ext) {
        if (arguments.length < 2) {
            throw "You must provide at least a target and 1 object to extend from"
        }

        var i, j, obj, key, val, descriptor;

        for (i = 1; i < arguments.length; i++) {
            obj = arguments[i];
            for (key in obj) {
                // Don't copy built-ins
                if (!obj.hasOwnProperty(key)) {
                    continue;
                }

                descriptor = Object.getOwnPropertyDescriptor(obj, key)

                // Accessor descriptories are copied as is
                if (descriptor.get || descriptor.set) {
                    Object.defineProperty(target, key, descriptor);
                    continue;
                }

                val = descriptor.value;

                // Don't copy undefineds or references to target (would cause infinite loop)
                if (val === undefined || val === target) {
                    continue;
                }

                // Replace existing function and store reference to it in .base
                if (val instanceof Function && target[key] && val !== target[key]) {
                    val.base = target[key];
                    val._isProperty = val.base._isProperty;
                }

                if (val instanceof Function) {
                    // If this function observes make a reference to it so we can set
                    // them up when this get instantiated
                    if (val._observing) {
                        // Force a COPY of the array or we will probably end up with various
                        // classes sharing the same one.
                        if (!target._observingFunctions) {
                            target._observingFunctions = [];
                        } else {
                            target._observingFunctions = target._observingFunctions.slice(0);
                        }


                        for (j = 0; j<val._observing.length; j++) {
                            target._observingFunctions.push({property:val._observing[j], method: key});
                        }
                    } // if (val._observing)

                    // If this is a computer property then add it to the list so get/set know where to look
                    if (val._isProperty) {
                        if (!target._computedProperties) {
                            target._computedProperties = [];
                        } else {
                            target._computedProperties = target._computedProperties.slice(0);
                        }

                        target._computedProperties.push(key)
                    }
                } // if (val instanceof Function)

                descriptor.value = val;

                Object.defineProperty(target, key, descriptor);
            } // for (key in obj)
        } // for (i = 1; i < arguments.length; i++)


        return target;
    },

    callback: function(target, method) {
        console.warn("cocos.util.callback is deprecated. Use the built-in Function.bind instead")
        if (typeof(method) == 'string') {
            var methodName = method;
            method = target[method];
            if (!method) {
                throw "Callback to undefined method: " + methodName;
            }
        }
        if (!method) {
            throw "Callback with no method to call";
        }

        return function() {
            method.apply(target, arguments);
        }
    },

    domReady: function() {
        if (this._isReady) {
            return;
        }

        if (!document.body) {
            setTimeout(function() { util.domReady(); }, 13);
        }

        window.__isReady = true;

        if (window.__readyList) {
            var fn, i = 0;
            while ( (fn = window.__readyList[ i++ ]) ) {
                fn.call(document);
            }

            window.__readyList = null;
            delete window.__readyList;
        }
    },


    /**
     * Adapted from jQuery
     * @ignore
     */
    bindReady: function() {

        if (window.__readyBound) {
            return;
        }

        window.__readyBound = true;

        // Catch cases where $(document).ready() is called after the
        // browser event has already occurred.
        if ( document.readyState === "complete" ) {
            return util.domReady();
        }

        // Mozilla, Opera and webkit nightlies currently support this event
        if ( document.addEventListener ) {
            // Use the handy event callback
            //document.addEventListener( "DOMContentLoaded", DOMContentLoaded, false );
            
            // A fallback to window.onload, that will always work
            window.addEventListener( "load", util.domReady, false );

        // If IE event model is used
        } else if ( document.attachEvent ) {
            // ensure firing before onload,
            // maybe late but safe also for iframes
            //document.attachEvent("onreadystatechange", DOMContentLoaded);
            
            // A fallback to window.onload, that will always work
            window.attachEvent( "onload", util.domReady );

            // If IE and not a frame
            /*
            // continually check to see if the document is ready
            var toplevel = false;

            try {
                toplevel = window.frameElement == null;
            } catch(e) {}

            if ( document.documentElement.doScroll && toplevel ) {
                doScrollCheck();
            }
            */
        }
    },



    ready: function(func) {
        if (window.__isReady) {
            func()
        } else {
            if (!window.__readyList) {
                window.__readyList = [];
            }
            window.__readyList.push(func);
        }

        util.bindReady();
    },


    /**
     * Tests if a given object is an Array
     *
     * @param {Array} ar The object to test
     *
     * @returns {Boolean} True if it is an Array, otherwise false
     */
    isArray: function(ar) {
      return ar instanceof Array
          || (ar && ar !== Object.prototype && util.isArray(ar.__proto__));
    },


    /**
     * Tests if a given object is a RegExp
     *
     * @param {RegExp} ar The object to test
     *
     * @returns {Boolean} True if it is an RegExp, otherwise false
     */
    isRegExp: function(re) {
      var s = ""+re;
      return re instanceof RegExp // easy case
          || typeof(re) === "function" // duck-type for context-switching evalcx case
          && re.constructor.name === "RegExp"
          && re.compile
          && re.test
          && re.exec
          && s.charAt(0) === "/"
          && s.substr(-1) === "/";
    },


    /**
     * Tests if a given object is a Date
     *
     * @param {Date} ar The object to test
     *
     * @returns {Boolean} True if it is an Date, otherwise false
     */
    isDate: function(d) {
        if (d instanceof Date) return true;
        if (typeof d !== "object") return false;
        var properties = Date.prototype && Object.getOwnPropertyNames(Date.prototype);
        var proto = d.__proto__ && Object.getOwnPropertyNames(d.__proto__);
        return JSON.stringify(proto) === JSON.stringify(properties);
    },

    /**
     * Utility to populate a namespace's index with its modules
     *
     * @param {Object} parent The module the namespace lives in. parent.exports will be populated automatically
     * @param {String} modules A space separated string of all the module names
     *
     * @returns {Object} The index namespace
     */
    populateIndex: function(parent, modules) {
        var namespace = {};
        modules = modules.split(' ');

        util.each(modules, function(mod, i) {
            // Use the global 'require' which allows overriding the parent module
            util.extend(namespace, window.require('./' + mod, parent));
        });

        util.extend(parent.exports, namespace);

        return namespace;
    },

    requireAll: function () {
        var mods = [].slice.call(arguments)
          , namespace = {}
          , parent = mods.shift()

        mods.forEach(function (m) {
            util.extend(namespace, window.require('./' + m, parent))
        })

        return namespace
    },

    /**
     * Update an object's properties so they're readonly
     *
     * @param {Object} obj Object to have readonly properties set on it
     * @param {String[]} properties The properties to make readonly
     */
    makeReadonly: function (obj, properties) {
        if (!(properties instanceof Array)) {
            properties = [properties];
        }
        for (var i = 0, len = properties.length, p; i < len; i++) {
            p = properties[i];
            obj['_' + p] = obj[p]
            Object.defineProperty(obj, p, {
                get: function (p) { return this['_' + p] }.bind(obj, p)
            });
        }
    }
}

util.extend(String.prototype, /** @scope String.prototype */ {
    /**
     * Create an array of words from a string
     *
     * @getter {String[]} w
     */
    get w () {
        return this.split(' ');
    }
});




module.exports = util;

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/libs/util.js


__jah__.resources["/libs/cocos2d/nodes/AtlasNode.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

var SpriteBatchNode = require('./BatchNode').SpriteBatchNode,
    TextureAtlas = require('../TextureAtlas').TextureAtlas,
    geo   = require('geometry')

/**
 * @class
 * It knows how to render a TextureAtlas object. If you are going to
 * render a TextureAtlas consider subclassing cocos.nodes.AtlasNode (or a
 * subclass of cocos.nodes.AtlasNode)
 *
 * @memberOf cocos.nodes
 * @extends cocos.nodes.SpriteBatchNode
 *
 * @opt {String} file Path to Atals image
 * @opt {Integer} itemWidth Character width
 * @opt {Integer} itemHeight Character height
 * @opt {Integer} itemsToRender Quantity of items to render
 */
function AtlasNode (opts) {
    AtlasNode.superclass.constructor.call(this, opts)

    this.itemWidth = opts.itemWidth
    this.itemHeight = opts.itemHeight

    this.textureAtlas = new TextureAtlas({file: opts.file, capacity: opts.itemsToRender})


    this._calculateMaxItems()
}

AtlasNode.inherit(SpriteBatchNode, /** @lends cocos.nodes.AtlasNode# */ {
    /**
     * Characters per row
     * @type Integer
     */
    itemsPerRow: 0,

    /**
     * Characters per column
     * @type Integer
     */
    itemsPerColumn: 0,

    /**
     * Width of a character
     * @type Integer
     */
    itemWidth: 0,

    /**
     * Height of a character
     * @type Integer
     */
    itemHeight: 0,


    /**
     * @type cocos.TextureAtlas
     */
    textureAtlas: null,

    updateAtlasValues: function () {
        throw "cocos.nodes.AtlasNode:Abstract - updateAtlasValue not overriden"
    },

    _calculateMaxItems: function () {
        var s = this.textureAtlas.texture.contentSize
        this.itemsPerColumn = s.height / this.itemHeight
        this.itemsPerRow = s.width / this.itemWidth
    }
})

exports.AtlasNode = AtlasNode

// vim:et:st=4:fdm=marker:fdl=0:fdc=1

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/nodes/AtlasNode.js


__jah__.resources["/libs/cocos2d/nodes/BatchNode.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

var util = require('util'),
    events = require('events'),
    geo = require('geometry'),
    ccp = geo.ccp,
    TextureAtlas = require('../TextureAtlas').TextureAtlas,
    RenderTexture = require('./RenderTexture').RenderTexture,
    Node = require('./Node').Node

/**
 * @class
 * Draws all children to an in-memory canvas and only redraws when something changes
 *
 * @memberOf cocos.nodes
 * @extends cocos.nodes.Node
 *
 * @opt {geometry.Size} size The size of the in-memory canvas used for drawing to
 * @opt {Boolean} [partialDraw=false] Draw only the area visible on screen. Small maps may be slower in some browsers if this is true.
 */
function BatchNode (opts) {
    BatchNode.superclass.constructor.call(this, opts)

    var size = opts.size || geo.sizeMake(1, 1)
    this.partialDraw = opts.partialDraw

    events.addPropertyListener(this, 'contentSize', 'change', this._resizeCanvas.bind(this))

    this._dirtyRects = []
    this.contentRect = geo.rectMake(0, 0, size.width, size.height)
    this.renderTexture = new RenderTexture(size)
    this.renderTexture.sprite.isRelativeAnchorPoint = false
    BatchNode.superclass.addChild.call(this, this.renderTexture)
}

BatchNode.inherit(Node, /** @lends cocos.nodes.BatchNode# */ {
    partialDraw: false,
    contentRect: null,
    renderTexture: null,
    dirty: true,

    /**
     * Region to redraw
     * @type geometry.Rect
     */
    dirtyRegion: null,
    dynamicResize: false,

    /** @private
     * Areas that need redrawing
     *
     * Not implemented
     */
    _dirtyRects: null,

    addChild: function (opts) {
        BatchNode.superclass.addChild.call(this, opts)

        var child, z

        if (opts instanceof Node) {
            child = opts
        } else {
            child = opts.child
            z     = opts.z
        }

        // TODO handle texture resize

        // Watch for changes in child
        events.addListener(child, 'drawdirty', function (oldBox) {
            if (oldBox) {
                this.addDirtyRegion(oldBox)
            }
            this.addDirtyRegion(child.boundingBox)
        }.bind(this))

        this.addDirtyRegion(child.boundingBox)
    },

    removeChild: function (opts) {
        BatchNode.superclass.removeChild.call(this, opts)

        // TODO remove isTransformDirty and visible property listeners

        this.dirty = true
    },

    addDirtyRegion: function (rect) {
        // Increase rect slightly to compensate for subpixel artefacts
        rect = new geo.Rect(Math.floor(rect.origin.x) - 1, Math.floor(rect.origin.y) - 1,
                            Math.ceil(rect.size.width) + 2 ,Math.ceil(rect.size.height) + 2)

        var region = this.dirtyRegion
        if (!region) {
            region = rect
        } else {
            region = geo.rectUnion(region, rect)
        }

        this.dirtyRegion = region
        this.dirty = true
    },

    _resizeCanvas: function (oldSize) {
        var size = this.contentSize

        if (geo.sizeEqualToSize(size, oldSize)) {
            return; // No change
        }


        this.renderTexture.contentSize = size
        this.dirty = true
    },

    update: function () {

    },

    visit: function (context) {
        if (!this.visible) {
            return
        }

        context.save()

        this.transform(context)

        var rect = this.dirtyRegion
        // Only redraw if something changed
        if (this.dirty) {

            if (rect) {
                if (this.partialDraw) {
                    // Clip region to visible area
                    var s = require('../Director').Director.sharedDirector.winSize,
                        p = this.position
                    var r = new geo.Rect(
                        0, 0,
                        s.width, s.height
                    )
                    r = geo.rectApplyAffineTransform(r, this.worldToNodeTransform())
                    rect = geo.rectIntersection(r, rect)
                }

                this.renderTexture.clear(rect)

                this.renderTexture.context.save()
                this.renderTexture.context.beginPath()
                this.renderTexture.context.rect(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)
                this.renderTexture.context.clip()
                this.renderTexture.context.closePath()
            } else {
                this.renderTexture.clear()
            }

            for (var i = 0, childLen = this.children.length; i < childLen; i++) {
                var c = this.children[i]
                if (c == this.renderTexture) {
                    continue
                }

                // Draw children inside rect
                if (!rect || geo.rectOverlapsRect(c.boundingBox, rect)) {
                    c.visit(this.renderTexture.context, rect)
                }
            }

            if (SHOW_REDRAW_REGIONS) {
                if (rect) {
                    this.renderTexture.context.beginPath()
                    this.renderTexture.context.rect(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)
                    this.renderTexture.context.fillStyle = "rgba(0, 0, 255, 0.5)"
                    this.renderTexture.context.fill()
                    this.renderTexture.context.closePath()
                }
            }

            if (rect) {
                this.renderTexture.context.restore()
            }

            this.dirty = false
            this.dirtyRegion = null
        }

        this.renderTexture.visit(context)

        context.restore()
    },

    draw: function (ctx) {
    },

    onEnter: function () {
        BatchNode.superclass.onEnter.call(this)

        if (this.partialDraw) {
            events.addPropertyListener(this.parent, 'isTransformDirty', 'change', function () {
                var box = this.visibleRect
                this.addDirtyRegion(box)
            }.bind(this))
        }
    }
})

/**
 * @class
 * A BatchNode that accepts only Sprite using the same texture
 *
 * @memberOf cocos.nodes
 * @extends cocos.nodes.BatchNode
 *
 * @opt {String} file (Optional) Path to image to use as sprite atlas
 * @opt {Texture2D} texture (Optional) Texture to use as sprite atlas
 * @opt {cocos.TextureAtlas} textureAtlas (Optional) TextureAtlas to use as sprite atlas
 */
function SpriteBatchNode (opts) {
    SpriteBatchNode.superclass.constructor.call(this, opts)

    var file         = opts.file,
        textureAtlas = opts.textureAtlas,
        texture      = opts.texture

    if (file || texture) {
        textureAtlas = new TextureAtlas({file: file, texture: texture})
    }

    this.textureAtlas = textureAtlas

    // FIXME This listener needs to be added/remove onEnter/onExit to avoid memory leaks
    events.addPropertyListener(this, 'opacity', 'change', function () {
        for (var i = 0, len = this.children.length; i < len; i++) {
            var child = this.children[i]
            child.opacity = this.opacity
        }
    }.bind(this))

}
SpriteBatchNode.inherit(BatchNode, /** @lends cocos.nodes.SpriteBatchNode# */ {
    textureAtlas: null,

    /**
     * @type cocos.Texture2D
     */
    get texture () {
        return this.textureAtlas ? this.textureAtlas.texture : null
    }

})

exports.BatchNode = BatchNode
exports.SpriteBatchNode = SpriteBatchNode

// vim:et:st=4:fdm=marker:fdl=0:fdc=1

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/nodes/BatchNode.js


__jah__.resources["/libs/cocos2d/nodes/index.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

var util = require('util'),
    path = require('path')

var modules = 'AtlasNode LabelAtlas ProgressBar PreloadScene Node Layer Scene Label Sprite TMXTiledMap BatchNode RenderTexture Menu MenuItem Transition'.split(' ')

/**
 * @memberOf cocos
 * @namespace All cocos2d nodes. i.e. anything that can be added to a Scene
 */
var nodes = {}

util.each(modules, function (mod, i) {
    util.extend(nodes, require('./' + mod))
})

module.exports = nodes

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/nodes/index.js


__jah__.resources["/libs/cocos2d/nodes/Label.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

var util = require('util'),
    console = require('system').console,
    Director = require('../Director').Director,
    Node = require('./Node').Node,
    ccp = require('geometry').ccp

/**
 * @class
 * Renders a simple text label
 *
 * @memberOf cocos.nodes
 * @extends cocos.nodes.Node
 *
 * @opt {String} [string=""] The text string to draw
 * @opt {Float} [fontSize=16] The size of the font
 * @opt {String} [fontName="Helvetica"] The name of the font to use
 * @opt {String} [fontColor="white"] The color of the text
 */
function Label (opts) {
    Label.superclass.constructor.call(this, opts)
    this.anchorPoint = ccp(0.5, 0.5)

    'fontSize fontName fontColor string'.w.forEach(function (name) {
        // Set property on init
        if (opts[name]) {
            this[name] = opts[name]
        }
    }.bind(this))

    // Update content size
    this._updateLabelContentSize()
}

Label.inherit(Node, /** @lends cocos.nodes.Label# */ {
    string:   '',
    fontName: 'Helvetica',
    fontSize: 16,
    fontColor: 'white',

    /**
     * String of the font name and size to use in a format &lt;canvas&gt; understands
     *
     * @type String
     */
    get font () {
        return this.fontSize + 'px __cc2d_' + this.fontName + ',' + this.fontName
    },

    draw: function (context) {
        if (FLIP_Y_AXIS) {
            context.save()

            // Flip Y axis
            context.scale(1, -1)
            context.translate(0, -this.fontSize)
        }


        context.fillStyle = this.fontColor
        context.font = this.font
        context.textBaseline = 'top'
        if (context.fillText) {
            context.fillText(this.string, 0, 0)
        } else if (context.mozDrawText) {
            context.mozDrawText(this.string)
        }

        if (FLIP_Y_AXIS) {
            context.restore()
        }
    },

    /**
     * @private
     */
    _updateLabelContentSize: function () {
        var ctx = Director.sharedDirector.context
        var size = {width: 0, height: this.fontSize}

        var prevFont = ctx.font
        ctx.font = this.font

        if (ctx.measureText) {
            var txtSize = ctx.measureText(this.string)
            size.width = txtSize.width
        } else if (ctx.mozMeasureText) {
            size.width = ctx.mozMeasureText(this.string)
        }

        ctx.font = prevFont

        this.contentSize = size
    }
})

module.exports.Label = Label

// vim:et:st=4:fdm=marker:fdl=0:fdc=1

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/nodes/Label.js


__jah__.resources["/libs/cocos2d/nodes/LabelAtlas.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

var AtlasNode = require('./AtlasNode').AtlasNode,
    Sprite = require('./Sprite').Sprite,
    geo   = require('geometry'),
    events = require('events')

/**
 * @class
 *
 * @memberOf cocos.nodes
 * @extends cocos.nodes.BatchNode
 *
 * @opt {String} [string=] Initial text to draw
 * @opt {String} charMapFile
 * @opt {Integer} itemWidth
 * @opt {Integer} itemHeight
 * @opt {String} startCharMap Single character
 */
function LabelAtlas (opts) {
    LabelAtlas.superclass.constructor.call(this, {
        file: opts.charMapFile,
        itemWidth: opts.itemWidth,
        itemHeight: opts.itemHeight,
        itemsToRender: opts.string.length,
        size: new geo.Size(opts.itemWidth * opts.string.length, opts.itemHeight)
    })

    events.addPropertyListener(this, 'string', 'change', this.updateAtlasValue.bind(this))

    this.mapStartChar = opts.startCharMap.charCodeAt(0)
    this.string = opts.string

    this.contentSize = new geo.Size(opts.itemWidth * this.string.length, opts.itemHeight)
}

LabelAtlas.inherit(AtlasNode, /** @lends cocos.nodes.LabelAtlas# */ {
    string: '',

    mapStartChar: '',

    updateAtlasValue: function () {
        var n = this.string.length,
            s = this.string

        // FIXME this should reuse children to improve performance
        while (this.children.length > 0) {
            this.removeChild(this.children[0])
        }

        for (var i = 0; i < n; i++) {
            var a = s.charCodeAt(i) - this.mapStartChar,
                row = (a % this.itemsPerRow),
                col = Math.floor(a / this.itemsPerRow)

            var left = row * this.itemWidth,
                top  = col * this.itemHeight

            var tile = new Sprite({rect: new geo.Rect(left, top, this.itemWidth, this.itemHeight),
                              textureAtlas: this.textureAtlas})

            tile.position = new geo.Point(i * this.itemWidth, 0)
            tile.anchorPoint = new geo.Point(0, 0)
            tile.opacity = this.opacity

            this.addChild({child: tile})
        }
    }
})

exports.LabelAtlas = LabelAtlas

// vim:et:st=4:fdm=marker:fdl=0:fdc=1

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/nodes/LabelAtlas.js


__jah__.resources["/libs/cocos2d/nodes/Layer.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

var util   = require('util')
  , events = require('events')
  , ccp    = require('geometry').ccp

var Node            = require('./Node').Node
  , Director        = require('../Director').Director
  , EventDispatcher = require('../EventDispatcher').EventDispatcher
  , TouchDispatcher = require('../TouchDispatcher').TouchDispatcher

/**
 * @class
 * A fullscreen Node. You need at least 1 layer in your app to add other nodes to.
 *
 * @memberOf cocos.nodes
 * @extends cocos.nodes.Node
 */
function Layer () {
    Layer.superclass.constructor.call(this)

    var s = Director.sharedDirector.winSize

    this.isRelativeAnchorPoint = false
    this.anchorPoint = ccp(0.5, 0.5)
    this.contentSize = s

    if (!Director.sharedDirector.isTouchScreen) {
        events.addPropertyListener(this, 'isMouseEnabled', 'change', function () {
            if (this.isRunning) {
                if (this.isMouseEnabled) {
                    EventDispatcher.sharedDispatcher.addMouseDelegate({delegate: this, priority: this.mouseDelegatePriority})
                } else {
                    EventDispatcher.sharedDispatcher.removeMouseDelegate({delegate: this})
                }
            }
        }.bind(this))

        events.addPropertyListener(this, 'isKeyboardEnabled', 'change', function () {
            if (this.isRunning) {
                if (this.isKeyboardEnabled) {
                    EventDispatcher.sharedDispatcher.addKeyboardDelegate({delegate: this, priority: this.keyboardDelegatePriority})
                } else {
                    EventDispatcher.sharedDispatcher.removeKeyboardDelegate({delegate: this})
                }
            }
        }.bind(this))
    }
}

Layer.inherit(Node, /** @lends cocos.nodes.Layer# */ {
    /**
     * When true causes this layer to receive mouse events
     * @type Boolean
     */
    isMouseEnabled: false

    /**
     * When true causes this layer to receive keyboard events
     * @type Boolean
     */
  , isKeyboardEnabled: false
  , mouseDelegatePriority: 0
  , keyboardDelegatePriority: 0

    /**
     * When true on touch screen devices causes this layer to receive touch events
     * @type Boolean
     */
  , get isTouchEnabled () {
        return this._isTouchEnabled
    }
  , set isTouchEnabled (enabled) {
        if (!Director.sharedDirector.isTouchScreen) {
            throw new Error("Only touch screen devices can listen for touch events")
        }

        if (this._isTouchEnabled != enabled) {
            this._isTouchEnabled = enabled
            if (this.isRunning) {
                if (enabled) {
                    this.registerWithTouchDispatcher()
                } else {
                    TouchDispatcher.sharedDispatcher.removeDelegate(this)
                }
            }
        }
    }
  , _isTouchEnabled: false

    /**
     * Override this method in your layer if you wish to change the type of
     * touch event dispatchment you want
     */
  , registerWithTouchDispatcher: function () {
        TouchDispatcher.sharedDispatcher.addStandardDelegate(this, 0)
    }

  , onEnter: function () {
        if (Director.sharedDirector.isTouchScreen) {
            if (this._isTouchEnabled) {
                this.registerWithTouchDispatcher()
            }
        } else {
            if (this.isMouseEnabled) {
                EventDispatcher.sharedDispatcher.addMouseDelegate({delegate: this, priority: this.mouseDelegatePriority})
            }
            if (this.isKeyboardEnabled) {
                EventDispatcher.sharedDispatcher.addKeyboardDelegate({delegate: this, priority: this.keyboardDelegatePriority})
            }
        }

        Layer.superclass.onEnter.call(this)
    }

  , onExit: function () {
        if (Director.sharedDirector.isTouchScreen) {
            TouchDispatcher.sharedDispatcher.removeDelegate(this)
        } else {
            if (this.isMouseEnabled) {
                EventDispatcher.sharedDispatcher.removeMouseDelegate({delegate: this})
            }
            if (this.isKeyboardEnabled) {
                EventDispatcher.sharedDispatcher.removeKeyboardDelegate({delegate: this})
            }
        }

        Layer.superclass.onExit.call(this)
    }
})

module.exports.Layer = Layer

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/nodes/Layer.js


__jah__.resources["/libs/cocos2d/nodes/Menu.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

var util = require('util'),
    Layer = require('./Layer').Layer,
    Director = require('../Director').Director,
    MenuItem = require('./MenuItem').MenuItem,
    geom = require('geometry'), ccp = geom.ccp

var TouchDispatcher = require('../TouchDispatcher').TouchDispatcher

/**
 * @private
 * @constant
 */
var kMenuStateWaiting = 0

/**
 * @private
 * @constant
 */
var kMenuStateTrackingTouch = 1

var kMenuTouchPriority = -128

/**
 * @class
 * A fullscreen node used to render a selection of menu options
 *
 * @memberOf cocos.nodes
 * @extends cocos.nodes.Layer
 *
 * @opt {cocos.nodes.MenuItem[]} items An array of MenuItems to draw on the menu
 */
function Menu (opts) {
    Menu.superclass.constructor.call(this, opts)

    var items = opts.items

    if (Director.sharedDirector.isTouchScreen) {
        this.isTouchEnabled = true
    } else {
        this.isMouseEnabled = true
    }

    var s = Director.sharedDirector.winSize

    this.isRelativeAnchorPoint = false
    this.anchorPoint = ccp(0.5, 0.5)
    this.contentSize = s

    this.position = ccp(s.width / 2, s.height / 2)


    if (items) {
        var z = 0
        items.forEach(function (item) {
            this.addChild({child: item, z: z++})
        }.bind(this))
    }
}

Menu.inherit(Layer, /** @lends cocos.nodes.Menu# */ {
    mouseDelegatePriority: (-Number.MAX_VALUE + 1),
    state: kMenuStateWaiting,
    selectedItem: null,
    color: null,

    addChild: function (opts) {
        if (!opts.child instanceof MenuItem) {
            throw "Menu only supports MenuItem objects as children"
        }

        Menu.superclass.addChild.call(this, opts)
    },

    // Touch Events
    registerWithTouchDispatcher: function () {
        TouchDispatcher.sharedDispatcher.addTargetedDelegate(this, kMenuTouchPriority, true)
    },

    itemForTouch: function (event) {
        var location = Director.sharedDirector.convertTouchToCanvas(event.touch)

        var children = this.children
        for (var i = 0, len = children.length; i < len; i++) {
            var item = children[i]

            if (item.visible && item.isEnabled) {
                var local = item.convertToNodeSpace(location)

                var r = item.rect
                r.origin = ccp(0, 0)

                if (geom.rectContainsPoint(r, local)) {
                    return item
                }

            }
        }

        return null
    },

    touchBegan: function (evt) {
        if (this.state != kMenuStateWaiting || !this.visible) {
            return false
        }

        for (var c = this.parent; c; c = c.parent) {
            if (!c.visible)
                return false
        }

        var selectedItem = this.itemForTouch(evt)
        this.selectedItem = selectedItem
        if (selectedItem) {
            selectedItem.selected()
            this.state = kMenuStateTrackingTouch

            return true
        }

        return false
    },

    touchEnded: function (evt) {
        var selItem = this.selectedItem

        if (selItem) {
            selItem.unselected()
            selItem.activate()
        }

        if (this.state != kMenuStateWaiting) {
            this.state = kMenuStateWaiting
        }
    },

    touchCancelled: function (evt) {
        var selItem = this.selectedItem

        if (selItem) {
            selItem.unselected()
        }

        if (this.state != kMenuStateWaiting) {
            this.state = kMenuStateWaiting
        }
    },

    touchMoved: function (evt) {
        var currentItem = this.itemForTouch(evt)

        if (currentItem != this.selectedItem) {
            if (this.selectedItem) {
                this.selectedItem.unselected()
            }
            this.selectedItem = currentItem
            if (this.selectedItem) {
                this.selectedItem.selected()
            }
        }
    },


    // Mouse Events
    itemForMouseEvent: function (event) {
        var location = event.locationInCanvas

        var children = this.children
        for (var i = 0, len = children.length; i < len; i++) {
            var item = children[i]

            if (item.visible && item.isEnabled) {
                var local = item.convertToNodeSpace(location)

                var r = item.rect
                r.origin = ccp(0, 0)

                if (geom.rectContainsPoint(r, local)) {
                    return item
                }

            }
        }

        return null
    },

    mouseUp: function (event) {
        var selItem = this.selectedItem

        if (selItem) {
            selItem.unselected()
            selItem.activate()
        }

        if (this.state != kMenuStateWaiting) {
            this.state = kMenuStateWaiting
        }
        if (selItem) {
            return true
        }
        return false

    },
    mouseDown: function (event) {
        if (this.state != kMenuStateWaiting || !this.visible) {
            return false
        }

        var selectedItem = this.itemForMouseEvent(event)
        this.selectedItem = selectedItem
        if (selectedItem) {
            selectedItem.selected()
            this.state = kMenuStateTrackingTouch

            return true
        }

        return false
    },

    mouseDragged: function (event) {
        var currentItem = this.itemForMouseEvent(event)

        if (currentItem != this.selectedItem) {
            if (this.selectedItem) {
                this.selectedItem.unselected()
            }
            this.selectedItem = currentItem
            if (this.selectedItem) {
                this.selectedItem.selected()
            }
        }

        if (currentItem && this.state == kMenuStateTrackingTouch) {
            return true
        }

        return false

    }

})

exports.Menu = Menu

// vim:et:st=4:fdm=marker:fdl=0:fdc=1

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/nodes/Menu.js


__jah__.resources["/libs/cocos2d/nodes/MenuItem.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

var util = require('util'),
    Node = require('./Node').Node,
    Sprite = require('./Sprite').Sprite,
    rectMake = require('geometry').rectMake,
    ccp = require('geometry').ccp

/**
 * @class
 * Base class for any buttons or options in a menu
 *
 * @memberOf cocos.nodes
 * @extends cocos.nodes.Node
 *
 * @opt {Function} callback Function to call when menu item is activated
 */
function MenuItem (opts) {
    MenuItem.superclass.constructor.call(this, opts)

    var callback = opts.callback

    this.anchorPoint = ccp(0.5, 0.5)
    this.callback = callback
}

MenuItem.inherit(Node, /** @lends cocos.nodes.MenuItem# */ {
    _isEnabled: true,
    isSelected: false,
    callback: null,

    activate: function () {
        if (this.isEnabled && this.callback) {
            this.callback(this)
        }
    },

    /**
     * @getter rect
     * @type geometry.Rect
     */
    get rect () {
        return rectMake(
            this.position.x - this.contentSize.width  * this.anchorPoint.x,
            this.position.y - this.contentSize.height * this.anchorPoint.y,
            this.contentSize.width,
            this.contentSize.height
        )
    },

    get isEnabled () {
        return this._isEnabled
    },

    set isEnabled (enabled) {
        this._isEnabled = enabled
    },

    selected: function () {
        this.isSelected = true
    },

    unselected: function () {
        this.isSelected = false
    }
})

/**
 * @class
 * A menu item that accepts any cocos.nodes.Node
 *
 * @memberOf cocos.nodes
 * @extends cocos.nodes.MenuItem
 *
 * @opt {cocos.nodes.Node} normalImage Main Node to draw
 * @opt {cocos.nodes.Node} selectedImage Node to draw when menu item is selected
 * @opt {cocos.nodes.Node} disabledImage Node to draw when menu item is disabled
 */
function MenuItemSprite (opts) {
    MenuItemSprite.superclass.constructor.call(this, opts)

    var normalImage   = opts.normalImage,
        selectedImage = opts.selectedImage,
        disabledImage = opts.disabledImage

    this.normalImage = normalImage
    this.selectedImage = selectedImage
    this.disabledImage = disabledImage

    this.contentSize = normalImage.contentSize
}

MenuItemSprite.inherit(MenuItem, /** @lends cocos.nodes.MenuItemSprite# */ {
    _normalImage: null,
    _selectedImage: null,
    _disabledImage: null,

    get normalImage () {
        return this._normalImage
    },

    set normalImage (image) {
        if (image != this.normalImage) {
            image.anchorPoint = ccp(0, 0)
            image.visible = true
            this.removeChild({child: this.normalImage, cleanup: true})
            this.addChild(image)

            this._normalImage = image
        }
    },

    get selectedImage () {
        return this._selectedImage
    },

    set selectedImage (image) {
        if (image != this.selectedImage) {
            image.anchorPoint = ccp(0, 0)
            image.visible = false
            this.removeChild({child: this.selectedImage, cleanup: true})
            this.addChild(image)

            this._selectedImage = image
        }
    },

    get disabledImage () {
        return this._disabledImage
    },

    set disabledImage (image) {
        if (image != this.disabledImage) {
            image.anchorPoint = ccp(0, 0)
            image.visible = false
            this.removeChild({child: this.disabledImage, cleanup: true})
            this.addChild(image)

            this._disabledImage = image
        }
    },

    selected: function () {
        MenuItemSprite.superclass.selected.call(this)

        if (this.selectedImage) {
            this.normalImage.visible =   false
            this.selectedImage.visible = true
            if (this.disabledImage) this.disabledImage.visible = false
        } else {
            this.normalImage.visible =   true
            if (this.disabledImage) this.disabledImage.visible = false
        }
    },

    unselected: function () {
        MenuItemSprite.superclass.unselected.call(this)

        this.normalImage.visible =   true
        if (this.selectedImage) this.selectedImage.visible = false
        if (this.disabledImage) this.disabledImage.visible = false
    },

    get isEnabled () {
        return this._isEnabled
    },

    set isEnabled (enabled) {
        this._isEnabled = enabled

        if (enabled) {
            this.normalImage.visible =   true
            if (this.selectedImage) this.selectedImage.visible = false
            if (this.disabledImage) this.disabledImage.visible = false
        } else {
            if (this.disabledImage) {
                this.normalImage.visible =   false
                if (this.selectedImage) this.selectedImage.visible = false
                this.disabledImage.visible = true
            } else {
                this.normalImage.visible =   true
                if (this.selectedImage) this.selectedImage.visible = false
            }
        }
    }
})

/**
 * @class
 * MenuItem that accepts image files
 *
 * @memberOf cocos.nodes
 * @extends cocos.nodes.MenuItemSprite
 *
 * @opt {String} normalImage Main image file to draw
 * @opt {String} selectedImage Image file to draw when menu item is selected
 * @opt {String} disabledImage Image file to draw when menu item is disabled
 */
function MenuItemImage (opts) {
    var normalI   = opts.normalImage,
        selectedI = opts.selectedImage,
        disabledI = opts.disabledImage,
        callback  = opts.callback

    var normalImage = new Sprite({file: normalI}),
        selectedImage = new Sprite({file: selectedI}),
        disabledImage = null

    if (disabledI) {
        disabledImage = new Sprite({file: disabledI})
    }

    MenuItemImage.superclass.constructor.call(this, {normalImage: normalImage, selectedImage: selectedImage, disabledImage: disabledImage, callback: callback})
}

MenuItemImage.inherit(MenuItemSprite)

exports.MenuItem = MenuItem
exports.MenuItemImage = MenuItemImage
exports.MenuItemSprite = MenuItemSprite

// vim:et:st=4:fdm=marker:fdl=0:fdc=1

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/nodes/MenuItem.js


__jah__.resources["/libs/cocos2d/nodes/Node.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

//{{{ Imports
var util   = require('util')
  , events = require('events')
  , geo    = require('geometry')
  , ccp    = geo.ccp

var Scheduler     = require('../Scheduler').Scheduler
  , ActionManager = require('../ActionManager').ActionManager
//}}}

/**
 * @class
 * The base class all visual elements extend from
 *
 * @memberOf cocos.nodes
 */
function Node () {
    this._contentSize = new geo.Size(0, 0)
    this._anchorPoint = ccp(0.0, 0.0)
    this.anchorPointInPixels = ccp(0, 0)
    this._position = ccp(0, 0)
    this.children = []

    events.addListener(this, 'dirtytransform', this._dirtyTransform.bind(this))
}

Node.inherit(Object, /** @lends cocos.nodes.Node# */ {
    /**
     * Is the node visible
     * @type Boolean
     */
    get visible ()  { return this._visible }
  , set visible (x) { this._visible = x; this._dirtyDraw() }
  , _visible: true

    /**
     * Position relative to parent node
     * @type geometry.Point
     */
  , get position ()  { return this._position }
  , set position (x) { this._position = x; events.trigger(this, 'dirtytransform', {target: this, property: 'position'}) }
  , _position: null

    /**
     * Parent node
     * @type cocos.nodes.Node
     * @readonly
     */
  , parent: null

    /**
     * Unique tag to identify the node
     * @type String
     */
  , tag: null

    /**
     * Size of the node
     * @type geometry.Size
     */
  , get contentSize ()  { return this._contentSize }
  , set contentSize (x) { this._contentSize = x; events.trigger(this, 'dirtytransform', {target: this, property: 'contentSize'}); this._updateAnchorPointInPixels() }
  , _contentSize: null

    /**
     * Nodes Z index. i.e. draw order
     * @type Integer
     */
  , zOrder: 0

    /**
     * Anchor point for scaling and rotation. 0x0 is top left and 1x1 is bottom right
     * @type geometry.Point
     */
  , get anchorPoint ()  { return this._anchorPoint }
  , set anchorPoint (x) { this._anchorPoint = x; events.trigger(this, 'dirtytransform', {target: this, property: 'anchorPoint'}); this._updateAnchorPointInPixels() }

    /**
     * Anchor point for scaling and rotation in pixels from top left
     * @type geometry.Point
     */
  , anchorPointInPixels: null

    /**
     * Rotation angle in degrees
     * @type Float
     */
  , get rotation ()  { return this._rotation }
  , set rotation (x) { this._rotation = x; events.trigger(this, 'dirtytransform', {target: this, property: 'rotation'}) }
  , _rotation: 0

    /**
     * X scale factor
     * @type Float
     */
  , get scaleX ()  { return this._scaleX }
  , set scaleX (x) { this._scaleX = x; events.trigger(this, 'dirtytransform', {target: this, property: 'scaleX'}) }

    /**
     * @ignore
     */
  , _scaleX: 1

    /**
     * Y scale factor
     * @type Float
     */
  , get scaleY ()  { return this._scaleY }
  , set scaleY (x) { this._scaleY = x; events.trigger(this, 'dirtytransform', {target: this, property: 'scaleY'}) }

    /**
     * @ignore
     */
  , _scaleY: 1

    /**
     * Opacity of the Node. 0 is totally transparent, 255 is totally opaque
     * @type Float
     */
  , get opacity ()  { return this._opacity }
  , set opacity (x) { this._opacity = x; this._dirtyDraw() }
  , _opacity: 255

    /**
     * Is the node active in the scene
     * @type Boolean
     * @readonly
     */
  , isRunning: false

    /**
     * Is the anchor point relative to the Node
     * @type Boolean
     */
  , get isRelativeAnchorPoint ()  { return this._isRelativeAnchorPoint }
  , set isRelativeAnchorPoint (x) { this._isRelativeAnchorPoint = x; events.trigger(this, 'dirtytransform', {target: this, property: 'isRelativeAnchorPoint'}) }
  , _isRelativeAnchorPoint: true

    /**
     * Has a property changed the requires recaculation of the transform matrix
     * @type Boolean
     */
  , isTransformDirty: true

  , isInverseDirty: true

  , inverse: null

    /**
     * Current transform matrix used to render the Node. Set by cocos.nodes.Node#nodeToParentTransform
     * @type Boolean
     */
  , transformMatrix: null

    /**
     * The child Nodes
     * @type {cocos.nodes.Node[]}
     */
  , children: null

    /**
     * @private
     * Calculates the anchor point in pixels and updates the
     * anchorPointInPixels property
     */
  , _updateAnchorPointInPixels: function () {
        var ap = this.anchorPoint
          , cs = this.contentSize
        this.anchorPointInPixels = ccp(cs.width * ap.x, cs.height * ap.y)
    }

    /**
     * Add a child Node
     *
     * @opt {cocos.nodes.Node} child The child node to add
     * @opt {Integer} [z] Z Index for the child
     * @opt {Integer|String} [tag] A tag to reference the child with
     * @returns {cocos.nodes.Node} The node the child was added to. i.e. 'this'
     */
  , addChild: function (opts) {
        if (opts instanceof Node) {
            return this.addChild({child: opts})
        }

        var child = opts.child
          , z = opts.z
          , tag = opts.tag
          , added = false

        if (z === undefined || z === null) {
            z = child.zOrder
        }

        //this.insertChild({child: child, z:z})


        var childLen = this.children.length
          , i, c
        for (i = 0; i < childLen; i++) {
            c = this.children[i]
            if (c.zOrder > z) {
                added = true
                this.children.splice(i, 0, child)
                break
            }
        }

        if (!added) {
            this.children.push(child)
        }

        child.tag = tag
        child.zOrder = z
        child.parent = this

        if (this.isRunning) {
            child.onEnter()
        }

        return this
    }

    /**
     * Get a child node via its tag. Returns null if no Node is found
     *
     * @opt {String} tag Tag of the Node to return
     *
     * @returns cocos.nodes.Node
     */
  , getChild: function (opts) {
        var tag = opts.tag

        for (var i = 0; i < this.children.length; i++) {
            if (this.children[i].tag == tag) {
                return this.children[i]
            }
        }

        return null
    }

    /**
     * Remove a child node.
     *
     * If 'cleanup' is true all actions and scheduled methods will be removed
     * from the child and its children. You must set this to 'true' if you're
     * removing the object forever or you will have a memory leak.
     *
     * @opt {cocos.nodes.Node} child The Node to remove
     * @opt {Boolean} [cleanup=false] Should a cleanup be performed after removing the Node
     */
  , removeChild: function (opts) {
        if (opts instanceof Node) {
            return this.removeChild({child: opts})
        }

        var child = opts.child
          , cleanup = opts.cleanup

        if (!child) {
            return
        }

        var children = this.children
          , idx = children.indexOf(child)

        if (idx > -1) {
            this._detachChild({child: child, cleanup: cleanup})
        }
    }

    /**
     * Remove all child nodes.
     *
     * If 'cleanup' is true all actions and scheduled methods will be removed
     * from the child and its children.
     *
     * @opt {Boolean} [cleanup=false] Should a cleanup be performed after removing the Node
     */
  , removeChildren: function (opts) {
        var children = this.children
          , isRunning = this.isRunning

        // Perform cleanup on each child but can't call removeChild()
        // due to Array.splice's destructive nature during iteration.
        for (var i = 0; i < children.length; i++) {
            if (opts.cleanup) {
                children[i].cleanup()
            }
            if (isRunning) {
                children[i].onExit()
            }
            children[i].parent = null
        }
        // Now safe to empty children list
        this.children = []
    }

    /**
     * @private
     * Detach the child node from this node
     *
     * @opt {cocos.nodes.Node} child The Node to remove
     * @opt {Boolean} [cleanup=false] Should a cleanup be performed after removing the Node
     */
  , _detachChild: function (opts) {
        var child = opts.child
          , cleanup = opts.cleanup

        var children = this.children
          , isRunning = this.isRunning
          , idx = children.indexOf(child)

        if (isRunning) {
            child.onExit()
        }

        if (cleanup) {
            child.cleanup()
        }

        child.parent = null
        children.splice(idx, 1)
    }

    /**
     * Change the Z index of a child node. Other child nodes will have their Z
     * index adjusted to accommodate.
     *
     * @opt {cocos.nodes.Node} child Child node to reorder
     * @opt {Integer} z The new Z index for the child
     */
  , reorderChild: function (opts) {
        var child = opts.child
          , z     = opts.z
          , pos   = this.children.indexOf(child)

        if (pos == -1) {
            throw "Node isn't a child of this node"
        }

        child.zOrder = z

        // Remove child
        this.children.splice(pos, 1)

        // Add child back at correct location
        var added = false
          , childLen = this.children.length
          , i, c
        for (i = 0; i < childLen; i++) {
            c = this.children[i]
            if (c.zOrder > z) {
                added = true
                this.children.splice(i, 0, child)
                break
            }
        }

        if (!added) {
            this.children.push(child)
        }
    }

    /**
     * Draws the node. Override to do custom drawing. If it's less efficient to
     * draw only the area inside the rect then don't bother. The result will be
     * clipped to that area anyway.
     *
     * @param {CanvasRenderingContext2D} context Canvas rendering context
     * @param {geometry.Rect} rect Rectangular region that needs redrawing. Limit drawing to this area only if it's more efficient to do so.
     */
  , draw: function (context, rect) {
        // All draw code goes here
    }

    /**
     * The scale factor for the node. Only valid is scaleX and scaleY are identical
     *
     * @type Float
     */
  , get scale () {
        if (this.scaleX != this.scaleY) {
            throw "scaleX and scaleY aren't identical"
        }

        return this.scaleX
    }

    /**
     * Sets both scaleX and scaleY to the given value
     *
     * @type Float
     */
  , set scale (val) {
        this.scaleX = val
        this.scaleY = val
    }

    /**
     * Schedule a timer to call the 'update' method on this node every frame
     *
     * @opt {Integer} [priority=0] Priority order for when the method should be called
     */
  , scheduleUpdate: function (opts) {
        opts = opts || {}
        var priority = opts.priority || 0

        Scheduler.sharedScheduler.scheduleUpdate({target: this, priority: priority, paused: !this.isRunning})
    }

  , unscheduleUpdate: function () {
        Scheduler.sharedScheduler.unscheduleUpdateForTarget(this)
    }

    /**
     * Triggered when the node is added to a scene
     *
     * @event
     */
  , onEnter: function () {
        this.children.forEach(function (child) { child.onEnter() })

        this.resumeSchedulerAndActions()
        this.isRunning = true
    }

    /**
     * Triggered when the node is removed from a scene
     *
     * @event
     */
  , onExit: function () {
        this.pauseSchedulerAndActions()
        this.isRunning = false

        this.children.forEach(function (child) { child.onExit() })
    }

    /**
     * Stop and remove all actions and scheduled method calls on itself and
     * children
     */
  , cleanup: function () {
        this.stopAllActions()
        this.unscheduleAllSelectors()
        this.children.forEach(function (child) { child.cleanup() })
    }

  , resumeSchedulerAndActions: function () {
        Scheduler.sharedScheduler.resumeTarget(this)
        ActionManager.sharedManager.resumeTarget(this)
    }

    /**
     * Temporarily pause scheduled methods and actions
     */
  , pauseSchedulerAndActions: function () {
        Scheduler.sharedScheduler.pauseTarget(this)
        ActionManager.sharedManager.pauseTarget(this)
    }

    /**
     * Remove a specific scheduled method call
     */
  , unscheduleSelector: function (selector) {
        Scheduler.sharedScheduler.unschedule({target: this, method: selector})
    }

    /**
     * Remove all scheduled methods calls
     */
  , unscheduleAllSelectors: function () {
        Scheduler.sharedScheduler.unscheduleAllSelectorsForTarget(this)
    }

    /**
     * Stop all running actions on this node
     */
  , stopAllActions: function () {
        ActionManager.sharedManager.removeAllActionsFromTarget(this)
    }

    /**
     * Called automatically every frame and triggers the call to 'draw' this
     * node and its children in the correct order.
     *
     * For custom drawing override the 'draw' method. Only override this if you
     * really need to do something special.
     *
     * @param {CanvasRenderingContext2D} context Canvas rendering context
     * @param {geometry.Rect} [rect] Area that needs redrawing
     */
  , visit: function (context, rect) {
        if (!this.visible) {
            return
        }

        context.save()

        this.transform(context)

        // Set alpha value (global only for now)
        context.globalAlpha = this.opacity / 255.0

        // Adjust redraw region by nodes position
        if (rect) {
            var pos = this.position
            rect = new geo.Rect(rect.origin.x - pos.x, rect.origin.y - pos.y, rect.size.width, rect.size.height)
        }

        // Draw background nodes
        this.children.forEach(function (child, i) {
            if (child.zOrder < 0) {
                child.visit(context, rect)
            }
        })

        this.draw(context, rect)

        // Draw foreground nodes
        this.children.forEach(function (child, i) {
            if (child.zOrder >= 0) {
                child.visit(context, rect)
            }
        })

        context.restore()
    }

    /**
     * Transforms the node by its scale, rotation and position. Called automatically when one of these changes
     *
     * @param {CanvasRenderingContext2D} context Canvas rendering context
     */
  , transform: function (context) {
        // Translate
        if (this.isRelativeAnchorPoint && (this.anchorPointInPixels.x !== 0 || this.anchorPointInPixels.y !== 0)) {
            context.translate(Math.round(-this.anchorPointInPixels.x), Math.round(-this.anchorPointInPixels.y))
        }

        if (this.anchorPointInPixels.x !== 0 || this.anchorPointInPixels.y !== 0) {
            context.translate(Math.round(this.position.x + this.anchorPointInPixels.x), Math.round(this.position.y + this.anchorPointInPixels.y))
        } else {
            context.translate(Math.round(this.position.x), Math.round(this.position.y))
        }

        // Rotate
        if (FLIP_Y_AXIS) {
            context.rotate(-geo.degreesToRadians(this.rotation))
        } else {
            context.rotate(geo.degreesToRadians(this.rotation))
        }

        // Scale
        context.scale(this.scaleX, this.scaleY)

        if (this.anchorPointInPixels.x !== 0 || this.anchorPointInPixels.y !== 0) {
            context.translate(Math.round(-this.anchorPointInPixels.x), Math.round(-this.anchorPointInPixels.y))
        }
    }

    /**
     * Run an action on the node
     *
     * @param {cocos.actions.Action} action Action to run
     */
  , runAction: function (action) {
        ActionManager.sharedManager.addAction({action: action, target: this, paused: this.isRunning})
    }

    /**
     * @opt {String} tag Tag of the action to return
     */
  , getAction: function (opts) {
        return ActionManager.sharedManager.getActionFromTarget({target: this, tag: opts.tag})
    }

  , nodeToParentTransform: function () {
        if (this.isTransformDirty) {
            this.transformMatrix = geo.affineTransformIdentity()

            if (!this.isRelativeAnchorPoint && !geo.pointEqualToPoint(this.anchorPointInPixels, ccp(0, 0))) {
                this.transformMatrix = geo.affineTransformTranslate(this.transformMatrix, this.anchorPointInPixels.x, this.anchorPointInPixels.y)
            }

            if (!geo.pointEqualToPoint(this.position, ccp(0, 0))) {
                this.transformMatrix = geo.affineTransformTranslate(this.transformMatrix, this.position.x, this.position.y)
            }

            if (this.rotation !== 0) {
                this.transformMatrix = geo.affineTransformRotate(this.transformMatrix, -geo.degreesToRadians(this.rotation))
            }
            if (!(this.scaleX == 1 && this.scaleY == 1)) {
                this.transformMatrix = geo.affineTransformScale(this.transformMatrix, this.scaleX, this.scaleY)
            }

            if (!geo.pointEqualToPoint(this.anchorPointInPixels, ccp(0, 0))) {
                this.transformMatrix = geo.affineTransformTranslate(this.transformMatrix, -this.anchorPointInPixels.x, -this.anchorPointInPixels.y)
            }

            this.isTransformDirty = false

        }

        return this.transformMatrix
    }

  , parentToNodeTransform: function () {
        // TODO
    }

  , nodeToWorldTransform: function () {
        var t = this.nodeToParentTransform()

        var p
        for (p = this.parent; p; p = p.parent) {
            t = geo.affineTransformConcat(t, p.nodeToParentTransform())
        }

        return t
    }

  , worldToNodeTransform: function () {
        return geo.affineTransformInvert(this.nodeToWorldTransform())
    }

  , convertToNodeSpace: function (worldPoint) {
        return geo.pointApplyAffineTransform(worldPoint, this.worldToNodeTransform())
    }

    /**
     * Rectangle bounding box relative to its parent Node
     *
     * @type geometry.Rect
     */
  , get boundingBox () {
        if (this.isTransformDirty || !this._boundingBox) {
            this._updateBoundingBox()
        }
        return this._boundingBox
    }


  , _updateBoundingBox: function () {
        var cs = this.contentSize
          , rect = new geo.Rect(0, 0, cs.width, cs.height)

        this._boundingBox = geo.rectApplyAffineTransform(rect, this.nodeToParentTransform())
    }

    /**
     * Rectangle bounding box relative to the world
     *
     * @type geometry.Rect
     */
  , get worldBoundingBox () {
        var cs = this.contentSize
          , rect = new geo.Rect(0, 0, cs.width, cs.height)
 
        rect = geo.rectApplyAffineTransform(rect, this.nodeToWorldTransform())
        return rect
    }

    /**
     * The area of the node currently visible on screen. Returns an rect even
     * if visible is false.
     *
     * @type geometry.Rect
     */
  , get visibleRect () {
        var s = require('../Director').Director.sharedDirector.winSize
          , rect = new geo.Rect(0, 0, s.width, s.height)

        return geo.rectApplyAffineTransform(rect, this.worldToNodeTransform())
    }

    /**
     * @private
     */
  , _dirtyTransform: function () {
        var oldBB = this.boundingBox
        this.isTransformDirty = true
        this._dirtyDraw(oldBB)
        events.trigger(this, 'transformdirty', oldBB)
    }

  , _dirtyDraw: function (oldBB) {
        events.trigger(this, 'drawdirty', (oldBB instanceof geo.Rect) ? oldBB : void(0))
    }

    /**
     * Schedules a custom method with an interval time in seconds.
     * If time is 0, it will be ticked every frame.
     * If time is 0, it is recommended to use 'scheduleUpdate' instead.
     *
     * If the method is already scheduled, then the interval parameter will
     * be updated without scheduling it again.
     *
     * @opt {String|Function} method Function of method name to schedule
     * @opt {Float} [interval=0] Interval in seconds
     */
  , schedule: function (opts) {
        if (typeof opts == 'string') {
            return this.schedule({method: opts, interval: 0})
        }

        opts.interval = opts.interval || 0

        Scheduler.sharedScheduler.schedule({target: this, method: opts.method, interval: opts.interval, paused: this.isRunning})
    }

    /**
     * Unschedules a custom method
     *
     * @param {String|Function} method
     */
  , unschedule: function (method) {
        if (!method) {
            return
        }

        if (typeof method == 'string') {
            method = this[method]
        }

        Scheduler.sharedScheduler.unschedule({target: this, method: method})
    }

})

module.exports.Node = Node

// vim:et:st=4:fdm=marker:fdl=0:fdc=1

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/nodes/Node.js


__jah__.resources["/libs/cocos2d/nodes/PreloadScene.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

var Scene       = require('./Scene').Scene,
    Director    = require('../Director').Director,
    Label       = require('./Label').Label,
    ProgressBar = require('./ProgressBar').ProgressBar,
    Preloader   = require('preloader').Preloader,
    RemoteResource = require('remote_resources').RemoteResource,
    geo         = require('geometry'),
    util        = require('util'),
    events      = require('events')


/**
 * @class
 * To customise the preload screen you should inherit from
 * cocos.nodes.PreloadScene and then set Director.sharedDirector.preloadSceneConstructor
 * to your PreloadScene.
 *
 * @memberOf cocos.nodes
 * @extends cocos.nodes.Scene
 */
function PreloadScene (opts) {
    PreloadScene.superclass.constructor.call(this, opts)

    // Setup preloader
    var preloader = new Preloader()    // The main preloader
    this.preloader = preloader

    // Listen for preload events
    events.addListener(preloader, 'load', function (preloader, uri) {
        events.trigger(this, 'load', preloader, uri)
    }.bind(this))

    events.addListener(preloader, 'complete', function (preloader) {
        events.trigger(this, 'complete', preloader)
    }.bind(this))
}

PreloadScene.inherit(Scene, /** @lends cocos.nodes.PreloadScene# */ {
    preloader: null

    /**
     * True when we're going to preload the queue
     * @type Boolean
     */
  , isReady: false

  , load: function () {
        if (this.isRunning) {
            this.populateQueue()
            this.preloader.load()
        }

        this.isReady = true
    }
  , populateQueue: function () {
        this.preloader.addEverythingToQueue()
    }
  , onEnter: function () {
        PreloadScene.superclass.onEnter.call(this)

        if (this.isReady) {
            this.preloader.load()
        }
    }

})

exports.PreloadScene = PreloadScene

// vim:et:st=4:fdm=marker:fdl=0:fdc=1

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/nodes/PreloadScene.js


__jah__.resources["/libs/cocos2d/nodes/ProgressBar.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

var Node   = require('./Node').Node,
    util   = require('util'),
    geo    = require('geometry'),
    events = require('events'),
    Sprite = require('./Sprite').Sprite

/**
 * @class
 *
 * @memberOf cocos.nodes
 * @extends cocos.nodes.Node
 */
function ProgressBar (opts) {
    ProgressBar.superclass.constructor.call(this, opts)
    var size = new geo.Size(272, 32)
    this.contentSize = size
    this.anchorPoint = new geo.Point(0.5, 0.5)

    var s
    if (opts.emptyImage) {
        s = new Sprite({file: opts.emptyImage, rect: new geo.Rect(0, 0, size.width, size.height)})
        s.anchorPoint = new geo.Point(0, 0)
        this.emptySprite = s
        this.addChild({child: s})
    }
    if (opts.fullImage) {
        s = new Sprite({file: opts.fullImage, rect: new geo.Rect(0, 0, 0, size.height)})
        s.anchorPoint = new geo.Point(0, 0)
        this.fullSprite = s
        this.addChild({child: s})
    }

    events.addPropertyListener(this, 'maxValue', 'change', this.updateImages.bind(this))
    events.addPropertyListener(this, 'value',    'change', this.updateImages.bind(this))

    this.updateImages()
}

ProgressBar.inherit(Node, /** @lends cocos.nodes.ProgressBar# */ {
    emptySprite: null,
    fullSprite: null,
    maxValue: 100,
    value: 0,

    updateImages: function () {
        var empty = this.emptySprite,
            full  = this.fullSprite,
            value = this.value,
            size  = this.contentSize,
            maxValue = this.maxValue,
            ratio = (value / maxValue)

        var diff = Math.round(size.width * ratio)
        if (diff === 0) {
            full.visible = false
        } else {
            full.visible = true
            full.rect = new geo.Rect(0, 0, diff, size.height)
            full.contentSize = new geo.Size(diff, size.height)
        }

        if ((size.width - diff) === 0) {
            empty.visible = false
        } else {
            empty.visible = true
            empty.rect = new geo.Rect(diff, 0, size.width - diff, size.height)
            empty.position = new geo.Point(diff, 0)
            empty.contentSize = new geo.Size(size.width - diff, size.height)
        }
    }
})

exports.ProgressBar = ProgressBar

// vim:et:st=4:fdm=marker:fdl=0:fdc=1

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/nodes/ProgressBar.js


__jah__.resources["/libs/cocos2d/nodes/ProgressBarPreloadScene.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

var PreloadScene = require('./PreloadScene').PreloadScene
  , Director    = require('../Director').Director
  , Label       = require('./Label').Label
  , ProgressBar = require('./ProgressBar').ProgressBar
  , Preloader   = require('preloader').Preloader
  , RemoteResource = require('remote_resources').RemoteResource
  , geo         = require('geometry')
  , util        = require('util')
  , events      = require('events')


/**
 * @class
 * PreloadScene that draws a progress bar and 'please wait' message
 *
 * @memberOf cocos.nodes
 * @extends cocos.nodes.PreloadScene
 */
function ProgressBarPreloadScene (opts) {
    ProgressBarPreloadScene.superclass.constructor.call(this, opts)
    var size = Director.sharedDirector.winSize

    // Setup 'please wait' label
    var label = new Label({
        fontSize: 14,
        fontName: 'Helvetica',
        fontColor: '#ffffff',
        string: 'Please wait...'
    })
    label.position = new geo.Point(size.width / 2, (size.height / 2) + 32)
    this.label = label
    this.addChild({child: label})

    // Preloader for the progress bar assets
    var loadingPreloader = new Preloader([this.emptyImage, this.fullImage])

    // When progress bar resources have loaded then draw them and load all the rest
    events.addListener(loadingPreloader, 'complete', function (preloader) {
        this.createProgressBar()
        this.load()
    }.bind(this))

    loadingPreloader.load()
}

ProgressBarPreloadScene.inherit(PreloadScene, /** @lends cocos.nodes.ProgressBarPreloadScene# */ {
    progressBar: null,
    label: null,
    emptyImage: "/libs/cocos2d/resources/progress-bar-empty.png",
    fullImage:  "/libs/cocos2d/resources/progress-bar-full.png",

    createProgressBar: function () {
        var preloader = this.preloader,
            size = Director.sharedDirector.winSize

        var progressBar = new ProgressBar({
            emptyImage: "/libs/cocos2d/resources/progress-bar-empty.png",
            fullImage:  "/libs/cocos2d/resources/progress-bar-full.png"
        })

        progressBar.position = new geo.Point(size.width / 2, size.height / 2)

        this.progressBar = progressBar
        this.addChild({child: progressBar})

        events.addListener(preloader, 'load', function (preloader, uri) {
            progressBar.maxValue = preloader.count
            progressBar.value = preloader.loaded
        })
    }
})

exports.ProgressBarPreloadScene = ProgressBarPreloadScene

// vim:et:st=4:fdm=marker:fdl=0:fdc=1

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/nodes/ProgressBarPreloadScene.js


__jah__.resources["/libs/cocos2d/nodes/RenderTexture.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

var util = require('util'),
    evt = require('events'),
    Node = require('./Node').Node,
    geo = require('geometry'),
    Sprite = require('./Sprite').Sprite,
    TextureAtlas = require('../TextureAtlas').TextureAtlas,
    ccp = geo.ccp

/**
 * @class
 * An in-memory canvas which can be drawn to in the background before drawing on screen
 *
 * @memberOf cocos.nodes
 * @extends cocos.nodes.Node
 *
 * @opt {Integer} width The width of the canvas
 * @opt {Integer} height The height of the canvas
 */
function RenderTexture (opts) {
    RenderTexture.superclass.constructor.call(this, opts)

    var width = opts.width,
        height = opts.height

    evt.addPropertyListener(this, 'contentSize', 'change', this._resizeCanvas.bind(this))

    this.canvas = document.createElement('canvas')
    this.context = this.canvas.getContext('2d')

    var atlas = new TextureAtlas({canvas: this.canvas})
    this.sprite = new Sprite({textureAtlas: atlas, rect: {origin: ccp(0, 0), size: {width: width, height: height}}})

    this.contentSize = geo.sizeMake(width, height)
    this.addChild(this.sprite)
    this.anchorPoint = ccp(0, 0)
    this.sprite.anchorPoint = ccp(0, 0)

}

RenderTexture.inherit(Node, /** @lends cocos.nodes.RenderTexture# */ {
    canvas: null,
    context: null,
    sprite: null,

    /**
     * @private
     */
    _resizeCanvas: function () {
        var size = this.contentSize,
            canvas = this.canvas

        canvas.width  = size.width
        canvas.height = size.height
        if (FLIP_Y_AXIS) {
            this.context.scale(1, -1)
            this.context.translate(0, -canvas.height)
        }

        var s = this.sprite
        if (s) {
            s.textureRect = {rect: geo.rectMake(0, 0, size.width, size.height)}
        }
    },

    /**
     * Clear the canvas
     */
    clear: function (rect) {
        if (rect) {
            this.context.clearRect(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)
        } else {
            this.canvas.width = this.canvas.width
            if (FLIP_Y_AXIS) {
                this.context.scale(1, -1)
                this.context.translate(0, -this.canvas.height)
            }
        }
    }
})

module.exports.RenderTexture = RenderTexture

// vim:et:st=4:fdm=marker:fdl=0:fdc=1

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/nodes/RenderTexture.js


__jah__.resources["/libs/cocos2d/nodes/Scene.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

var Node     = require('./Node').Node
  , Director = require('../Director').Director
  , geo      = require('geometry')


/**
 * @class
 * A Scene defines the entire view. e.g. A welcome screen, settings menu and
 * game world will each be a differen Scene.
 *
 * Your Scene will contain one or more Layers which build up the user interface.
 *
 * Only one Scene can be visible at a time but you can swap between them when
 * you need to show different components of the application. Think of them like
 * full screen windows. Only the active Scene will receive calls to draw itself.
 *
 * @example
 * var scene = new Scene()
 *   , layer = new Layer()
 * scene.addChild(layer)
 * Director.sharedDirector.runWithScene(scene)
 *
 * @memberOf cocos.nodes
 * @extends cocos.nodes.Node
 */
function Scene () {
    Scene.superclass.constructor.call(this)

    var s = Director.sharedDirector.winSize

    this.isRelativeAnchorPoint = false
    this.anchorPoint = new geo.Point(0.5, 0.5)
    this.contentSize = s
}

Scene.inherit(Node)

module.exports.Scene = Scene

// vim:et:st=4:fdm=marker:fdl=0:fdc=1

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/nodes/Scene.js


__jah__.resources["/libs/cocos2d/nodes/Sprite.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

var util = require('util')
  , evt  = require('events')
  , geo  = require('geometry')
  , ccp  = geo.ccp

var Director         = require('../Director').Director
  , SpriteFrameCache = require('../SpriteFrameCache').SpriteFrameCache
  , TextureAtlas     = require('../TextureAtlas').TextureAtlas
  , Node             = require('./Node').Node

/**
 * @class
 * A 2D graphic that can be animated
 *
 * @memberOf cocos.nodes
 * @extends cocos.nodes.Node
 *
 * @opt {String} file Path to image to use as sprite atlas
 * @opt {Rect} [rect] The rect in the sprite atlas image file to use as the sprite
 */
function Sprite (opts) {
    Sprite.superclass.constructor.call(this, opts)

    opts = opts || {}

    var file         = opts.file
      , textureAtlas = opts.textureAtlas
      , texture      = opts.texture
      , frame        = opts.frame
      , spritesheet  = opts.spritesheet
      , rect         = opts.rect
      , frameName    = opts.frameName

    this.anchorPoint = ccp(0.5, 0.5)

    this.offsetPosition = ccp(0, 0)
    this.unflippedOffsetPositionFromCenter = ccp(0, 0)

    if (frameName) {
        frame = SpriteFrameCache.sharedSpriteFrameCache.getSpriteFrame(frameName)
    }

    if (frame) {
        texture = frame.texture
        rect    = frame.rect
    }

    evt.addListener(this, 'dirtytransform', this._updateQuad.bind(this))
    evt.addPropertyListener(this, 'textureAtlas', 'change', this._updateTextureQuad.bind(this))

    if (file || texture) {
        textureAtlas = new TextureAtlas({file: file, texture: texture})
    } else if (spritesheet) {
        textureAtlas = spritesheet.textureAtlas
        this.useSpriteSheet = true
    } else if (!textureAtlas) {
        //throw "Sprite has no texture"
    }

    if (!rect && textureAtlas) {
        rect = new geo.Rect(0, 0, textureAtlas.texture.size.width, textureAtlas.texture.size.height)
    }

    if (rect) {
        this.rect = rect
        this.contentSize = rect.size

        this.quad = { drawRect: {origin: ccp(0, 0), size: rect.size}
                    , textureRect: rect
                    }
    }

    this.textureAtlas = textureAtlas

    if (frame) {
        this.displayFrame = frame
    }
}

Sprite.inherit(Node, /** @lends cocos.nodes.Sprite# */{
    textureAtlas: null
  , dirty: true
  , recursiveDirty: true
  , quad: null
  , flipX: false
  , flipY: false
  , offsetPosition: null
  , unflippedOffsetPositionFromCenter: null
  , untrimmedSize: null

    /**
     * The rectangle area in the source image where the sprite is
     * @type geometry.Rect
     */
  , get rect ()  { return this._rect }
  , set rect (x) { this._rect = x; evt.trigger(this, 'dirtytransform', {target: this, property: 'rect'}) }
  , _rect: null

    /**
     * @private
     */
  , _updateTextureQuad: function (obj, key, texture, oldTexture) {
        if (oldTexture) {
            oldTexture.removeQuad({quad: this.quad})
        }

        if (texture) {
            texture.insertQuad({quad: this.quad})
        }
    }

    /**
     * @type geometry.Rect
     */
  , set textureCoords (rect) {
        var quad = this.quad
        if (!quad) {
            quad = {
                drawRect: geo.rectMake(0, 0, 0, 0), 
                textureRect: geo.rectMake(0, 0, 0, 0)
            }
        }

        quad.textureRect = util.copy(rect)

        this.quad = quad
    }

    /**
     * @type geometry.Rect
     */
  , set textureRect (opts) {
        var rect = opts.rect
          , rotated = !!opts.rotated
          , untrimmedSize = opts.untrimmedSize || rect.size

        this.contentSize = untrimmedSize
        this.rect = util.copy(rect)
        this.textureCoords = rect

        var quad = this.quad

        var relativeOffset = util.copy(this.unflippedOffsetPositionFromCenter)

        if (this.flipX) {
            relativeOffset.x = -relativeOffset.x
        }
        if (this.flipY) {
            relativeOffset.y = -relativeOffset.y
        }

        var offsetPosition = util.copy(this.offsetPosition)
        offsetPosition.x =  relativeOffset.x + (this.contentSize.width  - rect.size.width) / 2
        offsetPosition.y = -relativeOffset.y + (this.contentSize.height - rect.size.height) / 2

        quad.drawRect.origin = util.copy(offsetPosition)
        quad.drawRect.size = util.copy(rect.size)
        if (this.flipX) {
            quad.drawRect.size.width *= -1
            quad.drawRect.origin.x = -rect.size.width
        }
        if (this.flipY) {
            quad.drawRect.size.height *= -1
            quad.drawRect.origin.y = -rect.size.height
        }

        this.quad = quad
    }

    /**
     * @private
     */
  , _updateQuad: function () {
        if (!this.rect) {
            return
        }
        if (!this.quad) {
            this.quad = { drawRect: geo.rectMake(0, 0, 0, 0)
                        , textureRect: geo.rectMake(0, 0, 0, 0)
                        }
        }

        var relativeOffset = util.copy(this.unflippedOffsetPositionFromCenter)

        if (this.flipX) {
            relativeOffset.x = -relativeOffset.x
        }
        if (this.flipY) {
            relativeOffset.y = -relativeOffset.y
        }

        var offsetPosition = util.copy(this.offsetPosition)
        offsetPosition.x = relativeOffset.x + (this.contentSize.width  - this.rect.size.width) / 2
        offsetPosition.y = relativeOffset.y + (this.contentSize.height - this.rect.size.height) / 2

        this.quad.textureRect = util.copy(this.rect)
        this.quad.drawRect.origin = util.copy(offsetPosition)
        this.quad.drawRect.size = util.copy(this.rect.size)

        if (this.flipX) {
            this.quad.drawRect.size.width *= -1
            this.quad.drawRect.origin.x = -this.rect.size.width
        }
        if (this.flipY) {
            this.quad.drawRect.size.height *= -1
            this.quad.drawRect.origin.y = -this.rect.size.height
        }
    }

  , updateTransform: function (ctx) {
        if (!this.useSpriteSheet) {
            throw "updateTransform is only valid when Sprite is being rendered using a SpriteSheet"
        }

        if (!this.visible) {
            this.dirty = false
            this.recursiveDirty = false
            return
        }

        // TextureAtlas has hard reference to this quad so we can just update it directly
        this.quad.drawRect.origin = new geo.Point( this.position.x - this.anchorPointInPixels.x * this.scaleX
                                                 , this.position.y - this.anchorPointInPixels.y * this.scaleY
                                                 )
        this.quad.drawRect.size = new geo.Size( this.rect.size.width * this.scaleX
                                              , this.rect.size.height * this.scaleY
                                              )

        this.dirty = false
        this.recursiveDirty = false
    }

  , draw: function (ctx) {
        if (!this.quad) {
            return
        }
        this.textureAtlas.drawQuad(ctx, this.quad)
    }

  , isFrameDisplayed: function (frame) {
        if (!this.rect || !this.textureAtlas) {
            return false
        }
        return (frame.texture === this.textureAtlas.texture && geo.rectEqualToRect(frame.rect, this.rect))
    }


    /**
     * @type cocos.SpriteFrame
     */
  , set displayFrame (frame) {
        if (!frame) {
            delete this.quad
            return
        }
        this.unflippedOffsetPositionFromCenter = util.copy(frame.offset)

        // change texture
        if (!this.textureAtlas || frame.texture !== this.textureAtlas.texture) {
            this.textureAtlas = new TextureAtlas({texture: frame.texture})
        }

        this.textureRect = {rect: frame.rect, rotated: frame.rotated, untrimmedSize: frame.originalSize}
    }
})

module.exports.Sprite = Sprite

// vim:et:st=4:fdm=marker:fdl=0:fdc=1

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/nodes/Sprite.js


__jah__.resources["/libs/cocos2d/nodes/TMXLayer.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

var util = require('util'),
    events = require('events'),
    SpriteBatchNode = require('./BatchNode').SpriteBatchNode,
    Sprite = require('./Sprite').Sprite,
    TMXOrientationOrtho = require('../TMXOrientation').TMXOrientationOrtho,
    TMXOrientationHex   = require('../TMXOrientation').TMXOrientationHex,
    TMXOrientationIso   = require('../TMXOrientation').TMXOrientationIso,
    geo    = require('geometry'),
    ccp    = geo.ccp,
    Node = require('./Node').Node



var FLIPPED_HORIZONTALLY_FLAG = 0x80000000
  , FLIPPED_VERTICALLY_FLAG   = 0x40000000
  , FLIPPED_DIAGONALLY_FLAG   = 0x20000000

/**
 * @class
 * A tile map layer loaded from a TMX file. This will probably automatically be made by cocos.TMXTiledMap
 *
 * @memberOf cocos.nodes
 * @extends cocos.nodes.SpriteBatchNode
 *
 * @opt {cocos.TMXTilesetInfo} tilesetInfo
 * @opt {cocos.TMXLayerInfo} layerInfo
 * @opt {cocos.TMXMapInfo} mapInfo
 */
function TMXLayer (opts) {
    var tilesetInfo = opts.tilesetInfo,
        layerInfo = opts.layerInfo,
        mapInfo = opts.mapInfo

    var size = layerInfo.layerSize,
        totalNumberOfTiles = size.width * size.height

    var tex = null
    if (tilesetInfo) {
        tex = tilesetInfo.sourceImage
    }

    TMXLayer.superclass.constructor.call(this, {file: tex})

    this.anchorPoint = ccp(0, 0)

    this.layerName = layerInfo.name
    this.layerSize = layerInfo.layerSize
    this.tiles = layerInfo.tiles
    this.minGID = layerInfo.minGID
    this.maxGID = layerInfo.maxGID
    this.opacity = layerInfo.opacity
    this.properties = util.copy(layerInfo.properties)

    this.tileset = tilesetInfo
    this.mapTileSize = mapInfo.tileSize
    this.layerOrientation = mapInfo.orientation

    var offset = this.calculateLayerOffset(layerInfo.offset)
    this.position = offset

    this.contentSize = new geo.Size(this.layerSize.width * this.mapTileSize.width, (this.layerSize.height * this.mapTileSize.height) + this.tileset.tileSize.height)
}

TMXLayer.inherit(SpriteBatchNode, /** @lends cocos.nodes.TMXLayer# */ {
    layerSize: null,
    layerName: '',
    tiles: null,
    tilset: null,
    layerOrientation: 0,
    mapTileSize: null,
    properties: null,

    calculateLayerOffset: function (pos) {
        var ret = ccp(0, 0)

        switch (this.layerOrientation) {
        case TMXOrientationOrtho:
            ret = ccp(pos.x * this.mapTileSize.width, pos.y * this.mapTileSize.height)
            break
        case TMXOrientationIso:
            // TODO
            break
        case TMXOrientationHex:
            // TODO
            break
        }

        return ret
    },

    setupTiles: function () {
        events.addPropertyListener(this.texture, 'contentSize', 'change', function (e) {
            this.tileset.imageSize = this.texture.contentSize
        }.bind(this))
        this.tileset.imageSize = this.texture.contentSize

        this.parseInternalProperties()

        for (var y = 0; y < this.layerSize.height; y++) {
            for (var x = 0; x < this.layerSize.width; x++) {

                var pos = x + this.layerSize.width * y
                  , gid = this.tiles[pos]
                  , flipH = gid & FLIPPED_HORIZONTALLY_FLAG
                  , flipV = gid & FLIPPED_VERTICALLY_FLAG
                  , flipD = gid & FLIPPED_DIAGONALLY_FLAG

                // Remove flip flags
                gid &= ~( FLIPPED_HORIZONTALLY_FLAG
                        | FLIPPED_VERTICALLY_FLAG
                        | FLIPPED_DIAGONALLY_FLAG
                        )


                if (gid !== 0) {
                    this.appendTile({ gid: gid
                                    , position: new geo.Point(x, y)
                                    , flipH: flipH
                                    , flipV: flipV
                                    , flipD: flipD
                                    })

                    // Optimization: update min and max GID rendered by the layer
                    this.minGID = Math.min(gid, this.minGID)
                    this.maxGID = Math.max(gid, this.maxGID)
                }
            }
        }
    },

    propertyNamed: function (name) {
        return this.properties[name]
    },

    parseInternalProperties: function () {
        var vertexz = this.properties.cc_vertexz

        if (vertexz) {
            if (vertexz === 'automatic') {
                this._useAutomaticVertexZ = true
            } else {
                this._vertexZvalue = parseInt(vertexz, 10)
            }
        }
    },

    appendTile: function (opts) {
        var gid = opts.gid,
            pos = opts.position

        var z = pos.x + pos.y * this.layerSize.width

        var rect = this.tileset.rectForGID(gid)
        var tile = new Sprite({rect: rect, textureAtlas: this.textureAtlas})
        tile.position = this.positionAt(pos)
        tile.opacity = this.opacity

        var anchorX = 0
          , anchorY = 0
        if (opts.flipH) {
            tile.scaleX = -1
            anchorX = 1
        }
        if (opts.flipV) {
            tile.scaleY = -1
            anchorY = 1
        }
        if (opts.flipD) {
            console.warn("Diagonal flipped tiles are unsupported")
        }

        tile.anchorPoint = new geo.Point(anchorX, anchorY)

        this.addChild({ child: tile
                      , z: this.vertexZForPos(pos)
                      , tag: z
                      })

        return tile
    },
    positionAt: function (pos) {
        switch (this.layerOrientation) {
        case TMXOrientationOrtho:
            return this.positionForOrthoAt(pos)
        case TMXOrientationIso:
            return this.positionForIsoAt(pos)
        /*
        case TMXOrientationHex:
            // TODO
        */
        default:
            return ccp(0, 0)
        }
    },

    vertexZForPos: function (pos) {
        var maxVal = 0
        if (this._useAutomaticVertexZ) {
            switch (this.layerOrientation) {
            case TMXOrientationIso:
                maxVal = this.layerSize.width + this.layerSize.height
                return -(maxVal - (pos.x + pos.y))
            case TMXOrientationOrtho:
                return -(this.layerSize.height - pos.y)
            case CCTMXOrientationHex:
                throw new Error("TMX Hexa zOrder not supported")
            default:
                throw new Error("TMX invalid value")
            }
        } else {
            return this._vertexZvalue
        }
    },

    positionForOrthoAt: function (pos) {
        var overlap = this.mapTileSize.height - this.tileset.tileSize.height
        var x = Math.floor(pos.x * this.mapTileSize.width + 0.49)
        var y
        if (FLIP_Y_AXIS) {
            y = Math.floor((this.layerSize.height - pos.y - 1) * this.mapTileSize.height + 0.49)
        } else {
            y = Math.floor(pos.y * this.mapTileSize.height + 0.49) + overlap
        }
        return ccp(x, y)
    },

    positionForIsoAt: function (pos) {
        var mapTileSize = this.mapTileSize,
            layerSize = this.layerSize

        if (FLIP_Y_AXIS) {
            return ccp(
                mapTileSize.width  / 2 * (layerSize.width + pos.x - pos.y - 1),
                mapTileSize.height / 2 * ((layerSize.height * 2 - pos.x - pos.y) - 2)
            )
        } else {
            throw "Isometric tiles without FLIP_Y_AXIS is currently unsupported"
        }
    },

    /**
     * Get the tile at a specifix tile coordinate
     *
     * @param {geometry.Point} pos Position of tile to get in tile coordinates (not pixels)
     * @returns {cocos.nodes.Sprite} The tile
     */
    tileAt: function (pos) {
        var layerSize = this.layerSize,
            tiles = this.tiles

        if (pos.x < 0 || pos.y < 0 || pos.x >= layerSize.width || pos.y >= layerSize.height) {
            throw "TMX Layer: Invalid position"
        }

        var tile,
            gid = this.tileGIDAt(pos)

        // if GID is 0 then no tile exists at that point
        if (gid) {
            var z = pos.x + pos.y * layerSize.width
            tile = this.getChild({tag: z})
        }

        return tile
    },


    tileGID: function (pos) {
        var tilesPerRow = this.layerSize.width,
            tilePos = pos.x + (pos.y * tilesPerRow)

        return this.tiles[tilePos]
    },
    tileGIDAt: function (pos) {
        return this.tileGID(pos)
    },

    removeTile: function (pos) {
        var gid = this.tileGID(pos)
        if (gid === 0) {
            // Tile is already blank
            return
        }

        var tiles = this.tiles,
            tilesPerRow = this.layerSize.width,
            tilePos = pos.x + (pos.y * tilesPerRow)


        tiles[tilePos] = 0

        var sprite = this.getChild({tag: tilePos})
        if (sprite) {
            this.removeChild({child: sprite})
        }
    }
})

exports.TMXLayer = TMXLayer

// vim:et:st=4:fdm=marker:fdl=0:fdc=1

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/nodes/TMXLayer.js


__jah__.resources["/libs/cocos2d/nodes/TMXTiledMap.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

var util = require('util'),
    geo = require('geometry'),
    ccp = geo.ccp,
    Node = require('./Node').Node,
    TMXOrientationOrtho = require('../TMXOrientation').TMXOrientationOrtho,
    TMXOrientationHex   = require('../TMXOrientation').TMXOrientationHex,
    TMXOrientationIso   = require('../TMXOrientation').TMXOrientationIso,
    TMXLayer   = require('./TMXLayer').TMXLayer,
    TMXMapInfo = require('../TMXXMLParser').TMXMapInfo

/**
 * @class
 * A TMX Map loaded from a .tmx file
 *
 * @memberOf cocos.nodes
 * @extends cocos.nodes.Node
 *
 * @opt {String} file The file path of the TMX map to load
 */
function TMXTiledMap (opts) {
    TMXTiledMap.superclass.constructor.call(this, opts)

    this.anchorPoint = ccp(0, 0)

    var mapInfo = new TMXMapInfo(opts.file)

    this.mapSize        = mapInfo.mapSize
    this.tileSize       = mapInfo.tileSize
    this.mapOrientation = mapInfo.orientation
    this.objectGroups   = mapInfo.objectGroups
    this.properties     = mapInfo.properties
    this.tileProperties = mapInfo.tileProperties

    // Add layers to map
    var idx = 0
    mapInfo.layers.forEach(function (layerInfo) {
        if (layerInfo.visible) {
            var child = this.parseLayer({layerInfo: layerInfo, mapInfo: mapInfo})
            this.addChild({child: child, z: idx, tag: idx})

            var childSize   = child.contentSize
            var currentSize = this.contentSize
            currentSize.width  = Math.max(currentSize.width,  childSize.width)
            currentSize.height = Math.max(currentSize.height, childSize.height)
            this.contentSize = currentSize

            idx++
        }
    }.bind(this))
}


TMXTiledMap.inherit(Node, /** @lends cocos.nodes.TMXTiledMap# */ {
    mapSize: null,
    tileSize: null,
    mapOrientation: 0,
    objectGroups: null,
    properties: null,
    tileProperties: null,

    parseLayer: function (opts) {
        var tileset = this.tilesetForLayer(opts)
        var layer = new TMXLayer({tilesetInfo: tileset, layerInfo: opts.layerInfo, mapInfo: opts.mapInfo})

        layer.setupTiles()

        return layer
    },

    tilesetForLayer: function (opts) {
        var layerInfo = opts.layerInfo,
            mapInfo = opts.mapInfo,
            size = layerInfo.layerSize

        // Reverse loop
        var tileset
        for (var i = mapInfo.tilesets.length - 1; i >= 0; i--) {
            tileset = mapInfo.tilesets[i]

            for (var y = 0; y < size.height; y++) {
                for (var x = 0; x < size.width; x++) {
                    var pos = x + size.width * y,
                        gid = layerInfo.tiles[pos]

                    if (gid !== 0 && gid >= tileset.firstGID) {
                        return tileset
                    }
                } // for (var x
            } // for (var y
        } // for (var i

        //console.log("cocos2d: Warning: TMX Layer '%s' has no tiles", layerInfo.name)
        return tileset
    },

    /**
     * Get a layer
     *
     * @opt {String} name The name of the layer to get
     * @returns {cocos.nodes.TMXLayer} The layer requested
     */
    getLayer: function (opts) {
        var layerName = opts.name,
            layer = null

        this.children.forEach(function (item) {
            if (item instanceof TMXLayer && item.layerName == layerName) {
                layer = item
            }
        })
        if (layer !== null) {
            return layer
        }
    },

    /**
     * Return the ObjectGroup for the secific group
     *
     * @opt {String} name The object group name
     * @returns {cocos.TMXObjectGroup} The object group
     */
    getObjectGroup: function (opts) {
        var objectGroupName = opts.name,
            objectGroup = null

        this.objectGroups.forEach(function (item) {
            if (item.name == objectGroupName) {
                objectGroup = item
            }
        })
        if (objectGroup !== null) {
            return objectGroup
        }
    },

    /**
     * @deprected Since v0.2. You should now use cocos.TMXTiledMap#getObjectGroup.
     */
    objectGroupNamed: function (opts) {
        console.warn('TMXTiledMap#objectGroupNamed is deprected. Use TMXTiledMap#getObjectGroup instread')
        return this.getObjectGroup(opts)
    }
})

exports.TMXTiledMap = TMXTiledMap


}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/nodes/TMXTiledMap.js


__jah__.resources["/libs/cocos2d/nodes/Transition.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

var geo             = require('geometry'),
    util            = require('util'),
    actions         = require('../actions')

var Scene           = require('./Scene').Scene,
    Director        = require('../Director').Director,
    EventDispatcher = require('../EventDispatcher').EventDispatcher,
    Scheduler       = require('../Scheduler').Scheduler

/** @ignore
 * Orientation Type used by some transitions
 */
var tOrientation = {
    kOrientationLeftOver: 0,
    kOrientationRightOver: 1,
    kOrientationUpOver: 0,
    kOrientationDownOver: 1
}

/**
 * @class
 * Base class for Transition scenes
 *
 * @memberOf cocos.nodes
 * @extends cocos.nodes.Scene
 *
 * @opt {Float} duration How long the transition should last
 * @opt {cocos.nodes.Scene} scene Income scene
 */
function TransitionScene (opts) {
    TransitionScene.superclass.constructor.call(this, opts)

    this.duration = opts.duration
    if (!opts.scene) {
        throw "TransitionScene requires scene property"
    }
    this.inScene = opts.scene
    this.outScene = Director.sharedDirector._runningScene

    if (this.inScene == this.outScene) {
        throw "Incoming scene must be different from the outgoing scene"
    }
    EventDispatcher.sharedDispatcher.dispatchEvents = false
    this.sceneOrder()
}

TransitionScene.inherit(Scene, /** @lends cocos.nodes.TransitionScene# */ {
    /**
     * Incoming scene
     * @type {cocos.nodes.Scene}
     */
    inScene: null,

    /**
     * Outgoing (current) scene
     * @type {cocos.nodes.Scene}
     */
    outScene: null,

    /**
     * transition duration
     * @type Float
     */
    duration: null,

    inSceneOnTop: null,
    sendCleanupToScene: null,

    /**
     * Called after the transition finishes
     */
    finish: function () {
        var is = this.inScene,
            os = this.outScene

        /* clean up */
        is.visible = true
        is.position = geo.PointZero()
        is.scale = 1.0
        is.rotation = 0

        os.visible = false
        os.position = geo.PointZero()
        os.scale = 1.0
        os.rotation = 0

        Scheduler.sharedScheduler.schedule({
            target: this,
            method: this.setNewScene,
            interval: 0
        })
    },

    /**
     * Used by some transitions to hide the outer scene
     */
    hideOutShowIn: function () {
        this.inScene.visible = true
        this.outScene.visible = false
    },

    setNewScene: function (dt) {
        var dir = Director.sharedDirector

        this.unscheduleSelector(this.setNewScene)
        // Save 'send cleanup to scene'
        // Not sure if it's cool to be accessing all these Director privates like this...
        this.sendCleanupToScene = dir._sendCleanupToScene

        dir.replaceScene(this.inScene)

        // enable events while transitions
        EventDispatcher.sharedDispatcher.dispatchEvents = true

        // issue #267
        this.outScene.visible = true
    },

    sceneOrder: function () {
        this.inSceneOnTop = true
    },

    draw: function (context, rect) {
        if (this.inSceneOnTop) {
            this.outScene.visit(context, rect)
            this.inScene.visit(context, rect)
        } else {
            this.inScene.visit(context, rect)
            this.outScene.visit(context, rect)
        }
    },

    onEnter: function () {
        TransitionScene.superclass.onEnter.call(this)
        this.inScene.onEnter()
        // outScene_ should not receive the onEnter callback
    },

    onExit: function () {
        TransitionScene.superclass.onExit.call(this)
        this.outScene.onExit()
        // inScene_ should not receive the onExit callback
        // only the onEnterTransitionDidFinish
        if (this.inScene.hasOwnProperty('onEnterTransitionDidFinish')) {
            this.inScene.onEnterTransitionDidFinish()
        }
    },

    cleanup: function () {
        TransitionScene.superclass.cleanup.call(this)

        if (this.sendCleanupToScene) {
            this.outScene.cleanup()
        }
    }
})

/**
 * @class
 * Rotate and zoom out the outgoing scene, and then rotate and zoom in the incoming
 *
 * @memberOf cocos.nodes
 * @extends cocos.nodes.TransitionScene
 */
function TransitionRotoZoom (opts) {
    TransitionRotoZoom.superclass.constructor.call(this, opts)
}

TransitionRotoZoom.inherit(TransitionScene, /** @lends cocos.nodes.TransitionRotoZoom# */ {
    onEnter: function() {
        TransitionRotoZoom.superclass.onEnter.call(this)

        var dur = this.duration
        this.inScene.scale = 0.001
        this.outScene.scale = 1.0

        this.inScene.anchorPoint = geo.ccp(0.5, 0.5)
        this.outScene.anchorPoint = geo.ccp(0.5, 0.5)

        var outzoom = [
            new actions.Spawn({actions: [
                new actions.ScaleBy({scale: 0.001, duration: dur/2}),
                new actions.RotateBy({angle: 360*2, duration: dur/2})
                ]}),
            new actions.DelayTime({duration: dur/2})]

        // Can't nest sequences or reverse them very easily, so incoming scene actions must be put
        // together manually for now...
        var inzoom = [
            new actions.DelayTime({duration: dur/2}),

            new actions.Spawn({actions: [
                new actions.ScaleTo({scale: 1.0, duration: dur/2}),
                new actions.RotateBy({angle: -360*2, duration: dur/2})
                ]}),
            new actions.CallFunc({
                target: this,
                method: this.finish
            })
        ]

        // Sequence init() copies actions
        this.outScene.runAction(new actions.Sequence({actions: outzoom}))
        this.inScene.runAction(new actions.Sequence({actions: inzoom}))
    }
})

/**
 * @class
 * Move in from to the left the incoming scene.
 *
 * @memberOf cocos.nodes
 * @extends cocos.nodes.TransitionScene
 */
function TransitionMoveInL (opts) {
    TransitionMoveInL.superclass.constructor.call(this, opts)
}

TransitionMoveInL.inherit(TransitionScene, /** @lends cocos.nodes.TransitionMoveInL# */ {
    onEnter: function () {
        TransitionMoveInL.superclass.onEnter.call(this)

        this.initScenes()

        this.inScene.runAction(new actions.Sequence({actions: [
            this.action(),
            new actions.CallFunc({
                target: this,
                method: this.finish
            })]
        }))
    },

    action: function () {
        return new actions.MoveTo({
            position: geo.ccp(0, 0),
            duration: this.duration
        })
    },

    initScenes: function () {
        var s = Director.sharedDirector.winSize
        this.inScene.position = geo.ccp(-s.width, 0)
    }
})

/**
 * @class
 * Move in from to the right the incoming scene.
 *
 * @memberOf cocos.nodes
 * @extends cocos.nodes.TransitionMoveInL
 */
function TransitionMoveInR (opts) {
    TransitionMoveInR.superclass.constructor.call(this, opts)
}

TransitionMoveInR.inherit(TransitionMoveInL, /** @lends cocos.nodes.TransitionMoveInR# */ {
    initScenes: function () {
        var s = Director.sharedDirector.winSize
        this.inScene.position = geo.ccp(s.width, 0)
    }
})

/**
 * @class
 * Move the incoming scene in from the top.
 *
 * @memberOf cocos.nodes
 * @extends cocos.nodes.TransitionMoveInL
 */
function TransitionMoveInT (opts) {
    TransitionMoveInT.superclass.constructor.call(this, opts)
}

TransitionMoveInT.inherit(TransitionMoveInL, /** @lends cocos.nodes.TransitionMoveInT# */ {
    initScenes: function () {
        var s = Director.sharedDirector.winSize
        this.inScene.position = geo.ccp(0, s.height)
    }
})

/**
 * @class
 * Move the incoming scene in from the bottom.
 *
 * @memberOf cocos.nodes
 * @extends cocos.nodes.TransitionMoveInL
 */
function TransitionMoveInB (opts) {
    TransitionMoveInB.superclass.constructor.call(this, opts)
}

TransitionMoveInB.inherit(TransitionMoveInL, /** @lends cocos.nodes.TransitionMoveInB# */ {
    initScenes: function () {
        var s = Director.sharedDirector.winSize
        this.inScene.position = geo.ccp(0, -s.height)
    }
})

/**
 * @class
 * Slide in the incoming scene from the left.
 *
 * @memberOf cocos.nodes
 * @extends cocos.nodes.TransitionScene
 */
function TransitionSlideInL (opts) {
    TransitionSlideInL.superclass.constructor.call(this, opts)
}

TransitionSlideInL.inherit(TransitionScene, /** @lends cocos.nodes.TransitionSlideInL# */ {
    onEnter: function () {
        TransitionSlideInL.superclass.onEnter.call(this)

        this.initScenes()

        var movein = this.action()
        var moveout = this.action()
        var outAction = new actions.Sequence({
            actions: [
            moveout,
            new actions.CallFunc({
                target: this,
                method: this.finish
            })]
        })
        this.inScene.runAction(movein)
        this.outScene.runAction(outAction)
    },

    sceneOrder: function () {
        this.inSceneOnTop = false
    },

    initScenes: function () {
        var s = Director.sharedDirector.winSize
        this.inScene.position = geo.ccp(-s.width, 0)
    },

    action: function () {
        var s = Director.sharedDirector.winSize
        return new actions.MoveBy({
            position: geo.ccp(s.width, 0),
            duration: this.duration
        })
    }
})

/**
 * @class
 * Slide in the incoming scene from the right.
 *
 * @memberOf cocos.nodes
 * @extends cocos.nodes.TransitionSlideInL
 */
function TransitionSlideInR (opts) {
    TransitionSlideInR.superclass.constructor.call(this, opts)
}

TransitionSlideInR.inherit(TransitionSlideInL, /** @lends cocos.nodes.TransitionSlideInR# */ {
    sceneOrder: function () {
        this.inSceneOnTop = true
    },

    initScenes: function () {
        var s = Director.sharedDirector.winSize
        this.inScene.position = geo.ccp(s.width, 0)
    },

    action: function () {
        var s = Director.sharedDirector.winSize
        return new actions.MoveBy({
            position: geo.ccp(-s.width, 0),
            duration: this.duration
        })
    }
})

/**
 * @class
 * Slide in the incoming scene from the top.
 *
 * @memberOf cocos.nodes
 * @extends cocos.nodes.TransitionSlideInL
 */
function TransitionSlideInT (opts) {
    TransitionSlideInT.superclass.constructor.call(this, opts)
}

TransitionSlideInT.inherit(TransitionSlideInL, /** @lends cocos.nodes.TransitionSlideInT# */ {
    sceneOrder: function () {
        this.inSceneOnTop = false
    },

    initScenes: function () {
        var s = Director.sharedDirector.winSize
        this.inScene.position = geo.ccp(0, s.height)
    },

    action: function () {
        var s = Director.sharedDirector.winSize
        return new actions.MoveBy({
            position: geo.ccp(0, -s.height),
            duration: this.duration
        })
    }
})

/**
 * @class
 * Slide in the incoming scene from the bottom.
 *
 * @memberOf cocos.nodes
 * @extends cocos.nodes.TransitionSlideInL
 */
function TransitionSlideInB (opts) {
    TransitionSlideInB.superclass.constructor.call(this, opts)
}

TransitionSlideInB.inherit(TransitionSlideInL, /** @lends cocos.nodes.TransitionSlideInB# */ {
    sceneOrder: function () {
        this.inSceneOnTop = true
    },

    initScenes: function () {
        var s = Director.sharedDirector.winSize
        this.inScene.position = geo.ccp(0, -s.height)
    },

    action: function () {
        var s = Director.sharedDirector.winSize
        return new actions.MoveBy({
            position: geo.ccp(0, s.height),
            duration: this.duration
        })
    }
})

exports.TransitionScene = TransitionScene
exports.TransitionRotoZoom = TransitionRotoZoom
exports.TransitionMoveInL = TransitionMoveInL
exports.TransitionMoveInR = TransitionMoveInR
exports.TransitionMoveInT = TransitionMoveInT
exports.TransitionMoveInB = TransitionMoveInB
exports.TransitionSlideInL = TransitionSlideInL
exports.TransitionSlideInR = TransitionSlideInR
exports.TransitionSlideInT = TransitionSlideInT
exports.TransitionSlideInB = TransitionSlideInB

// vim:et:st=4:fdm=marker:fdl=0:fdc=1

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/nodes/Transition.js


__jah__.resources["/libs/cocos2d/remote_resources_patch.js"] = {data: function (exports, require, module, __filename, __dirname) {
var remote_resources = require('remote_resources')
  , RemoteFont = require('./RemoteFont').RemoteFont

var originalGetRemoteResourceConstructor = remote_resources.getRemoteResourceConstructor

remote_resources.getRemoteResourceConstructor = function (mimetype) {
    var RemoteObj
    if (/\bfont\b/.test(mimetype)) {
        RemoteObj = RemoteFont
    } else {
        RemoteObj = originalGetRemoteResourceConstructor(mimetype)
    }

    return RemoteObj
}

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/remote_resources_patch.js


__jah__.resources["/libs/cocos2d/RemoteFont.js"] = {data: function (exports, require, module, __filename, __dirname) {
var events = require('events')
  , remote_resources = require('remote_resources')

var fontTestElement
  , ctx
/**
 * Very crude way to test for when a font has loaded
 *
 * While a font is loading they will be drawn as blank onto a canvas.
 * This function  creates a small canvas and tests the pixels to see if the
 * given font draws. If it does then we can assume the font loaded.
 */
function hasFontLoaded (window, fontName) {
    var testSize = 16
    if (!fontTestElement) {
        fontTestElement = window.document.createElement('canvas')
        fontTestElement.width = testSize
        fontTestElement.height = testSize
        fontTestElement.style.display = 'none'

        ctx = fontTestElement.getContext('2d')
        window.document.body.appendChild(fontTestElement)
    }

    fontTestElement.width = testSize
    ctx.fillStyle = 'rgba(0, 0, 0, 0)'
    ctx.fillRect(0, 0, testSize, testSize)
    ctx.font = testSize + "px __cc2d_" + fontName
    ctx.fillStyle = 'rgba(255, 255, 255, 1)'
    ctx.fillText("M", 0, testSize);

    var pixels = ctx.getImageData(0, 0, testSize, testSize).data

    for (var i = 0; i < testSize * testSize; i++) {
        if (pixels[i * 4] != 0) {
            fontTestElement.parentNode.removeChild(fontTestElement)
            fontTestElement = null
            return true
        }
    }

    return false
}

/**
 * @class
 * @memberOf cocos
 * @extends remote_resources.RemoteResource
 */
function RemoteFont(url, path) {
    remote_resources.RemoteResource.apply(this, arguments)
}

RemoteFont.prototype = Object.create(remote_resources.RemoteResource.prototype)

RemoteFont.prototype.load = function () {
    var window = require('./Director').Director.sharedDirector.window

    var fontName = this.path.split('/').pop().split('.')[0]
    var fontFace = "@font-face { \
                        font-family: '__cc2d_" + fontName + "'; \
                        src: url(" + this.url + "); \
                    }"

    var t = document.createElement('style')
    t.appendChild(document.createTextNode(fontFace))
    window.document.body.appendChild(t)

    var ticker = setInterval(function () {
        if (hasFontLoaded(window, fontName)) {
            __jah__.resources[this.path].loaded = true
            events.trigger(this, 'load', this)
            clearInterval(ticker)
        }
    }.bind(this), 100)
}

exports.RemoteFont = RemoteFont

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/RemoteFont.js


__jah__.resources["/libs/cocos2d/resources/progress-bar-empty.png"] = {data: __jah__.assetURL + "/libs/cocos2d/resources/progress-bar-empty.png", mimetype: "image/png", remote: true};
__jah__.resources["/libs/cocos2d/resources/progress-bar-full.png"] = {data: __jah__.assetURL + "/libs/cocos2d/resources/progress-bar-full.png", mimetype: "image/png", remote: true};
__jah__.resources["/libs/cocos2d/Scheduler.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

var util = require('util')

/** @ignore */
function HashUpdateEntry() {
    this.timers = []
    this.timerIndex = 0
    this.currentTimer = null
    this.currentTimerSalvaged = false
    this.paused = false
}

/** @ignore */
function HashMethodEntry() {
    this.timers = []
    this.timerIndex = 0
    this.currentTimer = null
    this.currentTimerSalvaged = false
    this.paused = false
}

/**
 * @class
 * Runs a function repeatedly at a fixed interval
 *
 * @memberOf cocos
 *
 * @opt {Function} callback The function to run at each interval
 * @opt {Float} interval Number of milliseconds to wait between each exectuion of callback
 */
function Timer (opts) {
    this.callback = opts.callback
    this.interval = opts.interval || 0
    this.elapsed = -1
}

Timer.inherit(Object, /** @lends cocos.Timer# */ {
    callback: null,
    interval: 0,
    elapsed: -1,

    /**
     * @private
     */
    update: function (dt) {
        if (this.elapsed == -1) {
            this.elapsed = 0
        } else {
            this.elapsed += dt
        }

        if (this.elapsed >= this.interval) {
            this.callback(this.elapsed)
            this.elapsed = 0
        }
    }
})

/**
 * @class
 * Runs the timers
 *
 * @memberOf cocos
 *
 * @singleton
 */
function Scheduler () {
    this.updates0 = []
    this.updatesNeg = []
    this.updatesPos = []
    this.hashForUpdates = {}
    this.hashForMethods = {}
}
Scheduler.inherit(Object, /** @lends cocos.Scheduler# */ {
    updates0: null,
    updatesNeg: null,
    updatesPos: null,
    hashForUpdates: null,
    hashForMethods: null,
    timeScale: 1.0,

    /**
     * The scheduled method will be called every 'interval' seconds.
     * If paused is YES, then it won't be called until it is resumed.
     * If 'interval' is 0, it will be called every frame, but if so, it recommened to use 'scheduleUpdateForTarget:' instead.
     * If the selector is already scheduled, then only the interval parameter will be updated without re-scheduling it again.
     */
    schedule: function (opts) {
        var target   = opts.target,
            method   = (typeof opts.method == 'function') ? opts.method : target[opts.method],
            interval = opts.interval,
            paused   = opts.paused || false

        var element = this.hashForMethods[target.id]

        if (!element) {
            element = new HashMethodEntry()
            this.hashForMethods[target.id] = element
            element.target = target
            element.paused = paused
        } else if (element.paused != paused) {
            throw "cocos.Scheduler. Trying to schedule a method with a pause value different than the target"
        }

        var timer = new Timer({callback: method.bind(target), interval: interval})
        element.timers.push(timer)
    },

    /**
     * Schedules the 'update' selector for a given target with a given priority.
     * The 'update' selector will be called every frame.
     * The lower the priority, the earlier it is called.
     */
    scheduleUpdate: function (opts) {
        var target   = opts.target,
            priority = opts.priority,
            paused   = opts.paused

        var i, len
        var entry = {target: target, priority: priority, paused: paused}
        var added = false

        if (priority === 0) {
            this.updates0.push(entry)
        } else if (priority < 0) {
            for (i = 0, len = this.updatesNeg.length; i < len; i++) {
                if (priority < this.updatesNeg[i].priority) {
                    this.updatesNeg.splice(i, 0, entry)
                    added = true
                    break
                }
            }

            if (!added) {
                this.updatesNeg.push(entry)
            }
        } else /* priority > 0 */{
            for (i = 0, len = this.updatesPos.length; i < len; i++) {
                if (priority < this.updatesPos[i].priority) {
                    this.updatesPos.splice(i, 0, entry)
                    added = true
                    break
                }
            }

            if (!added) {
                this.updatesPos.push(entry)
            }
        }

        this.hashForUpdates[target.id] = entry
    },

    /**
     * 'tick' the scheduler.
     * You should NEVER call this method, unless you know what you are doing.
     */
    tick: function (dt) {
        var i, len, x
        if (this.timeScale != 1.0) {
            dt *= this.timeScale
        }

        var entry
        for (i = 0, len = this.updatesNeg.length; i < len; i++) {
            entry = this.updatesNeg[i]
            if (entry && !entry.paused) {
                entry.target.update(dt)
            }
        }


        for (i = 0, len = this.updates0.length; i < len; i++) {
            entry = this.updates0[i]
            if (entry && !entry.paused) {
                entry.target.update(dt)
            }
        }

        for (i = 0, len = this.updatesPos.length; i < len; i++) {
            entry = this.updatesPos[i]
            if (entry && !entry.paused) {
                entry.target.update(dt)
            }
        }

        for (x in this.hashForMethods) {
            if (this.hashForMethods.hasOwnProperty(x)) {
                entry = this.hashForMethods[x]

                if (entry) {
                    for (i = 0, len = entry.timers.length; i < len; i++) {
                        var timer = entry.timers[i]
                        if (timer) {
                            timer.update(dt)
                        }
                    }
                }
            }
        }

    },

    /**
     * Unshedules a selector for a given target.
     * If you want to unschedule the "update", use unscheduleUpdateForTarget.
     */
    unschedule: function (opts) {
        if (!opts.target || !opts.method) {
            return
        }

        var target = opts.target,
            method = (typeof opts.method == 'function') ? opts.method : target[opts.method]

        var element = this.hashForMethods[opts.target.id]
        if (element) {
            for (var i=0; i<element.timers.length; i++) {
                // Compare callback function
                if (element.timers[i].callback == method.bind(target)) {
                    var timer = element.timers.splice(i, 1)
                    timer = null
                }
            }
        }
    },

    /**
     * Unschedules the update selector for a given target
     */
    unscheduleUpdateForTarget: function (target) {
        if (!target) {
            return
        }
        var id = target.id,
            elementUpdate = this.hashForUpdates[id]
        if (elementUpdate) {
            // Remove from updates list
            if (elementUpdate.priority === 0) {
                this.updates0.splice(this.updates0.indexOf(elementUpdate), 1)
            } else if (elementUpdate.priority < 0) {
                this.updatesNeg.splice(this.updatesNeg.indexOf(elementUpdate), 1)
            } else /* priority > 0 */{
                this.updatesPos.splice(this.updatesPos.indexOf(elementUpdate), 1)
            }
        }
        // Release HashMethodEntry object
        this.hashForUpdates[id] = null
    },

    /**
     * Unschedules all selectors from all targets.
     * You should NEVER call this method, unless you know what you are doing.
     */
    unscheduleAllSelectors: function () {
        var i, x, entry

        // Custom selectors
        for (x in this.hashForMethods) {
            if (this.hashForMethods.hasOwnProperty(x)) {
                entry = this.hashForMethods[x]
                this.unscheduleAllSelectorsForTarget(entry.target)
            }
        }
        // Updates selectors
        for (i = 0, len = this.updatesNeg.length; i < len; i++) {
            entry = this.updatesNeg[i]
            if (entry) {
                this.unscheduleUpdateForTarget(entry.target)
            }
        }

        for (i = 0, len = this.updates0.length; i < len; i++) {
            entry = this.updates0[i]
            if (entry) {
                this.unscheduleUpdateForTarget(entry.target)
            }
        }

        for (i = 0, len = this.updatesPos.length; i < len; i++) {
            entry = this.updatesPos[i]
            if (entry) {
                this.unscheduleUpdateForTarget(entry.target)
            }
        }
    },

    /**
     * Unschedules all selectors for a given target.
     * This also includes the "update" selector.
     */
    unscheduleAllSelectorsForTarget: function (target) {
        if (!target) {
            return
        }
        // Custom selector
        var element = this.hashForMethods[target.id]
        if (element) {
            element.paused = true
            element.timers = []; // Clear all timers
        }
        // Release HashMethodEntry object
        this.hashForMethods[target.id] = null

        // Update selector
        this.unscheduleUpdateForTarget(target)
    },

    /**
     * Pauses the target.
     * All scheduled selectors/update for a given target won't be 'ticked' until the target is resumed.
     * If the target is not present, nothing happens.
     */

    pauseTarget: function (target) {
        var element = this.hashForMethods[target.id]
        if (element) {
            element.paused = true
        }

        var elementUpdate = this.hashForUpdates[target.id]
        if (elementUpdate) {
            elementUpdate.paused = true
        }
    },

    /**
     * Resumes the target.
     * The 'target' will be unpaused, so all schedule selectors/update will be 'ticked' again.
     * If the target is not present, nothing happens.
     */
    resumeTarget: function (target) {
        var element = this.hashForMethods[target.id]
        if (element) {
            element.paused = false
        }

        var elementUpdate = this.hashForUpdates[target.id]
        //console.log('foo', target.id, elementUpdate)
        if (elementUpdate) {
            elementUpdate.paused = false
        }
    }
})

Object.defineProperty(Scheduler, 'sharedScheduler', {
    /**
     * A shared singleton instance of cocos.Scheduler
     *
     * @memberOf cocos.Scheduler
     * @getter {cocos.Scheduler} sharedScheduler
     */
    get: function () {
        if (!Scheduler._instance) {
            Scheduler._instance = new this()
        }

        return Scheduler._instance
    }

  , enumerable: true
})

exports.Timer = Timer
exports.Scheduler = Scheduler

// vim:et:st=4:fdm=marker:fdl=0:fdc=1

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/Scheduler.js


__jah__.resources["/libs/cocos2d/SpriteFrame.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

var util = require('util'),
    geo = require('geometry'),
    ccp = geo.ccp

/**
 * @class
 * Represents a single frame of animation for a cocos.Sprite
 *
 * A SpriteFrame has:
 * - texture: A Texture2D that will be used by the Sprite
 * - rectangle: A rectangle of the texture
 *
 * @example
 * var frame = new SpriteFrame({texture: texture, rect: rect})
 * sprite.displayFrame = frame
 *
 * @memberOf cocos
 *
 * @opt {cocos.Texture2D} texture The texture to draw this frame using
 * @opt {geometry.Rect} rect The rectangle inside the texture to draw
 */
function SpriteFrame (opts) {
    SpriteFrame.superclass.constructor.call(this, opts)

    this.texture      = opts.texture
    this.rect         = opts.rect
    this.rotated      = !!opts.rotate
    this.offset       = opts.offset || ccp(0, 0)
    this.originalSize = opts.originalSize || util.copy(this.rect.size)
}

SpriteFrame.inherit(Object, /** @lends cocos.SpriteFrame# */ {
    rect: null,
    rotated: false,
    offset: null,
    originalSize: null,
    texture: null,

    /**
     * @ignore
     */
    toString: function () {
        return "[object SpriteFrame | TextureName=" + this.texture.name + ", Rect = (" + this.rect.origin.x + ", " + this.rect.origin.y + ", " + this.rect.size.width + ", " + this.rect.size.height + ")]"
    },

    /**
     * Make a copy of this frame
     *
     * @returns {cocos.SpriteFrame} Exact copy of this object
     */
    copy: function () {
        return new SpriteFrame({rect: this.rect, rotated: this.rotated, offset: this.offset, originalSize: this.originalSize, texture: this.texture})
    }

})

exports.SpriteFrame = SpriteFrame

// vim:et:st=4:fdm=marker:fdl=0:fdc=1

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/SpriteFrame.js


__jah__.resources["/libs/cocos2d/SpriteFrameCache.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

var util = require('util'),
    geo = require('geometry'),
    Plist = require('Plist').Plist,
    SpriteFrame = require('./SpriteFrame').SpriteFrame,
    Texture2D = require('./Texture2D').Texture2D

/**
 * @class
 *
 * @memberOf cocos
 * @singleton
 */
function SpriteFrameCache () {
    SpriteFrameCache.superclass.constructor.call(this)

    this.spriteFrames = {}
    this.spriteFrameAliases = {}
}

SpriteFrameCache.inherit(Object, /** @lends cocos.SpriteFrameCache# */ {
    /**
     * List of sprite frames
     * @type Object
     */
    spriteFrames: null,

    /**
     * List of sprite frame aliases
     * @type Object
     */
    spriteFrameAliases: null,

    /**
     * Add SpriteFrame(s) to the cache
     *
     * @param {String} opts.file The filename of a Zwoptex .plist containing the frame definiitons.
     */
    addSpriteFrames: function (opts) {
        var plistPath = opts.file,
            plist = new Plist({file: plistPath}),
            plistData = plist.data


        var metaDataDict = plistData.metadata,
            framesDict = plistData.frames

        var format = 0,
            texturePath = null

        if (metaDataDict) {
            format = metaDataDict.format
            // Get texture path from meta data
            texturePath = metaDataDict.textureFileName
        }

        if (!texturePath) {
            // No texture path so assuming it's the same name as the .plist but ending in .png
            texturePath = plistPath.replace(/\.plist$/i, '.png')
        }


        var texture = new Texture2D({file: texturePath})

        // Add frames
        for (var frameDictKey in framesDict) {
            if (framesDict.hasOwnProperty(frameDictKey)) {
                var frameDict = framesDict[frameDictKey],
                    spriteFrame = null

                switch (format) {
                case 0:
                    var x = frameDict.x,
                        y =  frameDict.y,
                        w =  frameDict.width,
                        h =  frameDict.height,
                        ox = frameDict.offsetX,
                        oy = frameDict.offsetY,
                        ow = frameDict.originalWidth,
                        oh = frameDict.originalHeight

                    // check ow/oh
                    if (!ow || !oh) {
                        //console.log("cocos2d: WARNING: originalWidth/Height not found on the CCSpriteFrame. AnchorPoint won't work as expected. Regenerate the .plist")
                    }

                    if (FLIP_Y_AXIS) {
                        oy *= -1
                    }

                    // abs ow/oh
                    ow = Math.abs(ow)
                    oh = Math.abs(oh)

                    // create frame
                    spriteFrame = new SpriteFrame({texture: texture,
                                                         rect: geo.rectMake(x, y, w, h),
                                                       rotate: false,
                                                       offset: geo.ccp(ox, oy),
                                                 originalSize: geo.sizeMake(ow, oh)})
                    break

                case 1:
                case 2:
                    var frame      = geo.rectFromString(frameDict.frame),
                        rotated    = !!frameDict.rotated,
                        offset     = geo.pointFromString(frameDict.offset),
                        sourceSize = geo.sizeFromString(frameDict.sourceSize)

                    if (FLIP_Y_AXIS) {
                        offset.y *= -1
                    }


                    // create frame
                    spriteFrame = new SpriteFrame({texture: texture,
                                                         rect: frame,
                                                       rotate: rotated,
                                                       offset: offset,
                                                 originalSize: sourceSize})
                    break

                case 3:
                    var spriteSize       = geo.sizeFromString(frameDict.spriteSize),
                        spriteOffset     = geo.pointFromString(frameDict.spriteOffset),
                        spriteSourceSize = geo.sizeFromString(frameDict.spriteSourceSize),
                        textureRect      = geo.rectFromString(frameDict.textureRect),
                        textureRotated   = frameDict.textureRotated


                    if (FLIP_Y_AXIS) {
                        spriteOffset.y *= -1
                    }

                    // get aliases
                    var aliases = frameDict.aliases
                    for (var i = 0, len = aliases.length; i < len; i++) {
                        var alias = aliases[i]
                        this.spriteFrameAliases[frameDictKey] = alias
                    }

                    // create frame
                    spriteFrame = new SpriteFrame({texture: texture,
                                                         rect: geo.rectMake(textureRect.origin.x, textureRect.origin.y, spriteSize.width, spriteSize.height),
                                                       rotate: textureRotated,
                                                       offset: spriteOffset,
                                                 originalSize: spriteSourceSize})
                    break

                default:
                    throw "Unsupported Zwoptex format: " + format
                }

                // Add sprite frame
                this.spriteFrames[frameDictKey] = spriteFrame
            }
        }
    },

    /**
     * Get a single SpriteFrame
     *
     * @param {String} opts.name The name of the sprite frame
     * @returns {cocos.SpriteFrame} The sprite frame
     */
    getSpriteFrame: function (opts) {
        var name = opts.name || opts

        var frame = this.spriteFrames[name]

        if (!frame) {
            // No frame, look for an alias
            var key = this.spriteFrameAliases[name]

            if (key) {
                frame = this.spriteFrames[key]
            }

            if (!frame) {
                throw "Unable to find frame: " + name
            }
        }

        return frame
    }
})

Object.defineProperty(SpriteFrameCache, 'sharedSpriteFrameCache', {
    /**
     * A shared singleton instance of cocos.SpriteFrameCache
     *
     * @memberOf cocos.SpriteFrameCache
     * @getter {cocos.SpriteFrameCache} sharedSpriteFrameCache
     */
    get: function () {
        if (!SpriteFrameCache._instance) {
            SpriteFrameCache._instance = new this()
        }

        return SpriteFrameCache._instance
    }

  , enumerable: true
})

exports.SpriteFrameCache = SpriteFrameCache

// vim:et:st=4:fdm=marker:fdl=0:fdc=1

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/SpriteFrameCache.js


__jah__.resources["/libs/cocos2d/Texture2D.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

var util = require('util'),
    events = require('events'),
    RemoteResource = require('remote_resources').RemoteResource

/**
 * @class
 *
 * @memberOf cocos
 *
 * @opt {String} [file] The file path of the image to use as a texture
 * @opt {Texture2D|HTMLImageElement} [data] Image data to read from
 */
function Texture2D (opts) {
    var file = opts.file,
        data = opts.data,
        texture = opts.texture

    if (file) {
        this.name = file
        data = resource(file)
    } else if (texture) {
        this.name = texture.name
        data = texture.imgElement
    }

    this.size = {width: 0, height: 0}

    if (data instanceof RemoteResource) {
        events.addListenerOnce(data, 'load', this.dataDidLoad.bind(this))
        this.imgElement = data.load()
    } else {
        this.imgElement = data
        this.dataDidLoad(data)
    }
}

Texture2D.inherit(Object, /** @lends cocos.Texture2D# */ {
    imgElement: null,
    size: null,
    name: null,
    isLoaded: false,

    dataDidLoad: function (data) {
        this.isLoaded = true
        this.size = {width: this.imgElement.width, height: this.imgElement.height}
        events.trigger(this, 'load', this)
    },

    drawAtPoint: function (ctx, point) {
        if (!this.isLoaded) {
            return
        }
        ctx.drawImage(this.imgElement, point.x, point.y)
    },
    drawInRect: function (ctx, rect) {
        if (!this.isLoaded) {
            return
        }
        ctx.drawImage(this.imgElement,
            rect.origin.x, rect.origin.y,
            rect.size.width, rect.size.height
        )
    },

    /**
     * @getter data
     * @type {String} Base64 encoded image data
     */
    get data () {
        return this.imgElement ? this.imgElement.src : null
    },

    /**
     * @getter contentSize
     * @type {geometry.Size} Size of the texture
     */
    get contentSize () {
        return this.size
    },

    get pixelsWide () {
        return this.size.width
    },

    get pixelsHigh () {
        return this.size.height
    }
})

exports.Texture2D = Texture2D

// vim:et:st=4:fdm=marker:fdl=0:fdc=1

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/Texture2D.js


__jah__.resources["/libs/cocos2d/TextureAtlas.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

var util = require('util'),
    Texture2D = require('./Texture2D').Texture2D


/* QUAD STRUCTURE
 quad = {
     drawRect: <rect>, // Where the quad is drawn to
     textureRect: <rect>  // The slice of the texture to draw in drawRect
 }
*/

/**
 * @class
 * A single texture that can represent lots of smaller images
 *
 * @memberOf cocos
 *
 * @opt {String} file The file path of the image to use as a texture
 * @opt {Texture2D|HTMLImageElement} [data] Image data to read from
 * @opt {CanvasElement} [canvas] A canvas to use as a texture
 */
function TextureAtlas (opts) {
    var file = opts.file,
        data = opts.data,
        texture = opts.texture,
        canvas = opts.canvas

    if (canvas) {
        // If we've been given a canvas element then we'll use that for our image
        this.imgElement = canvas
    } else {
        texture = new Texture2D({texture: texture, file: file, data: data})
        this.texture = texture
        this.imgElement = texture.imgElement
    }

    this.quads = []
}

TextureAtlas.inherit(Object, /** @lends cocos.TextureAtlas# */ {
    quads: null,
    imgElement: null,
    texture: null,

    insertQuad: function (opts) {
        var quad = opts.quad,
            index = opts.index || 0

        this.quads.splice(index, 0, quad)
    },
    removeQuad: function (opts) {
        var index = opts.index

        this.quads.splice(index, 1)
    },


    drawQuads: function (ctx) {
        this.quads.forEach(function (quad) {
            if (!quad) return
            this.drawQuad(ctx, quad)
        }.bind(this))
    },

    drawQuad: function (ctx, quad) {
        var sx = quad.textureRect.origin.x,
            sy = quad.textureRect.origin.y,
            sw = quad.textureRect.size.width,
            sh = quad.textureRect.size.height

        var dx = quad.drawRect.origin.x,
            dy = quad.drawRect.origin.y,
            dw = quad.drawRect.size.width,
            dh = quad.drawRect.size.height


        var scaleX = 1
        var scaleY = 1

        if (FLIP_Y_AXIS) {
            dy -= dh
            dh *= -1
        }


        if (dw < 0) {
            dw *= -1
            scaleX = -1
        }

        if (dh < 0) {
            dh *= -1
            scaleY = -1
        }

        ctx.scale(scaleX, scaleY)

        var img = this.imgElement
        ctx.drawImage(img,
            sx, sy, // Draw slice from x,y
            sw, sh, // Draw slice size
            dx, dy, // Draw at 0, 0
            dw, dh  // Draw size
        )

        if (FLIP_Y_AXIS) {
            ctx.scale(1, -1)
        } else {
            ctx.scale(1, 1)
        }
    }
})

exports.TextureAtlas = TextureAtlas

// vim:et:st=4:fdm=marker:fdl=0:fdc=1

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/TextureAtlas.js


__jah__.resources["/libs/cocos2d/TMXOrientation.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

/**
 * @memberOf cocos
 * @namespace
 */
var TMXOrientation = /** @lends cocos.TMXOrientation */ {
    /**
     * Orthogonal orientation
     * @constant
     */
    TMXOrientationOrtho: 1,

    /**
     * Hexagonal orientation
     * @constant
     */
    TMXOrientationHex: 2,

    /**
     * Isometric orientation
     * @constant
     */
    TMXOrientationIso: 3
}

module.exports = TMXOrientation

// vim:et:st=4:fdm=marker:fdl=0:fdc=1

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/TMXOrientation.js


__jah__.resources["/libs/cocos2d/TMXXMLParser.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

var util = require('util'),
    path = require('path'),
    ccp = require('geometry').ccp,
    base64 = require('base64'),
    gzip   = require('gzip'),
    TMXOrientationOrtho = require('./TMXOrientation').TMXOrientationOrtho,
    TMXOrientationHex = require('./TMXOrientation').TMXOrientationHex,
    TMXOrientationIso = require('./TMXOrientation').TMXOrientationIso

/**
 * @class
 *
 * @memberOf cocos
 */
function TMXTilesetInfo () {
}

TMXTilesetInfo.inherit(Object, /** @lends cocos.TMXTilesetInfo# */ {
    name: '',
    firstGID: 0,
    tileSize: null,
    spacing: 0,
    margin: 0,
    sourceImage: null,

    rectForGID: function (gid) {
        var rect = {size: {}, origin: ccp(0, 0)}
        rect.size = util.copy(this.tileSize)

        gid = gid - this.firstGID

        var imgSize = this.imageSize

        var maxX = Math.floor((imgSize.width - this.margin * 2 + this.spacing) / (this.tileSize.width + this.spacing))

        rect.origin.x = (gid % maxX) * (this.tileSize.width + this.spacing) + this.margin
        rect.origin.y = Math.floor(gid / maxX) * (this.tileSize.height + this.spacing) + this.margin

        return rect
    }
})

/**
 * @class
 *
 * @memberOf cocos
 */
function TMXLayerInfo () {
    this.properties = {}
    this.offset = ccp(0, 0)
}

TMXLayerInfo.inherit(Object, /** @lends cocos.TMXLayerInfo# */ {
    name: '',
    layerSize: null,
    tiles: null,
    visible: true,
    opacity: 255,
    minGID: 100000,
    maxGID: 0,
    properties: null,
    offset: null
})

/**
 * @class
 *
 * @memberOf cocos
 */
function TMXObjectGroup () {
    this.properties = {}
    this.objects = {}
    this.offset = ccp(0, 0)
}

TMXObjectGroup.inherit(Object, /** @lends cocos.TMXObjectGroup# */ {
    name: '',
    properties: null,
    offset: null,
    objects: null,

    /**
     * Get the value for the specific property name
     *
     * @opt {String} name Property name
     * @returns {String} Property value
     */
    getProperty: function (opts) {
        var propertyName = opts.name
        return this.properties[propertyName]
    },

    /**
     * @deprected Since v0.2. You should now use cocos.TMXObjectGroup#getProperty
     */
    propertyNamed: function (opts) {
        console.warn('TMXObjectGroup#propertyNamed is deprected. Use TMXTiledMap#getProperty instread')
        return this.getProperty(opts)
    },

    /**
     * Get the object for the specific object name. It will return the 1st
     * object found on the array for the given name.
     *
     * @opt {String} name Object name
     * @returns {Object} Object
     */
    getObject: function (opts) {
        var objectName = opts.name
        var object = null

        this.objects.forEach(function (item) {
            if (item.name == objectName) {
                object = item
            }
        })
        if (object !== null) {
            return object
        }
    },

    /**
     * @deprected Since v0.2. You should now use cocos.TMXObjectGroup#getProperty
     */
    objectNamed: function (opts) {
        console.warn('TMXObjectGroup#objectNamed is deprected. Use TMXObjectGroup#getObject instread')
        return this.getObject(opts)
    }
})

/**
 * @class
 *
 * @memberOf cocos
 *
 * @param {String} tmxFile The file path of the TMX file to load
 */
function TMXMapInfo (tmxFile) {
    this.tilesets = []
    this.layers = []
    this.objectGroups = []
    this.properties = {}
    this.tileProperties = {}
    this.filename = tmxFile

    this.parseXMLFile(tmxFile)
}

TMXMapInfo.inherit(Object, /** @lends cocos.TMXMapInfo# */ {
    filename: '',
    orientation: 0,
    mapSize: null,
    tileSize: null,
    layer: null,
    tilesets: null,
    objectGroups: null,
    properties: null,
    tileProperties: null,

    parseXMLFile: function (xmlFile) {
        var parser = new DOMParser(),
            doc = parser.parseFromString(resource(xmlFile), 'text/xml')

        // PARSE <map>
        var map = doc.documentElement

        // Set Orientation
        switch (map.getAttribute('orientation')) {
        case 'orthogonal':
            this.orientation = TMXOrientationOrtho
            break
        case 'isometric':
            this.orientation = TMXOrientationIso
            break
        case 'hexagonal':
            this.orientation = TMXOrientationHex
            break
        default:
            throw "cocos2d: TMXFomat: Unsupported orientation: " + map.getAttribute('orientation')
        }
        this.mapSize = {width: parseInt(map.getAttribute('width'), 10), height: parseInt(map.getAttribute('height'), 10)}
        this.tileSize = {width: parseInt(map.getAttribute('tilewidth'), 10), height: parseInt(map.getAttribute('tileheight'), 10)}


        // PARSE <tilesets>
        var tilesets = map.getElementsByTagName('tileset')
        var i, j, len, jen, s
        for (i = 0, len = tilesets.length; i < len; i++) {
            var t = tilesets[i]
              , externalTilesetName = t.getAttribute('source')

            var tileset = new TMXTilesetInfo()
            tileset.firstGID = parseInt(t.getAttribute('firstgid'), 10)

            // Tileset is in external file, load in XML from there -- Must
            // happen AFTER 'firstGID' is obtained because firstGID is stored
            // in the main .tmx file, not the .tsx
            if (externalTilesetName) {
                var externalTilesetPath = path.join(path.dirname(xmlFile), externalTilesetName)
                t = parser.parseFromString(resource(externalTilesetPath), 'text/xml').documentElement
            }

            tileset.name = t.getAttribute('name')
            if (t.getAttribute('spacing')) {
                tileset.spacing = parseInt(t.getAttribute('spacing'), 10)
            }
            if (t.getAttribute('margin')) {
                tileset.margin = parseInt(t.getAttribute('margin'), 10)
            }

            s = {}
            s.width = parseInt(t.getAttribute('tilewidth'), 10)
            s.height = parseInt(t.getAttribute('tileheight'), 10)
            tileset.tileSize = s

            // PARSE <image> We assume there's only 1
            var image = t.getElementsByTagName('image')[0]
            if (externalTilesetName) {
                tileset.sourceImage = path.join(path.dirname(externalTilesetPath), image.getAttribute('source'))
            } else {
                tileset.sourceImage = path.join(path.dirname(this.filename), image.getAttribute('source'))
            }

            this.tilesets.push(tileset)
        }

        // PARSE <layer>s
        var layers = map.getElementsByTagName('layer')
        for (i = 0, len = layers.length; i < len; i++) {
            var l = layers[i]
            var data = l.getElementsByTagName('data')[0]
            var layer = new TMXLayerInfo()

            layer.name = l.getAttribute('name')
            if (l.getAttribute('visible') !== false) {
                layer.visible = true
            } else {
                layer.visible = !!parseInt(l.getAttribute('visible'), 10)
            }

            s = {}
            s.width = parseInt(l.getAttribute('width'), 10)
            s.height = parseInt(l.getAttribute('height'), 10)
            layer.layerSize = s

            var opacity = l.getAttribute('opacity')
            if (!opacity && opacity !== 0) {
                layer.opacity = 255
            } else {
                layer.opacity = 255 * parseFloat(opacity)
            }

            var x = parseInt(l.getAttribute('x'), 10),
                y = parseInt(l.getAttribute('y'), 10)
            if (isNaN(x)) {
                x = 0
            }
            if (isNaN(y)) {
                y = 0
            }
            layer.offset = ccp(x, y)


            // Firefox has a 4KB limit on node values. It will split larger
            // nodes up into multiple nodes. So, we'll stitch them back
            // together.
            var nodeValue = ''
            for (j = 0, jen = data.childNodes.length; j < jen; j++) {
                nodeValue += data.childNodes[j].nodeValue
            }

            // Unpack the tilemap data
            var compression = data.getAttribute('compression')
            switch (compression) {
            case 'gzip':
                layer.tiles = gzip.unzipBase64AsArray(nodeValue, 4)
                break

            // Uncompressed
            case null:
            case '':
                layer.tiles = base64.decodeAsArray(nodeValue, 4)
                break

            default:
                throw "Unsupported TMX Tile Map compression: " + compression
            }

            // Parties <properties> in <layer>
            var properties = l.querySelectorAll('properties > property')
              , propertiesValue = {}
              , property
            for (j = 0; j < properties.length; j++) {
                property = properties[j]
                if (property.getAttribute('name')) {
                    propertiesValue[property.getAttribute('name')] = property.getAttribute('value')
                }
            }

            layer.properties = propertiesValue
            this.layers.push(layer)
        }

        // TODO PARSE <tile>

        // PARSE <objectgroup>
        var objectgroups = map.getElementsByTagName('objectgroup')
        for (i = 0, len = objectgroups.length; i < len; i++) {
            var g = objectgroups[i],
                objectGroup = new TMXObjectGroup()

            objectGroup.name = g.getAttribute('name')

            properties = g.querySelectorAll('objectgroup > properties property')
            propertiesValue = {}
            property

            for (j = 0; j < properties.length; j++) {
                property = properties[j]
                if (property.getAttribute('name')) {
                    propertiesValue[property.getAttribute('name')] = property.getAttribute('value')
                }
            }

            objectGroup.properties = propertiesValue

            var objectsArray = [],
                objects = g.querySelectorAll('object')

            for (j = 0; j < objects.length; j++) {
                var object = objects[j]
                var objectValue = {
                    x       : parseInt(object.getAttribute('x'), 10),
                    y       : parseInt(object.getAttribute('y'), 10),
                    width   : parseInt(object.getAttribute('width'), 10),
                    height  : parseInt(object.getAttribute('height'), 10)
                }

                if (FLIP_Y_AXIS) {
                    objectValue.y = (this.mapSize.height * this.tileSize.height) - objectValue.y - objectValue.height
                }

                if (object.getAttribute('name')) {
                    objectValue.name = object.getAttribute('name')
                }
                if (object.getAttribute('type')) {
                    objectValue.type = object.getAttribute('type')
                }
                properties = object.querySelectorAll('property')
                for (var k = 0; k < properties.length; k++) {
                    property = properties[k]
                    if (property.getAttribute('name')) {
                        objectValue[property.getAttribute('name')] = property.getAttribute('value')
                    }
                }
                objectsArray.push(objectValue)

            }
            objectGroup.objects = objectsArray
            this.objectGroups.push(objectGroup)
        }


        // PARSE <map><property>
        var properties = doc.querySelectorAll('map > properties > property')

        for (i = 0; i < properties.length; i++) {
            var property = properties[i]
            if (property.getAttribute('name')) {
                this.properties[property.getAttribute('name')] = property.getAttribute('value')
            }
        }
    }
})

exports.TMXMapInfo = TMXMapInfo
exports.TMXLayerInfo = TMXLayerInfo
exports.TMXTilesetInfo = TMXTilesetInfo
exports.TMXObjectGroup = TMXObjectGroup

// vim:et:st=4:fdm=marker:fdl=0:fdc=1

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/TMXXMLParser.js


__jah__.resources["/libs/cocos2d/TouchDispatcher.js"] = {data: function (exports, require, module, __filename, __dirname) {
'use strict'

var util = require('util')
  , geo = require('geometry')


var kCCTouchSelectorBeganBit = 1 << 0
  , kCCTouchSelectorMovedBit = 1 << 1
  , kCCTouchSelectorEndedBit = 1 << 2
  , kCCTouchSelectorCancelledBit = 1 << 3
  , kCCTouchSelectorAllBits = ( kCCTouchSelectorBeganBit | kCCTouchSelectorMovedBit | kCCTouchSelectorEndedBit | kCCTouchSelectorCancelledBit)

// Touch types
var kCCTouchBegan     = 1
  , kCCTouchMoved     = 2
  , kCCTouchEnded     = 3
  , kCCTouchCancelled = 4
  , kCCTouchMax       = 5

function TouchHandler (delegate, priority) {
    this.delegate = delegate
    this.priority = priority
}

function StandardTouchHandler (delegate, priority) {
    StandardTouchHandler.superclass.constructor.call(this, delegate, priority)
}
StandardTouchHandler.inherit(TouchHandler)

function TargetedTouchHandler (delegate, priority, swallowsTouches) {
    TargetedTouchHandler.superclass.constructor.call(this, delegate, priority)

    this.swallowsTouches = swallowsTouches
    this.claimedTouches = {}
}
TargetedTouchHandler.inherit(TouchHandler)

/**
 * @class
 * This singleton is responsible for dispatching Touch events on some devices
 *
 * @memberOf cocos
 * @singleton
 */
function TouchDispatcher () {
    this.standardHandlers = []
    this.targetedHandlers = []

    this._toRemove = false
    this._toAdd    = false
    this._toQuit   = false
    this._locked   = false

    this._handlersToAdd = []
    this._handlersToRemove = []
}

TouchDispatcher.inherit(Object, /** @lends cocos.TouchDispatcher# */ {
    dispatchEvents: true
  , standardHandlers: null
  , targetedHandlers: null

  , forceAddHandler: function (handler, array) {
        var i = 0
        array.forEach(function (h) {
            if (h.priority < handler.priority) {
                i++
            }

            if (h.delegate == handler.delegate) {
                throw new Error ("Delegate already added to touch dispatcher")
            }
        }.bind(this))

        array.splice(i, 0, handler)
    }

  , addStandardDelegate: function (delegate, priority) {
        var handler = new StandardTouchHandler(delegate, priority)

        if (this._locked) {
            this._handlersToAdd.push(handler)
            this._toAdd = true
        } else {
            this.forceAddHandler(handler, this.standardHandlers)
        }
    }

  , addTargetedDelegate: function (delegate, priority, swallowsTouches) {
        var handler = new TargetedTouchHandler(delegate, priority, !!swallowsTouches)

        if (this._locked) {
            this._handlersToAdd.push(handler)
            this._toAdd = true
        } else {
            this.forceAddHandler(handler, this.targetedHandlers)
        }
    }

  , forceRemoveDelegate: function (delegate) {
        var i, handler
        for (i = 0; i < this.targetedHandlers.length; i++) {
            handler = this.targetedHandlers[i]
            if (handler.delegate === delegate) {
                this.targetedHandlers.splice(i, 1)
                handler.claimedTouches
                break
            }
        }

        for (i = 0; i < this.standardHandlers.length; i++) {
            handler = this.standardHandlers[i]
            if (handler.delegate === delegate) {
                this.standardHandlers.splice(i, 1)
                break
            }
        }
    }

  , removeDelegate: function (delegate) {
        if (!delegate) {
            return
        }

        if (this._locked) {
            this._handlersToRemove.push(delegate)
            this._toRemove = true
        } else {
            this.forceRemoveDelegate(delegate)
        }
    }

  , forceRemoveAllDelegates: function () {
        this.standardHandlers.splice(0, this.standardHandlers.length)
        this.targetedHandlers.splice(0, this.targetedHandlers.length)
    }

  , removeAllDelegates: function () {
        if (this._locked) {
            this._toQuit = true
        } else {
            this.forceRemoveAllDelegates()
        }
    }

  , findHandler: function (delegate) {
        var i, handler
        for (i = 0; i < this.targetedHandlers.length; i++) {
            handler = this.targetedHandlers[i]
            if (handler.delegate === delegate) {
                return handler
            }
        }

        for (i = 0; i < this.standardHandlers.length; i++) {
            handler = this.standardHandlers[i]
            if (handler.delegate === delegate) {
                return handler
            }
        }

        return null
    }
  , rearrangeHandlers: function (array) {
        array.sort(function (first, second) {
            return first.priority - second.priority
        })
    }

  , setDelegatePriority: function (delegate, priority) {
        if (!delegate) throw new Error("Got nil touch delegate")

        var handler = this.findHandler(delegate)
        if (!handler) throw new Error("Delegate not found")

        handler.priority = priority

        this.rearrangeHandlers(this.targetedHandlers)
        this.rearrangeHandlers(this.standardHandlers)
    }

  , ontouches: function (evt, touchType) {
        this._locked = true

        var director = require('./Director').Director.sharedDirector

        var i, j, touch, handler, idx

        // Can't modify the evt.touches object directly -- and we only need to if we're doing both types of handlers
        var needsMutableSet = this.targetedHandlers.length && this.standardHandlers.length
          , mutableTouches = needsMutableSet ? Array.prototype.splice.call(evt.changedTouches, 0) : evt.changedTouches

        for (i = 0; i < mutableTouches.length; i++) {
            touch = mutableTouches[i]
            touch.locationInCanvas = director.convertTouchToCanvas(touch)
        }

        // Process Targeted handlers first
        if (this.targetedHandlers.length > 0) {
            var claimed = false
            for (i = 0; i < mutableTouches.length; i++) {
                touch = mutableTouches[i]

                for (j = 0; j < this.targetedHandlers.length; j++) {
                    handler = this.targetedHandlers[j]

                    claimed = false
                    // Touch began
                    if (touchType == kCCTouchBegan) {
                        if (handler.delegate.touchBegan) {
                            claimed = handler.delegate.touchBegan({touch: touch, originalEvent: evt})
                        }
                        if (claimed) {
                            handler.claimedTouches[touch.identifier] = touch
                        }
                    }
                    // Touch move, end, cancel
                    else if (handler.claimedTouches[touch.identifier]) {
                        claimed = true
                        switch (touchType) {
                        case kCCTouchMoved:
                            if (handler.delegate.touchMoved) handler.delegate.touchMoved({touch: touch, originalEvent: evt})
                            break

                        case kCCTouchEnded:
                            console.log('touch end')
                            if (handler.delegate.touchEnded) handler.delegate.touchEnded({touch: touch, originalEvent: evt})
                            delete handler.claimedTouches[touch.identifier]
                            break

                        case kCCTouchCancelled:
                            if (handler.delegate.touchCancelled) handler.delegate.touchCancelled({touch: touch, originalEvent: evt})
                            delete handler.claimedTouches[touch.identifier]
                            break
                        }
                    }

                    if (claimed && handler.swallowsTouches) {
                        if (needsMutableSet) {
                            idx = mutableTouches.indexOf(touch)
                            mutableTouches.splice(idx, 1)
                            // Removed item, so knock loop back one
                            i--
                        }
                        break
                    }
                }
            }
        }

        // Standard touch handling
        if (this.standardHandlers.length > 0 && mutableTouches.length > 0) {
            for (j = 0; j < this.standardHandlers.length; j++) {
                handler = this.standardHandlers[j]
                switch (touchType) {
                case kCCTouchBegan:
                    if (handler.delegate.touchesBegan)
                        handler.delegate.touchesBegan({touches: mutableTouches, originalEvent: evt})
                    break

                case kCCTouchMoved:
                    if (handler.delegate.touchesMoved)
                        handler.delegate.touchesMoved({touches: mutableTouches, originalEvent: evt})
                    break

                case kCCTouchEnded:
                    if (handler.delegate.touchesEnded)
                        handler.delegate.touchesEnded({touches: mutableTouches, originalEvent: evt})
                    break

                case kCCTouchCancelled:
                    if (handler.delegate.touchesCancelled)
                        handler.delegate.touchesCancelled({touches: mutableTouches, originalEvent: evt})
                    break
                }
            }
        }

        this._locked = false
        if (this._toRemove)  {
            this._toRemove = false
            for (i = 0; i < this._handlersToRemove.length; i++) {
                this.forceRemoveDelegate(this._handlersToRemove[i])
            }
            // Clear the array in place
            this._handlersToRemove.splice(0, this._handlersToRemove.length)
        }

        if (this._toAdd) {
            this._toAdd = false
            for (i = 0; i < this._handlersToAdd.length; i++) {
                handler = this._handlersToAdd[i]
                if (handler instanceof TargetedTouchHandler) {
                    this.forceAddHandler(handler, this.targetedHandlers)
                } else {
                    this.forceAddHandler(handler, this.standardHandlers)
                }
            }
            // Clear the array in place
            this._handlersToAdd.splice(0, this._handlersToAdd.length)
        }

        if (this._toQuit) {
            this._toQuit = false
            this.forceRemoveAllDelegates()
        }
    }

  , touchesBegan: function (evt) {
        if (this.dispatchEvents)
            this.ontouches(evt, kCCTouchBegan)
    }

  , touchesMoved: function (evt) {
        if (this.dispatchEvents)
            this.ontouches(evt, kCCTouchMoved)
    }

  , touchesEnded: function (evt) {
        if (this.dispatchEvents)
            this.ontouches(evt, kCCTouchEnded)
    }

  , touchesCancelled: function (evt) {
        if (this.dispatchEvents)
            this.ontouches(evt, kCCTouchCancelled)
    }

})

Object.defineProperty(TouchDispatcher, 'sharedDispatcher', {
    /**
     * A shared singleton instance of cocos.TouchDispatcher
     *
     * @memberOf cocos.TouchDispatcher
     * @getter {cocos.TouchDispatcher} sharedDispatcher
     */
    get: function () {
        if (!TouchDispatcher._instance) {
            TouchDispatcher._instance = new this()
        }

        return TouchDispatcher._instance
    }

  , enumerable: true
})

exports.TouchDispatcher = TouchDispatcher
exports.TouchHandler = TouchHandler

// vim:et:st=4:fdm=marker:fdl=0:fdc=1

}, mimetype: "application/javascript", remote: false}; // END: /libs/cocos2d/TouchDispatcher.js


})();