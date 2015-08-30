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

/**
 * Keeps track of information needed to perform diffs for a given DOM node.
 * @param {!string} nodeName
 * @param {?string=} key
 * @constructor
 */
class NodeData {

  /**
   * The attributes and their values.
   * @const
   */
  Map attrs = {};

  /**
   * An array of attribute name/value pairs, used for quickly diffing the
   * incomming attributes to see if the DOM node's attributes need to be
   * updated.
   * @const {Array<*>}
   */
  List attrsArr = [];

  /**
   * The incoming attributes for this Node, before they are updated.
   * @const {!Object<string, *>}
   */
  Map newAttrs = {};

  /**
   * The key used to identify this node, used to preserve DOM nodes when they
   * move within their parent.
   * @const
   */
  String key;


  /**
   * Keeps track of children within this node by their key.
   * {?Object<string, !Element>}
   */
  Map keyMap;

  /**
   * Whether or not the keyMap is currently valid.
   * {boolean}
   */
  var keyMapValid = true;

  /**
   * The last child to have been visited within the current pass.
   * @type {?Node}
   */
  var lastVisitedChild;

  /**
   * The node name for this node.
   * @const {string}
   */
  String nodeName;

  String text = null;

  NodeData(String this.nodeName, String this.key);
}

/**
 * Initializes a NodeData object for a Node.
 *
 * @param {!Node} node The node to initialize data for.
 * @param {string} nodeName The node name of node.
 * @param {?string=} key The key that identifies the node.
 * @return {!NodeData} The newly initialized data object
 */
NodeData initData(Node node, String nodeName, String key) {
  var data = new NodeData(nodeName, key);
  _nodeData[node] = data;
  return data;
}

Expando<NodeData> _nodeData = new Expando<NodeData>();

/**
 * Retrieves the NodeData object for a Node, creating it if necessary.
 *
 * @param {!Node} node The node to retrieve the data for.
 * @return {NodeData} The NodeData for this Node.
 */
NodeData getData(Node node) {
  var data = _nodeData[node];

  if (data == null) {
    var nodeName = node.nodeName.toLowerCase();
    var key = null;

    if (node is Element) {
      key = node.getAttribute('key');
    }

    data = initData(node, nodeName, key);
  }

  return data;
}
