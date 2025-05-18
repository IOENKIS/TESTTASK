# TESTTASK — iOS Demo App (Swift UI / Async‑Await)

A small, production‑style iOS 17 app crafted for the **ABZ Agency developer test assignment**.
It demonstrates:

* 🔄 **Paginated GET** (`/users?page=&count=`) — infinite scroll + image caching
* 📝 **Multipart POST** (`/users`) — registration form with validation & photo upload
* 🗂  Single **AppViewModel** (MVVM) shared between tabs
* 🔌 **Reachability** overlay (NWPathMonitor)
* 🌗  SwiftUI only — no storyboards, almost no UIKit

---

## 📦  Project structure

```
TESTTASK/
├─ Model
│  ├─ PresentationModel.swift
│  └─ UserDTO.swift
│
├─ ViewModel
│  └─ AppViewModel.swift
│
├─ View
│  ├─ Splash
│  │  └─ SplashView.swift
│  ├─ GET
│  │  ├─ UserCardView.swift
│  │  └─ UsersView.swift
│  ├─ POST
│  │  ├─ CustomTextField.swift
│  │  ├─ PhotoUploadField.swift
│  │  ├─ RadioButtonField.swift
│  │  ├─ RegistrationOverlay.swift
│  │  └─ SignUpView.swift
│  └─ Extra
│     ├─ ImagePicker.swift
│     ├─ NoInternetOverlay.swift
│     └─ TopBar.swift
│
├─ Resources
│  ├─ Fonts/NunitoSans-Variable.ttf
│  ├─ Styles/ButtonStyles.swift
│  ├─ Styles/TextStyle.swift
│  └─ Assets.xcassets (colors, icons, .noInternet, …)
│
└─ App
   ├─ ContentView.swift (tabs + splash routing)
   └─ TESTTASKApp.swift (entry point)
```

---

## 🚀  Getting started

1. **Xcode 15+**, iOS 17 SDK.
2. `git clone` → open **TESTTASK.xcodeproj**.
3. Build & run on a device (*preferred*) or simulator.

> The app needs **Camera** access for photo upload — accept the prompt on first launch.

---

## 🏗  Key implementation notes

| Feature                | File                           | Comment                                           |
| ---------------------- | ------------------------------ | ------------------------------------------------- |
| Splash screen (3 s)    | `ContentView.swift`            | `@State showSplash` + `transition(.opacity)`      |
| Single source of truth | `AppViewModel.swift`           | Handles networking, reachability, caching         |
| Network layer          | bottom of `AppViewModel.swift` | Tiny `enum API` with generic async GET            |
| Image cache            | `NSCache<NSURL,UIImage>`       | Avatar downloaded once per session                |
| Button styles          | `ButtonStyles.swift`           | `primaryButton()` / `secondaryButton()` modifier  |
| No‑Internet overlay    | `NoInternetOverlay.swift`      | Appears globally when `!vm.isConnected`           |
| Validation             | inside `SignUpView`            | RFC‑2822 regex (email), UA‑phone, JPEG size check |

---

## 🖼  Screenshots

| Users | Sign Up | No Internet |
| ----- | ------- | ----------- |
|![users](https://github.com/user-attachments/assets/89c520db-0320-434f-9aeb-042c0ae5087f)|![singUp](https://github.com/user-attachments/assets/37ae051e-da68-4d9e-9ec4-72faaea07aae)|![noInternet](https://github.com/user-attachments/assets/f4907377-ded6-4258-a33d-61e8d4d0b5cb)|

---

## 🔧  Configuration & customisation

| Setting           | Where                    | Default                                                  |
| ----------------- | ------------------------ | -------------------------------------------------------- |
| API base URL      | `API.base`               | `https://frontend-test-assignment-api.abz.agency/api/v1` |
| Page size (users) | `AppViewModel.pageSize`  | `6`                                                      |
| Token TTL         | `ensureToken()`          | `40 min`                                                 |
| Primary color     | `Assets › customPrimary` | `#F8DA2A`                                                |

---

## 🤝  Credits / 3rd‑party

Pure Swift / SwiftUI. No external libraries are used.

---

## 📄  License

MIT — do whatever you want, but the code is provided **as is** with no warranty.
