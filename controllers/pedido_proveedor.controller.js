// src/controllers/pedido_proveedor.controller.js
import db from "../config/db.js";

// Obtener todos los pedidos a proveedor
export const getPedidosProveedor = async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT 
        pp.id_pedido,
        pp.id_proveedor,
        pp.id_producto,
        pp.fecha,
        pp.cantidad,
        pp.id_estado_pedido,
        pp.costo_unitario,
        pp.total,
        pp.fecha_creacion,
        pp.fecha_actualizacion,
        pr.razon_social as nombre_proveedor,
        p.nombre as nombre_producto,
        p.descripcion as descripcion_producto,
        ep.id_estado_pedido,
        ep.estado as nombre_estado
      FROM pedido_proveedor pp
      LEFT JOIN proveedor pr ON pp.id_proveedor = pr.id_proveedor
      LEFT JOIN producto p ON pp.id_producto = p.id_producto
      LEFT JOIN estado_pedido_proveedor ep ON pp.id_estado_pedido = ep.id_estado_pedido
      ORDER BY pp.fecha DESC, pp.fecha_creacion DESC`);
    
    // Mapear a la estructura que espera el frontend
    const pedidosMapeados = rows.map(pedido => ({
      id_pedido: pedido.id_pedido,
      id_proveedor: pedido.id_proveedor,
      id_producto: pedido.id_producto,
      fecha: pedido.fecha,
      cantidad: pedido.cantidad,
      id_estado_pedido: pedido.id_estado_pedido,
      costo_unitario: parseFloat(pedido.costo_unitario) || 0,
      total: parseFloat(pedido.total) || 0,
      fecha_creacion: pedido.fecha_creacion,
      fecha_actualizacion: pedido.fecha_actualizacion,
      proveedor: {
        razon_social: pedido.nombre_proveedor
      },
      producto: {
        nombre: pedido.nombre_producto,
        descripcion: pedido.descripcion_producto
      },
      estado: { // ✅ Cambiado de 'estado_pedido' a 'estado'
        id_estado_pedido: pedido.id_estado_pedido,
        estado: pedido.nombre_estado
      }
    }));
    
    res.json(pedidosMapeados);
  } catch (error) {
    console.error("Error al obtener pedidos a proveedor:", error);
    res.status(500).json({ message: "Error al obtener pedidos a proveedor" });
  }
};

// Obtener pedido por ID
export const getPedidoProveedorById = async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT 
        pp.*,
        pr.razon_social as nombre_proveedor,
        p.nombre as nombre_producto,
        p.descripcion as descripcion_producto,
        ep.id_estado_pedido,
        ep.estado as nombre_estado
      FROM pedido_proveedor pp
      LEFT JOIN proveedor pr ON pp.id_proveedor = pr.id_proveedor
      LEFT JOIN producto p ON pp.id_producto = p.id_producto
      LEFT JOIN estado_pedido_proveedor ep ON pp.id_estado_pedido = ep.id_estado_pedido
      WHERE pp.id_pedido = ?`,
      [req.params.id]
    );
    
    if (rows.length === 0) {
      return res.status(404).json({ message: "Pedido no encontrado" });
    }
    
    const pedido = rows[0];
    const pedidoMapeado = {
      id_pedido: pedido.id_pedido,
      id_proveedor: pedido.id_proveedor,
      id_producto: pedido.id_producto,
      fecha: pedido.fecha,
      cantidad: pedido.cantidad,
      id_estado_pedido: pedido.id_estado_pedido,
      costo_unitario: parseFloat(pedido.costo_unitario) || 0,
      total: parseFloat(pedido.total) || 0,
      fecha_creacion: pedido.fecha_creacion,
      fecha_actualizacion: pedido.fecha_actualizacion,
      proveedor: {
        razon_social: pedido.nombre_proveedor
      },
      producto: {
        nombre: pedido.nombre_producto,
        descripcion: pedido.descripcion_producto
      },
      estado: { // ✅ Cambiado de 'estado_pedido' a 'estado'
        id_estado_pedido: pedido.id_estado_pedido,
        estado: pedido.nombre_estado
      }
    };
    
    res.json(pedidoMapeado);
  } catch (error) {
    console.error("Error al obtener pedido:", error);
    res.status(500).json({ message: "Error al obtener pedido" });
  }
};

