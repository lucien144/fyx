import 'package:flutter/widgets.dart';

class PostAvatar extends StatelessWidget {
  final String image;
  final String nick;

  PostAvatar(this.image, this.nick);

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          image,
          fit: BoxFit.cover,
          width: 40,
          height: 40,
        ),
      ),
      SizedBox(
        width: 4,
      ),
      Text(nick)
    ]);
  }
}
