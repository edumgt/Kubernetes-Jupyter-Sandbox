import { mkdir } from "node:fs/promises";
import { chromium } from "playwright";

const outputDir = process.env.OUTPUT_DIR ?? "/workspace/docs/screenshots";
const frontendUrl = (process.env.FRONTEND_URL ?? "http://127.0.0.1:30080").replace(/\/$/, "");
const backendUrl = (process.env.BACKEND_URL ?? "http://127.0.0.1:30081").replace(/\/$/, "");
const airflowUrl = (process.env.AIRFLOW_URL ?? "http://127.0.0.1:30090").replace(/\/$/, "");
const jupyterUrl = (process.env.JUPYTER_URL ?? "http://127.0.0.1:30088").replace(/\/$/, "");
const gitlabUrl = (process.env.GITLAB_URL ?? "http://127.0.0.1:30089").replace(/\/$/, "");
const test1LabUrl = process.env.TEST1_LAB_URL ?? "";
const test1Username = process.env.TEST1_USERNAME ?? "test1@test.com";
const test1Password = process.env.TEST1_PASSWORD ?? "123456";
const adminUsername = process.env.ADMIN_USERNAME ?? process.env.CONTROL_PLANE_USERNAME ?? "admin@test.com";
const adminPassword = process.env.ADMIN_PASSWORD ?? process.env.CONTROL_PLANE_PASSWORD ?? "123456";
const browserCdpUrl = process.env.BROWSER_CDP_URL ?? "";

const targetSet = new Set(
  (
    process.env.CAPTURE_TARGETS ??
    "frontend,backend,airflow,jupyter,gitlab,control-plane-login,control-plane-nodes,control-plane-pods,user-jupyter-hello,admin-active-users"
  )
    .split(",")
    .map((value) => value.trim().toLowerCase())
    .filter(Boolean),
);

async function ensureDir() {
  await mkdir(outputDir, { recursive: true });
}

async function sleep(ms) {
  await new Promise((resolve) => setTimeout(resolve, ms));
}

async function waitForHttp(url, { timeoutMs = 300000, intervalMs = 5000 } = {}) {
  const deadline = Date.now() + timeoutMs;

  while (Date.now() < deadline) {
    try {
      const response = await fetch(url, { redirect: "manual" });
      if (response.status >= 200 && response.status < 400) {
        return;
      }
    } catch {
      // Keep polling until the service is reachable.
    }

    await sleep(intervalMs);
  }

  throw new Error(`Timed out waiting for ${url}`);
}

function withHash(url, hash = "") {
  return hash ? `${url}/${hash}` : `${url}/`;
}

async function createPage(browser, height = 1200) {
  return browser.newPage({
    viewport: { width: 1440, height },
  });
}

async function loginApp(page, username, password) {
  await page.getByLabel("Email").fill(username);
  await page.getByLabel("Password").fill(password);
  await page.getByRole("button", { name: "Login" }).click();
  await page.getByRole("button", { name: "Logout" }).waitFor({ state: "visible", timeout: 180000 });
  await page.waitForLoadState("networkidle", { timeout: 180000 }).catch(() => {});
}

async function loginAdmin(page) {
  await loginApp(page, adminUsername, adminPassword);
}

async function captureFrontend(browser) {
  await waitForHttp(frontendUrl, { timeoutMs: 180000 });
  const page = await createPage(browser, 1300);
  await page.goto(withHash(frontendUrl), { waitUntil: "networkidle", timeout: 180000 });
  await page.screenshot({ path: `${outputDir}/frontend-dashboard.png`, fullPage: true });
  await page.close();
}

async function captureBackend(browser) {
  const docsUrl = `${backendUrl}/docs`;
  await waitForHttp(docsUrl, { timeoutMs: 180000 });
  const page = await createPage(browser, 1024);
  await page.goto(docsUrl, { waitUntil: "networkidle", timeout: 180000 });
  await page.screenshot({ path: `${outputDir}/backend-openapi.png`, fullPage: true });
  await page.close();
}

async function captureAirflow(browser) {
  const loginUrl = `${airflowUrl}/login/`;
  await waitForHttp(loginUrl, { timeoutMs: 240000 });
  const page = await createPage(browser, 1024);
  await page.goto(loginUrl, { waitUntil: "domcontentloaded", timeout: 240000 });
  await page.getByLabel("Username").fill("admin");
  await page.getByLabel("Password").fill("admin12345!");
  await page.getByRole("button", { name: /sign in/i }).click();
  await page.waitForLoadState("networkidle", { timeout: 240000 });
  await page.screenshot({ path: `${outputDir}/airflow-home.png`, fullPage: true });
  await page.close();
}

async function captureJupyter(browser) {
  const loginUrl = `${jupyterUrl}/login`;
  await waitForHttp(loginUrl, { timeoutMs: 240000 });
  const page = await createPage(browser, 1024);
  await page.goto(loginUrl, { waitUntil: "domcontentloaded", timeout: 240000 });
  await page.getByLabel("Password or token").fill("platform123");
  await page.getByRole("button", { name: /log in/i }).click();
  await page.waitForURL(/lab/, { timeout: 240000 });
  await page.waitForLoadState("networkidle", { timeout: 240000 }).catch(() => {});
  await page.screenshot({ path: `${outputDir}/jupyter-lab.png`, fullPage: true });
  await page.close();
}

