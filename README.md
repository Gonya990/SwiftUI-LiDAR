# Lidar Scan (Igor G-LIDAR)

SwiftUI + ARKit iOS app for LiDAR room meshes and Object Capture models. Built with [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`project.yml`).

**Bundle ID:** `com.igorgoncharenko.lidarscan`  
**Display name:** Igor G-LIDAR  
**Product name:** Lidar Scan IGORAN

## Features

- **Room scan (OBJ)** — fast LiDAR mesh of a space, export as `.obj`
- **Object Capture (USDZ)** — guided multi-pass capture of a physical object into a textured `.usdz`
- **Library** — browse saved scans, share via the system share sheet / Files, delete locally
- Scans live under **Files → On My iPhone → Igor G-LIDAR**

## Requirements

- iOS 18.0+
- Xcode 16+ (with iOS 18 SDK)
- Physical device with a LiDAR sensor (iPhone Pro / iPad Pro)
- **Simulator is not supported** (ARKit LiDAR + Object Capture require hardware)

## Getting started

```bash
git clone https://github.com/Gonya990/SwiftUI-LiDAR.git
cd SwiftUI-LiDAR
brew install xcodegen   # if needed
xcodegen generate
open "Lidar Scan.xcodeproj"
```

Select a physical LiDAR device and run the **Lidar Scan** scheme.

## Deploy to iPhone

```bash
# Optional overrides if your UDID / CoreDevice UUID differ:
# export IOS_DEVICE_ID=00008130-...
# export IOS_CORE_DEVICE=E2386A00-...
./scripts/deploy-iphone.sh
```

The script regenerates a bloated Xcode project if needed, builds for device, installs, and launches `com.igorgoncharenko.lidarscan`. Unlock the phone (passcode) before install.

## Презентация и видео

Русскоязычная инструкция по продукту:

- [docs/product/USAGE.md](docs/product/USAGE.md) — что готово, запуск, сценарии использования
- [docs/product/igor-g-lidar-guide.html](docs/product/igor-g-lidar-guide.html) — слайд-презентация (откройте в браузере)
- [docs/product/igor-g-lidar-usage.mp4](docs/product/igor-g-lidar-usage.mp4) — короткое обучающее видео

Пересборка видео (нужны `ffmpeg`, ImageMagick, `say`):

```bash
./scripts/build-usage-video.sh
```

## Tech stack

- SwiftUI, ARKit, RealityKit, SceneKit
- Apple Object Capture sample code (see `APPLE_OBJECT_CAPTURE_SAMPLE_LICENSE.txt`)

## License

MIT License
