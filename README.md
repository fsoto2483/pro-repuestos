# REPUESTOS PRO

Catalogo profesional de repuestos automotrices hecho en Flutter con Material 3.
Corre en **Android**, **Web** y **Windows** desde el mismo codigo.

> **Fase 2 (actual): catalogo real sobre base de datos local.**
> Todavia no hay Firebase, ni Supabase, ni backend, ni IA. Los datos viven en
> una base SQLite dentro del dispositivo, que se llena desde archivos CSV o
> Excel.

---

## Que incluye

### Fase 1 — interfaz

| Area | Estado |
| --- | --- |
| Login con Google (simulado) y con correo/contrasena | Listo |
| Registro de cuenta nueva (simulado) | Listo |
| Catalogo con busqueda rapida por nombre, marca, SKU y OEM | Listo |
| 7 categorias visuales con pantalla propia | Listo |
| Ficha de producto con ficha tecnica y compatibilidad | Listo |
| Cotizacion (carrito) con cantidades, IVA y total | Listo |
| Favoritos y perfil de usuario | Listo |
| Bottom Navigation Bar en movil y barra lateral en pantallas grandes | Listo |

### Fase 2 — datos

| Area | Estado |
| --- | --- |
| Base de datos local SQLite (drift) en Android, Web y Windows | Listo |
| 8 tablas relacionadas con llaves foraneas activas | Listo |
| 441 productos reales con SKU, OEM, precio, stock y ficha tecnica | Listo |
| Filtros en cascada Marca -> Modelo -> Motor -> Ano -> Categoria | Listo |
| Carga masiva desde CSV o Excel, con reporte de errores por fila | Listo |
| Imagenes de producto por URL, con portada generada de respaldo | Listo |

---

## Como ejecutarlo

Necesitas Flutter 3.35 o superior. Verifica con `flutter --version`.

```bash
# 1. Instalar las dependencias
flutter pub get

# 2. Ver los dispositivos disponibles
flutter devices
```

### En el navegador (lo mas rapido para revisar)

```bash
flutter run -d chrome
```

Si no tienes Chrome instalado, usa un servidor local y abre la URL que imprime:

```bash
flutter run -d web-server --web-port=43127
```

### En Android

Conecta el telefono con depuracion USB activada, o abre un emulador, y ejecuta:

```bash
flutter run -d android
```

### En Windows

```bash
flutter run -d windows
```

---

## Cuenta de prueba

La pantalla de login tiene una tarjeta con el boton **Usar** que llena estos
datos automaticamente:

- Correo: `demo@repuestospro.com`
- Contrasena: `repuestos123`

El boton **Continuar con Google** entra directo, sin pedir nada: en esta fase
esta simulado.

---

## La base de datos

Ocho tablas, relacionadas entre si. Las flechas indican a quien apunta cada una:

```
categorias ──┐
             ├──> productos ──┬──> imagenes_productos
marcas_      │                │
repuesto ────┘                └──> compatibilidades <──┐
                                        │              │
marcas_vehiculo ──> modelos ──> motores ┘              │
                       └───────────────────────────────┘
```

- **categorias**: Frenos, Direccion, Suspension, Motor, Transmision,
  Electrico, Lubricantes.
- **marcas_repuesto**: quien fabrica la pieza (Bosch, Brembo, Monroe...). Es la
  marca que se ve en la tarjeta del producto.
- **marcas_vehiculo**: la marca del carro (Chevrolet, Renault, Hyundai...). Es
  la que encabeza el filtro en cascada.
- **modelos** y **motores**: cada modelo pertenece a una marca de vehiculo, y
  cada motor a un modelo, con su rango de anos.
- **productos**: SKU, OEM, precio, stock, garantia y ficha tecnica.
- **imagenes_productos**: las fotos de cada producto, por URL.
- **compatibilidades**: que producto sirve para que modelo, opcionalmente
  acotado a un motor y a un rango de anos. Es la tabla que hace posible el
  filtro por vehiculo.

Las llaves foraneas estan activas (`PRAGMA foreign_keys = ON`), asi que no
puede quedar un producto sin categoria ni una compatibilidad apuntando a un
modelo que ya no existe.

La primera vez que se abre la aplicacion, la base se llena sola con los
archivos de `assets/data/`. Despues manda lo que haya cargado el usuario.

---

## Carga masiva

**Perfil -> Catalogo -> Carga masiva.**

Acepta archivos `.csv`, `.xlsx` y `.xls`. La tabla de destino se deduce del
nombre del archivo o de la hoja de Excel: `productos.csv`, `productos.xlsx` o
una hoja llamada `productos` entran todas a la misma tabla.

