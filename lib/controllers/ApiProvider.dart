import 'package:dio/dio.dart';
import 'package:fyx/controllers/IApiProvider.dart';
import 'package:fyx/model/Credentials.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/theme/L.dart';

class ApiProvider implements IApiProvider {
  final Dio dio = Dio();

  // ignore: non_constant_identifier_names
  final URL = 'https://nyx.cz/api';

  Credentials? _credentials;

  TOnError? onError;
  TOnAuthError? onAuthError;
  TOnContextData? onContextData;

  getCredentials() {
    if (_credentials != null && _credentials!.isValid) {
      return _credentials;
    }
    return null;
  }

  setCredentials(Credentials? creds) {
    if (creds != null && creds.isValid) {
      _credentials = creds;
    }
    return _credentials;
  }

  ApiProvider() {
    dio.interceptors.add(InterceptorsWrapper(onRequest: (RequestOptions options, RequestInterceptorHandler handler) async {
      try {
        // TODO: Perhaps, solve Czech characters too...
        // TODO: Get rid of MainRepository()
        var deviceName = MainRepository().deviceInfo.localizedModel.replaceAll(RegExp(r'[ʀ]', caseSensitive: false), 'r');
        deviceName = deviceName.replaceAll(RegExp(r'[^\w _\-]', caseSensitive: false), '_');
        options.headers['user-agent'] =
            'Fyx | ${MainRepository().deviceInfo.systemName} | ${MainRepository().packageInfo.version} (${MainRepository().packageInfo.buildNumber}) | $deviceName';
      } catch (e) {
        options.headers['user-agent'] = 'Fyx';
      }

      print('[API] UA: ${options.headers['user-agent']}');
      print('[API] ${options.method.toUpperCase()}: ${options.uri}');

      if (_credentials != null && _credentials!.isValid) {
        print('[API] -> Bearer: ${_credentials!.token}');
        options.headers['Authorization'] = 'Bearer ${_credentials!.token}';
      }
      return handler.next(options);
    }, onResponse: (Response response, ResponseInterceptorHandler handler) async {
      if (response.data is Map && response.data.containsKey('context')) {
        if (onContextData != null) {
          onContextData!(response.data['context']);
        }
      }

      // All seems ok.
      if (response.statusCode == 200) {
        return handler.next(response);
      }

      // Negative rating confirmation
      if (response.statusCode == 403 && ['NeedsConfirmation'].contains(response.data?['code'])) {
        return handler.next(response);
      }

      // Malformed response
      if (onError != null) {
        onError!(L.API_ERROR);
      }
      return handler.next(response);
    }, onError: (DioError e, ErrorInterceptorHandler handler) async {
      // Not Authorized
      if (e.response?.statusCode == 401) {
        if (onAuthError != null) {
          onAuthError!(e.response!.data['message']);
        }
        return handler.next(e);
      }

      // Other problem
      if ([400, 404].contains(e.response?.statusCode)) {
        if (onError != null) {
          onError!(e.response!.data['message']);
        }
        return handler.next(e);
      }

      if (onError != null) {
        if (e.message?.contains('SocketException') ?? false) {
          onError!(L.CONNECTION_ERROR);
        } else {
          onError!(e.message ?? '');
        }
      }
    }));
  }

  Future<Response> login(String username) async {
    return await dio.post('$URL/create_token/$username');
  }

  Future<Response> registerFcmToken(String token) async {
    String client = 'fyx';
    return await dio.post('$URL/register_for_notifications/${_credentials?.token}/$client/$token');
  }

  Future<Response> searchDiscussions(String term) async {
    return await dio.get('$URL/search/unified?search=$term&limit=100');
  }

  Future<Response> search(String term, {int? lastId}) async {
    Map<String, dynamic> params = {'order': lastId == null ? 'newest' : 'older_than', 'from_id': lastId, 'text': term};
    return await dio.get('$URL/search', queryParameters: params);
  }

  Future<Response> fetchLast() async {
    return await dio.get('$URL/last');
  }

  Future<Response> fetchReminders() async {
    return await dio.get('$URL/bookmarks/reminders');
  }

  Future<Response> fetchBookmarks() async {
    return await dio.get('$URL/bookmarks/all');
  }

  Future<Response> fetchHistory() async {
    return await dio.get('$URL/bookmarks/history', queryParameters: {'more_results': true, 'show_read': true});
  }

  Future<Response> fetchDiscussion(int discussionId, {int? lastId, String? user, String? search, bool filterReplies = false}) async {
    Map<String, dynamic> params = {'order': lastId == null ? 'newest' : 'older_than', 'from_id': lastId, 'user': user, 'text': search};
    if (lastId != null && filterReplies) {
      return await dio.get('$URL/discussion/$discussionId/id/$lastId/replies');
    }
    return await dio.get('$URL/discussion/$discussionId', queryParameters: params);
  }

