#!/usr/bin/env python3
"""Genera los CSV del catalogo de REPUESTOS PRO en assets/data/.

Las tablas de referencia (marcas, modelos, motores, categorias) estan escritas
a mano con datos reales del mercado latinoamericano. Los productos se arman
combinando plantillas de repuesto con familias de vehiculos que comparten
piezas, que es como funciona un catalogo real.

Uso:
    python3 tool/generar_datos.py
"""

from __future__ import annotations

import csv
import json
import random
from pathlib import Path

SALIDA = Path(__file__).resolve().parent.parent / "assets" / "data"
SEMILLA = 20260911

# --------------------------------------------------------------- categorias

CATEGORIAS = [
    ("frenos", "Frenos", "Pastillas, discos, bandas, mordazas y liquido de frenos", "frenos", "#E03131", 1),
    ("direccion", "Direccion", "Terminales, cremalleras, rotulas y bombas hidraulicas", "direccion", "#4C6EF5", 2),
    ("suspension", "Suspension", "Amortiguadores, espirales, bujes, tijeras y bases", "suspension", "#7950F2", 3),
    ("motor", "Motor", "Filtros, correas, empaques, bombas, sensores y termostatos", "motor", "#FD7E14", 4),
    ("transmision", "Transmision", "Embragues, crucetas, homocineticas y rodamientos", "transmision", "#0CA678", 5),
    ("electrico", "Electrico", "Baterias, alternadores, bujias, arranques e iluminacion", "electrico", "#EAB308", 6),
    ("lubricantes", "Lubricantes", "Aceites sinteticos, refrigerantes, grasas y aditivos", "lubricantes", "#1098AD", 7),
]

# ----------------------------------------------------------- marcas de parte

MARCAS_PARTE = [
    ("bosch", "Bosch", "Alemania", "original"),
    ("brembo", "Brembo", "Italia", "original"),
    ("trw", "TRW", "Alemania", "original"),
    ("ate", "ATE", "Alemania", "original"),
    ("wagner", "Wagner", "Estados Unidos", "homologada"),
    ("acdelco", "ACDelco", "Estados Unidos", "original"),
    ("monroe", "Monroe", "Estados Unidos", "original"),
    ("kyb", "KYB", "Japon", "original"),
    ("sachs", "Sachs", "Alemania", "original"),
    ("moog", "Moog", "Estados Unidos", "homologada"),
    ("febi", "Febi Bilstein", "Alemania", "homologada"),
    ("skf", "SKF", "Suecia", "original"),
    ("zf", "ZF", "Alemania", "original"),
    ("gates", "Gates", "Estados Unidos", "original"),
    ("mann", "Mann-Filter", "Alemania", "original"),
    ("mahle", "Mahle", "Alemania", "original"),
    ("ngk", "NGK", "Japon", "original"),
    ("denso", "Denso", "Japon", "original"),
    ("valeo", "Valeo", "Francia", "original"),
    ("delphi", "Delphi", "Reino Unido", "homologada"),
    ("gmb", "GMB", "Japon", "homologada"),
    ("gsp", "GSP", "China", "alternativa"),
    ("philips", "Philips", "Paises Bajos", "original"),
    ("mobil", "Mobil 1", "Estados Unidos", "original"),
    ("castrol", "Castrol", "Reino Unido", "original"),
    ("shell", "Shell", "Paises Bajos", "original"),
    ("valvoline", "Valvoline", "Estados Unidos", "homologada"),
    ("liquimoly", "Liqui Moly", "Alemania", "original"),
]

# ------------------------------------------------- marcas, modelos y motores
# (marca_id, nombre, pais, [(modelo_id, nombre, carroceria, desde, hasta,
#   [(motor_id, codigo, nombre, cilindrada, combustible, hp, desde, hasta)])])

