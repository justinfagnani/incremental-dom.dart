/**
 * Copyright 2015 The Incremental DOM Authors. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS-IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:html';
import 'alignment.dart' show alignWithDOM, clearUnvisitedDOM;
import 'attributes.dart' show updateAttribute;
import 'node_data.dart' show getData, NodeData;
import 'walker.dart' show getWalker;
import 'traversal.dart' show firstChild, nextSibling, parentNode;

/**
 * The offset in the virtual element declaration where the attributes are
 * specified.
 * @const
 */
const ATTRIBUTES_OFFSET = 3;


/**
 * Builds an array of arguments for use with elementOpenStart, attr and
 * elementOpenEnd.
 * @const {Array<*>}
 */
// final List argsBuilder = [null, null, null];
// Argh, global state!!!
// TODO(justinfagnani): come up with a better way to do this than the JS version
// probably by introducing an IncrementalDom class
String tag;
String key;
List statics;
List attributes = [];


// if (process.env.NODE_ENV !== 'production') {
//   /**
//    * Keeps track whether or not we are in an attributes declaration (after
//    * elementOpenStart, but before elementOpenEnd).
//    * @type {boolean}
//    */
//   var inAttributes = false;
//
//
//   /** Makes sure that the caller is not where attributes are expected. */
//   var assertNotInAttributes = function() {
//     if (inAttributes) {
//       throw new Error('Was not expecting a call to attr or elementOpenEnd, ' +
//           'they must follow a call to elementOpenStart.');
//     }
//   };
//
//
//   /** Makes sure that the caller is where attributes are expected. */
//   var assertInAttributes = function() {
//     if (!inAttributes) {
//       throw new Error('Was expecting a call to attr or elementOpenEnd. ' +
//           'elementOpenStart must be followed by zero or more calls to attr, ' +
//           'then one call to elementOpenEnd.');
//     }
//   };
//
//
//   /**
//    * Makes sure that tags are correctly nested.
//    * @param {string} tag
//    */
//   var assertCloseMatchesOpenTag = function(tag) {
//     var closingNode = getWalker().getCurrentParent();
//     var data = getData(closingNode);
//
//     if (tag !== data.nodeName) {
//       throw new Error('Received a call to close ' + tag + ' but ' +
//             data.nodeName + ' was open.');
//     }
//   };
//
//
//   /** Updates the state to being in an attribute declaration. */
//   var setInAttributes = function() {
//     inAttributes = true;
//   };
//
//
//   /** Updates the state to not being in an attribute declaration. */
//   var setNotInAttributes = function() {
//     inAttributes = false;
//   };
// }


/**
 * @param {string} tag The element's tag.
 * @param {?string=} key The key used to identify this element. This can be an
 *     empty string, but performance may be better if a unique value is used
 *     when iterating over an array of items.
 * @param {?Array<*>=} statics An array of attribute name/value pairs of the
 *     static attributes for the Element. These will only be set once when the
 *     Element is created.
 * @param {...*} var_args Attribute name/value pairs of the dynamic attributes
 *     for the Element.
 * @return {!Element} The corresponding Element.
 */
Element elementOpen(String tag, [String key, List statics, List var_args]) {
  // if (process.env.NODE_ENV !== 'production') {
  //   assertNotInAttributes();
  // }

  Element node = alignWithDOM(tag, key, statics);
  NodeData data = getData(node);

  /*
   * Checks to see if one or more attributes have changed for a given Element.
   * When no attributes have changed, this is much faster than checking each
   * individual argument. When attributes have changed, the overhead of this is
   * minimal.
   */
  var attrsArr = data.attrsArr;
  var attrsChanged = false;
  var i = 0; //ATTRIBUTES_OFFSET;
  var j = 0;

  if (var_args == null) {
    if (attrsArr.length > 0) {
      attrsChanged = true;
      attrsArr.clear();
    }
  } else {
    if (attrsArr.length != var_args.length) {
      attrsChanged = true;
      attrsArr.length = var_args.length;
    } else {
      for (; i < var_args.length; i += 1, j += 1) {
        if (attrsArr[j] != var_args[i]) {
          attrsChanged = true;
          break;
        }
      }
    }
    for (; i < var_args.length; i += 1, j += 1) {
      attrsArr[j] = var_args[i];
    }
  }

  /*
   * Actually perform the attribute update.
   */
  if (attrsChanged) {
    String attr;
    Map newAttrs = data.newAttrs;

    for (attr in newAttrs.keys) {
      newAttrs[attr] = null;
    }

    for (i = 0; i < var_args.length; i += 2) {
      newAttrs[attrsArr[i]] = attrsArr[i + 1];
    }

    for (attr in newAttrs.keys) {
      updateAttribute(node, attr, newAttrs[attr]);
    }
  }

  firstChild();
  return node;
}


