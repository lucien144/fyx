import 'package:dio/dio.dart';
import 'package:fyx/model/Credentials.dart';

typedef TOnError = void Function(String);
typedef TOnAuthError = void Function(String);
typedef TOnContextData = void Function(Map<String, dynamic>);

enum ATTACHMENT { bytes, filename, mime, extension, mediatype }

abstract class IApiProvider {
  TOnError onError;
  TOnAuthError onAuthError;
  TOnContextData onContextData;

  Credentials getCredentials();
  Credentials setCredentials(Credentials val);
  Future<Response> login(String username);
  Future<Response> logout();
  Future<Response> registerFcmToken(String token);
  Future<Response> fetchBookmarks();
  Future<Response> fetchHistory();
  Future<Response> fetchDiscussion(int id, {int lastId, String user});
  Future<Response> fetchDiscussionHome(int id);
  Future<Response> fetchMail({int lastId});
  Future<Response> fetchNotices();
  Future<Response> sendMail(String recipient, String message, {List<Map<ATTACHMENT, dynamic>> attachments});
  Future<Response> postDiscussionMessage(int id, String message, {List<Map<ATTACHMENT, dynamic>> attachments});
  Future<Response> setPostReminder(int discussionId, int postId, bool setReminder);
  Future<Response> giveRating(int discussionId, int postId, bool add, bool confirm, bool remove);
}
