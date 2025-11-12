// src/controllers/venta.controller.js
import db from '../config/db.js';

// src/controllers/venta.controller.js - solo la parte de getVentas
export const getVentas = async (req, res) => {
    try {
        const [ventas] = await db.execute(`
            SELECT 
                v.id_venta,
                v.id_cliente,
                DATE_FORMAT(v.fecha, '%Y-%m-%d') as fecha,  -- ✅ FORMATO EXPLÍCITO
                TIME(v.hora) as hora,
                v.total,
                v.id_metodo_pago,
                v.id_estado_venta,
                v.id_repartidor,
                v.id_vendedor,
                v.notas,
                v.fecha_creacion,
                v.fecha_actualizacion,
                c.razon_social, 
                p_cliente.telefono,
                p_cliente.direccion,
                p_cliente.nombre_completo,
                ev.estado, 
                mp.metodo_pago, 
                u.nombre_usuario as vendedor,
                p_repartidor.nombre_completo as repartidor
            FROM venta v
            LEFT JOIN cliente c ON v.id_cliente = c.id_cliente
            LEFT JOIN persona p_cliente ON c.id_persona = p_cliente.id_persona
            LEFT JOIN estado_venta ev ON v.id_estado_venta = ev.id_estado_venta
            LEFT JOIN metodo_pago mp ON v.id_metodo_pago = mp.id_metodo_pago
            LEFT JOIN usuario u ON v.id_vendedor = u.id_usuario
            LEFT JOIN repartidor r ON v.id_repartidor = r.id_repartidor
            LEFT JOIN persona p_repartidor ON r.id_persona = p_repartidor.id_persona
            ORDER BY v.fecha_creacion DESC
        `);
        
        console.log('📊 Ventas obtenidas:', ventas.length);
        res.json(ventas);
    } catch (error) {
        console.error('❌ Error en getVentas:', error);
        res.status(500).json({ error: error.message });
    }
};

