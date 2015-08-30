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
import 'package:incremental-dom/incremental-dom.dart' show patch, text;

main() {
  group('text nodes', () {
    Element container;

    setUp(() {
      container = document.createElement('div');
      document.body.append(container);
    });

    tearDown(() {
      container.remove();
    });

    group('when created', () {
      test('should render a text node with the specified value', () {
        patch(container, (_) {
          text('Hello world!');
        });
        Node node = container.childNodes[0];

        expect(node.text, 'Hello world!');
        expect(node, new isInstanceOf<Text>());
      });

      test('should allow for multiple text nodes under one parent element', () {
        patch(container, (_) {
          text('Hello ');
          text('World');
          text('!');
        });

        expect(container.text, 'Hello World!');
      });
    });

    group('with conditional text', () {
      render(data) {
        text(data);
      }

      test('should update the DOM when the text is updated', () {
        patch(container, (_) => render('Hello'));
        patch(container, (_) => render('Hello World!'));
        Node node = container.childNodes[0];

        expect(node.text, 'Hello World!');
      });
    });
  });
}
