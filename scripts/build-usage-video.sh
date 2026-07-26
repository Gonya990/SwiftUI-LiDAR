#!/usr/bin/env bash
# Build narrated Russian usage video for Igor G-LIDAR (slideshow + TTS).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

OUT_DIR="${OUT_DIR:-$ROOT/docs/product}"
WORK="${TMPDIR:-/tmp}/igor-g-lidar-video-$$"
ARTIFACTS_DIR="${ARTIFACTS_DIR:-$HOME/.cursor/projects/Users-igorgoncharenko/artifacts}"
W=1920
H=1080
VOICE="${SAY_VOICE:-Milena}"
FPS=30

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing: $1" >&2; exit 1; }; }
need ffmpeg
need ffprobe
need say
need python3

if command -v magick >/dev/null 2>&1; then
  IM=(magick)
elif command -v convert >/dev/null 2>&1; then
  IM=(convert)
else
  echo "Missing: ImageMagick (magick or convert)" >&2
  exit 1
fi

# Prefer project venv with Pillow for Cyrillic slides
PY="$ROOT/.venv-video/bin/python"
if [[ ! -x "$PY" ]]; then
  python3 -m venv "$ROOT/.venv-video"
  "$ROOT/.venv-video/bin/pip" install -q pillow
  PY="$ROOT/.venv-video/bin/python"
fi

mkdir -p "$WORK/slides" "$WORK/audio" "$WORK/clips" "$OUT_DIR" "$ARTIFACTS_DIR"
trap 'rm -rf "$WORK"' EXIT

make_slide() {
  local name="$1" title="$2" body="$3"
  "$PY" "$ROOT/scripts/render_slide.py" --title "$title" --body "$body" --out "$WORK/slides/${name}.png"
}

fit_media_to_slide() {
  local src="$1" dest="$2"
  "${IM[@]}" "$src" -resize "${W}x${H}>" -background '#0b1220' -gravity center -extent "${W}x${H}" "$dest"
}

audio_duration() {
  ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$1"
}

make_still_clip() {
  local frame="$1" wav="$2" clip="$3"
  local dur pad_dur
  dur="$(audio_duration "$wav")"
  pad_dur="$(python3 -c "print(max(2.5, float('$dur') + 0.45))")"
  ffmpeg -y -hide_banner -loglevel error \
    -loop 1 -i "$frame" -i "$wav" \
    -c:v libx264 -preset medium -crf 22 -tune stillimage \
    -c:a aac -b:a 128k -pix_fmt yuv420p \
    -t "$pad_dur" -shortest "$clip"
}

make_gif_clip() {
  local gif="$1" wav="$2" clip="$3"
  local dur pad_dur
  dur="$(audio_duration "$wav")"
  pad_dur="$(python3 -c "print(max(2.5, float('$dur') + 0.45))")"
  ffmpeg -y -hide_banner -loglevel error -stream_loop -1 -i "$gif" -i "$wav" \
    -vf "scale=${W}:${H}:force_original_aspect_ratio=decrease,pad=${W}:${H}:(ow-iw)/2:(oh-ih)/2:color=0x0b1220,fps=${FPS},format=yuv420p" \
    -c:v libx264 -preset medium -crf 23 -c:a aac -b:a 128k \
    -t "$pad_dur" -shortest "$clip"
}

speak() {
  local id="$1" text="$2"
  local aiff="$WORK/audio/${id}.aiff"
  local wav="$WORK/audio/${id}.wav"
  say -v "$VOICE" -o "$aiff" "$text"
  ffmpeg -y -hide_banner -loglevel error -i "$aiff" "$wav"
  echo "$wav"
}

echo "Voice: $VOICE"
echo "Work:  $WORK"
echo "Python slides: $PY"

make_slide "01_title" "Igor G-LIDAR" \
  $'3D-сканер на LiDAR\nКомната → .obj · Предмет → .usdz\nБиблиотека и Файлы iOS'

make_slide "03_works" "Что работает" \
  $'• Физический iPhone / iPad Pro с LiDAR\n• Симулятор — нет\n• Object Capture — если поддерживается устройством\n• Без LiDAR — сообщение о недоступности'

make_slide "04_launch" "Как запустить" \
  $'1. brew install xcodegen\n2. xcodegen generate\n3. open \"Lidar Scan.xcodeproj\"\n4. Схема Lidar Scan → устройство\n\nили: ./scripts/deploy-iphone.sh'

make_slide "07_object" "Скан предмета → USDZ" \
  $'• Один объект в кадре\n• Обойдите по кругу\n• Матовые поверхности, ровный свет\n• Результат: model-mobile.usdz\n• Не сканируйте всю комнату в этом режиме'

make_slide "09_tips" "Советы и дальше" \
  $'• Комната: плавное покрытие сеткой\n• Предмет: текстура, без блеска\n• HTML: docs/product/igor-g-lidar-guide.html\n• Текст: docs/product/USAGE.md'

concat_list="$WORK/concat.txt"
: > "$concat_list"

wav="$(speak 01_title 'Igor G LiDAR. Трёхмерный сканер на LiDAR для iPhone и iPad Pro. Комната в OBJ, предмет в USDZ.')"
make_still_clip "$WORK/slides/01_title.png" "$wav" "$WORK/clips/01_title.mp4"
printf "file '%s'\n" "$WORK/clips/01_title.mp4" >> "$concat_list"

