import 'package:flutter/widgets.dart';

import 'definitions.dart';
import 'models.dart';
import 'store.dart';

class InertiaFrame extends StatefulWidget {
  final String path;
  final bool? confineRedirects;
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
