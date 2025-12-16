-- ===============================
-- SCRIPT SQL PARA SUNAT PERÚ
-- ===============================
-- Ejecuta este script para verificar que las tablas existan
-- Si no existen, las crea automáticamente

-- ===============================
-- TABLA: comprobante_sunat
-- ===============================
-- Almacena boletas y facturas generadas

CREATE TABLE IF NOT EXISTS `comprobante_sunat` (
  `id_comprobante` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `id_venta` int(11) NOT NULL,
  `tipo` varchar(20) NOT NULL COMMENT 'BOLETA o FACTURA',
  `serie` varchar(10) NOT NULL,
  `numero_secuencial` int(11) NOT NULL,
  `xml_generado` longtext NOT NULL COMMENT 'Contenido XML completo',
  `estado` varchar(50) NOT NULL DEFAULT 'GENERADO' COMMENT 'GENERADO, ACEPTADO, RECHAZADO, ERROR, PENDIENTE',
  `respuesta_sunat` longtext COMMENT 'JSON con respuesta de SUNAT',
  `fecha_generacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_envio` timestamp NULL,
  `intentos_envio` int(11) DEFAULT 0,
  `ruc_cliente` varchar(11),
  `dni_cliente` varchar(8),
  `cliente_nombre` varchar(255),
  `total` decimal(10, 2),
  FOREIGN KEY (`id_venta`) REFERENCES `venta` (`id_venta`) ON DELETE CASCADE,
  UNIQUE KEY `unique_comprobante` (`serie`, `numero_secuencial`, `tipo`),
  INDEX `idx_estado` (`estado`),
  INDEX `idx_tipo` (`tipo`),
  INDEX `idx_fecha` (`fecha_generacion`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ===============================
-- TABLA: sunat_configuracion
-- ===============================
-- Almacena datos de configuración de la empresa

CREATE TABLE IF NOT EXISTS `sunat_configuracion` (
  `id_config` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `ruc` varchar(11) NOT NULL UNIQUE,
  `nombre_empresa` varchar(255) NOT NULL,
  `direccion` varchar(500),
  `telefono` varchar(20),
  `email` varchar(100),
  `serie_boleta` varchar(10) NOT NULL DEFAULT '0001',
  `serie_factura` varchar(10) NOT NULL DEFAULT '0001',
  `usuario_sunat` varchar(100),
  `usuario_sol` varchar(100),
  `ambiente` varchar(20) DEFAULT 'pruebas' COMMENT 'pruebas o produccion',
  `activo` tinyint(1) DEFAULT 1,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_actualizacion` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  INDEX `idx_ruc` (`ruc`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ===============================
-- INSERTAR DATOS INICIALES
-- ===============================
-- Solo si la tabla está vacía

INSERT INTO `sunat_configuracion` (
  `ruc`,
  `nombre_empresa`,
  `direccion`,
  `serie_boleta`,
  `serie_factura`,
  `ambiente`
) VALUES (
  '20612278815',
  'GENERAL SERVICE VIÑA E.I.R.L.',
  'OTR.PRIMAVERA MZA. 25 LOTE. 1 A.H. PRIMAVERA',
  '0001',
  '0001',
  'pruebas'
)
ON DUPLICATE KEY UPDATE 
  `nombre_empresa` = VALUES(`nombre_empresa`),
  `fecha_actualizacion` = NOW();

-- ===============================
-- VISTAS ÚTILES
-- ===============================

-- Vista: Resumen de comprobantes por estado
CREATE OR REPLACE VIEW vw_comprobantes_resumen AS
SELECT 
  tipo,
  estado,
  COUNT(*) as cantidad,
  SUM(total) as monto_total,
  MAX(fecha_generacion) as ultima_generacion
FROM comprobante_sunat
GROUP BY tipo, estado;

-- Vista: Comprobantes por cliente
CREATE OR REPLACE VIEW vw_comprobantes_por_cliente AS
SELECT 
  cs.id_comprobante,
  cs.tipo,
  cs.serie,
  cs.numero_secuencial,
  c.razon_social as cliente,
  p.nombre_completo,
  cs.total,
  cs.estado,
  cs.fecha_generacion,
  cs.fecha_envio,
  cs.intentos_envio
FROM comprobante_sunat cs
JOIN venta v ON cs.id_venta = v.id_venta
JOIN cliente c ON v.id_cliente = c.id_cliente
JOIN persona p ON c.id_persona = p.id_persona;

-- ===============================
-- PROCEDIMIENTOS ALMACENADOS
-- ===============================

DELIMITER $$

-- Obtener siguiente número de serie
CREATE PROCEDURE IF NOT EXISTS sp_obtener_siguiente_numero (
  IN p_tipo VARCHAR(20),
  IN p_serie VARCHAR(10),
  OUT p_numero INT
)
BEGIN
  SELECT COALESCE(MAX(numero_secuencial), 0) + 1 
  INTO p_numero
  FROM comprobante_sunat 
  WHERE tipo = p_tipo AND serie = p_serie;
END$$

-- Obtener estad ísticas SUNAT
CREATE PROCEDURE IF NOT EXISTS sp_estadisticas_sunat (
  IN p_fecha_inicio DATE,
  IN p_fecha_fin DATE
)
BEGIN
  SELECT 
    DATE(fecha_generacion) as fecha,
    tipo,
    estado,
    COUNT(*) as cantidad,
    SUM(total) as monto
  FROM comprobante_sunat
  WHERE DATE(fecha_generacion) BETWEEN p_fecha_inicio AND p_fecha_fin
  GROUP BY DATE(fecha_generacion), tipo, estado
  ORDER BY fecha DESC;
END$$

DELIMITER ;

-- ===============================
-- ÍNDICES ADICIONALES PARA PERFORMANCE
-- ===============================

CREATE INDEX IF NOT EXISTS idx_comprobante_venta ON comprobante_sunat(`id_venta`);
CREATE INDEX IF NOT EXISTS idx_comprobante_serie ON comprobante_sunat(`serie`, `numero_secuencial`);
CREATE INDEX IF NOT EXISTS idx_comprobante_fechas ON comprobante_sunat(`fecha_generacion`, `fecha_envio`);

-- ===============================
-- VERIFICACIÓN FINAL
-- ===============================

-- Mostrar estructura de las tablas
-- DESCRIBE comprobante_sunat;
-- DESCRIBE sunat_configuracion;

-- Verificar datos de configuración
-- SELECT * FROM sunat_configuracion;

-- Contar comprobantes
-- SELECT COUNT(*) as total_comprobantes FROM comprobante_sunat;
-- SELECT tipo, estado, COUNT(*) FROM comprobante_sunat GROUP BY tipo, estado;