VEHICULOS = [
    ("chevrolet", "Chevrolet", "Estados Unidos", [
        ("cv-spark-gt", "Spark GT", "Hatchback", 2011, 2017, [
            ("cv-spark-gt-b12d1", "B12D1", "1.2 16V B12D1", 1.2, "Gasolina", 80, 2011, 2017),
        ]),
        ("cv-sail", "Sail", "Sedan", 2013, 2019, [
            ("cv-sail-l2b", "L2B", "1.4 16V L2B", 1.4, "Gasolina", 98, 2013, 2019),
        ]),
        ("cv-onix", "Onix", "Hatchback", 2017, 2024, [
            ("cv-onix-lde", "LDE", "1.4 16V LDE", 1.4, "Gasolina", 98, 2017, 2021),
            ("cv-onix-lih", "LIH", "1.0 Turbo LIH", 1.0, "Gasolina", 116, 2020, 2024),
        ]),
        ("cv-tracker", "Tracker", "SUV", 2020, 2025, [
            ("cv-tracker-lih", "LIH", "1.2 Turbo LIH", 1.2, "Gasolina", 132, 2020, 2025),
        ]),
        ("cv-captiva", "Captiva", "SUV", 2008, 2018, [
            ("cv-captiva-le9", "LE9", "2.4 16V LE9", 2.4, "Gasolina", 167, 2008, 2018),
        ]),
        ("cv-dmax", "Luv D-Max", "Pickup", 2006, 2013, [
            ("cv-dmax-4jj1", "4JJ1", "3.0 TDI 4JJ1", 3.0, "Diesel", 163, 2006, 2013),
            ("cv-dmax-c24se", "C24SE", "2.4 16V C24SE", 2.4, "Gasolina", 130, 2006, 2013),
        ]),
    ]),
    ("renault", "Renault", "Francia", [
        ("rn-logan", "Logan", "Sedan", 2014, 2020, [
            ("rn-logan-k4m", "K4M", "1.6 16V K4M", 1.6, "Gasolina", 105, 2014, 2020),
        ]),
        ("rn-sandero", "Sandero", "Hatchback", 2015, 2021, [
            ("rn-sandero-k4m", "K4M", "1.6 16V K4M", 1.6, "Gasolina", 105, 2015, 2019),
            ("rn-sandero-h4m", "H4M", "1.6 16V H4M", 1.6, "Gasolina", 115, 2019, 2021),
        ]),
        ("rn-stepway", "Stepway", "Hatchback", 2016, 2022, [
            ("rn-stepway-h4m", "H4M", "1.6 16V H4M", 1.6, "Gasolina", 115, 2016, 2022),
        ]),
        ("rn-duster", "Duster", "SUV", 2012, 2021, [
            ("rn-duster-k4m", "K4M", "1.6 16V K4M", 1.6, "Gasolina", 105, 2012, 2021),
            ("rn-duster-f4r", "F4R", "2.0 16V F4R", 2.0, "Gasolina", 138, 2012, 2021),
        ]),
        ("rn-kwid", "Kwid", "Hatchback", 2018, 2024, [
            ("rn-kwid-b4d", "B4D", "1.0 12V B4D", 1.0, "Gasolina", 66, 2018, 2024),
        ]),
    ]),
    ("hyundai", "Hyundai", "Corea del Sur", [
        ("hy-accent", "Accent", "Sedan", 2012, 2018, [
            ("hy-accent-g4lc", "G4LC", "1.4 16V G4LC", 1.4, "Gasolina", 100, 2012, 2018),
            ("hy-accent-g4fg", "G4FG", "1.6 16V G4FG", 1.6, "Gasolina", 123, 2012, 2018),
        ]),
        ("hy-i10", "i10", "Hatchback", 2014, 2020, [
            ("hy-i10-g4la", "G4LA", "1.2 16V G4LA", 1.2, "Gasolina", 87, 2014, 2020),
        ]),
        ("hy-elantra", "Elantra", "Sedan", 2017, 2023, [
            ("hy-elantra-g4fg", "G4FG", "1.6 16V G4FG", 1.6, "Gasolina", 128, 2017, 2023),
            ("hy-elantra-g4nb", "G4NB", "1.8 16V G4NB", 1.8, "Gasolina", 147, 2017, 2020),
        ]),
        ("hy-tucson", "Tucson", "SUV", 2016, 2022, [
            ("hy-tucson-g4na", "G4NA", "2.0 16V G4NA", 2.0, "Gasolina", 155, 2016, 2022),
            ("hy-tucson-d4ha", "D4HA", "2.0 CRDi D4HA", 2.0, "Diesel", 185, 2016, 2022),
        ]),
    ]),
    ("kia", "Kia", "Corea del Sur", [
        ("ki-rio", "Rio", "Sedan", 2012, 2017, [
            ("ki-rio-g4lc", "G4LC", "1.4 16V G4LC", 1.4, "Gasolina", 100, 2012, 2017),
        ]),
        ("ki-picanto", "Picanto", "Hatchback", 2012, 2020, [
            ("ki-picanto-g4la", "G4LA", "1.2 16V G4LA", 1.2, "Gasolina", 87, 2012, 2020),
        ]),
        ("ki-cerato", "Cerato", "Sedan", 2014, 2021, [
            ("ki-cerato-g4fg", "G4FG", "1.6 16V G4FG", 1.6, "Gasolina", 128, 2014, 2021),
        ]),
        ("ki-sportage", "Sportage", "SUV", 2016, 2022, [
            ("ki-sportage-g4na", "G4NA", "2.0 16V G4NA", 2.0, "Gasolina", 155, 2016, 2022),
            ("ki-sportage-d4ha", "D4HA", "2.0 CRDi D4HA", 2.0, "Diesel", 185, 2016, 2022),
        ]),
    ]),
    ("toyota", "Toyota", "Japon", [
        ("ty-corolla", "Corolla", "Sedan", 2014, 2019, [
            ("ty-corolla-2zr", "2ZR-FE", "1.8 16V 2ZR-FE", 1.8, "Gasolina", 140, 2014, 2019),
        ]),
        ("ty-yaris", "Yaris", "Sedan", 2018, 2023, [
            ("ty-yaris-2nr", "2NR-FE", "1.5 16V 2NR-FE", 1.5, "Gasolina", 107, 2018, 2023),
        ]),
        ("ty-hilux", "Hilux", "Pickup", 2016, 2023, [
            ("ty-hilux-2gd", "2GD-FTV", "2.4 TDI 2GD-FTV", 2.4, "Diesel", 150, 2016, 2023),
            ("ty-hilux-1gd", "1GD-FTV", "2.8 TDI 1GD-FTV", 2.8, "Diesel", 177, 2016, 2023),
        ]),
        ("ty-prado", "Prado", "SUV", 2010, 2020, [
            ("ty-prado-1gr", "1GR-FE", "4.0 V6 1GR-FE", 4.0, "Gasolina", 271, 2010, 2020),
        ]),
    ]),
    ("nissan", "Nissan", "Japon", [
        ("ni-versa", "Versa", "Sedan", 2015, 2020, [
            ("ni-versa-hr16", "HR16DE", "1.6 16V HR16DE", 1.6, "Gasolina", 118, 2015, 2020),
        ]),
        ("ni-march", "March", "Hatchback", 2014, 2021, [
            ("ni-march-hr16", "HR16DE", "1.6 16V HR16DE", 1.6, "Gasolina", 107, 2014, 2021),
        ]),
        ("ni-frontier", "Frontier", "Pickup", 2010, 2020, [
            ("ni-frontier-yd25", "YD25DDTi", "2.5 TDI YD25DDTi", 2.5, "Diesel", 190, 2010, 2020),
            ("ni-frontier-qr25", "QR25DE", "2.5 16V QR25DE", 2.5, "Gasolina", 152, 2010, 2020),
        ]),
        ("ni-qashqai", "Qashqai", "SUV", 2018, 2023, [
            ("ni-qashqai-mr20", "MR20DD", "2.0 16V MR20DD", 2.0, "Gasolina", 141, 2018, 2023),
        ]),
    ]),
    ("mazda", "Mazda", "Japon", [
        ("mz-3", "Mazda 3", "Sedan", 2015, 2019, [
            ("mz-3-pevps", "PE-VPS", "2.0 Skyactiv-G", 2.0, "Gasolina", 155, 2015, 2019),
        ]),
        ("mz-2", "Mazda 2", "Hatchback", 2016, 2021, [
            ("mz-2-p5vps", "P5-VPS", "1.5 Skyactiv-G", 1.5, "Gasolina", 113, 2016, 2021),
        ]),
        ("mz-cx5", "CX-5", "SUV", 2017, 2023, [
            ("mz-cx5-pyvps", "PY-VPS", "2.5 Skyactiv-G", 2.5, "Gasolina", 190, 2017, 2023),
        ]),
    ]),
    ("ford", "Ford", "Estados Unidos", [
        ("fo-fiesta", "Fiesta", "Hatchback", 2011, 2016, [
            ("fo-fiesta-duratec", "Duratec", "1.6 16V Duratec", 1.6, "Gasolina", 120, 2011, 2016),
        ]),
        ("fo-escape", "Escape", "SUV", 2013, 2019, [
            ("fo-escape-ecoboost", "EcoBoost", "2.0 EcoBoost", 2.0, "Gasolina", 240, 2013, 2019),
        ]),
        ("fo-ranger", "Ranger", "Pickup", 2016, 2022, [
            ("fo-ranger-puma32", "Puma", "3.2 TDCi Puma", 3.2, "Diesel", 200, 2016, 2022),
            ("fo-ranger-puma22", "Puma", "2.2 TDCi Puma", 2.2, "Diesel", 160, 2016, 2022),
        ]),
    ]),
    ("volkswagen", "Volkswagen", "Alemania", [
        ("vw-gol", "Gol", "Hatchback", 2013, 2018, [
            ("vw-gol-ea111", "EA111", "1.6 8V EA111", 1.6, "Gasolina", 101, 2013, 2018),
        ]),
        ("vw-polo", "Polo", "Hatchback", 2018, 2023, [
            ("vw-polo-ea211", "EA211", "1.6 16V EA211", 1.6, "Gasolina", 110, 2018, 2023),
        ]),
        ("vw-amarok", "Amarok", "Pickup", 2011, 2021, [
            ("vw-amarok-tdi", "CDCA", "2.0 TDI biturbo", 2.0, "Diesel", 180, 2011, 2021),
        ]),
    ]),
    ("suzuki", "Suzuki", "Japon", [
        ("su-swift", "Swift", "Hatchback", 2018, 2023, [
            ("su-swift-k12c", "K12C", "1.2 Dualjet K12C", 1.2, "Gasolina", 90, 2018, 2023),
        ]),
        ("su-vitara", "Vitara", "SUV", 2016, 2022, [
            ("su-vitara-m16a", "M16A", "1.6 16V M16A", 1.6, "Gasolina", 120, 2016, 2022),
        ]),
    ]),
]

