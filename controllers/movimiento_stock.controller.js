// src/controllers/movimiento_stock.controller.js
import db from "../config/db.js";

// Obtener todos los movimientos
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
        p.nombre as nombre_producto,
        u.nombre_usuario,
        per.nombre_completo
      FROM movimiento_stock m
      LEFT JOIN producto p ON m.id_producto = p.id_producto
      LEFT JOIN usuario u ON m.id_usuario = u.id_usuario
      LEFT JOIN persona per ON u.id_persona = per.id_persona
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
      producto: {
        nombre: mov.nombre_producto
      },
      usuario: {
        id_usuario: mov.id_usuario,
        username: mov.nombre_usuario,
        nombre: mov.nombre_completo
      }
    }));
    
    res.json(movimientosMapeados);
  } catch (error) {
    console.error("Error al obtener movimientos:", error);
    res.status(500).json({ message: "Error al obtener movimientos" });
  }
};

// Obtener movimientos por producto
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
        p.nombre as nombre_producto,
        u.nombre_usuario,
        per.nombre_completo
       FROM movimiento_stock m
       LEFT JOIN producto p ON m.id_producto = p.id_producto
       LEFT JOIN usuario u ON m.id_usuario = u.id_usuario
       LEFT JOIN persona per ON u.id_persona = per.id_persona
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
      producto: {
        nombre: mov.nombre_producto
      },
      usuario: {
        id_usuario: mov.id_usuario,
        username: mov.nombre_usuario,
        nombre: mov.nombre_completo
      }
    }));
    
    res.json(movimientosMapeados);
  } catch (error) {
    console.error("Error al obtener movimientos del producto:", error);
    res.status(500).json({ message: "Error al obtener movimientos del producto" });
  }
};

// Registrar nuevo movimiento
export const createMovimiento = async (req, res) => {
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();

    const { id_producto, tipo_movimiento, cantidad, descripcion } = req.body;
    const id_usuario = req.user.id_usuario; // Del middleware verifyToken

    // Validar tipo de movimiento
    const tiposValidos = ['ingreso', 'egreso', 'ajuste', 'venta', 'devolucion'];
    if (!tiposValidos.includes(tipo_movimiento)) {
      return res.status(400).json({ message: "Tipo de movimiento no válido" });
    }

    // Insertar el movimiento
    const [result] = await connection.query(
      `INSERT INTO movimiento_stock 
       (id_producto, tipo_movimiento, cantidad, descripcion, id_usuario) 
       VALUES (?, ?, ?, ?, ?)`,
      [id_producto, tipo_movimiento, cantidad, descripcion, id_usuario]
    );

    // Actualizar stock del producto
    const stockModificacion = (tipo_movimiento === 'ingreso' || tipo_movimiento === 'devolucion') ? cantidad : -cantidad;
    await connection.query(
      `UPDATE producto SET stock = stock + ? WHERE id_producto = ?`,
      [stockModificacion, id_producto]
    );

    await connection.commit();
    
    res.status(201).json({ 
      id_movimiento: result.insertId,
      message: "Movimiento registrado correctamente" 
    });
  } catch (error) {
    await connection.rollback();
    console.error("Error al crear movimiento:", error);
    res.status(500).json({ message: "Error al registrar movimiento" });
  } finally {
    connection.release();
  }
};

// ... métodos existentes

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