import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/components/bottom_sheets/context_menu/item.dart';
import 'package:fyx/controllers/log_service.dart';
import 'package:fyx/exceptions/UnsupportedDownloadFormatException.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadButton extends StatefulWidget {
  const DownloadButton({Key? key, required this.url}) : super(key: key);
  final String url;

  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;
    return ContextMenuItem(
      label: 'Uložit obrázek',
      isColumn: false,
      icon: _saving
          ? MdiIcons.progressDownload
          : MdiIcons.download,
      onTap: () async {
        if (_saving) {
          return;
        }

        setState(() => _saving = true);
        try {
          PermissionStatus status = await Permission.storage.request();
          var isGranted = status.isGranted;

          if (Platform.isAndroid) {
            // https://pub.dev/packages/permission_handler#requesting-storage-permissions-always-returns-denied-on-android-13-what-can-i-do
            DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
            final androidInfo = await deviceInfoPlugin.androidInfo;
            isGranted = androidInfo.version.sdkInt >= 33 || isGranted;
          }

          if (isGranted) {
            // See https://github.com/lucien144/fyx/issues/304#issuecomment-1094851596
            var appDocDir = await getTemporaryDirectory();
            final result = await GallerySaver.saveImage(widget.url, albumName: 'Fyx');
            if (!(result ?? false)) {
              throw Error();
            }
            T.success(L.TOAST_IMAGE_SAVE_OK, bg: colors.success);
            Navigator.of(context).pop();
          } else {
            T.error('Nelze uložit. Povolte ukládání, prosím.', bg: colors.danger);
          }
        } on UnsupportedDownloadFormatException catch (exception) {
          T.error(exception.message, bg: colors.danger);
        } catch (error) {
          T.error(L.TOAST_IMAGE_SAVE_ERROR, bg: colors.danger);
          print((error as Error).stackTrace);
          LogService.captureError(error, stack: error.stackTrace);
        } finally {
          setState(() => _saving = false);
        }
      },
    );
  }
}
