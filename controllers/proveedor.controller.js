import db from "../config/db.js";

export const getProveedores = async (req, res) => {
  try {
    const [rows] = await db.query("SELECT * FROM proveedor");
    res.json(rows);
  } catch (error) {
    console.error("Error al obtener proveedor:", error);
    res.status(500).json({ message: "Error al obtener proveedor" });
  }
};