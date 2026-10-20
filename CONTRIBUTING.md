# 贡献指南

感谢你愿意改进这个复刻练习项目。提交前请确认改动符合项目的学习定位，并且没有引入任何真实业务数据或品牌素材。

## 可以贡献的内容

- 修复已有页面的交互、样式或类型错误；
- 增加通用组件与可访问性改进；
- 改进文档、启动流程和测试；
- 在**不复制源站资产或私有接口**的前提下，补充公开可见的交互模式；
- 用独立实现完善占位页面。

## 不接受的内容

- 参考产品的源代码、设计稿源文件、图片、字体、图标包或接口文档；
- 真实客户、员工、订单或个人数据；
- 绕过登录、绕过授权或抓取第三方系统数据的脚本；
- 用于冒充官方、商业运营或误导用户的品牌素材；
- 明文密钥、数据库密码、JWT 密钥或云平台凭据。

## 开发流程

1. 从 `main` 创建分支：`feat/xxx`、`fix/xxx`、`docs/xxx`。
2. 按 `.env.example` 配置本地环境并完成启动。
3. 修改后运行：

   ```bash
   cd frontend
   pnpm type-check
   pnpm build

   cd ../backend
   mvn -q -DskipTests package
   ```

4. 在 Pull Request 中描述改动、验证步骤和截图（如需要）。截图必须来自本地演示数据，并已完成脱敏。

## 代码约定

### 前端

- 页面放在 `frontend/src/views/youmi/`，复用 `styles/youmi.scss` 中的设计令牌。
- 静态路由集中在 `frontend/src/router/index.ts`；新增导航时同步更新 `youmi/menu.ts`。
- 筛选、表格、分页和详情抽屉遵循现有页面模式，避免为单个页面复制大段样式。
- API 封装集中在 `frontend/src/api/youmi/` 或复用 `api/scrm/`。
- 后端返回的 `Long` 字段可能是字符串，参与计算前使用 `Number()`。
- 通过 `pnpm type-check` 与 `pnpm build`。

### 后端

- 复刻版新增接口放在 `module/youmi/`，通用业务复用 `module/scrm/`。
- 保持统一响应结构，分页使用 `PageResult`。
- 涉及聚合查询时显式处理空数据、除零和时区边界。
- 新增 SQL 变更时同步更新 `sql/youmi_scrm.sql`，并说明升级路径。

## 提交信息

```text
feat(order): add batch audit confirmation
fix(report): guard division by zero in win rate
docs(design): document navigation tokens
```

## 品牌与合规

提交涉及品牌名称、Logo 或产品宣传语的内容前，请先确认使用场景合法。维护者有权拒绝可能造成官方关联误解的贡献。

## 安全

请勿公开披露未修复的漏洞。报告方式见 [SECURITY.md](SECURITY.md)。
