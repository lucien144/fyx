import 'package:fyx/features/gallery/presentation/viewmodel/gallery_viewmodel.dart';
import 'package:fyx/features/mail/data/repositories/mail_repository_impl.dart';
import 'package:fyx/features/mail/domain/repositories/mail_repository.dart';
import 'package:fyx/features/mail/presentation/viewmodel/mail_viewmodel.dart';
import 'package:fyx/features/message/presentation/viewmodel/message_viewmodel.dart';
import 'package:fyx/features/userstats/data/datasources/userstats_database.dart';
import 'package:fyx/features/userstats/data/repositories/userstats_repository_impl.dart';
import 'package:fyx/features/userstats/domain/repositories/userstats_repository.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

/// Setup dependency injection with GetIt
void setupServiceLocator() {
    // ViewModels
    getIt.registerSingleton<GalleryViewModel>(GalleryViewModel());
    getIt.registerSingleton<MessageViewModel>(MessageViewModel());

    // Mail
    getIt.registerLazySingleton<MailRepository>(() => MailRepositoryImpl());
    getIt.registerSingleton<MailViewModel>(MailViewModel(getIt<MailRepository>()));

    // Userstats
    getIt.registerLazySingleton<UserstatsDatabase>(() => UserstatsDatabase());
    getIt.registerLazySingleton<UserstatsRepository>(
        () => UserstatsRepositoryImpl(getIt<UserstatsDatabase>()),
    );

}

/// Global accessor for UserstatsRepository
UserstatsRepository get userstatsRepo => getIt<UserstatsRepository>();
