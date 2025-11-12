// src/controllers/lote.controller.js
import db from "../config/db.js";

// Obtener todos los lotes
export const getLotes = async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT 
        l.id_lote,
        l.id_producto,
        l.numero_lote,
        l.fecha_caducidad,
        l.cantidad_inicial,
        l.cantidad_actual,
        l.fecha_creacion,
        l.activo,
        p.nombre as nombre_producto,
        m.nombre as nombre_marca,
        c.nombre as nombre_categoria
      FROM lote_producto l
      LEFT JOIN producto p ON l.id_producto = p.id_producto
      LEFT JOIN marcas m ON p.id_marca = m.id_marca
      LEFT JOIN categorias c ON p.id_categoria = c.id_categoria
      WHERE l.activo = 1
      ORDER BY l.fecha_caducidad ASC, l.fecha_creacion DESC`);
    
    // Mapear a la estructura que espera el frontend
    const lotesMapeados = rows.map(lote => ({
      id_lote: lote.id_lote,
      id_producto: lote.id_producto,
      numero_lote: lote.numero_lote,
     fecha_caducidad: lote.fecha_caducidad,
      cantidad_inicial: lote.cantidad_inicial,
      cantidad_actual: lote.cantidad_actual,
      fecha_creacion: lote.fecha_creacion,
      activo: lote.activo,
      producto: {
        nombre: lote.nombre_producto,
        marca: lote.nombre_marca,
        categoria: lote.nombre_categoria
      }
    }));
    
    res.json(lotesMapeados);
  } catch (error) {
    console.error("Error al obtener lotes:", error);
    res.status(500).json({ message: "Error al obtener lotes" });
  }
};

// Obtener lote por ID
export const getLoteById = async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT 
        l.*,
        p.nombre as nombre_producto,
        m.nombre as nombre_marca,
        c.nombre as nombre_categoria
      FROM lote_producto l
      LEFT JOIN producto p ON l.id_producto = p.id_producto
      LEFT JOIN marcas m ON p.id_marca = m.id_marca
      LEFT JOIN categorias c ON p.id_categoria = c.id_categoria
      WHERE l.id_lote = ? AND l.activo = 1`,
      [req.params.id]
    );
    
    if (rows.length === 0) {
      return res.status(404).json({ message: "Lote no encontrado" });
    }
    
    const lote = rows[0];
    const loteMapeado = {
      id_lote: lote.id_lote,
      id_producto: lote.id_producto,
      numero_lote: lote.numero_lote,
       fecha_caducidad: lote.fecha_caducidad,
      cantidad_inicial: lote.cantidad_inicial,
      cantidad_actual: lote.cantidad_actual,
      fecha_creacion: lote.fecha_creacion,
      activo: lote.activo,
      producto: {
        nombre: lote.nombre_producto,
        marca: lote.nombre_marca,
        categoria: lote.nombre_categoria
      }
    };
    
    res.json(loteMapeado);
  } catch (error) {
    console.error("Error al obtener lote:", error);
    res.status(500).json({ message: "Error al obtener lote" });
  }
};

// Crear nuevo lote
export const createLote = async (req, res) => {
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();

    const { id_producto, numero_lote, fecha_caducidad, cantidad_inicial } = req.body;
    const id_usuario = req.user.id_usuario;

    // ✅ DEBUG DETALLADO
    console.log('📦 DATOS RECIBIDOS EN BACKEND:');
    console.log('   - id_producto:', id_producto);
    console.log('   - numero_lote:', numero_lote);
    console.log('   - fecha_caducidad:', fecha_caducidad, '(tipo:', typeof fecha_caducidad, ')');
    console.log('   - cantidad_inicial:', cantidad_inicial);
    console.log('   - id_usuario:', id_usuario);

    // Validar que todos los campos estén presentes
    if (!fecha_caducidad) {
      console.log('❌ ERROR: fecha_caducidad es null o undefined');
      await connection.rollback();
      return res.status(400).json({ 
        message: "La fecha de caducidad es obligatoria",
        details: `Fecha recibida: ${fecha_caducidad}`
      });
    }

    // Validar que el producto exista
    const [productoRows] = await connection.query(
      "SELECT id_producto FROM producto WHERE id_producto = ? AND activo = 1",
      [id_producto]
    );
    
    if (productoRows.length === 0) {
      await connection.rollback();
      return res.status(404).json({ message: "Producto no encontrado" });
    }

    // Verificar si ya existe un lote con el mismo número
    const [loteExistente] = await connection.query(
      "SELECT id_lote FROM lote_producto WHERE numero_lote = ? AND activo = 1",
      [numero_lote]
    );
    
    if (loteExistente.length > 0) {
      await connection.rollback();
      return res.status(409).json({ message: "Ya existe un lote con este número" });
    }

    // Insertar el lote
    const [result] = await connection.query(
      `INSERT INTO lote_producto 
       (id_producto, numero_lote, fecha_caducidad, cantidad_inicial, cantidad_actual) 
       VALUES (?, ?, ?, ?, ?)`,
      [id_producto, numero_lote, fecha_caducidad, cantidad_inicial, cantidad_inicial]
    );

    // Registrar movimiento de stock (ingreso)
    await connection.query(
      `INSERT INTO movimiento_stock 
       (id_producto, tipo_movimiento, cantidad, descripcion, id_usuario) 
       VALUES (?, 'ingreso', ?, 'Ingreso por creación de lote ${numero_lote}', ?)`,
      [id_producto, cantidad_inicial, id_usuario]
    );

    // Actualizar stock del producto
    await connection.query(
      "UPDATE producto SET stock = stock + ? WHERE id_producto = ?",
      [cantidad_inicial, id_producto]
    );

    await connection.commit();
    
    res.status(201).json({ 
      id_lote: result.insertId,
      message: "Lote creado correctamente" 
    });
   } catch (error) {
    await connection.rollback();
    console.error("❌ ERROR DETALLADO al crear lote:", error);
    res.status(500).json({ 
      message: "Error al crear lote",
      error: error.message,
      sql: error.sql 
    });
  } finally {
    connection.release();
  }
};

