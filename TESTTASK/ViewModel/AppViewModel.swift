import Foundation
import UIKit
import Network

@MainActor
final class AppViewModel: ObservableObject {

    // MARK: Published поля
    
    // – Users
    @Published private(set) var users: [UserModel] = []
    @Published private(set) var isLoadingUsers = false
    @Published private(set) var usersHasMore  = true
    @Published var usersError: String? = nil

    // – Positions
    @Published private(set) var positions: [Position] = []
    @Published var positionsError: String? = nil

    // – Submit (Sign Up)
    @Published var isSubmitting = false
    @Published var createdUserId: Int? = nil
    @Published var submitError: SubmitError? = nil
    
    // - Network
    @Published var isConnected = true

    enum SubmitError: Identifiable, Equatable {
        case emailExists, tokenExpired, validation(String), other(String)
        var id: String {
            switch self {
            case .emailExists:   return "emailExists"
            case .tokenExpired:  return "tokenExpired"
            case .validation(let f): return "validation_\(f)"
            case .other(let m):  return m
            }
        }
    }

    // MARK: – приватні стани
    private var nextUsersURL: URL? = nil
    private let pageSize = 6
    private let imgCache = NSCache<NSURL, UIImage>()

    // token кешується на 40 хвилин
    private var cachedToken: String? = nil
    private var tokenFetchedAt: Date? = nil

    //───────────────────────────────────────────────────────────
    // MARK: Users
    //───────────────────────────────────────────────────────────
    func loadInitialUsers() async {
        resetUsersState()
        await loadUsersPage(url: makeUsersURL(page: 1))
    }

    func loadNextUsersIfNeeded(currentIdx idx: Int) async {
        guard idx == users.count - 1, usersHasMore else { return }
        await loadUsersPage(url: nextUsersURL)
    }

    private func resetUsersState() {
        users.removeAll(); usersHasMore = true; nextUsersURL = nil; usersError = nil
    }

    private func makeUsersURL(page: Int) -> URL {
        URL(string: "https://frontend-test-assignment-api.abz.agency/api/v1/users?page=\(page)&count=\(pageSize)")!
    }

