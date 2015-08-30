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

import 'tree_walker.dart' show TreeWalker;

/**
 * @type {TreeWalker}
 */
TreeWalker _walker;


/**
 * @return {TreeWalker} the current TreeWalker
 */
TreeWalker getWalker() => _walker;

/**
 * Sets the current TreeWalker
 * @param {TreeWalker} walker
 */
void setWalker(walker) {
  _walker = walker;
}
