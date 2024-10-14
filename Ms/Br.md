def getRemainingSearches(
    self, desktopAndMobile: bool = False
) -> RemainingSearches | int:
    bingInfo = self.utils.getBingInfo()
    searchPoints = 1
    counters = bingInfo["flyoutResult"]["userStatus"]["counters"]

    pcSearch: dict = counters.get("PCSearch", [{}])[0]
    mobileSearch: dict = counters.get("MobileSearch", [{}])[0]

    pointProgressMax: int = pcSearch.get("pointProgressMax", 0)
    searchPoints: int
    if pointProgressMax in [30, 90, 102]:
        searchPoints = 3
    elif pointProgressMax in [50, 150] or pointProgressMax >= 170:
        searchPoints = 5
    else:
        searchPoints = 1

    pcPointsRemaining = pcSearch.get("pointProgressMax", 0) - pcSearch.get("pointProgress", 0)
    assert pcPointsRemaining % searchPoints == 0
    remainingDesktopSearches: int = int(pcPointsRemaining / searchPoints)

    mobilePointsRemaining = (
        mobileSearch.get("pointProgressMax", 0) - mobileSearch.get("pointProgress", 0)
    )
    assert mobilePointsRemaining % searchPoints == 0
    remainingMobileSearches: int = int(mobilePointsRemaining / searchPoints)

    if desktopAndMobile:
        return RemainingSearches(
            desktop=remainingDesktopSearches, mobile=remainingMobileSearches
        )
    if self.mobile:
        return remainingMobileSearches
    return remainingDesktopSearches
