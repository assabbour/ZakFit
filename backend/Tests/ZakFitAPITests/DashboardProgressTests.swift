import Testing
@testable import ZakFitAPI

struct DashboardProgressTests {
    @Test func progressionSansActivite() {
        #expect(dashboardProgressPercentage(current: 0, target: 60) == 0)
    }

    @Test func progressionPartielle() {
        let percentage = dashboardProgressPercentage(current: 40, target: 60)
        #expect(abs(percentage - 66.6667) < 0.001)
    }

    @Test func objectifDepasse() {
        #expect(dashboardProgressPercentage(current: 75, target: 60) == 125)
    }
}
