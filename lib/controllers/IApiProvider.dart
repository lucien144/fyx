import 'package:dio/dio.dart';
import 'package:fyx/model/Credentials.dart';

typedef TOnError = void Function(String);
typedef TOnAuthError = void Function();

abstract class IApiProvider {
  TOnError onError;
  TOnAuthError onAuthError;

  Future<Credentials> getCredentials();
  void setCredentials(Credentials val);
  Future<Response> login(String username);
  Future<Response> fetchBookmarks();
  Future<Response> fetchHistory();
  Future<Response> fetchDiscussion(int id, {int lastId});
  Future<Response> postDiscussionMessage(int id, String message, {List<Map<String, dynamic>> attachments});
}
