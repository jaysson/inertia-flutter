import 'package:flutter/widgets.dart';
import 'package:inertia_flutter/inertia_flutter.dart';

import 'definitions.dart';
import 'models.dart';
import 'store.dart';

/// As opposed to [InertiaScreen] which renders the whole screen, [InertiaFrame] is meant to be used to lazy load parts of the screen.
/// Tabs and bottom sheets are a good use case for this.
/// By default, the redirects are handled within the frame, without causing any navigation in the app.
/// You can set [confineRedirects] to `true` to override this behaviour.
///
/// Initiates an Inertia request on mount for the given path/url
/// Subscribes to the [PageState] stream for the same url
/// Calls [frameMaker] whenever the [PageState] is updated for the url
class InertiaFrame extends StatefulWidget {
  /// Path/url to load
  final String path;

  /// Whether to follow redirects inside the frame or let the app navigation handle it.
  final bool? confineRedirects;

  /// Callback to render the frame
  final FrameMaker frameMaker;

  const InertiaFrame({
    required this.frameMaker,
    required this.path,
    this.confineRedirects,
    Key? key,
  }) : super(key: key);

  @override
  _InertiaFrameState createState() => _InertiaFrameState();
}

class _InertiaFrameState extends State<InertiaFrame> {
  Stream<PageState>? pageStream;

  @override
  void initState() {
    super.initState();
    Inertia.get(widget.path, followRedirects: widget.confineRedirects ?? true);
    pageStream = Inertia.getPageStream(widget.path);
  }

  @override
  Widget build(BuildContext context) {
    if (pageStream == null) {
      throw Exception("Page stream is null");
    }
    return StreamBuilder<PageState>(
      builder: (_, snapshot) => widget.frameMaker(
        widget.path,
        snapshot.data ?? PageState(isLoading: true),
      ),
      stream: pageStream,
    );
  }
}
