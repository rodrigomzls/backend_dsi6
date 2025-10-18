import db from "../config/db.js";

// Obtener todos los clientes
export const getClientes = async (req, res) => {
  try {
    const [rows] = await db.query("SELECT * FROM cliente");
    
    const clientesMapeados = rows.map(cliente => ({
      id: cliente.id_cliente,
      nombre: cliente.nombre,
      telefono: cliente.telefono,
      direccion: cliente.direccion,
      distritoId: cliente.id_distrito,
      tipoCliente: cliente.tipo_cliente,
      activo: cliente.activo,
      fechaRegistro: cliente.fecha_registro
    }));
    
    console.log('Clientes mapeados:', clientesMapeados);
    res.json(clientesMapeados);
  } catch (error) {
    console.error("Error al obtener clientes:", error);
    res.status(500).json({ message: "Error al obtener clientes" });
  }
};

// Obtener cliente por ID
export const getClienteById = async (req, res) => {
  try {
    const [rows] = await db.query("SELECT * FROM cliente WHERE id_cliente = ?", [req.params.id]);
    if (rows.length === 0) return res.status(404).json({ message: "Cliente no encontrado" });
    
    const cliente = rows[0];
    const clienteMapeado = {
      id: cliente.id_cliente,
      nombre: cliente.nombre,
      telefono: cliente.telefono,
      direccion: cliente.direccion,
      distritoId: cliente.id_distrito,
      tipoCliente: cliente.tipo_cliente,
      activo: cliente.activo,
      fechaRegistro: cliente.fecha_registro
    };
    
    res.json(clienteMapeado);
  } catch (error) {
    console.error("Error al obtener cliente:", error);
    res.status(500).json({ message: "Error al obtener cliente" });
  }
};

// Crear nuevo cliente
export const createCliente = async (req, res) => {
  try {
    const { nombre, telefono, direccion, distritoId, tipoCliente } = req.body;
    
    const [result] = await db.query(
      "INSERT INTO cliente (nombre, telefono, direccion, id_distrito, tipo_cliente) VALUES (?, ?, ?, ?, ?)",
      [nombre, telefono, direccion, distritoId, tipoCliente]
    );
    
    res.status(201).json({ 
      id: result.insertId, 
      message: "Cliente creado correctamente" 
    });
  } catch (error) {
    console.error("Error al crear cliente:", error);
    res.status(500).json({ message: "Error al crear cliente" });
  }
};

// Actualizar cliente
export const updateCliente = async (req, res) => {
  try {
    const { id } = req.params;
    const { nombre, telefono, direccion, distritoId, tipoCliente, activo } = req.body;

    const [result] = await db.query(
      "UPDATE cliente SET nombre = ?, telefono = ?, direccion = ?, id_distrito = ?, tipo_cliente = ?, activo = ? WHERE id_cliente = ?",
      [nombre, telefono, direccion, distritoId, tipoCliente, activo, id]
    );

    if (result.affectedRows === 0)
      return res.status(404).json({ message: "Cliente no encontrado" });

    res.json({ message: "Cliente actualizado correctamente" });
  } catch (error) {
    console.error("Error al actualizar cliente:", error);
    res.status(500).json({ message: "Error al actualizar cliente" });
  }
};

// Eliminar cliente
export const deleteCliente = async (req, res) => {
  try {
    const [result] = await db.query("DELETE FROM cliente WHERE id_cliente = ?", [req.params.id]);
    if (result.affectedRows === 0)
      return res.status(404).json({ message: "Cliente no encontrado" });

    res.json({ message: "Cliente eliminado correctamente" });
  } catch (error) {
    console.error("Error al eliminar cliente:", error);
    res.status(500).json({ message: "Error al eliminar cliente" });
  }
};