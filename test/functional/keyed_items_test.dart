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

@TestOn('browser')
import 'dart:html';
import 'package:test/test.dart';
import 'package:incremental-dom/incremental-dom.dart' show
  patch,
  elementVoid;

main() {
  group('rendering with keys', () {
    var container;

    render(items) {
      for(var i=0; i<items.length; i++) {
        elementVoid('div', items[i]['key'], ['id', items[i]['key']]);
      }
    }

    setUp(() {
      container = document.createElement('div');
      document.body.append(container);
    });

    tearDown(() {
      container.remove();
    });

    test('should not re-use a node with a non-null key', () {
      var items = [
        { 'key': 'one' }
      ];

      patch(container, (_) => render(items));
      var keyedNode = container.childNodes[0];

      items.insert(0, { 'key' : null });
      patch(container, (_) => render(items));

      expect(container.childNodes.length, 2);
      expect(container.childNodes[0], isNot(keyedNode));
    });

    test('should not modify DOM nodes with falsey keys', () {
      // var slice = Array.prototype.slice;
      var items = [
        { 'key': null },
        { 'key': '' },
      ];

      patch(container, (_) => render(items));
      var nodes = new List.from(container.childNodes);

      patch(container, (_) => render(items));

      expect(container.childNodes, nodes);
    });

    test('should not modify the DOM nodes when inserting', () {
      var items = [
        { 'key': 'one' },
        { 'key': 'two' }
      ];

      patch(container, (_) => render(items));
      var firstNode = container.childNodes[0];
      var secondNode = container.childNodes[1];

      items.replaceRange(1, 1, [{ 'key': 'one-point-five' }]);
      patch(container, (_) => render(items));

      expect(container.childNodes.length, 3);
      expect(container.childNodes[0], firstNode);
      expect(container.childNodes[0].id, 'one');
      expect(container.childNodes[1].id, 'one-point-five');
      expect(container.childNodes[2], secondNode);
      expect(container.childNodes[2].id, 'two');
    });

    test('should not modify the DOM nodes when removing', () {
      var items = [
        { 'key': 'one' },
        { 'key': 'two' },
        { 'key': 'three' }
      ];

      patch(container, (_) => render(items));
      var firstNode = container.childNodes[0];
      var thirdNode = container.childNodes[2];

      // items.splice(1, 1);
      items.removeRange(1, 2);
      patch(container, (_) => render(items));

      expect(container.childNodes.length, 2);
      expect(container.childNodes[0], firstNode);
      expect(container.childNodes[0].id, 'one');
      expect(container.childNodes[1], thirdNode);
      expect(container.childNodes[1].id, 'three');
    });

    test('should not modify the DOM nodes when re-ordering', () {
      var items = [
        { 'key': 'one' },
        { 'key': 'two' },
        { 'key': 'three' }
      ];

      patch(container, (_) => render(items));
      var firstNode = container.childNodes[0];
      var secondNode = container.childNodes[1];
      var thirdNode = container.childNodes[2];

      // items.splice(1, 1);
      items.removeRange(1, 2);
      items.add({ 'key': 'two' });
      patch(container, (_) => render(items));

      expect(container.childNodes.length, 3);
      expect(container.childNodes[0], firstNode);
      expect(container.childNodes[0].id, 'one');
      expect(container.childNodes[1], thirdNode);
      expect(container.childNodes[1].id, 'three');
      expect(container.childNodes[2], secondNode);
      expect(container.childNodes[2].id, 'two');
    });
  });
}
