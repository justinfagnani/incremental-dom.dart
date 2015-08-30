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
import 'node_data.dart' show getData;
import 'package:reflectable/reflectable.dart' show Reflectable, InstanceMirror,
  instanceInvokeCapability;

const reflectable = const Reflectable(instanceInvokeCapability);

/**
 * Applies an attribute or property to a given Element. If the value is null
 * or undefined, it is removed from the Element. Otherwise, the value is set
 * as an attribute.
 * @param {!Element} el
 * @param {string} name The attribute's name.
 * @param {?(boolean|number|string)=} value The attribute's value.
 */
void applyAttr(Element el, String name, value) {
  if (value == null) {
    el.attributes.remove(name);
  } else {
    el.attributes[name] = value.toString();
  }
}

/**
 * Applies a property to a given Element.
 * @param {!Element} el
 * @param {string} name The property's name.
 * @param {*} value The property's value.
 */
void applyProp(Element el, String name, value) {
  reflectable.reflect(el).invokeSetter(name, value);
}

/**
 * Applies a style to an Element. No vendor prefix expansion is done for
 * property names/values.
 * @param {!Element} el
 * @param {string} name The attribute's name.
 * @param {string|Object<string,string>} style The style to set. Either a
 *     string of css or an object containing property-value pairs.
 */
void applyStyle(Element el, String name, style) {
  if (style is String) {
    el.style.cssText = style;
  } else {
    el.style.cssText = '';

    var styleMap = style as Map<String, String>;
    for (var prop in styleMap.keys) {
      el.style.setProperty(prop, style[prop]);
    }
  }
}

/**
 * Updates a single attribute on an Element.
 * @param {!Element} el
 * @param {string} name The attribute's name.
 * @param {*} value The attribute's value. If the value is an object or
 *     function it is set on the Element, otherwise, it is set as an HTML
 *     attribute.
 */
void applyAttributeTyped(Element el, String name, value) {
  print('applyAttributeTyped value: $value type ${value.runtimeType}');
  if (value is String || value is num || value is bool || value == null) {
    applyAttr(el, name, value);
  } else {
    applyProp(el, name, value);
  }
}

/**
 * Calls the appropriate attribute mutator for this attribute.
 * @param {!Element} el
 * @param {string} name The attribute's name.
 * @param {*} value The attribute's value.
 */
void updateAttribute(Element el, String name, value) {
  var data = getData(el);
  var attrs = data.attrs;

  if (attrs[name] == value) {
    return;
  }

  // TODO(justinfagnani): Rip all of this out?
  var mutator = mutators[name] ?? mutators['__all'];
  mutator(el, name, value);

  attrs[name] = value;
}

/**
 * Exposes our default attribute mutators publicly, so they may be used in
 * custom mutators.
 * @const {!Object<string, function(!Element, string, *)>}
 */
var defaults = {
  applyAttr: applyAttr,
  applyProp: applyProp,
  applyStyle: applyStyle,
};


/**
 * A publicly mutable object to provide custom mutators for attributes.
 * @const {!Object<string, function(!Element, string, *)>}
 */
Map<String, Function> mutators = <String, Function>{
  // Special generic mutator that's called for any attribute that does not
  // have a specific mutator.
  '__all': applyAttributeTyped,

  // Special case the style attribute
  'style': applyStyle
};
