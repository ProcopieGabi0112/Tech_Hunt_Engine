"use client";

import { useState, useEffect } from "react";
import {safeFetch} from "@/lib/safeFetch";
import { Briefcase, Trash2, Eye } from "lucide-react";

/* ------------------ TYPES ------------------ */

type JobApplication = {
  applicationId: number;
  applyDate: string;
  applySource: string;
  status: string;
  salary: string;
  userId: number;
  jobId: number;
  jobTitle: string;
  companyName: string;
};

/* ------------------ MAIN PAGE ------------------ */

export default function JobApplicationsPage() {
  const [apps, setApps] = useState<JobApplication[]>([]);
  const [selected, setSelected] = useState<JobApplication | null>(null);

  async function loadApplications() {
    const res = await safeFetch("/job-applications/my");
    if (res.ok) setApps(await res.json());
  }

  useEffect(() => {
    loadApplications();
  }, []);

  return (
    <div className="p-6 max-w-6xl mx-auto">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-3xl font-bold flex items-center gap-2">
          <Briefcase className="w-8 h-8" /> My Job Applications
        </h1>
      </div>

      {/* ------------------ TABLE ------------------ */}
      <div className="overflow-x-auto border rounded-lg">
        <table className="w-full border-collapse">
          <thead className="bg-gray-100 border-b">
  <tr>
    <th className="p-3 text-left text-black font-semibold">Job Title</th>
    <th className="p-3 text-left text-black font-semibold">Company</th>
    <th className="p-3 text-left text-black font-semibold">Status</th>
    <th className="p-3 text-left text-black font-semibold">Applied On</th>
    <th className="p-3 text-center text-black font-semibold">Actions</th>
  </tr>
</thead>

          <tbody>
            {apps.length === 0 ? (
              <tr>
                <td
                  colSpan={5}
                  className="text-center p-6 text-gray-500 italic"
                >
                  No applications found
                </td>
              </tr>
            ) : (
              apps.map((app) => (
                <tr
                  key={app.applicationId}
                  className="border-b hover:bg-gray-50 cursor-pointer"
                  onClick={() => setSelected(app)}
                >
                  <td className="p-3">{app.jobTitle}</td>
                  <td className="p-3">{app.companyName}</td>
                  <td className="p-3">{app.status}</td>
                  <td className="p-3">
                    {new Date(app.applyDate).toLocaleDateString()}
                  </td>

                  <td className="p-3 text-center">
                    <div className="flex justify-center gap-3">
                      <button
                        className="text-blue-600 hover:text-blue-800"
                        onClick={(e) => {
                          e.stopPropagation();
                          setSelected(app);
                        }}
                      >
                        <Eye size={20} />
                      </button>

                      <button
                        className="text-red-500 hover:text-red-700"
                        onClick={(e) => {
                          e.stopPropagation();
                          // TODO: delete endpoint
                        }}
                      >
                        <Trash2 size={20} />
                      </button>
                    </div>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {/* ------------------ MODAL ------------------ */}
      {selected && (
        <JobApplicationModal
          app={selected}
          onClose={() => setSelected(null)}
        />
      )}
    </div>
  );
}

/* ------------------ MODAL ------------------ */

function JobApplicationModal({
  app,
  onClose,
}: {
  app: JobApplication;
  onClose: () => void;
}) {
  return (
    <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
      <div className="bg-white w-[600px] rounded-lg p-6 shadow-xl">
        <h2 className="text-2xl font-bold mb-2">{app.jobTitle}</h2>

        <p className="text-sm text-gray-600 mb-4">{app.companyName}</p>

        <div className="space-y-2">
          <p>
            <span className="font-medium">Status:</span> {app.status}
          </p>
          <p>
            <span className="font-medium">Applied on:</span>{" "}
            {new Date(app.applyDate).toLocaleDateString()}
          </p>
          <p>
            <span className="font-medium">Source:</span> {app.applySource}
          </p>
          <p>
            <span className="font-medium">Salary:</span> {app.salary}
          </p>
        </div>

        <div className="flex justify-end gap-2 mt-6">
          <button className="px-3 py-1 bg-gray-200 rounded" onClick={onClose}>
            Close
          </button>
          <button className="px-3 py-1 bg-red-600 text-white rounded flex items-center gap-1">
            <Trash2 size={16} /> Delete
          </button>
        </div>
      </div>
    </div>
  );
}
