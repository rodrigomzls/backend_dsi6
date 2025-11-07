// src/controllers/repartidor-venta.controller.js
import db from '../config/db.js';

// Obtener ventas asignadas al repartidor actual
export const getVentasAsignadas = async (req, res) => {
    try {
        // Obtener el id_repartidor del usuario actual
        const [repartidores] = await db.execute(`
            SELECT r.id_repartidor 
            FROM repartidor r
            JOIN usuario u ON r.id_persona = u.id_persona
            WHERE u.id_usuario = ?
        `, [req.user.id_usuario]);

        if (repartidores.length === 0) {
            return res.status(404).json({ error: 'Repartidor no encontrado para este usuario' });
        }

        const repartidorId = repartidores[0].id_repartidor;
        console.log(`🔍 Buscando ventas para repartidor ID: ${repartidorId}`);
        
        const [ventas] = await db.execute(`
            SELECT 
                v.id_venta,
                v.id_cliente,
                DATE_FORMAT(v.fecha, '%Y-%m-%d') as fecha,
                TIME(v.hora) as hora,
                v.total,
                v.id_estado_venta,
                ev.estado,
                p_cliente.nombre_completo,
                p_cliente.telefono,
                p_cliente.direccion,
                p_cliente.coordenadas,
                c.razon_social,
                mp.metodo_pago,
                v.notas,
                v.fecha_creacion
            FROM venta v
            LEFT JOIN cliente c ON v.id_cliente = c.id_cliente
            LEFT JOIN persona p_cliente ON c.id_persona = p_cliente.id_persona
            LEFT JOIN estado_venta ev ON v.id_estado_venta = ev.id_estado_venta
            LEFT JOIN metodo_pago mp ON v.id_metodo_pago = mp.id_metodo_pago
            WHERE v.id_repartidor = ? 
            AND v.id_estado_venta IN (4, 5) -- Listo para repartos, En ruta
            ORDER BY v.fecha_creacion DESC
        `, [repartidorId]);
        
        console.log(`✅ Ventas asignadas encontradas: ${ventas.length}`);
        res.json(ventas);
    } catch (error) {
        console.error('Error obteniendo ventas asignadas:', error);
        res.status(500).json({ error: error.message });
    }
};

// Obtener entregas pendientes (estado "En ruta")
export const getEntregasPendientes = async (req, res) => {
    try {
        // Obtener el id_repartidor del usuario actual
        const [repartidores] = await db.execute(`
            SELECT r.id_repartidor 
            FROM repartidor r
            JOIN usuario u ON r.id_persona = u.id_persona
            WHERE u.id_usuario = ?
        `, [req.user.id_usuario]);

        if (repartidores.length === 0) {
            return res.status(404).json({ error: 'Repartidor no encontrado para este usuario' });
        }

        const repartidorId = repartidores[0].id_repartidor;
        console.log(`🔍 Buscando entregas pendientes para repartidor ID: ${repartidorId}`);
        
        const [ventas] = await db.execute(`
            SELECT 
                v.id_venta,
                v.id_cliente,
                DATE_FORMAT(v.fecha, '%Y-%m-%d') as fecha,
                TIME(v.hora) as hora,
                v.total,
                v.id_estado_venta,
                ev.estado,
                p_cliente.nombre_completo,
                p_cliente.telefono,
                p_cliente.direccion,
                p_cliente.coordenadas,
                c.razon_social,
                mp.metodo_pago,
                v.notas,
                v.fecha_creacion
            FROM venta v
            LEFT JOIN cliente c ON v.id_cliente = c.id_cliente
            LEFT JOIN persona p_cliente ON c.id_persona = p_cliente.id_persona
            LEFT JOIN estado_venta ev ON v.id_estado_venta = ev.id_estado_venta
            LEFT JOIN metodo_pago mp ON v.id_metodo_pago = mp.id_metodo_pago
            WHERE v.id_repartidor = ? 
            AND v.id_estado_venta = 5 -- En ruta
            ORDER BY v.fecha_creacion DESC
        `, [repartidorId]);
        
        console.log(`✅ Entregas pendientes encontradas: ${ventas.length}`);
        res.json(ventas);
    } catch (error) {
        console.error('Error obteniendo entregas pendientes:', error);
        res.status(500).json({ error: error.message });
    }
};

