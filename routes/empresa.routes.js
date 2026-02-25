// ============================================
// RUTAS DE EMPRESA - VERSIÓN ESCALABLE
// ============================================
import express from 'express';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { 
    getEmpresaConfig, 
    updateEmpresaConfig,
    uploadLogo 
} from '../controllers/empresa.controller.js';
import { verifyToken, requireRole } from '../middleware/auth.js';
import paths from '../config/paths.js'; // ✅ Importar configuración de rutas

const router = express.Router();

// ============================================
// 🎯 CONFIGURACIÓN DE MULTER - USANDO RUTAS CONFIGURADAS
// ============================================
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        // ✅ Usar la ruta configurada
        const targetPath = paths.frontend.empresa;
        
        console.log('📁 Guardando logos en:', targetPath);
        
        // Crear la carpeta si no existe
        if (!fs.existsSync(targetPath)) {
            console.log('📁 Creando carpeta:', targetPath);
            fs.mkdirSync(targetPath, { recursive: true });
        }
        
        cb(null, targetPath);
    },
    
    filename: (req, file, cb) => {
        const tipo = req.body.tipo || 'logo';
        const ext = path.extname(file.originalname);
        const filename = `logo-${tipo}-${Date.now()}${ext}`;
        console.log('📄 Nombre de archivo:', filename);
        cb(null, filename);
    }
});

const upload = multer({ 
    storage: storage,
    limits: { fileSize: 2 * 1024 * 1024 },
    fileFilter: (req, file, cb) => {
        const allowedTypes = /jpeg|jpg|png|gif|svg/;
        const ext = allowedTypes.test(path.extname(file.originalname).toLowerCase());
        const mime = allowedTypes.test(file.mimetype);
        
        if (ext && mime) {
            cb(null, true);
        } else {
            cb(new Error('Solo se permiten imágenes (JPEG, PNG, GIF, SVG)'));
        }
    }
});

// Rutas
router.get('/config', getEmpresaConfig);
router.use(verifyToken);
router.put('/config', requireRole([1], 'empresa'), updateEmpresaConfig);
router.post('/upload-logo', 
    requireRole([1], 'empresa'), 
    upload.single('logo'), 
    uploadLogo
);

export default router;