import 'package:mobile_apps_recan/models/chat_topic.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

class AiChatService {
  const new _();

  static const Duration _thinkingDelay = Duration(milliseconds: 900);

  static List<ChatTopic> get topics => [
    ChatTopic(
      category: ChatCategory.general,
      question: tr('Apa itu ReCan?', 'What is ReCan?'),
      answer: tr(
        'ReCan adalah aplikasi daur ulang kaleng untuk civitas kampus. Setor '
            'kaleng di Drop Station, kumpulkan poin, lalu tukarkan dengan '
            'produk kriya atau saldo e-wallet.',
        'ReCan is a can recycling app for the campus community. Drop cans at '
            'a Drop Station, collect points, then redeem them for crafts or '
            'e-wallet balance.',
      ),
      keywords: [
        'apa itu recan',
        'tentang recan',
        'apa itu re can',
        'what is recan',
        'about recan',
      ],
    ),
    ChatTopic(
      category: ChatCategory.drop,
      question: tr('Berapa poin per kaleng?', 'How many points per can?'),
      answer: tr(
        'Setiap kaleng yang terverifikasi bernilai 25 poin. Contoh: 20 '
            'kaleng = 500 poin, dan 1000 kaleng kolektif = 25.000 poin. Cek '
            'saldo di beranda dan rinciannya di tab Aktivitas.',
        'Every verified can is worth 25 points. For example: 20 cans = 500 '
            'points, and a 1000-can collective drop = 25,000 points. Check '
            'your balance on the home page and the details in the Activity '
            'tab.',
      ),
      keywords: ['poin per kaleng', 'points per can', 'poin', 'point', 'saldo'],
    ),
    ChatTopic(
      category: ChatCategory.drop,
      question: tr('Lokasi Drop Station UPJ', 'UPJ Drop Station locations'),
      answer: tr(
        'Drop Station ada di Gedung Utama, Kantin, dan Perpustakaan UPJ. '
            'Buka peta dari tombol Lihat Semua di bagian Drop Station '
            'beranda untuk melihat jarak dan kapasitas tiap station.',
        'Drop Stations are at the UPJ Main Building, Canteen, and Library. '
            'Open the map from the See All button in the Drop Station section '
            'on the home page to see the distance and capacity of each '
            'station.',
      ),
      keywords: [
        'lokasi',
        'dimana',
        'di mana',
        'station',
        'terdekat',
        'where',
        'location',
        'nearest',
      ],
    ),
    ChatTopic(
      category: ChatCategory.rewards,
      question: tr(
        'Cara tukar poin & E-Wallet',
        'How to redeem points & E-Wallet',
      ),
      answer: tr(
        'Buka tab Katalog, pilih produk kriya, voucher, atau saldo e-wallet '
            '(GoPay, OVO, DANA), lalu konfirmasi dengan ReCan Points. Saldo '
            'e-wallet bisa ditukar mulai Rp 20.000.',
        'Open the Catalog tab, pick a craft product, voucher, or e-wallet '
            'balance (GoPay, OVO, DANA), then confirm with ReCan Points. '
            'E-wallet balance can be redeemed from Rp 20,000.',
      ),
      keywords: [
        'tukar',
        'menukar',
        'redeem',
        'exchange',
        'wallet',
        'voucher',
        'katalog',
        'catalog',
        'hadiah',
        'reward',
      ],
    ),
    ChatTopic(
      category: ChatCategory.rewards,
      question: tr(
        'Apa itu produk Kriya Upcycling?',
        'What are Upcycled Craft products?',
      ),
      answer: tr(
        'Kriya Upcycling adalah produk bernilai baru dari kaleng bekas, '
            'seperti miniatur F1, jet tempur, mobil klasik, kapal pinisi, '
            'vas, dan lampu meja. Semuanya dirakit tangan dan bisa ditukar '
            'dengan poin di Katalog.',
        'Upcycled Crafts are products given new value from used cans, such '
            'as F1, fighter jet, classic car, and pinisi ship miniatures, '
            'vases, and desk lamps. All are hand-assembled and can be '
            'redeemed with points in the Catalog.',
      ),
      keywords: ['kriya', 'upcycl', 'craft', 'miniatur', 'miniature'],
    ),
    ChatTopic(
      category: ChatCategory.rewards,
      question: tr(
        'Bagaimana sistem Tier Member?',
        'How does the Member Tier work?',
      ),
      answer: tr(
        'Tier naik seiring total poinmu: Bronze (di bawah 1.000), Silver '
            '(1.000 - 5.000), lalu Gold (di atas 5.000). Ketuk kartu tier di '
            'Profil untuk melihat keuntungannya.',
        'Your tier rises with your total points: Bronze (under 1,000), '
            'Silver (1,000 - 5,000), then Gold (over 5,000). Tap the tier '
            'card on Profile to see its benefits.',
      ),
      keywords: ['tier', 'level', 'member', 'bronze', 'silver', 'gold'],
    ),
    ChatTopic(
      category: ChatCategory.rewards,
      question: tr(
        'Cara kerja Misi Harian/Bulanan',
        'How Daily/Monthly Missions work',
      ),
      answer: tr(
        'Misi terbagi menjadi harian, mingguan, dan bulanan. Setor kaleng '
            'atau lakukan aksi yang diminta sampai target terpenuhi, lalu '
            'klaim hadiahnya di beranda untuk poin ekstra. Setor tiap hari '
            'agar streak-mu terus naik.',
        'Missions come in daily, weekly, and monthly sets. Drop cans or '
            'complete the requested action until the target is met, then '
            'claim the reward on the home page for extra points. Drop every '
            'day to keep your streak growing.',
      ),
      keywords: ['misi', 'quest', 'streak', 'mission', 'harian', 'bulanan'],
    ),
    ChatTopic(
      category: ChatCategory.general,
      question: tr(
        'Dampak limbah kaleng bagi lingkungan',
        'Environmental impact of can waste',
      ),
      answer: tr(
        'Satu kaleng butuh 50 - 200 tahun untuk terurai. Mendaur ulang '
            'aluminium menghemat hingga 95% energi, dan setiap kaleng yang '
            'kamu setor di ReCan dihitung menghemat sekitar 0,13 kg emisi '
            'karbon.',
        'A single can takes 50 - 200 years to decompose. Recycling aluminum '
            'saves up to 95% of the energy, and every can you drop at ReCan '
            'is counted as saving about 0.13 kg of carbon emissions.',
      ),
      keywords: [
        'dampak',
        'lingkungan',
        'impact',
        'environment',
        'karbon',
        'carbon',
        'limbah',
      ],
    ),
    ChatTopic(
      category: ChatCategory.drop,
      question: tr('Syarat kaleng yang diterima', 'Accepted can requirements'),
      answer: tr(
        'Hanya kaleng minuman aluminium yang diterima. Kosongkan dan bilas '
            'dulu, lalu pipihkan agar hemat tempat. Kaleng baja, botol '
            'plastik, dan sampah lain akan ditolak.',
        'Only aluminum drink cans are accepted. Empty and rinse them first, '
            'then flatten them to save space. Steel cans, plastic bottles, '
            'and other waste will be rejected.',
      ),
      keywords: [
        'syarat',
        'diterima',
        'accepted',
        'requirement',
        'kaleng',
        'can',
      ],
    ),
    ChatTopic(
      category: ChatCategory.general,
      question: tr('Bantuan akun bermasalah', 'Help with account problems'),
      answer: tr(
        'Untuk masalah akun, coba keluar lalu masuk kembali. Kamu juga bisa '
            'memperbarui data di Profil > Edit Profil, atau buka Pusat '
            'Bantuan untuk menghubungi tim ReCan.',
        'For account problems, try signing out and signing in again. You can '
            'also update your data in Profile > Edit Profile, or open the '
            'Help Center to contact the ReCan team.',
      ),
      keywords: [
        'akun',
        'bermasalah',
        'login',
        'masuk',
        'password',
        'kata sandi',
        'account',
        'problem',
        'sign in',
      ],
    ),
  ];

  static String get greeting => tr(
    'Halo! Aku ReCan AI, asisten lingkungan kamu. Pilih salah satu '
        'pertanyaan di bawah ya. ♻️',
    'Hi! I am ReCan AI, your environment assistant. Pick one of the '
        'questions below. ♻️',
  );

  static String _normalize(String message) => message
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  static Future<String> send(String message) async {
    await Future<void>.delayed(_thinkingDelay);
    final normalized = _normalize(message);
    final all = topics;
    for (final topic in all) {
      if (_normalize(topic.question) == normalized) return topic.answer;
    }
    for (final topic in all) {
      if (topic.keywords.any(normalized.contains)) return topic.answer;
    }
    return tr(
      'Aku ReCan AI. Tanyakan seputar poin, setor kaleng, katalog, tier, '
          'atau misi harian ya!',
      'I am ReCan AI. Ask me about points, dropping cans, the catalog, '
          'tiers, or daily missions!',
    );
  }
}
