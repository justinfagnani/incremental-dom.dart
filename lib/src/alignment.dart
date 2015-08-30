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
import 'dart:html' hide TreeWalker;
import 'nodes.dart' show createNode, getChild, registerChild;
import 'node_data.dart' show getData;
import 'walker.dart' show getWalker;
import 'tree_walker.dart' show TreeWalker;

/**
 * Makes sure that keyed Element matches the tag name provided.
 * @param {!Element} node The node that is being matched.
 * @param {string=} tag The tag name of the Element.
 * @param {?string=} key The key of the Element.
 */
void assertKeyedTagMatches(Element node, String tag, String key) {
  var nodeName = getData(node).nodeName;
  if (nodeName != tag) {
    throw new ArgumentError('Was expecting node with key "$key" to be a '
        '$tag , not a $nodeName.');
  }
}

/**
 * Checks whether or not a given node matches the specified nodeName and key.
 *
 * @param {!Node} node An HTML node, typically an HTMLElement or Text.
 * @param {?string} nodeName The nodeName for this node.
 * @param {?string=} key An optional key that identifies a node.
 * @return {boolean} True if the node matches, false otherwise.
 */
bool matches(Node node, String nodeName, String key) {
  var data = getData(node);

  // Key check is done using double equals as we want to treat a null key the
  // same as undefined. This should be okay as the only values allowed are
  // strings, null and undefined so the == semantics are not too weird.
  return key == data.key && nodeName == data.nodeName;
}


/**
 * Aligns the virtual Element definition with the actual DOM, moving the
 * corresponding DOM node to the correct location or creating it if necessary.
 * @param {string} nodeName For an Element, this should be a valid tag string.
 *     For a Text, this should be #text.
 * @param {?string=} key The key used to identify this element.
 * @param {?Array<*>=} statics For an Element, this should be an array of
 *     name-value pairs.
 * @return {!Node} The matching node.
 */
Node alignWithDOM(String nodeName, String key, [List statics]) {
  TreeWalker walker = getWalker();
  Node currentNode = walker.currentNode;
  Element parent = walker.getCurrentParent();
  Node matchingNode;

  // Check to see if we have a node to reuse
  if (currentNode != null && matches(currentNode, nodeName, key)) {
    matchingNode = currentNode;
  } else {
    Element existingNode = getChild(parent, key);

    // Check to see if the node has moved within the parent or if a new one
    // should be created
    if (existingNode != null) {
      // if (process.env.NODE_ENV !== 'production') {
        assertKeyedTagMatches(existingNode, nodeName, key);
      // }

      matchingNode = existingNode;
    } else {
      matchingNode = createNode(walker.doc, nodeName, key, statics);

      if (key != null) {
        registerChild(parent, key, matchingNode);
      }
    }

    // If the node has a key, remove it from the DOM to prevent a large number
    // of re-orders in the case that it moved far or was completely removed.
    // Since we hold on to a reference through the keyMap, we can always add it
    // back.
    if (currentNode != null && getData(currentNode).key != null) {
      matchingNode.replaceWith(currentNode);
      getData(parent).keyMapValid = false;
    } else {
      parent.insertBefore(matchingNode, currentNode);
    }

    walker.currentNode = matchingNode;
  }

  return matchingNode;
}


/**
 * Clears out any unvisited Nodes, as the corresponding virtual element
 * functions were never called for them.
 * @param {!Node} node
 */
void clearUnvisitedDOM(Node node) {
  var data = getData(node);
  Map keyMap = data.keyMap;
  var keyMapValid = data.keyMapValid;
  var lastChild = node.lastChild;
  var lastVisitedChild = data.lastVisitedChild;

  data.lastVisitedChild = null;

  if (lastChild == lastVisitedChild && keyMapValid) {
    return;
  }

  while (lastChild != lastVisitedChild) {
    lastChild.remove();
    lastChild = node.lastChild;
  }

  if (keyMap != null && keyMap.length > 0) {
    // Clean the keyMap, removing any unusued keys.
    var unusedKeys = [];
    for (var key in keyMap.keys) {
      if (keyMap[key].parentNode == null) {
        unusedKeys.add(key);
      }
    }
    for (var key in unusedKeys) {
      keyMap.remove(key);
    }
  }

  data.keyMapValid = true;
}
