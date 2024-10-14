def getRemainingSearches(self, desktopAndMobile: bool = False) -> RemainingSearches | int:
    dashboard = self.utils.getDashboardData()
    searchPoints = 1
    counters = dashboard["userStatus"]["counters"]

    # Add checks to ensure the key exists
    progressDesktop = counters.get("pcSearch", [{}])[0].get("pointProgress", 0)
    targetDesktop = counters.get("pcSearch", [{}])[0].get("pointProgressMax", 0)

    if len(counters.get("pcSearch", [])) >= 2:
        progressDesktop += counters["pcSearch"][1].get("pointProgress", 0)
        targetDesktop += counters["pcSearch"][1].get("pointProgressMax", 0)

    if targetDesktop in [30, 90, 102]:
        searchPoints = 3
    elif targetDesktop == 50 or targetDesktop >= 170 or targetDesktop == 150:
        searchPoints = 5

    remainingDesktop = int((targetDesktop - progressDesktop) / searchPoints)
    remainingMobile = 0

    if dashboard["userStatus"]["levelInfo"]["activeLevel"] != "Level1":
        progressMobile = counters.get("mobileSearch", [{}])[0].get("pointProgress", 0)
        targetMobile = counters.get("mobileSearch", [{}])[0].get("pointProgressMax", 0)
        remainingMobile = int((targetMobile - progressMobile) / searchPoints)

    if desktopAndMobile:
        return RemainingSearches(desktop=remainingDesktop, mobile=remainingMobile)
    if self.mobile:
        return remainingMobile
    return remainingDesktop
