import 'package:dio/dio.dart';
import 'package:fyx/model/Credentials.dart';

abstract class IApiProvider {
  Future<Credentials> getCredentials();
  void setCredentials(Credentials val);
  Future<Response> login(String username);
  Future<Response> fetchBookmarks();
  Future<Response> fetchHistory();
  Future<Response> fetchDiscussion(int id);
}