// Actualizar lote
export const updateLote = async (req, res) => {
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();

    const { id_producto, numero_lote, fecha_caducidad, cantidad_actual } = req.body;
    const id_lote = req.params.id;

    // Verificar que el lote existe
    const [loteRows] = await connection.query(
      "SELECT * FROM lote_producto WHERE id_lote = ? AND activo = 1",
      [id_lote]
    );
    
    if (loteRows.length === 0) {
      await connection.rollback();
      return res.status(404).json({ message: "Lote no encontrado" });
    }

    const loteActual = loteRows[0];

    // Verificar si el nuevo número de lote ya existe (excluyendo el actual)
    const [loteExistente] = await connection.query(
      "SELECT id_lote FROM lote_producto WHERE numero_lote = ? AND id_lote != ? AND activo = 1",
      [numero_lote, id_lote]
    );
    
    if (loteExistente.length > 0) {
      await connection.rollback();
      return res.status(409).json({ message: "Ya existe otro lote con este número" });
    }

    // Actualizar el lote
    await connection.query(
      `UPDATE lote_producto 
       SET id_producto = ?, numero_lote = ?, fecha_caducidad = ?, cantidad_actual = ?
       WHERE id_lote = ?`,
      [id_producto, numero_lote, fecha_caducidad, cantidad_actual, id_lote]
    );

    // Si cambió la cantidad, registrar movimiento de ajuste
    if (cantidad_actual !== loteActual.cantidad_actual) {
      const diferencia = cantidad_actual - loteActual.cantidad_actual;
      const id_usuario = req.user.id_usuario;
      
      await connection.query(
        `INSERT INTO movimiento_stock 
         (id_producto, tipo_movimiento, cantidad, descripcion, id_usuario) 
         VALUES (?, 'ajuste', ?, 'Ajuste de cantidad en lote ${numero_lote}', ?)`,
        [id_producto, diferencia, id_usuario]
      );

      // Actualizar stock del producto
      await connection.query(
        "UPDATE producto SET stock = stock + ? WHERE id_producto = ?",
        [diferencia, id_producto]
      );
    }

    await connection.commit();
    
    res.json({ 
      message: "Lote actualizado correctamente" 
    });
  } catch (error) {
    await connection.rollback();
    console.error("Error al actualizar lote:", error);
    res.status(500).json({ message: "Error al actualizar lote" });
  } finally {
    connection.release();
  }
};

// Eliminar lote (soft delete)
export const deleteLote = async (req, res) => {
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();

    const id_lote = req.params.id;
    const id_usuario = req.user.id_usuario;

    // Obtener información del lote antes de eliminar
    const [loteRows] = await connection.query(
      "SELECT * FROM lote_producto WHERE id_lote = ? AND activo = 1",
      [id_lote]
    );
    
    if (loteRows.length === 0) {
      await connection.rollback();
      return res.status(404).json({ message: "Lote no encontrado" });
    }

    const lote = loteRows[0];

    // Registrar movimiento de stock (egreso por eliminación)
    await connection.query(
      `INSERT INTO movimiento_stock 
       (id_producto, tipo_movimiento, cantidad, descripcion, id_usuario) 
       VALUES (?, 'egreso', ?, 'Eliminación de lote ${lote.numero_lote}', ?)`,
      [lote.id_producto, lote.cantidad_actual, id_usuario]
    );

    // Actualizar stock del producto
    await connection.query(
      "UPDATE producto SET stock = stock - ? WHERE id_producto = ?",
      [lote.cantidad_actual, lote.id_producto]
    );

    // Soft delete del lote
    await connection.query(
      "UPDATE lote_producto SET activo = 0 WHERE id_lote = ?",
      [id_lote]
    );

    await connection.commit();
    
    res.json({ 
      message: "Lote eliminado correctamente" 
    });
  } catch (error) {
    await connection.rollback();
    console.error("Error al eliminar lote:", error);
    res.status(500).json({ message: "Error al eliminar lote" });
  } finally {
    connection.release();
  }
};