"use client";

import { useState, useEffect } from "react";
import {safeFetch} from "@/lib/safeFetch";
import { Briefcase, Search, MapPin, Building2, DollarSign } from "lucide-react";

/* ------------------ TYPES ------------------ */

type Job = {
  jobId: number;
  title: string;
  companyName: string;
  location: string;
  salary: string;
  jobType: string;
  description: string;
  requirements: string;
};

/* ------------------ MAIN PAGE ------------------ */

export default function JobsPage() {
  const [jobs, setJobs] = useState<Job[]>([]);
  const [selected, setSelected] = useState<Job | null>(null);

  const [search, setSearch] = useState("");
  const [company, setCompany] = useState("");
  const [location, setLocation] = useState("");

  async function loadJobs() {
    const res = await safeFetch(
      `/jobs/search?title=${search}&company=${company}&location=${location}`
    );
    if (res.ok) setJobs(await res.json());
  }

  useEffect(() => {
    loadJobs();
  }, []);

  return (
    <div className="p-6 max-w-6xl mx-auto">
      <h1 className="text-3xl font-bold flex items-center gap-2 mb-6">
        <Briefcase className="w-8 h-8" /> Find Jobs
      </h1>

      {/* ------------------ FILTERS ------------------ */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <div className="flex items-center border rounded-lg px-3">
          <Search className="w-5 h-5 text-gray-500" />
          <input
            className="w-full p-2 outline-none"
            placeholder="Search job title..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>

        <div className="flex items-center border rounded-lg px-3">
          <Building2 className="w-5 h-5 text-gray-500" />
          <input
            className="w-full p-2 outline-none"
            placeholder="Company..."
            value={company}
            onChange={(e) => setCompany(e.target.value)}
          />
        </div>

        <div className="flex items-center border rounded-lg px-3">
          <MapPin className="w-5 h-5 text-gray-500" />
          <input
            className="w-full p-2 outline-none"
            placeholder="Location..."
            value={location}
            onChange={(e) => setLocation(e.target.value)}
          />
        </div>

        <button
          onClick={loadJobs}
          className="bg-blue-600 text-white rounded-lg px-4 py-2 font-semibold"
        >
          Search
        </button>
      </div>

      {/* ------------------ JOB LIST ------------------ */}
      <div className="space-y-4">
        {jobs.map((job) => (
          <div
            key={job.jobId}
            className="p-4 border rounded-lg hover:bg-gray-50 cursor-pointer flex justify-between"
            onClick={() => setSelected(job)}
          >
            <div>
              <p className="font-semibold text-lg">{job.title}</p>
              <p className="text-sm text-gray-600">{job.companyName}</p>

              <div className="flex gap-4 mt-2 text-sm text-gray-700">
                <span className="flex items-center gap-1">
                  <MapPin size={16} /> {job.location}
                </span>
                <span className="flex items-center gap-1">
                  <DollarSign size={16} /> {job.salary}
                </span>
              </div>
            </div>

            <button
              className="bg-green-600 text-white px-4 py-2 rounded-md"
              onClick={(e) => {
                e.stopPropagation();
                applyToJob(job.jobId);
              }}
            >
              Apply
            </button>
          </div>
        ))}
      </div>

      {/* ------------------ MODAL ------------------ */}
      {selected && (
        <JobModal job={selected} onClose={() => setSelected(null)} />
      )}
    </div>
  );
}

/* ------------------ APPLY FUNCTION ------------------ */

async function applyToJob(jobId: number) {
  await safeFetch(`/job-applications/apply/${jobId}`, { method: "POST" });
  alert("Application submitted!");
}

/* ------------------ MODAL ------------------ */

function JobModal({
  job,
  onClose,
}: {
  job: Job;
  onClose: () => void;
}) {
  return (
    <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
      <div className="bg-white w-[650px] rounded-lg p-6 shadow-xl">
        <h2 className="text-2xl font-bold mb-2">{job.title}</h2>
        <p className="text-sm text-gray-600 mb-4">{job.companyName}</p>

        <div className="space-y-3">
          <p>
            <span className="font-medium">Location:</span> {job.location}
          </p>
          <p>
            <span className="font-medium">Salary:</span> {job.salary}
          </p>
          <p>
            <span className="font-medium">Type:</span> {job.jobType}
          </p>

          <div>
            <p className="font-medium mb-1">Description:</p>
            <p className="text-gray-700 whitespace-pre-line">{job.description}</p>
          </div>

          <div>
            <p className="font-medium mb-1">Requirements:</p>
            <p className="text-gray-700 whitespace-pre-line">{job.requirements}</p>
          </div>
        </div>

        <div className="flex justify-end gap-2 mt-6">
          <button className="px-3 py-1 bg-gray-200 rounded" onClick={onClose}>
            Close
          </button>
          <button
            className="px-3 py-1 bg-green-600 text-white rounded"
            onClick={() => applyToJob(job.jobId)}
          >
            Apply
          </button>
        </div>
      </div>
    </div>
  );
}