async function captureGitLab(browser) {
  const loginUrl = `${gitlabUrl}/users/sign_in`;
  await waitForHttp(loginUrl, { timeoutMs: 600000 });
  const page = await createPage(browser, 1024);
  await page.goto(loginUrl, { waitUntil: "domcontentloaded", timeout: 480000 });
  await page.getByLabel(/username or primary email/i).fill("root");
  await page.getByLabel(/^password$/i).fill("v7Q#2mL!9xC@4pR%8tZ");
  await page.getByRole("button", { name: /sign in/i }).click();
  await page.waitForLoadState("networkidle", { timeout: 480000 });
  await page.screenshot({ path: `${outputDir}/gitlab-dashboard.png`, fullPage: true });
  await page.close();
}

async function captureControlPlaneLogin(browser) {
  await waitForHttp(frontendUrl, { timeoutMs: 180000 });
  const page = await createPage(browser, 1300);
  await page.goto(withHash(frontendUrl, "#sandbox-admin"), {
    waitUntil: "networkidle",
    timeout: 180000,
  });
  await page.screenshot({ path: `${outputDir}/k8s-control-plane-login.png`, fullPage: true });
  await page.close();
}

async function captureControlPlaneNodes(browser) {
  await waitForHttp(frontendUrl, { timeoutMs: 180000 });
  const page = await createPage(browser, 1400);
  await page.goto(withHash(frontendUrl, "#sandbox-admin"), {
    waitUntil: "networkidle",
    timeout: 180000,
  });
  await loginAdmin(page);
  await page.getByText("Control Plane Dashboard").waitFor({ timeout: 180000 });
  const section = page.locator("section").filter({ hasText: "Control Plane Dashboard" }).first();
  await section.scrollIntoViewIfNeeded();
  await page.waitForTimeout(1000);
  await section.screenshot({ path: `${outputDir}/k8s-control-plane-nodes.png` });
  await page.close();
}

async function captureControlPlanePods(browser) {
  await waitForHttp(frontendUrl, { timeoutMs: 180000 });
  const page = await createPage(browser, 1400);
  await page.goto(withHash(frontendUrl, "#sandbox-admin"), {
    waitUntil: "networkidle",
    timeout: 180000,
  });
  await loginAdmin(page);
  const section = page.locator("section").filter({ hasText: "Control Plane Dashboard" }).first();
  await section.scrollIntoViewIfNeeded();
  await page.getByRole("tab", { name: "Pods" }).click();
  await page.waitForLoadState("networkidle", { timeout: 180000 }).catch(() => {});
  await page.waitForTimeout(1000);
  await section.screenshot({ path: `${outputDir}/k8s-control-plane-pods.png` });
  await page.close();
}

async function captureUserJupyterHello(browser) {
  if (!test1LabUrl) {
    throw new Error("TEST1_LAB_URL is required for the user-jupyter-hello capture.");
  }

  await waitForHttp(test1LabUrl, { timeoutMs: 240000, intervalMs: 3000 });
  const page = await createPage(browser, 1100);
  await page.goto(test1LabUrl, { waitUntil: "domcontentloaded", timeout: 240000 });
  await page.getByRole("heading", { name: "test1@test.com sandbox" }).waitFor({ timeout: 240000 });
  await page.getByText("hello world", { exact: true }).first().waitFor({ timeout: 240000 });
  await page.waitForLoadState("networkidle", { timeout: 240000 }).catch(() => {});
  await page.screenshot({ path: `${outputDir}/user-jupyter-hello-world.png` });
  await page.close();
}

async function captureAdminActiveUsers(browser) {
  await waitForHttp(frontendUrl, { timeoutMs: 180000 });
  const page = await createPage(browser, 1500);
  await page.goto(withHash(frontendUrl, "#sandbox-admin"), {
    waitUntil: "networkidle",
    timeout: 180000,
  });
  await loginAdmin(page);
  const section = page.locator("#sandbox-admin");
  await section.waitFor({ state: "visible", timeout: 180000 });
  await section.scrollIntoViewIfNeeded();
  await section.getByText(/running/i).first().waitFor({ timeout: 180000 });
  await page.waitForTimeout(1000);
  await section.screenshot({ path: `${outputDir}/admin-dashboard-running-users.png` });
  await page.close();
}

const captures = [
  ["frontend", captureFrontend],
  ["backend", captureBackend],
  ["airflow", captureAirflow],
  ["jupyter", captureJupyter],
  ["gitlab", captureGitLab],
  ["control-plane-login", captureControlPlaneLogin],
  ["control-plane-nodes", captureControlPlaneNodes],
  ["control-plane-pods", captureControlPlanePods],
  ["user-jupyter-hello", captureUserJupyterHello],
  ["admin-active-users", captureAdminActiveUsers],
];

const browser = browserCdpUrl
  ? await chromium.connectOverCDP(browserCdpUrl)
  : await chromium.launch({ headless: true });

try {
  await ensureDir();
  for (const [name, capture] of captures) {
    if (!targetSet.has(name)) {
      continue;
    }
    await capture(browser);
  }
} finally {
  await browser.close();
}