// Crear nuevo pedido a proveedor
export const createPedidoProveedor = async (req, res) => {
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();

    const { 
      id_proveedor, 
      id_producto, 
      fecha, 
      cantidad, 
      id_estado_pedido = 1, // Por defecto: Solicitado
      costo_unitario 
    } = req.body;

    // Validar que el proveedor exista
    const [proveedorRows] = await connection.query(
      "SELECT id_proveedor FROM proveedor WHERE id_proveedor = ? AND activo = 1",
      [id_proveedor]
    );
    
    if (proveedorRows.length === 0) {
      await connection.rollback();
      return res.status(404).json({ message: "Proveedor no encontrado" });
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

    // Calcular total
    const total = cantidad * (costo_unitario || 0);

    // Insertar el pedido
    const [result] = await connection.query(
      `INSERT INTO pedido_proveedor 
       (id_proveedor, id_producto, fecha, cantidad, id_estado_pedido, costo_unitario, total) 
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [id_proveedor, id_producto, fecha, cantidad, id_estado_pedido, costo_unitario, total]
    );

    await connection.commit();
    
    res.status(201).json({ 
      id_pedido: result.insertId,
      message: "Pedido a proveedor creado correctamente" 
    });
  } catch (error) {
    await connection.rollback();
    console.error("Error al crear pedido a proveedor:", error);
    res.status(500).json({ message: "Error al crear pedido a proveedor" });
  } finally {
    connection.release();
  }
};

// Actualizar pedido a proveedor
export const updatePedidoProveedor = async (req, res) => {
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();

    const { 
      cantidad, 
      id_estado_pedido,
      costo_unitario 
    } = req.body;
    
    const id_pedido = req.params.id;

    // Verificar que el pedido existe
    const [pedidoRows] = await connection.query(
      "SELECT * FROM pedido_proveedor WHERE id_pedido = ?",
      [id_pedido]
    );
    
    if (pedidoRows.length === 0) {
      await connection.rollback();
      return res.status(404).json({ message: "Pedido no encontrado" });
    }

    const pedidoActual = pedidoRows[0];

    // Calcular total
    const total = cantidad * (costo_unitario || pedidoActual.costo_unitario || 0);

    // Actualizar el pedido
    await connection.query(
      `UPDATE pedido_proveedor 
       SET cantidad = ?, id_estado_pedido = ?, costo_unitario = ?, total = ?
       WHERE id_pedido = ?`,
      [cantidad, id_estado_pedido, costo_unitario, total, id_pedido]
    );

    // Si el estado cambió a "Recibido" (4), actualizar stock
    if (id_estado_pedido === 4 && pedidoActual.id_estado_pedido !== 4) {
      const id_usuario = req.user.id_usuario;
      
      // Registrar movimiento de stock (ingreso)
      await connection.query(
        `INSERT INTO movimiento_stock 
         (id_producto, tipo_movimiento, cantidad, descripcion, id_usuario) 
         VALUES (?, 'ingreso', ?, 'Ingreso por pedido a proveedor #${id_pedido}', ?)`,
        [pedidoActual.id_producto, cantidad, id_usuario]
      );

      // Actualizar stock del producto
      await connection.query(
        "UPDATE producto SET stock = stock + ? WHERE id_producto = ?",
        [cantidad, pedidoActual.id_producto]
      );
    }

    await connection.commit();
    
    res.json({ 
      message: "Pedido a proveedor actualizado correctamente" 
    });
  } catch (error) {
    await connection.rollback();
    console.error("Error al actualizar pedido a proveedor:", error);
    res.status(500).json({ message: "Error al actualizar pedido a proveedor" });
  } finally {
    connection.release();
  }
};

// Eliminar pedido a proveedor
export const deletePedidoProveedor = async (req, res) => {
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();

    const id_pedido = req.params.id;

    // Verificar que el pedido existe
    const [pedidoRows] = await connection.query(
      "SELECT * FROM pedido_proveedor WHERE id_pedido = ?",
      [id_pedido]
    );
    
    if (pedidoRows.length === 0) {
      await connection.rollback();
      return res.status(404).json({ message: "Pedido no encontrado" });
    }

    // Eliminar el pedido
    await connection.query(
      "DELETE FROM pedido_proveedor WHERE id_pedido = ?",
      [id_pedido]
    );

    await connection.commit();
    
    res.json({ 
      message: "Pedido a proveedor eliminado correctamente" 
    });
  } catch (error) {
    await connection.rollback();
    console.error("Error al eliminar pedido a proveedor:", error);
    res.status(500).json({ message: "Error al eliminar pedido a proveedor" });
  } finally {
    connection.release();
  }
};

// Obtener estados de pedido
export const getEstadosPedido = async (req, res) => {
  try {
    const [rows] = await db.query("SELECT * FROM estado_pedido_proveedor");
    res.json(rows);
  } catch (error) {
    console.error("Error al obtener estados de pedido:", error);
    res.status(500).json({ message: "Error al obtener estados de pedido" });
  }
};