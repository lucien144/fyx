import 'package:fyx/model/enums/PostTypeEnum.dart';
import 'package:fyx/model/post/Content.dart';
import 'package:fyx/model/post/Image.dart';
import 'package:fyx/model/post/Link.dart';
import 'package:fyx/model/post/Video.dart';
import 'package:fyx/model/post/poll/PollAnswer.dart';

class ContentPoll implements Content {
  String _question;
  String _instructions;
  bool _publicResults;
  int _allowedVotes;
  String _allowAnswersUntil;
  String _showAnswersAfter;
  List<PollAnswer> _answers;

  String get question => _question;

  String get instructions => _instructions;

  bool get publicResults => _publicResults;

  int get allowedVotes => _allowedVotes;

  String get allowAnswersUntil => _allowAnswersUntil;

  String get showAnswersAfter => _showAnswersAfter;

  List<PollAnswer> get answers => _answers;

  ContentPoll.fromJson(Map<String, dynamic> json) {
    _question = json['question'];
    _instructions = json['instructions'];
    _publicResults = json['public_results'];
    _allowedVotes = json['allowed_votes'];
    _allowAnswersUntil = json['allow_answers_until'];
    _showAnswersAfter = json['show_answers_after'];
    if (json['answers'] != null) {
      _answers = new List<PollAnswer>();
      (json['answers'] as Map<String, dynamic>).forEach((String key, dynamic answer) {
        _answers.add(new PollAnswer.fromJson(answer as Map<String, dynamic>));
      });
    }
  }

  @override
  PostTypeEnum get contentType => PostTypeEnum.poll;

  @override
  List get attachments => [];

  @override
  Map<String, dynamic> get attachmentsWithFeatured => {};

  @override
  // TODO: implement body
  String get body => throw UnimplementedError();

  @override
  bool get consecutiveImages => false;

  @override
  List<Link> get emptyLinks => [];

  @override
  List<Image> get images => [];

  @override
  bool get isCompact => false;

  @override
  // TODO: implement rawBody
  String get rawBody => throw UnimplementedError();

  @override
  // TODO: implement strippedContent
  String get strippedContent => throw UnimplementedError();

  @override
  List<Video> get videos => [];
}