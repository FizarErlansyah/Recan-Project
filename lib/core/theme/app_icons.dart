import 'package:hugeicons/hugeicons.dart';

/// Hugeicons glyph data as stored on models and passed between widgets.
typedef IconGlyph = List<List<dynamic>>;

/// The one place that decides which Hugeicons glyph stands for each concept,
/// so the same idea never gets two different drawings across screens.
abstract final class AppIcons {
  // Navigation and controls
  static const IconGlyph back = HugeIcons.strokeRoundedArrowLeft01;
  static const IconGlyph chevronRight = HugeIcons.strokeRoundedArrowRight01;
  static const IconGlyph check = HugeIcons.strokeRoundedTick02;
  static const IconGlyph checkCircle = HugeIcons.strokeRoundedCheckmarkCircle02;
  static const IconGlyph radioOff = HugeIcons.strokeRoundedCircle;
  static const IconGlyph add = HugeIcons.strokeRoundedAdd01;
  static const IconGlyph remove = HugeIcons.strokeRoundedMinusSign;
  static const IconGlyph refresh = HugeIcons.strokeRoundedRefresh;
  static const IconGlyph offline = HugeIcons.strokeRoundedWifiDisconnected01;
  static const IconGlyph download = HugeIcons.strokeRoundedDownload01;
  static const IconGlyph share = HugeIcons.strokeRoundedShare01;
  static const IconGlyph bookmark = HugeIcons.strokeRoundedBookmark01;
  static const IconGlyph camera = HugeIcons.strokeRoundedCamera01;
  static const IconGlyph apps = HugeIcons.strokeRoundedDashboardSquare01;

  // Account and forms
  static const IconGlyph person = HugeIcons.strokeRoundedUser;
  static const IconGlyph mail = HugeIcons.strokeRoundedMail01;
  static const IconGlyph phone = HugeIcons.strokeRoundedCall;
  static const IconGlyph lock = HugeIcons.strokeRoundedLockPassword;
  static const IconGlyph visible = HugeIcons.strokeRoundedView;
  static const IconGlyph hidden = HugeIcons.strokeRoundedViewOff;
  static const IconGlyph translate = HugeIcons.strokeRoundedTranslate;
  static const IconGlyph appearance = HugeIcons.strokeRoundedMoon02;
  static const IconGlyph help = HugeIcons.strokeRoundedHelpCircle;
  static const IconGlyph info = HugeIcons.strokeRoundedInformationCircle;
  static const IconGlyph document = HugeIcons.strokeRoundedFile02;
  static const IconGlyph logout = HugeIcons.strokeRoundedLogout01;
  static const IconGlyph notes = HugeIcons.strokeRoundedNoteEdit;

  // ReCan domain
  static const IconGlyph recycle = HugeIcons.strokeRoundedRecycle01;
  static const IconGlyph coins = HugeIcons.strokeRoundedCoins01;
  static const IconGlyph eco = HugeIcons.strokeRoundedLeaf01;
  static const IconGlyph weight = HugeIcons.strokeRoundedWeightScale;
  static const IconGlyph gift = HugeIcons.strokeRoundedGift;
  static const IconGlyph globe = HugeIcons.strokeRoundedGlobe02;
  static const IconGlyph wallet = HugeIcons.strokeRoundedWallet01;
  static const IconGlyph bank = HugeIcons.strokeRoundedBank;
  static const IconGlyph qr = HugeIcons.strokeRoundedQrCode;
  static const IconGlyph location = HugeIcons.strokeRoundedLocation01;
  static const IconGlyph medal = HugeIcons.strokeRoundedMedal01;
  static const IconGlyph award = HugeIcons.strokeRoundedAward01;
  static const IconGlyph target = HugeIcons.strokeRoundedTarget01;
  static const IconGlyph package = HugeIcons.strokeRoundedPackage;
  static const IconGlyph ai = HugeIcons.strokeRoundedAiChat02;

  // Content
  static const IconGlyph clock = HugeIcons.strokeRoundedClock01;
  static const IconGlyph idea = HugeIcons.strokeRoundedIdea01;
  static const IconGlyph chart = HugeIcons.strokeRoundedBarChart;
  static const IconGlyph thumbsUp = HugeIcons.strokeRoundedThumbsUp;
  static const IconGlyph science = HugeIcons.strokeRoundedMicroscope;
  static const IconGlyph warning = HugeIcons.strokeRoundedAlert02;
  static const IconGlyph autorenew = HugeIcons.strokeRoundedRepeat;
  static const IconGlyph collaboration = HugeIcons.strokeRoundedHandshake;
  static const IconGlyph team = HugeIcons.strokeRoundedUserGroup;
  static const IconGlyph smartphone = HugeIcons.strokeRoundedSmartPhone01;
  static const IconGlyph architecture = HugeIcons.strokeRoundedBuilding03;
  static const IconGlyph design = HugeIcons.strokeRoundedPaintBoard;

  // Policy pages
  static const IconGlyph legal = HugeIcons.strokeRoundedLegalHammer;
  static const IconGlyph sharedData = HugeIcons.strokeRoundedFolderShared01;
  static const IconGlyph accountSettings =
      HugeIcons.strokeRoundedUserSettings01;
  static const IconGlyph security = HugeIcons.strokeRoundedSecurityCheck;
  static const IconGlyph privacy = HugeIcons.strokeRoundedShieldUser;

  // Station and onboarding
  static const IconGlyph dashboard = HugeIcons.strokeRoundedDashboardSquare01;
  static const IconGlyph meal = HugeIcons.strokeRoundedRestaurant01;
  static const IconGlyph parking = HugeIcons.strokeRoundedSquareParking;
  static const IconGlyph print = HugeIcons.strokeRoundedPrinter;
}
