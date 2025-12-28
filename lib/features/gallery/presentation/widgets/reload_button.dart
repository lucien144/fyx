import 'package:flutter/material.dart';
import 'package:fyx/components/bottom_sheets/context_menu/item.dart';
import 'package:fyx/features/gallery/presentation/gallery_viewmodel.dart';
import 'package:fyx/shared/services/service_locator.dart';

class ReloadButton extends StatelessWidget {
  const ReloadButton({Key? key, required this.url}) : super(key: key);
  final String url;

  @override
  Widget build(BuildContext context) {
    return ContextMenuItem(
      isColumn: false,
      icon: Icons.refresh,
      onTap: () async {
        final viewModel = getIt<GalleryViewModel>();
        await viewModel.reloadImage(url);
        Navigator.of(context).pop();
      },
      label: 'Reload obrázku',
    );
  }
}
