import NProgress from "@/plugins/nprogress";
import router from "@/router";
import { useUserStore } from "@/stores";

export function setupPermissionGuard() {
  const whiteList = ["/login"];

  router.beforeEach(async (to, _from) => {
    NProgress.start();
    const userStore = useUserStore();

    try {
      const title = to.meta?.title as string | undefined;
      document.title = title ? `${title} - 友米SCRM` : "友米SCRM";

      if (!userStore.isLoggedIn()) {
        if (whiteList.includes(to.path)) {
          return;
        }
        NProgress.done();
        return `/login?redirect=${encodeURIComponent(to.fullPath)}`;
      }

      if (to.path === "/login") {
        return { path: "/" };
      }

      if (!userStore.userInfo?.roles?.length) {
        await userStore.getUserInfo();
      }

      if (to.matched.length === 0) {
        return "/404";
      }
    } catch (error) {
      console.error("Route guard error:", error);
      await userStore.resetAllState();
      NProgress.done();
      return "/login";
    }
  });

  router.afterEach(() => {
    NProgress.done();
  });
}
