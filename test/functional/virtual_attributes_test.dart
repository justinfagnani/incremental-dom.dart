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
    attr;

main() {
  group('virtual attribute updates', () {
    var container;

    setUp(() {
      container = document.createElement('div');
      document.body.append(container);
    });

    tearDown(() {
      container.remove();
    });

    group('for conditional attributes', () {
      render(Map obj) {
        elementOpenStart('div', '', []);
          // the check is supposed to be for JS-truthiness
          if (obj.containsKey('key') && obj['key'] != null && obj['key'] != false) {
            attr('data-expanded', obj['key']);
          }
        elementOpenEnd();
        elementClose('div');
      }

      test('should be present when specified', () {
        patch(container, (_) => render({
          'key': 'hello'
        }));
        var el = container.childNodes[0];

        expect(el.getAttribute('data-expanded'), 'hello');
      });

      test('should be not present when not specified', () {
        patch(container, (_) => render({
          'key': false
        }));
        var el = container.childNodes[0];

        expect(el.getAttribute('data-expanded'), null);
      });

      test('should update the DOM when they change', () {
        patch(container, (_) => render({
          'key': 'foo'
        }));
        patch(container, (_) => render({
          'key': 'bar'
        }));
        var el = container.childNodes[0];

        expect(el.getAttribute('data-expanded'), 'bar');
      });
    });

  });
}
