class SubscriptionTier {
  final bool isPremium;
  final int freeExportsRemaining;
  final int maxFreeExportsPerDay;
  final bool showWatermark;
  final bool showAds;

  SubscriptionTier({
    required this.isPremium,
    required this.freeExportsRemaining,
    this.maxFreeExportsPerDay = 3,
    required this.showWatermark,
    required this.showAds,
  });

  SubscriptionTier copyWith({
    bool? isPremium,
    int? freeExportsRemaining,
    int? maxFreeExportsPerDay,
    bool? showWatermark,
    bool? showAds,
  }) {
    return SubscriptionTier(
      isPremium: isPremium ?? this.isPremium,
      freeExportsRemaining: freeExportsRemaining ?? this.freeExportsRemaining,
      maxFreeExportsPerDay: maxFreeExportsPerDay ?? this.maxFreeExportsPerDay,
      showWatermark: showWatermark ?? this.showWatermark,
      showAds: showAds ?? this.showAds,
    );
  }
}
