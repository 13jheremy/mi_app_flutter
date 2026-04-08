# Configuración de Keystore para Android
# Este archivo contiene la configuración para firmar la app en producción

# Ubicación del keystore
KEYSTORE_PATH=/path/to/your/keystore.jks

# Alias de la clave
KEY_ALIAS=your_key_alias

# Contraseña del keystore
KEYSTORE_PASSWORD=your_keystore_password

# Contraseña de la clave
KEY_PASSWORD=your_key_password

# Configuración en build.gradle.kts:
#
# android {
#     signingConfigs {
#         create("release") {
#             storeFile = file(System.getenv("KEYSTORE_PATH") ?: "keystore.jks")
#             storePassword = System.getenv("KEYSTORE_PASSWORD")
#             keyAlias = System.getenv("KEY_ALIAS")
#             keyPassword = System.getenv("KEY_PASSWORD")
#         }
#     }
#
#     buildTypes {
#         release {
#             signingConfig = signingConfigs.getByName("release")
#             ...
#         }
#     }
# }

# Para CI/CD, configurar estas variables de entorno:
# KEYSTORE_PATH, KEYSTORE_PASSWORD, KEY_ALIAS, KEY_PASSWORD