/**
 * Declares a virtual Element at the current location in the document. This
 * corresponds to an opening tag and a elementClose tag is required. This is
 * like elementOpen, but the attributes are defined using the attr function
 * rather than being passed as arguments. Must be folllowed by 0 or more calls
 * to attr, then a call to elementOpenEnd.
 * @param {string} tag The element's tag.
 * @param {?string=} key The key used to identify this element. This can be an
 *     empty string, but performance may be better if a unique value is used
 *     when iterating over an array of items.
 * @param {?Array<*>=} statics An array of attribute name/value pairs of the
 *     static attributes for the Element. These will only be set once when the
 *     Element is created.
 */
void elementOpenStart(String tag, [String key, List statics]) {
  // if (process.env.NODE_ENV !== 'production') {
  //   assertNotInAttributes();
  //   setInAttributes();
  // }

  tag = tag;
  key = key;
  statics = statics;
}


/***
 * Defines a virtual attribute at this point of the DOM. This is only valid
 * when called between elementOpenStart and elementOpenEnd.
 *
 * @param {string} name
 * @param {*} value
 */
void attr(String name, value) {
  // if (process.env.NODE_ENV !== 'production') {
  //   assertInAttributes();
  // }

  attributes..add(name)..add(value);
}


/**
 * Closes an open tag started with elementOpenStart.
 * @return {!Element} The corresponding Element.
 */
Element elementOpenEnd() {
  // if (process.env.NODE_ENV !== 'production') {
  //   assertInAttributes();
  //   setNotInAttributes();
  // }

  var node = elementOpen(tag, key, statics, attributes);
  tag = null;
  key = null;
  statics = null;
  attributes.clear();
  return node;
}


/**
 * Closes an open virtual Element.
 *
 * @param {string} tag The element's tag.
 * @return {!Element} The corresponding Element.
 */
Element elementClose(String tag) {
  // if (process.env.NODE_ENV !== 'production') {
  //   assertNotInAttributes();
  //   assertCloseMatchesOpenTag(tag);
  // }

  parentNode();

  Element node = getWalker().currentNode;
  clearUnvisitedDOM(node);

  nextSibling();
  return node;
}


/**
 * Declares a virtual Element at the current location in the document that has
 * no children.
 * @param {string} tag The element's tag.
 * @param {?string=} key The key used to identify this element. This can be an
 *     empty string, but performance may be better if a unique value is used
 *     when iterating over an array of items.
 * @param {?Array<*>=} statics An array of attribute name/value pairs of the
 *     static attributes for the Element. These will only be set once when the
 *     Element is created.
 * @param {...*} var_args Attribute name/value pairs of the dynamic attributes
 *     for the Element.
 * @return {!Element} The corresponding Element.
 */
Element elementVoid(String tag, [String key, List statics, List var_args]) {
  // if (process.env.NODE_ENV !== 'production') {
  //   assertNotInAttributes();
  // }

  var node = elementOpen(tag, key, statics, var_args);
  elementClose(tag);
  return node;
}


/**
 * Declares a virtual Text at this point in the document.
 *
 * @param {string|number|boolean} value The value of the Text.
 * @param {...(function(string|number|boolean):string)} var_args
 *     Functions to format the value which are called only when the value has
 *     changed.
 * @return {!Text} The corresponding text node.
 */
Text text(value, [List<Function> var_args]) {
  // if (process.env.NODE_ENV !== 'production') {
  //   assertNotInAttributes();
  // }

  var node = alignWithDOM('#text', null);
  var data = getData(node);

  if (data.text != value) {
    data.text = value;

    var formatted = value;
    if (var_args != null) {
      for (var i = 0; i < var_args.length; i += 1) {
        formatted = var_args[i](formatted);
      }
    }

    node.data = formatted;
  }

  nextSibling();
  return node;
}
