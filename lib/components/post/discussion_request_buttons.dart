import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/post/content/discussion_request.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';

class DiscussionRequestButtons extends StatefulWidget {
  final ContentDiscussionRequest content;

  const DiscussionRequestButtons({Key? key, required this.content}) : super(key: key);

  @override
  _DiscussionRequestButtonsState createState() => _DiscussionRequestButtonsState();
}

class _DiscussionRequestButtonsState extends State<DiscussionRequestButtons> {
  bool $loading = false;
  late ContentDiscussionRequest $content;

  @override
  void initState() {
    $content = widget.content;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;

    if ($content.canVote == false || $content.discussionId != null) {
      return Row(
        children: [
          Text('${$content.computedValues?.votersPositiveTotal ?? '0'} pro'),
          const SizedBox(width: 16),
          Text('${$content.computedValues?.votersNegativeTotal ?? '0'} proti'),
        ],
      );
    }

    return Stack(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              child: Text('👍 Pro'),
              onPressed: $loading
                  ? null
                  : () async {
                      setState(() => $loading = true);
                      final response = await ApiController().discussionCreateRequest(widget.content.parentDiscussionId, widget.content.parentPostId);
                      setState(() {
                        $content = response;
                        $loading = false;
                      });
                    },
              color: colors.primary,
              padding: EdgeInsets.symmetric(horizontal: 16),
              disabledColor: colors.disabled,
            ),
            const SizedBox(width: 16),
            CupertinoButton(
              child: Text('👎 Proti'),
              onPressed: $loading
                  ? null
                  : () async {
                      setState(() => $loading = true);
                      final response =
                          await ApiController().discussionCreateRequest(widget.content.parentDiscussionId, widget.content.parentPostId, true);
                      setState(() {
                        $content = response;
                        $loading = false;
                      });
                    },
              color: colors.primary,
              padding: EdgeInsets.symmetric(horizontal: 16),
              disabledColor: colors.disabled,
            )
          ],
        ),
        if ($loading)
          Positioned.fill(
              child: Align(
            child: CupertinoActivityIndicator(),
            alignment: Alignment.center,
          )),
      ],
    );
  }
}
