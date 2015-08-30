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
    elementVoid;

main() {
  group('element creation', () {
    Element container;
    // var sandbox = sinon.sandbox.create();

    setUp(() {
      container = document.createElement('div');
      document.body.append(container);
    });

    tearDown(() {
      // sandbox.restore();
      container.remove();
      // document.body.removeChild(container);
    });

    group('when creating a single node', () {
      Element el;

      setUp(() {
        patch(container, (_) {
          elementVoid('div', '', ['id', 'someId', 'class', 'someClass', 'data-custom', 'custom'],
              ['data-foo', 'Hello',
               'data-bar', 'World']);
        });

        el = container.childNodes[0];
      });

      test('should render with the specified tag', () {
        expect(el.tagName, 'DIV');
      });

      test('should render with static attributes', () {
        expect(el.id, 'someId');
        expect(el.className, 'someClass');
        expect(el.getAttribute('data-custom'), 'custom');
      });

      test('should render with dynamic attributes', () {
        expect(el.getAttribute('data-foo'), 'Hello');
        expect(el.getAttribute('data-bar'), 'World');
      });

      group('should return DOM node', () {
        setUp(() {
          patch(container, (_) {});
        });

        test('from elementOpen', () {
          patch(container, (_) {
            el = elementOpen('div');
            elementClose('div');
          });

          expect(el, container.childNodes[0]);
        });

        test('from elementClose', () {
          patch(container, (_) {
            elementOpen('div');
            el = elementClose('div');
          });

          expect(el, container.childNodes[0]);
        });

        test('from elementVoid', () {
          patch(container, (_) {
            el = elementVoid('div');
          });

          expect(el, container.childNodes[0]);
        });

        test('from elementOpenEnd', () {
          patch(container, (_) {
            elementOpenStart('div');
            el = elementOpenEnd();
            elementClose('div');
          });

          expect(el, container.childNodes[0]);
        });
      });

    });

    test('should allow creation without static attributes', () {
      patch(container, (_) {
        elementVoid('div', '', null,
            ['id', 'test']);
      });
      Element el = container.childNodes[0];
      expect(el.id, 'test');
    });

    group('for HTML elements', () {
      test('should use the XHTML namespace', () {
        patch(container, (_) {
          elementVoid('div');
        });

        Element el = container.childNodes[0];
        expect(el.namespaceUri, 'http://www.w3.org/1999/xhtml');
      });

      // test('should use createElement if no namespace has been specified', () {
      //   var doc = container.ownerDocument;
      //   var div = doc.createElement('div');
      //   sandbox.stub(doc, 'createElement').returns(div);
      //
      //   patch(container, () => {
      //     elementVoid('div');
      //   });
      //
      //   var el = container.childNodes[0];
      //   expect(el.namespaceUri, 'http://www.w3.org/1999/xhtml');
      //   expect(doc.createElement).to.have.been.calledOnce;
      // });
    });

    group('for svg elements', () {
      setUp(() {
        patch(container, (_) {
          elementOpen('svg');
            elementOpen('g');
              elementVoid('circle');
            elementClose('g');
            elementOpen('foreignObject');
              elementVoid('p');
            elementClose('foreignObject');
            elementVoid('path');
          elementClose('svg');
        });
      });

      test('should create svgs in the svg namespace', () {
        var el = container.querySelector('svg');
        expect(el.namespaceUri, 'http://www.w3.org/2000/svg');
      });

      test('should create descendants of svgs in the svg namespace', () {
        var el = container.querySelector('circle');
        expect(el.namespaceUri, 'http://www.w3.org/2000/svg');
      });

      test('should have the svg namespace for foreignObjects', () {
        var el = container.querySelector('svg').childNodes[1];
        expect(el.namespaceUri, 'http://www.w3.org/2000/svg');
      });

      test('should revert to the xhtml namespace when encounering a foreignObject', () {
        var el = container.querySelector('p');
        expect(el.namespaceUri, 'http://www.w3.org/1999/xhtml');
      });

      test('should reset to the previous namespace after exiting a forignObject', () {
        var el = container.querySelector('path');
        expect(el.namespaceUri, 'http://www.w3.org/2000/svg');
      });

      test('should create children in the svg namespace when patching an svg', () {
        var svg = container.querySelector('svg');
        patch(svg, (_) {
          elementVoid('rect');
        });

        var el = svg.querySelector('rect');
        expect(el.namespaceUri, 'http://www.w3.org/2000/svg');
      });
    });
  });
}
