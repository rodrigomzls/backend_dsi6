// src/routes/auth.routes.js
import express from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import db from '../config/db.js';

const router = express.Router();

// ========================== LOGIN ==========================
router.post('/login', async (req, res) => {
  try {
    const { nombre_usuario, password } = req.body;

    const [users] = await db.execute(
      `SELECT u.*, r.rol, p.nombre_completo 
       FROM usuario u 
       JOIN rol r ON u.id_rol = r.id_rol 
       JOIN persona p ON u.id_persona = p.id_persona 
       WHERE u.nombre_usuario = ? AND u.activo = 1`,
      [nombre_usuario]
    );

    if (users.length === 0) {
      return res.status(400).json({ error: 'Usuario o password incorrectos.' });
    }

    const user = users[0];
    const validPassword = await bcrypt.compare(password, user.password);

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

// ========================== VERIFY TOKEN ==========================
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

// ========================== REGISTER ==========================
router.post('/register', async (req, res) => {
  try {
    const { nombre_usuario, email, password, id_rol, id_persona } = req.body;

    if (!nombre_usuario || !email || !password || !id_rol) {
      return res.status(400).json({ message: 'Faltan campos obligatorios' });
    }

    // Verificar si ya existe usuario o email
    const [existing] = await db.execute(
      'SELECT * FROM usuario WHERE nombre_usuario = ? OR email = ?',
      [nombre_usuario, email]
    );
    if (existing.length > 0) {
      return res.status(409).json({ message: 'Usuario o correo ya registrado' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const [result] = await db.execute(
      'INSERT INTO usuario (nombre_usuario, email, password, id_rol, id_persona, activo) VALUES (?, ?, ?, ?, ?, 1)',
      [nombre_usuario, email, hashedPassword, id_rol, id_persona || null]
    );

    const id_usuario = result.insertId;

    const token = jwt.sign(
      { id_usuario, nombre_usuario, id_rol },
      process.env.JWT_SECRET || 'fallback_secret',
      { expiresIn: '8h' }
    );

    res.status(201).json({
      message: 'Usuario registrado exitosamente',
      token,
      user: {
        id: id_usuario,
        username: nombre_usuario,
        email,
        role: id_rol
      }
    });
  } catch (error) {
    console.error('Error en register:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
});

export default router;