  Future<Response> bookmarkDiscussion(int discussionId, bool state) async {
    Map<String, dynamic> params = {'new_state': state};
    return await dio.post('$URL/discussion/$discussionId/bookmark', queryParameters: params);
  }

  Future<Response> fetchDiscussionHome(int id) async {
    return await dio.get('$URL/discussion/$id/content/home');
  }

  Future<Response> setDiscussionRights(int id, {required String username, required String right, required bool set}) async {
    return await dio.post('$URL/discussion/rights?discussion_id=$id&username=$username&right=$right&set=${set ? 'true' : 'false'}');
  }

  Future<Response> setDiscussionRightsDaysLeft(int id, {required String username, required int daysLeft}) async {
    return await dio.post('$URL/discussion/rights/days_left?discussion_id=$id&username=$username&days_left=$daysLeft');
  }

  Future<Response> fetchDiscussionHeader(int id) async {
    return await dio.get('$URL/discussion/$id/content/header');
  }

  Future<Response> fetchNotices() async {
    return await dio.get('$URL/notifications');
  }

  Future<Response> postDiscussionMessage(int discussionId, String message) async {
    return await dio.post('$URL/discussion/$discussionId/send/text',
        data: {'content': message, 'format': 'html'}, options: Options(contentType: Headers.formUrlEncodedContentType));
  }

  Future<Response> deleteDiscussionMessage(int discussionId, int postId) async {
    return await dio.delete('$URL/discussion/$discussionId/delete/$postId');
  }

  Future<Response> setPostReminder(int discussionId, int postId, bool setReminder) async {
    return await dio.post('$URL/discussion/$discussionId/reminder/$postId/$setReminder');
  }

  Future<Response> getPostRatings(int discussionId, int postId) async {
    return await dio.get('$URL/discussion/$discussionId/rating/$postId');
  }

  Future<Response> giveRating(int discussionId, int postId, bool positive, bool confirm, bool remove) async {
    String action = positive ? 'positive' : 'negative';
    action = remove ? 'remove' : action;
    action = confirm ? 'negative_visible' : action;
    return await dio.post('$URL/discussion/$discussionId/rating/$postId/$action', options: Options(validateStatus: (status) => status! < 500));
  }

  Future<Response> logout() async {
    return await dio.delete('$URL/profile/delete_token/${_credentials?.token}');
  }

  Future<Response> fetchMail({int? lastId, String? username}) async {
    Map<String, dynamic> params = {'order': lastId == null ? 'newest' : 'older_than', 'from_id': lastId, 'user': username};
    return await dio.get('$URL/mail', queryParameters: params);
  }

  Future<Response> sendMail(String recipient, String message) async {
    return await dio.post('$URL/mail/send',
        data: {'recipient': recipient, 'message': message, 'format': 'html'}, options: Options(contentType: Headers.formUrlEncodedContentType));
  }

  Future<Response> deleteFile(int id) async {
    return await dio.delete('$URL/file/delete/$id');
  }

  Future<Response> fetchMailWaitingFiles() async {
    return await dio.get('$URL/mail/waiting_files');
  }

  Future<Response> fetchDiscussionWaitingFiles(int id) async {
    return await dio.get('$URL/discussion/$id/waiting_files');
  }

  Future<List> uploadFile(List<Map<ATTACHMENT, dynamic>> attachments, {int id = 0}) async {
    List<Future> uploads = [];
    for (Map<ATTACHMENT, dynamic> attachment in attachments) {
      FormData fileData = new FormData.fromMap({
        'file': MultipartFile.fromBytes(attachment[ATTACHMENT.bytes],
            filename: attachment[ATTACHMENT.filename], contentType: attachment[ATTACHMENT.mediatype]),
        'file_type': id == 0 ? 'mail_attachment' : 'discussion_attachment',
        'id_specific': id
      });
      uploads.add(dio.put('$URL/file/upload', data: fileData));
    }
    return Future.wait(uploads);
  }

  Future<Response> votePoll(int discussionId, int postId, List<int> votes) async {
    if (votes.isEmpty) {
      return await dio.post('$URL/discussion/$discussionId/poll/$postId/empty-vote');
    } else {
      return await dio.post('$URL/discussion/$discussionId/poll/$postId/vote/${votes.join(',')}');
    }
  }

  Future<Response> rollDice(int discussionId, int postId) async {
    return await dio.post('$URL/discussion/$discussionId/dice/$postId/roll');
  }
}
