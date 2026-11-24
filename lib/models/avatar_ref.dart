import 'package:flutter/foundation.dart';

/// Where a profile photo lives. A local [path] is the copy kept on the device;
/// [url] is the remote copy. Once uploads exist the service fills [url] and
/// clears [path], so widgets only ever receive this and never a storage detail.
@immutable
class AvatarRef {
  const new({this.path, this.url});

  static const AvatarRef none = AvatarRef();

  final String? path;
  final String? url;

  bool get isEmpty => path == null && url == null;
}
