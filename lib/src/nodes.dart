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
import 'attributes.dart' show updateAttribute;
import 'node_data.dart' show getData, initData;
import 'namespace.dart' show getNamespaceForTag;

/**
 * Creates an Element.
 * @param {!Document} doc The document with which to create the Element.
 * @param {string} tag The tag for the Element.
 * @param {?string=} key A key to identify the Element.
 * @param {?Array<*>=} statics An array of attribute name/value pairs of
 *     the static attributes for the Element.
 * @return {!Element}
 */
Element createElement(Document doc, String tag, String key, List statics) {
  String namespace = getNamespaceForTag(tag);
  Element el;

  if (namespace != null) {
    el = doc.createElementNS(namespace, tag);
  } else {
    el = doc.createElement(tag);
  }

  initData(el, tag, key);

  if (statics != null && statics.isNotEmpty) {
    for (var i = 0; i < statics.length; i += 2) {
      updateAttribute(el, (statics[i]), statics[i + 1]);
    }
  }

  return el;
}


/**
 * Creates a Node, either a Text or an Element depending on the node name
 * provided.
 * @param {!Document} doc The document with which to create the Node.
 * @param {string} nodeName The tag if creating an element or #text to create
 *     a Text.
 * @param {?string=} key A key to identify the Element.
 * @param {?Array<*>=} statics The static data to initialize the Node
 *     with. For an Element, an array of attribute name/value pairs of
 *     the static attributes for the Element.
 * @return {!Node}
 */
Node createNode(Document doc, String nodeName, String key, List statics) {
  if (nodeName == '#text') {
    return new Text(''); //doc.createTextNode('');
  }

  return createElement(doc, nodeName, key, statics);
}


/**
 * Creates a mapping that can be used to look up children using a key.
 * @param {!Node} el
 * @return {!Object<string, !Element>} A mapping of keys to the children of the
 *     Element.
 */
Map<String, Element> createKeyMap(Element el) {
  var map = <String, Element>{};
  var children = el.children;
  var count = children.length;

  for (var i = 0; i < count; i += 1) {
    var child = children[i];
    var key = getData(child).key;

    if (key != null) {
      map[key] = child;
    }
  }

  return map;
}


/**
 * Retrieves the mapping of key to child node for a given Element, creating it
 * if necessary.
 * @param {!Node} el
 * @return {!Object<string, !Node>} A mapping of keys to child Elements
 */
Map<String, Element> getKeyMap(Node el) {
  var data = getData(el);

  if (data.keyMap == null) {
    data.keyMap = createKeyMap(el);
  }

  return data.keyMap;
}

/**
 * Retrieves a child from the parent with the given key.
 * @param {!Node} parent
 * @param {?string=} key
 * @return {?Element} The child corresponding to the key.
 */
Element getChild(Node parent, String key) =>
    (key == null ? null : getKeyMap(parent)[key]);

/**
 * Registers an element as being a child. The parent will keep track of the
 * child using the key. The child can be retrieved using the same key using
 * getKeyMap. The provided key should be unique within the parent Element.
 * @param {!Node} parent The parent of child.
 * @param {string} key A key to identify the child with.
 * @param {!Node} child The child to register.
 */
void registerChild(Node parent, String key, Node child) {
  getKeyMap(parent)[key] = child;
}
