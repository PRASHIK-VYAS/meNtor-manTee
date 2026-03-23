const roleMiddleware = (allowedRoles) => {
    return (req, res, next) => {
        const roles = Array.isArray(allowedRoles) ? allowedRoles : [allowedRoles];
        if (!roles.includes(req.user.role)) {
            return res.status(403).json({ message: 'Access forbidden.' });
        }
        next();
    };
};

module.exports = roleMiddleware;