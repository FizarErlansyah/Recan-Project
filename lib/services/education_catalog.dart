import 'package:mobile_apps_recan/models/education_article.dart';

class EducationCatalog {
  const new _();

  static final List<EducationArticle> articles = [
    EducationArticle(
      id: 1,
      category: EducationCategory.about,
      titleId: 'Apa Itu ReCan dan Bagaimana Cara Kerjanya',
      titleEn: 'What ReCan Is and How It Works',
      summaryId: 'Kenali ekosistem Drop Station pintar di kampusmu.',
      summaryEn: 'Meet the smart Drop Station ecosystem on your campus.',
      paragraphsId: const [
        'ReCan adalah aplikasi daur ulang kaleng untuk civitas kampus. Ide dasarnya sederhana: kaleng bekas yang biasanya berakhir di tempat sampah kini punya nilai, dan setiap orang bisa ikut menjaganya tetap berputar.',
        'Kamu cukup datang ke Drop Station terdekat, memindai kode QR, lalu memasukkan kaleng satu per satu. Sensor di dalam station menghitung jumlah dan berat kaleng, kemudian mengubahnya menjadi poin secara otomatis.',
        'Poin yang terkumpul bisa ditukar dengan kriya daur ulang, saldo e-wallet, atau voucher kampus. Semakin rutin kamu menyetor, semakin tinggi tier member yang kamu dapatkan.',
      ],
      paragraphsEn: const [
        'ReCan is a can recycling app for the campus community. The idea is simple: used cans that usually end up in the trash now have value, and everyone can help keep them in circulation.',
        'Just go to the nearest Drop Station, scan the QR code, and insert your cans one by one. Sensors inside the station count the cans and weigh them, then convert them into points automatically.',
        'The points you collect can be redeemed for recycled crafts, e-wallet balance, or campus vouchers. The more regularly you drop cans, the higher your member tier climbs.',
      ],
      insightId: 'Satu kaleng yang disetor di ReCan mendapat 25 poin, dan semuanya tercatat otomatis di tab Aktivitas.',
      insightEn: 'Every can dropped at ReCan earns 25 points, all recorded automatically in the Activity tab.',
      stats: const [
        ArticleStat(
          value: '25',
          labelId: 'Poin per kaleng',
          labelEn: 'Points per can',
        ),
        ArticleStat(
          value: '3',
          labelId: 'Drop Station kampus',
          labelEn: 'Campus Drop Stations',
        ),
        ArticleStat(
          value: '3',
          labelId: 'Tier member',
          labelEn: 'Member tiers',
        ),
      ],
      publishedAt: DateTime(2026, 10, 12),
      readMinutes: 3,
    ),
    EducationArticle(
      id: 2,
      category: EducationCategory.about,
      titleId: 'Dari Kaleng Bekas Menjadi Kriya Bernilai',
      titleEn: 'From Used Cans to Valuable Crafts',
      summaryId: 'Perjalanan satu kaleng setelah kamu menyetornya.',
      summaryEn: 'The journey of a single can after you drop it.',
      paragraphsId: const [
        'Setelah kamu menyetor, kaleng dikumpulkan oleh petugas dan dibawa ke tempat pemilahan. Di sana kaleng dibersihkan dari sisa minuman dan label, lalu dipisahkan berdasarkan jenis logamnya.',
        'Sebagian kaleng dilebur menjadi lembaran aluminium baru, sementara sebagian lainnya dipotong dan dibentuk oleh perajin lokal menjadi miniatur, vas, dan lampu meja yang ada di Katalog.',
        'Setiap karya dipoles dengan tangan sehingga tidak ada dua produk yang benar-benar sama. Dengan menukar poinmu, kamu ikut menghidupi perajin lokal dan menjaga aluminium tetap berputar.',
      ],
      paragraphsEn: const [
        'After you drop your cans, staff collect them and take them to a sorting site. There the cans are cleaned of leftover drink and labels, then separated by metal type.',
        'Some cans are melted into new aluminum sheets, while others are cut and shaped by local artisans into the miniatures, vases, and desk lamps you see in the Catalog.',
        'Every piece is polished by hand so no two products are exactly the same. By redeeming your points, you support local artisans and keep aluminum in circulation.',
      ],
      insightId: 'Tidak ada cetakan pabrik. Setiap sambungan pada kriya ReCan dibentuk dan dipoles dengan tangan.',
      insightEn: 'There are no factory molds. Every joint on a ReCan craft is shaped and polished by hand.',
      stats: const [
        ArticleStat(
          value: '6',
          labelId: 'Produk kriya',
          labelEn: 'Craft products',
        ),
        ArticleStat(
          value: '100%',
          labelId: 'Aluminium daur ulang',
          labelEn: 'Recycled aluminum',
        ),
        ArticleStat(
          value: '1:18',
          labelId: 'Skala miniatur',
          labelEn: 'Miniature scale',
        ),
      ],
      publishedAt: DateTime(2026, 10, 8),
      readMinutes: 4,
    ),
    EducationArticle(
      id: 3,
      category: EducationCategory.importance,
      titleId: 'Mengapa Aluminium Layak Didaur Ulang',
      titleEn: 'Why Aluminum Deserves a Second Life',
      summaryId: 'Aluminium bisa didaur ulang tanpa kehilangan kualitas.',
      summaryEn: 'Aluminum can be recycled without losing its quality.',
      paragraphsId: const [
        'Aluminium adalah salah satu material paling istimewa di dunia industri. Berbeda dengan banyak bahan lain yang menurun mutunya setiap kali diolah ulang, aluminium dapat didaur ulang berkali-kali tanpa kehilangan kualitas aslinya.',
        'Memproduksi aluminium dari bijih bauksit membutuhkan energi yang sangat besar. Sebaliknya, melebur kaleng bekas hanya memerlukan sebagian kecil dari energi tersebut, sehingga emisi karbon yang dihasilkan jauh lebih rendah.',
        'Itu sebabnya satu kaleng yang kamu buang hari ini bisa kembali menjadi kaleng baru dalam hitungan minggu, lalu melakukannya lagi dan lagi tanpa batas.',
      ],
      paragraphsEn: const [
        'Aluminum is one of the most remarkable materials in industry. Unlike many other materials that degrade each time they are reprocessed, aluminum can be recycled again and again without losing its original quality.',
        'Producing aluminum from bauxite ore takes a huge amount of energy. Melting used cans, by contrast, needs only a small fraction of that energy, so the carbon emissions are far lower.',
        'That is why a can you throw away today can become a new can within weeks, and then do it again and again without limit.',
      ],
      insightId: 'Mendaur ulang 1 kaleng aluminium menghemat energi hingga 95% dibandingkan memproduksi dari bijih bauksit mentah.',
      insightEn: 'Recycling 1 aluminum can saves up to 95% of the energy needed to produce it from raw bauxite ore.',
      stats: const [
        ArticleStat(
          value: '95%',
          labelId: 'Energi dihemat',
          labelEn: 'Energy saved',
        ),
        ArticleStat(
          value: '∞',
          labelId: 'Kali bisa didaur ulang',
          labelEn: 'Times recyclable',
        ),
        ArticleStat(
          value: '60',
          labelId: 'Hari kaleng kembali ke rak',
          labelEn: 'Days to return to shelves',
        ),
      ],
      publishedAt: DateTime(2026, 9, 28),
      readMinutes: 4,
    ),
    EducationArticle(
      id: 4,
      category: EducationCategory.importance,
      titleId: 'Tips Memilah Sampah di Kos dan Kampus',
      titleEn: 'Tips for Sorting Waste at Home and on Campus',
      summaryId: 'Tiga kebiasaan kecil yang mempermudah proses daur ulang.',
      summaryEn: 'Three small habits that make recycling easier.',
      paragraphsId: const [
        'Memilah sampah tidak perlu rumit. Mulailah dengan menyediakan satu wadah khusus untuk kaleng di kamar kos atau tas kuliahmu, terpisah dari sampah basah dan plastik.',
        'Bilas kaleng sebelum disetor agar tidak berbau dan tidak mengotori kaleng lain. Setelah itu, pipihkan kaleng supaya hemat tempat dan lebih banyak yang bisa kamu bawa sekali jalan.',
        'Biasakan menyetor saat melewati Drop Station, misalnya sepulang kuliah. Kebiasaan kecil yang rutin lebih berdampak daripada setoran besar yang jarang.',
      ],
      paragraphsEn: const [
        'Sorting waste does not have to be complicated. Start by keeping a dedicated container for cans in your room or backpack, separate from wet waste and plastic.',
        'Rinse cans before dropping them so they do not smell or dirty other cans. Then flatten them to save space and carry more in a single trip.',
        'Make it a habit to drop cans when you pass a Drop Station, for example on your way home from class. Small, regular habits make more impact than large, rare deposits.',
      ],
      insightId: 'Kaleng yang dibilas dan dipipihkan lebih cepat diproses dan menghemat ruang hingga separuhnya.',
      insightEn: 'Rinsed and flattened cans are processed faster and save up to half the space.',
      stats: const [
        ArticleStat(
          value: '3',
          labelId: 'Langkah mudah',
          labelEn: 'Easy steps',
        ),
        ArticleStat(
          value: '50%',
          labelId: 'Ruang dihemat',
          labelEn: 'Space saved',
        ),
        ArticleStat(
          value: '5 mnt',
          labelId: 'Waktu per hari',
          labelEn: 'Minutes per day',
        ),
      ],
      publishedAt: DateTime(2026, 10, 3),
      readMinutes: 3,
    ),
    EducationArticle(
      id: 5,
      category: EducationCategory.impact,
      titleId: 'Jejak Karbon yang Kamu Hemat Setiap Hari',
      titleEn: 'The Carbon Footprint You Save Every Day',
      summaryId: 'Setiap kaleng yang disetor ikut menurunkan emisi.',
      summaryEn: 'Every can you drop helps cut emissions.',
      paragraphsId: const [
        'Setiap produk punya jejak karbon, yaitu jumlah gas rumah kaca yang dihasilkan sepanjang hidupnya. Untuk aluminium, sebagian besar jejak itu muncul saat penambangan dan peleburan bijih mentah.',
        'Ketika kaleng bekas didaur ulang, tahap-tahap berat itu dilewati. Karena itu, tiap kaleng yang kamu setor di ReCan secara nyata mengurangi emisi dibandingkan jika kaleng itu dibuang.',
        'Di Beranda kamu bisa memantau grafik dampak karbon dan melihat berapa kilogram emisi yang sudah kamu hemat. Angka itu bertambah setiap kali kamu menyelesaikan satu sesi setoran.',
      ],
      paragraphsEn: const [
        'Every product has a carbon footprint, the amount of greenhouse gases produced over its life. For aluminum, most of that footprint comes from mining and smelting raw ore.',
        'When used cans are recycled, those heavy stages are skipped. That is why every can you drop at ReCan genuinely reduces emissions compared with throwing it away.',
        'On the Home page you can follow the carbon impact chart and see how many kilograms of emissions you have saved. The number grows every time you finish a deposit session.',
      ],
      insightId: 'Setiap kaleng yang disetor di ReCan dihitung menghemat sekitar 0,13 kg emisi karbon.',
      insightEn: 'Every can dropped at ReCan is counted as saving about 0.13 kg of carbon emissions.',
      stats: const [
        ArticleStat(
          value: '0,13',
          labelId: 'kg CO2 per kaleng',
          labelEn: 'kg CO2 per can',
        ),
        ArticleStat(
          value: '7',
          labelId: 'Hari grafik mingguan',
          labelEn: 'Days in weekly chart',
        ),
        ArticleStat(
          value: '95%',
          labelId: 'Energi lebih hemat',
          labelEn: 'Less energy used',
        ),
      ],
      publishedAt: DateTime(2026, 10, 10),
      readMinutes: 4,
    ),
    EducationArticle(
      id: 6,
      category: EducationCategory.impact,
      titleId: 'Kampus Bersih, Bumi Lestari',
      titleEn: 'A Clean Campus for a Greener Planet',
      summaryId: 'Dampak kolektif ribuan kaleng yang tidak lagi terbuang.',
      summaryEn: 'The collective impact of thousands of cans kept from waste.',
      paragraphsId: const [
        'Dampak terbesar daur ulang lahir dari kebiasaan bersama. Ketika seluruh civitas ikut menyetor, ribuan kaleng tidak lagi berakhir di tempat pembuangan atau tercecer di taman dan selokan.',
        'Kampus yang bersih bukan hanya enak dipandang. Lingkungan yang terjaga mengurangi risiko banjir akibat saluran tersumbat dan membuat ruang belajar jadi lebih nyaman bagi semua orang.',
        'Program ini sejalan dengan tujuan pembangunan berkelanjutan (SDG 11 dan 12) tentang kota yang berkelanjutan serta konsumsi dan produksi yang bertanggung jawab. Langkahmu hari ini adalah bagian dari gerakan itu.',
      ],
      paragraphsEn: const [
        'The biggest impact of recycling comes from shared habits. When the whole community joins in, thousands of cans no longer end up in landfills or scattered across gardens and drains.',
        'A clean campus is not only pleasant to look at. A well-kept environment reduces the risk of floods from clogged drains and makes study spaces more comfortable for everyone.',
        'This program is aligned with the sustainable development goals (SDG 11 and 12) on sustainable cities and responsible consumption and production. Your step today is part of that movement.',
      ],
      insightId: 'Kampanye SDG 11 & 12 UPJ mengajak seluruh civitas menjadikan daur ulang kaleng sebagai kebiasaan harian.',
      insightEn: 'The UPJ SDG 11 & 12 campaign invites the whole community to make can recycling a daily habit.',
      stats: const [
        ArticleStat(
          value: '1.240',
          labelId: 'kg kaleng terkumpul',
          labelEn: 'kg of cans collected',
        ),
        ArticleStat(
          value: '2',
          labelId: 'Target SDG didukung',
          labelEn: 'SDG goals supported',
        ),
        ArticleStat(
          value: '1.860',
          labelId: 'kg emisi dihemat',
          labelEn: 'kg of emissions saved',
        ),
      ],
      publishedAt: DateTime(2026, 10),
      readMinutes: 5,
    ),
  ];
}
