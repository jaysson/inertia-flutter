import 'package:flutter/widgets.dart';

import 'definitions.dart';
import 'models.dart';
import 'store.dart';

/// Wrapper for rendering components specified in [InertiaPage] response.
///
/// Initiates an Inertia request on mount, using the [settings.name] as the path/url.
/// Subscribes to the [PageState] stream for the same url
/// Calls [pageMaker] whenever the [PageState] is updated for the url
class InertiaScreen extends StatefulWidget {
  /// Passed to [pageMaker]
  final RouteSettings settings;

  /// This function returns the screen for a [PageState] and [RouteSettings]
  final PageMaker pageMaker;

  const InertiaScreen({
    required this.settings,
    required this.pageMaker,
    Key? key,
  }) : super(key: key);

  @override
  _InertiaScreenState createState() => _InertiaScreenState();
}

class _InertiaScreenState extends State<InertiaScreen> {
  late Stream<PageState> _pageStream;

  @override
  void initState() {
    super.initState();
    var path = widget.settings.name;
    if (path == null) {
      throw Exception("Path is required");
    }
    Inertia.get(path);
    _pageStream = Inertia.getPageStream(path);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PageState>(
      builder: (_, snapshot) => widget.pageMaker(
        widget.settings,
        snapshot.data ?? PageState(isLoading: true),
      ),
      stream: _pageStream,
    );
  }
}
