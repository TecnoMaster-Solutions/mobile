import 'package:flutter/foundation.dart';

const String kBackendBaseUrl = kIsWeb
    ? 'http://localhost:3001'   // Flutter Web
    : 'http://10.0.2.2:3001';   // Emulador Android / iOS