Reglas:

- Se pueden cargar solo las tablas que cambiaron. Las que no vengan en el
  archivo conservan lo que ya estaba.
- Una fila a la que le falte un dato obligatorio se descarta y se reporta con
  su numero de fila, tal como se ve en Excel.
- Una fila que apunte a un registro que no existe tambien se descarta, junto
  con todo lo que dependa de ella.
- Si a un archivo le faltan columnas obligatorias, no se guarda nada: la base
  queda como estaba.
- Los precios se entienden con separador de miles y con simbolo: `189000`,
  `189.000` y `$ 189.000` son el mismo valor.
- La ficha tecnica se escribe como `clave=valor|clave=valor`, para poder
  editarla comodamente en Excel.

Las columnas que espera cada archivo estan listadas dentro de la misma
pantalla, en la seccion **Formato de los archivos**.

Para volver al catalogo de ejemplo, el boton **Restaurar el catalogo de
ejemplo** recarga los archivos que trae la aplicacion.

---

## Verificar que todo esta bien

```bash
flutter analyze   # no debe reportar ningun problema
flutter test      # 26 pruebas, todas deben pasar
```

Las pruebas incluyen la carga de los 441 productos reales, la cascada de
filtros y los casos de archivo mal formado.

---

## Como esta organizado el codigo

```
lib/
├── main.dart                  Punto de entrada
├── app.dart                   MaterialApp, providers y decision login/catalogo
│
├── core/
│   ├── theme/                 Colores de marca, tema Material 3 e iconos
│   └── utils/                 Formato de precios y reglas responsive
│
├── data/
│   ├── db/                    Tablas drift, consultas SQL y conexion
│   ├── import/                Lectura de CSV/Excel, validacion y siembra
│   ├── models/                Product, PartCategory, vehiculos, filtros
│   └── repositories/          Unico lugar que sabe de donde salen los datos
│
├── state/                     Controladores con ChangeNotifier + provider
│   ├── auth_controller.dart
│   ├── catalog_controller.dart
│   └── cart_controller.dart
│
├── features/                  Una carpeta por pantalla
│   ├── auth/                  Login y registro
│   ├── shell/                 Navegacion principal (bottom bar / rail)
│   ├── catalog/               Pantalla principal, tarjetas, filtros
│   ├── categories/            Cuadricula de categorias y su detalle
│   ├── product/               Ficha del repuesto
│   ├── cart/                  Cotizacion
│   ├── import/                Carga masiva desde archivo
│   └── profile/               Perfil, favoritos y cierre de sesion
│
└── widgets/                   Componentes compartidos (logo, portadas, vacios)

assets/data/                   Los CSV del catalogo inicial
tool/generar_datos.py          Script que genera esos CSV
```

La regla importante: **las pantallas nunca consultan la base directamente.**
Siempre pasan por `CatalogRepository`. Por eso, cuando llegue el backend, solo
cambia el cuerpo del repositorio.

---

## Sobre las imagenes de los productos

La tabla `imagenes_productos` y su archivo CSV ya funcionan, pero vienen
vacios a proposito: mezclar unas pocas fotos de banco con portadas generadas se
ve inconsistente. Mientras no haya foto, cada producto dibuja su portada con el
degradado y el icono de su categoria (`lib/widgets/product_cover.dart`).

Para activar las fotos reales basta con llenar `imagenes_productos.csv` con las
URLs y cargarlo desde la pantalla de carga masiva. No hay que tocar codigo.

---

## Diseno

- **Tipografia:** Manrope (incluida en `assets/fonts/`, licencia SIL OFL).
- **Color de marca:** naranja industrial `#FF5A1F` sobre grafito `#0D1117`.
- **Material 3** con tema claro y oscuro definidos en `lib/core/theme/`.
- **Responsive:** barra inferior por debajo de 720 px de ancho, barra lateral
  por encima; la grilla usa entre 2 y 5 columnas segun el espacio disponible.

---

## Notas tecnicas de la Fase 2

- La base usa **drift 2.35** con `drift_flutter`. En Web se necesitan
  `web/sqlite3.wasm` y `web/drift_worker.js`, que ya estan en el repositorio.
- Si cambias las tablas de `lib/data/db/tables.dart`, hay que regenerar el
  codigo: `dart run build_runner build`.
- Para regenerar los CSV de ejemplo: `python3 tool/generar_datos.py`.

---

## Siguientes fases (todavia no implementadas)

1. Autenticacion real (Firebase Auth o Supabase Auth).
2. Sincronizacion del catalogo contra un servidor.
3. Pedidos, historial y panel de administracion.
