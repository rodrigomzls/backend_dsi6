// src/routes/auth.routes.js
import express from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import db from '../config/db.js';

const router = express.Router();

// Login
router.post('/login', async (req, res) => {
    try {
        // Recibimos "contrasena" del frontend pero usamos "password" para la BD
        const { nombre_usuario, password } = req.body;

        console.log('Intento de login:', { nombre_usuario, password }); // Para debug

        const [users] = await db.execute(
            `SELECT u.*, r.rol, p.nombre_completo 
             FROM usuario u 
             JOIN rol r ON u.id_rol = r.id_rol 
             JOIN persona p ON u.id_persona = p.id_persona 
             WHERE u.nombre_usuario = ? AND u.activo = 1`,
            [nombre_usuario]
        );

        if (users.length === 0) {
            console.log('Usuario no encontrado:', nombre_usuario);
            return res.status(400).json({ error: 'Usuario o password incorrectos.' });
        }

        const user = users[0];
        console.log('Usuario encontrado:', user.nombre_usuario);
        
        // IMPORTANTE: Verificar que la password de la BD existe
        if (!user.password) {
            console.log('La columna password está vacía o no existe');
            return res.status(400).json({ error: 'Error en la configuración del usuario.' });
        }

        // Comparar passwords - usamos "contrasena" del frontend con "password" de la BD
        const validPassword = await bcrypt.compare(password, user.password);
        console.log('password válida:', validPassword);

        if (!validPassword) {
            return res.status(400).json({ error: 'Usuario o password incorrectos.' });
        }

        const token = jwt.sign(
            { 
                userId: user.id_usuario, 
                role: user.id_rol,
                username: user.nombre_usuario 
            },
            process.env.JWT_SECRET || 'fallback_secret',
            { expiresIn: '8h' }
        );

        res.json({
            token,
            user: {
                id: user.id_usuario,
                username: user.nombre_usuario,
                nombre: user.nombre_completo,
                role: user.id_rol,
                roleName: user.rol
            }
        });

    } catch (error) {
        console.error('Error en login:', error);
        res.status(500).json({ error: 'Error interno del servidor.' });
    }
});

// Verificar token (sin cambios)
router.get('/verify', async (req, res) => {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (!token) {
        return res.status(401).json({ valid: false });
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
            return res.status(401).json({ valid: false });
        }
        
        const user = users[0];
        res.json({
            valid: true,
            user: {
                id: user.id_usuario,
                username: user.nombre_usuario,
                nombre: user.nombre_completo,
                role: user.id_rol,
                roleName: user.rol
            }
        });
    } catch (error) {
        res.status(401).json({ valid: false });
    }
});

export default router;