// Obtener historial de entregas completadas
export const getHistorialEntregas = async (req, res) => {
    try {
        // Obtener el id_repartidor del usuario actual
        const [repartidores] = await db.execute(`
            SELECT r.id_repartidor 
            FROM repartidor r
            JOIN usuario u ON r.id_persona = u.id_persona
            WHERE u.id_usuario = ?
        `, [req.user.id_usuario]);

        if (repartidores.length === 0) {
            return res.status(404).json({ error: 'Repartidor no encontrado para este usuario' });
        }

        const repartidorId = repartidores[0].id_repartidor;
        console.log(`🔍 Buscando historial para repartidor ID: ${repartidorId}`);
        
        const [ventas] = await db.execute(`
            SELECT 
                v.id_venta,
                v.id_cliente,
                DATE_FORMAT(v.fecha, '%Y-%m-%d') as fecha,
                TIME(v.hora) as hora,
                v.total,
                v.id_estado_venta,
                ev.estado,
                p_cliente.nombre_completo,
                p_cliente.telefono,
                p_cliente.direccion,
                p_cliente.coordenadas,
                c.razon_social,
                mp.metodo_pago,
                v.notas,
                v.fecha_creacion
            FROM venta v
            LEFT JOIN cliente c ON v.id_cliente = c.id_cliente
            LEFT JOIN persona p_cliente ON c.id_persona = p_cliente.id_persona
            LEFT JOIN estado_venta ev ON v.id_estado_venta = ev.id_estado_venta
            LEFT JOIN metodo_pago mp ON v.id_metodo_pago = mp.id_metodo_pago
            WHERE v.id_repartidor = ? 
            AND v.id_estado_venta IN (7, 8) -- Pagado, Cancelado
            ORDER BY v.fecha_creacion DESC
        `, [repartidorId]);
        
        console.log(`✅ Historial de entregas encontrado: ${ventas.length}`);
        res.json(ventas);
    } catch (error) {
        console.error('Error obteniendo historial:', error);
        res.status(500).json({ error: error.message });
    }
};

