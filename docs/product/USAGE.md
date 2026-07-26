# Igor G-LIDAR — что готово и как пользоваться

Интерактивная презентация: [igor-g-lidar-guide.html](./igor-g-lidar-guide.html)  
Обучающее видео: [igor-g-lidar-usage.mp4](./igor-g-lidar-usage.mp4) (пересборка: `./scripts/build-usage-video.sh`)

## Что сделано

- **Скан комнаты** — LiDAR-mesh в реальном времени (голубая сетка), экспорт в `.obj`
- **Скан предмета** — Object Capture → текстурированный `.usdz`
- **Библиотека** — список сканов, превью, ShareLink, локальное удаление
- **Файлы iOS** — `Файлы → На моём iPhone → Igor G-LIDAR`
- Русский UI и скрипт деплоя на физический iPhone

## Что работает

| Сценарий | Статус |
|----------|--------|
| Комната → OBJ | Работает на устройстве с LiDAR |
| Предмет → USDZ | Работает, если `ObjectCaptureSession.isSupported` |
| Библиотека / Share / Files | Работает |
| iOS Simulator | Не поддерживается |

Без LiDAR приложение сообщает, что сканирование недоступно.

## Требования

- iOS 18+, Xcode 16+
- Физическое устройство с LiDAR (iPhone Pro / iPad Pro)
- `xcodegen` для генерации `.xcodeproj`

## Как запустить

```bash
cd SwiftUI-LiDAR
brew install xcodegen   # если нужно
xcodegen generate
open "Lidar Scan.xcodeproj"
```

Схема **Lidar Scan**, выбрать физическое устройство (не Simulator).

Или:

```bash
./scripts/deploy-iphone.sh
# опционально: IOS_DEVICE_ID / IOS_CORE_DEVICE
```

Разблокируйте iPhone перед установкой.

## Как пользоваться

### 1. Сканировать комнату

1. На старте — **Сканировать комнату**
2. Медленно обойдите пространство 30–60 сек; голубая сетка = поверхности видны
3. **Экспортировать 3D-модель** → имя файла → share sheet
4. Файл также в `Documents/Scans/Rooms/`

### 2. Сканировать предмет

1. Один объект, чистый фон, зафиксируйте предмет
2. **Сканировать предмет** → обход по кругу по подсказкам Object Capture
3. После съёмки — реконструкция → `model-mobile.usdz`
4. Лучше матовые текстурированные поверхности и ровный свет  
   Не снимайте всю комнату в этом режиме.

### 3. Мои 3D-сканы

1. Кнопка **Мои 3D-сканы**
2. Превью, шаринг, удаление
3. В приложении Файлы: **На моём iPhone → Igor G-LIDAR**  
   (`Scans/Rooms`, `Scans/Objects/…`)

## Пересборка видео

```bash
./scripts/build-usage-video.sh
```

Нужны: `ffmpeg`, ImageMagick (`magick`/`convert`), голос macOS `say` (например Milena).
Скрипт сам создаст `.venv-video` с Pillow для кириллических слайдов.
