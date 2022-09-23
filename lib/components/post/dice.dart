import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/components/avatar.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/post/content/Dice.dart';
import 'package:fyx/theme/Helpers.dart';
import 'package:fyx/theme/T.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';

class Dice extends StatefulWidget {
  final ContentDice content;

  Dice(this.content);

  @override
  _DiceState createState() => _DiceState();
}

class _DiceState extends State<Dice> {
  bool _loading = false;
  ContentDice? _dice;
  ScrollController controller = ScrollController();

  @override
  void initState() {
    _dice = widget.content;
    super.initState();
  }

  Widget buildRolls(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;

    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        controller: controller,
        itemBuilder: (context, index) {
          final roll = _dice!.rolls[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: colors.pollAnswer,
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    roll.rolls.reduce((a, b) => a + b).toString(),
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                Tooltip(
                  message: '${roll.user}: ${roll.rolls.join(", ")}',
                  waitDuration: Duration(milliseconds: 0),
                  showDuration: Duration(milliseconds: 1500 + (roll.rolls.length * 300)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5, bottom: 0),
                    child: Avatar(Helpers.avatarUrl(roll.user), size: 22, isHighlighted: false),
                  ),
                )
              ]),
            ),
          );
        },
        itemCount: _dice!.rolls.length,
        shrinkWrap: true,
        padding: const EdgeInsets.all(0));
  }

  @override
  Widget build(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;

    return Container(
        alignment: Alignment.centerLeft,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(_dice!.reason, style: DefaultTextStyle.of(context).style.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
          if (_dice!.showRollsAfter > 0 && _dice!.showRollsAfter > DateTime.now().millisecondsSinceEpoch)
            Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Výsledky se zobrazí po ${Helpers.absoluteTime(_dice!.showRollsAfter)}',
                  style: TextStyle(fontStyle: FontStyle.italic),
                )),
          if (_dice!.allowRollsUntil > 0 && _dice!.allowRollsUntil > DateTime.now().millisecondsSinceEpoch)
            Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Házet možné do ${Helpers.absoluteTime(_dice!.allowRollsUntil)}',
                  style: TextStyle(fontStyle: FontStyle.italic),
                )),
          SizedBox(
            height: 8,
          ),
          buildRolls(context),
          if (_dice!.canRoll)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: CupertinoButton(
                onPressed: _loading
                    ? null
                    : () async {
                        setState(() => _loading = true);
                        try {
                          var poll = await ApiController().rollDice(_dice!.discussionId, _dice!.postId);
                          setState(() => _dice = poll);
                        } catch (error) {
                          T.error(error.toString(), bg: colors.danger);
                        } finally {
                          setState(() => _loading = false);
                        }
                      },
                child: _loading ? CupertinoActivityIndicator() : Text('Hodit! ${_dice!.diceCount}d${_dice!.diceSides}'),
                color: colors.primary,
                padding: EdgeInsets.all(0),
                disabledColor: colors.disabled,
              ),
            )
        ]),
        color: colors.pollBackground,
        padding: EdgeInsets.all(15));
  }
}
