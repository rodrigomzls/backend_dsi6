// src/controllers/movimiento_stock.controller.js
import db from "../config/db.js";

// Obtener todos los movimientos - VERSIÓN CORREGIDA
export const getMovimientos = async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT 
        m.id_movimiento,
        m.id_producto,
        m.tipo_movimiento,
        m.cantidad,
        m.fecha,
        m.descripcion,
        m.id_usuario,
        m.id_lote,  -- ✅ NUEVO: Incluir id_lote
        p.nombre as nombre_producto,
        u.nombre_usuario,
        per.nombre_completo,
        l.numero_lote,  -- ✅ NUEVO: Información del lote
        l.fecha_caducidad  -- ✅ NUEVO: Fecha de caducidad del lote
      FROM movimiento_stock m
      LEFT JOIN producto p ON m.id_producto = p.id_producto
      LEFT JOIN usuario u ON m.id_usuario = u.id_usuario
      LEFT JOIN persona per ON u.id_persona = per.id_persona
      LEFT JOIN lote_producto l ON m.id_lote = l.id_lote  -- ✅ NUEVO: JOIN con lote
      ORDER BY m.fecha DESC`);
    
    // Mapear a la estructura que espera el frontend
    const movimientosMapeados = rows.map(mov => ({
      id_movimiento: mov.id_movimiento,
      id_producto: mov.id_producto,
      tipo_movimiento: mov.tipo_movimiento,
      cantidad: mov.cantidad,
      fecha: mov.fecha,
      descripcion: mov.descripcion,
      id_usuario: mov.id_usuario,
      id_lote: mov.id_lote,  // ✅ NUEVO: Incluir id_lote
      producto: {
        nombre: mov.nombre_producto
      },
      usuario: {
        id_usuario: mov.id_usuario,
        username: mov.nombre_usuario,
        nombre: mov.nombre_completo
      },
      lote: mov.id_lote ? {  // ✅ NUEVO: Información del lote si existe
        numero_lote: mov.numero_lote,
        fecha_caducidad: mov.fecha_caducidad
      } : null
    }));
    
    res.json(movimientosMapeados);
  } catch (error) {
    console.error("Error al obtener movimientos:", error);
    res.status(500).json({ message: "Error al obtener movimientos" });
  }
};

// Obtener movimientos por producto - VERSIÓN CORREGIDA
export const getMovimientosByProducto = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT 
        m.id_movimiento,
        m.id_producto,
        m.tipo_movimiento,
        m.cantidad,
        m.fecha,
        m.descripcion,
        m.id_usuario,
        m.id_lote,  -- ✅ NUEVO
        p.nombre as nombre_producto,
        u.nombre_usuario,
        per.nombre_completo,
        l.numero_lote,  -- ✅ NUEVO
        l.fecha_caducidad  -- ✅ NUEVO
       FROM movimiento_stock m
       LEFT JOIN producto p ON m.id_producto = p.id_producto
       LEFT JOIN usuario u ON m.id_usuario = u.id_usuario
       LEFT JOIN persona per ON u.id_persona = per.id_persona
       LEFT JOIN lote_producto l ON m.id_lote = l.id_lote  -- ✅ NUEVO
       WHERE m.id_producto = ?
       ORDER BY m.fecha DESC`,
      [req.params.id_producto]
    );
    
    // Mapear a la estructura que espera el frontend
    const movimientosMapeados = rows.map(mov => ({
      id_movimiento: mov.id_movimiento,
      id_producto: mov.id_producto,
      tipo_movimiento: mov.tipo_movimiento,
      cantidad: mov.cantidad,
      fecha: mov.fecha,
      descripcion: mov.descripcion,
      id_usuario: mov.id_usuario,
      id_lote: mov.id_lote,  // ✅ NUEVO
      producto: {
        nombre: mov.nombre_producto
      },
      usuario: {
        id_usuario: mov.id_usuario,
        username: mov.nombre_usuario,
        nombre: mov.nombre_completo
      },
      lote: mov.id_lote ? {  // ✅ NUEVO
        numero_lote: mov.numero_lote,
        fecha_caducidad: mov.fecha_caducidad
      } : null
    }));
    
    res.json(movimientosMapeados);
  } catch (error) {
    console.error("Error al obtener movimientos del producto:", error);
    res.status(500).json({ message: "Error al obtener movimientos del producto" });
  }
};

