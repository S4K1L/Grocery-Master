import '../services/accounts_db.dart';

class Account {
  String? uid;
  String? username;

  String? id;
  String? type;
  String? phone;
  String? pass;
  String? email;

  Account({
    this.uid,
    this.id,
    this.username,
    this.pass,
    this.phone,
    this.type,
    this.email,
  });

  List<Account> accountList = [];

  // getting the list
  Future<bool> getListAccount() async {
    accountList = [];

    List? jsonList = await AccountsDB().createAccountDataList();
    if (jsonList != null) {
      for (var element in jsonList) {
        var data = element.data();
        accountList.add(Account(
          uid: data["uid"],
          id: data["id"],
          username: data["username"],
          pass: data["password"],
          phone: data["phone"],
          type: data["type"],
          email: data["email"],
        ));
      }
      print("\t\t\t\tGot Account list");
      return true;
    } else {
      print("\t\t\t\tFailed to fetch Account list");
      return false;
    }
  }
}
