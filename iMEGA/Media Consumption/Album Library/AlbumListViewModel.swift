import Combine
import SwiftUI
import MEGADomain

@MainActor
final class AlbumListViewModel: NSObject, ObservableObject  {
    @Published var cameraUploadNode: NodeEntity?
    @Published var album: AlbumEntity?
    @Published var shouldLoad = true
    @Published var albums = [AlbumEntity]()
    @Published var newlyAddedAlbum: AlbumEntity?

    @Published var showCreateAlbumAlert = false {
        willSet {
            self.alertViewModel.placeholderText = newAlbumName()
        }
    }
   
    lazy var selection = AlbumSelection()
    
    var albumCreationAlertMsg: String?
    var albumLoadingTask: Task<Void, Never>?
    var createAlbumTask: Task<Void, Never>?
    var isCreateAlbumFeatureFlagEnabled: Bool {
        featureFlagProvider.isFeatureFlagEnabled(for: .createAlbum)
    }
    var newAlbumContent: (AlbumEntity, [NodeEntity]?)?
    
    var albumNames: [String] {
        albums.map { $0.name }
    }
    
    private let usecase: AlbumListUseCaseProtocol
    private(set) var alertViewModel: TextFieldAlertViewModel
    private let featureFlagProvider: FeatureFlagProviderProtocol
    private var subscriptions = Set<AnyCancellable>()
    
    private weak var photoAlbumContainerViewModel: PhotoAlbumContainerViewModel?
    
    init(usecase: AlbumListUseCaseProtocol,
         alertViewModel: TextFieldAlertViewModel,
         photoAlbumContainerViewModel: PhotoAlbumContainerViewModel? = nil,
         featureFlagProvider: FeatureFlagProviderProtocol = FeatureFlagProvider()) {
        self.usecase = usecase
        self.alertViewModel = alertViewModel
        self.photoAlbumContainerViewModel = photoAlbumContainerViewModel
        self.featureFlagProvider = featureFlagProvider
        super.init()
        setupSubscription()
        self.alertViewModel.action = { [weak self] newAlbumName in
            self?.createUserAlbum(with: newAlbumName)
        }
        
        assignAlbumNameValidator()
        subscribeToEditMode()
    }
    
    func columns(horizontalSizeClass: UserInterfaceSizeClass?) -> [GridItem] {
        guard isCreateAlbumFeatureFlagEnabled,
              let horizontalSizeClass else {
            return Array(
                repeating: .init(.flexible(), spacing: 10),
                count: 3
            )
        }
        return Array(
            repeating: .init(.flexible(), spacing: 10),
            count: horizontalSizeClass == .compact ? 3 : 5
        )
    }
    
    func loadAlbums() {
        albumLoadingTask = Task {
            async let systemAlbums = systemAlbums()
            async let userAlbums = userAlbums()
            albums = await systemAlbums + userAlbums
            shouldLoad = false
        }
    }
    
    func cancelLoading() {
        albumLoadingTask?.cancel()
        createAlbumTask?.cancel()
    }
    
    func createUserAlbum(with name: String?) {
        guard let name = name else { return }
        guard name.isNotEmpty else {
            createUserAlbum(with: newAlbumName())
            return
        }
        
        shouldLoad = true
        createAlbumTask = Task {
            do {
                let newAlbum = try await usecase.createUserAlbum(with: name)
  
                if let insertIndex = albums.firstIndex(where: { $0.type == .user && (newAlbum.modificationTime ?? .distantPast) > ($0.modificationTime ?? .distantPast) }) {
                    albums.insert(newAlbum, at: insertIndex)
                }  else {
                    albums.append(newAlbum)
                }
                newlyAddedAlbum = await usecase.hasNoPhotosAndVideos() ? nil : newAlbum
                photoAlbumContainerViewModel?.shouldShowSelectBarButton = true
            } catch {
                MEGALogError("Error creating user album: \(error.localizedDescription)")
            }
            shouldLoad = false
        }
    }
    
    func onCreateAlbum() {
        guard selection.editMode.isEditing == false else { return }
        showCreateAlbumAlert.toggle()
    }
    
    // MARK: - Private
    private func systemAlbums() async -> [AlbumEntity] {
        do {
            return try await usecase.systemAlbums().map({ album in
                if let localizedAlbumName = localisedName(forAlbumType: album.type) {
                    return album.update(name: localizedAlbumName)
                }
                return album
            })
        } catch {
            MEGALogError("Error loading system albums: \(error.localizedDescription)")
            return []
        }
    }
    
    private func localisedName(forAlbumType albumType: AlbumEntityType) -> String? {
        switch (albumType) {
        case .favourite:
            return Strings.Localizable.CameraUploads.Albums.Favourites.title
        case .gif:
            return Strings.Localizable.CameraUploads.Albums.Gif.title
        case .raw:
            return Strings.Localizable.CameraUploads.Albums.Raw.title
        default:
            return nil
        }
    }
    
    private func userAlbums() async -> [AlbumEntity] {
        var userAlbums = await usecase.userAlbums()
        photoAlbumContainerViewModel?.shouldShowSelectBarButton = userAlbums.isNotEmpty
        userAlbums.sort { ($0.modificationTime ?? .distantPast) > ($1.modificationTime ?? .distantPast) }
        return userAlbums
    }
    
    private func assignAlbumNameValidator() {
        alertViewModel.validator = AlbumNameValidator(
            existingAlbumNames: { [weak self] in
                self?.albumNames ?? []
            }).create
    }
    

    func newAlbumName() -> String {
        let newAlbumName = Strings.Localizable.CameraUploads.Albums.Create.Alert.placeholder
        let names = Set(albums.filter { $0.name.hasPrefix(newAlbumName) }.map { $0.name })
        
        guard names.count > 0 else { return newAlbumName }
        guard names.contains(newAlbumName) else { return newAlbumName }
        
        for i in 1...names.count {
            let newName = "\(newAlbumName) (\(i))"
            if !names.contains(newName) {
                return newName
            }
        }
        return newAlbumName
    }
    
    func onNewAlbumContentAdded(_ album: AlbumEntity, photos: [NodeEntity]) {
        newAlbumContent = (album, photos)
    }
    
    func navigateToNewAlbum() {
        album = newAlbumContent?.0
    }
    
    @MainActor
    func onAlbumTap(_ album: AlbumEntity) {
        guard selection.editMode.isEditing == false else { return }
        
        albumCreationAlertMsg = nil
        self.album = album
    }
    
    // MARK: - Private
    
    private func setupSubscription() {
        usecase.albumsUpdatedPublisher
            .debounce(for: .seconds(0.35), scheduler: DispatchQueue.global())
            .sink { [weak self] in
                self?.loadAlbums()
            }.store(in: &subscriptions)
    }
    
    private func subscribeToEditMode() {
        photoAlbumContainerViewModel?.$editMode
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.selection.editMode = $0
            })
            .store(in: &subscriptions)
    }
}
