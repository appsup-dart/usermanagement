// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library usermanagement;

import 'package:rpc/rpc.dart';
import 'dart:async';
import 'dart:math';
import 'package:mailer/mailer.dart';
import 'dart:io';
import 'dart:convert';

part 'src/app.dart';
part 'src/userbase.dart';
part 'src/api.dart';
part 'src/tokens.dart';

String rootDataDir = new String.fromEnvironment("usermanagement_home",defaultValue: "data");

final Map<String, AccessToken> tokens = {};


