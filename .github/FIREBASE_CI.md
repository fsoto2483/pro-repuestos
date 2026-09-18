# Secretos requeridos para CI/CD de Firebase Hosting
#
# En GitHub → Settings → Secrets and variables → Actions, crea:
#
#   FIREBASE_SERVICE_ACCOUNT
#     JSON completo de una cuenta de servicio de Google Cloud / Firebase.
#
# Cómo obtenerlo:
#   1. Firebase Console → Project settings (engranaje) → Service accounts
#   2. "Generate new private key" → descarga el .json
#   3. Copia TODO el contenido del JSON y pégalo como valor del secret
#
# Roles recomendados en la cuenta de servicio:
#   - Firebase Hosting Admin
#   - Service Account User (si el deploy lo pide)
#
# Proyecto Firebase: repuestospro-prod
# Hosting public dir: build/web (ver firebase.json)
# Repo: fsoto2483/pro-repuestos
#
# Flujos:
#   - push a main    → .github/workflows/firebase-hosting.yml → canal live
#   - push a develop → .github/workflows/firebase-hosting-develop.yml → canal develop
#
# Alternativa (CLI local / token CI, NO usado por estos workflows):
#   npx firebase-tools login:ci
#   → imprime un token; se usaría como secret FIREBASE_TOKEN con
#     `firebase deploy --only hosting --token "$FIREBASE_TOKEN"`
