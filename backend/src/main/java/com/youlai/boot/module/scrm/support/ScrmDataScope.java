package com.youlai.boot.module.scrm.support;

import com.youlai.boot.security.util.SecurityUtils;

import java.util.Set;

public final class ScrmDataScope {

    private ScrmDataScope() {
    }

    public static boolean canViewAll() {
        Set<String> roles = SecurityUtils.getRoles();
        return SecurityUtils.isRoot()
                || roles.contains("ADMIN")
                || roles.contains("DEPT_MANAGER");
    }

    public static Long scopeOwnerId() {
        return canViewAll() ? null : SecurityUtils.getUserId();
    }
}
