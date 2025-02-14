@testable import MEGA
import MEGADomain

final class MockDownloadNodeUseCase: DownloadNodeUseCaseProtocol {
    var transferEntity: TransferEntity? = nil
    var result: (Result<TransferEntity, TransferErrorEntity>)? = nil
    var transferError: TransferErrorEntity = .generic
    
    func downloadFileToOffline(forNodeHandle handle: HandleEntity, filename: String?, appdata: String?, startFirst: Bool, start: ((TransferEntity) -> Void)?, update: ((TransferEntity) -> Void)?, completion: ((Result<TransferEntity, TransferErrorEntity>) -> Void)?, folderUpdate: ((FolderTransferUpdateEntity) -> Void)?) {
        guard let result = result else { return }
        completion?(result)
    }
    
    func downloadChatFileToOffline(forNodeHandle handle: HandleEntity, messageId: HandleEntity, chatId: HandleEntity, filename: String?, appdata: String?, startFirst: Bool, start: ((TransferEntity) -> Void)?, update: ((TransferEntity) -> Void)?, completion: ((Result<TransferEntity, TransferErrorEntity>) -> Void)?) {
        guard let result = result else { return }
        completion?(result)
    }

    func downloadFileToTempFolder(nodeHandle: HandleEntity, appData: String?, update: ((TransferEntity) -> Void)?, completion: @escaping (Result<TransferEntity, TransferErrorEntity>) -> Void) {
        guard let transferEntity = transferEntity,
              let update = update else { return }
        update(transferEntity)
        guard let result = result else { return }
        completion(result)
    }
    
    func downloadFileLinkToOffline(_ fileLink: FileLinkEntity, filename: String?, transferMetaData: TransferMetaDataEntity?, startFirst: Bool, start: ((TransferEntity) -> Void)?, update: ((TransferEntity) -> Void)?, completion: @escaping (Result<TransferEntity, TransferErrorEntity>) -> Void) {
        guard let result = result else { return }
        completion(result)
    }
    
    func cancelDownloadTransfers() { }
}
