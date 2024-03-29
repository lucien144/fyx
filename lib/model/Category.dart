// ignore_for_file: non_constant_identifier_names

class Category {
  late int _id_cat;
  late String _jmeno;
  late int _sort_code;

  Category.fromJson(Map<String, dynamic> json) {
    this._id_cat = int.parse(json['id_cat']);
    this._jmeno = json['jmeno'];
    this._sort_code = int.parse(json['sort_code']);
  }

  int get idCat => _id_cat;

  String get jmeno => _jmeno;

  int get sortCode => _sort_code;
}
