-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 25-02-2026 a las 18:34:59
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `sistema_agua`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categorias`
--

CREATE TABLE `categorias` (
  `id_categoria` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `categorias`
--

INSERT INTO `categorias` (`id_categoria`, `nombre`) VALUES
(1, 'Bidón'),
(2, 'Botella'),
(3, 'Botellín');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cliente`
--

CREATE TABLE `cliente` (
  `id_cliente` int(11) NOT NULL,
  `id_persona` int(11) NOT NULL,
  `tipo_cliente` enum('Bodega','Restaurante','Gimnasio','Persona','Empresa') NOT NULL,
  `razon_social` varchar(200) DEFAULT NULL,
  `activo` tinyint(1) DEFAULT 1,
  `fecha_registro` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `cliente`
--

INSERT INTO `cliente` (`id_cliente`, `id_persona`, `tipo_cliente`, `razon_social`, `activo`, `fecha_registro`) VALUES
(1, 7, 'Bodega', 'Bodega Don Pepin', 1, '2025-10-18 20:18:44'),
(2, 8, 'Restaurante', 'Restaurante La Olla', 1, '2025-10-18 20:18:44'),
(3, 9, 'Gimnasio', 'Gimnasio Power Futal', 1, '2025-10-18 20:18:44'),
(4, 10, 'Persona', NULL, 1, '2025-10-23 04:27:24'),
(5, 11, 'Bodega', 'ncjaisnca', 1, '2025-10-26 22:28:02'),
(6, 12, 'Persona', NULL, 1, '2025-10-26 22:34:51'),
(7, 20, 'Persona', NULL, 1, '2025-11-10 14:18:04'),
(8, 21, 'Persona', NULL, 1, '2025-11-10 15:32:34'),
(9, 23, 'Persona', NULL, 1, '2025-11-10 15:37:16'),
(10, 24, 'Persona', NULL, 1, '2025-11-10 16:18:00'),
(11, 25, 'Persona', NULL, 1, '2025-11-10 16:22:07'),
(12, 27, 'Empresa', 'vidrieriaSAN', 1, '2025-11-12 18:16:13'),
(13, 28, 'Bodega', 'Huancas', 1, '2025-11-19 17:51:55'),
(14, 29, 'Persona', NULL, 1, '2025-11-19 18:13:02'),
(15, 31, 'Bodega', 'por el grifo sanjuan', 1, '2025-11-23 23:48:44'),
(16, 33, 'Persona', NULL, 1, '2025-12-28 15:57:15');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `comprobante_sunat`
--

CREATE TABLE `comprobante_sunat` (
  `id_comprobante` int(11) NOT NULL,
  `id_venta` int(11) NOT NULL,
  `tipo` varchar(20) NOT NULL COMMENT 'BOLETA o FACTURA',
  `serie` varchar(10) NOT NULL,
  `numero_secuencial` int(11) NOT NULL,
  `xml_generado` longtext NOT NULL COMMENT 'Contenido XML completo',
  `estado` varchar(50) NOT NULL DEFAULT 'GENERADO' COMMENT 'GENERADO, ACEPTADO, RECHAZADO, ERROR, PENDIENTE',
  `respuesta_sunat` longtext DEFAULT NULL COMMENT 'JSON con respuesta de SUNAT',
  `fecha_generacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_envio` timestamp NULL DEFAULT NULL,
  `intentos_envio` int(11) DEFAULT 0,
  `ruc_cliente` varchar(11) DEFAULT NULL,
  `dni_cliente` varchar(8) DEFAULT NULL,
  `cliente_nombre` varchar(255) DEFAULT NULL,
  `total` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `comprobante_sunat`
--

INSERT INTO `comprobante_sunat` (`id_comprobante`, `id_venta`, `tipo`, `serie`, `numero_secuencial`, `xml_generado`, `estado`, `respuesta_sunat`, `fecha_generacion`, `fecha_envio`, `intentos_envio`, `ruc_cliente`, `dni_cliente`, `cliente_nombre`, `total`) VALUES
(5, 43, 'FACTURA', 'F001', 3, '<?xml version=\"1.0\"?><invoice>XML SIMULADO</invoice>', 'ACEPTADO', '{\"code\":\"0\",\"description\":\"La Factura ha sido aceptada\",\"notes\":[\"Generado en modo desarrollo\"],\"hash\":\"dev_ee00ab8d37f550a8e330ed4aa6825f34\",\"estado\":\"ACEPTADO\"}', '2025-12-16 03:10:24', '2025-12-16 03:10:24', 1, NULL, NULL, 'Ernesto Gabriel Rengifo Lopez', 8.00),
(8, 52, 'FACTURA', 'F001', 6, '<?xml version=\"1.0\"?><invoice>XML SIMULADO</invoice>', 'ACEPTADO', '{\"code\":\"0\",\"description\":\"La Factura ha sido aceptada\",\"notes\":[\"Generado en modo desarrollo\"],\"hash\":\"dev_971b8050555898e0ae0cb51248a71c71\",\"estado\":\"ACEPTADO\"}', '2025-12-17 16:09:13', '2025-12-17 16:09:13', 1, NULL, NULL, 'Ernesto Gabriel Rengifo Lopez', 15.00),
(9, 53, 'BOLETA', 'B001', 1, '<?xml version=\"1.0\"?><invoice>XML SIMULADO</invoice>', 'ACEPTADO', '{\"code\":\"0\",\"description\":\"La Factura ha sido aceptada\",\"notes\":[\"Generado en modo desarrollo\"],\"hash\":\"dev_dd1eccbddc61b49c79935a9242867b2d\",\"estado\":\"ACEPTADO\"}', '2025-12-17 19:48:02', '2025-12-17 19:48:02', 1, NULL, NULL, 'Julio Carlos Santillama', 12.00),
(10, 56, 'BOLETA', 'B001', 2, '<?xml version=\"1.0\"?><invoice>XML SIMULADO</invoice>', 'ACEPTADO', '{\"code\":\"0\",\"description\":\"La Factura ha sido aceptada\",\"notes\":[\"Generado en modo desarrollo\"],\"hash\":\"dev_e8c0484e0b7ec96295a94dda51f6ca31\",\"estado\":\"ACEPTADO\"}', '2025-12-19 18:07:20', '2025-12-19 18:07:20', 1, NULL, NULL, 'Gimnasio Power Futal', 12.00),
(11, 59, 'BOLETA', 'B001', 3, '<?xml version=\"1.0\"?><invoice>XML SIMULADO</invoice>', 'ACEPTADO', '{\"code\":\"0\",\"description\":\"La Factura ha sido aceptada\",\"notes\":[\"Generado en modo desarrollo\"],\"hash\":\"dev_6a1eb9bf209c62a97c03f0f42c460b4c\",\"estado\":\"ACEPTADO\"}', '2025-12-28 18:13:58', '2025-12-28 18:13:58', 1, NULL, NULL, 'Dennys gongora Farina', 53.50),
(12, 105, 'BOLETA', 'B001', 4, '<?xml version=\"1.0\"?><invoice>XML SIMULADO</invoice>', 'ACEPTADO', '{\"code\":\"0\",\"description\":\"La Factura ha sido aceptada\",\"notes\":[\"Generado en modo desarrollo\"],\"hash\":\"dev_b70b5ac55d29eae41a361501664c1c26\",\"estado\":\"ACEPTADO\"}', '2026-01-27 02:36:46', '2026-01-27 02:36:46', 1, NULL, NULL, 'Gimnasio Power Futal', 12.00),
(13, 121, 'FACTURA', 'F001', 7, '<?xml version=\"1.0\"?><invoice>XML SIMULADO</invoice>', 'ACEPTADO', '{\"code\":\"0\",\"description\":\"La Factura ha sido aceptada\",\"notes\":[\"Generado en modo desarrollo\"],\"hash\":\"dev_294be780dd7d7201fd29042849a9d3f1\",\"estado\":\"ACEPTADO\"}', '2026-02-13 19:31:23', '2026-02-13 19:31:23', 1, '20111111111', NULL, 'Restaurante La Olla', 15.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `departamento`
--

CREATE TABLE `departamento` (
  `id_departamento` int(11) NOT NULL,
  `departamento` varchar(100) NOT NULL,
  `id_pais` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `departamento`
--

INSERT INTO `departamento` (`id_departamento`, `departamento`, `id_pais`) VALUES
(1, 'Lima', 1),
(2, 'Arequipa', 1),
(3, 'Cuzco', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `distrito`
--

CREATE TABLE `distrito` (
  `id_distrito` int(11) NOT NULL,
  `distrito` varchar(100) NOT NULL,
  `id_provincia` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `distrito`
--

INSERT INTO `distrito` (`id_distrito`, `distrito`, `id_provincia`) VALUES
(1, 'Lima Cercado', 1),
(2, 'Miraflores', 1),
(3, 'San Isidro', 1),
(4, 'La Victoria', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empresa_config`
--

CREATE TABLE `empresa_config` (
  `id_config` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `ruc` varchar(11) NOT NULL,
  `eslogan` varchar(200) DEFAULT NULL,
  `direccion` text NOT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `logo_url` varchar(255) DEFAULT NULL,
  `logo_texto` varchar(10) DEFAULT '?',
  `logo_login` varchar(255) DEFAULT NULL,
  `logo_navbar` varchar(255) DEFAULT NULL,
  `nombre_sistema` varchar(100) DEFAULT NULL,
  `web` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `activo` tinyint(1) DEFAULT 1,
  `fecha_actualizacion` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `empresa_config`
--

INSERT INTO `empresa_config` (`id_config`, `nombre`, `ruc`, `eslogan`, `direccion`, `telefono`, `logo_url`, `logo_texto`, `logo_login`, `logo_navbar`, `nombre_sistema`, `web`, `email`, `activo`, `fecha_actualizacion`) VALUES
(1, 'VIÑA', '20305757451', 'Agua de calidad para tu hogar', 'Av.las rosas - UCAYALI - CORONEL PORTILLO - CALLERIA', '998398222', NULL, '💧', 'assets/empresa/logo-logo-1772041439817.png', 'assets/empresa/logo-logo-1772041487460.png', 'VIÑA', 'www.aguaviña.com', 'ventas@xn--aguavia-9za.com', 1, '2026-02-25 18:13:40');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `entrega_dinero_repartidor`
--

CREATE TABLE `entrega_dinero_repartidor` (
  `id_entrega` int(11) NOT NULL,
  `id_repartidor` int(11) NOT NULL,
  `total` decimal(10,2) NOT NULL CHECK (`total` > 0),
  `metodo_entrega` enum('efectivo','transferencia','yape') DEFAULT 'efectivo',
  `fecha_entrega` datetime DEFAULT current_timestamp(),
  `estado` enum('pendiente','completado','verificado','rechazado') DEFAULT 'completado',
  `notas` text DEFAULT NULL,
  `fecha_registro` datetime DEFAULT current_timestamp(),
  `id_usuario_registro` int(11) DEFAULT NULL,
  `tipo_entrega` varchar(50) DEFAULT 'hoy' COMMENT 'hoy: solo ventas de hoy, regularizada: ventas anteriores por fecha, mixta: días anteriores entregados hoy, completa_anterior: solo días anteriores, mixta_completa: hoy+anterior'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `entrega_dinero_repartidor`
--

INSERT INTO `entrega_dinero_repartidor` (`id_entrega`, `id_repartidor`, `total`, `metodo_entrega`, `fecha_entrega`, `estado`, `notas`, `fecha_registro`, `id_usuario_registro`, `tipo_entrega`) VALUES
(5, 2, 4.00, 'efectivo', '2026-01-01 15:41:34', 'completado', 'Entrega registrada por María García. Método: efectivo', '2026-01-01 15:41:34', 11, 'hoy'),
(6, 1, 29.00, 'efectivo', '2026-01-01 16:01:59', 'completado', 'Entrega registrada por Juan Pérez. Método: efectivo', '2026-01-01 16:01:59', 8, 'hoy'),
(7, 3, 58.00, 'efectivo', '2026-01-01 17:04:15', 'completado', 'Entrega registrada por Carlos López. Método: efectivo', '2026-01-01 17:04:15', 10, 'hoy'),
(8, 1, 9.00, 'efectivo', '2026-01-02 22:38:35', 'completado', 'Entrega registrada por Juan Pérez. Método: efectivo', '2026-01-02 22:38:35', 8, 'hoy'),
(9, 1, 4.00, 'yape', '2026-01-02 00:00:00', 'completado', 'Entrega regularizada por Juan Pérez. Fecha original: 2026-01-02. Método: yape', '2026-01-07 13:01:50', 8, 'hoy'),
(10, 1, 4.00, 'yape', '2025-12-30 00:00:00', 'completado', 'Entrega regularizada por Juan Pérez. Fecha original: 2025-12-30. Método: yape', '2026-01-07 13:07:37', 8, 'hoy'),
(11, 1, 656.50, 'yape', '2025-12-28 00:00:00', 'completado', 'Entrega regularizada por Juan Pérez. Fecha original: 2025-12-28. Método: yape', '2026-01-07 13:10:27', 8, 'hoy'),
(12, 1, 37.50, 'yape', '2025-12-29 00:00:00', 'completado', 'Entrega regularizada por Juan Pérez. Fecha original: 2025-12-29. Método: yape', '2026-01-07 13:10:27', 8, 'hoy'),
(14, 2, 12.00, 'yape', '2025-12-30 00:00:00', 'completado', 'Entrega regularizada por María García. Fecha original: 2025-12-30. Método: yape', '2026-01-07 20:25:42', 11, 'hoy'),
(18, 3, 14.00, 'efectivo', '2025-11-23 00:00:00', 'completado', 'Entrega regularizada por Carlos López. Fecha original: 2025-11-23. Método: efectivo', '2026-01-08 10:33:22', 10, 'hoy'),
(19, 3, 12.00, 'efectivo', '2025-12-17 00:00:00', 'completado', 'Entrega regularizada por Carlos López. Fecha original: 2025-12-17. Método: efectivo', '2026-01-08 10:33:22', 10, 'hoy'),
(20, 3, 16.00, 'efectivo', '2025-12-29 00:00:00', 'completado', 'Entrega regularizada por Carlos López. Fecha original: 2025-12-29. Método: efectivo', '2026-01-08 10:33:22', 10, 'hoy'),
(21, 3, 53.50, 'efectivo', '2025-12-28 00:00:00', 'completado', 'Entrega regularizada por Carlos López. Fecha original: 2025-12-28. Método: efectivo', '2026-01-08 10:33:22', 10, 'hoy'),
(22, 3, 12.00, 'efectivo', '2025-12-19 00:00:00', 'completado', 'Entrega regularizada por Carlos López. Fecha original: 2025-12-19. Método: efectivo', '2026-01-08 10:33:22', 10, 'hoy'),
(23, 3, 10.00, 'efectivo', '2025-12-30 00:00:00', 'completado', 'Entrega regularizada por Carlos López. Fecha original: 2025-12-30. Método: efectivo', '2026-01-08 10:33:22', 10, 'hoy'),
(24, 2, 9.00, 'efectivo', '2026-01-08 23:20:27', 'completado', 'Entrega registrada por María García. Método: efectivo', '2026-01-08 23:20:27', 11, 'hoy'),
(25, 3, 8.00, 'yape', '2026-01-08 00:00:00', 'completado', 'Entrega regularizada por Carlos López. Fecha original: 2026-01-08. Método: yape', '2026-01-09 01:54:41', 10, 'hoy'),
(26, 3, 600.00, 'efectivo', '2026-01-14 19:57:35', 'completado', 'Entrega registrada por Carlos López. Método: efectivo', '2026-01-14 19:57:35', 10, 'hoy'),
(27, 3, 13.50, 'efectivo', '2026-01-15 20:43:14', 'completado', 'Entrega registrada por Carlos López. Método: efectivo', '2026-01-15 20:43:14', 10, 'hoy'),
(32, 1, 20.00, 'efectivo', '2026-01-15 00:00:00', 'completado', 'Entrega regularizada por Juan Pérez. Fecha original: 2026-01-15. Método: efectivo', '2026-01-18 14:54:08', 8, 'hoy'),
(33, 2, 20.00, 'efectivo', '2026-01-15 00:00:00', 'completado', 'Entrega regularizada por María García. Fecha original: 2026-01-15. Método: efectivo', '2026-01-18 14:54:56', 11, 'hoy'),
(36, 3, 12.00, 'efectivo', '2026-01-15 00:00:00', 'completado', 'Entrega regularizada por Carlos López. Fecha original: 2026-01-15. Método: efectivo', '2026-01-20 23:40:58', 10, 'hoy'),
(37, 3, 4.00, 'efectivo', '2026-01-19 00:00:00', 'completado', 'Entrega regularizada por Carlos López. Fecha original: 2026-01-19. Método: efectivo', '2026-01-20 23:41:36', 10, 'hoy'),
(38, 3, 4.00, 'efectivo', '2026-01-20 23:50:06', 'completado', 'Entrega registrada por Carlos López. Método: efectivo', '2026-01-20 23:50:06', 10, 'hoy'),
(39, 2, 15.00, 'efectivo', '2026-01-21 15:07:25', 'completado', 'Entrega registrada por María García. Método: efectivo', '2026-01-21 15:07:25', 11, 'hoy'),
(40, 3, 9.00, 'efectivo', '2026-01-21 15:21:08', 'completado', 'Entrega registrada por Carlos López. Método: efectivo', '2026-01-21 15:21:08', 10, 'hoy'),
(41, 3, 34.50, 'efectivo', '2026-01-26 21:30:03', 'completado', 'Entrega registrada por Carlos López. Método: efectivo', '2026-01-26 21:30:03', 10, 'hoy'),
(42, 3, 21.00, 'efectivo', '2026-01-28 19:45:17', 'completado', 'Entrega registrada por Carlos López. Método: efectivo', '2026-01-28 19:45:17', 10, 'hoy'),
(43, 3, 22.50, 'efectivo', '2026-02-11 18:39:04', 'completado', 'Entrega registrada por Carlos López. Método: efectivo', '2026-02-11 18:39:04', 10, 'hoy'),
(44, 1, 25.50, 'efectivo', '2025-10-21 00:00:00', 'completado', 'Entrega regularizada por Juan Pérez. Fecha original: 2025-10-21. Método: efectivo', '2026-02-13 14:02:36', 8, 'hoy'),
(45, 1, 8.00, 'efectivo', '2025-10-22 00:00:00', 'completado', 'Entrega regularizada por Juan Pérez. Fecha original: 2025-10-22. Método: efectivo', '2026-02-13 14:02:36', 8, 'hoy'),
(46, 1, 60.00, 'efectivo', '2025-11-01 00:00:00', 'completado', 'Entrega regularizada por Juan Pérez. Fecha original: 2025-11-01. Método: efectivo', '2026-02-13 14:02:36', 8, 'hoy'),
(47, 1, 64.00, 'efectivo', '2025-11-09 00:00:00', 'completado', 'Entrega regularizada por Juan Pérez. Fecha original: 2025-11-09. Método: efectivo', '2026-02-13 14:02:36', 8, 'hoy'),
(48, 1, 51.00, 'efectivo', '2025-11-10 00:00:00', 'completado', 'Entrega regularizada por Juan Pérez. Fecha original: 2025-11-10. Método: efectivo', '2026-02-13 14:03:36', 8, 'hoy'),
(49, 1, 12.00, 'efectivo', '2025-12-18 00:00:00', 'completado', 'Entrega regularizada por Juan Pérez. Fecha original: 2025-12-18. Método: efectivo', '2026-02-13 14:05:33', 8, 'hoy'),
(50, 1, 30.00, 'efectivo', '2025-12-05 00:00:00', 'completado', 'Entrega regularizada por Juan Pérez. Fecha original: 2025-12-05. Método: efectivo', '2026-02-13 14:06:14', 8, 'hoy'),
(51, 1, 15.00, 'efectivo', '2025-12-17 00:00:00', 'completado', 'Entrega regularizada por Juan Pérez. Fecha original: 2025-12-17. Método: efectivo', '2026-02-13 14:06:14', 8, 'hoy'),
(52, 1, 12.00, 'efectivo', '2025-11-24 00:00:00', 'completado', 'Entrega regularizada por Juan Pérez. Fecha original: 2025-11-24. Método: efectivo', '2026-02-13 14:06:46', 8, 'hoy'),
(53, 1, 600.00, 'efectivo', '2025-12-03 00:00:00', 'completado', 'Entrega regularizada por Juan Pérez. Fecha original: 2025-12-03. Método: efectivo', '2026-02-13 14:06:46', 8, 'hoy'),
(54, 1, 4.00, 'efectivo', '2025-11-12 00:00:00', 'completado', 'Entrega regularizada por Juan Pérez. Fecha original: 2025-11-12. Método: efectivo', '2026-02-13 14:07:20', 8, 'hoy'),
(55, 1, 24.00, 'efectivo', '2025-11-13 00:00:00', 'completado', 'Entrega regularizada por Juan Pérez. Fecha original: 2025-11-13. Método: efectivo', '2026-02-13 14:07:20', 8, 'hoy'),
(56, 1, 4.00, 'efectivo', '2025-11-17 00:00:00', 'completado', 'Entrega regularizada por Juan Pérez. Fecha original: 2025-11-17. Método: efectivo', '2026-02-13 14:07:20', 8, 'hoy'),
(57, 1, 70.00, 'efectivo', '2025-11-19 00:00:00', 'completado', 'Entrega regularizada por Juan Pérez. Fecha original: 2025-11-19. Método: efectivo', '2026-02-13 14:07:20', 8, 'hoy'),
(58, 1, 74.50, 'efectivo', '2025-11-23 00:00:00', 'completado', 'Entrega regularizada por Juan Pérez. Fecha original: 2025-11-23. Método: efectivo', '2026-02-13 14:07:20', 8, 'hoy'),
(59, 3, 15.00, 'efectivo', '2026-02-13 00:00:00', 'completado', 'Entrega regularizada por Carlos López. Fecha original: 2026-02-13. Método: efectivo', '2026-02-14 12:08:13', 10, 'hoy'),
(60, 3, 9.00, 'efectivo', '2026-02-14 00:00:00', 'completado', 'Entrega regularizada por Carlos López. Fecha original: 2026-02-14. Método: efectivo', '2026-02-17 13:09:40', 10, 'hoy');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `entrega_dinero_ventas`
--

CREATE TABLE `entrega_dinero_ventas` (
  `id_asociacion` int(11) NOT NULL,
  `id_entrega` int(11) NOT NULL,
  `id_venta` int(11) NOT NULL,
  `monto_asignado` decimal(10,2) NOT NULL,
  `fecha_asociacion` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `entrega_dinero_ventas`
--

INSERT INTO `entrega_dinero_ventas` (`id_asociacion`, `id_entrega`, `id_venta`, `monto_asignado`, `fecha_asociacion`) VALUES
(5, 5, 81, 4.00, '2026-01-01 20:41:34'),
(6, 6, 78, 12.00, '2026-01-01 21:01:59'),
(7, 7, 74, 9.00, '2026-01-01 22:04:15'),
(8, 8, 82, 9.00, '2026-01-03 03:38:35'),
(9, 6, 77, 8.00, '2026-01-01 21:01:59'),
(10, 6, 79, 9.00, '2026-01-01 21:01:59'),
(11, 7, 75, 30.00, '2026-01-01 22:04:15'),
(12, 7, 76, 15.00, '2026-01-01 22:04:15'),
(13, 7, 80, 4.00, '2026-01-01 22:04:15'),
(14, 9, 83, 4.00, '2026-01-07 18:01:50'),
(15, 10, 69, 4.00, '2026-01-07 18:07:38'),
(16, 11, 58, 600.00, '2026-01-07 18:10:27'),
(17, 11, 60, 8.50, '2026-01-07 18:10:27'),
(18, 12, 67, 22.50, '2026-01-07 18:10:27'),
(19, 11, 61, 33.00, '2026-01-07 18:10:27'),
(20, 12, 68, 15.00, '2026-01-07 18:10:27'),
(21, 11, 62, 15.00, '2026-01-07 18:10:27'),
(28, 14, 71, 4.50, '2026-01-08 01:25:42'),
(29, 14, 72, 7.50, '2026-01-08 01:25:42'),
(42, 18, 42, 6.00, '2026-01-08 15:33:22'),
(43, 23, 70, 4.00, '2026-01-08 15:33:22'),
(44, 22, 56, 12.00, '2026-01-08 15:33:22'),
(45, 19, 53, 12.00, '2026-01-08 15:33:22'),
(46, 21, 59, 53.50, '2026-01-08 15:33:22'),
(47, 20, 63, 4.00, '2026-01-08 15:33:22'),
(48, 18, 43, 8.00, '2026-01-08 15:33:22'),
(49, 23, 73, 6.00, '2026-01-08 15:33:22'),
(50, 20, 66, 12.00, '2026-01-08 15:33:22'),
(53, 25, 84, 8.00, '2026-01-09 06:54:41'),
(54, 26, 86, 600.00, '2026-01-15 00:57:35'),
(55, 27, 87, 13.50, '2026-01-16 01:43:14'),
(61, 32, 88, 12.00, '2026-01-18 19:54:08'),
(62, 32, 89, 8.00, '2026-01-18 19:54:08'),
(63, 33, 90, 12.00, '2026-01-18 19:54:56'),
(64, 33, 91, 8.00, '2026-01-18 19:54:56'),
(67, 36, 93, 12.00, '2026-01-21 04:40:58'),
(68, 37, 98, 4.00, '2026-01-21 04:41:36'),
(69, 38, 99, 4.00, '2026-01-21 04:50:06'),
(71, 40, 101, 9.00, '2026-01-21 20:21:08'),
(72, 24, 85, 9.00, '2026-01-23 00:03:32'),
(73, 39, 100, 15.00, '2026-01-23 00:03:32'),
(74, 41, 104, 22.50, '2026-01-27 02:30:03'),
(75, 41, 105, 12.00, '2026-01-27 02:30:03'),
(76, 42, 106, 6.00, '2026-01-29 00:45:17'),
(77, 42, 107, 7.50, '2026-01-29 00:45:17'),
(78, 42, 108, 7.50, '2026-01-29 00:45:17'),
(79, 43, 120, 22.50, '2026-02-11 23:39:04'),
(80, 44, 3, 17.00, '2026-02-13 19:02:36'),
(81, 45, 5, 8.00, '2026-02-13 19:02:36'),
(82, 44, 4, 8.50, '2026-02-13 19:02:36'),
(83, 46, 6, 60.00, '2026-02-13 19:02:36'),
(84, 47, 10, 22.00, '2026-02-13 19:02:36'),
(85, 47, 12, 24.00, '2026-02-13 19:02:36'),
(86, 47, 13, 18.00, '2026-02-13 19:02:36'),
(87, 48, 14, 51.00, '2026-02-13 19:03:36'),
(88, 49, 55, 12.00, '2026-02-13 19:05:34'),
(89, 50, 49, 30.00, '2026-02-13 19:06:14'),
(90, 51, 52, 15.00, '2026-02-13 19:06:14'),
(91, 53, 46, 600.00, '2026-02-13 19:06:46'),
(92, 52, 44, 12.00, '2026-02-13 19:06:46'),
(93, 54, 28, 4.00, '2026-02-13 19:07:20'),
(94, 55, 29, 24.00, '2026-02-13 19:07:20'),
(95, 56, 30, 4.00, '2026-02-13 19:07:20'),
(96, 58, 34, 30.00, '2026-02-13 19:07:20'),
(97, 57, 31, 60.00, '2026-02-13 19:07:20'),
(98, 58, 35, 24.00, '2026-02-13 19:07:20'),
(99, 57, 32, 4.00, '2026-02-13 19:07:20'),
(100, 58, 36, 4.00, '2026-02-13 19:07:20'),
(101, 57, 33, 6.00, '2026-02-13 19:07:20'),
(102, 58, 37, 6.00, '2026-02-13 19:07:20'),
(103, 58, 38, 4.50, '2026-02-13 19:07:20'),
(104, 58, 39, 6.00, '2026-02-13 19:07:20'),
(105, 59, 121, 15.00, '2026-02-14 17:08:13'),
(106, 60, 122, 9.00, '2026-02-17 18:09:40');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `errores_sunat`
--

CREATE TABLE `errores_sunat` (
  `id_error` int(11) NOT NULL,
  `id_venta` int(11) NOT NULL,
  `mensaje_error` text DEFAULT NULL,
  `fecha_error` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `errores_sunat`
--

INSERT INTO `errores_sunat` (`id_error`, `id_venta`, `mensaje_error`, `fecha_error`) VALUES
(1, 43, 'Duplicate entry \'F001-1-FACTURA\' for key \'unique_comprobante\'', '2025-12-15 00:30:17'),
(2, 49, 'Duplicate entry \'F001-1-FACTURA\' for key \'unique_comprobante\'', '2025-12-15 21:22:37'),
(3, 53, 'Esta venta ya tiene un comprobante emitido', '2025-12-18 11:44:16'),
(4, 59, 'Error', '2025-12-28 13:13:08'),
(5, 105, 'Error', '2026-01-26 21:34:00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estado_pedido_proveedor`
--

CREATE TABLE `estado_pedido_proveedor` (
  `id_estado_pedido` int(11) NOT NULL,
  `estado` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `estado_pedido_proveedor`
--

INSERT INTO `estado_pedido_proveedor` (`id_estado_pedido`, `estado`) VALUES
(1, 'Solicitado'),
(2, 'Confirmado'),
(3, 'En camino'),
(4, 'Recibido'),
(5, 'Cancelado');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estado_venta`
--

CREATE TABLE `estado_venta` (
  `id_estado_venta` int(11) NOT NULL,
  `estado` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `estado_venta`
--

INSERT INTO `estado_venta` (`id_estado_venta`, `estado`) VALUES
(1, 'Pendiente'),
(4, 'Listo para repartos'),
(5, 'En ruta'),
(7, 'Pagado'),
(8, 'Cancelado');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `insumo`
--

CREATE TABLE `insumo` (
  `id_insumo` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `unidad_medida` varchar(20) NOT NULL,
  `costo_promedio` decimal(10,2) DEFAULT 0.00,
  `stock_actual` int(11) DEFAULT 0,
  `stock_minimo` int(11) DEFAULT 0,
  `id_proveedor_principal` int(11) DEFAULT NULL,
  `activo` tinyint(1) DEFAULT 1,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `insumo`
--

INSERT INTO `insumo` (`id_insumo`, `nombre`, `descripcion`, `unidad_medida`, `costo_promedio`, `stock_actual`, `stock_minimo`, `id_proveedor_principal`, `activo`, `fecha_creacion`) VALUES
(1, 'Bidón plástico vacío 20L', 'Bidón de plástico vacío para envasar agua', 'unidades', 1.80, 0, 100, 1, 1, '2025-11-13 17:05:58'),
(2, 'Botella PET 650ml', 'Botella PET vacía para agua 650ml', 'unidades', 0.25, 0, 500, 1, 1, '2025-11-13 17:05:58'),
(3, 'Botella PET 600ml', 'Botella PET vacía para agua 600ml', 'unidades', 0.22, 0, 400, 1, 1, '2025-11-13 17:05:58'),
(4, 'Tapa rosca plástica', 'Tapa de plástico para bidones y botellas', 'unidades', 0.08, 70, 1000, 1, 1, '2025-11-13 17:05:58'),
(5, 'Etiqueta frontal Agua Bella', 'Etiqueta frontal para productos marca Bella', 'unidades', 0.03, 0, 2000, 1, 1, '2025-11-13 17:05:58'),
(6, 'Etiqueta frontal Agua Viña', 'Etiqueta frontal para productos marca Viña', 'unidades', 0.03, 1000, 1500, 1, 1, '2025-11-13 17:05:58'),
(7, 'Sello de seguridad', 'Sello de seguridad para bidones', 'unidades', 0.15, 170, 300, 1, 1, '2025-11-13 17:05:58');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `lote_producto`
--

CREATE TABLE `lote_producto` (
  `id_lote` int(11) NOT NULL,
  `id_producto` int(11) NOT NULL,
  `numero_lote` varchar(50) NOT NULL,
  `fecha_caducidad` date NOT NULL,
  `cantidad_inicial` int(11) NOT NULL,
  `cantidad_actual` int(11) NOT NULL,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `activo` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `lote_producto`
--

INSERT INTO `lote_producto` (`id_lote`, `id_producto`, `numero_lote`, `fecha_caducidad`, `cantidad_inicial`, `cantidad_actual`, `fecha_creacion`, `activo`) VALUES
(1, 1, 'LOTE-001-2025', '2026-03-30', 100, 59, '2025-10-18 20:18:44', 1),
(2, 2, 'LOTE-002-2025', '2026-03-30', 80, 51, '2025-10-18 20:18:44', 1),
(3, 3, 'LOTE-003-2025', '2026-03-30', 200, 0, '2025-10-18 20:18:44', 1),
(4, 4, 'LOTE-004-2025', '2026-03-30', 150, 110, '2025-10-18 20:18:44', 1),
(5, 1, 'L-2025Z', '2026-05-11', 100, 200, '2025-11-12 05:34:20', 0),
(6, 2, 'L-202510', '2026-06-12', 50, 100, '2025-11-12 17:44:59', 0),
(7, 3, '256-l', '2026-06-19', 500, 822, '2025-11-19 18:57:49', 0),
(8, 1, 'LOTE-006-2025', '2026-05-24', 20, 41, '2025-11-24 19:49:53', 0),
(9, 1, 'BL-202511-862', '2026-05-28', 100, 200, '2025-11-28 16:41:37', 0),
(10, 2, 'VL-202512-366', '2026-06-02', 200, 400, '2025-12-02 19:16:33', 0),
(15, 1, 'BL-202602-316', '2026-08-08', 20, 20, '2026-02-08 20:20:53', 1),
(18, 1, 'BL-202602-439', '2026-08-11', 20, 20, '2026-02-11 19:05:30', 1),
(19, 2, 'VL-202602-881', '2026-08-11', 100, 100, '2026-02-11 19:15:21', 1),
(20, 1, 'BL-202602-488', '2026-08-11', 50, 50, '2026-02-11 19:16:36', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `marcas`
--

CREATE TABLE `marcas` (
  `id_marca` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `marcas`
--

INSERT INTO `marcas` (`id_marca`, `nombre`) VALUES
(1, 'Bella'),
(2, 'Viña');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `metodo_pago`
--

CREATE TABLE `metodo_pago` (
  `id_metodo_pago` int(11) NOT NULL,
  `metodo_pago` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `metodo_pago`
--

INSERT INTO `metodo_pago` (`id_metodo_pago`, `metodo_pago`) VALUES
(1, 'Efectivo'),
(2, 'Yape'),
(3, 'Transferencia'),
(4, 'Tarjeta');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `movimiento_stock`
--

CREATE TABLE `movimiento_stock` (
  `id_movimiento` int(11) NOT NULL,
  `id_producto` int(11) NOT NULL,
  `tipo_movimiento` enum('ingreso','egreso','ajuste','devolucion') NOT NULL,
  `cantidad` int(11) NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT current_timestamp(),
  `descripcion` varchar(255) DEFAULT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `id_lote` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `movimiento_stock`
--

INSERT INTO `movimiento_stock` (`id_movimiento`, `id_producto`, `tipo_movimiento`, `cantidad`, `fecha`, `descripcion`, `id_usuario`, `id_lote`) VALUES
(4, 2, 'ingreso', 100, '2025-11-09 21:54:22', 'Produccion de bidones', 9, 2),
(5, 3, 'ingreso', 500, '2025-11-09 21:55:16', 'Porduccion de agua bella', 9, 3),
(6, 4, 'ingreso', 400, '2025-11-09 22:10:57', 'se solicitado 400 paquetes de agua viña', 9, 4),
(7, 1, 'ingreso', 100, '2025-11-10 18:33:02', 'Se ingreso 100 bidones de agua', 9, 1),
(8, 3, 'ingreso', 100, '2025-11-10 19:09:23', 'fdzgg', 9, 3),
(10, 1, 'ingreso', 100, '2025-11-12 14:04:38', 'Ingreso de nuevo lote de 100 bidones  de agua bella', 9, 5),
(12, 2, 'ingreso', 50, '2025-11-12 17:46:20', '', 9, 6),
(13, 1, 'egreso', 1, '2025-11-12 20:58:45', 'Venta #28 - Lote LOTE-001-2025', 3, 1),
(14, 3, 'egreso', 4, '2025-11-13 14:26:03', 'Venta #29 - Lote LOTE-003-2025', 3, 3),
(15, 1, 'egreso', 1, '2025-11-17 20:57:25', 'Venta #30 - Lote LOTE-001-2025', 3, 1),
(16, 3, 'egreso', 10, '2025-11-19 17:53:16', 'Venta #31 - Lote LOTE-003-2025', 3, 3),
(17, 1, 'egreso', 1, '2025-11-19 18:13:42', 'Venta #32 - Lote LOTE-001-2025', 3, 1),
(18, 3, 'egreso', 1, '2025-11-19 18:17:41', 'Venta #33 - Lote LOTE-003-2025', 3, 3),
(20, 3, 'ingreso', 500, '2025-11-19 19:00:51', 'Ingreso paquetes de agua bella', 9, 7),
(21, 1, 'egreso', 3, '2025-11-23 18:26:24', 'Venta #34 - Lote LOTE-001-2025', 6, 1),
(22, 3, 'egreso', 3, '2025-11-23 18:26:24', 'Venta #34 - Lote LOTE-003-2025', 6, 3),
(23, 3, 'egreso', 4, '2025-11-23 19:08:42', 'Venta #35 - Lote LOTE-003-2025', 6, 3),
(24, 1, 'egreso', 1, '2025-11-23 19:57:21', 'Venta #36 - Lote LOTE-001-2025', 6, 1),
(25, 3, 'egreso', 1, '2025-11-23 20:40:38', 'Venta #37 - Lote LOTE-003-2025', 6, 3),
(26, 2, 'egreso', 1, '2025-11-23 22:43:23', 'Venta #38 - Lote LOTE-002-2025', 6, 2),
(27, 3, 'egreso', 1, '2025-11-23 22:50:23', 'Venta #39 - Lote LOTE-003-2025', 6, 3),
(28, 2, 'egreso', 2, '2025-11-23 23:07:04', 'Venta #40 - Lote LOTE-002-2025', 6, 2),
(29, 3, 'egreso', 2, '2025-11-23 23:49:52', 'Venta #41 - Lote LOTE-003-2025', 6, 3),
(30, 3, 'egreso', 1, '2025-11-24 00:49:14', 'Venta #42 - Lote LOTE-003-2025', 6, 3),
(31, 1, 'egreso', 2, '2025-11-24 00:50:31', 'Venta #43 - Lote LOTE-001-2025', 6, 1),
(32, 3, 'egreso', 2, '2025-11-24 19:31:24', 'Venta #44 - Lote LOTE-003-2025', 6, 3),
(34, 1, 'ingreso', 21, '2025-11-24 19:52:16', '', 9, 8),
(36, 1, 'ingreso', 100, '2025-11-28 16:41:37', '📥 Ingreso - Bidón Agua Bella - 100 unidades', 3, 9),
(38, 2, 'ingreso', 200, '2025-12-02 19:16:33', '📥 Ingreso - Bidón Agua Viña - 200 unidades', 3, 10),
(39, 3, 'egreso', 4, '2025-12-02 19:20:53', 'Venta #45 - Lote LOTE-003-2025', 6, 3),
(40, 3, 'egreso', 100, '2025-12-03 13:56:19', 'Venta #46 - Lote LOTE-003-2025', 6, 3),
(41, 2, 'egreso', 1, '2025-12-05 04:49:17', 'Venta #47 - Lote LOTE-002-2025', 3, 2),
(42, 2, 'egreso', 1, '2025-12-06 01:01:52', 'Venta #48 - Lote LOTE-002-2025', 3, 2),
(43, 3, 'egreso', 5, '2025-12-06 02:19:13', 'Venta #49 - Lote LOTE-003-2025', 6, 3),
(44, 2, 'egreso', 1, '2025-12-17 03:54:28', 'Venta #50 - Lote LOTE-002-2025', 3, 2),
(45, 4, 'egreso', 2, '2025-12-17 16:04:28', 'Venta #51 - Lote LOTE-004-2025', 3, 4),
(46, 4, 'egreso', 2, '2025-12-17 16:07:08', 'Venta #52 - Lote LOTE-004-2025', 3, 4),
(47, 3, 'egreso', 2, '2025-12-17 19:21:30', 'Venta #53 - Lote LOTE-003-2025', 3, 3),
(48, 2, 'egreso', 1, '2025-12-17 20:04:17', 'Venta #54 - Lote LOTE-002-2025', 3, 2),
(49, 3, 'egreso', 1, '2025-12-17 20:04:17', 'Venta #54 - Lote LOTE-003-2025', 3, 3),
(50, 1, 'egreso', 3, '2025-12-18 05:31:50', 'Venta #55 - Lote LOTE-001-2025', 3, 1),
(51, 3, 'egreso', 2, '2025-12-19 18:01:35', 'Venta #56 - Lote LOTE-003-2025', 3, 3),
(52, 3, 'egreso', 1, '2025-12-21 03:28:02', 'Venta #57 - Lote LOTE-003-2025', 3, 3),
(53, 3, 'egreso', 56, '2025-12-28 15:57:58', 'Venta #58 - Lote LOTE-003-2025', 3, 3),
(54, 3, 'egreso', 44, '2025-12-28 15:57:58', 'Venta #58 - Lote 256-l', 3, 7),
(55, 1, 'egreso', 1, '2025-12-28 18:02:09', 'Venta #59 - Lote LOTE-001-2025', 3, 1),
(56, 2, 'egreso', 1, '2025-12-28 18:02:09', 'Venta #59 - Lote LOTE-002-2025', 3, 2),
(57, 3, 'egreso', 5, '2025-12-28 18:02:09', 'Venta #59 - Lote 256-l', 3, 7),
(58, 4, 'egreso', 2, '2025-12-28 18:02:09', 'Venta #59 - Lote LOTE-004-2025', 3, 4),
(59, 1, 'egreso', 1, '2025-12-29 00:12:25', 'Venta #60 - Lote LOTE-001-2025', 3, 1),
(60, 2, 'egreso', 1, '2025-12-29 00:12:25', 'Venta #60 - Lote LOTE-002-2025', 3, 2),
(61, 3, 'egreso', 3, '2025-12-29 00:13:01', 'Venta #61 - Lote 256-l', 3, 7),
(62, 4, 'egreso', 2, '2025-12-29 00:13:01', 'Venta #61 - Lote LOTE-004-2025', 3, 4),
(63, 3, 'egreso', 1, '2025-12-29 00:13:48', 'Venta #62 - Lote 256-l', 3, 7),
(64, 2, 'egreso', 2, '2025-12-29 00:13:48', 'Venta #62 - Lote LOTE-002-2025', 3, 2),
(65, 1, 'egreso', 1, '2025-12-29 17:17:25', 'Venta #63 - Lote LOTE-001-2025', 3, 1),
(66, 3, 'egreso', 4, '2025-12-29 17:18:44', 'Venta #64 - Lote 256-l', 3, 7),
(67, 4, 'egreso', 4, '2025-12-29 17:19:10', 'Venta #65 - Lote LOTE-004-2025', 3, 4),
(68, 1, 'egreso', 3, '2025-12-29 17:19:37', 'Venta #66 - Lote LOTE-001-2025', 3, 1),
(69, 4, 'egreso', 3, '2025-12-29 17:20:06', 'Venta #67 - Lote LOTE-004-2025', 3, 4),
(70, 4, 'egreso', 2, '2025-12-29 17:20:29', 'Venta #68 - Lote LOTE-004-2025', 3, 4),
(71, 1, 'egreso', 1, '2025-12-30 15:41:16', 'Venta #69 - Lote LOTE-001-2025', 3, 1),
(72, 1, 'egreso', 1, '2025-12-30 18:15:04', 'Venta #70 - Lote LOTE-001-2025', 3, 1),
(73, 2, 'egreso', 1, '2025-12-30 18:24:32', 'Venta #71 - Lote LOTE-002-2025', 3, 2),
(74, 4, 'egreso', 1, '2025-12-30 18:28:17', 'Venta #72 - Lote LOTE-004-2025', 3, 4),
(75, 3, 'egreso', 1, '2025-12-30 18:31:12', 'Venta #73 - Lote 256-l', 3, 7),
(76, 2, 'egreso', 2, '2026-01-01 14:25:46', 'Venta #74 - Lote LOTE-002-2025', 3, 2),
(77, 4, 'egreso', 4, '2026-01-01 14:26:35', 'Venta #75 - Lote LOTE-004-2025', 3, 4),
(78, 4, 'egreso', 2, '2026-01-01 14:27:29', 'Venta #76 - Lote LOTE-004-2025', 3, 4),
(79, 1, 'egreso', 2, '2026-01-01 14:38:48', 'Venta #77 - Lote LOTE-001-2025', 3, 1),
(80, 3, 'egreso', 2, '2026-01-01 14:39:12', 'Venta #78 - Lote 256-l', 3, 7),
(81, 2, 'egreso', 2, '2026-01-01 14:39:33', 'Venta #79 - Lote LOTE-002-2025', 3, 2),
(82, 1, 'egreso', 1, '2026-01-01 16:16:35', 'Venta #80 - Lote LOTE-001-2025', 3, 1),
(83, 1, 'egreso', 1, '2026-01-01 20:39:00', 'Venta #81 - Lote LOTE-001-2025', 3, 1),
(84, 2, 'egreso', 2, '2026-01-03 03:33:07', 'Venta #82 - Lote LOTE-002-2025', 3, 2),
(85, 1, 'egreso', 1, '2026-01-03 04:52:03', 'Venta #83 - Lote LOTE-001-2025', 3, 1),
(86, 1, 'egreso', 2, '2026-01-08 15:36:24', 'Venta #84 - Lote LOTE-001-2025', 3, 1),
(87, 2, 'egreso', 2, '2026-01-08 15:42:51', 'Venta #85 - Lote LOTE-002-2025', 3, 2),
(88, 3, 'egreso', 100, '2026-01-15 00:34:52', 'Venta #86 - Lote 256-l', 3, 7),
(89, 2, 'egreso', 3, '2026-01-16 01:13:05', 'Venta #87 - Lote LOTE-002-2025', 3, 2),
(90, 3, 'egreso', 2, '2026-01-16 01:19:25', 'Venta #88 - Lote 256-l', 3, 7),
(91, 1, 'egreso', 2, '2026-01-16 01:20:58', 'Venta #89 - Lote LOTE-001-2025', 3, 1),
(92, 3, 'egreso', 2, '2026-01-16 01:21:50', 'Venta #90 - Lote 256-l', 3, 7),
(93, 1, 'egreso', 2, '2026-01-16 01:30:04', 'Venta #91 - Lote LOTE-001-2025', 3, 1),
(94, 3, 'egreso', 2, '2026-01-16 01:30:39', 'Venta #92 - Lote 256-l', 3, 7),
(95, 3, 'egreso', 2, '2026-01-16 01:31:32', 'Venta #93 - Lote 256-l', 3, 7),
(96, 4, 'egreso', 2, '2026-01-16 01:32:28', 'Venta #94 - Lote LOTE-004-2025', 3, 4),
(97, 1, 'egreso', 2, '2026-01-16 04:54:59', 'Venta #95 - Lote LOTE-001-2025', 3, 1),
(98, 1, 'egreso', 2, '2026-01-16 04:55:53', 'Venta #96 - Lote LOTE-001-2025', 3, 1),
(99, 3, 'egreso', 2, '2026-01-16 04:59:58', 'Venta #97 - Lote 256-l', 3, 7),
(100, 1, 'egreso', 1, '2026-01-19 23:32:30', 'Venta #98 - Lote LOTE-001-2025', 3, 1),
(101, 1, 'egreso', 1, '2026-01-21 04:45:20', 'Venta #99 - Lote LOTE-001-2025', 3, 1),
(102, 4, 'egreso', 2, '2026-01-21 20:04:46', 'Venta #100 - Lote LOTE-004-2025', 3, 4),
(103, 2, 'egreso', 2, '2026-01-21 20:15:45', 'Venta #101 - Lote LOTE-002-2025', 3, 2),
(104, 4, 'egreso', 2, '2026-01-22 21:20:01', 'Venta #102 - Lote LOTE-004-2025', 3, 4),
(105, 3, 'egreso', 2, '2026-01-22 21:21:03', 'Venta #103 - Lote 256-l', 3, 7),
(106, 4, 'egreso', 3, '2026-01-26 17:44:47', 'Venta #104 - Lote LOTE-004-2025', 3, 4),
(107, 3, 'egreso', 2, '2026-01-27 02:18:45', 'Venta #105 - Lote 256-l', 3, 7),
(108, 3, 'egreso', 1, '2026-01-28 13:56:09', 'Venta #106 - Lote 256-l', 3, 7),
(109, 4, 'egreso', 1, '2026-01-28 13:56:47', 'Venta #107 - Lote LOTE-004-2025', 3, 4),
(110, 4, 'egreso', 1, '2026-01-28 13:57:40', 'Venta #108 - Lote LOTE-004-2025', 3, 4),
(111, 3, 'egreso', 1, '2026-01-28 13:58:11', 'Venta #109 - Lote 256-l', 3, 7),
(112, 1, 'egreso', 2, '2026-01-28 16:22:23', 'Venta #110 - Lote LOTE-001-2025', 3, 1),
(113, 3, 'egreso', 2, '2026-01-28 16:22:50', 'Venta #111 - Lote 256-l', 3, 7),
(114, 1, 'egreso', 1, '2026-01-28 16:23:30', 'Venta #112 - Lote LOTE-001-2025', 3, 1),
(115, 2, 'egreso', 2, '2026-01-28 16:24:10', 'Venta #113 - Lote LOTE-002-2025', 3, 2),
(127, 1, 'ingreso', 20, '2026-02-08 20:20:53', 'Ingreso - Bidón Agua Bella - 20 unidades', 3, 15),
(132, 1, 'ingreso', 20, '2026-02-11 19:05:30', 'Ingreso - Bidón Agua Bella - 20 unidades', 3, 18),
(133, 2, 'egreso', 400, '2026-02-11 19:07:54', 'Eliminación de lote VL-202512-366', 3, NULL),
(134, 1, 'egreso', 200, '2026-02-11 19:09:56', 'Eliminación de lote BL-202511-862', 3, NULL),
(135, 2, 'egreso', 100, '2026-02-11 19:12:46', 'Eliminación de lote L-202510', 3, NULL),
(136, 1, 'egreso', 41, '2026-02-11 19:13:23', 'Eliminación de lote LOTE-006-2025', 3, NULL),
(137, 1, 'egreso', 200, '2026-02-11 19:13:48', 'Eliminación de lote L-2025Z', 3, NULL),
(138, 2, 'ingreso', 100, '2026-02-11 19:15:21', 'Ingreso - Bidón Agua Viña - 100 unidades', 3, 19),
(139, 1, 'ingreso', 50, '2026-02-11 19:16:36', 'Ingreso - Bidón Agua Bella - 50 unidades', 3, 20),
(140, 3, 'egreso', 822, '2026-02-11 19:40:53', 'Eliminación de lote 256-l', 3, 7),
(141, 4, 'egreso', 115, '2026-02-11 19:42:24', 'Eliminación de lote LOTE-004-2025', 3, 4),
(142, 4, 'egreso', 3, '2026-02-11 23:07:47', 'Venta #120 - Lote LOTE-004-2025', 3, 4),
(143, 4, 'egreso', 2, '2026-02-13 19:01:59', 'Venta #121 - Lote LOTE-004-2025', 3, 4),
(144, 2, 'egreso', 2, '2026-02-14 17:09:03', 'Venta #122 - Lote LOTE-002-2025', 3, 2),
(145, 1, 'egreso', 1, '2026-02-25 01:58:52', 'Venta #123 - Lote LOTE-001-2025', 3, 1),
(146, 1, 'egreso', 2, '2026-02-25 20:26:17', 'Venta #124 - Lote LOTE-001-2025', 3, 1),
(147, 1, 'devolucion', 2, '2026-02-25 21:30:42', 'Devolución por cancelación de venta #124 - El cliente no tiene dinero para pagar - Lote LOTE-001-2025', 3, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pais`
--

CREATE TABLE `pais` (
  `id_pais` int(11) NOT NULL,
  `pais` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `pais`
--

INSERT INTO `pais` (`id_pais`, `pais`) VALUES
(1, 'Perú'),
(2, 'Chile'),
(3, 'Ecuador');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pedido_proveedor`
--

CREATE TABLE `pedido_proveedor` (
  `id_pedido` int(11) NOT NULL,
  `id_proveedor` int(11) NOT NULL,
  `fecha` date NOT NULL,
  `id_estado_pedido` int(11) NOT NULL,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_actualizacion` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `total` decimal(10,2) DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `pedido_proveedor`
--

INSERT INTO `pedido_proveedor` (`id_pedido`, `id_proveedor`, `fecha`, `id_estado_pedido`, `fecha_creacion`, `fecha_actualizacion`, `total`) VALUES
(2, 1, '2025-11-14', 5, '2025-11-14 19:07:37', '2025-11-19 16:22:27', 100.00),
(3, 2, '2025-11-17', 4, '2025-11-17 18:33:53', '2025-11-19 15:46:37', 50.00),
(5, 3, '2025-11-19', 5, '2025-11-19 15:11:53', '2025-11-19 15:15:57', 10.00),
(7, 1, '2025-11-19', 5, '2025-11-19 16:23:11', '2025-11-19 18:03:46', 300.00),
(8, 2, '2025-11-19', 4, '2025-11-19 16:24:39', '2025-11-19 18:03:04', 100.00),
(9, 4, '2025-11-19', 4, '2025-11-19 18:44:36', '2025-11-19 18:45:30', 20.00),
(10, 1, '2025-11-20', 5, '2025-11-20 15:29:44', '2026-02-14 17:02:07', 30.00),
(11, 5, '2025-11-24', 4, '2025-11-24 19:42:30', '2025-11-24 19:43:10', 8.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pedido_proveedor_detalle`
--

CREATE TABLE `pedido_proveedor_detalle` (
  `id_detalle` int(11) NOT NULL,
  `id_pedido` int(11) NOT NULL,
  `id_insumo` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `costo_unitario` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) GENERATED ALWAYS AS (`cantidad` * `costo_unitario`) STORED
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `pedido_proveedor_detalle`
--

INSERT INTO `pedido_proveedor_detalle` (`id_detalle`, `id_pedido`, `id_insumo`, `cantidad`, `costo_unitario`) VALUES
(1, 2, 4, 1000, 0.10),
(2, 3, 7, 100, 0.50),
(5, 5, 3, 100, 0.10),
(12, 8, 6, 1000, 0.10),
(16, 7, 4, 1500, 0.20),
(17, 9, 4, 50, 0.20),
(18, 9, 7, 50, 0.20),
(19, 10, 5, 100, 0.10),
(20, 10, 6, 100, 0.20),
(21, 11, 7, 20, 0.20),
(22, 11, 4, 20, 0.20);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `persona`
--

CREATE TABLE `persona` (
  `id_persona` int(11) NOT NULL,
  `tipo_documento` enum('DNI','RUC','CE','NO_ESPECIFICADO') NOT NULL DEFAULT 'NO_ESPECIFICADO',
  `numero_documento` varchar(20) DEFAULT NULL,
  `nombre_completo` varchar(200) NOT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `direccion` varchar(200) DEFAULT NULL,
  `coordenadas` varchar(100) DEFAULT NULL,
  `activo` tinyint(1) DEFAULT 1,
  `fecha_registro` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `persona`
--

INSERT INTO `persona` (`id_persona`, `tipo_documento`, `numero_documento`, `nombre_completo`, `telefono`, `direccion`, `coordenadas`, `activo`, `fecha_registro`) VALUES
(1, 'DNI', '70123456', 'Juan Pérez', '912345678', 'Av. Principal 123', NULL, 1, '2025-10-18 20:18:44'),
(2, 'DNI', '70876543', 'María García', '912867430', 'JC4P+3MJ Pucallpa', '', 1, '2025-10-18 20:18:44'),
(3, 'DNI', '71234567', 'Carlos López', '934210987', 'Jr. Union 789', NULL, 1, '2025-10-18 20:18:44'),
(4, 'RUC', '20123456789', 'Proveedor Agua Pura SAC', '945678321', 'Av. Industrial 123', NULL, 1, '2025-10-18 20:18:44'),
(5, 'RUC', '20123456788', 'Insumos Beverage Perú', '976543210', 'Calle Los Olivos 456', NULL, 1, '2025-10-18 20:18:44'),
(6, 'DNI', '70000001', 'Administrador Sistema', '997654321', 'Dirección Admin', NULL, 1, '2025-10-18 20:18:44'),
(7, 'DNI', '77722728', 'Axel Leandro Cohen Panduro', '959203847', 'Av. Mercado 111', '-12.046374,-77.042793', 1, '2025-10-18 20:18:44'),
(8, 'RUC', '20111111111', 'Restaurante La Olla SAC', '947331209', 'JC7M+JHQ, Pucallpa', '-12.046374,-77.042793', 1, '2025-10-18 20:18:44'),
(9, 'DNI', '44443222', 'Diego Fabricio Chavarry Macuyama', '986472315', 'Jr. Deportes 333', '-12.046374,-77.042793', 1, '2025-10-18 20:18:44'),
(10, 'DNI', '61430576', 'Rodrigo Eduardo Meza Lomas', '918711805', 'Av. Bellavista 1055', NULL, 1, '2025-10-23 03:39:46'),
(11, 'DNI', '83819371', 'michel ', '982638432', 'Jr.los cedros', '-12.2652765,-76.8639302', 1, '2025-10-26 22:28:02'),
(12, 'DNI', '73910292', 'Luis Torres Paredes', '982837932', 'jr.los mangos ms 3 lt 2', NULL, 1, '2025-10-26 22:34:51'),
(13, 'DNI', '76162729', 'Paolo Cesar Fumachi Lopez', '961739701', 'JC2H+CX4 Pucallpa', '', 1, '2025-10-28 03:36:35'),
(16, 'DNI', '72839299', 'Leydi', '965068226', 'av.urbanizacion', '', 1, '2025-11-06 14:56:45'),
(20, 'DNI', '71938290', 'Dennys gongora Farina', '988728323', 'Jr.28 de julio', NULL, 1, '2025-11-10 14:18:04'),
(21, 'DNI', '72621231', 'Elizabeth lopez', '917566979', 'jr.los naranjanos', NULL, 1, '2025-11-10 15:32:34'),
(22, 'DNI', '72829020', 'Jose manuela Rojas Panduro', '988172822', 'av. centenario 300', '', 1, '2025-11-10 15:33:37'),
(23, 'DNI', '71312341', 'Felix Reategui Lopez', '924121212', 'av.tupac amaru ', NULL, 1, '2025-11-10 15:37:16'),
(24, 'DNI', '89717222', 'Julio Carlos Santillama', '945232411', 'jr.las flores mz.12 lt.5', NULL, 1, '2025-11-10 16:18:00'),
(25, 'NO_ESPECIFICADO', 'TEMP-1762791727082-y', 'Cristiano Ronaldo dos Santos Aveiro', '927810192', 'Av. Centenario 524, Pucallpa 25000', NULL, 1, '2025-11-10 16:22:07'),
(26, 'DNI', '72022898', 'Raul Murrieta ', '928393833', 'jr.urubamba ', NULL, 1, '2025-11-12 17:28:01'),
(27, 'RUC', '00127827292', 'Ernesto Gabriel Rengifo Lopez', '978292229', 'JC3J+8MF, Jirón Antonio Vásquez R., Pucallpa 25002', NULL, 1, '2025-11-12 18:16:13'),
(28, 'NO_ESPECIFICADO', 'TEMP-1763574715329-i', 'Luciana Canesa', '982938828', 'AV. Los cedros mz.b lt.5', NULL, 1, '2025-11-19 17:51:55'),
(29, 'DNI', '42288795', 'raul portugal padilla', '930613571', 'urb. imosa mz.A lt.9', NULL, 1, '2025-11-19 18:13:02'),
(30, 'RUC', '203992828922', 'Agua Manantial S.A.C', '989392892', 'jr.macisea', NULL, 1, '2025-11-19 18:42:45'),
(31, 'NO_ESPECIFICADO', 'TEMP-1763941724191-q', 'miguel angel', '934734256', 'Hospital II Ramón Castilla', NULL, 1, '2025-11-23 23:48:44'),
(32, 'RUC', '203330209223', 'Agua Manantial pucallpa', '983923432', 'jr.centenario 504', NULL, 1, '2025-11-24 19:41:15'),
(33, 'DNI', '72235341', 'Miguel Angel Velazques Rosas', '939702033', 'Jr.Los cedros mz.A lt.3', NULL, 1, '2025-12-28 15:57:15');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto`
--

CREATE TABLE `producto` (
  `id_producto` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `id_categoria` int(11) DEFAULT NULL,
  `id_marca` int(11) NOT NULL,
  `presentacion` varchar(50) DEFAULT NULL,
  `volumen` varchar(20) DEFAULT NULL,
  `precio` decimal(10,2) NOT NULL,
  `stock` int(11) DEFAULT 0,
  `stock_minimo` int(11) DEFAULT 0,
  `id_pais_origen` int(11) DEFAULT NULL,
  `descripcion` text DEFAULT NULL,
  `activo` tinyint(1) DEFAULT 1,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `producto`
--

INSERT INTO `producto` (`id_producto`, `nombre`, `id_categoria`, `id_marca`, `presentacion`, `volumen`, `precio`, `stock`, `stock_minimo`, `id_pais_origen`, `descripcion`, `activo`, `fecha_creacion`) VALUES
(1, 'Bidón Agua Bella', 1, 1, 'Bidón', '20L', 4.00, 149, 20, 1, 'Agua purificada en práctico bidón, ideal para el consumo diario y mantener una hidratación saludable.', 1, '2025-10-18 20:18:44'),
(2, 'Bidón Agua Viña', 1, 2, 'Bidón', '20L', 4.50, 151, 15, 1, 'Agua natural de excelente pureza en bidón, perfecta para el hogar o la oficina.', 1, '2025-10-18 20:18:44'),
(3, 'Paquete de Botella Agua Bella', 2, 1, 'Botella PET', '650ml', 6.00, 0, 50, 1, 'Pack de botellas de agua pura y ligera, ideal para llevar a cualquier lugar.', 1, '2025-10-18 20:18:44'),
(4, 'Paquete de Botella Agua Viña', 2, 2, 'Botella PET', '600ml', 7.50, 110, 30, 1, 'Pack de agua natural en botellas individuales, refrescante y de gran calidad.', 1, '2025-10-18 20:18:44');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `proveedor`
--

CREATE TABLE `proveedor` (
  `id_proveedor` int(11) NOT NULL,
  `id_persona` int(11) NOT NULL,
  `razon_social` varchar(200) NOT NULL,
  `activo` tinyint(1) DEFAULT 1,
  `fecha_registro` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `proveedor`
--

INSERT INTO `proveedor` (`id_proveedor`, `id_persona`, `razon_social`, `activo`, `fecha_registro`) VALUES
(1, 4, 'Proveedor Agua Pura SAC', 1, '2025-10-18 20:18:44'),
(2, 5, 'Insumos Beverage Perú', 1, '2025-10-18 20:18:44'),
(3, 26, 'Agua y Vida sac', 1, '2025-11-12 17:28:01'),
(4, 30, 'Manantial ', 1, '2025-11-19 18:42:45'),
(5, 32, 'Manantial pucallpa', 1, '2025-11-24 19:41:15');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `provincia`
--

CREATE TABLE `provincia` (
  `id_provincia` int(11) NOT NULL,
  `provincia` varchar(100) NOT NULL,
  `id_departamento` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `provincia`
--

INSERT INTO `provincia` (`id_provincia`, `provincia`, `id_departamento`) VALUES
(1, 'Lima', 1),
(2, 'Huaura', 1),
(3, 'Cañete', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `repartidor`
--

CREATE TABLE `repartidor` (
  `id_repartidor` int(11) NOT NULL,
  `id_persona` int(11) NOT NULL,
  `placa_furgon` varchar(20) DEFAULT NULL,
  `activo` tinyint(1) DEFAULT 1,
  `fecha_contratacion` date DEFAULT NULL,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `repartidor`
--

INSERT INTO `repartidor` (`id_repartidor`, `id_persona`, `placa_furgon`, `activo`, `fecha_contratacion`, `fecha_creacion`) VALUES
(1, 1, 'ABC-123', 1, '2024-01-15', '2025-10-18 20:18:44'),
(2, 2, 'DEF-456', 1, '2024-02-01', '2025-10-18 20:18:44'),
(3, 3, 'GHI-789', 1, '2024-01-20', '2025-10-18 20:18:44');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rol`
--

CREATE TABLE `rol` (
  `id_rol` int(11) NOT NULL,
  `rol` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `rol`
--

INSERT INTO `rol` (`id_rol`, `rol`) VALUES
(1, 'Administrador'),
(2, 'Vendedor'),
(3, 'Repartidor'),
(4, 'Almacenero');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sistema_bitacora`
--

CREATE TABLE `sistema_bitacora` (
  `id_bitacora` int(11) NOT NULL,
  `modulo` varchar(50) NOT NULL,
  `accion` varchar(50) NOT NULL,
  `descripcion` text NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `id_referencia` int(11) DEFAULT NULL,
  `fecha_registro` timestamp NOT NULL DEFAULT current_timestamp(),
  `ip_origen` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `sistema_bitacora`
--

INSERT INTO `sistema_bitacora` (`id_bitacora`, `modulo`, `accion`, `descripcion`, `id_usuario`, `id_referencia`, `fecha_registro`, `ip_origen`, `user_agent`) VALUES
(1, 'entregas_dinero', 'registro', 'Repartidor Juan Pérez entregó S/ 600 (efectivo)', 8, 1, '2025-12-28 20:45:45', NULL, NULL),
(2, 'entregas_dinero', 'registro', 'Repartidor Carlos López entregó S/ 53.5 (efectivo)', 10, 2, '2025-12-28 22:03:19', NULL, NULL),
(3, 'entregas_dinero', 'registro', 'Repartidor Juan Pérez entregó S/ 1110.5 (efectivo)', 8, 4, '2025-12-29 01:39:32', NULL, NULL),
(4, 'entregas_dinero', 'registro', 'Repartidor Juan Pérez entregó S/ 1110.5 (efectivo)', 8, 5, '2025-12-29 01:40:22', NULL, NULL),
(5, 'entregas_dinero', 'registro', 'Repartidor Juan Pérez entregó S/ 4 (efectivo)', 8, 1, '2025-12-31 00:19:40', NULL, NULL),
(6, 'entregas_dinero', 'registro', 'Repartidor Carlos López entregó S/ 54 (efectivo)', 10, 2, '2026-01-01 14:36:27', NULL, NULL),
(7, 'entregas_dinero', 'registro', 'Repartidor Carlos López entregó S/ 4 (efectivo)', 10, 3, '2026-01-01 16:18:50', NULL, NULL),
(8, 'entregas_dinero', 'registro', 'Repartidor Juan Pérez entregó S/ 29 (efectivo)', 8, 4, '2026-01-01 19:14:57', NULL, NULL),
(9, 'entregas_dinero', 'registro', 'Repartidor María García entregó S/ 4 (efectivo)', 11, 5, '2026-01-01 20:41:34', NULL, NULL),
(10, 'entregas_dinero', 'registro', 'Repartidor Juan Pérez entregó S/ 29 (efectivo)', 8, 6, '2026-01-01 21:01:59', NULL, NULL),
(11, 'entregas_dinero', 'registro', 'Repartidor Carlos López entregó S/ 58 (efectivo)', 10, 7, '2026-01-01 22:04:15', NULL, NULL),
(12, 'entregas_dinero', 'registro', 'Repartidor Juan Pérez entregó S/ 9 (efectivo)', 8, 8, '2026-01-03 03:38:35', NULL, NULL),
(13, 'entregas_dinero', 'regularizacion', 'Repartidor Juan Pérez regularizó entrega pendiente de 2026-01-02 - S/ 4', 8, 9, '2026-01-07 18:01:50', NULL, NULL),
(14, 'entregas_dinero', 'regularizacion', 'Repartidor Juan Pérez regularizó entrega pendiente de 2025-12-30 - S/ 4', 8, 10, '2026-01-07 18:07:38', NULL, NULL),
(15, 'entregas_dinero', 'regularizacion', 'Repartidor Juan Pérez regularizó entrega pendiente de 2025-12-29 - S/ 37.5', 8, 12, '2026-01-07 18:10:27', NULL, NULL),
(16, 'entregas_dinero', 'regularizacion', 'Repartidor Juan Pérez regularizó entrega pendiente de 2025-12-28 - S/ 656.5', 8, 11, '2026-01-07 18:10:27', NULL, NULL),
(17, 'entregas_dinero', 'registro', 'Repartidor María García entregó S/ 76.5 (efectivo)', 11, 13, '2026-01-07 18:49:02', NULL, NULL),
(18, 'entregas_dinero', 'regularizacion', 'Repartidor María García regularizó entrega pendiente de 2025-12-30 - S/ 12', 11, 14, '2026-01-08 01:25:42', NULL, NULL),
(19, 'entregas_dinero', 'entrega_completa', 'Repartidor María García entregó TODO el dinero pendiente (S/ 64.5) incluyendo días anteriores.', 11, 15, '2026-01-08 01:27:20', NULL, NULL),
(20, 'entregas_dinero', 'entrega_completa', 'Repartidor María García entregó TODO el dinero pendiente (S/ 64.5) incluyendo días anteriores.', 11, 16, '2026-01-08 02:37:12', NULL, NULL),
(21, 'entregas_dinero', 'registro_con_ventas', 'Repartidor María García registró entrega tipo \"completa_anterior\" por S/ 64.5', 11, 17, '2026-01-08 13:34:00', NULL, NULL),
(22, 'entregas_dinero', 'regularizacion', 'Repartidor Carlos López regularizó entrega pendiente de 2025-12-17 - S/ 12', 10, 19, '2026-01-08 15:33:22', NULL, NULL),
(23, 'entregas_dinero', 'regularizacion', 'Repartidor Carlos López regularizó entrega pendiente de 2025-12-19 - S/ 12', 10, 22, '2026-01-08 15:33:22', NULL, NULL),
(24, 'entregas_dinero', 'regularizacion', 'Repartidor Carlos López regularizó entrega pendiente de 2025-12-28 - S/ 53.5', 10, 21, '2026-01-08 15:33:22', NULL, NULL),
(25, 'entregas_dinero', 'regularizacion', 'Repartidor Carlos López regularizó entrega pendiente de 2025-11-23 - S/ 14', 10, 18, '2026-01-08 15:33:22', NULL, NULL),
(26, 'entregas_dinero', 'regularizacion', 'Repartidor Carlos López regularizó entrega pendiente de 2025-12-30 - S/ 10', 10, 23, '2026-01-08 15:33:22', NULL, NULL),
(27, 'entregas_dinero', 'regularizacion', 'Repartidor Carlos López regularizó entrega pendiente de 2025-12-29 - S/ 16', 10, 20, '2026-01-08 15:33:22', NULL, NULL),
(28, 'entregas_dinero', 'registro', 'Repartidor María García entregó S/ 9 (efectivo)', 11, 24, '2026-01-09 04:20:27', NULL, NULL),
(29, 'entregas_dinero', 'regularizacion', 'Repartidor Carlos López regularizó entrega pendiente de 2026-01-08 - S/ 8', 10, 25, '2026-01-09 06:54:41', NULL, NULL),
(30, 'entregas_dinero', 'registro', 'Repartidor Carlos López entregó S/ 600 (efectivo)', 10, 26, '2026-01-15 00:57:35', NULL, NULL),
(31, 'entregas_dinero', 'registro', 'Repartidor Carlos López entregó S/ 13.5 (efectivo)', 10, 27, '2026-01-16 01:43:14', NULL, NULL),
(32, 'entregas_dinero', 'registro', 'Repartidor Juan Pérez entregó S/ 20 (efectivo)', 8, 28, '2026-01-16 01:45:33', NULL, NULL),
(33, 'entregas_dinero', 'registro', 'Repartidor María García entregó S/ 12 (efectivo)', 11, 29, '2026-01-16 01:46:13', NULL, NULL),
(34, 'entregas_dinero', 'regularizacion', 'Repartidor María García regularizó entrega pendiente de 2026-01-15 - S/ 12', 11, 30, '2026-01-16 05:05:34', NULL, NULL),
(35, 'entregas_dinero', 'regularizacion', 'Repartidor María García regularizó entrega pendiente de 2026-01-08 - S/ 9', 11, 31, '2026-01-16 05:08:37', NULL, NULL),
(36, 'entregas_dinero', 'regularizacion', 'Repartidor Juan Pérez regularizó entrega pendiente de 2026-01-15 - S/ 20', 8, 32, '2026-01-18 19:54:08', NULL, NULL),
(37, 'entregas_dinero', 'regularizacion', 'Repartidor María García regularizó entrega pendiente de 2026-01-15 - S/ 20', 11, 33, '2026-01-18 19:54:56', NULL, NULL),
(38, 'entregas_dinero', 'registro', 'Repartidor Carlos López entregó S/ 4 (efectivo)', 10, 34, '2026-01-20 01:57:35', NULL, NULL),
(39, 'entregas_dinero', 'regularizacion', 'Repartidor Carlos López regularizó entrega pendiente de 2026-01-19 - S/ 4', 10, 35, '2026-01-21 04:33:22', NULL, NULL),
(40, 'entregas_dinero', 'regularizacion', 'Repartidor Carlos López regularizó entrega pendiente de 2026-01-15 - S/ 12', 10, 36, '2026-01-21 04:40:58', NULL, NULL),
(41, 'entregas_dinero', 'regularizacion', 'Repartidor Carlos López regularizó entrega pendiente de 2026-01-19 - S/ 4', 10, 37, '2026-01-21 04:41:36', NULL, NULL),
(42, 'entregas_dinero', 'registro', 'Repartidor Carlos López entregó S/ 4 (efectivo)', 10, 38, '2026-01-21 04:50:06', NULL, NULL),
(43, 'entregas_dinero', 'registro', 'Repartidor María García entregó S/ 15 (efectivo)', 11, 39, '2026-01-21 20:07:25', NULL, NULL),
(44, 'entregas_dinero', 'registro', 'Repartidor Carlos López entregó S/ 9 (efectivo)', 10, 40, '2026-01-21 20:21:08', NULL, NULL),
(45, 'entregas_dinero', 'registro', 'Repartidor Carlos López entregó S/ 34.5 (efectivo)', 10, 41, '2026-01-27 02:30:03', NULL, NULL),
(46, 'entregas_dinero', 'registro', 'Repartidor Carlos López entregó S/ 21 (efectivo)', 10, 42, '2026-01-29 00:45:17', NULL, NULL),
(47, 'entregas_dinero', 'registro', 'Repartidor Carlos López entregó S/ 22.5 (efectivo)', 10, 43, '2026-02-11 23:39:04', NULL, NULL),
(48, 'entregas_dinero', 'regularizacion', 'Repartidor Juan Pérez regularizó entrega pendiente de 2025-10-22 - S/ 8', 8, 45, '2026-02-13 19:02:36', NULL, NULL),
(49, 'entregas_dinero', 'regularizacion', 'Repartidor Juan Pérez regularizó entrega pendiente de 2025-10-21 - S/ 25.5', 8, 44, '2026-02-13 19:02:36', NULL, NULL),
(50, 'entregas_dinero', 'regularizacion', 'Repartidor Juan Pérez regularizó entrega pendiente de 2025-11-01 - S/ 60', 8, 46, '2026-02-13 19:02:36', NULL, NULL),
(51, 'entregas_dinero', 'regularizacion', 'Repartidor Juan Pérez regularizó entrega pendiente de 2025-11-09 - S/ 64', 8, 47, '2026-02-13 19:02:36', NULL, NULL),
(52, 'entregas_dinero', 'regularizacion', 'Repartidor Juan Pérez regularizó entrega pendiente de 2025-11-10 - S/ 51', 8, 48, '2026-02-13 19:03:36', NULL, NULL),
(53, 'entregas_dinero', 'regularizacion', 'Repartidor Juan Pérez regularizó entrega pendiente de 2025-12-18 - S/ 12', 8, 49, '2026-02-13 19:05:34', NULL, NULL),
(54, 'entregas_dinero', 'regularizacion', 'Repartidor Juan Pérez regularizó entrega pendiente de 2025-12-05 - S/ 30', 8, 50, '2026-02-13 19:06:14', NULL, NULL),
(55, 'entregas_dinero', 'regularizacion', 'Repartidor Juan Pérez regularizó entrega pendiente de 2025-12-17 - S/ 15', 8, 51, '2026-02-13 19:06:14', NULL, NULL),
(56, 'entregas_dinero', 'regularizacion', 'Repartidor Juan Pérez regularizó entrega pendiente de 2025-12-03 - S/ 600', 8, 53, '2026-02-13 19:06:46', NULL, NULL),
(57, 'entregas_dinero', 'regularizacion', 'Repartidor Juan Pérez regularizó entrega pendiente de 2025-11-24 - S/ 12', 8, 52, '2026-02-13 19:06:46', NULL, NULL),
(58, 'entregas_dinero', 'regularizacion', 'Repartidor Juan Pérez regularizó entrega pendiente de 2025-11-12 - S/ 4', 8, 54, '2026-02-13 19:07:20', NULL, NULL),
(59, 'entregas_dinero', 'regularizacion', 'Repartidor Juan Pérez regularizó entrega pendiente de 2025-11-13 - S/ 24', 8, 55, '2026-02-13 19:07:20', NULL, NULL),
(60, 'entregas_dinero', 'regularizacion', 'Repartidor Juan Pérez regularizó entrega pendiente de 2025-11-17 - S/ 4', 8, 56, '2026-02-13 19:07:20', NULL, NULL),
(61, 'entregas_dinero', 'regularizacion', 'Repartidor Juan Pérez regularizó entrega pendiente de 2025-11-19 - S/ 70', 8, 57, '2026-02-13 19:07:20', NULL, NULL),
(62, 'entregas_dinero', 'regularizacion', 'Repartidor Juan Pérez regularizó entrega pendiente de 2025-11-23 - S/ 74.5', 8, 58, '2026-02-13 19:07:20', NULL, NULL),
(63, 'entregas_dinero', 'regularizacion', 'Repartidor Carlos López regularizó entrega pendiente de 2026-02-13 - S/ 15', 10, 59, '2026-02-14 17:08:13', NULL, NULL),
(64, 'entregas_dinero', 'regularizacion', 'Repartidor Carlos López regularizó entrega pendiente de 2026-02-14 - S/ 9', 10, 60, '2026-02-17 18:09:40', NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sunat_configuracion`
--

CREATE TABLE `sunat_configuracion` (
  `id_config` int(11) NOT NULL,
  `ruc` varchar(11) NOT NULL,
  `nombre_empresa` varchar(255) NOT NULL,
  `direccion` varchar(500) DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `serie_boleta` varchar(10) NOT NULL DEFAULT '0001',
  `serie_factura` varchar(10) NOT NULL DEFAULT '0001',
  `usuario_sunat` varchar(100) DEFAULT NULL,
  `usuario_sol` varchar(100) DEFAULT NULL,
  `ambiente` varchar(20) DEFAULT 'pruebas' COMMENT 'pruebas o produccion',
  `activo` tinyint(1) DEFAULT 1,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_actualizacion` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `sunat_configuracion`
--

INSERT INTO `sunat_configuracion` (`id_config`, `ruc`, `nombre_empresa`, `direccion`, `telefono`, `email`, `serie_boleta`, `serie_factura`, `usuario_sunat`, `usuario_sol`, `ambiente`, `activo`, `fecha_creacion`, `fecha_actualizacion`) VALUES
(1, '20612278815', 'GENERAL SERVICE VIÑA E.I.R.L.', 'OTR.PRIMAVERA MZA. 25 LOTE. 1 A.H. PRIMAVERA', NULL, NULL, '0001', '0001', NULL, NULL, 'pruebas', 1, '2025-12-05 03:01:02', '2025-12-05 03:01:02');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tracking_ubicacion`
--

CREATE TABLE `tracking_ubicacion` (
  `id_tracking` int(11) NOT NULL,
  `id_repartidor` int(11) NOT NULL,
  `id_venta` int(11) DEFAULT NULL,
  `latitud` decimal(10,8) NOT NULL,
  `longitud` decimal(11,8) NOT NULL,
  `velocidad` decimal(5,2) DEFAULT NULL,
  `precision_gps` decimal(5,2) DEFAULT NULL,
  `bateria_nivel` int(11) DEFAULT NULL,
  `timestamp_gps` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `id_usuario` int(11) NOT NULL,
  `nombre_usuario` varchar(100) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `id_rol` int(11) NOT NULL,
  `id_persona` int(11) NOT NULL,
  `activo` tinyint(1) DEFAULT 1,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_actualizacion` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`id_usuario`, `nombre_usuario`, `email`, `password`, `id_rol`, `id_persona`, `activo`, `fecha_creacion`, `fecha_actualizacion`) VALUES
(3, 'admin', 'admin@sistemaagua.com', '$2b$10$/0flwtx54/nkPXRbYEiOA.0uijO7K/bIq/osaG8HScJkFbek/UNf.', 1, 6, 1, '2025-10-21 01:38:47', '2025-11-19 13:44:04'),
(5, 'rodre', 'rrodrigomzls@gmail.com', '$2b$10$kvuSSdCSEu/pnm4dqUt.aev2dKK0pcUsreHNtoPWNGtP.lqSN9oNG', 2, 10, 1, '2025-10-23 03:42:18', '2025-10-28 14:40:00'),
(6, 'Paolo', 'cesarfumachi2002@gmail.com', '$2b$10$8veD/rOo2O8OUiAV2ZzcA.qRWXS2SehRvgTARvH5gs8h4.ASVN8Jy', 2, 13, 1, '2025-10-28 03:36:35', '2025-12-03 13:55:24'),
(8, 'Juan', 'juan@gmail.com', '$2b$10$32yxolacpgqblM0RaiSF9OYyyz3L7SjhFjZ19gt1Xw5FRZlwxiLlC', 3, 1, 1, '2025-10-31 21:23:33', '2025-12-23 17:21:39'),
(9, 'Leydi', 'Leydi@gmail.com', '$2b$10$MGGDaEKFnDHAREhlRpXg8uLDp142golIU3vf6zaPA4idL2ZVktyFG', 4, 16, 1, '2025-11-06 14:57:55', '2025-12-23 16:52:41'),
(10, 'Carlos', 'Carlos2023@gmail.com', '$2b$10$xAXh8WHUmNYldm42u8id.ulJsDrofTaVkcdFox4R7lMoi9iz1ZUfq', 3, 3, 1, '2025-11-24 00:56:20', '2025-11-24 00:56:20'),
(11, 'Maria', 'maria34suta@gmail.com', '$2b$10$J63Ut0EIWZMAMeZeTEdII.K0YzqQm6WE1AbJ5GO55v4K/5CMJdie6', 3, 2, 1, '2025-12-17 14:35:43', '2025-12-17 14:35:43');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `venta`
--

CREATE TABLE `venta` (
  `id_venta` int(11) NOT NULL,
  `id_cliente` int(11) NOT NULL,
  `fecha` date NOT NULL,
  `hora` time DEFAULT NULL,
  `total` decimal(10,2) NOT NULL,
  `id_metodo_pago` int(11) NOT NULL,
  `id_estado_venta` int(11) NOT NULL,
  `id_repartidor` int(11) DEFAULT NULL,
  `id_vendedor` int(11) DEFAULT NULL,
  `notas` text DEFAULT NULL,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_actualizacion` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `fecha_inicio_ruta` datetime DEFAULT NULL,
  `fecha_fin_ruta` datetime DEFAULT NULL,
  `ubicacion_inicio_ruta` varchar(255) DEFAULT NULL,
  `tracking_activo` tinyint(1) DEFAULT 0,
  `comprobante_emitido` tinyint(1) DEFAULT 0,
  `tipo_comprobante_solicitado` varchar(20) DEFAULT NULL COMMENT 'FACTURA, BOLETA, SIN_COMPROBANTE'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `venta`
--

INSERT INTO `venta` (`id_venta`, `id_cliente`, `fecha`, `hora`, `total`, `id_metodo_pago`, `id_estado_venta`, `id_repartidor`, `id_vendedor`, `notas`, `fecha_creacion`, `fecha_actualizacion`, `fecha_inicio_ruta`, `fecha_fin_ruta`, `ubicacion_inicio_ruta`, `tracking_activo`, `comprobante_emitido`, `tipo_comprobante_solicitado`) VALUES
(2, 3, '2025-10-21', '10:20:05', 8.50, 1, 7, NULL, 3, 'Se vendio un bidon de agua.', '2025-10-21 15:20:05', '2025-12-16 03:44:25', NULL, NULL, NULL, 0, 1, NULL),
(3, 1, '2025-10-21', '15:38:08', 17.00, 1, 7, 1, 3, 'hsghad', '2025-10-21 20:38:08', '2025-11-03 19:59:25', NULL, NULL, NULL, 0, 0, NULL),
(4, 1, '2025-10-21', '22:52:17', 8.50, 1, 7, 1, 3, '', '2025-10-22 03:52:17', '2025-11-08 21:19:37', NULL, NULL, NULL, 0, 0, NULL),
(5, 4, '2025-10-22', '23:37:32', 8.00, 2, 7, 1, 3, '', '2025-10-23 04:37:32', '2025-11-08 21:19:41', NULL, NULL, NULL, 0, 0, NULL),
(6, 2, '2025-11-01', '16:41:52', 60.00, 1, 7, 1, 5, '', '2025-11-01 21:41:52', '2025-11-08 21:19:45', NULL, NULL, NULL, 0, 0, NULL),
(7, 6, '2025-11-01', '16:46:29', 4.00, 1, 8, 3, 5, ' CANCELACIÓN REPARTIDOR: 🚚 Problema con el vehículo de reparto', '2025-11-01 21:46:29', '2025-12-17 20:06:54', '2025-12-17 15:05:58', '2025-12-17 15:06:54', '-8.385828,-74.5587662', 0, 0, NULL),
(8, 3, '2025-11-03', '13:28:51', 18.00, 1, 8, 3, 6, '', '2025-11-03 18:28:51', '2025-11-03 18:32:12', NULL, NULL, NULL, 0, 0, NULL),
(9, 3, '2025-11-09', '16:13:58', 13.50, 1, 8, 1, 3, '', '2025-11-09 21:13:58', '2025-11-09 21:17:36', NULL, NULL, NULL, 0, 0, NULL),
(10, 3, '2025-11-09', '16:22:15', 22.00, 1, 7, 1, 5, '', '2025-11-09 21:22:15', '2025-11-22 05:38:39', '2025-11-22 00:35:43', NULL, '-8.404992,-74.5439232', 1, 0, NULL),
(11, 3, '2025-11-09', '16:39:24', 8.00, 1, 8, 1, 5, ' CANCELACIÓN REPARTIDOR: no se encuentra en domicilio', '2025-11-09 21:39:24', '2025-11-09 21:45:45', NULL, NULL, NULL, 0, 0, NULL),
(12, 6, '2025-11-09', '17:14:48', 24.00, 1, 7, 1, 5, '', '2025-11-09 22:14:48', '2025-11-22 06:12:40', '2025-11-22 00:51:43', '2025-11-22 01:12:40', '-8.404992,-74.5439232', 0, 0, NULL),
(13, 3, '2025-11-09', '17:17:07', 18.00, 1, 7, 1, 5, '', '2025-11-09 22:17:07', '2025-11-22 16:05:00', '2025-11-22 09:04:15', '2025-11-22 11:05:00', '-8.404992,-74.5439232', 0, 0, NULL),
(14, 11, '2025-11-10', '11:25:35', 51.00, 1, 7, 1, 3, '', '2025-11-10 16:25:35', '2025-11-12 17:23:52', NULL, NULL, NULL, 0, 0, NULL),
(28, 1, '2025-11-12', '15:58:44', 4.00, 1, 7, 1, 3, NULL, '2025-11-12 20:58:44', '2025-11-22 21:31:03', '2025-11-22 15:30:48', '2025-11-22 16:31:03', '-8.404992,-74.5439232', 0, 0, NULL),
(29, 12, '2025-11-13', '09:26:03', 24.00, 1, 7, 1, 3, NULL, '2025-11-13 14:26:03', '2025-11-22 20:15:50', '2025-11-22 15:02:30', '2025-11-22 15:15:50', '-8.404992,-74.5439232', 0, 0, NULL),
(30, 11, '2025-11-17', '15:57:25', 4.00, 1, 7, 1, 3, NULL, '2025-11-17 20:57:25', '2025-11-22 18:50:28', NULL, NULL, NULL, 0, 0, NULL),
(31, 13, '2025-11-19', '12:53:16', 60.00, 1, 7, 1, 3, NULL, '2025-11-19 17:53:16', '2025-11-19 17:56:43', NULL, NULL, NULL, 0, 0, NULL),
(32, 14, '2025-11-19', '13:13:41', 4.00, 1, 7, 1, 3, NULL, '2025-11-19 18:13:41', '2025-11-19 18:30:46', NULL, NULL, NULL, 0, 0, NULL),
(33, 1, '2025-11-19', '13:17:41', 6.00, 1, 7, 1, 3, NULL, '2025-11-19 18:17:41', '2025-11-22 18:37:31', '2025-11-22 13:14:53', '2025-11-22 13:37:31', '-8.404992,-74.5439232', 0, 0, NULL),
(34, 11, '2025-11-23', '13:26:24', 30.00, 1, 7, 1, 6, NULL, '2025-11-23 18:26:24', '2025-11-23 19:08:16', '2025-11-23 13:59:45', '2025-11-23 14:08:16', NULL, 0, 0, NULL),
(35, 7, '2025-11-23', '14:08:42', 24.00, 2, 7, 1, 6, NULL, '2025-11-23 19:08:42', '2025-11-26 05:15:35', '2025-11-23 14:09:04', '2025-11-26 00:15:35', '-8.4059961,-74.5814659', 0, 0, NULL),
(36, 3, '2025-11-23', '14:57:21', 4.00, 1, 7, 1, 6, NULL, '2025-11-23 19:57:21', '2025-12-02 19:20:13', '2025-11-23 14:57:45', '2025-12-02 14:20:13', '-8.4059961,-74.5814659', 0, 0, NULL),
(37, 10, '2025-11-23', '15:40:38', 6.00, 1, 7, 1, 6, NULL, '2025-11-23 20:40:38', '2025-11-24 20:02:26', '2025-11-23 15:41:07', '2025-11-24 15:02:26', '-8.4059961,-74.5814659', 0, 0, NULL),
(38, 3, '2025-11-23', '17:43:23', 4.50, 1, 7, 1, 6, NULL, '2025-11-23 22:43:23', '2025-11-23 22:46:55', '2025-11-23 17:43:52', '2025-11-23 17:46:55', '-12.075008,-77.021184', 0, 0, NULL),
(39, 3, '2025-11-23', '17:50:23', 6.00, 1, 7, 1, 6, NULL, '2025-11-23 22:50:23', '2025-12-14 21:13:52', '2025-11-23 17:58:57', '2025-11-23 18:00:39', '-8.3881305,-74.5668224', 0, 1, NULL),
(40, 1, '2025-11-23', '18:07:04', 9.00, 2, 8, 1, 6, ' CANCELACIÓN REPARTIDOR: 👤 Cliente no disponible en la dirección', '2025-11-23 23:07:04', '2025-12-17 16:06:17', NULL, NULL, NULL, 0, 0, NULL),
(41, 15, '2025-11-23', '18:49:52', 12.00, 2, 8, 1, 6, ' CANCELACIÓN REPARTIDOR: 👤 Cliente no disponible en la dirección', '2025-11-23 23:49:52', '2025-12-17 16:06:00', '2025-12-12 21:10:07', '2025-12-17 11:06:00', '-12.075008,-77.021184', 0, 0, NULL),
(42, 8, '2025-11-23', '19:49:14', 6.00, 1, 7, 3, 6, NULL, '2025-11-24 00:49:14', '2025-12-21 03:32:39', '2025-12-20 22:30:04', '2025-12-20 22:32:39', '-8.385828,-74.5587662', 0, 0, NULL),
(43, 12, '2025-11-23', '19:50:31', 8.00, 2, 7, 3, 6, NULL, '2025-11-24 00:50:31', '2025-12-16 03:10:24', '2025-11-23 19:57:53', '2025-12-10 21:53:03', '-12.075008,-77.021184', 0, 1, NULL),
(44, 3, '2025-11-24', '14:31:24', 12.00, 2, 7, 1, 6, NULL, '2025-11-24 19:31:24', '2025-12-16 03:04:55', '2025-11-24 14:33:20', '2025-11-24 14:35:49', '-8.3918551,-74.5538237', 0, 1, NULL),
(45, 15, '2025-12-02', '14:20:53', 24.00, 1, 8, 3, 6, ' CANCELACIÓN REPARTIDOR: ⚠️ Zona insegura para la entrega', '2025-12-02 19:20:53', '2025-12-21 03:31:55', NULL, NULL, NULL, 0, 0, NULL),
(46, 12, '2025-12-03', '08:56:19', 600.00, 1, 7, 1, 6, NULL, '2025-12-03 13:56:19', '2025-12-03 14:01:32', '2025-12-03 09:00:14', '2025-12-03 09:01:32', '-12.075008,-77.0244608', 0, 0, NULL),
(47, 11, '2025-12-04', '23:49:17', 4.50, 1, 8, 3, 3, ' CANCELACIÓN REPARTIDOR: 🚚 Problema con el vehículo de reparto', '2025-12-05 04:49:17', '2025-12-21 03:32:25', NULL, NULL, NULL, 0, 0, NULL),
(48, 1, '2025-12-05', '20:01:52', 4.50, 1, 8, 3, 3, ' CANCELACIÓN REPARTIDOR: 📍 Dirección incorrecta o inexistente', '2025-12-06 01:01:52', '2025-12-21 03:32:05', NULL, NULL, NULL, 0, 0, NULL),
(49, 7, '2025-12-05', '21:19:13', 30.00, 1, 7, 1, 6, NULL, '2025-12-06 02:19:13', '2025-12-06 02:21:12', '2025-12-05 21:20:01', '2025-12-05 21:21:12', '-8.391052,-74.5701546', 0, 0, NULL),
(50, 1, '2025-12-16', '22:54:28', 4.50, 1, 7, 2, 3, NULL, '2025-12-17 03:54:28', '2025-12-17 14:50:32', '2025-12-17 09:35:55', '2025-12-17 09:49:54', '-8.385828,-74.5587662', 0, 1, NULL),
(51, 12, '2025-12-17', '11:04:28', 15.00, 1, 8, 1, 3, ' CANCELACIÓN REPARTIDOR: 👤 Cliente no disponible en la dirección', '2025-12-17 16:04:28', '2025-12-17 16:06:11', NULL, NULL, NULL, 0, 0, NULL),
(52, 12, '2025-12-17', '11:07:08', 15.00, 1, 7, 1, 3, NULL, '2025-12-17 16:07:08', '2025-12-17 16:09:13', '2025-12-17 11:07:25', '2025-12-17 11:08:38', '-8.385828,-74.5587662', 0, 1, NULL),
(53, 10, '2025-12-17', '14:21:30', 12.00, 1, 7, 3, 3, NULL, '2025-12-17 19:21:30', '2025-12-17 19:48:02', '2025-12-17 14:43:58', '2025-12-17 14:47:02', '-8.385828,-74.5587662', 0, 1, 'BOLETA'),
(54, 1, '2025-12-17', '15:04:17', 10.50, 1, 8, 3, 3, ' CANCELACIÓN REPARTIDOR: ⏰ Horario de entrega inconveniente', '2025-12-17 20:04:17', '2025-12-21 03:32:16', NULL, NULL, NULL, 0, 0, 'SIN_COMPROBANTE'),
(55, 1, '2025-12-18', '00:31:50', 12.00, 1, 7, 1, 3, NULL, '2025-12-18 05:31:50', '2025-12-22 13:46:24', '2025-12-18 11:45:35', '2025-12-22 08:46:24', '-8.385828,-74.5587662', 0, 0, 'BOLETA'),
(56, 3, '2025-12-19', '13:01:35', 12.00, 2, 7, 3, 3, NULL, '2025-12-19 18:01:35', '2025-12-19 18:07:20', '2025-12-19 13:03:19', '2025-12-19 13:07:05', '-12.075008,-77.021184', 0, 1, 'BOLETA'),
(57, 10, '2025-12-20', '22:28:02', 6.00, 1, 7, 2, 3, NULL, '2025-12-21 03:28:02', '2025-12-29 00:05:39', '2025-12-20 22:34:53', '2025-12-28 19:05:39', '-8.385828,-74.5587662', 0, 0, 'BOLETA'),
(58, 16, '2025-12-28', '10:57:58', 600.00, 1, 7, 1, 3, NULL, '2025-12-28 15:57:58', '2025-12-28 18:03:02', '2025-12-28 11:01:49', '2025-12-28 13:03:02', '-8.3990359,-74.5698964', 0, 0, 'FACTURA'),
(59, 7, '2025-12-28', '13:02:09', 53.50, 1, 7, 3, 3, NULL, '2025-12-28 18:02:09', '2025-12-28 18:13:58', '2025-12-28 13:04:23', '2025-12-28 13:11:59', '-8.404992,-74.5340928', 0, 1, 'BOLETA'),
(60, 1, '2025-12-28', '19:12:25', 8.50, 2, 7, 1, 3, NULL, '2025-12-29 00:12:25', '2025-12-29 00:18:39', '2025-12-28 19:14:30', '2025-12-28 19:18:39', '-8.404992,-74.5340928', 0, 0, 'BOLETA'),
(61, 3, '2025-12-28', '19:13:01', 33.00, 1, 7, 1, 3, NULL, '2025-12-29 00:13:01', '2025-12-29 00:18:42', '2025-12-28 19:16:20', '2025-12-28 19:18:42', '-8.404992,-74.5340928', 0, 0, 'BOLETA'),
(62, 8, '2025-12-28', '19:13:48', 15.00, 1, 7, 1, 3, NULL, '2025-12-29 00:13:48', '2025-12-29 00:18:45', '2025-12-28 19:16:59', '2025-12-28 19:18:45', '-8.404992,-74.5340928', 0, 0, 'FACTURA'),
(63, 7, '2025-12-29', '12:17:25', 4.00, 1, 7, 3, 3, NULL, '2025-12-29 17:17:25', '2025-12-29 17:26:39', '2025-12-29 12:22:59', '2025-12-29 12:26:39', '-8.404992,-74.5340928', 0, 0, 'BOLETA'),
(64, 1, '2025-12-29', '12:18:44', 24.00, 2, 7, 2, 3, NULL, '2025-12-29 17:18:44', '2025-12-29 17:27:43', '2025-12-29 12:21:59', '2025-12-29 12:27:43', '-8.404992,-74.5340928', 0, 0, 'SIN_COMPROBANTE'),
(65, 3, '2025-12-29', '12:19:10', 30.00, 1, 7, 2, 3, NULL, '2025-12-29 17:19:10', '2025-12-29 17:27:46', '2025-12-29 12:23:27', '2025-12-29 12:27:46', '-8.404992,-74.5340928', 0, 0, 'BOLETA'),
(66, 10, '2025-12-29', '12:19:37', 12.00, 2, 7, 3, 3, NULL, '2025-12-29 17:19:37', '2025-12-29 17:26:45', '2025-12-29 12:23:05', '2025-12-29 12:26:45', '-8.404992,-74.5340928', 0, 0, 'BOLETA'),
(67, 12, '2025-12-29', '12:20:06', 22.50, 2, 7, 1, 3, NULL, '2025-12-29 17:20:06', '2025-12-29 18:27:53', '2025-12-29 12:21:35', '2025-12-29 13:27:53', '-8.404992,-74.5340928', 0, 0, 'BOLETA'),
(68, 3, '2025-12-29', '12:20:29', 15.00, 2, 7, 1, 3, NULL, '2025-12-29 17:20:29', '2025-12-29 18:28:05', '2025-12-29 12:22:34', '2025-12-29 13:28:05', '-8.404992,-74.5340928', 0, 0, 'BOLETA'),
(69, 1, '2025-12-30', '10:41:16', 4.00, 2, 7, 1, 3, NULL, '2025-12-30 15:41:16', '2025-12-30 16:43:29', '2025-12-30 11:41:04', '2025-12-30 11:43:29', '-8.404992,-74.5340928', 0, 0, 'BOLETA'),
(70, 7, '2025-12-30', '13:15:04', 4.00, 2, 7, 3, 3, NULL, '2025-12-30 18:15:04', '2025-12-30 18:22:41', '2025-12-30 13:15:25', '2025-12-30 13:22:41', '-8.404992,-74.5340928', 0, 0, 'BOLETA'),
(71, 11, '2025-12-30', '13:24:32', 4.50, 1, 7, 2, 3, NULL, '2025-12-30 18:24:32', '2025-12-30 18:27:23', '2025-12-30 13:25:09', '2025-12-30 13:27:23', '-8.404992,-74.5340928', 0, 0, 'BOLETA'),
(72, 8, '2025-12-30', '13:28:17', 7.50, 3, 7, 2, 3, NULL, '2025-12-30 18:28:17', '2025-12-30 18:29:58', '2025-12-30 13:28:41', '2025-12-30 13:29:58', '-8.404992,-74.5340928', 0, 0, 'BOLETA'),
(73, 12, '2025-12-30', '13:31:12', 6.00, 4, 7, 3, 3, NULL, '2025-12-30 18:31:12', '2025-12-30 18:33:34', '2025-12-30 13:31:27', '2025-12-30 13:33:34', '-8.404992,-74.5340928', 0, 0, 'BOLETA'),
(74, 13, '2026-01-01', '09:25:46', 9.00, 2, 7, 3, 3, NULL, '2026-01-01 14:25:46', '2026-01-01 14:32:56', '2026-01-01 09:27:54', '2026-01-01 09:32:56', '-8.3951616,-74.5373696', 0, 0, 'BOLETA'),
(75, 12, '2026-01-01', '09:26:35', 30.00, 2, 7, 3, 3, NULL, '2026-01-01 14:26:35', '2026-01-01 14:33:49', '2026-01-01 09:29:32', '2026-01-01 09:33:49', '-8.3951616,-74.5373696', 0, 0, 'FACTURA'),
(76, 9, '2026-01-01', '09:27:29', 15.00, 2, 7, 3, 3, NULL, '2026-01-01 14:27:29', '2026-01-01 14:35:28', '2026-01-01 09:30:54', '2026-01-01 09:35:28', '-8.3951616,-74.5373696', 0, 0, 'BOLETA'),
(77, 1, '2026-01-01', '09:38:48', 8.00, 2, 7, 1, 3, NULL, '2026-01-01 14:38:48', '2026-01-01 14:43:29', '2026-01-01 09:40:03', '2026-01-01 09:43:29', '-8.3951616,-74.5373696', 0, 0, 'BOLETA'),
(78, 11, '2026-01-01', '09:39:12', 12.00, 2, 7, 1, 3, NULL, '2026-01-01 14:39:12', '2026-01-01 14:43:33', '2026-01-01 09:40:06', '2026-01-01 09:43:33', '-8.3951616,-74.5373696', 0, 0, 'BOLETA'),
(79, 7, '2026-01-01', '09:39:33', 9.00, 2, 7, 1, 3, NULL, '2026-01-01 14:39:33', '2026-01-01 14:43:37', '2026-01-01 09:40:13', '2026-01-01 09:43:37', '-8.3951616,-74.5373696', 0, 0, 'BOLETA'),
(80, 1, '2026-01-01', '11:16:35', 4.00, 2, 7, 3, 3, NULL, '2026-01-01 16:16:35', '2026-01-01 16:18:16', '2026-01-01 11:16:52', '2026-01-01 11:18:16', '-8.3951616,-74.5373696', 0, 0, 'BOLETA'),
(81, 1, '2026-01-01', '15:39:00', 4.00, 2, 7, 2, 3, NULL, '2026-01-01 20:39:00', '2026-01-01 20:40:53', '2026-01-01 15:39:17', '2026-01-01 15:40:53', '-8.3951616,-74.5373696', 0, 0, 'BOLETA'),
(82, 1, '2026-01-02', '22:33:07', 9.00, 2, 7, 1, 3, NULL, '2026-01-03 03:33:07', '2026-01-03 03:34:53', '2026-01-02 22:33:29', '2026-01-02 22:34:53', '-8.3862877,-74.5807337', 0, 0, 'BOLETA'),
(83, 7, '2026-01-02', '23:52:03', 4.00, 2, 7, 1, 3, NULL, '2026-01-03 04:52:03', '2026-01-03 04:55:05', '2026-01-02 23:53:48', '2026-01-02 23:55:05', '-8.3988877,-74.5700519', 0, 0, 'BOLETA'),
(84, 1, '2026-01-08', '10:36:24', 8.00, 2, 7, 3, 3, NULL, '2026-01-08 15:36:24', '2026-01-08 15:38:09', '2026-01-08 10:36:41', '2026-01-08 10:38:09', '-8.3951616,-74.5537536', 0, 0, 'BOLETA'),
(85, 11, '2026-01-08', '10:42:51', 9.00, 2, 7, 2, 3, NULL, '2026-01-08 15:42:51', '2026-01-08 15:44:34', '2026-01-08 10:43:16', '2026-01-08 10:44:34', '-8.3951616,-74.5537536', 0, 0, 'BOLETA'),
(86, 16, '2026-01-14', '19:34:52', 600.00, 1, 7, 3, 3, NULL, '2026-01-15 00:34:52', '2026-01-15 00:52:19', '2026-01-14 19:42:25', '2026-01-14 19:52:19', '-8.399107697955861,-74.56964318468314', 0, 0, 'BOLETA'),
(87, 1, '2026-01-15', '20:13:05', 13.50, 1, 7, 3, 3, NULL, '2026-01-16 01:13:05', '2026-01-16 01:43:02', '2026-01-15 20:37:30', '2026-01-15 20:43:02', '-8.39900968610542,-74.56973026608308', 0, 0, 'SIN_COMPROBANTE'),
(88, 7, '2026-01-15', '20:19:25', 12.00, 2, 7, 1, 3, NULL, '2026-01-16 01:19:25', '2026-01-16 01:45:15', '2026-01-15 20:37:06', '2026-01-15 20:45:15', '-8.39900968610542,-74.56973026608308', 0, 0, 'SIN_COMPROBANTE'),
(89, 3, '2026-01-15', '20:20:58', 8.00, 1, 7, 1, 3, NULL, '2026-01-16 01:20:58', '2026-01-16 01:45:18', '2026-01-15 20:37:10', '2026-01-15 20:45:18', '-8.39900968610542,-74.56973026608308', 0, 0, 'SIN_COMPROBANTE'),
(90, 12, '2026-01-15', '20:21:50', 12.00, 1, 7, 2, 3, NULL, '2026-01-16 01:21:50', '2026-01-16 01:46:04', '2026-01-15 20:37:24', '2026-01-15 20:46:04', '-8.39900968610542,-74.56973026608308', 0, 0, 'SIN_COMPROBANTE'),
(91, 9, '2026-01-15', '20:30:04', 8.00, 1, 7, 2, 3, NULL, '2026-01-16 01:30:04', '2026-01-16 05:02:45', '2026-01-16 00:01:22', '2026-01-16 00:02:45', '-8.399031183505079,-74.56959764732878', 0, 0, 'SIN_COMPROBANTE'),
(93, 14, '2026-01-15', '20:31:32', 12.00, 1, 7, 3, 3, NULL, '2026-01-16 01:31:32', '2026-01-19 02:13:38', '2026-01-18 21:10:17', '2026-01-18 21:13:38', '-8.399189,-74.569916', 0, 0, 'SIN_COMPROBANTE'),
(94, 2, '2026-01-15', '20:32:28', 15.00, 1, 8, NULL, 3, NULL, '2026-01-16 01:32:28', '2026-01-19 23:21:08', NULL, NULL, NULL, 0, 0, 'SIN_COMPROBANTE'),
(95, 1, '2026-01-15', '23:54:59', 8.00, 1, 8, NULL, 3, NULL, '2026-01-16 04:54:59', '2026-01-19 23:22:27', NULL, NULL, NULL, 0, 0, 'SIN_COMPROBANTE'),
(96, 11, '2026-01-15', '23:55:53', 8.00, 2, 8, NULL, 3, NULL, '2026-01-16 04:55:53', '2026-01-19 23:22:31', NULL, NULL, NULL, 0, 0, 'SIN_COMPROBANTE'),
(97, 11, '2026-01-15', '23:59:58', 12.00, 2, 8, NULL, 3, NULL, '2026-01-16 04:59:58', '2026-01-19 23:22:36', NULL, NULL, NULL, 0, 0, 'BOLETA'),
(98, 1, '2026-01-19', '18:32:30', 4.00, 2, 7, 3, 3, NULL, '2026-01-19 23:32:30', '2026-01-20 01:57:06', '2026-01-19 20:43:11', '2026-01-19 20:57:06', '-8.3990263,-74.5699794', 0, 0, 'BOLETA'),
(99, 1, '2026-01-20', '23:45:20', 4.00, 1, 7, 3, 3, NULL, '2026-01-21 04:45:20', '2026-01-22 04:21:37', '2026-01-20 23:46:45', '2026-01-20 23:48:13', '-8.399192,-74.56998633333333', 0, 0, 'BOLETA'),
(100, 3, '2026-01-21', '15:04:46', 15.00, 2, 7, 2, 3, NULL, '2026-01-21 20:04:46', '2026-01-21 20:06:50', '2026-01-21 15:05:15', '2026-01-21 15:06:50', '-8.3989865,-74.56993250000001', 0, 0, 'BOLETA'),
(101, 12, '2026-01-21', '15:15:45', 9.00, 1, 7, 3, 3, NULL, '2026-01-21 20:15:45', '2026-01-21 20:20:48', '2026-01-21 15:17:57', '2026-01-21 15:20:48', '-8.3989865,-74.56993250000001', 0, 0, 'SIN_COMPROBANTE'),
(102, 8, '2026-01-22', '16:20:01', 15.00, 1, 8, NULL, 3, NULL, '2026-01-22 21:20:01', '2026-01-22 21:20:30', NULL, NULL, NULL, 0, 0, 'SIN_COMPROBANTE'),
(103, 9, '2026-01-22', '16:21:03', 12.00, 1, 7, 2, 3, NULL, '2026-01-22 21:21:03', '2026-01-22 21:29:06', '2026-01-22 16:21:38', '2026-01-22 16:29:06', '-8.399192,-74.56998633333333', 0, 0, 'SIN_COMPROBANTE'),
(104, 1, '2026-01-26', '12:44:47', 22.50, 1, 7, 3, 3, NULL, '2026-01-26 17:44:47', '2026-01-26 17:47:31', '2026-01-26 12:45:04', '2026-01-26 12:47:31', '-8.398892061083963,-74.56965084140381', 0, 0, 'SIN_COMPROBANTE'),
(105, 3, '2026-01-26', '21:18:45', 12.00, 1, 7, 3, 3, NULL, '2026-01-27 02:18:45', '2026-01-27 02:36:46', '2026-01-26 21:21:22', '2026-01-26 21:23:46', '-8.398892061083963,-74.56965084140381', 0, 1, 'BOLETA'),
(106, 12, '2026-01-28', '08:56:09', 6.00, 1, 7, 3, 3, NULL, '2026-01-28 13:56:09', '2026-01-28 19:22:46', '2026-01-28 13:36:32', '2026-01-28 14:22:46', '-8.398994,-74.569672', 0, 0, 'SIN_COMPROBANTE'),
(107, 15, '2026-01-28', '08:56:47', 7.50, 1, 7, 3, 3, NULL, '2026-01-28 13:56:47', '2026-01-28 23:32:37', '2026-01-28 14:22:56', '2026-01-28 18:32:37', '-8.398892061083963,-74.56965084140381', 0, 0, 'SIN_COMPROBANTE'),
(108, 14, '2026-01-28', '08:57:40', 7.50, 1, 7, 3, 3, NULL, '2026-01-28 13:57:40', '2026-01-28 23:32:40', '2026-01-28 14:22:58', '2026-01-28 18:32:40', '-8.398892061083963,-74.56965084140381', 0, 0, 'SIN_COMPROBANTE'),
(109, 2, '2026-01-28', '08:58:11', 6.00, 1, 8, 3, 3, ' CANCELACIÓN REPARTIDOR: ⏰ Horario de entrega inconveniente', '2026-01-28 13:58:11', '2026-01-29 00:45:43', NULL, NULL, NULL, 0, 0, 'SIN_COMPROBANTE'),
(110, 10, '2026-01-28', '11:22:23', 8.00, 1, 8, 3, 3, ' CANCELACIÓN REPARTIDOR: ⏰ Horario de entrega inconveniente', '2026-01-28 16:22:23', '2026-02-11 22:33:12', NULL, NULL, NULL, 0, 0, 'SIN_COMPROBANTE'),
(111, 13, '2026-01-28', '11:22:50', 12.00, 1, 8, 3, 3, ' CANCELACIÓN REPARTIDOR: 🚚 Problema con el vehículo de reparto', '2026-01-28 16:22:50', '2026-02-11 22:33:37', NULL, NULL, NULL, 0, 0, 'SIN_COMPROBANTE'),
(112, 6, '2026-01-28', '11:23:30', 4.00, 1, 8, 3, 3, ' CANCELACIÓN REPARTIDOR: 🚚 Problema con el vehículo de reparto', '2026-01-28 16:23:30', '2026-02-11 22:33:29', NULL, NULL, NULL, 0, 0, 'SIN_COMPROBANTE'),
(113, 4, '2026-01-28', '11:24:10', 9.00, 1, 8, 3, 3, ' CANCELACIÓN REPARTIDOR: ⚠️ Zona insegura para la entrega', '2026-01-28 16:24:10', '2026-02-11 22:33:21', NULL, NULL, NULL, 0, 0, 'SIN_COMPROBANTE'),
(120, 3, '2026-02-11', '18:07:47', 22.50, 1, 7, 3, 3, NULL, '2026-02-11 23:07:47', '2026-02-11 23:38:57', '2026-02-11 18:08:42', '2026-02-11 18:38:57', '-8.398828129755561,-74.56967200000001', 0, 0, 'SIN_COMPROBANTE'),
(121, 2, '2026-02-13', '14:01:59', 15.00, 1, 7, 3, 3, NULL, '2026-02-13 19:01:59', '2026-02-13 19:31:23', '2026-02-13 14:25:40', '2026-02-13 14:30:27', '-8.398994,-74.569672', 0, 1, 'FACTURA'),
(122, 1, '2026-02-14', '12:09:03', 9.00, 1, 7, 3, 3, NULL, '2026-02-14 17:09:03', '2026-02-14 17:12:12', '2026-02-14 12:09:19', '2026-02-14 12:12:12', '-8.398799967103027,-74.56967286220673', 0, 0, 'BOLETA'),
(123, 12, '2026-02-24', '20:58:52', 4.00, 1, 8, NULL, 3, NULL, '2026-02-25 01:58:52', '2026-02-25 20:26:50', NULL, NULL, NULL, 0, 0, 'BOLETA'),
(124, 1, '2026-02-25', '15:26:17', 8.00, 1, 8, NULL, 3, ' CANCELACIÓN: El cliente no tiene dinero para pagar', '2026-02-25 20:26:17', '2026-02-25 21:30:42', NULL, NULL, NULL, 0, 0, 'SIN_COMPROBANTE');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `venta_detalle`
--

CREATE TABLE `venta_detalle` (
  `id_detalle` int(11) NOT NULL,
  `id_venta` int(11) NOT NULL,
  `id_producto` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precio_unitario` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) GENERATED ALWAYS AS (`cantidad` * `precio_unitario`) STORED
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `venta_detalle`
--

INSERT INTO `venta_detalle` (`id_detalle`, `id_venta`, `id_producto`, `cantidad`, `precio_unitario`) VALUES
(1, 2, 1, 1, 8.50),
(2, 3, 1, 2, 8.50),
(3, 4, 1, 1, 8.50),
(4, 5, 1, 2, 4.00),
(5, 6, 3, 10, 6.00),
(6, 7, 1, 1, 4.00),
(7, 8, 3, 3, 6.00),
(8, 9, 2, 3, 4.50),
(9, 10, 1, 1, 4.00),
(10, 10, 3, 3, 6.00),
(11, 11, 1, 2, 4.00),
(12, 12, 3, 4, 6.00),
(13, 13, 3, 3, 6.00),
(14, 14, 3, 6, 6.00),
(15, 14, 4, 2, 7.50),
(16, 28, 1, 1, 4.00),
(17, 29, 3, 4, 6.00),
(18, 30, 1, 1, 4.00),
(19, 31, 3, 10, 6.00),
(20, 32, 1, 1, 4.00),
(21, 33, 3, 1, 6.00),
(22, 34, 1, 3, 4.00),
(23, 34, 3, 3, 6.00),
(24, 35, 3, 4, 6.00),
(25, 36, 1, 1, 4.00),
(26, 37, 3, 1, 6.00),
(27, 38, 2, 1, 4.50),
(28, 39, 3, 1, 6.00),
(29, 40, 2, 2, 4.50),
(30, 41, 3, 2, 6.00),
(31, 42, 3, 1, 6.00),
(32, 43, 1, 2, 4.00),
(33, 44, 3, 2, 6.00),
(34, 45, 3, 4, 6.00),
(35, 46, 3, 100, 6.00),
(36, 47, 2, 1, 4.50),
(37, 48, 2, 1, 4.50),
(38, 49, 3, 5, 6.00),
(39, 50, 2, 1, 4.50),
(40, 51, 4, 2, 7.50),
(41, 52, 4, 2, 7.50),
(42, 53, 3, 2, 6.00),
(43, 54, 2, 1, 4.50),
(44, 54, 3, 1, 6.00),
(45, 55, 1, 3, 4.00),
(46, 56, 3, 2, 6.00),
(47, 57, 3, 1, 6.00),
(48, 58, 3, 100, 6.00),
(49, 59, 1, 1, 4.00),
(50, 59, 2, 1, 4.50),
(51, 59, 3, 5, 6.00),
(52, 59, 4, 2, 7.50),
(53, 60, 1, 1, 4.00),
(54, 60, 2, 1, 4.50),
(55, 61, 3, 3, 6.00),
(56, 61, 4, 2, 7.50),
(57, 62, 3, 1, 6.00),
(58, 62, 2, 2, 4.50),
(59, 63, 1, 1, 4.00),
(60, 64, 3, 4, 6.00),
(61, 65, 4, 4, 7.50),
(62, 66, 1, 3, 4.00),
(63, 67, 4, 3, 7.50),
(64, 68, 4, 2, 7.50),
(65, 69, 1, 1, 4.00),
(66, 70, 1, 1, 4.00),
(67, 71, 2, 1, 4.50),
(68, 72, 4, 1, 7.50),
(69, 73, 3, 1, 6.00),
(70, 74, 2, 2, 4.50),
(71, 75, 4, 4, 7.50),
(72, 76, 4, 2, 7.50),
(73, 77, 1, 2, 4.00),
(74, 78, 3, 2, 6.00),
(75, 79, 2, 2, 4.50),
(76, 80, 1, 1, 4.00),
(77, 81, 1, 1, 4.00),
(78, 82, 2, 2, 4.50),
(79, 83, 1, 1, 4.00),
(80, 84, 1, 2, 4.00),
(81, 85, 2, 2, 4.50),
(82, 86, 3, 100, 6.00),
(83, 87, 2, 3, 4.50),
(84, 88, 3, 2, 6.00),
(85, 89, 1, 2, 4.00),
(86, 90, 3, 2, 6.00),
(87, 91, 1, 2, 4.00),
(89, 93, 3, 2, 6.00),
(90, 94, 4, 2, 7.50),
(91, 95, 1, 2, 4.00),
(92, 96, 1, 2, 4.00),
(93, 97, 3, 2, 6.00),
(94, 98, 1, 1, 4.00),
(95, 99, 1, 1, 4.00),
(96, 100, 4, 2, 7.50),
(97, 101, 2, 2, 4.50),
(98, 102, 4, 2, 7.50),
(99, 103, 3, 2, 6.00),
(100, 104, 4, 3, 7.50),
(101, 105, 3, 2, 6.00),
(102, 106, 3, 1, 6.00),
(103, 107, 4, 1, 7.50),
(104, 108, 4, 1, 7.50),
(105, 109, 3, 1, 6.00),
(106, 110, 1, 2, 4.00),
(107, 111, 3, 2, 6.00),
(108, 112, 1, 1, 4.00),
(109, 113, 2, 2, 4.50),
(116, 120, 4, 3, 7.50),
(117, 121, 4, 2, 7.50),
(118, 122, 2, 2, 4.50),
(119, 123, 1, 1, 4.00),
(120, 124, 1, 2, 4.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `venta_detalle_lote`
--

CREATE TABLE `venta_detalle_lote` (
  `id_venta_detalle_lote` int(11) NOT NULL,
  `id_detalle_venta` int(11) NOT NULL,
  `id_lote` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `venta_detalle_lote`
--

INSERT INTO `venta_detalle_lote` (`id_venta_detalle_lote`, `id_detalle_venta`, `id_lote`, `cantidad`) VALUES
(1, 16, 1, 1),
(2, 17, 3, 4),
(3, 18, 1, 1),
(4, 19, 3, 10),
(5, 20, 1, 1),
(6, 21, 3, 1),
(7, 22, 1, 3),
(8, 23, 3, 3),
(9, 24, 3, 4),
(10, 25, 1, 1),
(11, 26, 3, 1),
(12, 27, 2, 1),
(13, 28, 3, 1),
(14, 29, 2, 2),
(15, 30, 3, 2),
(16, 31, 3, 1),
(17, 32, 1, 2),
(18, 33, 3, 2),
(19, 34, 3, 4),
(20, 35, 3, 100),
(21, 36, 2, 1),
(22, 37, 2, 1),
(23, 38, 3, 5),
(24, 39, 2, 1),
(25, 40, 4, 2),
(26, 41, 4, 2),
(27, 42, 3, 2),
(28, 43, 2, 1),
(29, 44, 3, 1),
(30, 45, 1, 3),
(31, 46, 3, 2),
(32, 47, 3, 1),
(33, 48, 3, 56),
(34, 48, 7, 44),
(35, 49, 1, 1),
(36, 50, 2, 1),
(37, 51, 7, 5),
(38, 52, 4, 2),
(39, 53, 1, 1),
(40, 54, 2, 1),
(41, 55, 7, 3),
(42, 56, 4, 2),
(43, 57, 7, 1),
(44, 58, 2, 2),
(45, 59, 1, 1),
(46, 60, 7, 4),
(47, 61, 4, 4),
(48, 62, 1, 3),
(49, 63, 4, 3),
(50, 64, 4, 2),
(51, 65, 1, 1),
(52, 66, 1, 1),
(53, 67, 2, 1),
(54, 68, 4, 1),
(55, 69, 7, 1),
(56, 70, 2, 2),
(57, 71, 4, 4),
(58, 72, 4, 2),
(59, 73, 1, 2),
(60, 74, 7, 2),
(61, 75, 2, 2),
(62, 76, 1, 1),
(63, 77, 1, 1),
(64, 78, 2, 2),
(65, 79, 1, 1),
(66, 80, 1, 2),
(67, 81, 2, 2),
(68, 82, 7, 100),
(69, 83, 2, 3),
(70, 84, 7, 2),
(71, 85, 1, 2),
(72, 86, 7, 2),
(73, 87, 1, 2),
(75, 89, 7, 2),
(76, 90, 4, 2),
(77, 91, 1, 2),
(78, 92, 1, 2),
(79, 93, 7, 2),
(80, 94, 1, 1),
(81, 95, 1, 1),
(82, 96, 4, 2),
(83, 97, 2, 2),
(84, 98, 4, 2),
(85, 99, 7, 2),
(86, 100, 4, 3),
(87, 101, 7, 2),
(88, 102, 7, 1),
(89, 103, 4, 1),
(90, 104, 4, 1),
(91, 105, 7, 1),
(92, 106, 1, 2),
(93, 107, 7, 2),
(94, 108, 1, 1),
(95, 109, 2, 2),
(96, 116, 4, 3),
(97, 117, 4, 2),
(98, 118, 2, 2),
(99, 119, 1, 1),
(100, 120, 1, 2);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vw_comprobantes_por_cliente`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vw_comprobantes_por_cliente` (
`id_comprobante` int(11)
,`tipo` varchar(20)
,`serie` varchar(10)
,`numero_secuencial` int(11)
,`cliente` varchar(200)
,`nombre_completo` varchar(200)
,`total` decimal(10,2)
,`estado` varchar(50)
,`fecha_generacion` timestamp
,`fecha_envio` timestamp
,`intentos_envio` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vw_comprobantes_resumen`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vw_comprobantes_resumen` (
`tipo` varchar(20)
,`estado` varchar(50)
,`cantidad` bigint(21)
,`monto_total` decimal(32,2)
,`ultima_generacion` timestamp
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vw_resumen_entregas_diario`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vw_resumen_entregas_diario` (
`fecha` date
,`id_repartidor` int(11)
,`repartidor` varchar(200)
,`entregas_dia` bigint(21)
,`total_dia` decimal(32,2)
,`metodos_utilizados` mediumtext
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vw_resumen_entregas_mensual`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vw_resumen_entregas_mensual` (
`ano` int(4)
,`mes` int(2)
,`id_repartidor` int(11)
,`repartidor` varchar(200)
,`entregas_mes` bigint(21)
,`total_mes` decimal(32,2)
,`promedio_entrega` decimal(14,6)
);

-- --------------------------------------------------------

--
-- Estructura para la vista `vw_comprobantes_por_cliente`
--
DROP TABLE IF EXISTS `vw_comprobantes_por_cliente`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_comprobantes_por_cliente`  AS SELECT `cs`.`id_comprobante` AS `id_comprobante`, `cs`.`tipo` AS `tipo`, `cs`.`serie` AS `serie`, `cs`.`numero_secuencial` AS `numero_secuencial`, `c`.`razon_social` AS `cliente`, `p`.`nombre_completo` AS `nombre_completo`, `cs`.`total` AS `total`, `cs`.`estado` AS `estado`, `cs`.`fecha_generacion` AS `fecha_generacion`, `cs`.`fecha_envio` AS `fecha_envio`, `cs`.`intentos_envio` AS `intentos_envio` FROM (((`comprobante_sunat` `cs` join `venta` `v` on(`cs`.`id_venta` = `v`.`id_venta`)) join `cliente` `c` on(`v`.`id_cliente` = `c`.`id_cliente`)) join `persona` `p` on(`c`.`id_persona` = `p`.`id_persona`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vw_comprobantes_resumen`
--
DROP TABLE IF EXISTS `vw_comprobantes_resumen`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_comprobantes_resumen`  AS SELECT `comprobante_sunat`.`tipo` AS `tipo`, `comprobante_sunat`.`estado` AS `estado`, count(0) AS `cantidad`, sum(`comprobante_sunat`.`total`) AS `monto_total`, max(`comprobante_sunat`.`fecha_generacion`) AS `ultima_generacion` FROM `comprobante_sunat` GROUP BY `comprobante_sunat`.`tipo`, `comprobante_sunat`.`estado` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vw_resumen_entregas_diario`
--
DROP TABLE IF EXISTS `vw_resumen_entregas_diario`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_resumen_entregas_diario`  AS SELECT cast(`edr`.`fecha_entrega` as date) AS `fecha`, `edr`.`id_repartidor` AS `id_repartidor`, `p`.`nombre_completo` AS `repartidor`, count(`edr`.`id_entrega`) AS `entregas_dia`, sum(`edr`.`total`) AS `total_dia`, group_concat(distinct `edr`.`metodo_entrega` order by `edr`.`metodo_entrega` ASC separator ',') AS `metodos_utilizados` FROM ((`entrega_dinero_repartidor` `edr` join `repartidor` `r` on(`edr`.`id_repartidor` = `r`.`id_repartidor`)) join `persona` `p` on(`r`.`id_persona` = `p`.`id_persona`)) WHERE `edr`.`estado` = 'completado' GROUP BY cast(`edr`.`fecha_entrega` as date), `edr`.`id_repartidor` ORDER BY cast(`edr`.`fecha_entrega` as date) DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vw_resumen_entregas_mensual`
--
DROP TABLE IF EXISTS `vw_resumen_entregas_mensual`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_resumen_entregas_mensual`  AS SELECT year(`edr`.`fecha_entrega`) AS `ano`, month(`edr`.`fecha_entrega`) AS `mes`, `edr`.`id_repartidor` AS `id_repartidor`, `p`.`nombre_completo` AS `repartidor`, count(`edr`.`id_entrega`) AS `entregas_mes`, sum(`edr`.`total`) AS `total_mes`, avg(`edr`.`total`) AS `promedio_entrega` FROM ((`entrega_dinero_repartidor` `edr` join `repartidor` `r` on(`edr`.`id_repartidor` = `r`.`id_repartidor`)) join `persona` `p` on(`r`.`id_persona` = `p`.`id_persona`)) WHERE `edr`.`estado` = 'completado' GROUP BY year(`edr`.`fecha_entrega`), month(`edr`.`fecha_entrega`), `edr`.`id_repartidor` ORDER BY year(`edr`.`fecha_entrega`) DESC, month(`edr`.`fecha_entrega`) DESC ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `categorias`
--
ALTER TABLE `categorias`
  ADD PRIMARY KEY (`id_categoria`);

--
-- Indices de la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`id_cliente`),
  ADD UNIQUE KEY `uk_cliente_persona` (`id_persona`),
  ADD KEY `idx_cliente_tipo` (`tipo_cliente`),
  ADD KEY `idx_cliente_activo` (`activo`),
  ADD KEY `idx_cliente_distrito` (`id_persona`);

--
-- Indices de la tabla `comprobante_sunat`
--
ALTER TABLE `comprobante_sunat`
  ADD PRIMARY KEY (`id_comprobante`),
  ADD UNIQUE KEY `unique_comprobante` (`serie`,`numero_secuencial`,`tipo`),
  ADD KEY `idx_estado` (`estado`),
  ADD KEY `idx_tipo` (`tipo`),
  ADD KEY `idx_fecha` (`fecha_generacion`),
  ADD KEY `idx_comprobante_venta` (`id_venta`),
  ADD KEY `idx_comprobante_serie` (`serie`,`numero_secuencial`),
  ADD KEY `idx_comprobante_fechas` (`fecha_generacion`,`fecha_envio`);

--
-- Indices de la tabla `departamento`
--
ALTER TABLE `departamento`
  ADD PRIMARY KEY (`id_departamento`),
  ADD KEY `id_pais` (`id_pais`);

--
-- Indices de la tabla `distrito`
--
ALTER TABLE `distrito`
  ADD PRIMARY KEY (`id_distrito`),
  ADD KEY `id_provincia` (`id_provincia`);

--
-- Indices de la tabla `empresa_config`
--
ALTER TABLE `empresa_config`
  ADD PRIMARY KEY (`id_config`);

--
-- Indices de la tabla `entrega_dinero_repartidor`
--
ALTER TABLE `entrega_dinero_repartidor`
  ADD PRIMARY KEY (`id_entrega`),
  ADD KEY `id_usuario_registro` (`id_usuario_registro`),
  ADD KEY `idx_repartidor_fecha` (`id_repartidor`,`fecha_entrega`),
  ADD KEY `idx_fecha_estado` (`fecha_entrega`,`estado`);

--
-- Indices de la tabla `entrega_dinero_ventas`
--
ALTER TABLE `entrega_dinero_ventas`
  ADD PRIMARY KEY (`id_asociacion`),
  ADD KEY `idx_entrega_venta` (`id_entrega`,`id_venta`),
  ADD KEY `idx_venta` (`id_venta`);

--
-- Indices de la tabla `errores_sunat`
--
ALTER TABLE `errores_sunat`
  ADD PRIMARY KEY (`id_error`),
  ADD KEY `id_venta` (`id_venta`);

--
-- Indices de la tabla `estado_pedido_proveedor`
--
ALTER TABLE `estado_pedido_proveedor`
  ADD PRIMARY KEY (`id_estado_pedido`);

--
-- Indices de la tabla `estado_venta`
--
ALTER TABLE `estado_venta`
  ADD PRIMARY KEY (`id_estado_venta`);

--
-- Indices de la tabla `insumo`
--
ALTER TABLE `insumo`
  ADD PRIMARY KEY (`id_insumo`),
  ADD KEY `idx_insumo_activo` (`activo`),
  ADD KEY `idx_insumo_proveedor` (`id_proveedor_principal`);

--
-- Indices de la tabla `lote_producto`
--
ALTER TABLE `lote_producto`
  ADD PRIMARY KEY (`id_lote`),
  ADD KEY `idx_lote_producto` (`id_producto`),
  ADD KEY `idx_lote_caducidad` (`fecha_caducidad`);

--
-- Indices de la tabla `marcas`
--
ALTER TABLE `marcas`
  ADD PRIMARY KEY (`id_marca`);

--
-- Indices de la tabla `metodo_pago`
--
ALTER TABLE `metodo_pago`
  ADD PRIMARY KEY (`id_metodo_pago`);

--
-- Indices de la tabla `movimiento_stock`
--
ALTER TABLE `movimiento_stock`
  ADD PRIMARY KEY (`id_movimiento`),
  ADD KEY `idx_movimiento_producto` (`id_producto`),
  ADD KEY `idx_movimiento_usuario` (`id_usuario`),
  ADD KEY `fk_movimiento_lote` (`id_lote`);

--
-- Indices de la tabla `pais`
--
ALTER TABLE `pais`
  ADD PRIMARY KEY (`id_pais`);

--
-- Indices de la tabla `pedido_proveedor`
--
ALTER TABLE `pedido_proveedor`
  ADD PRIMARY KEY (`id_pedido`),
  ADD KEY `idx_pedido_proveedor` (`id_proveedor`),
  ADD KEY `idx_pedido_estado` (`id_estado_pedido`),
  ADD KEY `idx_pedido_fecha` (`fecha`);

--
-- Indices de la tabla `pedido_proveedor_detalle`
--
ALTER TABLE `pedido_proveedor_detalle`
  ADD PRIMARY KEY (`id_detalle`),
  ADD KEY `id_pedido` (`id_pedido`),
  ADD KEY `id_insumo` (`id_insumo`);

--
-- Indices de la tabla `persona`
--
ALTER TABLE `persona`
  ADD PRIMARY KEY (`id_persona`),
  ADD UNIQUE KEY `numero_documento` (`numero_documento`),
  ADD KEY `idx_persona_documento` (`numero_documento`),
  ADD KEY `idx_persona_nombre` (`nombre_completo`),
  ADD KEY `idx_persona_activo` (`activo`);

--
-- Indices de la tabla `producto`
--
ALTER TABLE `producto`
  ADD PRIMARY KEY (`id_producto`),
  ADD KEY `id_pais_origen` (`id_pais_origen`),
  ADD KEY `idx_producto_categoria` (`id_categoria`),
  ADD KEY `idx_producto_marca` (`id_marca`);

--
-- Indices de la tabla `proveedor`
--
ALTER TABLE `proveedor`
  ADD PRIMARY KEY (`id_proveedor`),
  ADD UNIQUE KEY `uk_proveedor_persona` (`id_persona`),
  ADD KEY `idx_proveedor_activo` (`activo`);

--
-- Indices de la tabla `provincia`
--
ALTER TABLE `provincia`
  ADD PRIMARY KEY (`id_provincia`),
  ADD KEY `id_departamento` (`id_departamento`);

--
-- Indices de la tabla `repartidor`
--
ALTER TABLE `repartidor`
  ADD PRIMARY KEY (`id_repartidor`),
  ADD UNIQUE KEY `uk_repartidor_persona` (`id_persona`),
  ADD KEY `idx_repartidor_activo` (`activo`),
  ADD KEY `idx_repartidor_contratacion` (`fecha_contratacion`);

--
-- Indices de la tabla `rol`
--
ALTER TABLE `rol`
  ADD PRIMARY KEY (`id_rol`);

--
-- Indices de la tabla `sistema_bitacora`
--
ALTER TABLE `sistema_bitacora`
  ADD PRIMARY KEY (`id_bitacora`),
  ADD KEY `idx_modulo_fecha` (`modulo`,`fecha_registro`),
  ADD KEY `idx_usuario_fecha` (`id_usuario`,`fecha_registro`);

--
-- Indices de la tabla `sunat_configuracion`
--
ALTER TABLE `sunat_configuracion`
  ADD PRIMARY KEY (`id_config`),
  ADD UNIQUE KEY `ruc` (`ruc`),
  ADD KEY `idx_ruc` (`ruc`);

--
-- Indices de la tabla `tracking_ubicacion`
--
ALTER TABLE `tracking_ubicacion`
  ADD PRIMARY KEY (`id_tracking`),
  ADD KEY `id_repartidor` (`id_repartidor`),
  ADD KEY `id_venta` (`id_venta`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `nombre_usuario` (`nombre_usuario`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_usuario_rol` (`id_rol`),
  ADD KEY `idx_usuario_persona` (`id_persona`),
  ADD KEY `idx_usuario_activo` (`activo`),
  ADD KEY `idx_usuario_email` (`email`);

--
-- Indices de la tabla `venta`
--
ALTER TABLE `venta`
  ADD PRIMARY KEY (`id_venta`),
  ADD KEY `id_metodo_pago` (`id_metodo_pago`),
  ADD KEY `id_vendedor` (`id_vendedor`),
  ADD KEY `idx_venta_fecha` (`fecha`),
  ADD KEY `idx_venta_cliente` (`id_cliente`),
  ADD KEY `idx_venta_estado` (`id_estado_venta`),
  ADD KEY `idx_venta_repartidor` (`id_repartidor`);

--
-- Indices de la tabla `venta_detalle`
--
ALTER TABLE `venta_detalle`
  ADD PRIMARY KEY (`id_detalle`),
  ADD KEY `idx_venta_detalle_venta` (`id_venta`),
  ADD KEY `idx_venta_detalle_producto` (`id_producto`);

--
-- Indices de la tabla `venta_detalle_lote`
--
ALTER TABLE `venta_detalle_lote`
  ADD PRIMARY KEY (`id_venta_detalle_lote`),
  ADD KEY `idx_venta_detalle` (`id_detalle_venta`),
  ADD KEY `idx_lote` (`id_lote`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `categorias`
--
ALTER TABLE `categorias`
  MODIFY `id_categoria` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `cliente`
--
ALTER TABLE `cliente`
  MODIFY `id_cliente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT de la tabla `comprobante_sunat`
--
ALTER TABLE `comprobante_sunat`
  MODIFY `id_comprobante` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT de la tabla `departamento`
--
ALTER TABLE `departamento`
  MODIFY `id_departamento` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `distrito`
--
ALTER TABLE `distrito`
  MODIFY `id_distrito` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `empresa_config`
--
ALTER TABLE `empresa_config`
  MODIFY `id_config` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `entrega_dinero_repartidor`
--
ALTER TABLE `entrega_dinero_repartidor`
  MODIFY `id_entrega` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=61;

--
-- AUTO_INCREMENT de la tabla `entrega_dinero_ventas`
--
ALTER TABLE `entrega_dinero_ventas`
  MODIFY `id_asociacion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=107;

--
-- AUTO_INCREMENT de la tabla `errores_sunat`
--
ALTER TABLE `errores_sunat`
  MODIFY `id_error` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `estado_pedido_proveedor`
--
ALTER TABLE `estado_pedido_proveedor`
  MODIFY `id_estado_pedido` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `estado_venta`
--
ALTER TABLE `estado_venta`
  MODIFY `id_estado_venta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de la tabla `insumo`
--
ALTER TABLE `insumo`
  MODIFY `id_insumo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `lote_producto`
--
ALTER TABLE `lote_producto`
  MODIFY `id_lote` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT de la tabla `marcas`
--
ALTER TABLE `marcas`
  MODIFY `id_marca` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `metodo_pago`
--
ALTER TABLE `metodo_pago`
  MODIFY `id_metodo_pago` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `movimiento_stock`
--
ALTER TABLE `movimiento_stock`
  MODIFY `id_movimiento` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=148;

--
-- AUTO_INCREMENT de la tabla `pais`
--
ALTER TABLE `pais`
  MODIFY `id_pais` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `pedido_proveedor`
--
ALTER TABLE `pedido_proveedor`
  MODIFY `id_pedido` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT de la tabla `pedido_proveedor_detalle`
--
ALTER TABLE `pedido_proveedor_detalle`
  MODIFY `id_detalle` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT de la tabla `persona`
--
ALTER TABLE `persona`
  MODIFY `id_persona` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT de la tabla `producto`
--
ALTER TABLE `producto`
  MODIFY `id_producto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `proveedor`
--
ALTER TABLE `proveedor`
  MODIFY `id_proveedor` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `provincia`
--
ALTER TABLE `provincia`
  MODIFY `id_provincia` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `repartidor`
--
ALTER TABLE `repartidor`
  MODIFY `id_repartidor` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `rol`
--
ALTER TABLE `rol`
  MODIFY `id_rol` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `sistema_bitacora`
--
ALTER TABLE `sistema_bitacora`
  MODIFY `id_bitacora` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=65;

--
-- AUTO_INCREMENT de la tabla `sunat_configuracion`
--
ALTER TABLE `sunat_configuracion`
  MODIFY `id_config` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `tracking_ubicacion`
--
ALTER TABLE `tracking_ubicacion`
  MODIFY `id_tracking` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT de la tabla `venta`
--
ALTER TABLE `venta`
  MODIFY `id_venta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=125;

--
-- AUTO_INCREMENT de la tabla `venta_detalle`
--
ALTER TABLE `venta_detalle`
  MODIFY `id_detalle` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=121;

--
-- AUTO_INCREMENT de la tabla `venta_detalle_lote`
--
ALTER TABLE `venta_detalle_lote`
  MODIFY `id_venta_detalle_lote` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=101;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD CONSTRAINT `cliente_ibfk_1` FOREIGN KEY (`id_persona`) REFERENCES `persona` (`id_persona`);

--
-- Filtros para la tabla `comprobante_sunat`
--
ALTER TABLE `comprobante_sunat`
  ADD CONSTRAINT `comprobante_sunat_ibfk_1` FOREIGN KEY (`id_venta`) REFERENCES `venta` (`id_venta`) ON DELETE CASCADE;

--
-- Filtros para la tabla `departamento`
--
ALTER TABLE `departamento`
  ADD CONSTRAINT `departamento_ibfk_1` FOREIGN KEY (`id_pais`) REFERENCES `pais` (`id_pais`);

--
-- Filtros para la tabla `distrito`
--
ALTER TABLE `distrito`
  ADD CONSTRAINT `distrito_ibfk_1` FOREIGN KEY (`id_provincia`) REFERENCES `provincia` (`id_provincia`);

--
-- Filtros para la tabla `entrega_dinero_repartidor`
--
ALTER TABLE `entrega_dinero_repartidor`
  ADD CONSTRAINT `entrega_dinero_repartidor_ibfk_1` FOREIGN KEY (`id_repartidor`) REFERENCES `repartidor` (`id_repartidor`) ON DELETE CASCADE,
  ADD CONSTRAINT `entrega_dinero_repartidor_ibfk_2` FOREIGN KEY (`id_usuario_registro`) REFERENCES `usuario` (`id_usuario`) ON DELETE SET NULL;

--
-- Filtros para la tabla `entrega_dinero_ventas`
--
ALTER TABLE `entrega_dinero_ventas`
  ADD CONSTRAINT `entrega_dinero_ventas_ibfk_1` FOREIGN KEY (`id_entrega`) REFERENCES `entrega_dinero_repartidor` (`id_entrega`) ON DELETE CASCADE,
  ADD CONSTRAINT `entrega_dinero_ventas_ibfk_2` FOREIGN KEY (`id_venta`) REFERENCES `venta` (`id_venta`) ON DELETE CASCADE;

--
-- Filtros para la tabla `errores_sunat`
--
ALTER TABLE `errores_sunat`
  ADD CONSTRAINT `errores_sunat_ibfk_1` FOREIGN KEY (`id_venta`) REFERENCES `venta` (`id_venta`);

--
-- Filtros para la tabla `lote_producto`
--
ALTER TABLE `lote_producto`
  ADD CONSTRAINT `lote_producto_ibfk_1` FOREIGN KEY (`id_producto`) REFERENCES `producto` (`id_producto`);

--
-- Filtros para la tabla `movimiento_stock`
--
ALTER TABLE `movimiento_stock`
  ADD CONSTRAINT `fk_movimiento_lote` FOREIGN KEY (`id_lote`) REFERENCES `lote_producto` (`id_lote`),
  ADD CONSTRAINT `movimiento_stock_ibfk_1` FOREIGN KEY (`id_producto`) REFERENCES `producto` (`id_producto`),
  ADD CONSTRAINT `movimiento_stock_ibfk_2` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`);

--
-- Filtros para la tabla `pedido_proveedor`
--
ALTER TABLE `pedido_proveedor`
  ADD CONSTRAINT `pedido_proveedor_ibfk_1` FOREIGN KEY (`id_proveedor`) REFERENCES `proveedor` (`id_proveedor`),
  ADD CONSTRAINT `pedido_proveedor_ibfk_3` FOREIGN KEY (`id_estado_pedido`) REFERENCES `estado_pedido_proveedor` (`id_estado_pedido`);

--
-- Filtros para la tabla `pedido_proveedor_detalle`
--
ALTER TABLE `pedido_proveedor_detalle`
  ADD CONSTRAINT `pedido_proveedor_detalle_ibfk_1` FOREIGN KEY (`id_pedido`) REFERENCES `pedido_proveedor` (`id_pedido`) ON DELETE CASCADE,
  ADD CONSTRAINT `pedido_proveedor_detalle_ibfk_2` FOREIGN KEY (`id_insumo`) REFERENCES `insumo` (`id_insumo`);

--
-- Filtros para la tabla `producto`
--
ALTER TABLE `producto`
  ADD CONSTRAINT `producto_ibfk_1` FOREIGN KEY (`id_categoria`) REFERENCES `categorias` (`id_categoria`),
  ADD CONSTRAINT `producto_ibfk_2` FOREIGN KEY (`id_marca`) REFERENCES `marcas` (`id_marca`),
  ADD CONSTRAINT `producto_ibfk_4` FOREIGN KEY (`id_pais_origen`) REFERENCES `pais` (`id_pais`);

--
-- Filtros para la tabla `proveedor`
--
ALTER TABLE `proveedor`
  ADD CONSTRAINT `proveedor_ibfk_1` FOREIGN KEY (`id_persona`) REFERENCES `persona` (`id_persona`);

--
-- Filtros para la tabla `provincia`
--
ALTER TABLE `provincia`
  ADD CONSTRAINT `provincia_ibfk_1` FOREIGN KEY (`id_departamento`) REFERENCES `departamento` (`id_departamento`);

--
-- Filtros para la tabla `repartidor`
--
ALTER TABLE `repartidor`
  ADD CONSTRAINT `repartidor_ibfk_1` FOREIGN KEY (`id_persona`) REFERENCES `persona` (`id_persona`);

--
-- Filtros para la tabla `sistema_bitacora`
--
ALTER TABLE `sistema_bitacora`
  ADD CONSTRAINT `sistema_bitacora_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE SET NULL;

--
-- Filtros para la tabla `tracking_ubicacion`
--
ALTER TABLE `tracking_ubicacion`
  ADD CONSTRAINT `tracking_ubicacion_ibfk_1` FOREIGN KEY (`id_repartidor`) REFERENCES `repartidor` (`id_repartidor`),
  ADD CONSTRAINT `tracking_ubicacion_ibfk_2` FOREIGN KEY (`id_venta`) REFERENCES `venta` (`id_venta`);

--
-- Filtros para la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD CONSTRAINT `usuario_ibfk_1` FOREIGN KEY (`id_rol`) REFERENCES `rol` (`id_rol`),
  ADD CONSTRAINT `usuario_ibfk_2` FOREIGN KEY (`id_persona`) REFERENCES `persona` (`id_persona`);

--
-- Filtros para la tabla `venta`
--
ALTER TABLE `venta`
  ADD CONSTRAINT `venta_ibfk_1` FOREIGN KEY (`id_cliente`) REFERENCES `cliente` (`id_cliente`),
  ADD CONSTRAINT `venta_ibfk_2` FOREIGN KEY (`id_metodo_pago`) REFERENCES `metodo_pago` (`id_metodo_pago`),
  ADD CONSTRAINT `venta_ibfk_3` FOREIGN KEY (`id_estado_venta`) REFERENCES `estado_venta` (`id_estado_venta`),
  ADD CONSTRAINT `venta_ibfk_4` FOREIGN KEY (`id_repartidor`) REFERENCES `repartidor` (`id_repartidor`),
  ADD CONSTRAINT `venta_ibfk_5` FOREIGN KEY (`id_vendedor`) REFERENCES `usuario` (`id_usuario`);

--
-- Filtros para la tabla `venta_detalle`
--
ALTER TABLE `venta_detalle`
  ADD CONSTRAINT `venta_detalle_ibfk_1` FOREIGN KEY (`id_venta`) REFERENCES `venta` (`id_venta`) ON DELETE CASCADE,
  ADD CONSTRAINT `venta_detalle_ibfk_2` FOREIGN KEY (`id_producto`) REFERENCES `producto` (`id_producto`);

--
-- Filtros para la tabla `venta_detalle_lote`
--
ALTER TABLE `venta_detalle_lote`
  ADD CONSTRAINT `venta_detalle_lote_ibfk_1` FOREIGN KEY (`id_detalle_venta`) REFERENCES `venta_detalle` (`id_detalle`) ON DELETE CASCADE,
  ADD CONSTRAINT `venta_detalle_lote_ibfk_2` FOREIGN KEY (`id_lote`) REFERENCES `lote_producto` (`id_lote`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
