import db from "../config/db.js";

// Obtener todos los proveedores con información de persona
export const getProveedores = async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT 
        p.id_proveedor,
        per.nombre_completo as nombre,
        p.razon_social,
        per.telefono,
        per.direccion,
        p.activo
      FROM proveedor p
      INNER JOIN persona per ON p.id_persona = per.id_persona
      WHERE p.activo = TRUE
      ORDER BY per.nombre_completo
    `);
    
    // Mapear para que tenga el formato esperado
    const proveedoresMapeados = rows.map(proveedor => ({
      id_proveedor: proveedor.id_proveedor,
      nombre: proveedor.nombre || proveedor.razon_social, // Usar nombre_completo o razon_social
      razon_social: proveedor.razon_social
    }));
    
    res.json(proveedoresMapeados);
  } catch (error) {
    console.error("Error al obtener proveedores:", error);
    res.status(500).json({ message: "Error al obtener proveedores" });
  }
};