# Familias de vehiculos que comparten repuestos. Es la logica que usa un
# almacen real: una misma pastilla sirve para Accent y Rio porque comparten
# plataforma.
FAMILIAS = [
    ("coreanos-b", "58101-1R", ["hy-accent", "ki-rio"]),
    ("coreanos-c", "58101-3X", ["hy-elantra", "ki-cerato"]),
    ("coreanos-suv", "58101-D3", ["hy-tucson", "ki-sportage"]),
    ("coreanos-city", "58302-B4", ["hy-i10", "ki-picanto"]),
    ("chevy-city", "95priority", ["cv-spark-gt", "cv-sail"]),
    ("chevy-nuevo", "42707", ["cv-onix", "cv-tracker"]),
    ("chevy-suv", "20911", ["cv-captiva"]),
    ("renault-b", "410605", ["rn-logan", "rn-sandero", "rn-stepway"]),
    ("renault-suv", "410601", ["rn-duster"]),
    ("renault-city", "410609", ["rn-kwid"]),
    ("toyota-sedan", "04465-02", ["ty-corolla", "ty-yaris"]),
    ("nissan-b", "D1060-1H", ["ni-versa", "ni-march"]),
    ("nissan-suv", "D1060-4E", ["ni-qashqai"]),
    ("mazda-sky", "BHY1-33-28", ["mz-3", "mz-2", "mz-cx5"]),
    ("ford-b", "1848120", ["fo-fiesta"]),
    ("ford-suv", "1857858", ["fo-escape"]),
    ("vw-b", "5U0698151", ["vw-gol", "vw-polo"]),
    ("suzuki", "55810-61M", ["su-swift", "su-vitara"]),
    ("pickups", "04465-0K", ["ty-hilux", "fo-ranger", "ni-frontier", "vw-amarok", "cv-dmax"]),
    ("todoterreno", "04465-60", ["ty-prado"]),
]

