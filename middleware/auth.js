// src/middleware/auth.js
import jwt from 'jsonwebtoken';
import db from '../config/db.js';

export const verifyToken = async (req, res, next) => {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (!token) {
        return res.status(401).json({ error: 'Acceso denegado. Token requerido.' });
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET || 'fallback_secret');
        const [users] = await db.execute(
            `SELECT u.*, r.rol, p.nombre_completo 
             FROM usuario u 
             JOIN rol r ON u.id_rol = r.id_rol 
             JOIN persona p ON u.id_persona = p.id_persona 
             WHERE u.id_usuario = ? AND u.activo = 1`,
            [decoded.userId]
        );
        
        if (users.length === 0) {
            return res.status(401).json({ error: 'Token inválido.' });
        }
        
        req.user = users[0];
        next();
    } catch (error) {
        res.status(401).json({ error: 'Token inválido.' });
    }
};

export const requireRole = (roles) => {
    return (req, res, next) => {
        if (!roles.includes(req.user.id_rol)) {
            return res.status(403).json({ error: 'No tienes permisos para esta acción.' });
        }
        next();
    };
};