// Obtener detalle de una venta asignada al repartidor actual
export const getVentaDetalleAsignada = async (req, res) => {
    try {
        // Obtener el id_repartidor del usuario actual
        const [repartidores] = await db.execute(`
            SELECT r.id_repartidor 
            FROM repartidor r
            JOIN usuario u ON r.id_persona = u.id_persona
            WHERE u.id_usuario = ?
        `, [req.user.id_usuario]);

        if (repartidores.length === 0) {
            return res.status(404).json({ error: 'Repartidor no encontrado para este usuario' });
        }

        const repartidorId = repartidores[0].id_repartidor;
        const { id } = req.params;

        console.log(`🔍 Buscando detalle de venta ${id} para repartidor ID: ${repartidorId}`);
        
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
            WHERE v.id_venta = ? AND v.id_repartidor = ?
        `, [id, repartidorId]);

        if (ventas.length === 0) {
            return res.status(404).json({ error: 'Venta no encontrada o no asignada a este repartidor' });
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
        console.error('Error obteniendo detalle de venta asignada:', error);
        res.status(500).json({ error: error.message });
    }
};
// src/controllers/repartidor-venta.controller.js

// Marcar entrega como pagada (solo para repartidor)
export const updateEstadoVentaRepartidor = async (req, res) => {
    try {
        // Obtener el id_repartidor del usuario actual
        const [repartidores] = await db.execute(`
            SELECT r.id_repartidor 
            FROM repartidor r
            JOIN usuario u ON r.id_persona = u.id_persona
            WHERE u.id_usuario = ?
        `, [req.user.id_usuario]);

        if (repartidores.length === 0) {
            return res.status(404).json({ error: 'Repartidor no encontrado para este usuario' });
        }

        const repartidorId = repartidores[0].id_repartidor;
        const { id } = req.params;

        console.log(`🔄 Repartidor ${repartidorId} marcando venta ${id} como pagada`);

        // Verificar que la venta está asignada a este repartidor y en estado "En ruta"
        const [ventas] = await db.execute(`
            SELECT id_venta, id_estado_venta 
            FROM venta 
            WHERE id_venta = ? AND id_repartidor = ? AND id_estado_venta = 5
        `, [id, repartidorId]);

        if (ventas.length === 0) {
            return res.status(404).json({ 
                error: 'Venta no encontrada, no asignada a este repartidor o no está en estado "En ruta"' 
            });
        }

        // Actualizar estado a "Pagado" (7)
        const [result] = await db.execute(`
            UPDATE venta 
            SET id_estado_venta = 7, fecha_actualizacion = NOW()
            WHERE id_venta = ? AND id_repartidor = ?
        `, [id, repartidorId]);

        if (result.affectedRows === 0) {
            return res.status(400).json({ error: 'No se pudo actualizar el estado de la venta' });
        }

        console.log(`✅ Venta ${id} marcada como pagada por repartidor ${repartidorId}`);
        res.json({ 
            message: 'Venta marcada como pagada correctamente',
            id_estado_venta: 7,
            estado: 'Pagado'
        });
    } catch (error) {
        console.error('Error actualizando estado de venta:', error);
        res.status(500).json({ error: error.message });
    }
};

// Marcar entrega como cancelada (solo para repartidor)
export const cancelarEntregaRepartidor = async (req, res) => {
    try {
        // Obtener el id_repartidor del usuario actual
        const [repartidores] = await db.execute(`
            SELECT r.id_repartidor 
            FROM repartidor r
            JOIN usuario u ON r.id_persona = u.id_persona
            WHERE u.id_usuario = ?
        `, [req.user.id_usuario]);

        if (repartidores.length === 0) {
            return res.status(404).json({ error: 'Repartidor no encontrado para este usuario' });
        }

        const repartidorId = repartidores[0].id_repartidor;
        const { id } = req.params;
        const { motivo } = req.body;

        console.log(`🔄 Repartidor ${repartidorId} cancelando venta ${id}`);

        if (!motivo) {
            return res.status(400).json({ error: 'El motivo de cancelación es requerido' });
        }

        // Verificar que la venta está asignada a este repartidor y en estado "En ruta"
        const [ventas] = await db.execute(`
            SELECT id_venta, id_estado_venta 
            FROM venta 
            WHERE id_venta = ? AND id_repartidor = ? AND id_estado_venta = 5
        `, [id, repartidorId]);

        if (ventas.length === 0) {
            return res.status(404).json({ 
                error: 'Venta no encontrada, no asignada a este repartidor o no está en estado "En ruta"' 
            });
        }

        // Actualizar estado a "Cancelado" (8) y agregar motivo
        const [result] = await db.execute(`
            UPDATE venta 
            SET id_estado_venta = 8, notas = CONCAT(COALESCE(notas, ''), ' CANCELACIÓN REPARTIDOR: ', ?), 
                fecha_actualizacion = NOW()
            WHERE id_venta = ? AND id_repartidor = ?
        `, [motivo, id, repartidorId]);

        if (result.affectedRows === 0) {
            return res.status(400).json({ error: 'No se pudo cancelar la venta' });
        }

        console.log(`✅ Venta ${id} cancelada por repartidor ${repartidorId}`);
        res.json({ 
            message: 'Venta cancelada correctamente',
            id_estado_venta: 8,
            estado: 'Cancelado'
        });
    } catch (error) {
        console.error('Error cancelando venta:', error);
        res.status(500).json({ error: error.message });
    }
};