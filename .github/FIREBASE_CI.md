# Secretos requeridos para CI/CD de Firebase Hosting
#
# En GitHub → Settings → Secrets and variables → Actions, crea:
#
#   FIREBASE_SERVICE_ACCOUNT
#     JSON de una cuenta de servicio de Google Cloud / Firebase con roles:
#       - Firebase Hosting Admin
#       - Cloud Functions Viewer (si el action lo pide)
#       - Service Account User (a veces requerido)
#
# Cómo generar el JSON:
#   1. Firebase Console → Project settings → Service accounts
#   2. "Generate new private key"
#   3. Pega el contenido completo del JSON como valor del secret
#
# Proyecto Firebase: repuestospro-prod
# Hosting public dir: build/web (ver firebase.json)
#
# Flujos:
#   - push a main    → canal live (producción)
#   - push a develop → canal develop (pruebas)
