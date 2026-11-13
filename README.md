# MogliVisuals Recode — официальный сайт

Сайт проекта **MogliVisuals Recode**: чёрно-белые визуалы для Minecraft 1.21.11.

- **Файлы:** `index.html`, `assets/`, `MogliVisualsrecode.zip`, `update.json`
- **Хостинг:** GitHub Pages (автоматический деплой через GitHub Actions при пуше в `main`)
- **Автообновление лаунчера:** `update.json` в корне сайта — лаунчер читает его при каждом запуске

## Структура

```
/
├── index.html                 # лендинг
├── assets/                    # логотип, фон, скриншоты
├── MogliVisualsrecode.zip     # релиз лаунчера (exe + ui/)
├── update.json                # манифест автообновления (version, sha1, url, size)
└── .github/workflows/pages.yml
```

## Как обновить релиз

1. Соберите лаунчер: `cmake --build ../MogliVisualsLauncher/build --config Release`
2. Упакуйте: `tar -a -c -f MogliVisualsrecode.zip MogliVisuals.exe -C ../MogliVisualsLauncher/build/Release MogliVisuals.exe ui/` — проще всего собрать из папки `MogliVisualsLauncher/build/Release`:
   `tar -a -c -f ../site/MogliVisualsrecode.zip MogliVisuals.exe ui`
3. Вычислите SHA-1: `sha1sum MogliVisualsrecode.zip` (или `Get-FileHash -Algorithm SHA1`)
4. Обновите `update.json` (поля `version`, `url`, `sha1`, `size`, `changelog`)
5. `git add -A && git commit -m "Release vX.Y.Z" && git push`
6. GitHub Actions сам задеплоит сайт; лаунчеры пользователей обновятся при следующем запуске.
