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
    elementOpen,
    elementOpenStart,
    elementOpenEnd,
    elementClose,
    elementVoid,
    text;

main() {
  group('patching an element', () {
    var container;

    setUp(() {
      container = document.createElement('div');
      document.body.append(container);
    });

    tearDown(() {
      container.remove();
    });

    group('with an existing document tree', () {
      var div;

      render(_) {
        elementVoid('div', null, null,
            ['tabindex', '0']);
      }

      setUp(() {
        div = document.createElement('div');
        div.setAttribute('tabindex', '-1');
        container.append(div);
      });

      test('should preserve existing nodes', () {
        patch(container, render);
        var child = container.childNodes[0];

        expect(child, div);
      });

      test('should update attributes', () {
        patch(container, render);
        var child = container.childNodes[0];

        expect(child.getAttribute('tabindex'), '0');
      });

      group('should return DOM node', () {
        var node;

        test('from elementOpen', () {
          patch(container, (_) {
            node = elementOpen('div');
            elementClose('div');
          });

          expect(node, div);
        });

        test('from elementClose', () {
          patch(container, (_) {
            elementOpen('div');
            node = elementClose('div');
          });

          expect(node, div);
        });

        test('from elementVoid', () {
          patch(container, (_) {
            node = elementVoid('div');
          });

          expect(node, div);
        });

        test('from elementOpenEnd', () {
          patch(container, (_) {
            elementOpenStart('div');
            node = elementOpenEnd('div');
            elementClose('div');
          });

          expect(node, div);
        });
      });
    });

    test('should be re-entrant', () {
      var containerOne = document.createElement('div');
      var containerTwo = document.createElement('div');

      renderTwo(_) {
        text('foobar');
      }

      renderOne(_) {
        elementOpen('div');
          patch(containerTwo, renderTwo);
          text('hello');
        elementClose('div');
      }

      patch(containerOne, renderOne);

      expect(containerOne.text, 'hello');
      expect(containerTwo.text, 'foobar');
    });

    test('should pass third argument to render function', () {
      render(content) {
        text(content);
      }

      patch(container, render, 'foobar');

      expect(container.text, 'foobar');
    });
  });

  group('patching a documentFragment', () {
    test('should create the required DOM nodes', () {
      var frag = document.createDocumentFragment();

      patch(frag, (_) {
        elementOpen('div', null, null,
            ['id', 'aDiv']);
        elementClose('div');
      });

      expect(frag.childNodes[0].id, 'aDiv');
    });
  });
}
