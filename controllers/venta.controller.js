// src/controllers/venta.controller.js
import db from '../config/db.js';

// ============================================
// GET VENTAS - Listar todas las ventas
// ============================================
export const getVentas = async (req, res) => {
    try {
        const [ventas] = await db.execute(`
            SELECT 
                v.id_venta,
                v.id_cliente,
                v.fecha as fecha,
                v.hora as hora,
                v.total,
                v.id_metodo_pago,
                v.id_estado_venta,
                v.id_repartidor,
                v.id_vendedor,
                v.notas,
                v.fecha_creacion,
                v.fecha_actualizacion,
                v.tipo_comprobante_solicitado,
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

// ============================================
// GET VENTA BY ID - Obtener venta específica
// ============================================
export const getVentaById = async (req, res) => {
    try {
        const { id } = req.params;
        const [ventas] = await db.execute(`
            SELECT 
                v.id_venta,
                v.id_cliente,
                v.fecha as fecha,
                v.hora as hora,
                v.total,
                v.id_metodo_pago,
                v.id_estado_venta,
                v.id_repartidor,
                v.id_vendedor,
                v.notas,
                v.fecha_creacion,
                v.fecha_actualizacion,
                v.tipo_comprobante_solicitado,
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

// ============================================
// CREATE VENTA - VERSIÓN CORREGIDA CON VALIDACIÓN ROBUSTA DE STOCK
// ============================================
export const createVenta = async (req, res) => {
    const connection = await db.getConnection();
    
    try {
        await connection.beginTransaction();

        // ========== FUNCIONES AUXILIARES ==========
        const sanitizeParams = (params) => {
            return params.map(param => {
                if (param === undefined || param === '') {
                    console.warn('⚠️ Parámetro undefined o vacío detectado, convirtiendo a null');
                    return null;
                }
                if (typeof param === 'string') {
                    const cleaned = param.trim();
                    return cleaned === '' ? null : cleaned;
                }
                return param;
            });
        };

        const safeValue = (value, defaultValue = null) => {
            if (value === undefined) {
                console.log(`⚠️ Campo undefined detectado, usando valor por defecto: ${defaultValue}`);
                return defaultValue;
            }
            return value;
        };

        // ========== EXTRACCIÓN DE DATOS ==========
        const {
            id_cliente,
            id_metodo_pago,
            id_estado_venta = 1,
            id_repartidor,
            notas = '',
            detalles = [],
            tipo_comprobante_solicitado = 'SIN_COMPROBANTE'
        } = req.body;

        // ========== VALIDACIÓN DE CAMPOS BÁSICOS ==========
        console.log('🔍 VALIDANDO CAMPOS DE VENTA:');
        
        const clienteFinal = Number(id_cliente);
        const metodoPagoFinal = Number(id_metodo_pago);
        const estadoVentaFinal = Number(safeValue(id_estado_venta, 1));
        const repartidorFinal = safeValue(id_repartidor, null);
        const notasFinal = safeValue(notas, '');
        
        // Validar tipo de comprobante
        let tipoComprobanteFinal = safeValue(tipo_comprobante_solicitado, 'SIN_COMPROBANTE');
        const tiposPermitidos = ['FACTURA', 'BOLETA', 'SIN_COMPROBANTE'];
        if (!tiposPermitidos.includes(tipoComprobanteFinal)) {
            tipoComprobanteFinal = 'SIN_COMPROBANTE';
        }

        // Validar autenticación
        if (!req.user || !req.user.id_usuario) {
            return res.status(401).json({ error: 'Usuario no autenticado' });
        }
        const id_vendedor = req.user.id_usuario;

        // Validaciones básicas
        if (!clienteFinal || clienteFinal === 0) {
            return res.status(400).json({ error: 'Cliente es requerido' });
        }
        if (!metodoPagoFinal) {
            return res.status(400).json({ error: 'Método de pago es requerido' });
        }
        if (!detalles || detalles.length === 0) {
            return res.status(400).json({ error: 'Debe agregar al menos un producto' });
        }

        // ========== OBTENER FECHA Y HORA PERÚ ==========
        const ahora = new Date();
        const offsetPeru = -5 * 60;
        const fechaPeru = new Date(ahora.getTime() + offsetPeru * 60 * 1000);
        
        const dia = fechaPeru.getUTCDate().toString().padStart(2, '0');
        const mes = (fechaPeru.getUTCMonth() + 1).toString().padStart(2, '0');
        const anio = fechaPeru.getUTCFullYear();
        const fechaStr = `${anio}-${mes}-${dia}`;
        
        const horas = fechaPeru.getUTCHours().toString().padStart(2, '0');
        const minutos = fechaPeru.getUTCMinutes().toString().padStart(2, '0');
        const segundos = fechaPeru.getUTCSeconds().toString().padStart(2, '0');
        const horaStr = `${horas}:${minutos}:${segundos}`;

        // ========== ✅ NUEVA VALIDACIÓN PREVENTIVA DE STOCK ==========
        console.log('🔍 VERIFICANDO STOCK REAL ANTES DE PROCESAR VENTA:');
        
        // Mapa para almacenar información de productos
        const productosInfo = {};

        for (const detalle of detalles) {
            const { id_producto, cantidad } = detalle;
            
            // Obtener stock REAL desde lotes activos
            const [lotesDisponibles] = await connection.execute(`
                SELECT 
                    COALESCE(SUM(cantidad_actual), 0) as stock_real,
                    COUNT(*) as cantidad_lotes_activos,
                    GROUP_CONCAT(CONCAT(numero_lote, ':', cantidad_actual) SEPARATOR ', ') as lotes_detalle
                FROM lote_producto 
                WHERE id_producto = ? AND activo = 1 AND cantidad_actual > 0
            `, [id_producto]);

            const stockReal = Number(lotesDisponibles[0]?.stock_real) || 0;
            const lotesActivos = Number(lotesDisponibles[0]?.cantidad_lotes_activos) || 0;
            const lotesDetalle = lotesDisponibles[0]?.lotes_detalle || 'Ninguno';

            // Obtener nombre del producto
            const [productoInfo] = await connection.execute(
                'SELECT nombre, stock FROM producto WHERE id_producto = ?',
                [id_producto]
            );
            
            const nombreProducto = productoInfo[0]?.nombre || `ID: ${id_producto}`;
            const stockTablaProducto = productoInfo[0]?.stock || 0;
            
            // Guardar para logs
            productosInfo[id_producto] = {
                nombre: nombreProducto,
                stock_tabla: stockTablaProducto,
                stock_real: stockReal,
                lotes_activos: lotesActivos,
                lotes_detalle: lotesDetalle
            };

            console.log(`\n📦 Producto ID ${id_producto} - ${nombreProducto}:`);
            console.log(`   - Stock en tabla producto: ${stockTablaProducto}`);
            console.log(`   - Stock REAL (lotes activos): ${stockReal}`);
            console.log(`   - Cantidad solicitada: ${cantidad}`);
            console.log(`   - Lotes activos disponibles: ${lotesActivos}`);
            console.log(`   - Detalle de lotes: ${lotesDetalle}`);

            // ✅ VALIDACIÓN 1: Stock total suficiente
            if (stockReal < cantidad) {
                await connection.rollback();
                console.error(`❌ STOCK INSUFICIENTE - ${nombreProducto}`);
                console.error(`   Solicitado: ${cantidad}, Disponible real: ${stockReal}`);
                
                return res.status(400).json({ 
                    error: `Stock insuficiente para el producto "${nombreProducto}".`,
                    detalles: {
                        id_producto,
                        nombre: nombreProducto,
                        stock_disponible: stockReal,
                        stock_solicitado: cantidad,
                        lotes_activos: lotesActivos,
                        stock_en_tabla: stockTablaProducto
                    }
                });
            }

            // ✅ VALIDACIÓN 2: Verificar distribución por lotes individuales
            const [lotes] = await connection.execute(`
                SELECT id_lote, cantidad_actual, numero_lote
                FROM lote_producto 
                WHERE id_producto = ? AND activo = 1 AND cantidad_actual > 0
                ORDER BY fecha_caducidad ASC
            `, [id_producto]);

            let cantidadRestante = cantidad;
            const asignacionLotes = [];

            for (const lote of lotes) {
                if (cantidadRestante <= 0) break;
                const cantidadATomar = Math.min(cantidadRestante, lote.cantidad_actual);
                asignacionLotes.push({
                    id_lote: lote.id_lote,
                    numero_lote: lote.numero_lote,
                    cantidad: cantidadATomar
                });
                cantidadRestante -= cantidadATomar;
            }

            if (cantidadRestante > 0) {
                await connection.rollback();
                console.error(`❌ DISTRIBUCIÓN DE LOTE IMPOSIBLE - ${nombreProducto}`);
                
                return res.status(400).json({ 
                    error: `No se puede distribuir la cantidad solicitada entre los lotes disponibles para "${nombreProducto}".`,
                    detalles: {
                        id_producto,
                        nombre: nombreProducto,
                        solicitado: cantidad,
                        faltante: cantidadRestante,
                        lotes_disponibles: lotes.map(l => ({
                            lote: l.numero_lote,
                            stock: l.cantidad_actual
                        }))
                    }
                });
            }

            console.log(`   ✅ Distribución de lotes posible:`, asignacionLotes);
        }

        // ========== CREAR LA VENTA ==========
        console.log('🚀 EJECUTANDO INSERT EN VENTA...');
        const [result] = await connection.execute(`
            INSERT INTO venta (
                id_cliente, fecha, hora, total, id_metodo_pago, 
                id_estado_venta, id_repartidor, id_vendedor, notas,
                tipo_comprobante_solicitado
            ) VALUES (?, ?, ?, 0, ?, ?, ?, ?, ?, ?)
        `, sanitizeParams([
            clienteFinal, 
            fechaStr,
            horaStr,
            metodoPagoFinal, 
            estadoVentaFinal, 
            repartidorFinal, 
            id_vendedor, 
            notasFinal,
            tipoComprobanteFinal
        ]));

        const id_venta = result.insertId;
        let total_venta = 0;

        console.log('🆕 Venta creada con ID:', id_venta, 'Tipo comprobante:', tipoComprobanteFinal);

        // ========== PROCESAR DETALLES Y ACTUALIZAR STOCK ==========
        for (const detalle of detalles) {
            const { id_producto, cantidad, precio_unitario } = detalle;
            const subtotal = cantidad * precio_unitario;
            total_venta += subtotal;

            console.log('📦 Procesando detalle:', { id_producto, cantidad, precio_unitario, subtotal });

            // Insertar detalle de venta
            const [detalleResult] = await connection.execute(`
                INSERT INTO venta_detalle (id_venta, id_producto, cantidad, precio_unitario)
                VALUES (?, ?, ?, ?)
            `, sanitizeParams([id_venta, id_producto, cantidad, precio_unitario]));

            const id_detalle_venta = detalleResult.insertId;

            // Obtener lotes disponibles (usando FECHA_CADUCIDAD ASC - FIFO)
            const [lotes] = await connection.execute(`
                SELECT id_lote, cantidad_actual, numero_lote
                FROM lote_producto 
                WHERE id_producto = ? AND activo = 1 AND cantidad_actual > 0
                ORDER BY fecha_caducidad ASC
            `, sanitizeParams([id_producto]));

            let cantidadRestante = cantidad;

            // Asignar lotes específicos (FIFO)
            for (const lote of lotes) {
                if (cantidadRestante <= 0) break;

                const cantidadATomar = Math.min(cantidadRestante, lote.cantidad_actual);
                
                console.log('🏷️ Asignando lote:', { 
                    id_detalle_venta, 
                    id_lote: lote.id_lote, 
                    cantidad: cantidadATomar,
                    numero_lote: lote.numero_lote 
                });

                // Registrar en venta_detalle_lote
                await connection.execute(`
                    INSERT INTO venta_detalle_lote (id_detalle_venta, id_lote, cantidad)
                    VALUES (?, ?, ?)
                `, sanitizeParams([id_detalle_venta, lote.id_lote, cantidadATomar]));

                // Actualizar stock del lote
                await connection.execute(`
                    UPDATE lote_producto 
                    SET cantidad_actual = cantidad_actual - ? 
                    WHERE id_lote = ?
                `, sanitizeParams([cantidadATomar, lote.id_lote]));

                // Registrar movimiento de stock por lote
                await connection.execute(`
                    INSERT INTO movimiento_stock 
                    (id_producto, tipo_movimiento, cantidad, descripcion, id_usuario, id_lote)
                    VALUES (?, 'egreso', ?, 'Venta #${id_venta} - Lote ${lote.numero_lote}', ?, ?)
                `, sanitizeParams([id_producto, cantidadATomar, id_vendedor, lote.id_lote]));

                cantidadRestante -= cantidadATomar;
            }

            // Actualizar stock general del producto
            await connection.execute(`
                UPDATE producto 
                SET stock = stock - ? 
                WHERE id_producto = ?
            `, sanitizeParams([cantidad, id_producto]));
        }

        // ========== ACTUALIZAR TOTAL DE LA VENTA ==========
        await connection.execute(`
            UPDATE venta SET total = ? WHERE id_venta = ?
        `, sanitizeParams([total_venta, id_venta]));

        // ========== ✅ VERIFICACIÓN POST-VENTA ==========
        console.log('🔍 VERIFICANDO STOCK DESPUÉS DE LA VENTA:');
        for (const detalle of detalles) {
            const { id_producto } = detalle;
            
            const [stockPostVenta] = await connection.execute(`
                SELECT 
                    p.stock as stock_tabla,
                    COALESCE(SUM(lp.cantidad_actual), 0) as stock_lotes
                FROM producto p
                LEFT JOIN lote_producto lp ON p.id_producto = lp.id_producto AND lp.activo = 1
                WHERE p.id_producto = ?
                GROUP BY p.id_producto
            `, [id_producto]);

            if (stockPostVenta.length > 0) {
                console.log(`   - Producto ID ${id_producto}: Stock tabla=${stockPostVenta[0].stock_tabla}, Stock lotes=${stockPostVenta[0].stock_lotes}`);
                
                // Si hay inconsistencia, registrar pero NO revertir la venta
                if (stockPostVenta[0].stock_tabla !== stockPostVenta[0].stock_lotes) {
                    console.warn(`⚠️ INCONSISTENCIA DETECTADA post-venta para producto ID ${id_producto}`);
                }
            }
        }

        await connection.commit();

        console.log('✅ Venta completada exitosamente:', {
            id_venta,
            tipo_comprobante: tipoComprobanteFinal,
            total: total_venta,
            detalles: detalles.length
        });

        // ========== OBTENER VENTA COMPLETA PARA RESPUESTA ==========
        const [nuevaVenta] = await db.execute(`
            SELECT v.*, c.razon_social, ev.estado, mp.metodo_pago
            FROM venta v
            LEFT JOIN cliente c ON v.id_cliente = c.id_cliente
            LEFT JOIN estado_venta ev ON v.id_estado_venta = ev.id_estado_venta
            LEFT JOIN metodo_pago mp ON v.id_metodo_pago = mp.id_metodo_pago
            WHERE v.id_venta = ?
        `, [id_venta]);

        res.status(201).json({
            success: true,
            message: 'Venta registrada correctamente',
            venta: {
                ...nuevaVenta[0],
                tipo_comprobante_solicitado: tipoComprobanteFinal,
                detalles
            }
        });

    } catch (error) {
        await connection.rollback();
        console.error('❌ Error en createVenta:', error);
        console.error('📋 Stack trace completo:', error.stack);
        
        res.status(500).json({ 
            success: false,
            error: error.message 
        });
    } finally {
        connection.release();
    }
};

// ============================================
// GET VENTAS POR ESTADO
// ============================================
export const getVentasPorEstado = async (req, res) => {
    try {
        const { estadoId } = req.params;
        console.log(`🔍 Buscando ventas con estado: ${estadoId}`);
        
        const [ventas] = await db.execute(`
            SELECT 
                v.id_venta,
                v.id_cliente,
                v.fecha as fecha,
                v.hora as hora,
                v.total,
                v.id_metodo_pago,
                v.id_estado_venta,
                v.id_repartidor,
                v.id_vendedor,
                v.notas,
                v.fecha_creacion,
                v.fecha_actualizacion,
                v.tipo_comprobante_solicitado,
                c.razon_social, 
                p_cliente.telefono,
                p_cliente.direccion,
                p_cliente.nombre_completo,
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
        
        console.log(`📋 Total de ventas encontradas: ${ventas.length}`);
        res.json(ventas);
    } catch (error) {
        console.error('Error obteniendo ventas por estado:', error);
        res.status(500).json({ error: error.message });
    }
};

// ============================================
// ASIGNAR REPARTIDOR
// ============================================
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

// ============================================
// ACTUALIZAR ESTADO DE VENTA
// ============================================
export const updateEstadoVenta = async (req, res) => {
    try {
        const { id } = req.params;
        const { id_estado_venta, id_repartidor } = req.body;

        console.log(`🔄 Actualizando estado de venta ${id} a ${id_estado_venta}`);

        let fechaFinRutaClause = '';
        if (id_estado_venta === 7 || id_estado_venta === 8) {
            const [ventaInfo] = await db.execute(
                'SELECT fecha_inicio_ruta FROM venta WHERE id_venta = ?',
                [id]
            );
            
            if (ventaInfo.length > 0 && ventaInfo[0].fecha_inicio_ruta) {
                fechaFinRutaClause = ', fecha_fin_ruta = NOW(), tracking_activo = FALSE';
            }
        }

        let query = `UPDATE venta SET id_estado_venta = ?, fecha_actualizacion = NOW()${fechaFinRutaClause}`;
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

        const [estadoInfo] = await db.execute(
            'SELECT estado FROM estado_venta WHERE id_estado_venta = ?',
            [id_estado_venta]
        );

        const nombreEstado = estadoInfo[0]?.estado || 'Desconocido';

        console.log(`✅ Estado actualizado: ${nombreEstado}`);

        res.json({ 
            message: 'Estado actualizado correctamente',
            id_estado_venta: id_estado_venta,
            estado: nombreEstado,
            id_repartidor: id_repartidor || null
        });
    } catch (error) {
        console.error('Error actualizando estado:', error);
        res.status(500).json({ error: error.message });
    }
};

// ============================================
// ESTADÍSTICAS DE VENTAS
// ============================================
export const getEstadisticasVentas = async (req, res) => {
    try {
        const [estadisticasHoy] = await db.execute(`
            SELECT 
                COALESCE(SUM(CASE WHEN v.id_estado_venta = 7 THEN v.total ELSE 0 END), 0) as total_hoy,
                COUNT(CASE WHEN v.id_estado_venta = 7 THEN 1 END) as ventas_hoy,
                DATE(v.fecha) as fecha
            FROM venta v
            WHERE DATE(v.fecha) = CURDATE()
            GROUP BY DATE(v.fecha)
        `);
        
        const [estadisticasMes] = await db.execute(`
            SELECT 
                COALESCE(SUM(CASE WHEN v.id_estado_venta = 7 THEN v.total ELSE 0 END), 0) as total_mes,
                COUNT(CASE WHEN v.id_estado_venta = 7 THEN 1 END) as ventas_mes
            FROM venta v
            WHERE YEAR(v.fecha) = YEAR(CURDATE()) 
                AND MONTH(v.fecha) = MONTH(CURDATE())
        `);
        
        const [estadisticasGeneral] = await db.execute(`
            SELECT 
                COALESCE(SUM(CASE WHEN v.id_estado_venta = 7 THEN v.total ELSE 0 END), 0) as total_general,
                COUNT(CASE WHEN v.id_estado_venta = 7 THEN 1 END) as ventas_general
            FROM venta v
        `);
        
        const [ventasPorMetodo] = await db.execute(`
            SELECT 
                mp.metodo_pago,
                COUNT(v.id_venta) as cantidad,
                COALESCE(SUM(v.total), 0) as total
            FROM venta v
            JOIN metodo_pago mp ON v.id_metodo_pago = mp.id_metodo_pago
            WHERE v.id_estado_venta = 7
                AND DATE(v.fecha) = CURDATE()
            GROUP BY v.id_metodo_pago, mp.metodo_pago
            ORDER BY total DESC
        `);
        
        const totalHoy = estadisticasHoy[0]?.total_hoy || 0;
        const ventasHoy = estadisticasHoy[0]?.ventas_hoy || 0;
        
        res.json({
            totalHoy: parseFloat(totalHoy),
            totalMes: parseFloat(estadisticasMes[0]?.total_mes || 0),
            totalGeneral: parseFloat(estadisticasGeneral[0]?.total_general || 0),
            ventasHoy: ventasHoy,
            ventasMes: estadisticasMes[0]?.ventas_mes || 0,
            promedioTicket: ventasHoy > 0 ? parseFloat(totalHoy) / ventasHoy : 0,
            ventasPorMetodoPago: ventasPorMetodo.map(item => ({
                metodo: item.metodo_pago,
                cantidad: item.cantidad,
                total: parseFloat(item.total)
            }))
        });
        
    } catch (error) {
        console.error('Error obteniendo estadísticas:', error);
        res.status(500).json({ error: error.message });
    }
};

// ============================================
// RESUMEN DE VENTAS POR DÍA
// ============================================
export const getResumenVentasPorDia = async (req, res) => {
    try {
        const { fecha_inicio, fecha_fin } = req.query;
        
        const [resultado] = await db.execute(`
            SELECT 
                DATE(v.fecha) as fecha,
                COUNT(v.id_venta) as cantidad_ventas,
                COALESCE(SUM(CASE WHEN v.id_estado_venta = 7 THEN v.total ELSE 0 END), 0) as total_pagado,
                COALESCE(SUM(CASE WHEN v.id_estado_venta = 8 THEN v.total ELSE 0 END), 0) as total_cancelado
            FROM venta v
            WHERE v.fecha BETWEEN ? AND ?
            GROUP BY DATE(v.fecha)
            ORDER BY fecha DESC
        `, [fecha_inicio, fecha_fin]);
        
        res.json(resultado);
    } catch (error) {
        console.error('Error obteniendo resumen por día:', error);
        res.status(500).json({ error: error.message });
    }
};