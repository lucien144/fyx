import 'package:dio/dio.dart';
import 'package:fyx/model/Credentials.dart';

typedef TOnError = void Function(String);
typedef TOnAuthError = void Function(String);
typedef TOnContextData = void Function(Map<String, dynamic>);

enum ATTACHMENT { bytes, filename, mime, extension, mediatype, previewWidget }

abstract class IApiProvider {
  TOnError? onError;
  TOnAuthError? onAuthError;
  TOnContextData? onContextData;

  Credentials? getCredentials();
  Credentials? setCredentials(Credentials? val);
  Future<Response> login(String username);
  Future<Response> logout();
  Future<Response> registerFcmToken(String token);
  Future<Response> searchDiscussions(String term);
  Future<Response> search(String term, {int? lastId});
  Future<Response> fetchLast();
  Future<Response> fetchReminders();
  Future<Response> bookmarkDiscussion(int discussionId, bool state);
  Future<Response> fetchBookmarks();
  Future<Response> fetchHistory();
  Future<Response> fetchDiscussion(int id, {int? lastId, String? user, String? search, bool filterReplies});
  Future<Response> fetchDiscussionHome(int id);
  Future<Response> fetchDiscussionHeader(int id);
  Future<Response> setDiscussionRights(int id, {required String username, required String right, required bool set});
  Future<Response> setDiscussionRightsDaysLeft(int id, {required String username, required int daysLeft});
  Future<Response> fetchMail({int? lastId});
  Future<Response> fetchNotices();
  Future<Response> deleteFile(int id);
  Future<Response> fetchMailWaitingFiles();
  Future<Response> fetchDiscussionWaitingFiles(int id);
  Future<List> uploadFile(List<Map<ATTACHMENT, dynamic>> attachments, {int id});
  Future<Response> sendMail(String recipient, String message);
  Future<Response> postDiscussionMessage(int id, String message);
  Future<Response> deleteDiscussionMessage(int discussionId, int postId);
  Future<Response> setPostReminder(int discussionId, int postId, bool setReminder);
  Future<Response> giveRating(int discussionId, int postId, bool add, bool confirm, bool remove);
  Future<Response> getPostRatings(int discussionId, int postId);
  Future<Response> votePoll(int discussionId, int postId, List<int> votes);
  Future<Response> rollDice(int discussionId, int postId);

  Future<Response> discussionCreateRequest(int discussionId, int postId, [bool against = false]);
}
