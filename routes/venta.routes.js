// src/routes/venta.routes.js
import express from 'express';
import { 
    getVentas, 
    getVentaById, 
    createVenta, 
    updateEstadoVenta,
    getVentasPorEstado,  // ✅ AGREGAR ESTA IMPORTACIÓN
    asignarRepartidor    // ✅ AGREGAR ESTA IMPORTACIÓN
} from '../controllers/venta.controller.js';
import { verifyToken, requireRole } from '../middleware/auth.js';

const router = express.Router();

// Todas las rutas requieren autenticación y módulo 'ventas'
router.use(verifyToken);

// Rutas de ventas
router.get('/', requireRole([1, 2], 'ventas'), getVentas);
router.get('/:id', requireRole([1, 2], 'ventas'), getVentaById);
router.post('/', requireRole([1, 2], 'ventas'), createVenta);
router.patch('/:id/estado', requireRole([1, 2], 'ventas'), updateEstadoVenta);

// Rutas específicas
router.get('/estado/:estadoId', requireRole([1, 2], 'ventas'), getVentasPorEstado);
router.patch('/:id/asignar-repartidor', requireRole([1, 2], 'ventas_asignacion_rutas'), asignarRepartidor); // Usa módulo 'rutas'

export default router;