import express from "express";
import { getCategorias } from "../controllers/categoria.controller.js";

const router = express.Router();

router.get("/", getCategorias);

export default router;