<template>
  <q-layout view="lHh Lpr lFf">
    <q-page-container>
      <q-page class="page-shell">
        <section class="hero-panel">
          <div class="eyebrow">K8s Data Platform OVA</div>
          <h1>Ubuntu 24 위에 Docker, k3s, Airflow, Jupyter, Quasar를 한 번에 올리는 랩</h1>
          <p>
            FastAPI backend, Quasar frontend, MongoDB, Redis, Teradata ANSI SQL mock/live
            gateway, GitLab CI to Harbor 배포 흐름을 하나의 대시보드에서 확인합니다.
          </p>
          <div class="hero-actions">
            <q-btn
              color="dark"
              unelevated
              no-caps
              icon="refresh"
              label="Reload Dashboard"
              @click="loadDashboard"
            />
            <q-btn
              outline
              color="dark"
              no-caps
              icon="play_circle"
              label="Run ANSI SQL"
              @click="runFirstQuery"
            />
          </div>
        </section>

        <section class="section-grid">
          <q-card v-for="service in dashboard.services" :key="service.name" flat class="status-card">
            <q-card-section>
              <div class="row items-center justify-between">
                <div>
                  <div class="card-label">{{ service.kind }}</div>
                  <div class="card-title">{{ service.name }}</div>
                </div>
                <q-badge :color="service.ok ? 'positive' : 'negative'" rounded>
                  {{ service.ok ? "ready" : "check" }}
                </q-badge>
              </div>
              <div class="card-endpoint">{{ service.endpoint }}</div>
              <div class="card-detail">{{ service.detail }}</div>
            </q-card-section>
          </q-card>
        </section>

        <section class="content-grid">
          <q-card flat class="surface-card">
            <q-card-section>
              <div class="section-title">Runtime Profile</div>
              <div class="chip-grid">
                <q-chip
                  v-for="(value, key) in dashboard.runtime"
                  :key="key"
                  color="white"
                  text-color="dark"
                  square
                >
                  <strong>{{ key }}</strong>&nbsp;{{ value }}
                </q-chip>
              </div>
            </q-card-section>
          </q-card>

          <q-card flat class="surface-card">
            <q-card-section>
              <div class="section-title">Quick Links</div>
              <div class="button-grid">
                <q-btn
                  v-for="link in dashboard.quick_links"
                  :key="link.name"
                  :href="link.url"
                  target="_blank"
                  no-caps
                  outline
                  color="dark"
                  class="link-button"
                >
                  <div class="text-left full-width">
                    <div class="link-title">{{ link.name }}</div>
                    <div class="link-description">{{ link.description }}</div>
                  </div>
                </q-btn>
              </div>
            </q-card-section>
          </q-card>
        </section>

        <section class="content-grid">
          <q-card flat class="surface-card">
            <q-card-section>
              <div class="section-title">Sample ANSI SQL</div>
              <q-table
                flat
                :rows="dashboard.sample_queries"
                :columns="queryColumns"
                row-key="name"
                hide-pagination
              >
                <template #body-cell-sql="props">
                  <q-td :props="props">
                    <code class="sql-preview">{{ props.value }}</code>
                  </q-td>
                </template>
              </q-table>
            </q-card-section>
          </q-card>

          <q-card flat class="surface-card">
            <q-card-section>
              <div class="section-title">Notebook Workspace</div>
              <div v-if="dashboard.notebooks.length" class="notebook-list">
                <q-chip
                  v-for="notebook in dashboard.notebooks"
                  :key="notebook"
                  icon="book"
                  color="secondary"
                  text-color="white"
                >
                  {{ notebook }}
                </q-chip>
              </div>
              <q-banner v-else rounded class="banner-note">
                Shared notebook volume is empty. Jupyter pod will still start and can create files.
              </q-banner>
            </q-card-section>
          </q-card>
        </section>

        <section class="content-grid">
          <q-card flat class="surface-card">
            <q-card-section>
              <div class="section-title">Teradata Mode</div>
              <p class="muted">{{ dashboard.teradata.note }}</p>
              <q-banner rounded class="banner-note">
                Current mode: <strong>{{ dashboard.teradata.mode }}</strong>
              </q-banner>
            </q-card-section>
          </q-card>

          <q-card flat class="surface-card">
            <q-card-section>
              <div class="section-title">Query Result</div>
              <q-inner-loading :showing="queryLoading || loading">
                <q-spinner-grid color="dark" size="42px" />
              </q-inner-loading>
              <q-markup-table flat class="result-table" v-if="queryResult.rows.length">
                <thead>
                  <tr>
                    <th v-for="column in queryResult.columns" :key="column">{{ column }}</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(row, rowIndex) in queryResult.rows" :key="rowIndex">
                    <td v-for="column in queryResult.columns" :key="column">{{ row[column] }}</td>
                  </tr>
                </tbody>
              </q-markup-table>
              <q-banner v-else rounded class="banner-note">
                Run the first sample query to preview the Teradata response shape.
              </q-banner>
            </q-card-section>
          </q-card>
        </section>
      </q-page>
    </q-page-container>
  </q-layout>
</template>

<script setup>
import { Notify } from "quasar";
import { onMounted, ref } from "vue";

const apiBaseUrl = import.meta.env.VITE_API_BASE_URL || "http://localhost:8000";

const loading = ref(true);
const queryLoading = ref(false);

const dashboard = ref({
  runtime: {},
  services: [],
  quick_links: [],
  sample_queries: [],
  notebooks: [],
  teradata: {
    mode: "mock",
    note: "",
  },
});

const queryResult = ref({
  columns: [],
  rows: [],
});

const queryColumns = [
  { name: "name", label: "Query", field: "name", align: "left" },
  { name: "description", label: "Description", field: "description", align: "left" },
  { name: "sql", label: "SQL", field: "sql", align: "left" },
];

async function loadDashboard() {
  loading.value = true;
  try {
    const response = await fetch(`${apiBaseUrl}/api/dashboard`);
    if (!response.ok) {
      throw new Error(`Dashboard request failed: ${response.status}`);
    }
    dashboard.value = await response.json();
  } catch (error) {
    Notify.create({
      type: "negative",
      message: error.message,
    });
  } finally {
    loading.value = false;
  }
}

async function runFirstQuery() {
  const firstQuery = dashboard.value.sample_queries[0];
  if (!firstQuery) {
    return;
  }

  queryLoading.value = true;
  try {
    const response = await fetch(`${apiBaseUrl}/api/teradata/query`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        sql: firstQuery.sql,
        limit: 10,
      }),
    });

    if (!response.ok) {
      throw new Error(`Query request failed: ${response.status}`);
    }

    const payload = await response.json();
    queryResult.value = {
      columns: payload.columns,
      rows: payload.rows,
    };
    Notify.create({
      type: "positive",
      message: payload.note,
    });
  } catch (error) {
    Notify.create({
      type: "negative",
      message: error.message,
    });
  } finally {
    queryLoading.value = false;
  }
}

onMounted(async () => {
  await loadDashboard();
  await runFirstQuery();
});
</script>
