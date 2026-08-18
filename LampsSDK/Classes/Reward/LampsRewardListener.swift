import Foundation

struct LampsRewardLoadListener {
    var onReqError: ((_ code: Int, _ message: String?) -> Void)?
    var onLoadSuccess: ((_ model: LampsRewardAdModel) -> Void)?
    var onLoadError: (() -> Void)?
}

struct LampsRewardInteractionListener {
    var onAdShow: ((_ model: LampsRewardAdModel) -> Void)?
    var onAdShowError: ((_ model: LampsRewardAdModel, _ code: Int, _ message: String?) -> Void)?
    var onAdRewardArrived: ((_ model: LampsRewardAdModel) -> Void)?
    var onAdClose: ((_ model: LampsRewardAdModel, _ hasRewarded: Bool) -> Void)?
}

struct LampsRewardSDKLoadListener {
    var onSuccess: ((_ winner: LampsRewardAdModel) -> Void)?
    var onFail: (() -> Void)?
}
