// src/routes/entrega-dinero.routes.js
import express from 'express';
import db from '../config/db.js';

const router = express.Router();

// Middleware de autenticación
import { verifyToken, requireRole } from '../middleware/auth.js';

// Todas las rutas requieren autenticación
router.use(verifyToken);

/**
 * @route   POST /api/entregas-dinero/registrar
 * @desc    Registrar entrega de dinero del repartidor al administrador
 * @access  Private (Repartidor)
 */
router.post('/registrar', requireRole([3], 'historial_entregas'), async (req, res) => {
  let connection;
  try {
    connection = await db.getConnection();
    
    const { total, metodo_entrega, fecha_entrega } = req.body;
    
    // Validaciones
    if (!total || total <= 0) {
      return res.status(400).json({ 
        error: 'El monto total debe ser mayor a 0' 
      });
    }

    if (!metodo_entrega || !['efectivo', 'transferencia', 'yape'].includes(metodo_entrega)) {
      return res.status(400).json({ 
        error: 'Método de entrega no válido. Use: efectivo, transferencia o yape' 
      });
    }

    // Obtener id_repartidor del usuario autenticado
    const [repartidores] = await connection.execute(`
      SELECT r.id_repartidor, p.nombre_completo
      FROM repartidor r
      JOIN usuario u ON r.id_persona = u.id_persona
      JOIN persona p ON r.id_persona = p.id_persona
      WHERE u.id_usuario = ?
      LIMIT 1
    `, [req.user.id_usuario]);

    if (repartidores.length === 0) {
      return res.status(404).json({ 
        error: 'Repartidor no encontrado para este usuario' 
      });
    }

    const repartidor = repartidores[0];
    const repartidorId = repartidor.id_repartidor;
    const repartidorNombre = repartidor.nombre_completo;

    console.log(`💰 Registrando entrega de dinero para repartidor ${repartidorNombre} (ID: ${repartidorId})`);

    // Registrar la entrega
   const [result] = await connection.execute(`
  INSERT INTO entrega_dinero_repartidor 
    (id_repartidor, total, metodo_entrega, fecha_entrega, estado, notas, id_usuario_registro)
  VALUES (?, ?, ?, ?, 'completado', ?, ?)
`, [
  repartidorId, 
  total, 
  metodo_entrega, 
  fecha_entrega || new Date(),
  `Entrega registrada por ${repartidorNombre}. Método: ${metodo_entrega}`,
  req.user.id_usuario  // ← AGREGAR ESTO
]);

// En el método POST /registrar, después de insertar la entrega:

// Asociar ventas pagadas sin entrega con esta entrega
const [ventasSinEntrega] = await connection.execute(`
  SELECT id_venta, total
  FROM venta 
  WHERE id_repartidor = ?
    AND id_estado_venta = 7 -- Pagado
    AND DATE(fecha_fin_ruta) = CURDATE()
    AND id_venta NOT IN (
      SELECT id_venta FROM entrega_dinero_ventas
    )
  ORDER BY fecha_fin_ruta ASC
`, [repartidorId]);

let totalAsociado = 0;
for (const venta of ventasSinEntrega) {
  if (totalAsociado + venta.total <= total) {
    await connection.execute(`
      INSERT INTO entrega_dinero_ventas (id_entrega, id_venta, monto_asignado)
      VALUES (?, ?, ?)
    `, [result.insertId, venta.id_venta, venta.total]);
    
    totalAsociado += venta.total;
  }
}


    // Obtener el registro creado
    const [entregaCreada] = await connection.execute(`
      SELECT 
        id_entrega,
        total,
        metodo_entrega,
        DATE_FORMAT(fecha_entrega, '%Y-%m-%d %H:%i:%s') as fecha_entrega_format,
        estado,
        notas
      FROM entrega_dinero_repartidor
      WHERE id_entrega = ?
    `, [result.insertId]);

    // Registrar en bitácora del sistema
    await connection.execute(`
      INSERT INTO sistema_bitacora 
        (modulo, accion, descripcion, id_usuario, id_referencia)
      VALUES ('entregas_dinero', 'registro', ?, ?, ?)
    `, [
      `Repartidor ${repartidorNombre} entregó S/ ${total} (${metodo_entrega})`,
      req.user.id_usuario,
      result.insertId
    ]);

    res.json({
      success: true,
      message: '✅ Entrega de dinero registrada exitosamente',
      data: {
        id_entrega: result.insertId,
        total: total,
        metodo_entrega: metodo_entrega,
        fecha_entrega: entregaCreada[0].fecha_entrega_format,
        estado: 'completado',
        repartidor: {
          id: repartidorId,
          nombre: repartidorNombre
        }
      }
    });

  } catch (error) {
    console.error('❌ Error registrando entrega de dinero:', error);
    res.status(500).json({ 
      error: 'Error interno del servidor al registrar la entrega',
      detalles: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  } finally {
    if (connection) connection.release();
  }
});

/**
 * @route   GET /api/entregas-dinero/historial
 * @desc    Obtener historial de entregas de dinero del repartidor
 * @access  Private (Repartidor)
 */
router.get('/historial', requireRole([3], 'historial_entregas'), async (req, res) => {
  try {
    // Obtener id_repartidor
    const [repartidores] = await db.execute(`
      SELECT r.id_repartidor 
      FROM repartidor r
      JOIN usuario u ON r.id_persona = u.id_persona
      WHERE u.id_usuario = ?
      LIMIT 1
    `, [req.user.id_usuario]);

    if (repartidores.length === 0) {
      return res.status(404).json({ 
        error: 'Repartidor no encontrado para este usuario' 
      });
    }

    const repartidorId = repartidores[0].id_repartidor;

    // Obtener historial (últimas 50 entregas)
   // En el método GET /historial, cambiar la consulta:
const [entregas] = await db.execute(`
  SELECT 
    id_entrega,
    total,
    metodo_entrega,
    DATE_FORMAT(fecha_entrega, '%Y-%m-%d') as fecha,
    DATE_FORMAT(
      CONVERT_TZ(fecha_entrega, '+00:00', '-05:00'), 
      '%H:%i:%s'
    ) as hora,
    estado,
    notas,
    DATE_FORMAT(
      CONVERT_TZ(fecha_registro, '+00:00', '-05:00'), 
      '%Y-%m-%d %H:%i:%s'
    ) as fecha_registro,
    TIMESTAMPDIFF(HOUR, fecha_registro, NOW()) as horas_transcurridas
  FROM entrega_dinero_repartidor
  WHERE id_repartidor = ?
  ORDER BY fecha_entrega DESC, fecha_registro DESC
  LIMIT 50
`, [repartidorId]);

    // Calcular estadísticas
    const [estadisticas] = await db.execute(`
      SELECT 
        COUNT(*) as total_entregas,
        SUM(total) as monto_total,
        MIN(fecha_entrega) as primera_entrega,
        MAX(fecha_entrega) as ultima_entrega
      FROM entrega_dinero_repartidor
      WHERE id_repartidor = ?
    `, [repartidorId]);

    res.json({
      success: true,
      data: {
        entregas: entregas,
        estadisticas: estadisticas[0],
        total_registros: entregas.length
      }
    });

  } catch (error) {
    console.error('❌ Error obteniendo historial de entregas de dinero:', error);
    res.status(500).json({ 
      error: 'Error interno del servidor al obtener el historial'
    });
  }
});

/**
 * @route   GET /api/entregas-dinero/total-entregado
 * @desc    Obtener total entregado al administrador (hoy)
 * @access  Private (Repartidor)
 */
router.get('/total-entregado', requireRole([3], 'historial_entregas'), async (req, res) => {
  try {
    // Obtener id_repartidor
    const [repartidores] = await db.execute(`
      SELECT r.id_repartidor 
      FROM repartidor r
      JOIN usuario u ON r.id_persona = u.id_persona
      WHERE u.id_usuario = ?
      LIMIT 1
    `, [req.user.id_usuario]);

    if (repartidores.length === 0) {
      return res.status(404).json({ 
        error: 'Repartidor no encontrado para este usuario' 
      });
    }

    const repartidorId = repartidores[0].id_repartidor;

    // Obtener total entregado HOY
    const [result] = await db.execute(`
      SELECT 
        COALESCE(SUM(total), 0) as total_entregado,
        COUNT(*) as cantidad_entregas,
        GROUP_CONCAT(DISTINCT metodo_entrega) as metodos_utilizados
      FROM entrega_dinero_repartidor
      WHERE id_repartidor = ? 
        AND estado = 'completado'
        AND DATE(fecha_entrega) = CURDATE()
    `, [repartidorId]);

    // Obtener total entregado en la semana
    const [semanal] = await db.execute(`
      SELECT 
        COALESCE(SUM(total), 0) as total_semana,
        COUNT(*) as entregas_semana
      FROM entrega_dinero_repartidor
      WHERE id_repartidor = ? 
        AND estado = 'completado'
        AND YEARWEEK(fecha_entrega, 1) = YEARWEEK(CURDATE(), 1)
    `, [repartidorId]);

    // Obtener total entregado en el mes
    const [mensual] = await db.execute(`
      SELECT 
        COALESCE(SUM(total), 0) as total_mes,
        COUNT(*) as entregas_mes
      FROM entrega_dinero_repartidor
      WHERE id_repartidor = ? 
        AND estado = 'completado'
        AND YEAR(fecha_entrega) = YEAR(CURDATE())
        AND MONTH(fecha_entrega) = MONTH(CURDATE())
    `, [repartidorId]);

    res.json({
      success: true,
      data: {
        hoy: {
          total: parseFloat(result[0].total_entregado),
          entregas: result[0].cantidad_entregas,
          metodos: result[0].metodos_utilizados?.split(',') || []
        },
        semana: {
          total: parseFloat(semanal[0].total_semana),
          entregas: semanal[0].entregas_semana
        },
        mes: {
          total: parseFloat(mensual[0].total_mes),
          entregas: mensual[0].entregas_mes
        }
      }
    });

  } catch (error) {
    console.error('❌ Error obteniendo total entregado:', error);
    res.status(500).json({ 
      error: 'Error interno del servidor al obtener el total entregado'
    });
  }
});

/**
 * @route   GET /api/entregas-dinero/pendiente
 * @desc    Obtener dinero pendiente de entrega (ventas pagadas hoy)
 * @access  Private (Repartidor)
 */
router.get('/pendiente', requireRole([3], 'historial_entregas'), async (req, res) => {
  try {
    // Obtener id_repartidor
    const [repartidores] = await db.execute(`
      SELECT r.id_repartidor 
      FROM repartidor r
      JOIN usuario u ON r.id_persona = u.id_persona
      WHERE u.id_usuario = ?
      LIMIT 1
    `, [req.user.id_usuario]);

    if (repartidores.length === 0) {
      return res.status(404).json({ 
        error: 'Repartidor no encontrado para este usuario' 
      });
    }

    const repartidorId = repartidores[0].id_repartidor;

    // Obtener ventas pagadas hoy que aún no tienen entrega de dinero registrada
    const [pendiente] = await db.execute(`
      SELECT 
        COALESCE(SUM(v.total), 0) as total_pendiente,
        COUNT(*) as ventas_pendientes
      FROM venta v
      WHERE v.id_repartidor = ?
        AND v.id_estado_venta = 7 -- Pagado
        AND DATE(v.fecha_fin_ruta) = CURDATE()
        AND v.id_venta NOT IN (
          SELECT edr.id_venta 
          FROM entrega_dinero_ventas edr 
          WHERE edr.id_repartidor = ?
            AND DATE(edr.fecha_asociacion) = CURDATE()
        )
    `, [repartidorId, repartidorId]);

    res.json({
      success: true,
      data: {
        pendiente: parseFloat(pendiente[0].total_pendiente),
        ventas_pendientes: pendiente[0].ventas_pendientes
      }
    });

  } catch (error) {
    console.error('❌ Error obteniendo dinero pendiente:', error);
    res.status(500).json({ 
      error: 'Error interno del servidor al obtener el dinero pendiente'
    });
  }
});

/**
 * @route   GET /api/entregas-dinero/resumen
 * @desc    Obtener resumen de entregas por rango de fechas
 * @access  Private (Repartidor)
 */
router.get('/resumen', requireRole([3], 'historial_entregas'), async (req, res) => {
  try {
    const { fecha_inicio, fecha_fin } = req.query;
    
    if (!fecha_inicio || !fecha_fin) {
      return res.status(400).json({ 
        error: 'Las fechas de inicio y fin son requeridas' 
      });
    }

    // Obtener id_repartidor
    const [repartidores] = await db.execute(`
      SELECT r.id_repartidor 
      FROM repartidor r
      JOIN usuario u ON r.id_persona = u.id_persona
      WHERE u.id_usuario = ?
      LIMIT 1
    `, [req.user.id_usuario]);

    if (repartidores.length === 0) {
      return res.status(404).json({ 
        error: 'Repartidor no encontrado para este usuario' 
      });
    }

    const repartidorId = repartidores[0].id_repartidor;

    // Obtener resumen por día
    const [resumen] = await db.execute(`
      SELECT 
        DATE(fecha_entrega) as fecha,
        COUNT(*) as cantidad_entregas,
        SUM(total) as total_dia,
        GROUP_CONCAT(DISTINCT metodo_entrega) as metodos
      FROM entrega_dinero_repartidor
      WHERE id_repartidor = ?
        AND estado = 'completado'
        AND DATE(fecha_entrega) BETWEEN ? AND ?
      GROUP BY DATE(fecha_entrega)
      ORDER BY fecha DESC
    `, [repartidorId, fecha_inicio, fecha_fin]);

    // Calcular totales
    const totalGeneral = resumen.reduce((sum, dia) => sum + parseFloat(dia.total_dia), 0);
    const entregasTotales = resumen.reduce((sum, dia) => sum + dia.cantidad_entregas, 0);

    res.json({
      success: true,
      data: {
        resumen: resumen,
        estadisticas: {
          total_general: totalGeneral,
          entregas_totales: entregasTotales,
          promedio_diario: totalGeneral / (resumen.length || 1),
          dias_con_entregas: resumen.length
        },
        periodo: {
          fecha_inicio: fecha_inicio,
          fecha_fin: fecha_fin,
          dias: Math.ceil((new Date(fecha_fin) - new Date(fecha_inicio)) / (1000 * 60 * 60 * 24)) + 1
        }
      }
    });

  } catch (error) {
    console.error('❌ Error obteniendo resumen:', error);
    res.status(500).json({ 
      error: 'Error interno del servidor al obtener el resumen'
    });
  }
});
/**
 * @route   GET /api/entregas-dinero/dinero-realmente-pendiente
 * @desc    Obtener dinero realmente pendiente (ventas pagadas - entregas registradas)
 * @access  Private (Repartidor)
 */
router.get('/dinero-realmente-pendiente', requireRole([3], 'historial_entregas'), async (req, res) => {
  try {
    // Obtener id_repartidor
    const [repartidores] = await db.execute(`
      SELECT r.id_repartidor 
      FROM repartidor r
      JOIN usuario u ON r.id_persona = u.id_persona
      WHERE u.id_usuario = ?
      LIMIT 1
    `, [req.user.id_usuario]);

    if (repartidores.length === 0) {
      return res.status(404).json({ 
        error: 'Repartidor no encontrado para este usuario' 
      });
    }

    const repartidorId = repartidores[0].id_repartidor;

    // 1. Obtener total de ventas pagadas SIN entregas registradas
    const [ventasPendientes] = await db.execute(`
      SELECT 
        COALESCE(SUM(v.total), 0) as total_pendiente,
        COUNT(*) as ventas_pendientes
      FROM venta v
      WHERE v.id_repartidor = ?
        AND v.id_estado_venta = 7 -- Pagado
        AND v.id_venta NOT IN (
          -- Ventas que ya tienen entrega de dinero registrada
          SELECT DISTINCT edv.id_venta
          FROM entrega_dinero_ventas edv
          JOIN entrega_dinero_repartidor edr ON edv.id_entrega = edr.id_entrega
          WHERE edr.id_repartidor = ?
            AND edr.estado = 'completado'
        )
    `, [repartidorId, repartidorId]);

    res.json({
      success: true,
      data: {
        pendiente: parseFloat(ventasPendientes[0].total_pendiente),
        ventas_pendientes: ventasPendientes[0].ventas_pendientes
      }
    });

  } catch (error) {
    console.error('❌ Error obteniendo dinero realmente pendiente:', error);
    res.status(500).json({ 
      error: 'Error interno del servidor al obtener el dinero pendiente'
    });
  }
});
// En entrega-dinero.routes.js - AGREGAR ESTAS RUTAS
/**
 * @route   GET /api/entregas-dinero/entregas-hoy
 * @desc    Obtener entregas del día actual
 * @access  Private (Repartidor)
 */
router.get('/entregas-hoy', requireRole([3], 'historial_entregas'), async (req, res) => {
  try {
    // Obtener id_repartidor
    const [repartidores] = await db.execute(`
      SELECT r.id_repartidor 
      FROM repartidor r
      JOIN usuario u ON r.id_persona = u.id_persona
      WHERE u.id_usuario = ?
      LIMIT 1
    `, [req.user.id_usuario]);

    if (repartidores.length === 0) {
      return res.status(404).json({ 
        error: 'Repartidor no encontrado para este usuario' 
      });
    }

    const repartidorId = repartidores[0].id_repartidor;

    // Obtener entregas de hoy
    const [entregas] = await db.execute(`
      SELECT 
        id_entrega,
        total,
        metodo_entrega,
        fecha_entrega,
        estado,
        notas
      FROM entrega_dinero_repartidor
      WHERE id_repartidor = ?
        AND DATE(fecha_entrega) = CURDATE()
        AND estado = 'completado'
      ORDER BY fecha_entrega DESC
    `, [repartidorId]);

    // Calcular total del día
    const [totales] = await db.execute(`
      SELECT 
        COALESCE(SUM(total), 0) as total_entregado,
        COUNT(*) as cantidad_entregas
      FROM entrega_dinero_repartidor
      WHERE id_repartidor = ?
        AND DATE(fecha_entrega) = CURDATE()
        AND estado = 'completado'
    `, [repartidorId]);

    res.json({
      success: true,
      data: {
        total_entregado: parseFloat(totales[0].total_entregado),
        cantidad_entregas: totales[0].cantidad_entregas,
        entregas: entregas
      }
    });

  } catch (error) {
    console.error('❌ Error obteniendo entregas de hoy:', error);
    res.status(500).json({ 
      error: 'Error interno del servidor al obtener las entregas de hoy'
    });
  }
});

/**
 * @route   GET /api/entregas-dinero/por-fecha
 * @desc    Obtener entregas por fecha específica
 * @access  Private (Repartidor)
 */
router.get('/por-fecha', requireRole([3], 'historial_entregas'), async (req, res) => {
  try {
    const { fecha } = req.query;
    
    if (!fecha) {
      return res.status(400).json({ 
        error: 'La fecha es requerida' 
      });
    }

    // Obtener id_repartidor
    const [repartidores] = await db.execute(`
      SELECT r.id_repartidor 
      FROM repartidor r
      JOIN usuario u ON r.id_persona = u.id_persona
      WHERE u.id_usuario = ?
      LIMIT 1
    `, [req.user.id_usuario]);

    if (repartidores.length === 0) {
      return res.status(404).json({ 
        error: 'Repartidor no encontrado para este usuario' 
      });
    }

    const repartidorId = repartidores[0].id_repartidor;

    // Obtener entregas por fecha
    const [entregas] = await db.execute(`
      SELECT 
        id_entrega,
        total,
        metodo_entrega,
        fecha_entrega,
        estado,
        notas
      FROM entrega_dinero_repartidor
      WHERE id_repartidor = ?
        AND DATE(fecha_entrega) = ?
        AND estado = 'completado'
      ORDER BY fecha_entrega DESC
    `, [repartidorId, fecha]);

    res.json({
      success: true,
      data: entregas
    });

  } catch (error) {
    console.error('❌ Error obteniendo entregas por fecha:', error);
    res.status(500).json({ 
      error: 'Error interno del servidor al obtener las entregas por fecha'
    });
  }
});
/**
 * @route   GET /api/entregas-dinero/pendiente-hoy
 * @desc    Obtener dinero pendiente de entrega específico de HOY
 * @access  Private (Repartidor)
 */
router.get('/pendiente-hoy', requireRole([3], 'historial_entregas'), async (req, res) => {
  try {
    // Obtener id_repartidor
    const [repartidores] = await db.execute(`
      SELECT r.id_repartidor 
      FROM repartidor r
      JOIN usuario u ON r.id_persona = u.id_persona
      WHERE u.id_usuario = ?
      LIMIT 1
    `, [req.user.id_usuario]);

    if (repartidores.length === 0) {
      return res.status(404).json({ 
        error: 'Repartidor no encontrado para este usuario' 
      });
    }

    const repartidorId = repartidores[0].id_repartidor;

    // Ventas pagadas HOY
    const [ventasHoy] = await db.execute(`
      SELECT 
        COALESCE(SUM(v.total), 0) as total_ventas_hoy,
        COUNT(*) as ventas_hoy
      FROM venta v
      WHERE v.id_repartidor = ?
        AND v.id_estado_venta = 7 -- Pagado
        AND DATE(v.fecha_fin_ruta) = CURDATE()
    `, [repartidorId]);

    // Entregas registradas HOY
    const [entregasHoy] = await db.execute(`
      SELECT 
        COALESCE(SUM(total), 0) as total_entregado_hoy,
        COUNT(*) as entregas_hoy
      FROM entrega_dinero_repartidor
      WHERE id_repartidor = ?
        AND estado = 'completado'
        AND DATE(fecha_entrega) = CURDATE()
    `, [repartidorId]);

    const totalVentas = parseFloat(ventasHoy[0].total_ventas_hoy);
    const totalEntregado = parseFloat(entregasHoy[0].total_entregado_hoy);
    const pendiente = Math.max(0, totalVentas - totalEntregado);

    res.json({
      success: true,
      data: {
        pendiente: pendiente,
        ventas_pendientes: ventasHoy[0].ventas_hoy,
        total_ventas_hoy: totalVentas,
        total_entregado_hoy: totalEntregado
      }
    });

  } catch (error) {
    console.error('❌ Error obteniendo dinero pendiente hoy:', error);
    res.status(500).json({ 
      error: 'Error interno del servidor al obtener el dinero pendiente hoy'
    });
  }
});
export default router;