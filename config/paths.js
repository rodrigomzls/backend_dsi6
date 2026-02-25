// backend_dsi6/config/paths.js
import path from 'path';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Determinar si estamos en producción
const isProduction = process.env.NODE_ENV === 'production';

// Raíz del proyecto (subimos 2 niveles desde /config hasta la raíz)
const projectRoot = path.join(__dirname, '../..');

// Definir rutas según el entorno
const paths = {
    // Rutas del frontend
    frontend: {
        root: path.join(projectRoot, 'frontend_dsi6'),
        assets: isProduction 
            ? path.join(projectRoot, 'frontend_dsi6', 'dist', 'assets')
            : path.join(projectRoot, 'frontend_dsi6', 'src', 'assets'),
        empresa: isProduction
            ? path.join(projectRoot, 'frontend_dsi6', 'dist', 'assets', 'empresa')
            : path.join(projectRoot, 'frontend_dsi6', 'src', 'assets', 'empresa')
    },
    
    // URLs públicas
    urls: {
        assets: '/assets',
        empresa: '/assets/empresa'
    },
    
    // Configuración
    isProduction,
    projectRoot
};

// Logs para depuración
console.log('📁 Configuración de rutas:');
console.log('   🏭 Modo:', isProduction ? 'PRODUCCIÓN' : 'DESARROLLO');
console.log('   📂 Assets:', paths.frontend.assets);
console.log('   📂 Empresa:', paths.frontend.empresa);

export default paths;