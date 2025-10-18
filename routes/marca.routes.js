import express from "express";
import { getMarcas } from "../controllers/marca.controller.js";

const router = express.Router();

router.get("/", getMarcas);

export default router;