# ------------------------------------------------------- plantillas de parte
# (clave, nombre, categoria, [marcas], precio_min, precio_max, garantia,
#  sufijo_oem, descripcion, ficha_base, cobertura)
# `cobertura` indica a cuantas familias se le aplica la plantilla.

PLANTILLAS = [
    # -------------------------------------------------------------- frenos
    ("past-del", "Pastillas de freno delanteras", "frenos",
     ["brembo", "trw", "bosch", "acdelco"], 128000, 265000, 12, "A0",
     "Juego de 4 pastillas para el eje delantero, con material de baja "
     "pulverizacion y menor ruido de frenado.",
     {"Posicion": "Eje delantero", "Piezas": "4", "Sensor de desgaste": "Incluido"}, 16),
    ("past-tra", "Pastillas de freno traseras", "frenos",
     ["trw", "bosch", "ate"], 96000, 198000, 12, "A1",
     "Pastillas traseras con soporte de acero estampado y capa antirruido.",
     {"Posicion": "Eje trasero", "Piezas": "4"}, 11),
    ("disco-del", "Disco de freno delantero ventilado", "frenos",
     ["brembo", "trw", "ate", "bosch"], 165000, 385000, 12, "B0",
     "Disco ventilado con recubrimiento anticorrosivo y balanceo de alta "
     "precision para evitar vibracion en el pedal.",
     {"Tipo": "Ventilado", "Posicion": "Delantero"}, 14),
    ("bandas", "Bandas de freno traseras", "frenos",
     ["bosch", "trw", "acdelco"], 88000, 176000, 12, "C0",
     "Juego de bandas traseras libres de asbesto, con remachado reforzado "
     "para uso urbano intensivo.",
     {"Posicion": "Trasero", "Piezas": "4", "Material": "Sin asbesto"}, 9),
    ("cilindro", "Cilindro maestro de freno", "frenos",
     ["wagner", "ate", "trw"], 320000, 585000, 18, "D0",
     "Cilindro maestro con sellos de EPDM y cuerpo de aluminio. Incluye "
     "deposito y tapa con sensor de nivel.",
     {"Deposito": "Incluido", "Material": "Aluminio"}, 7),
    ("mordaza", "Mordaza de freno delantera", "frenos",
     ["acdelco", "trw", "brembo"], 420000, 720000, 12, "E0",
     "Mordaza remanufacturada con piston nuevo, guias y kit de sellos, "
     "lista para instalar.",
     {"Pistones": "1", "Incluye": "Guias, sellos y tornilleria"}, 6),

    # ----------------------------------------------------------- direccion
    ("terminal", "Terminal de direccion exterior", "direccion",
     ["trw", "febi", "moog"], 58000, 138000, 12, "F0",
     "Terminal con esfera de acero forjado y guardapolvo de poliuretano "
     "resistente a la humedad.",
     {"Material": "Acero forjado", "Incluye": "Tuerca y pasador"}, 15),
    ("rotula", "Rotula inferior de suspension", "direccion",
     ["febi", "moog", "trw"], 72000, 168000, 12, "G0",
     "Rotula con cuerpo de acero y buje de poliacetal autolubricado.",
     {"Incluye": "Tuerca y pasador"}, 13),
    ("cremallera", "Cremallera de direccion", "direccion",
     ["zf", "trw", "febi"], 1250000, 2350000, 24, "H0",
     "Cremallera remanufacturada bajo estandar de fabrica, probada en banco "
     "y con terminales nuevos incluidos.",
     {"Terminales": "Incluidos", "Prueba en banco": "Si"}, 8),
    ("bomba-dir", "Bomba de direccion hidraulica", "direccion",
     ["bosch", "zf", "valeo"], 680000, 1180000, 18, "I0",
     "Bomba de paletas con valvula de alivio calibrada de fabrica. Reduce el "
     "ruido en maniobras a baja velocidad.",
     {"Polea": "Incluida"}, 7),
    ("guardapolvo", "Guardapolvo de cremallera", "direccion",
     ["febi", "moog"], 18000, 48000, 6, "J0",
     "Fuelle de caucho EPDM con abrazaderas incluidas. Protege la cremallera "
     "del agua y el polvo.",
     {"Material": "EPDM", "Abrazaderas": "Incluidas"}, 8),

    # ---------------------------------------------------------- suspension
    ("amort-del", "Amortiguador delantero a gas", "suspension",
     ["monroe", "kyb", "sachs"], 185000, 420000, 24, "K0",
     "Amortiguador bitubo presurizado con valvula sensible a la carretera. "
     "Mejora el agarre y reduce el cabeceo al frenar.",
     {"Posicion": "Delantero", "Tipo": "Bitubo a gas"}, 17),
    ("amort-tra", "Amortiguador trasero a gas", "suspension",
     ["monroe", "kyb", "sachs"], 158000, 365000, 24, "L0",
     "Reemplazo equivalente al original. Recupera la altura y el confort de "
     "marcha de fabrica.",
     {"Posicion": "Trasero", "Tipo": "Bitubo a gas"}, 15),
    ("espiral", "Espiral delantero reforzado", "suspension",
     ["sachs", "kyb", "febi"], 128000, 285000, 12, "M0",
     "Resorte de acero al silicio con recubrimiento epoxico. Conserva la "
     "altura original aun con carga.",
     {"Posicion": "Delantero"}, 11),
    ("buje", "Buje de tijera delantera", "suspension",
     ["moog", "febi", "sachs"], 28000, 78000, 12, "N0",
     "Buje de caucho vulcanizado sobre camisa metalica. Elimina golpeteos en "
     "huecos y reductores.",
     {"Material": "Caucho y acero"}, 13),
    ("tijera", "Tijera inferior completa", "suspension",
     ["febi", "moog", "trw"], 265000, 525000, 18, "O0",
     "Brazo de control con rotula y bujes preinstalados. Reduce el tiempo de "
     "montaje a la mitad.",
     {"Rotula": "Preinstalada", "Bujes": "Preinstalados"}, 9),
    ("base-amort", "Base de amortiguador con rodamiento", "suspension",
     ["skf", "sachs", "febi"], 78000, 185000, 12, "P0",
     "Kit de base superior con rodamiento axial y tope de goma. Elimina el "
     "ruido al girar el volante.",
     {"Incluye": "Base, rodamiento y tope", "Piezas": "3"}, 11),

    # --------------------------------------------------------------- motor
    ("filtro-aceite", "Filtro de aceite de motor", "motor",
     ["mann", "bosch", "mahle", "denso"], 18000, 52000, 6, "Q0",
     "Filtro de flujo total con valvula antidrenaje. Mantiene presion de "
     "aceite estable en el arranque en frio.",
     {"Valvula antidrenaje": "Si"}, 18),
    ("filtro-aire", "Filtro de aire de motor", "motor",
     ["mann", "mahle", "bosch"], 32000, 92000, 6, "R0",
     "Medio filtrante plisado de alta superficie. Protege el sensor MAF y "
     "mantiene el consumo de combustible.",
     {"Forma": "Rectangular"}, 17),
    ("filtro-cabina", "Filtro de aire acondicionado", "motor",
     ["mann", "mahle", "bosch"], 28000, 78000, 6, "R1",
     "Filtro de habitaculo con carbon activado que retiene polen, polvo y "
     "olores del trafico.",
     {"Tipo": "Carbon activado"}, 14),
    ("correa-kit", "Kit de correa de reparticion con tensor", "motor",
     ["gates", "bosch", "skf"], 285000, 620000, 24, "S0",
     "Kit completo con correa HNBR, tensor y polea loca. Cambio recomendado "
     "cada 90.000 km.",
     {"Material": "HNBR", "Piezas": "3"}, 12),
    ("bomba-agua", "Bomba de agua con empaque", "motor",
     ["skf", "gmb", "gates"], 165000, 385000, 18, "T0",
     "Bomba con sello mecanico de carburo y rodamiento sellado de por vida. "
     "Incluye empaque metalico.",
     {"Empaque": "Incluido", "Material aspas": "Metal"}, 13),
    ("empaque-culata", "Empaque de culata multicapa MLS", "motor",
     ["mahle", "febi"], 118000, 285000, 12, "U0",
     "Empaque metalico de 3 capas con recubrimiento elastomerico. Soporta "
     "altas presiones de compresion.",
     {"Capas": "3", "Material": "Acero inoxidable"}, 9),
    ("sensor-o2", "Sensor de oxigeno banda 1", "motor",
     ["denso", "bosch", "delphi"], 210000, 465000, 12, "V0",
     "Sonda lambda calefactada con conector original. Corrige codigos P0130 "
     "a P0135 y normaliza el consumo.",
     {"Tipo": "Calefactado", "Conector": "Original"}, 11),
    ("termostato", "Termostato con carcasa", "motor",
     ["gates", "mahle", "febi"], 62000, 168000, 12, "W0",
     "Conjunto listo para instalar con empaque y sensor de temperatura.",
     {"Carcasa": "Incluida", "Empaque": "Incluido"}, 12),

    # --------------------------------------------------------- transmision
    ("embrague", "Kit de embrague 3 piezas", "transmision",
     ["valeo", "sachs", "zf"], 620000, 1450000, 24, "X0",
     "Disco, prensa y collarin de una sola marca. Pedal suave y agarre "
     "progresivo desde el primer kilometro.",
     {"Piezas": "3", "Collarin": "Incluido"}, 14),
    ("collarin", "Rodamiento de embrague (collarin)", "transmision",
     ["skf", "valeo", "sachs"], 92000, 215000, 12, "Y0",
     "Collarin sellado y lubricado de por vida. Reduce el ruido al pisar el "
     "pedal de embrague.",
     {"Lubricacion": "De por vida"}, 11),
    ("homocinetica", "Homocinetica lado rueda", "transmision",
     ["gsp", "skf", "febi"], 198000, 425000, 12, "Z0",
     "Junta homocinetica con guardapolvo y grasa de bisulfuro incluidos. "
     "Elimina el chasquido al girar.",
     {"Incluye": "Guardapolvo y grasa"}, 12),
    ("cruceta", "Cruceta de cardan", "transmision",
     ["gmb", "skf", "febi"], 48000, 128000, 12, "AA",
     "Cruceta con agujas de acero templado y graseras laterales para "
     "mantenimiento periodico.",
     {"Graseras": "Si"}, 6),

    # ----------------------------------------------------------- electrico
    ("bateria", "Bateria 12V libre de mantenimiento", "electrico",
     ["bosch", "acdelco"], 310000, 685000, 18, "AB",
     "Bateria libre de mantenimiento con rejilla de alta conductividad. "
     "Arranque confiable en clima frio y alta demanda electrica.",
     {"Voltaje": "12 V", "Mantenimiento": "Libre"}, 14),
    ("alternador", "Alternador con regulador integrado", "electrico",
     ["valeo", "bosch", "denso"], 820000, 1650000, 24, "AC",
     "Alternador con regulador integrado y polea de rueda libre. Probado en "
     "banco antes del despacho.",
     {"Voltaje": "12 V", "Polea": "Rueda libre"}, 12),
    ("bujias", "Bujias de iridio juego x4", "electrico",
     ["ngk", "denso", "bosch"], 98000, 268000, 12, "AD",
     "Electrodo central de iridio de 0,6 mm. Encendido mas estable y hasta "
     "100.000 km de vida util.",
     {"Cantidad": "4 unidades", "Electrodo": "Iridio"}, 15),
    ("arranque", "Motor de arranque", "electrico",
     ["denso", "bosch", "valeo"], 520000, 1150000, 24, "AE",
     "Arranque reductor con solenoide nuevo y bendix reforzado. Menor "
     "consumo de corriente al arrancar.",
     {"Voltaje": "12 V", "Rotacion": "Horaria"}, 10),
    ("bobina", "Bobina de encendido", "electrico",
     ["delphi", "bosch", "denso"], 88000, 235000, 12, "AF",
     "Bobina tipo lapiz con aislamiento epoxico. Corrige fallos de encendido "
     "y codigos P0300.",
     {"Tipo": "Lapiz", "Voltaje primario": "12 V"}, 13),
    ("bombillos", "Juego de bombillos halogenos", "electrico",
     ["philips", "bosch"], 52000, 148000, 6, "AG",
     "Par de bombillos con 30 % mas de luz que un halogeno estandar. Luz "
     "blanca calida homologada.",
     {"Cantidad": "2 unidades", "Voltaje": "12 V"}, 12),

    # --------------------------------------------------------- lubricantes
    ("aceite-sint", "Aceite sintetico 5W-30 API SP 4 L", "lubricantes",
     ["mobil", "castrol", "shell"], 148000, 265000, 0, "AH",
     "Aceite 100 % sintetico con proteccion contra LSPI. Intervalos de "
     "cambio de hasta 10.000 km.",
     {"Viscosidad": "5W-30", "Contenido": "4 L", "Base": "100 % sintetica"}, 5),
    ("aceite-semi", "Aceite semisintetico 10W-40 4 L", "lubricantes",
     ["castrol", "valvoline", "shell"], 92000, 168000, 0, "AI",
     "Tecnologia de doble accion que limpia los lodos existentes y evita que "
     "se vuelvan a formar.",
     {"Viscosidad": "10W-40", "Contenido": "4 L", "Base": "Semisintetica"}, 5),
    ("aceite-diesel", "Aceite diesel 15W-40 CK-4 5 L", "lubricantes",
     ["shell", "mobil", "valvoline"], 165000, 285000, 0, "AJ",
     "Formulado para motores diesel con filtro de particulas. Controla el "
     "hollin y protege los aros.",
     {"Viscosidad": "15W-40", "Contenido": "5 L", "Norma": "API CK-4"}, 4),
    ("refrigerante", "Refrigerante organico listo para usar 4 L", "lubricantes",
     ["valvoline", "shell", "liquimoly"], 48000, 98000, 0, "AK",
     "Refrigerante organico de larga duracion, listo para usar. Protege "
     "contra corrosion hasta 5 anos.",
     {"Tipo": "OAT", "Contenido": "4 L", "Dilucion": "Listo para usar"}, 4),
    ("aceite-caja", "Aceite de caja 75W-90 GL-5 1 L", "lubricantes",
     ["shell", "castrol", "liquimoly"], 42000, 92000, 0, "AL",
     "Lubricante de engranajes de presion extrema. Mejora el cambio de "
     "marchas en frio y reduce el ruido.",
     {"Viscosidad": "75W-90", "Norma": "API GL-5", "Contenido": "1 L"}, 4),
    ("aditivo", "Limpiador de inyectores 300 ml", "lubricantes",
     ["liquimoly", "valvoline", "castrol"], 32000, 78000, 0, "AM",
     "Aditivo que disuelve depositos en inyectores y valvulas. Se agrega al "
     "tanque cada 2.000 km.",
     {"Contenido": "300 ml", "Aplicacion": "Directo al tanque"}, 4),
]

