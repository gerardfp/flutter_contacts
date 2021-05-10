import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SelectedContactsModel>(
          create: (context) => SelectedContactsModel(),
        )
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    var selectedContacts = context.watch<SelectedContactsModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text("Contacts"),
      ),
      body: ListView.builder(
        itemCount: selectedContacts.selectedContacts?.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          Contact contact = selectedContacts.selectedContacts[
              selectedContacts.selectedContacts.keys.elementAt(index)];
          return ListTile(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 2, horizontal: 18),
            leading: (contact.avatar != null && contact.avatar.isNotEmpty)
                ? CircleAvatar(
                    backgroundImage: MemoryImage(contact.avatar),
                  )
                : CircleAvatar(
                    child: Text(contact.initials()),
                    backgroundColor: Theme.of(context).accentColor,
                  ),
            title: Text(contact.displayName ?? ''),
            onTap: () {
              selectedContacts.toggle(contact);
            },
            selected: selectedContacts.isSelected(contact),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openContacts();
        },
        tooltip: 'Contacts',
        child: Icon(Icons.add),
      ),
    );
  }

  void openContacts() async {
    if (await Permission.contacts.request().isGranted) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ContactsPage()));
    }
  }
}

class ContactsPage extends StatefulWidget {
  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  Iterable<Contact> _contacts;

  @override
  void initState() {
    getContacts();
    super.initState();
  }

  getContacts() async {
    final Iterable<Contact> contacts = await ContactsService.getContacts();
    setState(() {
      _contacts = contacts;
    });
  }

  @override
  Widget build(BuildContext context) {
    var selectedContacts = context.watch<SelectedContactsModel>();

    return Scaffold(
      appBar: AppBar(
        title: (Text('Contacts')),
      ),
      body: _contacts != null
          ? ListView.builder(
              itemCount: _contacts?.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                Contact contact = _contacts?.elementAt(index);
                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 18),
                  leading: (contact.avatar != null && contact.avatar.isNotEmpty)
                      ? CircleAvatar(
                          backgroundImage: MemoryImage(contact.avatar),
                        )
                      : CircleAvatar(
                          child: Text(contact.initials()),
                          backgroundColor: Theme.of(context).accentColor,
                        ),
                  title: Text(contact.displayName ?? ''),
                  onTap: () {
                    selectedContacts.toggle(contact);
                  },
                  selected: selectedContacts.isSelected(contact),
                );
              },
            )
          : Center(child: const CircularProgressIndicator()),
    );
  }
}

class SelectedContactsModel extends ChangeNotifier {
  final _selectedContacts = {};

  get selectedContacts => _selectedContacts;

  void select(Contact contact) {
    _selectedContacts.putIfAbsent(contact.displayName, () => contact);
    notifyListeners();
  }

  void unselect(Contact contact) {
    _selectedContacts.remove(contact.displayName);
    notifyListeners();
  }

  bool isSelected(Contact contact) {
    return _selectedContacts.containsKey(contact.displayName);
  }

  void toggle(Contact contact) {
    if (isSelected(contact))
      unselect(contact);
    else
      select(contact);
  }
}
