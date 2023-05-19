import 'package:flutter/cupertino.dart';

class SearchHelpNotFound extends StatelessWidget {
  const SearchHelpNotFound({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 10,),
      Text('Nic nebylo nalezeno.', style: TextStyle(fontWeight: FontWeight.bold),),
      const SizedBox(height: 10,),
      Image.asset(
        'assets/philosoraptor.png',
        width: 56,
      ),
      Text('Pokud nebylo nic nalezeno, znamená to,\nže nic neexistuje?\n\nPak by ale něco nalezeno být mělo, nebo ne?', textAlign: TextAlign.center,)
    ]);
  }
}
