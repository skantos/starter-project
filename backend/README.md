# Firebase Firestore Backend
In this folder are all the [Firebase Firestore](https://firebase.google.com/docs/firestore) related files. 
You will use this folder to add the schema of the *Articles* you want to upload for the app and to add the rules that enforce this schema. 

## DB Schema
El esquema detallado está en `backend/docs/DB_SCHEMA.md`. Resumen rápido de colecciones usadas por la app:

- `articles/{articleId}`
  - Campos: `title`, `description`, `content`, `author`, `authorId`, `thumbnailURL` (ruta en Storage: `media/articles/{articleId}.jpg`), `publishedAt`, `createdAt`, `updatedAt`, `status` en `[draft|published]`, `tags: string[]`.

- `users/{userId}`
  - Perfil mínimo: `name`, `email`, `createdAt`.
  - Subcolección: `favorites/{articleId}` (docs con snapshot del artículo favorito del usuario, incluye `title`, `url`, `urlToImage|thumbnailURL`, `category`, etc.).

Notas:
- Las imágenes se suben a Cloud Storage bajo `media/articles/{articleId}.jpg` y se guarda la referencia en `thumbnailURL`.
- La app calcula conteos de favoritos por usuario con agregación `.count()` en `users/{uid}/favorites`.

## Getting Started
Before starting to work on the backend, you must have a Firebase project with the [Firebase Firestore](https://firebase.google.com/docs/firestore), [Firebase Cloud Storage](https://firebase.google.com/docs/storage) and [Firebase Local Emulator Suite](https://firebase.google.com/docs/emulator-suite) technologies enabled.
To do this, create a project but enable only Firebase Cloud Storage, Firebase Firestore, and Firebase Local Emulator Suite technologies.


## Deploying the Project
In order to deploy the Firestore rules from this repository to the [Firebase console](https://firebase.google.com/)  of your project, follow these steps:

### 1. Install firebase CLI
```
npm install -g firebase-tools
```
### 2. Login to your account
```
firebase login
```

### 3. Add your project id to the .firebasesrc file 
This corresponds to the project Id of the firebase project you created in the Firebase web-app.
[Change project id](.firebaserc)

### 4. Initialize the project
```
firebase init
```

You should leave everything as it is, choose:
- emulators
- firestore
- cloud storage

### 5. Deploy to firebase
```
firebase deploy
```
This will deploy all the rules you write in `firestore.rules` to your Firebase Firestore project.
Be careful becasuse it will overwrite the existing firestore.rules file of your project.

### Reglas usadas por el frontend actual (resumen)
```
match /articles/{articleId} {
  allow read, write: if true; // Desarrollo (ajustar a producción si aplica)
}

match /users/{userId} {
  allow read: if true; // lectura pública de nombre
  allow write: if request.auth != null && request.auth.uid == userId;
}

match /users/{userId}/favorites/{favoriteId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```

## Running the project in a local emulator
To run the application locally, use the following command:

```firebase emulators:start```
