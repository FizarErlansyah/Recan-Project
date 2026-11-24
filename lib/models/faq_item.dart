import 'package:mobile_apps_recan/utils/localization.dart';

class FaqItem {
  const new({
    required this._question,
    required this._questionEn,
    required this._answer,
    required this._answerEn,
  });

  final String _question;
  final String _questionEn;
  final String _answer;
  final String _answerEn;

  String get question => tr(_question, _questionEn);
  String get answer => tr(_answer, _answerEn);

  static const List<FaqItem> all = [
    FaqItem(
      question: 'Apa itu ReCan?',
      questionEn: 'What is ReCan?',
      answer:
          'ReCan adalah aplikasi daur ulang kaleng untuk semua orang. '
          'Setor kaleng bekas, kumpulkan poin, lalu tukarkan dengan voucher '
          'atau produk kriya daur ulang.',
      answerEn:
          'ReCan is a can recycling app for everyone. Drop your '
          'used cans, collect points, then redeem them for vouchers or '
          'recycled crafts.',
    ),
    FaqItem(
      question: 'Bagaimana cara menyetor kaleng?',
      questionEn: 'How do I drop cans?',
      answer:
          'Datang ke Drop Station terdekat, tekan tombol Scan di beranda, '
          'lalu pindai kode QR di station. Masukkan kaleng dan poin masuk '
          'otomatis setelah sesi selesai.',
      answerEn:
          'Go to the nearest Drop Station, tap Scan on the home page, then '
          'scan the QR code at the station. Insert your cans and the points '
          'are added automatically when the session ends.',
    ),
    FaqItem(
      question: 'Berapa poin yang saya dapat?',
      questionEn: 'How many points do I get?',
      answer:
          'Poin dihitung dari jumlah kaleng yang disetor. Pantau rinciannya '
          'di tab Aktivitas setelah setiap setoran.',
      answerEn:
          'Points are based on the number of cans you drop. Check the details '
          'in the Activity tab after every deposit.',
    ),
    FaqItem(
      question: 'Bagaimana cara menukar poin?',
      questionEn: 'How do I redeem points?',
      answer:
          'Buka tab Katalog untuk produk daur ulang, atau lihat bagian '
          'Reward & Promo di beranda untuk voucher mitra.',
      answerEn:
          'Open the Catalog tab for recycled products, or check the Reward & '
          'Promo section on the home page for partner vouchers.',
    ),
    FaqItem(
      question: 'Apa itu tier member?',
      questionEn: 'What is a member tier?',
      answer:
          'Tier naik seiring total poinmu. Semakin tinggi tier, semakin '
          'banyak keuntungan. Ketuk lencana tier di Profil untuk melihat '
          'detailnya.',
      answerEn:
          'Your tier rises with your total points. The higher the tier, the '
          'more benefits you get. Tap the tier badge on Profile to see the '
          'details.',
    ),
    FaqItem(
      question: 'Poin saya belum masuk, apa yang harus dilakukan?',
      questionEn: 'My points have not arrived, what should I do?',
      answer:
          'Tarik layar ke bawah untuk memuat ulang data. Jika poin belum '
          'muncul, tanyakan ke ReCan AI atau hubungi pengelola Drop Station.',
      answerEn:
          'Pull down to refresh the data. If the points still do not show up, '
          'ask ReCan AI or contact the Drop Station manager.',
    ),
  ];
}
