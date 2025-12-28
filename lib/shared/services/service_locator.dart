import 'package:fyx/features/gallery/presentation/gallery_viewmodel.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

/// Setup dependency injection with GetIt
void setupServiceLocator() {
    getIt.registerSingleton<GalleryViewModel>(GalleryViewModel());
}
