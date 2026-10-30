import 'package:mobile_apps_recan/services/mock_store.dart';

String tr(String id, String en) => MockStore.isEnglish.value ? en : id;

T trValue<T>(T id, T en) => MockStore.isEnglish.value ? en : id;
