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
 * Similar to the built-in Treewalker class, but simplified and allows direct
 * access to modify the currentNode property.
 * @param {!Element|!DocumentFragment} node The root Node of the subtree the
 *     walker should start traversing.
 * @constructor
 */
class TreeWalker {

  /**
   * Keeps track of the current parent node. This is necessary as the traversal
   * methods may traverse past the last child and we still need a way to get
   * back to the parent.
   * @const @private {!Array<!Node>}
   */
  final List<Node> _stack = <Node>[];

  /**
   * Keeps track of what namespace to create new Elements in.
   * @private
   * @const {!Array<(string|undefined)>}
   */
  final List<String> _nsStack = [null];

  final Document doc;
  Node currentNode;

  TreeWalker(Node node) : currentNode = node, doc = node.ownerDocument;

  /**
   * @return {!Node} The current parent of the current location in the subtree.
   */
  Node getCurrentParent() => _stack.last;


  /**
   * @return {(string|undefined)} The current namespace to create Elements in.
   */
  String getCurrentNamespace() => _nsStack.last;


  /**
   * @param {string=} namespace The namespace to enter.
   */
  void enterNamespace(String namespace) {
    _nsStack.add(namespace);
  }


  /**
   * Exits the current namespace
   */
  void exitNamespace() {
    _nsStack.removeLast();
  }


  /**
   * Changes the current location the firstChild of the current location.
   */
  firstChild() {
    _stack.add(currentNode);
    currentNode = currentNode.firstChild;
  }


  /**
   * Changes the current location the nextSibling of the current location.
   */
  nextSibling() {
    currentNode = currentNode.nextNode;
  }


  /**
   * Changes the current location the parentNode of the current location.
   */
  parentNode() {
    currentNode = _stack.removeLast();
  }
}
