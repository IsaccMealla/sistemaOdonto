-- Crear tablas de permisos si no existen

CREATE TABLE IF NOT EXISTS `rol_permiso` (
  `id` varchar(36) NOT NULL,
  `rol_id` varchar(36) NOT NULL,
  `permiso_id` varchar(36) NOT NULL,
  `otorgado_por_id` varchar(36) DEFAULT NULL,
  `fecha_asignacion` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `rol_permiso_rol_id_permiso_id_2b3ac8c3_uniq` (`rol_id`,`permiso_id`),
  KEY `rol_permiso_permiso_id_4c54f1f9_fk_permisos_id` (`permiso_id`),
  KEY `rol_permiso_otorgado_por_id_0db3c3b9_fk_usuarios_id` (`otorgado_por_id`),
  CONSTRAINT `rol_permiso_otorgado_por_id_0db3c3b9_fk_usuarios_id` FOREIGN KEY (`otorgado_por_id`) REFERENCES `usuarios` (`id`),
  CONSTRAINT `rol_permiso_permiso_id_4c54f1f9_fk_permisos_id` FOREIGN KEY (`permiso_id`) REFERENCES `permisos` (`id`),
  CONSTRAINT `rol_permiso_rol_id_a6bcf40f_fk_roles_id` FOREIGN KEY (`rol_id`) REFERENCES `roles` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `usuario_permiso` (
  `id` varchar(36) NOT NULL,
  `usuario_id` varchar(36) NOT NULL,
  `permiso_id` varchar(36) NOT NULL,
  `tipo` varchar(10) NOT NULL,
  `otorgado_por_id` varchar(36) DEFAULT NULL,
  `fecha_asignacion` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `usuario_permiso_usuario_id_permiso_id_0fa1e71a_uniq` (`usuario_id`,`permiso_id`),
  KEY `usuario_permiso_permiso_id_e6e93086_fk_permisos_id` (`permiso_id`),
  KEY `usuario_permiso_otorgado_por_id_3961c9b6_fk_usuarios_id` (`otorgado_por_id`),
  CONSTRAINT `usuario_permiso_otorgado_por_id_3961c9b6_fk_usuarios_id` FOREIGN KEY (`otorgado_por_id`) REFERENCES `usuarios` (`id`),
  CONSTRAINT `usuario_permiso_permiso_id_e6e93086_fk_permisos_id` FOREIGN KEY (`permiso_id`) REFERENCES `permisos` (`id`),
  CONSTRAINT `usuario_permiso_usuario_id_4e9cc02f_fk_usuarios_id` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
