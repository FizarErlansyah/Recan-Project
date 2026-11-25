import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/features/catalog/domain/product_art.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

class TutorialStep {
  const new({
    required this.titleId,
    required this.titleEn,
    required this.bodyId,
    required this.bodyEn,
    required this.icon,
    this.art = ProductArt.can,
    this.safetyId,
    this.safetyEn,
  });

  final String titleId;
  final String titleEn;
  final String bodyId;
  final String bodyEn;
  final IconGlyph icon;
  final ProductArt art;
  final String? safetyId;
  final String? safetyEn;

  String get title => tr(titleId, titleEn);
  String get body => tr(bodyId, bodyEn);

  String? get safety {
    final id = safetyId;
    final en = safetyEn;
    return id == null || en == null ? null : tr(id, en);
  }
}

/// "Olah Kaleng": turning a used drink can into a craft at home. Bundled with
/// the app, so it works without a connection.
abstract final class CanTutorial {
  static const List<TutorialStep> steps = [
    TutorialStep(
      titleId: 'Pilih dan bersihkan kaleng',
      titleEn: 'Pick and clean the can',
      bodyId:
          'Pakai kaleng minuman aluminium yang tidak penyok parah. Bilas sisa '
          'minuman, lalu keringkan sampai tidak lengket.',
      bodyEn:
          'Use aluminium drink cans without bad dents. Rinse out what is left '
          'and dry them until nothing is sticky.',
      icon: AppIcons.recycle,
    ),
    TutorialStep(
      titleId: 'Siapkan alat dan pelindung',
      titleEn: 'Gather tools and protection',
      bodyId:
          'Siapkan sarung tangan anti sayat, kacamata pelindung, gunting '
          'logam, kertas gosok, penggaris dan spidol.',
      bodyEn:
          'Get cut-resistant gloves, safety glasses, metal snips, sandpaper, '
          'a ruler and a marker.',
      icon: AppIcons.security,
      safetyId: 'Anak-anak hanya boleh mengikuti bersama orang dewasa.',
      safetyEn: 'Children may only join in with an adult.',
    ),
    TutorialStep(
      titleId: 'Buka bagian atas dan bawah',
      titleEn: 'Open the top and bottom',
      bodyId:
          'Tandai garis potong. Buat lubang awal dengan ujung gunting, lalu '
          'potong melingkar dan lepaskan tutup serta alas kaleng.',
      bodyEn:
          'Mark the cut line. Start a hole with the tip of the snips, then cut '
          'around and take off the top and bottom.',
      icon: AppIcons.target,
      safetyId:
          'Tepi potongan sangat tajam. Potong menjauhi tubuh dan jangan '
          'lepas sarung tangan.',
      safetyEn:
          'Cut edges are very sharp. Cut away from your body and keep the '
          'gloves on.',
    ),
    TutorialStep(
      titleId: 'Ratakan dan haluskan tepi',
      titleEn: 'Flatten and smooth the edges',
      bodyId:
          'Belah badan kaleng menjadi lembaran, ratakan di meja, lalu amplas '
          'semua tepi atau lipat ke dalam sekitar 3 mm.',
      bodyEn:
          'Slit the body into a sheet, flatten it on a table, then sand every '
          'edge or fold it in by about 3 mm.',
      icon: AppIcons.design,
      safetyId:
          'Raba tepi hanya dengan sarung tangan sampai benar-benar halus.',
      safetyEn: 'Touch edges only with gloves until they are truly smooth.',
    ),
    TutorialStep(
      titleId: 'Bentuk dan rakit',
      titleEn: 'Shape and assemble',
      bodyId:
          'Gambar pola pada lembaran, tekuk sesuai bentuk, lalu sambung dengan '
          'lem logam atau paku keling kecil.',
      bodyEn:
          'Draw your pattern on the sheet, bend it into shape, then join the '
          'parts with metal glue or small rivets.',
      icon: AppIcons.collaboration,
      art: ProductArt.vase,
    ),
    TutorialStep(
      titleId: 'Rapikan hasil dan sisa',
      titleEn: 'Finish and tidy up',
      bodyId:
          'Cat atau lapisi karya di ruang berventilasi. Kumpulkan serpihan '
          'logam dalam wadah tertutup, lalu setor kaleng sisa ke Drop Station.',
      bodyEn:
          'Paint or coat your piece in a ventilated room. Collect metal scraps '
          'in a closed container and drop spare cans at a Drop Station.',
      icon: AppIcons.checkCircle,
      art: ProductArt.lamp,
      safetyId: 'Serpihan kecil bisa melukai. Sapu, jangan dipungut tangan.',
      safetyEn: 'Small slivers cut too. Sweep them up, do not pick them up.',
    ),
  ];
}
