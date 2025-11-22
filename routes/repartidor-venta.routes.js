// src/routes/repartidor-venta.routes.js
import express from 'express';
import {
    getVentasAsignadas,
    getEntregasPendientes,
    getHistorialEntregas,
    getVentaDetalleAsignada,
    updateEstadoVentaRepartidor, // Nueva función
    cancelarEntregaRepartidor,
    iniciarRutaEntrega    // Nueva función
} from '../controllers/repartidor-venta.controller.js';
import { verifyToken, requireRole } from '../middleware/auth.js';

const router = express.Router();

// Todas las rutas requieren autenticación
router.use(verifyToken);

// Rutas existentes
router.get('/repartidor/asignadas', requireRole([3],'rutas_asignadas'), getVentasAsignadas);
router.get('/repartidor/pendientes', requireRole([3],'entregas_pendientes'), getEntregasPendientes);
router.get('/repartidor/historial', requireRole([3],'historial_entregas'), getHistorialEntregas);
router.get('/repartidor/detalle/:id', requireRole([3], 'rutas_asignadas'), getVentaDetalleAsignada);

// NUEVAS RUTAS PARA ACTUALIZAR ESTADO
router.patch('/repartidor/:id/pagado', requireRole([3], 'entregas_pendientes'), updateEstadoVentaRepartidor);
router.patch('/repartidor/:id/cancelado', requireRole([3], 'entregas_pendientes'), cancelarEntregaRepartidor);
router.patch('/repartidor/:id/iniciar-ruta', requireRole([3], 'rutas_asignadas'), iniciarRutaEntrega);
export default router;