export const createMovimiento = async (req, res) => {
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();

    const { id_producto, tipo_movimiento, cantidad, descripcion, id_lote } = req.body;
    const id_usuario = req.user.id_usuario;

    console.log('📦 DATOS MOVIMIENTO RECIBIDOS:', { 
      id_producto, tipo_movimiento, cantidad, id_lote, id_usuario 
    });

    // Validaciones básicas
    if (!id_producto || !tipo_movimiento || !cantidad) {
      await connection.rollback();
      return res.status(400).json({ message: "Faltan campos obligatorios" });
    }

    const tiposValidos = ['ingreso', 'egreso', 'ajuste', 'devolucion'];
    if (!tiposValidos.includes(tipo_movimiento)) {
      await connection.rollback();
      return res.status(400).json({ message: "Tipo de movimiento no válido" });
    }

    // Si es egreso/ajuste y tiene lote, validar stock del lote
    if (id_lote && (tipo_movimiento === 'egreso' || tipo_movimiento === 'ajuste')) {
      const [loteRows] = await connection.query(
        'SELECT cantidad_actual FROM lote_producto WHERE id_lote = ? AND activo = 1',
        [id_lote]
      );
      
      if (loteRows.length === 0) {
        await connection.rollback();
        return res.status(404).json({ message: "Lote no encontrado" });
      }
      
      if (loteRows[0].cantidad_actual < cantidad) {
        await connection.rollback();
        return res.status(400).json({ 
          message: `Stock insuficiente en el lote. Disponible: ${loteRows[0].cantidad_actual}` 
        });
      }
    }

    // Insertar movimiento
    const [result] = await connection.query(
      `INSERT INTO movimiento_stock 
       (id_producto, tipo_movimiento, cantidad, descripcion, id_usuario, id_lote) 
       VALUES (?, ?, ?, ?, ?, ?)`,
      [id_producto, tipo_movimiento, cantidad, descripcion, id_usuario, id_lote || null]
    );

    // Actualizar stock del producto
    const stockModificacion = (tipo_movimiento === 'ingreso' || tipo_movimiento === 'devolucion') ? cantidad : -cantidad;
    await connection.query(
      `UPDATE producto SET stock = stock + ? WHERE id_producto = ?`,
      [stockModificacion, id_producto]
    );

    // Si tiene lote, actualizar cantidad del lote
    if (id_lote) {
      const loteModificacion = (tipo_movimiento === 'ingreso' || tipo_movimiento === 'devolucion') ? cantidad : -cantidad;
      await connection.query(
        `UPDATE lote_producto SET cantidad_actual = cantidad_actual + ? WHERE id_lote = ?`,
        [loteModificacion, id_lote]
      );
    }

    await connection.commit();
    
    // Obtener información completa del movimiento creado
    const [movimientoCompleto] = await connection.query(`
      SELECT m.*, p.nombre as nombre_producto, lp.numero_lote
      FROM movimiento_stock m
      LEFT JOIN producto p ON m.id_producto = p.id_producto
      LEFT JOIN lote_producto lp ON m.id_lote = lp.id_lote
      WHERE m.id_movimiento = ?
    `, [result.insertId]);

    res.status(201).json({ 
      movimiento: movimientoCompleto[0],
      message: "Movimiento registrado correctamente" 
    });
  } catch (error) {
    await connection.rollback();
    console.error("❌ ERROR al crear movimiento:", error);
    res.status(500).json({ 
      message: "Error al registrar movimiento",
      error: error.message 
    });
  } finally {
    connection.release();
  }
};
// ... mantener los métodos updateMovimiento y deleteMovimiento existentes

// Actualizar movimiento
export const updateMovimiento = async (req, res) => {
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();

    const { id_producto, tipo_movimiento, cantidad, descripcion } = req.body;
    const id_movimiento = req.params.id;
    const id_usuario = req.user.id_usuario;

    // Obtener movimiento actual
    const [movimientoRows] = await connection.query(
      "SELECT * FROM movimiento_stock WHERE id_movimiento = ?",
      [id_movimiento]
    );
    
    if (movimientoRows.length === 0) {
      await connection.rollback();
      return res.status(404).json({ message: "Movimiento no encontrado" });
    }

    const movimientoActual = movimientoRows[0];

    // Revertir el movimiento anterior
    const stockModificacionAnterior = (movimientoActual.tipo_movimiento === 'ingreso' || movimientoActual.tipo_movimiento === 'devolucion') 
      ? -movimientoActual.cantidad 
      : movimientoActual.cantidad;

    await connection.query(
      `UPDATE producto SET stock = stock + ? WHERE id_producto = ?`,
      [stockModificacionAnterior, movimientoActual.id_producto]
    );

    // Aplicar el nuevo movimiento
    const stockModificacionNuevo = (tipo_movimiento === 'ingreso' || tipo_movimiento === 'devolucion') 
      ? cantidad 
      : -cantidad;

    await connection.query(
      `UPDATE producto SET stock = stock + ? WHERE id_producto = ?`,
      [stockModificacionNuevo, id_producto]
    );

    // Actualizar el movimiento
    await connection.query(
      `UPDATE movimiento_stock 
       SET id_producto = ?, tipo_movimiento = ?, cantidad = ?, descripcion = ?, id_usuario = ?
       WHERE id_movimiento = ?`,
      [id_producto, tipo_movimiento, cantidad, descripcion, id_usuario, id_movimiento]
    );

    await connection.commit();
    
    res.json({ 
      message: "Movimiento actualizado correctamente" 
    });
  } catch (error) {
    await connection.rollback();
    console.error("Error al actualizar movimiento:", error);
    res.status(500).json({ message: "Error al actualizar movimiento" });
  } finally {
    connection.release();
  }
};

// Eliminar movimiento
export const deleteMovimiento = async (req, res) => {
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();

    const id_movimiento = req.params.id;

    // Obtener movimiento
    const [movimientoRows] = await connection.query(
      "SELECT * FROM movimiento_stock WHERE id_movimiento = ?",
      [id_movimiento]
    );
    
    if (movimientoRows.length === 0) {
      await connection.rollback();
      return res.status(404).json({ message: "Movimiento no encontrado" });
    }

    const movimiento = movimientoRows[0];

    // Revertir el efecto en el stock
    const stockModificacion = (movimiento.tipo_movimiento === 'ingreso' || movimiento.tipo_movimiento === 'devolucion') 
      ? -movimiento.cantidad 
      : movimiento.cantidad;

    await connection.query(
      `UPDATE producto SET stock = stock + ? WHERE id_producto = ?`,
      [stockModificacion, movimiento.id_producto]
    );

    // Eliminar el movimiento
    await connection.query(
      "DELETE FROM movimiento_stock WHERE id_movimiento = ?",
      [id_movimiento]
    );

    await connection.commit();
    
    res.json({ 
      message: "Movimiento eliminado correctamente" 
    });
  } catch (error) {
    await connection.rollback();
    console.error("Error al eliminar movimiento:", error);
    res.status(500).json({ message: "Error al eliminar movimiento" });
  } finally {
    connection.release();
  }
};