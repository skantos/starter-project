# Reporte de implementación

## Resumen
- Funcionalidad principal: publicación de artículos, favoritos por usuario autenticado, perfil y métricas.
- Backend: Firestore + Cloud Storage. Reglas aplicadas para `users/{uid}` y `users/{uid}/favorites`.
- Frontend: Flutter con arquitectura limpia; favoritos y métricas ligadas al `uid`.

## Decisiones clave
- Favoritos por usuario en `users/{uid}/favorites` para aislar datos privados y simplificar reglas.
- Ícono de favorito en detalle con toggle en tiempo real y guardado/eliminado según exista el doc.
- Conteo de favoritos con agregación `.count()` en Firestore.
- Mostrar nombre del autor desde `users/{authorId}.name`; al publicar, se guarda también `author` como nombre para robustez de UI.
- Eliminación de Floor/SQLite: toda la persistencia se realiza en Firestore.

## Esquema
- Ver `backend/docs/DB_SCHEMA.md`. Se usa `thumbnailURL` como referencia en Storage (carpeta `media/articles`).

## Reglas de seguridad
- Lectura pública de `users/{uid}` (solo nombre). Escritura restringida al dueño.
- Lectura/escritura de `favorites` restringida al dueño.

## Rutas de la app
- `/` (Home), `/ArticleDetails`, `/createArticle`, `/SavedArticles`, `/profile`, `/login`, `/register`.

## Pendientes/Futuro
- Endurecer reglas en `articles` para producción (create/update/delete solo autenticados).
- Opcional: badges de favorito en cards del feed.
- Limpieza de dependencias: si no se usará Retrofit, considerar removerlo del proyecto.
