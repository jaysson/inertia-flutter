import 'package:flutter/material.dart';
import 'package:inertia_flutter/inertia_flutter.dart';
import 'package:inertia_flutter_example/components/drawer.dart';
import 'package:inertia_flutter_example/models/organisations.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

String? _getNextPageFromProps(props) => props['organizations']['next_page_url'];

List<OrganizationPreview> _getOrganisationsFromProps(props) =>
    List<OrganizationPreview>.from(
      props['organizations']['data'].map(
        (item) => OrganizationPreview.fromMap(item),
      ),
    );

class OrganizationsScreen extends StatefulWidget {
  final List<OrganizationPreview> data;
  final String? nextPage;

  const OrganizationsScreen({
    Key? key,
    required this.data,
    required this.nextPage,
  }) : super(key: key);

  factory OrganizationsScreen.fromProps(Map<String, dynamic> props) {
    return OrganizationsScreen(
      data: _getOrganisationsFromProps(props),
      nextPage: _getNextPageFromProps(props),
    );
  }

  @override
  _OrganizationsScreenState createState() => _OrganizationsScreenState();
}

class _OrganizationsScreenState extends State<OrganizationsScreen> {
  late PagingController<String?, OrganizationPreview> _pagingController;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController(firstPageKey: widget.nextPage);
    _pagingController.itemList = widget.data;
    _pagingController.addPageRequestListener(_handlePageRequest);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Organizations"),
      ),
      drawer: AppDrawer(),
      body: Column(
        children: [
          Expanded(
            child: PagedListView.separated(
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<OrganizationPreview>(
                  itemBuilder: _buildItem),
              separatorBuilder: _separatorBuilder,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, OrganizationPreview item, int index) {
    return ListTile(
      title: Text(item.name),
      subtitle: Text('${item.city} - ${item.phone}'),
    );
  }

  void _handlePageRequest(String? nextPage) async {
    if (nextPage != null) {
      final data = await Inertia.get(nextPage);
      if (data != null) {
        final organisations = _getOrganisationsFromProps(data.props);
        final nextPage = _getNextPageFromProps(data.props);
        if (nextPage == null) {
          _pagingController.appendLastPage(organisations);
        } else {
          _pagingController.appendPage(organisations, nextPage);
        }
      }
    }
  }

  Widget _separatorBuilder(BuildContext context, int index) {
    return Divider();
  }
}