    private func loadUsersPage(url: URL?) async {
        guard let url, !isLoadingUsers else { return }
        isLoadingUsers = true; usersError = nil
        #if DEBUG
        print("➡️ GET", url.absoluteString)
        #endif
        defer { isLoadingUsers = false }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let resp = try API.decoder.decode(UsersResponse.self, from: data)
            guard resp.success else { throw NSError(domain: "API", code: -1, userInfo:[NSLocalizedDescriptionKey:"success:false"]) }

            let startIdx = users.count
            users += resp.users.map(UserModel.init)
            nextUsersURL = resp.links.nextUrl
            usersHasMore = nextUsersURL != nil
            #if DEBUG
            print("✅ page", resp.page, "users +", resp.users.count)
            #endif
            // avatars
            for (off, dto) in resp.users.enumerated() {
                Task.detached { [weak self] in
                    await self?.fetchAvatar(url: dto.photo, at: startIdx + off)
                }
            }
        } catch {
            usersError = error.localizedDescription
            usersHasMore = false
            #if DEBUG
            print("❌ users error:", error)
            #endif
        }
    }

    private func fetchAvatar(url: URL, at idx: Int) async {
        if let img = imgCache.object(forKey: url as NSURL) {
            await MainActor.run { self.users[idx].avatar = img }; return }
        do {
            let (d, _) = try await URLSession.shared.data(from: url)
            if let img = UIImage(data: d) {
                imgCache.setObject(img, forKey: url as NSURL)
                await MainActor.run { self.users[idx].avatar = img }
            }
        } catch {}
    }

    //───────────────────────────────────────────────────────────
    // MARK: Positions (для радіо‑кнопок)
    //───────────────────────────────────────────────────────────
    func loadPositions() async {
        do {
            let resp: PositionsResponse = try await API.get("positions")
            positions = resp.positions
        } catch {
            positionsError = error.localizedDescription
        }
    }

    //───────────────────────────────────────────────────────────
    // MARK: Submit (POST /users)
    //───────────────────────────────────────────────────────────
    func submit(form: FormInput) async -> Bool {
        isSubmitting = true; submitError = nil; createdUserId = nil
        defer { isSubmitting = false }
        do {
            let token = try await ensureToken()

            // multipart
            var mp = MultipartForm()
            mp.field("name",        form.name)
            mp.field("email",       form.email)
            mp.field("phone",       form.phone)
            mp.field("position_id", String(form.positionId))
            mp.image("photo", data: form.jpegData)

            var req = URLRequest(url: API.base.appendingPathComponent("users"))
            req.httpMethod = "POST"
            req.httpBody   = mp.body
            req.setValue("multipart/form-data; boundary=\(mp.boundary)", forHTTPHeaderField: "Content-Type")
            req.setValue(token, forHTTPHeaderField: "Token")

            let (data, resp) = try await URLSession.shared.data(for: req)
            guard let http = resp as? HTTPURLResponse else { throw URLError(.badServerResponse) }

            switch http.statusCode {
            case 200..<300:
                let ok = try API.decoder.decode(PostOK.self, from: data)
                createdUserId = ok.userId
                Task { await self.loadInitialUsers() }
                return true

            case 401:
                submitError = .tokenExpired
                cachedToken = nil
                return false

            case 409:
                submitError = .emailExists
                return false

            case 422:
                let api = try? API.decoder.decode(APIError.self, from: data)
                submitError = .validation(api?.message ?? "Validation failed")
                return false

            default:
                let api = try? API.decoder.decode(APIError.self, from: data)
                submitError = .other(api?.message ?? "Server error \(http.statusCode)")
                return false
            }
        } catch {
            submitError = .other(error.localizedDescription)
            return false
        }
    }

    //───────────────────────────────────────────────────────────
    // MARK: Helpers
    //───────────────────────────────────────────────────────────
    private func ensureToken() async throws -> String {
        if let tok = cachedToken, let ts = tokenFetchedAt, Date().timeIntervalSince(ts) < 40*60 {
            return tok
        }
        let dto: TokenResponse = try await API.get("token")
        guard dto.success else { throw URLError(.badServerResponse) }
        cachedToken = dto.token; tokenFetchedAt = Date()
        return dto.token
    }
    //───────────────────────────────────────────────────────────────
    // MARK: – Network
    //───────────────────────────────────────────────────────────────
    
    private let monitor = NWPathMonitor()
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in self?.isConnected = path.status == .satisfied }
        }
        monitor.start(queue: .global(qos: .background))
    }

}

//───────────────────────────────────────────────────────────────
// MARK: – Simple Multipart builder
//───────────────────────────────────────────────────────────────
private struct MultipartForm {
    let boundary = UUID().uuidString
    private let crlf = "\r\n"
    fileprivate var buffer = Data()

    mutating func field(_ name: String, _ value: String) {
        append("--\(boundary)\(crlf)")
        append("Content-Disposition: form-data; name=\"\(name)\"\(crlf+crlf)")
        append(value + crlf)
    }
    mutating func image(_ name: String, data img: Data) {
        append("--\(boundary)\(crlf)")
        append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"photo.jpg\"\(crlf)")
        append("Content-Type: image/jpeg\(crlf+crlf)")
        buffer.append(img); append(crlf)
    }
    private mutating func append(_ s: String) { buffer.append(s.data(using: .utf8)!) }
    var body: Data {
        var end = buffer; end.append("--\(boundary)--\(crlf)".data(using: .utf8)!); return end
    }
}

enum API {
    static let base = URL(string: "https://frontend-test-assignment-api.abz.agency/api/v1")!

    static let decoder: JSONDecoder = {
        let d = JSONDecoder(); d.keyDecodingStrategy = .convertFromSnakeCase; return d
    }()

    /// Generic GET → T
    static func get<T: Decodable>(_ path: String) async throws -> T {
        let (data, _) = try await URLSession.shared.data(from: base.appendingPathComponent(path))
        return try decoder.decode(T.self, from: data)
    }
}
