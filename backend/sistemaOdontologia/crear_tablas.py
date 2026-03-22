import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'sistemaOdontologia.settings')
django.setup()

from django.db import connection

# SQL para crear las tablas
sql_create_tables = """
DROP TABLE IF EXISTS `rol_permiso`;
CREATE TABLE `rol_permiso` (
  `id` varchar(36) COLLATE utf8mb4_general_ci NOT NULL,
  `rol_id` varchar(36) COLLATE utf8mb4_general_ci NOT NULL,
  `permiso_id` varchar(36) COLLATE utf8mb4_general_ci NOT NULL,
  `otorgado_por_id` varchar(36) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `fecha_asignacion` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `rol_permiso_uniq` (`rol_id`,`permiso_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

DROP TABLE IF EXISTS `usuario_permiso`;
CREATE TABLE `usuario_permiso` (
  `id` varchar(36) COLLATE utf8mb4_general_ci NOT NULL,
  `usuario_id` varchar(36) COLLATE utf8mb4_general_ci NOT NULL,
  `permiso_id` varchar(36) COLLATE utf8mb4_general_ci NOT NULL,
  `tipo` varchar(10) COLLATE utf8mb4_general_ci NOT NULL,
  `otorgado_por_id` varchar(36) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `fecha_asignacion` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `usuario_permiso_uniq` (`usuario_id`,`permiso_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
"""

# Ejecutar SQL
with connection.cursor() as cursor:
    # Separar por statement
    statements = [s.strip() for s in sql_create_tables.split(';') if s.strip()]
    for statement in statements:
        print(f"Ejecutando: {statement[:50]}...")
        cursor.execute(statement)

print("\n✅ Tablas creadas exitosamente!")
