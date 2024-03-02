import 'package:flutter/cupertino.dart';

class SearchPostsHelp extends StatelessWidget {
  const SearchPostsHelp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10),
        Text('🕵️‍♂️ Příklady hledání v příspěvcích:', style: TextStyle(fontSize: 12)),
        SizedBox(height: 10),
        Text.rich(
          style: TextStyle(fontSize: 12),
          TextSpan(
            children: [
              TextSpan(text: '• '),
              TextSpan(text: 'foo bar', style: TextStyle(fontWeight: FontWeight.bold),),
              TextSpan(text: ' – začínající na '),
              TextSpan(text: 'foo', style: TextStyle(fontWeight: FontWeight.bold),),
              TextSpan(text: ' a '),
              TextSpan(text: 'bar', style: TextStyle(fontWeight: FontWeight.bold),),
            ],
          ),
        ),
        SizedBox(height: 5),
        Text.rich(
          style: TextStyle(fontSize: 12),
          TextSpan(
            children: [
              TextSpan(text: '• '),
              TextSpan(text: '=foo =bar', style: TextStyle(fontWeight: FontWeight.bold),),
              TextSpan(text: ' – hledá přesnou shodu'),
            ],
          ),
        ),
        SizedBox(height: 5),
        Text.rich(
          style: TextStyle(fontSize: 12),
          TextSpan(
            children: [
              TextSpan(text: '• '),
              TextSpan(text: 'foo -bar', style: TextStyle(fontWeight: FontWeight.bold),),
              TextSpan(text: ' – odfiltruje výskyty '),
              TextSpan(text: 'bar', style: TextStyle(fontWeight: FontWeight.bold),),
            ],
          ),
        ),
        SizedBox(height: 5),
        Text.rich(
          style: TextStyle(fontSize: 12),
          TextSpan(
            children: [
              TextSpan(text: '• '),
              TextSpan(text: 'hledaná fráze @uživatel', style: TextStyle(fontWeight: FontWeight.bold),),
              TextSpan(text: ' – hledá v příspěvcích '),
              TextSpan(text: 'uživatele', style: TextStyle(fontWeight: FontWeight.bold),),
            ],
          ),
        ),
        SizedBox(height: 5),
        Text.rich(
          style: TextStyle(fontSize: 12),
          TextSpan(
            children: [
              TextSpan(text: '• '),
              TextSpan(text: '"hledaná fráze"', style: TextStyle(fontWeight: FontWeight.bold),),
              TextSpan(text: ' – hledá frázi'),
            ],
          ),
        ),
        SizedBox(height: 5),
        Text.rich(
          style: TextStyle(fontSize: 12),
          TextSpan(
            children: [
              TextSpan(text: '• '),
              TextSpan(text: '@uživatel', style: TextStyle(fontWeight: FontWeight.bold),),
              TextSpan(text: ' – hledá uživatele'),
            ],
          ),
        )
      ],
    );
  }
}
