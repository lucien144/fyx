import 'package:fyx/model/ResponseContext.dart';
import 'package:fyx/model/reponses/FileUploadResponse.dart';

class WaitingFilesResponse {
  late ResponseContext _context;
  List<FileUploadResponse> _files = [];

  WaitingFilesResponse.fromJson(Map<String, dynamic> json) {
    _context = ResponseContext.fromJson(json['context']);
    _files = (json['waiting_files'] as List).map((file) => FileUploadResponse.fromJson(file)).toList();
  }

  List<FileUploadResponse> get files => _files;

  ResponseContext get context => _context;
}
