"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const supabase_1 = require("../config/supabase");
const router = (0, express_1.Router)();
// Register
router.post('/register', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { email, password, full_name, student_id } = req.body;
    try {
        const { data, error } = yield supabase_1.supabase.auth.signUp({
            email,
            password,
            options: { data: { full_name, student_id } },
        });
        if (error)
            return res.status(400).json({ error: error.message });
        return res.status(201).json({ user: data.user, message: 'Registration successful' });
    }
    catch (err) {
        return res.status(500).json({ error: 'Internal server error' });
    }
}));
// Login
router.post('/login', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { email, password } = req.body;
    try {
        const { data, error } = yield supabase_1.supabase.auth.signInWithPassword({ email, password });
        if (error)
            return res.status(401).json({ error: error.message });
        return res.status(200).json({ user: data.user, session: data.session });
    }
    catch (err) {
        return res.status(500).json({ error: 'Internal server error' });
    }
}));
// Logout
router.post('/logout', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { error } = yield supabase_1.supabase.auth.signOut();
        if (error)
            return res.status(400).json({ error: error.message });
        return res.status(200).json({ message: 'Logged out successfully' });
    }
    catch (err) {
        return res.status(500).json({ error: 'Internal server error' });
    }
}));
exports.default = router;
