// src/controllers/pedido_proveedor.controller.js - VERSIÓN COMPLETA ACTUALIZADA
import db from "../config/db.js";

// Obtener todos los pedidos a proveedor CON DETALLES
export const getPedidosProveedor = async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT 
        pp.id_pedido,
        pp.id_proveedor,
        pp.fecha,
        pp.id_estado_pedido,
        pp.total,
        pp.fecha_creacion,
        pp.fecha_actualizacion,
        pr.razon_social as nombre_proveedor,
        ep.estado as nombre_estado
      FROM pedido_proveedor pp
      LEFT JOIN proveedor pr ON pp.id_proveedor = pr.id_proveedor
      LEFT JOIN estado_pedido_proveedor ep ON pp.id_estado_pedido = ep.id_estado_pedido
      ORDER BY pp.fecha DESC, pp.fecha_creacion DESC`);
    
    // Obtener detalles para cada pedido
    const pedidosConDetalles = await Promise.all(
      rows.map(async (pedido) => {
        const [detalles] = await db.query(`
          SELECT 
            ppd.*,
            i.nombre as insumo_nombre,
            i.unidad_medida
          FROM pedido_proveedor_detalle ppd
          LEFT JOIN insumo i ON ppd.id_insumo = i.id_insumo
          WHERE ppd.id_pedido = ?
        `, [pedido.id_pedido]);

        return {
          id_pedido: pedido.id_pedido,
          id_proveedor: pedido.id_proveedor,
          fecha: pedido.fecha,
          id_estado_pedido: pedido.id_estado_pedido,
          total: parseFloat(pedido.total) || 0,
          fecha_creacion: pedido.fecha_creacion,
          fecha_actualizacion: pedido.fecha_actualizacion,
          proveedor: {
            razon_social: pedido.nombre_proveedor
          },
          estado: {
            id_estado_pedido: pedido.id_estado_pedido,
            estado: pedido.nombre_estado
          },
          detalles: detalles.map(det => ({
            id_detalle: det.id_detalle,
            id_insumo: det.id_insumo,
            cantidad: det.cantidad,
            costo_unitario: parseFloat(det.costo_unitario) || 0,
            subtotal: parseFloat(det.subtotal) || 0,
            insumo: {
              nombre: det.insumo_nombre,
              unidad_medida: det.unidad_medida
            }
          }))
        };
      })
    );

    res.json(pedidosConDetalles);
  } catch (error) {
    console.error("Error al obtener pedidos a proveedor:", error);
    res.status(500).json({ message: "Error al obtener pedidos a proveedor" });
  }
};

// Obtener pedido por ID
export const getPedidoProveedorById = async (req, res) => {
  try {
    const [pedidoRows] = await db.query(`
      SELECT 
        pp.*,
        pr.razon_social as nombre_proveedor,
        ep.estado as nombre_estado
      FROM pedido_proveedor pp
      LEFT JOIN proveedor pr ON pp.id_proveedor = pr.id_proveedor
      LEFT JOIN estado_pedido_proveedor ep ON pp.id_estado_pedido = ep.id_estado_pedido
      WHERE pp.id_pedido = ?`,
      [req.params.id]
    );
    
    if (pedidoRows.length === 0) {
      return res.status(404).json({ message: "Pedido no encontrado" });
    }

    const [detallesRows] = await db.query(`
      SELECT 
        ppd.*,
        i.nombre as insumo_nombre,
        i.unidad_medida
      FROM pedido_proveedor_detalle ppd
      LEFT JOIN insumo i ON ppd.id_insumo = i.id_insumo
      WHERE ppd.id_pedido = ?`,
      [req.params.id]
    );

    const pedido = pedidoRows[0];
    const pedidoCompleto = {
      id_pedido: pedido.id_pedido,
      id_proveedor: pedido.id_proveedor,
      fecha: pedido.fecha,
      id_estado_pedido: pedido.id_estado_pedido,
      total: parseFloat(pedido.total) || 0,
      fecha_creacion: pedido.fecha_creacion,
      fecha_actualizacion: pedido.fecha_actualizacion,
      proveedor: {
        razon_social: pedido.nombre_proveedor
      },
      estado: {
        id_estado_pedido: pedido.id_estado_pedido,
        estado: pedido.nombre_estado
      },
      detalles: detallesRows.map(det => ({
        id_detalle: det.id_detalle,
        id_insumo: det.id_insumo,
        cantidad: det.cantidad,
        costo_unitario: parseFloat(det.costo_unitario) || 0,
        subtotal: parseFloat(det.subtotal) || 0,
        insumo: {
          nombre: det.insumo_nombre,
          unidad_medida: det.unidad_medida
        }
      }))
    };

    res.json(pedidoCompleto);
  } catch (error) {
    console.error("Error al obtener pedido:", error);
    res.status(500).json({ message: "Error al obtener pedido" });
  }
};

// Crear nuevo pedido a proveedor CON MÚLTIPLES INSUMOS
export const createPedidoProveedor = async (req, res) => {
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();

    const { 
      id_proveedor, 
      fecha, 
      id_estado_pedido = 1,
      detalles
    } = req.body;

    // Validaciones
    if (!id_proveedor || !fecha || !detalles || !Array.isArray(detalles) || detalles.length === 0) {
      await connection.rollback();
      return res.status(400).json({ message: "Faltan campos obligatorios o detalles vacíos" });
    }

    // Validar proveedor
    const [proveedorRows] = await connection.query(
      "SELECT id_proveedor FROM proveedor WHERE id_proveedor = ? AND activo = 1",
      [id_proveedor]
    );
    
    if (proveedorRows.length === 0) {
      await connection.rollback();
      return res.status(404).json({ message: "Proveedor no encontrado" });
    }

    // Insertar el pedido (cabecera)
    const [result] = await connection.query(
      `INSERT INTO pedido_proveedor 
       (id_proveedor, fecha, id_estado_pedido, total) 
       VALUES (?, ?, ?, 0)`,
      [id_proveedor, fecha, id_estado_pedido]
    );

    const id_pedido = result.insertId;
    let totalPedido = 0;

    // Insertar detalles y validar insumos
    for (const detalle of detalles) {
      const { id_insumo, cantidad, costo_unitario } = detalle;

      // Validar insumo
      const [insumoRows] = await connection.query(
        "SELECT id_insumo FROM insumo WHERE id_insumo = ? AND activo = 1",
        [id_insumo]
      );
      
      if (insumoRows.length === 0) {
        await connection.rollback();
        return res.status(404).json({ message: `Insumo con ID ${id_insumo} no encontrado` });
      }

      // Insertar detalle
      await connection.query(
        `INSERT INTO pedido_proveedor_detalle 
         (id_pedido, id_insumo, cantidad, costo_unitario) 
         VALUES (?, ?, ?, ?)`,
        [id_pedido, id_insumo, cantidad, costo_unitario || 0]
      );

      totalPedido += cantidad * (costo_unitario || 0);
    }

    // Actualizar total del pedido
    await connection.query(
      "UPDATE pedido_proveedor SET total = ? WHERE id_pedido = ?",
      [totalPedido, id_pedido]
    );

    await connection.commit();
    
    // Obtener el pedido creado completo
    const [newPedido] = await connection.query(`
      SELECT 
        pp.*,
        pr.razon_social as nombre_proveedor,
        ep.estado as nombre_estado
      FROM pedido_proveedor pp
      LEFT JOIN proveedor pr ON pp.id_proveedor = pr.id_proveedor
      LEFT JOIN estado_pedido_proveedor ep ON pp.id_estado_pedido = ep.id_estado_pedido
      WHERE pp.id_pedido = ?`,
      [id_pedido]
    );

    const [detallesRows] = await connection.query(`
      SELECT 
        ppd.*,
        i.nombre as insumo_nombre,
        i.unidad_medida
      FROM pedido_proveedor_detalle ppd
      LEFT JOIN insumo i ON ppd.id_insumo = i.id_insumo
      WHERE ppd.id_pedido = ?`,
      [id_pedido]
    );

    const pedidoCompleto = {
      id_pedido: newPedido[0].id_pedido,
      id_proveedor: newPedido[0].id_proveedor,
      fecha: newPedido[0].fecha,
      id_estado_pedido: newPedido[0].id_estado_pedido,
      total: parseFloat(newPedido[0].total) || 0,
      fecha_creacion: newPedido[0].fecha_creacion,
      fecha_actualizacion: newPedido[0].fecha_actualizacion,
      proveedor: {
        razon_social: newPedido[0].nombre_proveedor
      },
      estado: {
        id_estado_pedido: newPedido[0].id_estado_pedido,
        estado: newPedido[0].nombre_estado
      },
      detalles: detallesRows.map(det => ({
        id_detalle: det.id_detalle,
        id_insumo: det.id_insumo,
        cantidad: det.cantidad,
        costo_unitario: parseFloat(det.costo_unitario) || 0,
        subtotal: parseFloat(det.subtotal) || 0,
        insumo: {
          nombre: det.insumo_nombre,
          unidad_medida: det.unidad_medida
        }
      }))
    };

    res.status(201).json({ 
      message: "Pedido a proveedor creado correctamente",
      pedido: pedidoCompleto
    });
  } catch (error) {
    await connection.rollback();
    console.error("Error al crear pedido a proveedor:", error);
    res.status(500).json({ message: "Error al crear pedido a proveedor" });
  } finally {
    connection.release();
  }
};

// Actualizar estado del pedido
export const updatePedidoProveedor = async (req, res) => {
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();

    const { id_estado_pedido } = req.body;
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

    // Actualizar el estado
    await connection.query(
      "UPDATE pedido_proveedor SET id_estado_pedido = ? WHERE id_pedido = ?",
      [id_estado_pedido, id_pedido]
    );

    // Si el estado cambió a "Recibido" (4), actualizar stock de insumos
    if (id_estado_pedido === 4) {
      const id_usuario = req.user.id_usuario;
      
      // Obtener detalles del pedido
      const [detallesRows] = await connection.query(
        "SELECT * FROM pedido_proveedor_detalle WHERE id_pedido = ?",
        [id_pedido]
      );

      // Actualizar stock de cada insumo
      for (const detalle of detallesRows) {
        await connection.query(
          "UPDATE insumo SET stock_actual = stock_actual + ? WHERE id_insumo = ?",
          [detalle.cantidad, detalle.id_insumo]
        );

        // Podrías registrar también un movimiento de stock si lo necesitas
      }
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

    // Eliminar el pedido (los detalles se eliminan en cascada)
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