// import 'package:flutter/foundation.dart' show kIsWeb;

// export 'file_utils_io.dart' if (dart.library.html) 'file_utils_web.dart';
// //
import 'package:flutter/foundation.dart' show kIsWeb;

export 'web_utils_stub.dart' if (dart.library.html) 'web_utils.dart';
