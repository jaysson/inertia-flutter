import 'package:flutter/widgets.dart';

import 'definitions.dart';
import 'models.dart';
import 'store.dart';

class InertiaScreen extends StatefulWidget {
  final RouteSettings settings;
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
  Stream<PageState>? pageStream;

  @override
  void initState() {
    super.initState();
    var path = widget.settings.name;
    if (path == null) {
      throw Exception("Path is required");
    }
    Inertia.get(path);
    pageStream = Inertia.getPageStream(path);
  }

  @override
  Widget build(BuildContext context) {
    if (pageStream == null) {
      throw Exception("Page stream is null");
    }
    return StreamBuilder<PageState>(
      builder: (_, snapshot) => widget.pageMaker(
        widget.settings,
        snapshot.data ?? PageState(isLoading: true),
      ),
      stream: pageStream,
    );
  }
}
