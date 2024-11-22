@echo off
setlocal EnableDelayedExpansion

title BatchStore

:: Устанавливаем пути для плагинов, профилей, загрузок и репозитория
set "plugins_dir=plugins"
set "profile_dir=profile"
set "download_dir=download"
set "repo_url=https://github.com/Distendo/BatchStore.git"
set "repo_dir=BatchStore"
set "time_file=last_time.txt"

:: Проверяем, установлен ли Git
git --version >nul 2>&1
if errorlevel 1 (
    echo Git не установлен! Установите Git для работы с этим приложением.
    pause
    exit
)

:: Создаем директории для плагинов, профилей и загрузок, если они не существуют
if not exist %plugins_dir% mkdir %plugins_dir%
if not exist %profile_dir% mkdir %profile_dir%
if not exist %download_dir% mkdir %download_dir%

:: Проверяем, существует ли файл username.txt. Если нет, запрашиваем имя пользователя
if not exist username.txt (
    set /p "username=Введите ваше имя: "
    echo %username% > username.txt
) else (
    set /p "username=<username.txt"
)

:: Устанавливаем путь к файлу профиля
set "profile_file=%profile_dir%\%username%.txt"

:: Если файл профиля не существует, создаем новый
if not exist %profile_file% (
    echo Имя: %username% > %profile_file%
    echo Роль: новичок >> %profile_file%
    echo Время: 0 д >> %profile_file%
    echo Баланс: 100 BatchCoin >> %profile_file%
    echo История: >> %profile_file%
)

:: Выполняем плагины, если они есть
for %%P in (%plugins_dir%\*.bat) do (
    call %%P
)

:: Проверяем, существует ли репозиторий. Если нет, клонируем его, иначе обновляем
if not exist %repo_dir% (
    echo Клонируем репозиторий...
    git clone %repo_url% %repo_dir%
) else (
    echo Обновляем репозиторий...
    cd %repo_dir%
    git pull
    cd ..
)

:menu
cls
echo ==========================================
echo             BatchStore
echo ==========================================
echo Привет, %username%!
echo Роль: Новичок
echo Баланс: 100 BatchCoin
echo ==========================================
echo Команды:
echo - profile  : Посмотреть профиль
echo - view     : Посмотреть доступные файлы
echo - buy      : Купить файл
echo - earn     : Заработать BatchCoin
echo - trade    : Передать BatchCoin другому пользователю
echo - history  : Просмотреть историю действий
echo - plugins  : Просмотреть доступные плагины
echo - download : Загрузить программу
echo - exit     : Выйти
echo ==========================================
set /p "command=Введите команду: "

:: Обрабатываем введенные команды
if /i "%command%"=="profile" goto view_profile
if /i "%command%"=="view" goto view_files
if /i "%command%"=="buy" goto buy_file
if /i "%command%"=="earn" goto earn_coins
if /i "%command%"=="trade" goto trade_coins
if /i "%command%"=="history" goto view_history
if /i "%command%"=="plugins" goto view_plugins
if /i "%command%"=="download" goto download_program
if /i "%command%"=="exit" exit
goto menu

:view_profile
cls
echo ------------------------------------------
echo               Ваш профиль
echo ------------------------------------------
type %profile_file%
echo ------------------------------------------
pause
goto menu

:view_files
cls
echo Доступные файлы:
for %%A in (%repo_dir%\*.bat) do (
    set "filename=%%~nxA"
    echo - !filename!
)
pause
goto menu

:buy_file
cls
set /p "file_choice=Введите имя файла для покупки: "
set "price=50"
if not exist "%repo_dir%\%file_choice%" (
    echo Файл не найден!
    pause
    goto menu
)

set /a balance=100
if %balance% lss %price% (
    echo У вас недостаточно средств!
    pause
    goto menu
)

set /a balance-=price
echo Копируем файл...
copy "%repo_dir%\%file_choice%" "%file_choice%"
echo Файл %file_choice% успешно куплен.
pause
goto menu

:earn_coins
cls
set /a bonus=10 + %random%%%20
set /a balance+=bonus
echo Вы заработали %bonus% BatchCoin!
pause
goto menu

:trade_coins
cls
set /p "receiver=Введите имя получателя: "
set /p "amount=Введите количество BatchCoin для перевода: "
if %balance% lss %amount% (
    echo У вас недостаточно средств для перевода!
    pause
    goto menu
)
set /a balance-=amount
echo Перевод %amount% BatchCoin пользователю %receiver% завершен!
pause
goto menu

:view_history
cls
echo ------------------------------------------
echo               История действий
echo ------------------------------------------
type %profile_file%
echo ------------------------------------------
pause
goto menu

:view_plugins
cls
echo Доступные плагины:
for %%P in (%plugins_dir%\*.bat) do (
    set "plugin_name=%%~nxP"
    echo - !plugin_name!
)
pause
goto menu

:download_program
cls
echo Доступные программы для загрузки:
for %%P in (%download_dir%\*.bat) do (
    set "program_name=%%~nxP"
    echo - !program_name!
)
set /p "download_choice=Введите имя программы для загрузки: "
if not exist "%download_dir%\%download_choice%" (
    echo Программа не найдена!
    pause
    goto menu
)

echo Загрузка программы %download_choice%...
copy "%download_dir%\%download_choice%" "%download_choice%"
pause
goto menu
