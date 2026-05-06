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
    var _a, _b;
    const { email, password, full_name, student_id } = req.body;
    console.log(`[Auth] Registration attempt: ${email}`);
    try {
        const { data, error } = yield supabase_1.supabase.auth.signUp({
            email,
            password,
            options: { data: { full_name, student_id } },
        });
        if (error) {
            console.error(`[Auth] Registration failed for ${email}:`, error.message);
            return res.status(400).json({ error: error.message });
        }
        // Try to auto-confirm if we have admin privileges (optional/best effort)
        try {
            if (data.user) {
                yield supabase_1.supabase.auth.admin.updateUserById(data.user.id, { email_confirm: true });
                console.log(`[Auth] Auto-confirmed user: ${data.user.id}`);
            }
        }
        catch (adminErr) {
            console.log(`[Auth] Could not auto-confirm (expected if using anon key): ${adminErr.message}`);
        }
        console.log(`[Auth] User created: ${(_a = data.user) === null || _a === void 0 ? void 0 : _a.id} (Confirmed: ${((_b = data.user) === null || _b === void 0 ? void 0 : _b.email_confirmed_at) != null})`);
        return res.status(201).json({
            user: data.user,
            session: data.session,
            message: data.session ? 'Registration successful' : 'Registration successful, please confirm your email'
        });
    }
    catch (err) {
        console.error(`[Auth] Internal registration error:`, err);
        return res.status(500).json({ error: 'Internal server error' });
    }
}));
// Login
router.post('/login', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _a;
    const { email, password } = req.body;
    console.log(`[Auth] Login attempt: ${email}`);
    // Development Bypass for local testing/demo
    if (process.env.NODE_ENV !== 'production' && password === 'nust_bypass_2024') {
        console.log(`[Auth] Bypass login triggered for ${email}`);
        return res.status(200).json({
            user: { id: '00000000-0000-0000-0000-000000000000', email, user_metadata: { full_name: 'Dev User' } },
            session: { access_token: 'mock-session-token', expires_in: 3600 }
        });
    }
    try {
        const { data, error } = yield supabase_1.supabase.auth.signInWithPassword({ email, password });
        if (error) {
            console.warn(`[Auth] Login failed for ${email}:`, error.message);
            // Handle specific Supabase errors
            if (error.message.includes('Invalid login credentials')) {
                return res.status(401).json({ error: 'The email or password you entered is incorrect.' });
            }
            if (error.message.toLowerCase().includes('confirm')) {
                return res.status(401).json({ error: 'Email not confirmed. Please check your inbox for a verification link.' });
            }
            return res.status(401).json({ error: error.message });
        }
        console.log(`[Auth] Login successful: ${(_a = data.user) === null || _a === void 0 ? void 0 : _a.id}`);
        return res.status(200).json({ user: data.user, session: data.session });
    }
    catch (err) {
        console.error(`[Auth] Internal login error:`, err);
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
