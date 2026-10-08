import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app/magic_app.dart';
import 'app/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Resolve the base data directory.
  final appSupportDir = await getApplicationSupportDirectory();
  final baseDir = p.join(appSupportDir.path, 'Magic');
  await Directory(baseDir).create(recursive: true);

  runApp(
    ProviderScope(
      overrides: [
        baseDataDirProvider.overrideWithValue(baseDir),
      ],
      child: const MagicApp(),
    ),
  );
}
