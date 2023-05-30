# JustChats

Я написал это приложение для изучения Firebase и MessageKit. 
Это общий чат в которм пользователи могут общаться после регистрации.

### Я использовал:
- MVC, Delegate и Singleton паттерны
- Базу данных Firebase Cloud Firestore
- MessageKit для экрана с чатом

## Примеры работы приложения

Неправильный пароль | Проверка полей UITextfield | Информация о правилах пароля
:---: | :---: | :---:
<img src="https://github.com/dudkaDev/JustChats/blob/main/Gifs/wrongPassword.gif" width="250"> | <img src="https://github.com/dudkaDev/JustChats/blob/main/Gifs/checkTextfields.gif" width="250"> | <img src="https://github.com/dudkaDev/JustChats/blob/main/Gifs/passwordInfo.gif" width="250"> |
Восстановление пароля | Отправка и прием сообщений
<img src="https://github.com/dudkaDev/JustChats/blob/main/Gifs/resetPassword.gif" width="250"> | <img src="https://github.com/dudkaDev/JustChats/blob/main/Gifs/receivingNewMessages.gif" width="250"> |

## Экраны

Стартовый экран | Вход | Регистрация | Чат | Настройка профиля
:---: | :---: | :---: | :---: | :---:
<img src="https://github.com/dudkaDev/JustChats/blob/main/Images/starting.png" width="150"> | <img src="https://github.com/dudkaDev/JustChats/blob/main/Images/logIn.png" width="150"> | <img src="https://github.com/dudkaDev/JustChats/blob/main/Images/signUp.png" width="150"> | <img src="https://github.com/dudkaDev/JustChats/blob/main/Images/chat.png" width="150"> | <img src="https://github.com/dudkaDev/JustChats/blob/main/Images/setupProfile.png" width="150"> 

### Чтобы протестировать приложение нужно
1. Клонировать это приложение в Xcode
2. Cоздать новый проект в [FirebaseConsole](https://console.firebase.google.com/u/0/)
3. Скачать `GoogleService-Info.plist`
4. Добавить `GoogleService-Info.plist` в проект Xcode
