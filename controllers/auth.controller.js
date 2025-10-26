// backend/controllers/authController.js
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import db from '../config/db.js'; // tu conexión a MySQL

const SECRET_KEY = process.env.JWT_SECRET || 'agua-vina-secret-key';

// 🧩 REGISTRO DE USUARIO
export const register = async (req, res) => {
  try {
    const { nombre_usuario, email, password, id_rol, id_persona } = req.body;

    if (!nombre_usuario || !email || !password || !id_rol || !id_persona) {
      return res.status(400).json({ message: 'Faltan campos obligatorios' });
    }

    // Verificar si ya existe
    const [userExists] = await db.query(
      'SELECT * FROM usuario WHERE nombre_usuario = ? OR email = ?',
      [nombre_usuario, email]
    );
    if (userExists.length > 0) {
      return res.status(409).json({ message: 'Usuario o correo ya registrado' });
    }

    // Hashear contraseña
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insertar usuario
    const [result] = await db.query(
      'INSERT INTO usuario (nombre_usuario, email, password, id_rol, id_persona, activo) VALUES (?, ?, ?, ?, ?, 1)',
      [nombre_usuario, email, hashedPassword, id_rol, id_persona]
    );

    const id_usuario = result.insertId;

    // Generar token
    const token = jwt.sign({ id_usuario, nombre_usuario, id_rol }, SECRET_KEY, { expiresIn: '8h' });

    res.status(201).json({
      message: 'Usuario registrado exitosamente',
      token,
      user: {
        id: id_usuario,
        username: nombre_usuario,
        role: id_rol,
        email
      }
    });
  } catch (error) {
    console.error('❌ Error en register:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
};