export const getVentaById = async (req, res) => {
    try {
        const { id } = req.params;
        const [ventas] = await db.execute(`
            SELECT 
                v.id_venta,
                v.id_cliente,
                DATE(v.fecha) as fecha,  -- ✅ FORMATO CORRECTO
                TIME(v.hora) as hora,    -- ✅ FORMATO CORRECTO
                v.total,
                v.id_metodo_pago,
                v.id_estado_venta,
                v.id_repartidor,
                v.id_vendedor,
                v.notas,
                v.fecha_creacion,
                v.fecha_actualizacion,
                c.razon_social, 
                p_cliente.telefono,
                p_cliente.direccion,
                p_cliente.nombre_completo,
                ev.estado, 
                mp.metodo_pago,
                u.nombre_usuario as vendedor,
                p_repartidor.nombre_completo as repartidor
            FROM venta v
            LEFT JOIN cliente c ON v.id_cliente = c.id_cliente
            LEFT JOIN persona p_cliente ON c.id_persona = p_cliente.id_persona
            LEFT JOIN estado_venta ev ON v.id_estado_venta = ev.id_estado_venta
            LEFT JOIN metodo_pago mp ON v.id_metodo_pago = mp.id_metodo_pago
            LEFT JOIN usuario u ON v.id_vendedor = u.id_usuario
            LEFT JOIN repartidor r ON v.id_repartidor = r.id_repartidor
            LEFT JOIN persona p_repartidor ON r.id_persona = p_repartidor.id_persona
            WHERE v.id_venta = ?
        `, [id]);

        if (ventas.length === 0) {
            return res.status(404).json({ error: 'Venta no encontrada' });
        }

        const [detalles] = await db.execute(`
            SELECT vd.*, p.nombre as producto_nombre, p.precio
            FROM venta_detalle vd
            JOIN producto p ON vd.id_producto = p.id_producto
            WHERE vd.id_venta = ?
        `, [id]);

        const venta = ventas[0];
        
        res.json({
            ...venta,
            detalles
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
// En venta.controller.js - mejora las validaciones de detalles
// En createVenta - MODIFICAR para manejar lotes específicos
export const createVenta = async (req, res) => {
  const connection = await db.getConnection();
  
  try {
    await connection.beginTransaction();

    const {
      id_cliente,
      id_metodo_pago,
      id_estado_venta = 1,
      id_repartidor = null,
      notas = '',
      detalles = []
    } = req.body;

    // Validaciones (mantener las existentes)
    if (!id_cliente || id_cliente === 0) {
      return res.status(400).json({ error: 'Cliente es requerido' });
    }
    if (!id_metodo_pago) {
      return res.status(400).json({ error: 'Método de pago es requerido' });
    }
    if (!detalles || detalles.length === 0) {
      return res.status(400).json({ error: 'Debe agregar al menos un producto' });
    }

    // 1. Crear la venta
    const [result] = await connection.execute(`
      INSERT INTO venta (id_cliente, fecha, hora, total, id_metodo_pago, 
                       id_estado_venta, id_repartidor, id_vendedor, notas)
      VALUES (?, CURDATE(), CURTIME(), 0, ?, ?, ?, ?, ?)
    `, [
      id_cliente, 
      id_metodo_pago, 
      id_estado_venta, 
      id_repartidor, 
      req.user.id_usuario, 
      notas
    ]);

    const id_venta = result.insertId;
    let total_venta = 0;

    // 2. Procesar detalles y asignar lotes (FIFO)
    for (const detalle of detalles) {
      const { id_producto, cantidad, precio_unitario } = detalle;
      const subtotal = cantidad * precio_unitario;
      total_venta += subtotal;

      // Insertar detalle de venta
      const [detalleResult] = await connection.execute(`
        INSERT INTO venta_detalle (id_venta, id_producto, cantidad, precio_unitario)
        VALUES (?, ?, ?, ?)
      `, [id_venta, id_producto, cantidad, precio_unitario]);

      const id_detalle_venta = detalleResult.insertId;

      // Obtener lotes disponibles (FIFO - por fecha de caducidad)
      const [lotes] = await connection.execute(`
        SELECT id_lote, cantidad_actual, numero_lote
        FROM lote_producto 
        WHERE id_producto = ? AND cantidad_actual > 0 AND activo = 1
        ORDER BY fecha_caducidad ASC
      `, [id_producto]);

      let cantidadRestante = cantidad;

      // Asignar lotes específicos
      for (const lote of lotes) {
        if (cantidadRestante <= 0) break;

        const cantidadATomar = Math.min(cantidadRestante, lote.cantidad_actual);
        
        // Registrar en venta_detalle_lote
        await connection.execute(`
          INSERT INTO venta_detalle_lote (id_detalle_venta, id_lote, cantidad)
          VALUES (?, ?, ?)
        `, [id_detalle_venta, lote.id_lote, cantidadATomar]);

        // Actualizar stock del lote
        await connection.execute(`
          UPDATE lote_producto 
          SET cantidad_actual = cantidad_actual - ? 
          WHERE id_lote = ?
        `, [cantidadATomar, lote.id_lote]);

        // Registrar movimiento de stock por lote
        await connection.execute(`
          INSERT INTO movimiento_stock 
          (id_producto, tipo_movimiento, cantidad, descripcion, id_usuario, id_lote)
          VALUES (?, 'egreso', ?, 'Venta #${id_venta} - Lote ${lote.numero_lote}', ?, ?)
        `, [id_producto, cantidadATomar, req.user.id_usuario, lote.id_lote]);

        cantidadRestante -= cantidadATomar;
      }

      // Actualizar stock general del producto
      await connection.execute(`
        UPDATE producto 
        SET stock = stock - ? 
        WHERE id_producto = ?
      `, [cantidad, id_producto]);

      // Verificar si hay suficiente stock
      if (cantidadRestante > 0) {
        throw new Error(`Stock insuficiente para el producto ID: ${id_producto}. Faltan ${cantidadRestante} unidades`);
      }
    }

    // 3. Actualizar total de la venta
    await connection.execute(`
      UPDATE venta SET total = ? WHERE id_venta = ?
    `, [total_venta, id_venta]);

    await connection.commit();

    // 4. Devolver venta completa
    const [nuevaVenta] = await db.execute(`
      SELECT v.*, c.razon_social, ev.estado, mp.metodo_pago
      FROM venta v
      LEFT JOIN cliente c ON v.id_cliente = c.id_cliente
      LEFT JOIN estado_venta ev ON v.id_estado_venta = ev.id_estado_venta
      LEFT JOIN metodo_pago mp ON v.id_metodo_pago = mp.id_metodo_pago
      WHERE v.id_venta = ?
    `, [id_venta]);

    res.status(201).json({
      ...nuevaVenta[0],
      detalles
    });

  } catch (error) {
    await connection.rollback();
    console.error('❌ Error en createVenta:', error);
    res.status(500).json({ error: error.message });
  } finally {
    connection.release();
  }
};
// Obtener ventas por estado
export const getVentasPorEstado = async (req, res) => {
    try {
        const { estadoId } = req.params;
        console.log(`Buscando ventas con estado: ${estadoId}`);
        
        const [ventas] = await db.execute(`
            SELECT 
                v.id_venta,
                v.id_cliente,
                DATE_FORMAT(v.fecha, '%Y-%m-%d') as fecha,
                TIME(v.hora) as hora,
                v.total,
                v.id_metodo_pago,
                v.id_estado_venta,
                v.id_repartidor,
                v.id_vendedor,
                v.notas,
                v.fecha_creacion,
                v.fecha_actualizacion,
                c.razon_social, 
                p_cliente.telefono,
                p_cliente.direccion,
                p_cliente.coordenadas,
                ev.estado, 
                mp.metodo_pago, 
                u.nombre_usuario as vendedor,
                p_repartidor.nombre_completo as repartidor,
                r.placa_furgon
            FROM venta v
            LEFT JOIN cliente c ON v.id_cliente = c.id_cliente
            LEFT JOIN persona p_cliente ON c.id_persona = p_cliente.id_persona
            LEFT JOIN estado_venta ev ON v.id_estado_venta = ev.id_estado_venta
            LEFT JOIN metodo_pago mp ON v.id_metodo_pago = mp.id_metodo_pago
            LEFT JOIN usuario u ON v.id_vendedor = u.id_usuario
            LEFT JOIN repartidor r ON v.id_repartidor = r.id_repartidor
            LEFT JOIN persona p_repartidor ON r.id_persona = p_repartidor.id_persona
            WHERE v.id_estado_venta = ?
            ORDER BY v.fecha_creacion DESC
        `, [estadoId]);
        console.log(`Ventas encontradas:`, ventas);
        res.json(ventas);
    } catch (error) {
        console.error('Error obteniendo ventas por estado:', error);
        res.status(500).json({ error: error.message });
    }
};

// Asignar repartidor a venta
export const asignarRepartidor = async (req, res) => {
    try {
        const { id } = req.params;
        const { id_repartidor, id_estado_venta } = req.body;
        console.log(`Asignando repartidor ${id_repartidor} a venta ${id}`);

        const [result] = await db.execute(`
            UPDATE venta 
            SET id_repartidor = ?, id_estado_venta = ?, fecha_actualizacion = NOW()
            WHERE id_venta = ?
        `, [id_repartidor, id_estado_venta, id]);

        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Venta no encontrada' });
        }

        res.json({ 
            message: 'Repartidor asignado correctamente',
            id_venta: id,
            id_repartidor: id_repartidor,
            id_estado_venta: id_estado_venta
        });
    } catch (error) {
        console.error('Error asignando repartidor:', error);
        res.status(500).json({ error: error.message });
    }
};

// Cambiar estado de venta (versión mejorada)
// En venta.controller.js - en updateEstadoVenta
export const updateEstadoVenta = async (req, res) => {
    try {
        const { id } = req.params;
        const { id_estado_venta, id_repartidor } = req.body;

        console.log(`🔄 Actualizando estado de venta ${id} a ${id_estado_venta}`);

        let query = `UPDATE venta SET id_estado_venta = ?, fecha_actualizacion = NOW()`;
        let params = [id_estado_venta];

        if (id_repartidor !== undefined) {
            query += `, id_repartidor = ?`;
            params.push(id_repartidor);
        }

        query += ` WHERE id_venta = ?`;
        params.push(id);

        const [result] = await db.execute(query, params);

        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Venta no encontrada' });
        }

        // Obtener el nombre del estado actualizado
        const [estadoInfo] = await db.execute(
            'SELECT estado FROM estado_venta WHERE id_estado_venta = ?',
            [id_estado_venta]
        );

        const nombreEstado = estadoInfo[0]?.estado || 'Desconocido';

        console.log(`✅ Estado actualizado: ${nombreEstado}`);

        res.json({ 
            message: 'Estado actualizado correctamente',
            id_estado_venta: id_estado_venta,
            estado: nombreEstado, // ✅ Incluir el nombre del estado
            id_repartidor: id_repartidor || null
        });
    } catch (error) {
        console.error('Error actualizando estado:', error);
        res.status(500).json({ error: error.message });
    }
};