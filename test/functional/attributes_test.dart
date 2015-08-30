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
    elementOpenStart,
    elementOpenEnd,
    attr,
    elementClose,
    elementVoid;

main() {
  group('attribute updates', () {
    var container;

    setUp(() {
      container = document.createElement('div');
      document.body.append(container);
    });

    tearDown(() {
      container.remove();
    });

    group('for conditional attributes', () {
      render(Map attrs) {
        elementOpenStart('div', '', []);
        for (var attrName in attrs.keys) {
          attr(attrName, attrs[attrName]);
        }
        elementOpenEnd();
        elementClose('div');
      }

      test('should be present when they have a value', () {
        patch(container, (_) => render({
          'data-expanded': 'hello'
        }));
        var el = container.childNodes[0];

        expect(el.getAttribute('data-expanded'), 'hello');
      });

      test('should be present when falsy', () {
        patch(container, (_) => render({
          'data-expanded': false
        }));
        var el = container.childNodes[0];

        expect(el.getAttribute('data-expanded'), 'false');
      });

      test('should be not present when undefined', () {
        patch(container, (_) => render({
          'id': null,
          'tabindex': null,
          'data-expanded': null,
        }));
        var el = container.childNodes[0];

        expect(el.getAttribute('data-expanded'), null);
        expect(el.getAttribute('id'), null);
        expect(el.getAttribute('tabindex'), null);
      });

      test('should update the DOM when they change', () {
        patch(container, (_) => render({
          'data-expanded': 'foo'
        }));
        patch(container, (_) => render({
          'data-expanded': 'bar'
        }));
        var el = container.childNodes[0];

        expect(el.getAttribute('data-expanded'), 'bar');
      });

      test('should update attribute in different position', () {
        patch(container, (_) => render({
          'data-foo': 'foo'
        }));
        patch(container, (_) => render({
          'data-bar': 'foo'
        }));
        var el = container.childNodes[0];

        expect(el.getAttribute('data-bar'), 'foo');
        expect(el.getAttribute('data-foo'), null);
      });

      test('should remove trailing attributes when missing', () {
        patch(container, (_) => render({
          'data-foo': 'foo',
          'data-bar': 'bar'
        }));
        patch(container, (_) => render({}));
        var el = container.childNodes[0];

        expect(el.getAttribute('data-foo'), null);
        expect(el.getAttribute('data-bar'), null);
      });
    });

    // group('for function attributes', () {
    //   test('should not be set as attributes', () {
    //     var fn = () => {};
    //     patch(container, (_) {
    //       elementVoid('div', '', null,
    //           ['fn', fn]);
    //     });
    //     var el = container.childNodes[0];
    //
    //     expect(el.hasAttribute('fn'), false);
    //   });
    //
    //   test('should be set on the node', () {
    //     var fn = () => {};
    //     patch(container, (_) {
    //       elementVoid('div', '', null,
    //           ['fn', fn]);
    //     });
    //     var el = container.childNodes[0];
    //
    //     expect(el.fn, fn);
    //   });
    // });
    //
    // group('for object attributes', () {
    //   test('should not be set as attributes', () {
    //     var obj = {};
    //     patch(container, (_) {
    //       elementVoid('div', '', null,
    //           ['obj', obj]);
    //     });
    //     var el = container.childNodes[0];
    //
    //     expect(el.hasAttribute('obj'), false);
    //   });
    //
    //   test('should be set on the node', () {
    //     var obj = {};
    //     patch(container, (_) {
    //       elementVoid('div', '', null,
    //           ['obj', obj]);
    //     });
    //     var el = container.childNodes[0];
    //
    //     expect(el.obj, obj);
    //   });
    // });

    // group('for style', () {
    //   render(style) {
    //     elementVoid('div', '', [],
    //         ['style', style]);
    //   }
    //
    //   test('should render with the correct style properties for objects', () {
    //     patch(container, (_) => render({
    //       'color': 'white',
    //       'backgroundColor': 'red'
    //     }));
    //     var el = container.childNodes[0];
    //
    //     expect(el.style.color, 'white');
    //     expect(el.style.backgroundColor, 'red');
    //   });
    //
    //   test('should update the correct style properties', () {
    //     patch(container, (_) => render({
    //       'color': 'white'
    //     }));
    //     patch(container, (_) => render({
    //       'color': 'red'
    //     }));
    //     var el = container.childNodes[0];
    //
    //     expect(el.style.color, 'red');
    //   });
    //
    //   test('should remove properties not present in the new object', () {
    //     patch(container, (_) => render({
    //       'color': 'white'
    //     }));
    //     patch(container, (_) => render({
    //       'backgroundColor': 'red'
    //     }));
    //     var el = container.childNodes[0];
    //
    //     expect(el.style.color, '');
    //     expect(el.style.backgroundColor, 'red');
    //   });
    //
    //   test('should render with the correct style properties for strings', () {
    //     patch(container, (_) => render('color: white; background-color: red;'));
    //     var el = container.childNodes[0];
    //
    //     expect(el.style.color, 'white');
    //     expect(el.style.backgroundColor, 'red');
    //   });
    // });

    group('for svg elements', () {
      test('should correctly apply the class attribute', () {
        patch(container, (_) {
          elementVoid('svg', null, null,
              ['class', 'foo']);
        });
        var el = container.childNodes[0];

        expect(el.getAttribute('class'), 'foo');
      });
    });
  });
}