PREFIJO_MARCA = {
    "bosch": "BOS", "brembo": "BRE", "trw": "TRW", "ate": "ATE",
    "wagner": "WAG", "acdelco": "ACD", "monroe": "MON", "kyb": "KYB",
    "sachs": "SAC", "moog": "MOG", "febi": "FEB", "skf": "SKF", "zf": "ZFG",
    "gates": "GAT", "mann": "MAN", "mahle": "MAH", "ngk": "NGK",
    "denso": "DEN", "valeo": "VAL", "delphi": "DEL", "gmb": "GMB",
    "gsp": "GSP", "philips": "PHI", "mobil": "MOB", "castrol": "CAS",
    "shell": "SHE", "valvoline": "VLV", "liquimoly": "LQM",
}


def escribir(nombre: str, encabezados: list[str], filas: list[list]) -> None:
    SALIDA.mkdir(parents=True, exist_ok=True)
    ruta = SALIDA / nombre
    with ruta.open("w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f, quoting=csv.QUOTE_MINIMAL)
        writer.writerow(encabezados)
        writer.writerows(filas)
    print(f"  {nombre:28} {len(filas):5} filas")


def ficha_a_texto(ficha: dict[str, str]) -> str:
    """Convierte la ficha tecnica al formato `clave=valor|clave=valor`.

    Se usa ese formato en vez de JSON porque es mucho mas comodo de escribir
    en una celda de Excel.
    """
    return "|".join(f"{k}={v}" for k, v in ficha.items())


def main() -> None:
    random.seed(SEMILLA)
    print("Generando el catalogo en assets/data/ ...")

    # ------------------------------------------------------ tablas simples
    escribir(
        "categorias.csv",
        ["id", "nombre", "descripcion", "icono", "color", "orden"],
        [list(c) for c in CATEGORIAS],
    )

    escribir(
        "marcas_repuesto.csv",
        ["id", "nombre", "pais", "tipo", "logo_url"],
        [[i, n, p, t, ""] for i, n, p, t in MARCAS_PARTE],
    )

    marcas_vehiculo = []
    modelos = []
    motores = []
    modelo_info: dict[str, tuple[str, int, int]] = {}
    motores_por_modelo: dict[str, list[tuple[str, int, int]]] = {}

    for marca_id, marca_nombre, pais, lista_modelos in VEHICULOS:
        marcas_vehiculo.append([marca_id, marca_nombre, pais])
        for mod_id, mod_nombre, carroceria, desde, hasta, lista_motores in lista_modelos:
            modelos.append([mod_id, marca_id, mod_nombre, carroceria, desde, hasta])
            modelo_info[mod_id] = (f"{marca_nombre} {mod_nombre}", desde, hasta)
            motores_por_modelo[mod_id] = []
            for mot_id, codigo, nombre, cc, comb, hp, m_desde, m_hasta in lista_motores:
                motores.append(
                    [mot_id, mod_id, codigo, nombre, cc, comb, hp, m_desde, m_hasta]
                )
                motores_por_modelo[mod_id].append((mot_id, m_desde, m_hasta))

    escribir("marcas_vehiculo.csv", ["id", "nombre", "pais"], marcas_vehiculo)
    escribir(
        "modelos.csv",
        ["id", "marca_id", "nombre", "carroceria", "ano_desde", "ano_hasta"],
        modelos,
    )
    escribir(
        "motores.csv",
        ["id", "modelo_id", "codigo", "nombre", "cilindrada", "combustible",
         "potencia_hp", "ano_desde", "ano_hasta"],
        motores,
    )

    # ---------------------------------------------------------- productos
    productos = []
    imagenes = []
    compatibilidades = []
    consecutivo = 0
    usados_sku: set[str] = set()

    for (clave, nombre_base, categoria, marcas, p_min, p_max, garantia,
         sufijo_oem, descripcion, ficha_base, cobertura) in PLANTILLAS:

        familias = random.sample(FAMILIAS, min(cobertura, len(FAMILIAS)))

        for fam_clave, oem_base, modelos_fam in familias:
            consecutivo += 1
            marca = random.choice(marcas)
            prefijo = PREFIJO_MARCA[marca]

            # El nombre incluye la aplicacion, igual que en un catalogo real.
            aplicacion = " / ".join(
                modelo_info[m][0] for m in modelos_fam[:2]
            )
            nombre = f"{nombre_base} {aplicacion}"

            sku = f"{prefijo}-{sufijo_oem}{consecutivo:04d}"
            if sku in usados_sku:
                continue
            usados_sku.add(sku)

            producto_id = f"p-{consecutivo:04d}"
            oem = f"{oem_base}{sufijo_oem}0"

            precio = round(random.uniform(p_min, p_max) / 1000) * 1000
            tiene_descuento = random.random() < 0.22
            precio_anterior = (
                round(precio * random.uniform(1.12, 1.3) / 1000) * 1000
                if tiene_descuento else ""
            )

            rueda = random.random()
            if rueda < 0.06:
                stock = 0
            elif rueda < 0.20:
                stock = random.randint(1, 5)
            else:
                stock = random.randint(6, 140)

            destacado = 1 if random.random() < 0.09 else 0
            calificacion = round(random.uniform(4.1, 4.9), 1)
            opiniones = random.randint(8, 320)

            ficha = dict(ficha_base)
            ficha["Aplicacion"] = aplicacion
            ficha["Referencia OEM"] = oem

            productos.append([
                producto_id, sku, oem, nombre, descripcion, categoria, marca,
                precio, precio_anterior, stock, garantia, calificacion,
                opiniones, destacado, ficha_a_texto(ficha),
            ])

            # Compatibilidad: una fila por modelo de la familia. Cuando el
            # repuesto depende del motor, se abre una fila por motor.
            depende_motor = categoria in ("motor", "transmision") or clave in (
                "bujias", "bobina", "alternador", "arranque",
            )
            for modelo_id in modelos_fam:
                _, desde, hasta = modelo_info[modelo_id]
                if depende_motor and motores_por_modelo[modelo_id]:
                    for mot_id, m_desde, m_hasta in motores_por_modelo[modelo_id]:
                        compatibilidades.append([
                            f"f-{len(compatibilidades) + 1:05d}", producto_id,
                            modelo_id, mot_id, m_desde, m_hasta,
                        ])
                else:
                    compatibilidades.append([
                        f"f-{len(compatibilidades) + 1:05d}", producto_id,
                        modelo_id, "", desde, hasta,
                    ])

    escribir(
        "productos.csv",
        ["id", "sku", "oem", "nombre", "descripcion", "categoria_id",
         "marca_repuesto_id", "precio", "precio_anterior", "stock",
         "garantia_meses", "calificacion", "numero_opiniones", "destacado",
         "ficha_tecnica"],
        productos,
    )

    escribir(
        "imagenes_productos.csv",
        ["id", "producto_id", "url", "orden", "principal"],
        imagenes,
    )

    escribir(
        "compatibilidades.csv",
        ["id", "producto_id", "modelo_id", "motor_id", "ano_desde", "ano_hasta"],
        compatibilidades,
    )

    resumen = {
        "categorias": len(CATEGORIAS),
        "marcas_repuesto": len(MARCAS_PARTE),
        "marcas_vehiculo": len(marcas_vehiculo),
        "modelos": len(modelos),
        "motores": len(motores),
        "productos": len(productos),
        "imagenes": len(imagenes),
        "compatibilidades": len(compatibilidades),
    }
    print("\nResumen:")
    print(json.dumps(resumen, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
