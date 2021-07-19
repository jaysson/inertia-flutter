import 'package:flutter/material.dart';
import 'package:inertia_flutter/inertia_flutter.dart';
import 'package:inertia_flutter_example/components/drawer.dart';
import 'package:inertia_flutter_example/models/contacts.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

String? _getNextPageFromProps(props) => props['contacts']['next_page_url'];

List<ContactPreview> _getOrganisationsFromProps(props) =>
    List<ContactPreview>.from(
      props['contacts']['data'].map(
        (item) => ContactPreview.fromMap(item),
      ),
    );

class ContactsScreen extends StatefulWidget {
  final List<ContactPreview> data;
  final String? nextPage;

  const ContactsScreen({
    Key? key,
    required this.data,
    required this.nextPage,
  }) : super(key: key);

  factory ContactsScreen.fromProps(Map<String, dynamic> props) {
    return ContactsScreen(
      data: _getOrganisationsFromProps(props),
      nextPage: _getNextPageFromProps(props),
    );
  }

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  late PagingController<String?, ContactPreview> _pagingController;

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
        title: Text("Contacts"),
      ),
      drawer: AppDrawer(),
      body: Column(
        children: [
          Expanded(
            child: PagedListView.separated(
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<ContactPreview>(
                  itemBuilder: _buildItem),
              separatorBuilder: _separatorBuilder,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, ContactPreview item, int index) {
    return ListTile(
      title: Text(item.name),
      subtitle: Text('${item.organizationName} (${item.city}) - ${item.phone}'),
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
