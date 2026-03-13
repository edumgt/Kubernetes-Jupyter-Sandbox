from typing import Any

from pydantic import BaseModel, Field


class ServiceStatus(BaseModel):
    name: str
    kind: str
    endpoint: str
    ok: bool
    detail: str


class QuickLink(BaseModel):
    name: str
    url: str
    description: str


class SampleQuery(BaseModel):
    name: str
    description: str
    sql: str


class DashboardResponse(BaseModel):
    runtime: dict[str, str]
    services: list[ServiceStatus]
    quick_links: list[QuickLink]
    sample_queries: list[SampleQuery]
    notebooks: list[str]
    teradata: dict[str, Any]


class TeradataQueryRequest(BaseModel):
    sql: str = Field(min_length=1)
    limit: int = Field(default=20, ge=1, le=200)


class TeradataQueryResponse(BaseModel):
    columns: list[str]
    rows: list[dict[str, Any]]
    source: str
    note: str
