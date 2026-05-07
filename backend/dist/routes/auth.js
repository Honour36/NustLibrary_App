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
    var _a;
    const { email, password, full_name, student_id } = req.body;
    console.log(`[Auth] Registration attempt: ${email}`);
    try {
        // We use admin.createUser to bypass email confirmation requirements
        // This requires the SUPABASE_SERVICE_ROLE_KEY to be set in .env
        const { data, error } = yield supabase_1.supabase.auth.admin.createUser({
            email,
            password,
            email_confirm: true,
            user_metadata: { full_name, student_id }
        });
        if (error) {
            console.warn(`[Auth] Admin registration failed for ${email}, falling back to signUp:`, error.message);
            // Fallback to standard signUp if admin creation fails (e.g. missing service role key)
            const { data: signUpData, error: signUpError } = yield supabase_1.supabase.auth.signUp({
                email,
                password,
                options: { data: { full_name, student_id } },
            });
            if (signUpError) {
                return res.status(400).json({ error: signUpError.message });
            }
            // Try to auto-confirm if possible (though email was already sent by signUp)
            if (signUpData.user) {
                try {
                    yield supabase_1.supabase.auth.admin.updateUserById(signUpData.user.id, { email_confirm: true });
                }
                catch (e) {
                    console.log('[Auth] Auto-confirm failed during fallback');
                }
            }
            return res.status(201).json({
                user: signUpData.user,
                message: 'Registration successful. Please check your email if confirmation is required.'
            });
        }
        console.log(`[Auth] User created via admin: ${(_a = data.user) === null || _a === void 0 ? void 0 : _a.id}`);
        return res.status(201).json({
            user: data.user,
            message: 'Registration successful'
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
