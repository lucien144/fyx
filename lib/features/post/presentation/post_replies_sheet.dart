import 'package:flutter/cupertino.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:fyx/components/post/post_list_item.dart';
import 'package:fyx/shared/services/analytics/analytics_service.dart';
import 'package:fyx/shared/services/service_locator.dart';
import 'package:fyx/features/post/presentation/viewmodel/post_replies_state.dart';
import 'package:fyx/features/post/presentation/viewmodel/post_replies_viewmodel.dart';
import 'package:fyx/model/Discussion.dart';
import 'package:fyx/model/Post.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

/// Bottom sheet with a post followed by all its replies.
class PostRepliesSheet extends WatchingStatefulWidget {
  final Post post;
  final Discussion? discussion;

  const PostRepliesSheet({super.key, required this.post, this.discussion});

  static Future<void> show(BuildContext context, {required Post post, Discussion? discussion}) {
    getIt<AnalyticsService>().logEvent('show_post_replies');
    return showCupertinoModalBottomSheet(
      context: context,
      builder: (_) => PostRepliesSheet(post: post, discussion: discussion),
    );
  }

  @override
  State<PostRepliesSheet> createState() => _PostRepliesSheetState();
}

class _PostRepliesSheetState extends State<PostRepliesSheet> {
  final _viewModel = di<PostRepliesViewModel>();

  @override
  void initState() {
    super.initState();
    _viewModel.load(widget.post);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = watch(_viewModel).state;
    final colors = Skin.of(context).theme.colors;

    return SingleChildScrollView(
      controller: ModalScrollController.of(context),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            Container(
              color: colors.primary.withValues(alpha: .1),
              child: PostListItem(widget.post, discussion: widget.discussion),
            ),
            switch (state.status) {
              PostRepliesStatus.loading => const Padding(padding: EdgeInsets.all(32), child: CupertinoActivityIndicator()),
              PostRepliesStatus.failed => Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text('Odpovědi se nepodařilo načíst.', style: TextStyle(color: colors.danger)),
                ),
              PostRepliesStatus.ready => Column(
                  children: [for (final reply in state.replies) PostListItem(reply, discussion: widget.discussion)],
                ),
            },
          ],
        ),
      ),
    );
  }
}
