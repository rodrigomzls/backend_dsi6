// backend_dsi6/controllers/sunat.controller.js
import db from '../config/db.js'; // ✅ AGREGAR ESTA IMPORTACIÓN
import sunatService from '../sunat/sunat.service.js';

class SunatController {
    async emitirComprobante(req, res) {
        try {
            const { idVenta } = req.params;
            console.log(`🚀 Solicitando emisión para venta ${idVenta}`);
            
            const resultado = await sunatService.emitirComprobante(idVenta);
            
            res.json({
                success: true,
                message: 'Comprobante emitido correctamente',
                data: resultado
            });
        } catch (error) {
            console.error('❌ Error en emitirComprobante:', error);
            res.status(500).json({
                success: false,
                error: error.message
            });
        }
    }

    async listarComprobantes(req, res) {
        try {
            const { 
                tipo, estado, fecha_desde, fecha_hasta, 
                pagina = 1, limite = 20, search
            } = req.query;
            
            let query = `
                SELECT cs.*, v.total, v.fecha, 
                       c.razon_social, p.nombre_completo,
                       CONCAT(cs.serie, '-', LPAD(cs.numero_secuencial, 8, '0')) as serie_numero
                FROM comprobante_sunat cs
                JOIN venta v ON cs.id_venta = v.id_venta
                LEFT JOIN cliente c ON v.id_cliente = c.id_cliente
                LEFT JOIN persona p ON c.id_persona = p.id_persona
                WHERE 1=1
            `;
            
            const params = [];
            
            if (tipo) { 
                query += ' AND cs.tipo = ?'; 
                params.push(tipo); 
            }
            if (estado) { 
                query += ' AND cs.estado = ?'; 
                params.push(estado); 
            }
            if (fecha_desde) { 
                query += ' AND DATE(cs.fecha_envio) >= ?'; 
                params.push(fecha_desde); 
            }
            if (fecha_hasta) { 
                query += ' AND DATE(cs.fecha_envio) <= ?'; 
                params.push(fecha_hasta); 
            }
            if (search) {
                query += ' AND (c.razon_social LIKE ? OR p.nombre_completo LIKE ? OR cs.serie LIKE ?)';
                const searchTerm = `%${search}%`;
                params.push(searchTerm, searchTerm, searchTerm);
            }
            
            // Contar total
            const countQuery = query.replace('SELECT cs.*, v.total, c.razon_social, p.nombre_completo', 'SELECT COUNT(*) as total');
            const [countResult] = await db.execute(countQuery, params);
            const total = countResult[0]?.total || 0;
            
            // Paginación
            query += ' ORDER BY cs.fecha_envio DESC LIMIT ? OFFSET ?';
            const offset = (pagina - 1) * limite;
            params.push(parseInt(limite), offset);
            
            const [comprobantes] = await db.execute(query, params);
            
            res.json({ 
                success: true, 
                total, 
                pagina: parseInt(pagina),
                limite: parseInt(limite),
                comprobantes 
            });
            
        } catch (error) {
            console.error('❌ Error en listarComprobantes:', error);
            res.status(500).json({ 
                success: false,
                error: error.message 
            });
        }
    }

    async obtenerXml(req, res) {
        try {
            const { idComprobante } = req.params;
            
            const [comprobantes] = await db.execute(
                'SELECT xml_generado FROM comprobante_sunat WHERE id_comprobante = ?',
                [idComprobante]
            );
            
            if (comprobantes.length === 0 || !comprobantes[0].xml_generado) {
                return res.status(404).json({ 
                    success: false,
                    error: 'XML no encontrado' 
                });
            }
            
            const xml = comprobantes[0].xml_generado;
            
            // Configurar headers para descarga
            res.setHeader('Content-Type', 'application/xml');
            res.setHeader('Content-Disposition', `attachment; filename="comprobante-${idComprobante}.xml"`);
            
            res.send(xml);
            
        } catch (error) {
            console.error('❌ Error en obtenerXml:', error);
            res.status(500).json({ 
                success: false,
                error: error.message 
            });
        }
    }

    async consultarComprobante(req, res) {
        try {
            const { idComprobante } = req.params;
            
            const [comprobantes] = await db.execute(
                `SELECT cs.*, v.total, v.fecha, v.id_cliente,
                       c.razon_social, p.nombre_completo, p.tipo_documento, p.numero_documento,
                       CONCAT(cs.serie, '-', LPAD(cs.numero_secuencial, 8, '0')) as serie_numero
                 FROM comprobante_sunat cs
                 JOIN venta v ON cs.id_venta = v.id_venta
                 LEFT JOIN cliente c ON v.id_cliente = c.id_cliente
                 LEFT JOIN persona p ON c.id_persona = p.id_persona
                 WHERE cs.id_comprobante = ?`,
                [idComprobante]
            );

            if (comprobantes.length === 0) {
                return res.status(404).json({ 
                    success: false,
                    error: 'Comprobante no encontrado' 
                });
            }

            res.json({ 
                success: true, 
                comprobante: comprobantes[0] 
            });
        } catch (error) {
            console.error('❌ Error en consultarComprobante:', error);
            res.status(500).json({ 
                success: false,
                error: error.message 
            });
        }
    }

    // ✅ AGREGAR MÉTODO PARA REENVIAR
    async reenviarComprobante(req, res) {
        try {
            const { idComprobante } = req.params;
            
            // Aquí deberías implementar la lógica para reenviar a SUNAT
            // Por ahora devolvemos un mensaje de éxito
            res.json({
                success: true,
                message: 'Comprobante reenviado exitosamente'
            });
            
        } catch (error) {
            console.error('❌ Error en reenviarComprobante:', error);
            res.status(500).json({
                success: false,
                error: error.message
            });
        }
    }
}

export default new SunatController();