fit_media_to_slide "$ROOT/Screenshots/Start Screen.PNG" "$WORK/slides/02_done.png"
wav="$(speak 02_done 'Готовы три сценария: скан комнаты с голубой сеткой и экспорт в OBJ, скан предмета через Object Capture в USDZ, и библиотека с шарингом через Файлы.')"
make_still_clip "$WORK/slides/02_done.png" "$wav" "$WORK/clips/02_done.mp4"
printf "file '%s'\n" "$WORK/clips/02_done.mp4" >> "$concat_list"

wav="$(speak 03_works 'Всё работает на физическом устройстве с LiDAR. Симулятор не поддерживается. Скан предмета доступен только если Object Capture поддерживается на устройстве.')"
make_still_clip "$WORK/slides/03_works.png" "$wav" "$WORK/clips/03_works.mp4"
printf "file '%s'\n" "$WORK/clips/03_works.mp4" >> "$concat_list"

wav="$(speak 04_launch 'Установите Xcode шестнадцать и xcodegen. Выполните xcodegen generate, откройте проект и запустите схему Lidar Scan на iPhone. Либо используйте скрипт deploy-iphone.sh.')"
make_still_clip "$WORK/slides/04_launch.png" "$wav" "$WORK/clips/04_launch.mp4"
printf "file '%s'\n" "$WORK/clips/04_launch.mp4" >> "$concat_list"

fit_media_to_slide "$ROOT/Screenshots/3D Scanning.PNG" "$WORK/slides/05_room.png"
wav="$(speak 05_room 'Нажмите «Сканировать комнату». Медленно обойдите пространство. Голубая сетка показывает поверхности. Когда зона покрыта — экспортируйте трёхмерную модель в OBJ.')"
make_still_clip "$WORK/slides/05_room.png" "$wav" "$WORK/clips/05_room.mp4"
printf "file '%s'\n" "$WORK/clips/05_room.mp4" >> "$concat_list"

wav="$(speak 06_room_gif 'Продолжайте движение плавно, пока сетка не покроет пол, стены и крупные объекты.')"
make_gif_clip "$ROOT/Screenshots/Capture 3D Scan.gif" "$wav" "$WORK/clips/06_room_gif.mp4"
printf "file '%s'\n" "$WORK/clips/06_room_gif.mp4" >> "$concat_list"

wav="$(speak 07_object 'Режим предмета: один объект, чистый фон, обход по кругу. После съёмки выполняется реконструкция в текстурированный USDZ. Не снимайте всю комнату в этом режиме.')"
make_still_clip "$WORK/slides/07_object.png" "$wav" "$WORK/clips/07_object.mp4"
printf "file '%s'\n" "$WORK/clips/07_object.mp4" >> "$concat_list"

fit_media_to_slide "$ROOT/Screenshots/View 3D Scan .PNG" "$WORK/slides/08_library.png"
wav="$(speak 08_library 'Мои трёхмерные сканы: превью, шаринг и удаление. Файлы лежат в приложении Файлы, папка Igor G LiDAR.')"
make_still_clip "$WORK/slides/08_library.png" "$wav" "$WORK/clips/08_library.mp4"
printf "file '%s'\n" "$WORK/clips/08_library.mp4" >> "$concat_list"

wav="$(speak 09_tips 'Для комнаты двигайтесь плавно. Для предмета выбирайте матовые поверхности и ровный свет. Подробная инструкция — в docs product USAGE.md и HTML-презентации.')"
make_still_clip "$WORK/slides/09_tips.png" "$wav" "$WORK/clips/09_tips.mp4"
printf "file '%s'\n" "$WORK/clips/09_tips.mp4" >> "$concat_list"

OUT_MP4="$OUT_DIR/igor-g-lidar-usage.mp4"
ffmpeg -y -hide_banner -loglevel error -f concat -safe 0 -i "$concat_list" \
  -c:v libx264 -preset medium -crf 23 -c:a aac -b:a 128k -movflags +faststart \
  "$OUT_MP4"

echo "Wrote $OUT_MP4"
ls -lh "$OUT_MP4"
ffprobe -v error -show_entries format=duration,size -of default=noprint_wrappers=1 "$OUT_MP4"

cp "$OUT_MP4" "$ARTIFACTS_DIR/igor-g-lidar-usage.mp4"
cp "$OUT_DIR/igor-g-lidar-guide.html" "$ARTIFACTS_DIR/igor-g-lidar-guide.html"
cp "$OUT_DIR/USAGE.md" "$ARTIFACTS_DIR/USAGE.md"
# Frame grabs for walkthrough
ffmpeg -y -hide_banner -loglevel error -ss 3 -i "$OUT_MP4" -frames:v 1 -update 1 "$ARTIFACTS_DIR/igor-g-lidar-frame-title.png"
ffmpeg -y -hide_banner -loglevel error -ss 45 -i "$OUT_MP4" -frames:v 1 -update 1 "$ARTIFACTS_DIR/igor-g-lidar-frame-room.png"
echo "Artifacts in $ARTIFACTS_DIR"
python3 -c "import os; print('SIZE_MB=', round(os.path.getsize('$OUT_MP4')/1024/1024, 1))"
