import '../../const/app_const.dart';
import '../storage_manager.dart';

mixin Concatenated {
  String get userName =>
      StorageManager.getString(AppConst.identifier.username) ?? '';

  bool isUserEmpty() {
    return userName.isEmpty;
  }

  String get name => StorageManager.getString(AppConst.identifier.name) ?? '';

  bool isNameEmpty() {
    return name.isEmpty;
  }
}
