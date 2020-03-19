import 'package:fyx/model/Credentials.dart';

class MainRepository {
  static final MainRepository _singleton = MainRepository._internal();
  Credentials _credentials;

  factory MainRepository() {
    return _singleton;
  }

  MainRepository._internal();

  set credentials(Credentials value) {
    _credentials = value;
  }

  Credentials get credentials => _credentials;
}
