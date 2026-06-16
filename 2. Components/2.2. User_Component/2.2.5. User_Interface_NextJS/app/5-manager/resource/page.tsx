"use client";

import { useEffect, useState } from "react";
import { API } from "@/config";

interface DbStats {
  totalTables: number;
  totalRows: number;
  totalSize: string;
  largestTable: string;
  largestTableSize: string;
}

interface TableInfo {
  tableName: string;
  rowCount: number;
  size: string;
}

interface ColumnInfo {
  columnName: string;
  dataType: string;
  isNullable: string;
}

export default function AdminDatabasePage() {
  const [stats, setStats] = useState<DbStats | null>(null);
  const [tables, setTables] = useState<TableInfo[]>([]);
  const [columns, setColumns] = useState<ColumnInfo[]>([]);
  const [selectedTable, setSelectedTable] = useState("");
  const [query, setQuery] = useState("SELECT * FROM db_owner.user LIMIT 20;");
  const [queryResult, setQueryResult] = useState<any[]>([]);
  const [loadingQuery, setLoadingQuery] = useState(false);

  useEffect(() => {
    loadStats();
    loadTables();
  }, []);

  const loadStats = async () => {
    const res = await fetch(`${API}/admin/db/stats`, { credentials: "include" });
    const data = await res.json();
    setStats(data);
  };

  const loadTables = async () => {
    const res = await fetch(`${API}/admin/db/tables`, { credentials: "include" });
    const data = await res.json();
    setTables(data);
  };

  const loadColumns = async (table: string) => {
    setSelectedTable(table);
    const res = await fetch(`${API}/admin/db/columns/${table}`, {
      credentials: "include",
    });
    const data = await res.json();
    setColumns(data);
  };

  const runQuery = async () => {
    setLoadingQuery(true);
    try {
      const res = await fetch(`${API}/admin/db/query`, {
        method: "POST",
        credentials: "include",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ query }),
      });

      const data = await res.json();
      setQueryResult(data);
    } catch (err) {
      console.error(err);
    } finally {
      setLoadingQuery(false);
    }
  };

  return (
    <div className="p-8">
      <h1 className="text-3xl font-semibold mb-8">Database Resources</h1>

      {/* =======================
          DATABASE STATS
      ======================== */}
      {stats && (
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-10">
          <div className="p-6 bg-white shadow rounded-xl">
            <h3 className="text-lg font-semibold">Total Tables</h3>
            <p className="text-3xl font-bold mt-2">{stats.totalTables}</p>
          </div>

          <div className="p-6 bg-white shadow rounded-xl">
            <h3 className="text-lg font-semibold">Total Rows</h3>
            <p className="text-3xl font-bold mt-2">{stats.totalRows}</p>
          </div>

          <div className="p-6 bg-white shadow rounded-xl">
            <h3 className="text-lg font-semibold">Database Size</h3>
            <p className="text-3xl font-bold mt-2">{stats.totalSize}</p>
          </div>
        </div>
      )}

      {/* =======================
          TABLE LIST
      ======================== */}
      <h2 className="text-2xl font-semibold mb-4">Tables</h2>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-10">
        {tables.map((t) => (
          <div
            key={t.tableName}
            className="p-5 bg-white shadow rounded-xl hover:shadow-lg transition cursor-pointer"
            onClick={() => loadColumns(t.tableName)}
          >
            <h3 className="text-xl font-semibold">{t.tableName}</h3>
            <p className="text-gray-600 text-sm">Rows: {t.rowCount}</p>
            <p className="text-gray-600 text-sm">Size: {t.size}</p>
          </div>
        ))}
      </div>

      {/* =======================
          COLUMN LIST
      ======================== */}
      {selectedTable && (
        <div className="mb-10">
          <h2 className="text-2xl font-semibold mb-4">
            Columns in {selectedTable}
          </h2>

          <table className="w-full border rounded-xl bg-white shadow">
            <thead>
              <tr className="bg-gray-100">
                <th className="p-3 text-left">Column</th>
                <th className="p-3 text-left">Type</th>
                <th className="p-3 text-left">Nullable</th>
              </tr>
            </thead>
            <tbody>
              {columns.map((c, idx) => (
                <tr key={idx} className="border-t">
                  <td className="p-3">{c.columnName}</td>
                  <td className="p-3">{c.dataType}</td>
                  <td className="p-3">{c.isNullable}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* =======================
          QUERY EXECUTION
      ======================== */}
      <h2 className="text-2xl font-semibold mb-4">Run SQL Query (Read‑Only)</h2>

      <textarea
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        className="w-full h-40 p-4 border rounded-lg shadow mb-4"
      />

      <button
        onClick={runQuery}
        className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
      >
        {loadingQuery ? "Running..." : "Execute"}
      </button>

      {/* Query Result */}
      {queryResult.length > 0 && (
        <div className="mt-8">
          <h3 className="text-xl font-semibold mb-3">Query Result</h3>

          <div className="overflow-auto border rounded-xl bg-white shadow">
            <table className="w-full">
              <thead>
                <tr className="bg-gray-100">
                  {Object.keys(queryResult[0]).map((col) => (
                    <th key={col} className="p-3 text-left">
                      {col}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {queryResult.map((row, idx) => (
                  <tr key={idx} className="border-t">
                    {Object.values(row).map((val: any, i) => (
                      <td key={i} className="p-3">
                        {String(val)}
                      </td>
                    ))}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  );
}
